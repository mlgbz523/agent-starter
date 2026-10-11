# DEVELOPMENT_WORKFLOW.md - 项目全生命周期开发流程与规划规范

> **核心宗旨**：杜绝 Agent 在规划阶段以“半成品草案逼单 PM 执行”。规范从需求捕获、架构推演、防御性条例注入、原子化拆解到核验交付的完整闭环。

---

## 一、 5 大开发阶段与 Skill 联动拓扑

在用户提出业务需求或触发 `/plan` 时，Agent 必须主动向用户陈述当前处于的阶段，并按序唤醒对应的专业 Skill：

```
[PM 需求/灵感]
      │
      ▼ (Stage 1)
【阶段 1：需求探索与设计规范】 ───► 调用 Skill: brainstorming
      │                            ├─ 业务意图与边界澄清
      │                            ├─ 提出 2~3 种架构方案对比与推荐
      │                            └─ 产出 Written Spec (docs/specs/...)
      ▼ (Stage 2)
【阶段 2：补充条例与防御性审计】 ───► 执行 DoR (方案就绪门禁)
      │                            ├─ 显式声明【非目标清单 (Non-Goals)】
      │                            ├─ 推演 5 类核心异常与降级策略 (Edge Cases)
      │                            ├─ 锁定数据结构与接口契约 (Data Contracts)
      │                            ├─ 依赖准入审查与环境配置 (.env.example)
      │                            └─ 确立起始还原点与可证伪测试命令
      ▼ (Stage 3)
【阶段 3：原子化工程规划】     ───► 调用 Skill: writing-plans
      │                            ├─ 依据 Spec 编写 docs/task_plan.md
      │                            ├─ 拆解为 Bite-sized Tasks (单任务 <= 2 文件)
      │                            ├─ 显式标注 Consumes / Produces 契约
      │                            ├─ 每个 Step 满足 Red-Green-Commit 循环
      │                            └─ 呈报【PM 决策卡片】申请执行授权
      ▼ (Stage 4)
【阶段 4：上下文隔离执行】     ───► 调用 Skill: subagent-driven-development / executing-plans
      │                            ├─ 联动: test-driven-development (TDD)
      │                            ├─ 联动: karpathy-guidelines (外科手术式修改)
      │                            └─ 状态机回显锁: [STATE: EXECUTE]
      ▼ (Stage 5)
【阶段 5：去伪存真核验交付】   ───► 调用 Skill: verification-before-completion
                                   ├─ 运行全量测试 (验证真实退出码 0)
                                   ├─ 提供三段式本地零门槛演示步骤
                                   └─ 呈报四要素去伪存真验收矩阵
```

---

## 二、 方案就绪硬门禁 (Definition of Ready - DoR)

在向 PM 申请执行授权前，方案文件（`docs/task_plan.md`）必须完整满足以下 6 大防御性补充条例：

| 补充条例模块 | 强制检查项 | 验证标准 |
| :--- | :--- | :--- |
| **1. 非目标清单 (Non-Goals)** | 明确列出本次绝对不做的边界 | 至少 2 条显式 Non-Goals，严禁模糊 |
| **2. 异常与边界推演 (Edge Cases)** | 超时、空数据、并发冲突、网络抖动等 | 至少 3~5 项异常应对策略与降级方案 |
| **3. 数据契约锁定 (Contracts)** | 入参、出参、字段名与类型签名 | 具备具体的代码级类型定义或 Schema |
| **4. 依赖与环境审计 (Supply Chain)** | 是否引入新三方库、是否需要环境变量 | 依赖通过探针验证，密钥声明于 `.env.example` |
| **5. 可证伪验证矩阵 (Verification)** | 每个 Task 对应终端 CLI 命令 | 命令必须具备失败（反向）与成功（正向）判定能力 |
| **6. 安全撤销预案 (Rollback)** | 任务起始快照基线 | 明确记录 Commit ID，支持 5 秒内无损撤销 |

---

## 三、 原子化划界度量衡：单契约闭环单元 (SCCU) 与科学依据

> 🚨 **反模式警示**：严禁在 Agent 规划中使用“天/小时/预计用时”等工时单位，也**严禁以“模型上下文窗口大小”作为浮动标准**（不同模型窗口差异巨大，且存在长上下文注意力衰减）。
> 所有原子任务必须以具备坚实理论依据的**【单契约闭环单元 (Single-Contract Closure Unit, SCCU)】**作为唯一客观切片标准。

