# 样例工程 1：经典扫雷游戏 (project_minesweeper)

> **定位**：用于测试 AI Agent 前端页面构建、核心算法（空白扩散、布雷判定）与单元测试闭环的基准样例项目。

---

## 📁 目录结构

```text
sandbox/project_minesweeper/
├── 🎮 index.html                 <-- 游戏完整单文件网页（可直接双击运行）
├── 🎮 minesweeper.html           <-- 兼容别名网页
├── 🚀 start-demo.bat             <-- 本地 HTTP 预览启动器（8000 端口）
├── 📋 task_plan.md               <-- 项目历史研发实施计划
├── 📑 README.md                  <-- 本说明文档
├── src/
│   └── minesweeper-core.js       <-- 扫雷核心逻辑类 (MinesweeperGame)
└── tests/
    └── minesweeper.test.js       <-- 自动化测试套件 (包含 7 大核心场景，8 项断言)
```

---

## 🚀 启动与体验方式

1. **方式一（最简）**：直接在文件资源管理器中双击 `index.html`，无需安装任何软件；
2. **方式二（本地服务器）**：双击 `start-demo.bat`，脚本将自动拉起 8000 端口并唤起默认浏览器打开游戏。

---

## 🧪 自动化测试验证

在工程根目录下执行：
```bash
node --test
```
预期输出：8 项测试全部通过（通过率 100%）。
