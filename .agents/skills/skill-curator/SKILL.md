---
name: skill-curator
description: Use when searching, evaluating, filtering, or installing agent skills from open-source repositories and community collections
---

# Skill Curator (技能搜寻与安装官)

## 触发场景 (When to Use)
- 用户提出需要为当前项目寻找新的专业能力（例如：“找一个自动化 Docker 构建 / Kubernetes / 代码性能分析的技能”）。
- 用户提供了一个 GitHub 仓库或 Raw SKILL.md 链接，希望审查并安装。
- **禁止场景**：如果项目已有框架、语言标准库或现有系统提示词足以解决问题，严禁滥用引入新 Skill（贯彻 YAGNI 原则）。

---

## 核心操作流程 (Core Workflow)

### 步骤 1：本地极简检索（零 Token 消耗）
在终端中执行真实 API 检索，严禁大模型凭空推断仓库是否存在：
```bash
python .agents/scripts/skill_curator.py search "<关键词>" --top 3
```

### 步骤 2：客观事实裁决（微量 Token，< 300 Token）
查看终端打印出的客观事实列表：
1. **核对真实 Star 数与来源作者**；
2. **三看三不看去伪存真**：
   - 优先选择有具体 Step 1/2 和明确 CLI 测试验证命令的技能；
   - 坚决淘汰通篇为概念吹嘘、宏大叙事的 AI 批量生成物。

### 步骤 3：物理安全安装与静态门禁
调用安装指令，脚本会自动拉取 Raw 纯文本并执行静态安全黑名单审查：
```bash
python .agents/scripts/skill_curator.py install "<GitHub Raw SKILL.md URL>" --target .agents/skills/
```

- 若检测到 `curl | sh`、破坏性删除等危险指令，脚本强制抛出异常阻断；
- **强制溯源要求**：安装生成的 `SKILL.md` 末尾**必须保留或自动追加【权威溯源与来源链接 (Sources & Citations)】**，明确注明原始 GitHub 仓库 URL、作者及官方 API 文档出处，绝不允许无源伪造；
- 审核通过后，文件自动写入项目 `.agents/skills/<name>/SKILL.md`，即刻通过渐进式加载（Progressive Disclosure）生效。

---

## 常见失误与红线 (Common Mistakes & Red Flags)
- ❌ **红线 1**：绝对禁止直接使用 `read_url_content` 抓取 SkillsMP 等复杂的完整网页（单页动辄消耗 30,000+ Token）。
- ❌ **红线 2**：绝对禁止在没有运行 `search` 命令得到真实结果前，自顾自“编造”一个 GitHub 仓库。
- ❌ **红线 3**：对于未通过单元测试验证的技能，禁止宣称已完成。
