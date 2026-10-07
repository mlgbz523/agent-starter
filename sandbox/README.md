# Sandbox 测试样例、靶场与运维隔离区 (非正式业务项目)

> **重要声明**：本目录下的所有代码、测试用例与运维工具（`project_minesweeper`、`project_2048`、`project_toolkit`）**仅用于测试与验证 AI Agent 的工程化执行能力、前端规范与独立运维工具承载**。
>
> - **严禁误用**：AI Agent 严禁将本目录当作实际业务项目环境；
> - **严禁推断技术栈**：不得据此推断主项目技术栈，正式项目的技术栈与命令请严格参见根目录 [`docs/PROJECT_ENV.md`](../docs/PROJECT_ENV.md)；
> - **物理隔离原则**：各子工程与工具集完全独立封闭在各自的 `project_?` 目录内，互不共享状态。

---

## 🗂️ 样例工程与工具箱物理隔离索引

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
├── 📂 project_2048/                 <-- 【样例二】经典 2048 益智小游戏（纯前端响应式应用）
│   ├── index.html                  <-- 单文件 2048 网页
│   ├── start-demo.bat              <-- 本地 HTTP 预览服务 (8001 端口)
│   └── README.md                   <-- 项目说明
│
└── 📂 project_toolkit/              <-- 【工具集】全套 C 盘清理与源头重定向运维工具箱
    ├── toolbox.bat                 <-- 中文总控台入口（数字菜单直达所有功能）
    ├── 使用说明.md                  <-- 完整操作指引与安全手册
    ├── 01_antigravity/             <-- 反重力存储搬迁与还原
    ├── 02_c_drive_cleanup/         <-- C 盘纯垃圾秒级清理（保留系统休眠）
    ├── 03_permanent_redirection/   <-- 一劳永逸源头重定向体系
    └── 04_appdata_selective/       <-- AppData 10 大常用应用定向搬迁
```

---

## 🚀 样例与工具一键启动方式

1. **扫雷游戏体验**：进入 [`project_minesweeper/`](project_minesweeper/)，双击 `index.html` 或 `start-demo.bat`；
2. **2048 游戏体验**：进入 [`project_2048/`](project_2048/)，双击 `index.html` 或 `start-demo.bat`；
3. **磁盘运维与瘦身工具箱**：进入 [`project_toolkit/`](project_toolkit/)，双击 `toolbox.bat` 即可呼出全功能中文交互控制台。

---

## 🧪 基准测试验证命令

在工作区根目录下执行标准测试命令：
```bash
node --test
```
预期结果：自动检出并运行 `sandbox/project_minesweeper/tests/minesweeper.test.js`，全部 8 项测试通过。
