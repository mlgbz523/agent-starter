<!-- notion: 未镜像 -->

# Archify (tt-a1i/archify) 全景架构与工程实现深度剖析

> **项目定位**：开源交互式系统架构可视化与交付工具，基于 AI Agent 技能体系（Agent Skill）驱动，将代码证据、系统描述或业务流程编译为完全自包含、可深度交互的单文件 HTML 作品。  
> **官方仓库**：[tt-a1i/archify](https://github.com/tt-a1i/archify) (v3.0.1) · **官方站点**：[archify.si](https://archify.si)

---

## 一、 项目背景与核心设计哲学 (Core Philosophy)

Archify 并非传统意义上的“流程图/Mermaid 美化脚本”，而是一个**专为 AI Coding Agent 设计的可验证可视化编译流水线与交互式运行引擎**。

```
                    ┌─────────────────────────┐
                    │   用户自然语言 / 代码库  │
                    └────────────┬────────────┘
                                 │ Agent 提取与结构化
                                 ▼
                    ┌─────────────────────────┐
                    │   5 种类型 JSON-IR 契约   │
                    └────────────┬────────────┘
                                 │ CLI 编译器流水线
                                 ▼
      ┌───────────┬─────────────┬───────────┬──────────────┐
      │ validate  │   deliver   │   check   │browser-check │
      │ 静态合规  │  渲染编译   │  摘要校验 │ 无头真实渲染 │
      └───────────┴─────────────┴───────────┴──────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │  独立单文件 HTML 交付物   │
                    │ (内置微型交互 Canvas 引擎) │
                    └─────────────────────────┘
```

### 1. 核心价值观 (Design Principles)
1. **证据重于炫技 (Truth before spectacle)**：
   - 拒绝生成虚无缥缈的“概念图”，图表中的每一个焦点、可达性分析、路由链路与源码链接，必须严格绑定真实代码凭证（Repository Evidence）或人工明确定义的契约。
2. **单一空间叙事优先 (One spatial narrative first)**：
   - 优先保证主业务路径（Primary Path）的直观清晰，次级关系与详细细节通过交互渐进披露，避免信息过载。
3. **确定性自动化验证门禁 (Deterministic verification)**：
   - 绝不依赖 Agent 口头声称“已画好”，必须通过真实的无头 Chrome 浏览器进行布局、尺寸、溢出与路由重叠交叉硬校验。
4. **便携式单文件交付 (Zero-runtime portable proof)**：
   - 输出物是 100% 独立离线的 HTML，零外部 CDN 依赖、零运行时服务依赖，直接发送或离线双击即可完整保留全套交互与动画。
5. **严禁语义漂移 (Identity without semantic drift)**：
   - 支持引入官方品牌徽标（基于 Simple Icons），但通过 SHA-256 摘要强锁定，禁止模糊匹配导致系统组件身份偏离。

---

## 二、 仓库全局拓扑与目录职责 (Repository Anatomy)

整个仓库由以下核心层次紧密协作构成：

| 根目录 / 模块 | 核心职责 | 技术实现与关键文件 |
| :--- | :--- | :--- |
| **`archify/`** | **核心 Agent Skill 包与 CLI 工具** | 安装入口，内含 `SKILL.md`、CLI 命令入口 `bin/archify.mjs` |
| ├─ `bin/` | CLI 运行时与自动化门禁 | `archify.mjs` (CLI 主入口), `finalize.mjs` (四阶段强检验流水线), `visual-check.mjs` (无头浏览器探针) |
| ├─ `renderers/` | 图形渲染与编译引擎 (Node ESM) | 五大模式专属渲染器 (`architecture`, `workflow`, `sequence`, `dataflow`, `lifecycle`) 及共享几何/排版库 (`shared/`) |
| ├─ `schemas/` | JSON-IR 强类型契约体系 | `architecture.schema.json`, `workflow.schema.json`, `sequence.schema.json` 等规范定义 |
| ├─ `references/` | Agent 渐进式作者上下文手册 | 包含作者契约 (`authoring-contract.md`)、交付标准 (`delivery-contract.md`)、排版修复指南 (`architecture-layout-repair.md`) |
| ├─ `delta/` | 架构演进差异比对引擎 | `architecture-delta.mjs`，支持对前后两次架构进行 Diff 并渲染差异高亮标记 |
| ├─ `assets/` | 编译底座模版与内置字体 | `template.html` (已编译的单文件运行时壳体), `JetBrains Mono` 字体嵌入规范 |
| **`viewer/`** | **交互式 Viewer 前端运行时源码** | 模块化 JS，通过 `scripts/generate-viewer.mjs` 合成并嵌入 `archify/assets/template.html` |
| **`website/`** | **官方网站与互动展厅 (Proof Lab)** | 基于 Astro 框架搭建的静态站点，负责线上展示、社区案例库与快速上手引导 |
| **`examples/`** | **11 类官方标准场景用例** | 包含 Web App 架构、缓存未命中时序、Agent 工具调用、数据血缘分析等真实 JSON 样本 |
| **`benchmarks/`** | **基准测试与自愈实验** | 普通模型表现下限评估 (`ordinary-model-floor`)、排版错误自主修复轮次测试 (`repair-rounds`) |
| **`journal/`** | **工程研发白皮书与演化日志** | 60+ 篇深入记录架构演进、A* 寻路优化、防穿透探针、视觉平衡度调优的真实工程日志 |

---

## 三、 五大图表类型与 JSON-IR 契约体系 (The 5 Types Router)

Archify 明确将系统结构映射划分为 5 种正交的表达模式，杜绝用“通用流程图”混淆特定业务语义：

```
                    ┌───────────────────────────────┐
                    │        Archify 类型路由器      │
                    └───────────────┬───────────────┘
         ┌──────────────┬───────────┴────┬──────────────┬──────────────┐
         ▼              ▼                ▼              ▼              ▼
   architecture      workflow        sequence        dataflow      lifecycle
  (系统架构拓扑)   (流程与工具调用)  (交互时序请求链路) (数据流与血缘管道)(状态机与生命周期)
```

1. **`architecture` (系统架构与边界模型)**：
   - **适用**：微服务拓扑、云环境边界、安全域网络分区、代码组件从属关系。
   - **核心概念**：`nodes`、`relationships`、`boundaries` (网络/租户隔离边界)、`sources` (源码行号直连)。
2. **`workflow` (工作流与决策流水线)**：
   - **适用**：AI Agent 决策循环、工具调用步骤、CI/CD 构建与人工审批门禁。
   - **核心概念**：步骤阶段（Stages）、分支判定（Decisions）、工具调用回执、并行流。
3. **`sequence` (时序调用与调用链)**：
   - **适用**：分布式系统请求生命周期、RPC 链路、缓存命中/未命中回源时序。
   - **核心概念**：参与者生命线（Lifelines）、同步/异步消息（Messages）、时序片段与激活态。
4. **`dataflow` (数据流向与血缘治理)**：
   - **适用**：ETL/ELT 管道、消息队列流转、数据消费与模型训练血缘。
   - **核心概念**：数据源（Sources）、处理算子（Transforms）、数据池（Sinks）、血缘穿透。
5. **`lifecycle` (状态跃迁与有限状态机)**：
   - **适用**：订单状态变化、实例生命周期、重试策略与不可逆终态。
   - **核心概念**：初态/过渡态/终态（Terminal States）、触发事件（Triggers）、回退路径。

---

## 四、 编译渲染器与几何路由引擎 (Renderers & Routing Engine)

Archify 内部的渲染器引擎位于 `archify/renderers/`，完全使用现代原生 Node.js ESM 编写，其核心算法包含：

### 1. 空间网格与端口扩散 (Spatial Grid & Port Spreading)
- 节点不再随机堆叠，而是被吸附在逻辑网格上；
- 同一节点引出多条关系边时，系统使用 `automatic-port-spread.mjs` 算法，动态计算端口锚点（Top/Bottom/Left/Right 偏移量），防止连线根部重合粘连。

### 2. 智能避障路由系统 (Orthogonal Routing & Crossover Avoidance)
- 连线采用正交折线（Manhattan Routing）；
- 具备自动碰撞检测，如果连线穿透其他组件，会自动计算避让折点（`via` 坐标）；
- 若布局产生不可避免的立体交叉（Crossovers），在收尾阶段会给出明确的重构修复建议（`resolvedCrossovers`）。

### 3. 原子化输出与状态保护 (`atomic-output.mjs`)
- 编译输出不是粗暴直接覆盖文件，而是采用原子临时写入 + 严格哈希签名校验（SHA-256） + 安全重命名的 POSIX/NTFS 安全写入机制，杜绝并发竞争或崩溃产生残缺 HTML。

---

## 五、 四阶段闭环交付门禁 (`finalize` Pipeline)

为杜绝传统 AI “自编自演、宣称搞定却全是 Bug”的虚假验收，Archify 建立了极严格的物理检验流水线：

```
[Agent 提交 JSON-IR]
        │
        ▼
   Stage 1: validate (Schema 静态合法性校验)
        │ ❌ 失败 ➔ 拦截并输出精确字段报错
        ▼
   Stage 2: deliver (SVG/DOM 计算并打包单文件 HTML)
        │ ❌ 失败 ➔ 拦截并输出排版计算异常
        ▼
   Stage 3: check (严格产物指纹与 Provenance 校验)
        │ ❌ 失败 ➔ 拦截并提示文件哈希损坏
        ▼
   Stage 4: browser-check (无头 Chrome 真实渲染检测)
        │ ❌ 失败 ➔ 拦截视口溢出、文字截断、样式崩溃
        ▼
[输出通过回执 (Receipt) ➔ 交付给用户]
```

### 关键实现：`bin/visual-check.mjs` (无头浏览器探针)
- 自动检测本地已安装的 Chrome / Chromium 浏览器；
- 以无头管道模式运行，实际加载生成的 `.html`；
- 执行深度页面诊断：检查控制台报错、DOM 挂载异常、视口尺寸自适应表现，确保在手机端与桌面端均能完美排版。

---

## 六、 独立 Viewer 运行时架构 (The Standalone Canvas)

编译生成的每个 HTML 文件都内置了轻量级原生 JavaScript 交互系统（源码位于 `viewer/`，体积极度克制，无 React/Vue 等框架开销）：

1. **虚拟摄像机系统 (`viewer-camera.js`)**：
   - 具备平滑惯性缩放（Zoom）、视口拖拽（Pan）、一键居中（Fit to Screen）与节点聚焦平移。
2. **定向路径探测器 (`route-probe.js`)**：
   - 支持高亮特定链路（如点击“浏览器”到“PostgreSQL”，自动点亮沿途所有经过的网关、微服务与缓存节点，暗化无关节点）。
3. **可达性影响分析 (`focus.js`)**：
   - 点击任一关键节点，一键开启“向下游追踪 (Reach Downstream)”或“向上游溯源 (Reach Upstream)”，用于微服务故障影响面分析或系统重构评估。
4. **语义透镜与全局雷达 (`semantic-lens.js` & `semantic-radar.js`)**：
   - 按照组件角色（前端/后端/数据库/云边界/安全组）进行一键分类高亮与隐藏；
   - 画面右下角具备 Mini-Map（鹰眼小地图），支持快速导览大体量系统架构。
5. **多维多媒体导出引擎 (`export.js`)**：
   - 纯客户端无损导出为 SVG 矢量图、高清 PNG 图片；
   - 支持导出专属的 **Route Share Card** 与 **Reach Share Card**（高信息密度结构分享卡片）；
   - 支持录制生成 **WebM 动效视频**，供汇报演说与文档嵌入。

---

## 七、 对现代 AI Agent 架构体系的深刻启示

Archify 为当代 AI Agent 工程化提供了标杆级的示范：

1. **结构化中间表示（JSON-IR）胜过自由代码生成**：
   - 让大模型直接写成千上万行 SVG/HTML 极易出现闭合错误、样式冲突与无法自愈；
   - 让大模型聚焦于输出严格 Schema 约束的 JSON 语义拓扑，由确定性引擎负责布局渲染，是保证 100% 成功率的最优解。
2. **退出码与多阶段回执（Receipts）是防幻觉唯一解**：
   - CLI 必须具备严格的非零退出码（Non-zero exit code）；
   - 输出结构化的 `summaryReceipt`，使 Agent 在报错时能精准根据报错信息定点自愈（Self-repair），而不是盲目重试。
3. **渐进式作者手册（Progressive Disclosure）**：
   - 通过 `SKILL.md` 引导 Agent 按需读取 `references/authoring-defaults.md`、`references/delivery-contract.md`，有效控制上下文 Token 窗口，实现超高密度知识的高效供给。
