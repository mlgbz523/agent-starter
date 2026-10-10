# 任务计划：规则治理深化与模型服从性加固 (task_plan.md)

> **使用说明**：凡命中三红线的任务，Agent 必须先在本文件中拟定实施方案与 3~5 条大白话验收标准，经 PM 批准后方可修改代码。每步完成即时打勾更新。

- **当前状态**：🟢 执行完毕，全部验收通过
- **任务目标**：
  落实开源社区与工程实践中关于 Agent 规则治理的 5 项深度优化建议，对当前工作区顶层宪法 [`.agents/AGENTS.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/AGENTS.md) 及子规则库进行外科手术式加固。精简内联长模板避免注意力稀释、确立状态机回显锁与动态范围升级拦截、适度放宽读取配额至 60~100 行根除工具抖动、补全 PowerShell 转义规范、并引入交付前 Git Diff 反思自检门禁。

---

## 一、 PM 白话验收标准 (5 条)

1. **主入口极致轻量，骨架完备下沉**：
   - [`.agents/AGENTS.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/AGENTS.md) 移除内联的决策卡片、交付声明、审批申请三大 Markdown 骨架，仅保留严格字段契约；完整模板下沉至 [`.agents/rules/05-pm-interaction-templates.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/rules/05-pm-interaction-templates.md) 且包含完整去伪存真矩阵表。
2. **状态机回显锁与动态扩圈阻断建立**：
   - 确立在调用任何写入/修改工具前必须输出首行状态回显 `[STATE: PLAN | EXECUTE | VERIFY]`；
   - 确立小任务执行中若发现改动即将超出 2 个文件或影响外部契约，立即挂起写入并回退至方案审批。
3. **读取配额平滑扩容，根除工具抖动**：
   - [`.agents/AGENTS.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/AGENTS.md) 与 [`.agents/rules/01-architecture-and-modularity.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/rules/01-architecture-and-modularity.md) 同步将单次读取上限调整为 60~100 行（单语义块/单函数），累计读取配额调整为 200 行，保持大原则“禁止全量读取”。
4. **终端特殊字符转义规范入库**：
   - 三.1 明确注明 Windows PowerShell 环境下对 Git Stash 引用的单引号保护 `'stash@{0}'` 规范。
5. **反思自检门禁与全套测试全绿**：
   - 四节补充交付前 Git Diff 反向自检条款；自动化门禁测试（`node --test`）与 Pre-commit 检查 100% 通过（退出码 0）。

---

## 二、 实施步骤与预估改动范围

- [x] **步骤 1：加固 [`.agents/AGENTS.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/AGENTS.md)**
  - 精简一.3，强化卡片核心 6 要素契约，增加动态范围升级铁律；
  - 增加一.4 末尾状态机回显锁 `[STATE: PLAN | EXECUTE | VERIFY]`；
  - 调整二.3 读取限制为 60~100 行、累计 200 行；
  - 补充三.1 Windows PowerShell `'stash@{0}'` 转义提示；
  - 精简四.3 交付完成声明骨架，外置到子规则文件；
  - 新增四.4 代码审查反打门禁 (Inversion Check)，原四.4 顺延为四.5；
  - 精简五.3 高危操作审批申请骨架，外置到子规则文件。
- [x] **步骤 2：加固 [`.agents/rules/05-pm-interaction-templates.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/rules/05-pm-interaction-templates.md)**
  - 完善模板三，内嵌完整去伪存真验收矩阵表与三分法三栏骨架。
- [x] **步骤 3：同步 [`.agents/rules/01-architecture-and-modularity.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/.agents/rules/01-architecture-and-modularity.md)**
  - 同步调整定向检索与单任务配额为 60~100 行与 200 行。
- [x] **步骤 4：自动化门禁回归验证**
  - 执行 `node --test` 核心测试套件，检查 Pre-commit 钩子。
- [x] **步骤 5：更新看板与交付汇报**
  - 更新 [`docs/PROGRESS.md`](file:///C:/Users/15770/.gemini/antigravity/worktrees/planProject/move_antigravity_working_directory/docs/PROGRESS.md)，呈报去伪存真验收矩阵。
