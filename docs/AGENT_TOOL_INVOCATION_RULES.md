<!-- notion: 未镜像 -->

# AI Agent 工具接入与调用准则：GitDiagram MCP 与 Gitingest

> **适用范围**：面向 AI Coding Agent 在外部开源项目理解、架构可视化分析、上下文高密摄取场景下的标准调用与协同规则。

---

## 一、 GitDiagram MCP 接入规范

### 1. 接入现状与配置
GitDiagram MCP 已经配置至当前 Agent 运行时环境：
- **MCP 远程服务地址**：`https://gitdiagram.com/mcp`
- **配置文件**：
  - `C:\Users\15770\.gemini\antigravity\mcp_config.json`
  - `C:\Users\15770\.gemini\config\mcp_config.json`
- **挂载工具**：
  1. `get_repository_diagram`：获取仓库架构说明、组件物理路径及 Mermaid 拓扑图。
  2. `find_repository_diagrams`：按组织或项目名搜索已有架构图的开源仓库。
  3. `get_explainer_video`：获取 1 分钟解说视频链接及旁白文本。

### 2. 显式调用规则 (Explicit Invocation)
- **调用场景**：
  - 用户输入：“请画出 `xxx` 仓库的架构图” / “分析 `xxx` 的依赖拓扑” / “查看该项目 1 分钟解说视频”。
- **调用规范**：
  - 必须提供标准 `"owner/repo"` 或 `https://github.com/...` 链接；
  - 优先输出提取到的原生 Mermaid 图与关键组件路径表格；
- **失败降级通道**：
  - 若 MCP 远程连接异常，一键降级为读取 HTTP Markdown 探针：`https://gitdiagram.com/{owner}/{repo}.md`。

### 3. 触发式调用规则 (Trigger-based Invocation)
- **触发意图**：
  - 用户提出对陌生外部公开仓库（>30 文件）进行技术调研、依赖选型或设计模式借鉴；
- **执行动作**：
  - Agent 在克隆或阅读任何源码前，先静默触发 `get_repository_diagram`，快速建立宏观组件划分认知，避免盲目抓取。
- **禁调红线**：
  - 私有仓库禁止调用；
  - 单文件微调或已知文件改动禁止调用。

---

## 二、 Gitingest：方式 1 (Python SDK) 集成与调用指南

### 1. 本地集成现状
- **运行环境**：已安装 Python 库 `gitingest` (v0.3.1)；
- **专属工具脚本**：[gitingest_tool.py](file:///e:/workSpace/notion/.agents/scripts/gitingest_tool.py)；
- **实测验证**：已通过本地目录测试（提取耗时 < 1s，输出规范 JSON 统计）。

### 2. 命令行调用格式
```bash
python .agents/scripts/gitingest_tool.py <目标URL或本地子目录> -o <输出文件路径> [选项]
```
- `-i, --include`：指定包含模式，如 `'*.py,*.ts'`；
- `-e, --exclude`：排除模式，如 `'*test*,*docs*,*dist*'`；
- `--max-size`：单文件上限，默认 50000 字节；
- `--json`：输出结构化预估 Token 统计。

### 3. 告知 Agent 何时调用 (When to Invoke)

| 场景分类 | 具体情况 | Agent 动作 |
| :--- | :--- | :--- |
| 🟢 **必须调用** | 需深入理解包含 5~15 个相互引用文件的子模块（如路由层、认证层） | 执行 `gitingest <子目录路径> -i "*.py" -o /tmp/context.txt`，单次提取打包 |
| 🟢 **必须调用** | 需将外部优秀开源项目的某个核心设计作为参考样例注入 Prompt | 针对目标仓库特定子路径执行定向提取 |
| 🔴 **严格禁用** | 面对大型仓库（>100 文件）未设置任何 include/exclude 过滤时 | **禁止全量摄取**，必须先用 GitDiagram 拆分子目录 |
| 🔴 **严格禁用** | 仅需查看系统整体架构、技术栈选型与模块拓扑时 | **禁止调用 Gitingest**，必须使用 GitDiagram MCP |
| 🔴 **严格禁用** | 单点代码定位、单函数 Bug 修复 | **禁止调用**，使用行号定位工具直接外科手术式替换 |

---

## 三、 双工具联动：三级漏斗模型实操步骤

```
[第一步：宏观定焦] ➔ GitDiagram MCP
  - 获得目标仓库顶层架构树、组件名单及关键目录 (Token 消耗: <3k)
         │
         ▼
[第二步：微观收割] ➔ Gitingest Python SDK
  - 定位到核心业务目录后，针对性打包该目录源码 (Token 消耗: 10k~30k)
         │
         ▼
[第三步：外科手术] ➔ 本地 Read / Edit Tools
  - 定位行号，精准微创修改，跑测试验收闭环
```
