---
description: 外部代码库智能理解与上下文提取规约 (GitDiagram MCP & Gitingest)
globs: ["**/*"]
always_on: true
---

# 07-Codebase Intelligence and Tools Rules

> **规范目的**：防止 Agent 在接手外部开源项目或分析大型仓库时“盲人摸象”、“逐文件读取浪费巨量轮次”或“全量倾倒击穿 Token 预算”，建立标准化的宏观拓扑嗅探与微观模块收割两级体系。

---

## 一、 GitDiagram MCP 规则 (宏观架构导航仪)

### 1. 显式调用规则 (Explicit Invocation)
当用户或任务明确要求“绘制架构图”、“分析项目模块拓扑”或“查看项目解说”时，Agent 必须通过 MCP 显式调用以下工具：

- **工具 1：`gitdiagram_get_repository_diagram`**
  - **调用时机**：需要特定公开仓库的全局分层、模块依赖、Mermaid 流程图或 GitHub 源码直达链接时。
  - **入参规范**：`repository`: `"owner/repo"` 格式（如 `"fastapi/fastapi"`）或任意公开 GitHub URL。
  - **处理返回**：直接提取结构化概览与 Mermaid 块呈报 PM，无需重新让 LLM 发明图表。
  - **降级通道**：若远程 MCP 瞬时超时或不可用，立即降级为读取轻量 HTTP Markdown 探针：`https://gitdiagram.com/{owner}/{repo}.md`。

- **工具 2：`gitdiagram_find_repository_diagrams`**
  - **调用时机**：用户给出的开源库名称模糊、组织名未知，或需要检索相似领域已有的架构图时。
  - **入参规范**：`query`: 项目名关键词（如 `"langchain"`）；`limit`: 1~10。

- **工具 3：`gitdiagram_get_explainer_video`**
  - **调用时机**：用户明确提出“看视频 / 听讲解 / 1分钟速读”该项目时。
  - **处理返回**：提供视频播放链接及旁白全稿（Narration Transcript）。

### 2. AGENTS.md 层的触发式调用规则 (Implicit Triggers)
在没有显式要求画图的情况下，凡命中以下触发条件，Agent **必须在动笔/阅读源码前静默触发 GitDiagram MCP**：
- 🎯 **触发词与意图**：
  - 用户提出“帮我了解/研究/参考 GitHub 上的 `xxx/yyy` 项目”；
  - 用户要求为当前项目引入、对比或借鉴某个开源库的技术架构；
  - 任务涉及阅读一个从未涉足过的外部公开仓库（> 30 个源文件）。
- 🚫 **阻断与禁调红线**：
  - 私有仓库严禁调用（GitDiagram 远程 MCP 仅索引公开仓库）；
  - 已在本地克隆且只需改动单个已知配置的小任务，严禁调用（避免无谓网络开销）。

---

## 二、 Gitingest 规则 (方式 1：Python SDK / 脚本收割机)

### 1. 本地集成规范与显式调用 (Tool Specification)
Agent 统一使用本地标准化工具脚本 `.agents/scripts/gitingest_tool.py` 或直接调用 `gitingest` Python 模块：

```bash
# 标准命令行调用 (输出结构化 JSON 元数据 + 写入上下文文件)
python .agents/scripts/gitingest_tool.py <目标URL或本地子目录> -o <输出文件路径> [选项]
```

- **参数规约**：
  - `-i, --include`: 必须配合包含过滤（如 `'*.py,*.ts'`），杜绝无节制泛抓；
  - `-e, --exclude`: 必须排除测试、文档与构建产物（如 `'*test*,*docs*,*dist*'`）；
  - `--max-size`: 默认锁定单文件 50KB（50000 字节）；
  - `--json`: 用于首轮探测预估 Token 数。

### 2. 触发式调用规则：Agent 何时调用？ (When to Invoke)
- ✅ **允许且强烈建议调用的时机**：
  1. **跨多文件紧密依赖分析**：需要理解一个子包（如 `src/core/router/`）内 5~15 个相互引用的文件时，一键打包成单份上下文，消除单文件逐次读取带来的 10+ 轮 Tool Calls 延迟。
  2. **跨仓库参考范式引入**：需要将某个外部优质开源项目的特定核心实现模块作为 Few-Shot 样本注入 Prompt 时。
  3. **模块重构或编写单元测试**：针对特定微服务或组件生成完整覆盖测试，需要统览该模块全貌时。
- ❌ **严禁调用红线 (Forbidden Scenarios)**：
  1. **禁止全库盲目吞吐**：严禁在未加 `--include` 或未加目录约束的情况下，对超过 100 个文件的大型项目执行全库 ingest（防止击穿上下文窗口并产生高昂 Token 费用）。
  2. **宏观架构阶段禁调**：在仅需了解技术栈和组件划分时，严禁使用 Gitingest，必须使用 GitDiagram MCP。
  3. **单点 Bug 修复禁调**：如果仅是修改单行语法或定位已知函数，直接使用行号定位工具，严禁动用 Gitingest。

---

## 三、 黄金协作范式：Macro-to-Micro 漏斗三步法

在分析或重构大型项目时，Agent 必须遵循以下漏斗法则：
1. **第 1 步【宏观定焦】**：调用 `gitdiagram_get_repository_diagram` 获知顶层组件与模块物理路径；
2. **第 2 步【微观收割】**：对锁定的关键子目录执行 `gitingest_tool.py` 定向生成上下文；
3. **第 3 步【外科手术】**：在当前工作区利用行号定位工具实施精准编辑与测试验证。
