# 任务计划：整理 sandbox 测试样例物理隔离与工具集归档 (task_plan.md)

> **使用说明**：凡命中三红线的任务，Agent 必须先在本文件中拟定实施方案与 3~5 条大白话验收标准，经 PM 批准后方可修改代码。每步完成即时打勾更新。

- **当前状态**：执行完毕，全部验收通过
- **任务目标**：
  1. 重新梳理 `sandbox/` 目录，将零散的扫雷与 2048 样例分别收纳至自包含、零耦合的 `project_?` 专属目录中；
  2. 规范归档历史任务计划与工具集资产索引，确保业务项目代码纯净、测试命令持续全绿。

---

## 一、 PM 白话验收标准 (5 条)

1. **项目物理完全隔离**：`sandbox/` 根目录下不再有散落的 HTML 或 BAT 脚本，所有测试项目各自独占一个 `project_?` 目录，互不干扰、拿走即用。
2. **每个样例开箱即用**：每个 `project_?` 目录下均包含完整的前端页面、启动脚本（`start-demo.bat`）以及项目说明（`README.md`），双击即可独立本地预览。
3. **自动化测试持续全绿**：移动后执行既有测试命令 `node --test`，无需改动测试断言，8 项自动化测试依然 100% 自动检出并全部通过。
4. **工具集与历史归档完备**：历史反重力迁移方案已安全移入 `docs/archive/` 归档留痕，资产清单（`LOCAL_PROJECT_ASSETS.md`）与目录索引清晰同步。
5. **提供安全后悔药**：任务开始前已建立还原点编号 `929a0ea`，若整理结果不满意，说“撤销刚才的修改”即可一键无损回到整理前状态。

---

## 二、 实施步骤与预估改动范围

- [x] 步骤 1：梳理扫雷项目，将散落在 `sandbox/` 根目录的 `minesweeper.html`、`start-demo.bat`、`task_plan.md` 与 `projectF/` 下的核心代码及测试统一收纳至独立的 `sandbox/project_minesweeper/`；
- [x] 步骤 2：梳理 2048 项目，将 `projectT/index.html` 迁移至 `sandbox/project_2048/`，并补齐独立的 `start-demo.bat` 与项目 `README.md`；
- [x] 步骤 3：清理 `sandbox/` 根目录旧冗余文件，更新 `sandbox/README.md` 索引说明；
- [x] 步骤 4：整理 `docs/archive/` 建立归档资产总览说明 `docs/archive/README.md`，同步更新 `docs/LOCAL_PROJECT_ASSETS.md`；
- [x] 步骤 5：实测执行 `node --test` 确认测试 100% 全绿，并更新交接看板 `docs/PROGRESS.md`。
