---
name: notion-architect
description: 科学使用 Notion 知识库排版与多级分页架构规范。仅在 PM 明确同意后单向镜像本地定稿文档；严格执行去 AI 机械味、严禁输出本地真实路径、更新不新建与 //specs->index 聚合。
---

# Notion Architect (Notion 知识架构与去 AI 味规范)

本规范专用于指导 Agent 科学、专业、高品位地使用 Notion，杜绝粗制滥造的“AI 味”排版，将 Notion 打造成杂志级、结构严密的人类高级知识库。

> **权威知识源**：
> 1. Notion 官方 Skill 库：`https://github.com/makenotion/skills`
> 2. Notion 官方 Help Center：Wikis & Knowledge Management Best Practices
> 3. Tiago Forte 的 PARA 知识管理哲学（Projects / Areas / Resources / Archives）

---

## 〇、 核心铁律（Anti-AI Slop Ironclads）

1. **绝对禁止代码块倒垃圾 (No Raw Code Dump)**：
   - 🚨 **严禁**将知识库文章、记忆内容、配置清单外层套上 ````markdown ... ```` 或任何语言代码块扔在 Notion 页面中！
   - Notion 是现代富文本协作工具，不是控制台日志。所有文字、列表、标题必须直接解析渲染为 Notion 原生富文本块。代码围栏仅允许用于**真正的、不超过 30 行的代码片段**。
2. **严禁扁平流水账长滚屏 (No Flat Wall of Text)**：
   - 🚨 **严禁**把几十条知识、记忆、日志无差别罗列在同一个页面的垂直线性流里！
   - 必须实施**多级物理分页（Subpage Tree）**，确保 Notion 左侧侧边栏能够逐层展开（折叠树层级），每页单屏滚动不超过 2-3 屏。
3. **严禁虚假元数据堆砌 (No Repetitive Metadata Fluff)**：
   - 🚨 **严禁**在每个正文段落机械重复 `- **重要度**：5/5 - **召回频次**：7次 - **状态**：激活` 这种死板且充满 AI 痕迹的文本块。
   - 元数据应当作为页面顶部的属性 Callout 或简短小徽章（如 `🟢 核心规范` `⚡ 活跃`），正文直入业务实质。
4. **渐进式披露与折叠原则 (Progressive Disclosure)**：
   - 凡是背景推导、历史上下文、详细报错日志或长配置，一律使用 **Toggle 折叠列表（`<details><summary>` / 折叠块）** 收纳。主页面只呈现结论与关键行动项。
5. **严禁标题重复写入 Emoji 图标 (No Duplicate Emoji in Title)**：
   - 🚨 **严禁**在页面标题（`title` 文本）前缀重复添加与页面 `icon` 相同的 Emoji！
   - Notion 会在侧边栏和页面顶部原生渲染 `icon` 属性。若在 `properties.title` 中再次写入 Emoji，会导致界面出现 `🎨 🎨 标题` 的双重图标灾难。设置了原生 `icon` 后，标题文本必须为纯净文字。

---

## 一、 知识库三级深度架构 (3-Tier Hierarchy)

Notion 知识库必须严格按照三级物理目录组织，确保在左侧目录树清晰可导航：

```
Level 1: 🏛️ 全局知识总览台 (Master Hub / Wiki Root)
 ├── 🎨 设计与 UI/UX 审美字典 (L2 Topic Portal)
 │    ├── 🎨 UI 设计审美底线与反 AI 味规范 (L3 Atomic Page)
 │    ├── 🖥️ B端 5 大交互原型字典 (L3 Atomic Page)
 │    └── ...
 ├── 🛠️ 全局工程哲学与开发规范 (L2 Topic Portal)
 │    ├── ⚡ 极简主义与四层复用漏斗 (L3 Atomic Page)
 │    ├── 🩺 依赖真实验证与证伪探针规范 (L3 Atomic Page)
 │    └── ...
 ├── 📁 业务实战档案库 (L2 Topic Portal)
 └── ⚙️ 系统底座与基础设施 (L2 Topic Portal)
```

