# 项目进度与任务状态账本 (PROGRESS)

## 📌 当前任务状态：【Second Brain 知识中枢治理、memory-curator v2.0 升级与 Notion 镜像同步】

- **执行时间**：2026-10-15
- **最后已知 Commit**：`25e6520`
- **任务目标**：
  1. **Second Brain 原生潜能激活**：扩展 `second_brain_mcp.py` 及 MCP Schema，暴露 `second_brain_list_projects`、`second_brain_update` 与 `second_brain_get_prompt_capsule`。
  2. **长期记忆守门员升级**：升级 `memory-curator` 至 v2.0，确立阶梯式低能耗召回（Token 降耗 ~70%）、消歧打补丁更新与决策日志自动归类。
  3. **记忆库工程治理**：在 `E:\workSpace\second-brain-cloudflare` 部署 Framework v2（`AGENTS.md`、`PROJECT_ENV.md`、`PROGRESS.md`），固化实测命令。
  4. **知识库双向归档**：本地原件存入 `docs/specs/second-brain-memory-curator-optimization.md`，并合规镜像至私人 Notion 知识库（`//specs -> index` 数据库）。

---

## 一、 核心资产与落地清单 (Delivered Assets)

| 资产类型 | 物理路径 | 状态 | 说明 |
|:---|:---|:---|:---|
| **机器全局瘦身宪章** | `C:\Users\15770\.gemini\config\rules\AGENTS.md` | ✅ 已极简化 | 1.5 KB（19行），仅保留独立判断、诚实证据、高危门禁与注入防御 |
| **全局专项规则清理** | `C:\Users\15770\.gemini\config\rules\01~13-*.md` | ✅ 已移除 | 全局上下文污染彻底归零，专项规则收敛至项目级按需加载 |
| **历史规则完整备份** | `C:\Users\15770\.gemini\config\rules_backup\rules_pre_boost_20261014\` | ✅ 已归档 | 包含原 01~13 专项规则与原 8.5 KB 根地图共 14 个文件 |
| **双向脚手架 (CMD)** | `init-agent.cmd`（两处模板根目录） | ✅ 已固化 | `@powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0init-agent.ps1" %*`，跨终端免策略报错 |
| **双向脚手架 (PS1)** | `init-agent.ps1`（两处模板根目录） | ✅ 已加固 | UTF-8 with BOM 编码、远程模板有效性校验、临时目录 `try/finally` 零泄露、`-Force` 幂等保护 |
| **模板主仓 (全局配置)** | `C:\Users\15770\.gemini\config\templates\agent-framework-v2\` | ✅ 已同步 | 完整 13 规约、6 模式、4 迁移文档、根 README.md 与双脚本工具集 |
| **模板主仓 (本地备份)** | `D:\Downloads\新建文件夹 (4)\agent-framework-v2\` | ✅ 已同步 | 与全局模板 100% 镜像一致 |
| **用户环境变量 Path** | `HKCU:\Environment\Path` | ✅ 已永久生效 | 已追加模板目录，新开 CMD/PowerShell 窗口可全局直敲 `init-agent` |
| **GitHub 私有模板仓库** | `mlgbz523/agent-framework-v2` | ✅ 已更新 | Private + Template，含 v2.0.1 标签，包含完整 13 规约与脚手架 |
| **机器全局专属归档** | `agent-framework-v2/global/` | ✅ 已纳入仓库 | 包含全局 AGENTS.md 宪章与 setup-global.cmd/ps1 一键部署脚本 |

---

## 二、 /boost 架构特性与防护细节

1. **全局上下文瘦身 (Zero Context Pollution)**：
   - 机器全局规则从 8.5 KB + 13个专项规则精简为单一宪章文件（1,516 字节）。
   - 彻底解决任何新项目冷启动时被全局规则强行塞入非相关场景约束（如小说项目被塞入代码重构规约）的问题。
2. **免 ExecutionPolicy 限制的双脚本设计**：
   - Windows 用户通常受限于 PowerShell `Restricted` 策略，`init-agent.cmd` 通过 `-ExecutionPolicy Bypass` 封装，双击或在 CMD/Git Bash 下均可一键执行。
3. **安全浅克隆与零 Git 污染**：
   - 当传入 `-RepoUrl` 时，脚本自动浅克隆（`--depth 1`）至系统隔离临时目录，在复制前物理切除 `.git`（清除只读属性防止删除失败），确保新项目不会意外绑定模板的 Git 提交历史。
4. **克隆有效性校验与磁盘泄漏防御**：
   - 针对非模板仓库克隆成功但缺少 `AGENTS.md` 或 `.agents/` 的边界异常，新增模板结构校验并降级回退至本地模板，同时使用 `try...finally` 彻底避免临时目录残留在 `%TEMP%`。
5. **`-Force` 行为一致性与幂等保护**：
   - 在未指定 `-Force` 时，若目标项目已存在 `.agents` 规约文件，保留用户既有定制内容，仅补全缺失文件；指定 `-Force` 时才强制同步。
6. **多场景骨架自适应**：
   - `code`: 自动生成 `docs/specs/` 与 `docs/archive/`。
   - `novel`: 自动生成 `docs/creative/`。
   - `research`: 自动生成 `docs/_ref/` 与 `docs/findings/`。
   - `doc`: 自动生成 `docs/drafts/`。
   - `general`: 基础 `docs/` 规范目录。

---

## 三、 实测与验收证据 (Verification Evidence)

1. **CMD 封装脚本实测 (Code 项目模拟)**：
   - 执行命令：`cmd /c "C:\Users\15770\.gemini\config\templates\agent-framework-v2\init-agent.cmd scratch\test-agent-init -ProjectType code"`
   - 结果：返回代码 0，成功部署 `AGENTS.md`、`.agents/rules/` (13条)、`.agents/modes/` (6类) 以及 `docs/specs`、`docs/archive`。
   - Git 污染检测：`Test-Path scratch\test-agent-init\.git` -> `False`（无 Git 污染）。
2. **D 盘含空格路径脚手架实测 (Novel 项目模拟)**：
   - 执行命令：`cmd /c "D:\Downloads\新建文件夹 (4)\agent-framework-v2\init-agent.cmd scratch\test-agent-init-d -ProjectType novel"`
   - 结果：返回代码 0，成功部署并创建 `docs/creative/`。
3. **无效远程仓库克隆及降级实测**：
   - 执行空仓库浅克隆，触发 `WARNING: 远程仓库不包含有效的 Agent 模板...`，成功降级至本地模板，退出码 0，临时目录清理率为 100%。
4. **`-Force` 保护与覆盖机制实测**：
   - 无 `-Force` 执行：已有 `AGENTS.md` 与已有规约内容 100% 保留，缺失的规约成功补齐。
   - 带 `-Force` 执行：已有规约被权威模板覆盖更新。
5. **全类型骨架测试**：
   - `code`、`novel`、`research`、`doc`、`general` 5 种场景骨架与 13 规约 + 6 模式矩阵测试通过率 100%。
6. **环境自洁验证**：
   - 测试完毕后已通过 `Remove-Item` 彻底清理所有 `scratch` 临时测试项目，无残留垃圾。

---

## 四、 专项里程碑：Second Brain 知识中枢治理与 memory-curator 深度优化 (2026-10-15)

1. **MCP 工具链扩展与 Python 桥接**：
   - `~/.gemini/scripts/second_brain_mcp.py` 扩展支持 `list_projects`、`update` 与 `get_prompt_capsule`。
   - `~/.gemini/antigravity/mcp/second-brain/` 补齐对应 Schema 与 `instructions.md`。
2. **长期记忆守门员升级 (memory-curator v2.0)**：
   - 全局与本地技能双向同步升级，落地“阶梯式低能耗召回”、“更新优于新建”与“决策日志自动归类”。
3. **Second Brain 源码工程 Framework v2 治理**：
   - 在 `E:\workSpace\second-brain-cloudflare` 初始化生成 `AGENTS.md`、`.agents/` 规则全集，创建 `docs/PROJECT_ENV.md`（固化测试/部署命令）与 `docs/PROGRESS.md`。
4. **知识库双向镜像与合规落地**：
   - 本地原件：`docs/specs/second-brain-memory-curator-optimization.md`
   - Notion 镜像：`//specs -> index` 数据库（页面 ID: `3f91f046-7a64-81c2-b72c-ecfed115a8ab`，属性 `架构`，零绝对敏感路径泄露）。
