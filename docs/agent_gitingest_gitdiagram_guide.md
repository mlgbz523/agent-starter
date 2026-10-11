<!-- notion: 未镜像 -->

# Gitingest 与 GitDiagram：AI Agent 落地实践与全流程协同指南

> **核心摘要**：`gitingest` 与 `gitdiagram` 是当前 AI Agent 接入与理解代码仓库的两大互补利器。GitDiagram 负责**“自顶向下建立宏观架构心智模型”**（宏观），Gitingest 负责**“按需过滤并高效打包代码上下文”**（微观）。两者配合构成了 Agent 探索未知代码库的标准漏斗工作流。

---

## 一、 项目定位与本质差异对比

| 维度 | Gitingest (`coderamp-labs/gitingest`) | GitDiagram (`ahmedkhaleel2004/gitdiagram`) |
| :--- | :--- | :--- |
| **项目定位** | 代码库上下文打包与摄取引擎 (Code Ingestion Engine) | 代码库架构语义可视化与拓扑分析器 (Architecture Visualizer) |
| **Agent 解决的痛点** | 解决“文件分散、逐个读取耗尽轮次、上下文格式混乱”的问题 | 解决“新接触复杂项目盲人摸象、缺乏全局宏观拓扑结构”的问题 |
| **输出形式** | 扁平化合并文本 (包含树形目录、文件大小、Token 统计与文件代码块) | 架构概览 Markdown、Mermaid 拓扑图、组件职责关联表、一分钟解说视频 |
| **上下文粒度** | **全量/局部源码级 (Code-level)**，为单次深推理提供上下文 | **架构/语义抽象级 (Architecture-level)**，Token 极省 (通常 2k~5k) |
| **与 Agent 交互方式** | Python SDK、CLI 命令行、Web API (`gitingest.com/api/...`) | 官方远程 MCP 服务器 (`/mcp`)、Markdown 镜像 (`/owner/repo.md`) |

---

## 二、 GitDiagram：Agent 的宏观架构导航仪

### 1. 方式一：远程 MCP 服务器接入 (首选，原生工具调用)
GitDiagram 官方直接托管了无需鉴权、开箱即用的远程 MCP 服务：
- **MCP 服务端地址**：`https://gitdiagram.com/mcp`
- **认证方式**：免 API Key，免登录

#### 在主流 Agent 环境中的配置方式：
- **Antigravity / Cursor / Windsurf (`mcp.json`)**：
```json
{
  "mcpServers": {
    "gitdiagram": {
      "type": "http",
      "url": "https://gitdiagram.com/mcp"
    }
  }
}
```
- **Claude Code CLI**：
```bash
claude mcp add --transport http gitdiagram https://gitdiagram.com/mcp
```
- **Codex / Gemini CLI**：
```bash
codex mcp add gitdiagram --url https://gitdiagram.com/mcp
gemini extensions install https://github.com/ahmedkhaleel2004/gitdiagram
```

#### Agent 调用效果：
Agent 会直接挂载工具 `get_architecture`。当用户询问“请帮我分析 fastchat 架构”时，Agent 自动调用该工具，瞬间获取仓库分层、组件清单与交互链路，避免直接 clone 动辄数百兆的仓库。

---

### 2. 方式二：轻量 Markdown 探针 (零安装免配置)
如果 Agent 尚未配置 MCP 工具，可以直接使用 HTTP 抓取探针：
- **URL 映射规范**：`https://gitdiagram.com/{owner}/{repo}.md`
- **特点**：返回干净的纯 Markdown 文本，包含系统概览、Mermaid 关系图以及带源文件跳转链接的组件清单。
- **示例**：
```bash
curl -s https://gitdiagram.com/coderamp-labs/gitingest.md
```

---

## 三、 Gitingest：Agent 的代码上下文高效收割机

### 1. 方式一：Python SDK 原生集成 (自研 Agent / Tool 最佳实践)
`gitingest` 提供了第一方 Python 库，支持异步与同步调用，可方便地包装为 Agent 的自定义 Tool：

```bash
pip install gitingest
```

```python
from gitingest import ingest

# 1. 摄取整个远程 GitHub 仓库
summary, tree, content = ingest("https://github.com/psf/requests")

# 2. 定向摄取：带包含/排除规则，控制 Token 预算
summary, tree, content = ingest(
    "https://github.com/pallets/flask",
    include_patterns={"src/flask/*.py", "README.md"},
    exclude_patterns={"*test*", "*docs*"},
    max_file_size=50_000  # 限制单文件最大体积
)

print(summary)  # 包含预估 Token 数、文件数统计
print(tree)     # 格式化目录树
# content 可直接拼接送入 LLM Prompt
```

---

### 2. 方式二：CLI 命令行直接执行 (本地 Agent 终端环境)
当 Agent 拥有终端执行权限时，可以直接调用 CLI 将代码精炼打包到本地暂存文件：

```bash
# 全局安装
pip install gitingest

# 将目标仓库（或本地目录）导出为单个提示词友好的文本
gitingest https://github.com/owner/repo -o /tmp/repo_context.txt

# 本地工作区用法：快速提取特定模块
gitingest ./src/core -e "*test*" -o /tmp/core_context.txt
```

---

### 3. 方式三：Web API 无状态读取 (免克隆临时调用)
- **API 端点**：`GET https://gitingest.com/api/{owner}/{repo}`
- **输出格式**：包含 `summary`、`digest_url` 等结构化 JSON，可用于低开销直接获取打包后的预编译文件。

---

## 四、 协同实战：Agent 探索复杂代码库的【漏斗工作流】(Macro-to-Micro)

在实际工程落地中，**坚决反对 Agent 一上来就全量抓取代码**（极易击穿上下文窗口，且浪费海量 Token）。最科学的协作链路如下：

```
                    ┌──────────────────────────────────────┐
                    │ 用户提出需求："为项目 X 增加鉴权中间件"│
                    └──────────────────┬───────────────────┘
                                       │
                                       ▼
    【阶段一：宏观定焦】                 GitDiagram (MCP / .md)
    • 获取系统顶层拓扑图
    • 识别关键组件：Router, Auth, Middleware 目录位置
    • 耗费 Token：~3k
                                       │
                                       ▼
    【阶段二：模块收割】                 Gitingest (SDK / CLI)
    • 针对识别出的模块进行定向提取
    • `gitingest ./src/middleware -i "*.py"`
    • 耗费 Token：~15k
                                       │
                                       ▼
    【阶段三：外科手术修改】             本地 Read / Edit Tools
    • 定位具体行号进行精确 Diff 替换
    • 运行测试完成验证
```

### 总结选型建议：
- **用 GitDiagram**：宏观调研、架构评审、新人串讲、快速理清陌生项目技术栈与组件关系。
- **用 Gitingest**：代码分析、Prompt 打包、跨文件重构、将现有代码作为参考样本注入上下文。
