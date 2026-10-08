---
description: 依赖探针与防假闭环命令规范
globs: ["**/*"]
always_on: false
---

# 03-Hallucination Probes

## 1. 依赖真实性探针 (预检门禁)
- 外部依赖引入前必须执行终端真实性探针（具体语言命令套路按需通过 Hooks ② 召回）。

## 2. 交付红线
- 严禁留空实现（`// TODO` / `pass`）。
- 每个步骤必须附带一行可复现的 CLI 自动化验证命令且退出码必须为 0。
