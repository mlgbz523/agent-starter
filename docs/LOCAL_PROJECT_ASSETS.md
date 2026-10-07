# planProject 本地配置与资产落地清单 (LOCAL_PROJECT_ASSETS.md)

> **使用说明**：记录当前 `planProject` 仓库的具体物理路径与实操落地现状。与通用的方法论解耦，便于独立维护。

---

## 本地工作区落地现状对照表

| 规范/工具 | 本地实际落地路径 | 状态与生效机制 |
| :--- | :--- | :--- |
| **最高顶层准则** | [`AGENTS.md`](AGENTS.md) | 已生效（包含导师机制、白话解释、Diff铁律、定向检索、2次熔断、三红线、复用边界、PM五大权限红线、依赖背书卡片） |
| **双生态兼容** | [`GEMINI.md`](GEMINI.md) | 已生效（符号链接/指向 `AGENTS.md`） |
| **项目交接中枢** | [`docs/PROGRESS.md`](docs/PROGRESS.md) | 已生效（模块进度、交接上下文状态看板） |
| **关键决策记录** | [`docs/DECISIONS.md`](docs/DECISIONS.md) | 已生效（ADR-001 ~ ADR-003，方案选型防翻车） |
| **环境与上线安全** | [`docs/DEPLOYMENT_SECURITY.md`](docs/DEPLOYMENT_SECURITY.md) | 已生效（三套环境隔离、数据库变更确认、发布与回滚 SOP） |
| **应急响应与度量** | [`docs/INCIDENT_RESPONSE.md`](docs/INCIDENT_RESPONSE.md) | 已生效（线上止血原则、三句话白话诊断、每周质量与额度度量） |
| **PM 技术词典** | [`docs/GLOSSARY.md`](docs/GLOSSARY.md) | 已生效（技术术语大白话索引与生活类比，Agent 自动维护） |
| **项目环境记录** | [`docs/PROJECT_ENV.md`](docs/PROJECT_ENV.md) | 已建立模板（初始为“未确认项目”，PM 确认项目后由 Agent 动态维护） |
| **Agent 测试样例库** | [`sandbox/`](sandbox/) | 物理隔离（`project_minesweeper/` 扫雷与 `project_2048/` 2048 小游戏完全独立互不干扰，仅用于测试 Agent 能力） |
| **磁盘运维与瘦身工具箱** | [`E:\DiskCleanToolkit\`](file:///E:/DiskCleanToolkit/) | 物理隔离生效（全套 C 盘清理、源头重定向与 AppData 搬迁工具，业务库内仅留 `tools/` 快捷指路入口） |
| **项目历史资产归档** | [`docs/archive/`](docs/archive/) | 已建立生效（历史任务计划与方案持久化归档留痕） |
| **契约测试门禁** | [`.agents/rules/02-contract-and-testing.md`](.agents/rules/02-contract-and-testing.md) | 已生效（锁定模型接口，绿色测试通过方可交付） |
| **防幻觉探针规范**| [`.agents/rules/03-hallucination-probes.md`](.agents/rules/03-hallucination-probes.md) | 已生效（包含 Python / Node.js 单行预检命令） |
| **技能搜寻与安装官**| [`.agents/scripts/skill_curator.py`](.agents/scripts/skill_curator.py) 与 [`.agents/skills/skill-curator/SKILL.md`](.agents/skills/skill-curator/SKILL.md) | 已生效并通过单元测试（零 Token 检索、安全黑名单拦截、自动溯源） |
| **专业并发调试技能**| [`.agents/skills/python-concurrency-debugging/SKILL.md`](.agents/skills/python-concurrency-debugging/SKILL.md) | 已安装生效（附带 Python 官方标准库与 AAS 开源规范溯源） |
| **原生 Git 工作流** | [`.gitignore`](.gitignore) 与 [`.pre-commit-config.yaml`](.pre-commit-config.yaml) | 已初始化生效并物理拦截测试通过（Conventional Commits + 密钥拦截） |