### 1. Level 1: 全局知识总览台 (Master Wiki Hub)
- **定位**：顶层仪表盘（Dashboard）。
- **页面构成**：
  - 顶部 Callout：知识库愿景与全局维护原则（1-2 句）。
  - 中部导航矩阵：使用带有 Emoji 的卡片式链接直达 4-6 个 L2 主题门户。
  - 底部快速检索：高频标签直达或最近重大更新动态。
  - **禁忌**：禁止在 L1 放置任何长正文。

### 2. Level 2: 领域主题中心 (Topic Portal)
- **定位**：细分垂直领域的“入口大厅”。
- **页面构成**：
  - 领域使命与核心原则（Callout）。
  - 子页面导航树（Child Pages Index）：明确列出下属所有 L3 页面的直达链接与一句话摘要。
  - 核心执行清单（Checklist / KPI）。
  - **禁忌**：禁止把 L3 的所有正文直接展开排在 L2。

### 3. Level 3: 原子知识详情页 (Atomic Knowledge Page)
- **定位**：具体某项规约、模式或项目的单一事实来源（Single Source of Truth）。
- **页面构成**：
  - 顶部属性卡：适用范围、触发关键词、版本状态。
  - 正文排版：
    - `> 💡 核心原则`：一句话定调。
    - 正反例对照表（DO / DON'T Table）：用表格清晰对比。
    - 实战范例与代码（短代码或 Toggle 折叠）。
    - 常见边界与排错指南。

---

## 二、 Notion 排版视觉字典 (Typography & Styling)

| 视觉元素 | 适用场景 | Markdown / Notion 规范写法 |
|---|---|---|
| **Callout 容器** | 核心警示、最高准则、关键背景 | `> 💡 **核心原则**：...` 或 `> 🚨 **高危红线**：...` |
| **Toggle 折叠** | 详细日志、长配置、推导过程 | `<details><summary>🔍 查看详细排查日志</summary>...</details>` |
| **对比表格** | 规范的正反案例、方案选型 | `\| 规范项 \| ❌ 错误示范 \| ✅ 正确示范 \|` |
| **层级标题** | 清晰的大纲层级（目录大纲） | `#` 用于标题，`##` 用于大模块，`###` 用于细分知识点 |
| **行内重点** | 强调关键术语与命令 | 使用行内代码标亮 `` `Command` ``，避免全段粗体 |

---

## 三、 Notion MCP 工具调用操作规范

当 Agent 使用 Notion MCP 处理页面时，必须遵循以下执行规约：

1. **创建子页面**：
   - 必须调用 `API-post-page`，将 `parent` 显式设为目标父页面的 `page_id`：
     ```json
     {
       "parent": { "page_id": "<parent_page_uuid>" },
       "icon": { "type": "emoji", "emoji": "🎨" },
       "properties": {
         "title": [{ "type": "text", "text": { "content": "页面标题" } }]
       }
     }
     ```
   - 这一步会产生真实的 Notion 物理子页面，使左侧导航栏具备折叠箭头。

2. **写入页面正文**：
   - 紧接着调用 `API-update-page-markdown`，传入精美排版的 Markdown 字符串：
     ```json
     {
       "page_id": "<new_page_uuid>",
       "type": "replace_content",
       "replace_content": {
         "new_str": "# 标题\n\n> 💡 导读...\n\n..."
       }
     }
     ```
   - 确保正文**不包含**外层 ````markdown ```` 围栏，直接输出干净文本。

3. **双向锚点链接**：
   - 父页面必须包含指向子页面的引用或超链接；子页面顶部可设置返回父页面的面包屑链接。

---

## 四、 研发方案与文档 Notion 镜像规范 (`//specs -> index` 聚合机制)

