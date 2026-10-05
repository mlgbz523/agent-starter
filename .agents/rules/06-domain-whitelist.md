---
description: Agent 网络访问域名白名单配置
globs: ["**/*"]
always_on: false
---

# 06-Domain Whitelist

> **最小权限原则**：Agent 仅允许访问以下受信域名，严禁扫描内网或向未知外部域名发送请求。

| 域名 | 用途说明 | 维护责任人 |
| :--- | :--- | :--- |
| `api.github.com` | skill_curator 技能生态检索与元数据抓取 | Agent / PM |
| `github.com` | 官方开源仓库拉取 | Agent / PM |
| `registry.npmjs.org` | Node.js 官方依赖元数据检索 | Agent / PM |
| `pypi.org` | Python 官方依赖元数据检索 | Agent / PM |

*注：若需访问新域名，需向 PM 提交申请卡片，获批后更新此文件。*
