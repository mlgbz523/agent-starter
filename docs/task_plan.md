# 任务计划：路径 A 抗幻觉与长记忆工程体系落地 (task_plan.md)

> **使用说明**：凡命中三红线的任务，Agent 必须先在本文件中拟定实施方案与 3~5 条大白话验收标准，经 PM 批准后方可修改业务代码。每步完成即时打勾更新。

- **当前状态**：🟢 全部执行完毕，实测验证通过 (`[STATE: VERIFY]`)
- **任务目标**：
  1. 在当前 Antigravity 运行环境落地三大抗幻觉支柱（Mem0 长期记忆挂载、Repomix 代码打包器集成、Memory Bank 会话物理阻断规约）；
  2. 实现长对话上下文防稀释、防中毒，跨会话无缝续接。

---

## 一、 PM 白话验收标准 (4 条)

1. **Repomix 本地一键打包实测可用**：
   - 运行项目内的打包命令 (`.\scripts\pack_context.ps1`) 能够一键将代码仓库安全、紧凑压缩为 XML 格式，自动剔除缓存、测试沙箱与无用大文件，CLI 退出码为 0。
2. **Mem0 长期记忆服务接入就绪**：
   - 在 Antigravity 全局 MCP 配置中注册 `mem0` 服务节点，且语法配置 100% 格式无误，不影响已有的 deepseek/free-search/cloudflare 插件。
3. **Memory Bank 物理阻断规约入宪**：
   - 在 `.agents/rules/07-memory-bank-protocol.md` 中明文确立长对话交接规则（15~20 轮或注意力衰退时主动落盘并引导开启新会话），并在 `PM_HANDBOOK.md` 中提供 PM 白话操作指南。
4. **全套门禁回归持续全绿**：
   - 核心测试套件 (`node --test`) 与 `pre-commit` 静态安全门禁 100% 通过（退出码 0）。

---

## 二、 实施步骤与预估改动范围

- [x] **步骤 1：工程化配置 Repomix 代码打包器**
  - 创建 `repomix.config.json`（配置过滤规则与安全边界）；
  - 创建 `scripts/pack_context.ps1` 一键执行脚本并实测运行（退出码 0，生成 174KB 纯净 XML 包）。
- [x] **步骤 2：落地 Memory Bank 状态机防遗忘规约**
  - 创建 [`.agents/rules/07-memory-bank-protocol.md`](.agents/rules/07-memory-bank-protocol.md)；
  - 更新 [`.agents/AGENTS.md`](.agents/AGENTS.md) 索引；
  - 更新 [`docs/PM_HANDBOOK.md`](docs/PM_HANDBOOK.md) 补充第十节交接指南。
- [x] **步骤 3：配置全局 Mem0 长期记忆 MCP 节点**
  - 更新 `C:\Users\15770\.gemini\config\mcp_config.json`，注入 `mem0` 节点；
  - 格式校验 100% 语法无误，安全隔离。
- [x] **步骤 4：全量自动化回归与交付汇报**
  - 运行 `node --test`（8/8 全绿）；
  - 运行 `pre-commit run --all-files`（100% Passed）；
  - 更新 [`docs/PROGRESS.md`](docs/PROGRESS.md) 并呈报去伪存真验收矩阵。