> **触发门禁**：仅在全局 `AGENTS.md` 规定的镜像时机触发（PM 明确说“归档/同步 Notion”，或定稿确认询问 PM 获同意后）。**严禁因本地生成了文档而自动触发！**

1. **本地原件优先与对话框契约**：
   - 本地 `docs/` 文件为唯一原件与事实真理源；
   - 严禁在对话流中直接倾倒超过 10 行正文，仅输出 2~3 行核心结论 + 本地 `file:///` 绝对物理路径。
2. **唯一收口母表锚点 (`//specs -> index`)**：
   - **L1 顶层入口 (`//specs`)**：Page ID `3f61f046-7a64-802e-94b3-efe70ffe7963`
   - **中枢数据库 (`index`)**：Database ID `3f61f046-7a64-805e-8497-d54d82f2ab3f`（Data Source ID: `3f61f046-7a64-80ce-b07e-000bf8edfcd5`）
   - **防乱铁律**：所有镜像文档统一作为行记录写入 `index` 数据库（`parent: { "database_id": "3f61f046-7a64-805e-8497-d54d82f2ab3f" }`），**严禁**在 `//specs` 下直接创建游离单页，**严禁**为每个项目单独新建物理分表。
   - **更新不新建**：同一文档定稿修订再次同步时，更新原页面内容，禁止新建重复页面。
3. **标准 4 列属性写入规约（覆盖 `specs` · `learn` · `retro` 三大视图）**：
   - **`Kind` 标准分类矩阵（仅限下列 12 类，其余类型不镜像）**：
     - **`📁 specs`（工程研发）**：`调研` | `架构` | `计划` | `测试` | `部署`
     - **`👓 learn`（技术学习）**：`学习计划` | `原理剖析` | `阶段测试` | `速查手册`
     - **`🛢️ retro`（复盘沉淀）**：`Bug 复盘` | `设计经验` | `性能调优`
   ```json
   {
     "parent": { "database_id": "3f61f046-7a64-805e-8497-d54d82f2ab3f" },
     "icon": { "type": "emoji", "emoji": "📐" },
     "properties": {
       "Name": { "title": [{ "text": { "content": "<名称，如 auth-jwt>" } }] },
       "Project": { "select": { "name": "<项目或技术栈名，如 core / rust>" } },
       "Kind": { "select": { "name": "<对应上述 12 个标准枚举之一>" } },
       "Status": { "status": { "name": "In progress" } }
     }
   }
   ```
4. **卡片内部标准排版（严禁输出本地真实物理路径）**：
   - **隐私与排版红线**：严禁在正文顶部输出本地物理绝对路径（如 `C:/Users/...` 等私有路径）。文档归属由 Notion 数据库的 `Project` 与 `Kind` 属性承载，正文保持纯净，杜绝机械元数据堆积与内部路径泄露。
   - **顶部目标**：`> 💡 **核心目标**：...`（2 行定调）
   - **架构拓扑**：原生 ````mermaid ```` 流程图/时序图代码块
   - **执行清单**：原生 `- [ ]` 交互式可勾选待办
   - **推导演化**：`<details><summary>🔍 查看演化推导与决策背景</summary>...</details>` 折叠收纳

---

## 五、 交付前反 AI 味自检清单

在向 PM 宣布 Notion 更新完成前，必须逐项自检：
- [ ] 是否存在把大段文档塞在代码块里的情况？（若有，立即拆解成原生排版）
- [ ] 研发规范是否已严格写入 `index` 数据库（`3f61f046-7a64-805e-8497-d54d82f2ab3f`），未在侧边栏产生散乱子页面？
- [ ] 对话框回复是否已收敛为 2~3 行极简摘要 + 直达链接？
- [ ] 是否运用了 Callout 提升视觉层级，运用了 Toggle 收纳低频次长篇细节？
- [ ] 表格、正反例是否工整清晰，杜绝了死板的机械元数据堆积？
