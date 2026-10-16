# Second Brain 知识中枢治理与 memory-curator 深度优化实战报告

> 💡 **核心目标**：实现个人私有 Cloudflare 知识中枢（Second Brain）与 Antigravity Agent Framework v2 治理体系的全链路深度咬合，彻底解决长程记忆中的注意力漂移、Token 冗余消耗、旧记忆丧尸化与源码仓库缺乏规范等工程痛点。

---

## 一、 背景与系统拓扑

在多 Agent 协同体系中，模型在长对话后容易出现注意力稀释与幻觉累积。虽然私有 Second Brain 提供了强大的云端向量存储与 D1 关系底座，但若缺乏客户端维度的严格门禁与元数据契约，知识库易退化为非结构化聊天流水账。

```
[ Antigravity 会话层 (New Chat / Task) ]
              │ (触发里程碑 / 错误熔断)
              ▼
[ 07-memory-bank-protocol 状态机持久化 ]
              │
              ▼
[ memory-curator v2.0 长期记忆守门员 ]
   ├── 阶梯式召回 (brief / list_recent -> 低能耗检索)
   ├── 项目命名空间校验 (list_projects -> 防污染)
   └── 原生消歧打补丁 (update 优于 remember -> 消除互斥条目)
              │
              ▼ (MCP 契约调用)
[ Cloudflare Second Brain 边缘中枢 (D1 + Vectorize + Hono) ]
```

---

## 二、 核心优化与落地成果

### 1. 解锁 Second Brain 原生 MCP 潜能
此前客户端仅对接了 4 个基础查询接口，使服务端沉睡了大量高级治理特性。本次在本地 MCP 桥接层（`second_brain_mcp.py`）及配置声明中，完整激活了以下三项关键工具：

| 工具名称 | 接口映射 | 业务价值 |
| :--- | :--- | :--- |
| `second_brain_list_projects` | `GET /projects` | 获取合法 Project 命名空间列表，校验 `project:<slug>` 标签，杜绝脏标签与拼写错误。 |
| `second_brain_update` | `POST /update` | **【核心破局】** 支持对已有条目进行原地覆盖或增量打补丁，彻底消除互斥并存的“丧尸记忆”。 |
| `second_brain_get_prompt_capsule` | `GET /prompt-capsules/...` | 支持按项目动态装载云端固化的工程认知与行为约束，减少本地 Prompt 编写成本。 |

### 2. 长期记忆守门员升级（memory-curator v2.0）
重构全局与项目级 `memory-curator` 技能，确立三大工程铁律：
1. **阶梯式低能耗召回策略**：冷启动或日常巡检优先调用 `brief` 或 `list_recent(limit=3)`，只拉取高密度摘要（< 300 Token）；仅在定位到具体模块时，才定向触发 `recall` 深搜。
2. **更新优于新建（Update over Insert）**：前置查重发现语义相近旧结论时，强制使用 `update` 覆盖或演进版本，严禁直接无差别插入双胞胎条目。
3. **决策日志自动流转**：涉及技术选型决策时，自动携带 `kind:decision` 标签，流转至 Second Brain 的 Decision Log 视图。

### 3. Second Brain 源码工程注入 Framework v2
在记忆库源码仓库（`second-brain-cloudflare`）中部署工程化治理规范：
- **`AGENTS.md`**：工作区地图与行为宪章，设立高风险操作门禁（防清空 D1、防抹除向量索引）。
- **`docs/PROJECT_ENV.md`**：权威固化 `wrangler dev`、`vitest run`、`sync_backup.js`、D1 远程迁移等实测命令基线。
- **`docs/PROGRESS.md`**：状态机进度账本，提供秒级会话复原入口。

---

## 三、 实测检验与验证凭证

1. **MCP 桥接连通性验证**：
   - 调用 `second_brain_list_recent` 实时拉取最新条目，成功获取边缘 SQLite 密文索引架构、双 Worker 隔离与 Notion 嵌入视口三条架构沉淀，链路响应正常。
2. **Python 运行环境语法校验**：
   - 语法编译与工具动态注册测试通过，无任何未捕获异常。
3. **工程脚手架隔离性验证**：
   - 目标仓库部署后目录纯净，剔除远程 Git 污染，环境账本与规则文件 100% 准确落盘。

---

## 四、 后续演进路线

- **Phase A**：结合仓库内 `build_zh.py`，微调 Second Brain Web 控制台中文本地化与移动端排版体验。
- **Phase B**：强化 `scripts/sync_backup.js` 灾备同步机制，实现与 GitHub 及本地知识库的自动双向同步与巡检。
