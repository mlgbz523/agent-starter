# 磁盘运维与瘦身工具箱隔离说明 (tools/README.md)

> **目录说明**：为保持业务工程（`planProject`）代码库的纯净，避免系统级运维脚本与业务代码混杂，全套 C 盘瘦身、存储搬迁与源头重定向工具已**整体打包并物理隔离迁移至独立工具箱专用目录**。

---

## 📍 独立工具箱物理路径

- **绝对路径**：[`E:\DiskCleanToolkit\`](file:///E:/DiskCleanToolkit/)
- **总控启动器**：[`E:\DiskCleanToolkit\toolbox.bat`](file:///E:/DiskCleanToolkit/toolbox.bat)
- **完整使用指南**：[`E:\DiskCleanToolkit\使用说明.md`](file:///E:/DiskCleanToolkit/%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E.md)

---

## 🚀 快捷直达方式

你在本工程内无需来回切换文件夹，只需**双击当前目录下的快捷启动脚本**：
- 双击 [`tools/打开磁盘工具箱.bat`](file:///E:/workSpace/planProject/tools/%E6%89%93%E5%BC%80%E7%A3%81%E7%9B%98%E5%B7%A5%E5%85%B7%E7%AE%B1.bat)
- 即可一秒唤起包含全部功能的中文总控交互台！

---

## 🗂️ 独立工具箱目录架构索引

```text
E:\DiskCleanToolkit\
├── 🚀 toolbox.bat                        <-- 【总控入口】双击唤起全功能中文数字菜单，一键直达
├── 📑 使用说明.md                         <-- 详尽的操作指引、安全保障与排错手册
│
├── 01_antigravity/                       <-- 【模块一】反重力 (Google Antigravity) 专属工具集
│   ├── migrate_gemini_storage.bat        <-- 工作区目录迁移至 E 盘 (已成功运行中)
│   ├── rollback_gemini_storage.bat       <-- 一键撤销还原至 C 盘
│   └── prune_worktrees.bat               <-- 项目历史工作树失效分支清理瘦身
│
├── 02_c_drive_cleanup/                   <-- 【模块二】C 盘纯垃圾秒级急救清理
│   └── clean_c_drive_junk.bat            <-- 纯垃圾一键扫空 (立省 ~18 GB，100% 完整保留系统休眠)
│
├── 03_permanent_redirection/             <-- 【模块三】一劳永逸源头重定向 (终身免疫体系)
│   ├── setup_permanent_redirection.bat   <-- 卡死四大入口 (再省 ~6.3 GB + 未来软件/模型 100% 自动入 D 盘)
│   └── rollback_permanent_redirection.bat<-- 一键撤销源头重定向与环境变量还原
│
└── 04_appdata_selective/                 <-- 【模块四】AppData 10 大常用应用定向搬迁
    ├── migrate_appdata_to_d.bat          <-- 精准搬迁 Telegram/AdsPower/miHoYo/nvm 等 (立省 ~12 GB)
    └── rollback_appdata_from_d.bat       <-- 一键撤销已搬迁应用
```

---

## 🛡️ 安全与撤销保障

- **系统核心零损伤**：所有工具均严格绕开 Windows 核心系统目录（如 `Packages`、`WinSxS`），绝无蓝屏或系统损坏隐患；
- **全套后悔药支持**：工具箱中每个迁移项均配备对应的 `rollback_*.bat` 撤销脚本，任何时候想恢复原状，双击即可无损迁回 C 盘。
