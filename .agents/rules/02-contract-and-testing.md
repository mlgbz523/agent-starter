---
description: 契约锁定与测试通行门禁
globs: ["**/*"]
always_on: true
---

# 02-Contract and Testing

## 1. 契约先行
- 编码前先定义并锁定数据模型接口 (TypeScript Interface / Pydantic)。

## 2. 验收门禁
- 严禁以“已写完”结项；必须终端运行 CLI 测试命令（如 `pytest` / `npm test`）并提供真实 PASS 终端输出。
- **验证命令真实证伪能力**：验证命令必须具备证伪能力——故意破坏关键逻辑后测试必须能够报错抓出；严禁吞退出码、严禁使用 `|| true`、严禁仅用 `echo` 伪造通过。

## 2-B. 无测试框架时的最小测试底座
- 新项目若尚无测试框架，Agent 必须先搭建最小测试底座（如 Node 原生 `node --test`、Python `pytest`）并在 `docs/PROJECT_ENV.md` 记录；
- 交付前必须运行**全量**测试套件（不只是新增用例），确保整体无回归。

## 3. 禁止测试作弊 (No Test Tampering)
- 🚫 严禁为了让测试变绿而篡改/删除既有断言、添加 `@skip`、或关闭代码检查规则；
- 确因需求变更需调整测试，必须在 `docs/task_plan.md` 中说明理由并经 PM 批准。
