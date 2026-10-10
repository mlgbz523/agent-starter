---
description: 契约锁定与测试通行门禁
globs: ["**/*"]
always_on: false
---

# 02-Contract and Testing

## 1. 契约先行
- 编码前先定义并锁定数据模型接口 (TypeScript Interface / Pydantic)。

## 2. 验收门禁
- 严禁以“已写完”结项；必须终端运行 CLI 测试命令（如 `pytest` / `npm test`）并提供 PASS 输出。
