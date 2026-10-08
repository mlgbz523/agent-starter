# 任务计划：剥离 Sandbox 追踪与全局自举脚手架规则部署 (task_plan.md)

> **使用说明**：凡命中三红线的任务，Agent 必须先在本文件中拟定实施方案与 3~5 条大白话验收标准，经 PM 批准后方可修改代码。每步完成即时打勾更新。

- **当前状态**：🟢 执行完毕，全部验收通过
- **任务目标**：
  1. 将本地测试样例与沙箱 `sandbox/` 从 Git 索引中解绑并加入 `.gitignore`，在保持本地物理文件绝对完整的前提下，彻底从远端 `agent-starter` 模板仓库（`main` 与特性分支）中剥离，保持开源模板极致纯净；
  2. 在 Antigravity 用户全局规则库（`C:\Users\15770\.gemini\config\rules\`）中创建【全局工作区治理自举守门员】规则（`workspace-governance-bootstrapper.md`），实现当 Agent 进入任何无规则工作区时，主动询问 PM 并支持一键拉取 `https://github.com/mlgbz523/agent-starter.git` 初始化生产级治理底座。

---

## 一、 PM 白话验收标准 (4 条)

1. **远端模板极致纯净，无 Sandbox 污染**：
   - 远端 GitHub 仓库（`main` 与特性分支）根目录不再包含 `sandbox/`，仅保留核心脚手架资产（`.agents/`, `docs/`, `README.md`, `.pre-commit-config.yaml`）。
2. **本地 Sandbox 物理文件 100% 完好无损**：
   - 本地 `sandbox/`（扫雷、2048、toolkit 运维工具箱）物理文件一个不丢，本地功能与测试可继续独立运行。
3. **全局自举守门员规则无缝部署**：
   - 全局规则文件 `C:\Users\15770\.gemini\config\rules\workspace-governance-bootstrapper.md` 成功部署；当 Agent 在任何没有 `AGENTS.md` 的新项目中启动时，强制拦截并主动向 PM 弹窗询问是否一键拉取 `agent-starter`。
4. **全套自动化门禁全绿且全端同步**：
   - Pre-commit 钩子 100% Passed，本地母仓库与云端 GitHub 仓库双向完成纯净同步。

---

## 二、 实施步骤与预估改动范围

- [x] **步骤 1：Git 索引安全解绑 `sandbox/` 并更新 `.gitignore`**
  - 在 `.gitignore` 追加 `sandbox/`；
  - 执行 `git rm -r --cached sandbox/`，仅解绑 Git 索引，绝不删除本地磁盘文件；
  - 本地 Commit 并推送到远端两个分支（`move_antigravity_working_directory` 与 `main`）。
- [x] **步骤 2：部署 Antigravity 全局自举规则**
  - 在 `C:\Users\15770\.gemini\config\rules\` 创建 `workspace-governance-bootstrapper.md`；
  - 编写空工作区检测、PM 决策卡片模板及拉取 SOP 逻辑。
- [x] **步骤 3：本地母仓库与远端一致性对齐**
  - 在 `E:\workSpace\planProject` 中同步解绑操作，确保母仓库工作区纯净。
- [x] **步骤 4：自动化门禁验证与交付汇报**
  - 执行 `pre-commit run --all-files` 验证；
  - 更新 [`docs/PROGRESS.md`](docs/PROGRESS.md) 并呈报完成清单。
