# Sandbox 测试样例与靶场目录 (非正式业务项目)

> **重要声明**：本目录下的所有代码与测试用例（`project_minesweeper`、`project_2048` 等）**仅用于测试与验证 AI Agent 的工程化执行能力、前端规范与自动化门禁**。
>
> - **严禁误用**：AI Agent 严禁将本目录当作实际业务项目环境；
> - **严禁推断技术栈**：不得据此推断主项目技术栈，正式项目的技术栈与命令请严格参见根目录 [`docs/PROJECT_ENV.md`](../docs/PROJECT_ENV.md)；
> - **物理隔离原则**：各子工程完全独立封闭在各自的 `project_?` 目录内，互不共享状态。

---

## 🗂️ 样例工程物理隔离索引

```text
sandbox/
├── 📑 README.md                    <-- 本索引说明文档
│
├── 📂 project_minesweeper/          <-- 【样例一】经典扫雷游戏（纯前端 + 单元测试）
│   ├── index.html                  <-- 单文件扫雷网页
│   ├── start-demo.bat              <-- 本地 HTTP 预览服务 (8000 端口)
│   ├── task_plan.md                <-- 研发任务实施计划
│   ├── README.md                   <-- 项目说明
│   ├── src/minesweeper-core.js     <-- 扫雷核心逻辑类
│   └── tests/minesweeper.test.js   <-- 自动化测试套件
│
└── 📂 project_2048/                 <-- 【样例二】经典 2048 益智小游戏（纯前端响应式应用）
    ├── index.html                  <-- 单文件 2048 网页
    ├── start-demo.bat              <-- 本地 HTTP 预览服务 (8001 端口)
    └── README.md                   <-- 项目说明
```

---

## 🚀 样例一键演示方式

1. **扫雷游戏体验**：进入 [`project_minesweeper/`](project_minesweeper/)，双击 `index.html` 或 `start-demo.bat`；
2. **2048 游戏体验**：进入 [`project_2048/`](project_2048/)，双击 `index.html` 或 `start-demo.bat`。

---

## 🧪 基准测试验证命令

在工作区根目录下执行标准测试命令：
```bash
node --test
```
预期结果：自动检出并运行 `sandbox/project_minesweeper/tests/minesweeper.test.js`，全部 8 项测试通过。
