---
description: 依赖探针与防假闭环命令规范
globs: ["**/*"]
always_on: false
---

# 03-Hallucination Probes

## 1. 依赖真实性探针 (终端预检命令)
- **Python**: `python -c "import pkg_name; print(hasattr(pkg_name, 'expected_method'))"`
- **Node.js**: `npm view pkg_name version`

## 2. 交付红线
- 严禁留空实现（`// TODO` / `pass`）。
- 每个步骤必须附带一行可复现的 CLI 自动化验证命令。
