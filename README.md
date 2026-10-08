# Agent-Starter：开箱即用的 AI 研发脚手架模版

> 这是一个专为现代 AI Agent（如 Antigravity / Claude Code / Cursor / Windsurf 等）研发打造的**工程化纯净底座**。
> 本项目**不绑定任何编程语言与全局配置**，天然包含 PM 友好协作宪法、防自嗨变异证伪门禁、本地 Git 密钥拦截以及渐进式记忆中枢。

---

## 🚀 3 步在任何新项目中开箱即用

### 方式 1：作为 GitHub/GitLab 模版仓库（推荐，最优雅）
1. 将本目录推送到 GitHub，在仓库设置（Settings）中勾选 **Template repository**；
2. 新建项目时，直接点击 **Use this template** -> **Create a new repository**；
3. 克隆到本地后，直接呼叫 Agent：“我想做 [你的项目名称]”，Agent 会自动带你完成技术栈确认与开发！

### 方式 2：直接复制到新项目（最直接）
1. 将本目录下的所有文件（包含 `.agents/`、`docs/`、`.pre-commit-config.yaml`）直接复制到新项目根目录下；
2. 在新项目终端中安装预检门禁（可选，推荐）：
   ```bash
   pip install pre-commit
   pre-commit install
   ```
3. 开始对话：“我想做 [你的项目名称]”。

---

## 📦 包含的核心资产（纯净 4 件套）

1. **规则引擎 (`.agents/`)**：
   - `AGENTS.md`：顶层宪法（三红线、白话汇报、反虚假验收协议、后悔药机制）。
   - `rules/`：6 大模块化规则切片（架构解耦、契约先行、证伪探针、复用漏斗、PM决策卡片、安全白名单）。
2. **记忆中枢 (`docs/`)**：
   - `PROJECT_ENV.md`：动态技术栈与已实测命令记录（初始为未确认状态）。
   - `PROGRESS.md`：PM 专属进度看板（解决多会话记忆断片）。
   - `GLOSSARY.md`：PM 技术白话词典。
   - `PM_HANDBOOK.md`：PM 验收与提需求实战手册。
   - `DEPLOYMENT_SECURITY.md` & `INCIDENT_RESPONSE.md`：上线安全与线上应急 SOP。
3. **机器硬门禁 (`.pre-commit-config.yaml`)**：
   - 物理级拦截代码中误写私钥/Token，自动规整代码格式与尾行。
4. **通用技能库 (`.agents/skills/`)**：
   - `skill-curator`：通用的开源技能检索与审计安装工具。