### 1. 科学依据支撑 (Theoretical & Empirical Foundations)
- **AI 注意力退化与复合错误**：斯坦福 *Lost in the Middle (TACL 2024)* 证实长窗口存在 U 型注意力坍塌；马尔可夫链复合错误率定理 $P_{\text{total}} = \prod p_i$ 证明缺少独立断言的长链任务失败率逼近 100%；UIUC *Agentless (2024)* 证明局部外科手术式切片优于大范围跨文件规划。
- **控制论闭环反馈**：维纳反馈理论与 NeurIPS *Reflexion* 证明，开环生成必然导致模型幻觉发散，只有真实环境 CLI 退出码（Exit Code 0）是收敛误差的唯一真理。
- **计算机软件工程奠基理论**：Parnas (1972)《系统模块化分解标准》奠定了按“信息隐藏与独立契约”切片，彻底否定按时间流切片；数据库事务 ACID 理论确立了独立可撤销性（Atomic Commit）是工程容错底线。

### 2. 客观工程不变性三大硬门禁 (SCCU Invariants)
每个原子任务节点必须同时通过以下 3 项客观检验，缺一不可：
1. **单测试可证伪门禁 (The One-Test Invariant)**：
   - 任务必须能仅由一组独立的单元测试（单 CLI 命令、单测试文件、纯本地、1 秒内）完全裁决其成败。禁止将跨层、跨系统的交互混合在单个节点中。
2. **Git 原子提交与独立撤销门禁 (The Revert Invariant)**：
   - 节点等于一个生产级 Atomic Commit。若将该节点 `git revert` 撤销，全局工程必须保持可编译且旧测试全绿，杜绝跨节点悬空依赖。
3. **单层职责与显式契约门禁 (Single Responsibility & Interface Closure)**：
   - 严格在数据契约层、纯逻辑运算层、或外部 I/O 适配层三者之一内封闭；
   - 必须显式声明精确的输入依赖（`Consumes`）与对外暴露符号（`Produces`）。

---

## 四、 Agent 面向 PM 的主动交互规范

### 1. 收到需求时的第一轮回复标准（严禁直接给草案要执行）
当 PM 提出新需求时，Agent 必须以如下结构回应：

> **我理解你要的是**：[一句话白话复述需求业务意图]
>
> 📋 **当前项目开发流程指示**：
> 本次任务将严格遵循 **5 阶段开发闭环**：
> 1. **当前阶段**：【阶段 1：需求探索与设计规范】（将调用 `brainstorming` 锁定技术架构与契约）；
> 2. **下一阶段**：【阶段 2 & 3：补充条例防御审计与原子化拆解】（将调用 `writing-plans` 生成带可证伪测试命令的细化方案）；
> 3. **执行与交付**：只有在方案通过 DoR 完整度审计并获得你明确批准后，才会调用 `subagent-driven-development` 动工编码。
>
> ❓ **在进入方案设计前，先与您对齐 1~2 个关键设计决策**：[提出聚焦业务的关键选择题]

### 2. 方案呈报时的卡片规范
在方案阶段结束时，只有方案完全满足 DoR，才允许以标准【PM 决策卡片】发起执行授权；若方案处于讨论草案阶段，末尾一律禁止出现“是否开始编写代码”，仅允许询问：“方案的异常边界与架构方向是否符合预期？是否需要补充特定条例？”。

---

## 五、 本地工程已就绪的 Skills 矩阵

| Skill 名称 | 本地路径 | 核心定位 |
| :--- | :--- | :--- |
| `brainstorming` | `.agents/skills/brainstorming/` | 需求意图挖掘、架构方案权衡、Written Spec 产出 |
| `writing-plans` | `.agents/skills/writing-plans/` | 原子化任务分解、接口契约锁定、TDD 步骤拆解 |
| `executing-plans` | `.agents/skills/executing-plans/` | 单会话任务逐项推进与检查点记录 |
| `subagent-driven-development` | `.agents/skills/subagent-driven-development/` | 上下文隔离的子智能体派发与结果汇总 |
| `test-driven-development` | `.agents/skills/test-driven-development/` | Red-Green-Refactor 驱动执行 |
| `verification-before-completion` | `.agents/skills/verification-before-completion` | 交付前真实 CLI 退出码检验与证据核验 |
| `karpathy-guidelines` | `.agents/skills/karpathy-guidelines/` | 外科手术式修改、极简实现、杜绝顺手重构 |
