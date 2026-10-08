# 任务计划：开发习惯移入 Second Brain 与规则瘦身 (task_plan.md)

> **使用说明**：凡命中三红线的任务，Agent 必须先在本文件中拟定实施方案与 3~5 条大白话验收标准，经 PM 批准后方可修改业务代码。每步完成即时打勾更新。

- **当前状态**：🟢 全部执行完毕，实测验证通过 (`[STATE: VERIFY]`)
- **任务目标**：
  1. 将 5 类开发习惯、命令细节与模板沉淀至 Cloudflare Second Brain 并验证召回；
  2. 在本地 `AGENTS.md` 植入 Recall Hooks 并精简底层实现说辞；
  3. 瘦身 4 个规则切片（01, 03, 04, 05），保持硬门禁 100% 完好；
  4. 完成全量自动化回归与交付验收。

---

## 一、 PM 白话验收标准 (5 条)

1. **5 类先验记忆 100% 成功存入云端**：
   - Git/Windows 还原点、依赖探针、微观注释风格、供应链阈值、PM 卡片模板 5 条记忆成功写入 D1 与 Vectorize。
2. **语义召回验证全部高分命中**：
   - 针对 5 类场景发起的检索 query，召回率 100%，相关度均在 90% 以上且带有 AI 洞察。
3. **本地宪法植入轻量 Recall Hooks**：
   - 在 `.agents/AGENTS.md` 中配置 4 条记忆中枢检索触发器，精简原本 50+ 行的底层 PowerShell 转义说辞。
4. **4 个规则切片精简纯化**：
   - 移除静态冗余的 Markdown 字面量与命令细节，保留外科手术式修改、限额盲读、退出码验证与审批流程硬门禁。
5. **全量自动化测试与安全门禁 100% 通过**：
   - `node --test` 8/8 通过，`pre-commit` 门禁 100% Passed。

---

## 二、 实施步骤与预估改动范围

- [x] **步骤 1：持久化 5 类高价值记忆至 Second Brain**
  - Git/Windows 还原点实操经验；
  - 依赖真实性探针套路；
  - 微观代码品味、极简哲学与精简注释规范；
  - 外部依赖供应链安全准入标准；
  - PM 决策卡片与交互标准 Markdown 模板库。
- [x] **步骤 2：端到端语义召回能力实测**
  - 实测 5 个场景 query 均能 100% 精确召回。
- [x] **步骤 3：本地 `AGENTS.md` 瘦身与 Recall Hooks 植入**
  - 植入 4 行轻量意图路由钩子；
  - 精简 Git 命令底层转义描述。
- [x] **步骤 4：规则切片（01, 03, 04, 05）精简与记忆中枢解耦**
  - 瘦身 `01-architecture-and-modularity.md`、`03-hallucination-probes.md`、`04-reuse-and-supply-chain.md`、`05-pm-interaction-templates.md`。
- [x] **步骤 5：全量自动化回归与交付报告**
  - 运行 `node --test` 与 `pre-commit run --all-files`；
  - 更新 `docs/PROGRESS.md` 与 `docs/DECISIONS.md`；
  - 生成 `walkthrough.md` 交付报告。
