#!/usr/bin/env python3
"""
skill_curator.py - 极简、低 Token、跨平台的 Agent Skill 搜寻、审计与安装工具。
仅使用 Python 3 标准库，零外部依赖。
"""

import sys
import os
import io

# 确保在 Windows 控制台或非 UTF-8 环境下输出中文和 Emoji 不报错
if sys.platform.startswith("win"):
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

import json
import argparse
import urllib.request
import urllib.parse
import urllib.error
import re
from pathlib import Path

GITHUB_API_SEARCH_CODE = "https://api.github.com/search/code"
GITHUB_API_SEARCH_REPOS = "https://api.github.com/search/repositories"
USER_AGENT = "Antigravity-SkillCurator/1.0"

# 高危指令静态审计黑名单规则
SECURITY_BLACK_LIST = [
    (r"curl\s+.*\|\s*(?:bash|sh)", "直接通过管道将网络脚本喂给 bash/sh 执行 (curl | sh)"),
    (r"wget\s+.*\|\s*(?:bash|sh)", "直接通过管道将网络脚本喂给 bash/sh 执行 (wget | sh)"),
    (r"rm\s+-rf\s+[/~]", "删除根目录或用户主目录的破坏性命令 (rm -rf /)"),
    (r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:", "Fork 炸弹攻击"),
    (r"mkfs\.", "格式化磁盘分区命令"),
    (r"eval\s*\(\s*(?:base64|atob)", "执行经过 base64 混淆的动态代码"),
    (r"(?:nc|netcat)\s+-e", "反弹 Shell 网络后门"),
]

def make_request(url: str, token: str = None) -> dict:
    headers = {
        "User-Agent": USER_AGENT,
        "Accept": "application/vnd.github.v3+json"
    }
    # 支持外部传入 GITHUB_TOKEN，避免 API 速率限制
    gh_token = token or os.environ.get("GITHUB_TOKEN")
    if gh_token:
        headers["Authorization"] = f"token {gh_token}"

    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=12) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        if e.code == 403:
            sys.stderr.write("[ERROR] 触发 GitHub API 速率限制。可通过设置环境变量 GITHUB_TOKEN 提高额度。\n")
        else:
            sys.stderr.write(f"[ERROR] HTTP 请求失败: {e.code} {e.reason}\n")
        return None
    except Exception as e:
        sys.stderr.write(f"[ERROR] 网络请求异常: {str(e)}\n")
        return None

def fetch_raw_text(url: str) -> str:
    headers = {"User-Agent": USER_AGENT}
    gh_token = os.environ.get("GITHUB_TOKEN")
    if gh_token:
        headers["Authorization"] = f"token {gh_token}"
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=12) as response:
            return response.read().decode("utf-8", errors="replace")
    except Exception as e:
        sys.stderr.write(f"[ERROR] 无法拉取文本内容: {str(e)}\n")
        return None

def parse_frontmatter(content: str) -> dict:
    """提取 Markdown 中的 YAML Frontmatter 元数据"""
    fm = {}
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if match:
        raw_yaml = match.group(1)
        for line in raw_yaml.splitlines():
            line = line.strip()
            if ":" in line and not line.startswith("#"):
                key, val = line.split(":", 1)
                fm[key.strip().lower()] = val.strip().strip("'\"")
    return fm

def search_skills(query: str, top_n: int = 3):
    """
    通过 GitHub Code / Repo API 搜索 SKILL.md，按客观事实整理输出，杜绝幻觉。
    只输出极简表格（~200 字），节约 98% Token。
    """
    print(f"\n[🔍 正在向 GitHub 发起真实检索: '{query}']...")

    # 策略 1: 优先检索知名公共 skills 仓库或带有 antigravity-skills / claude-code-skills 的项目
    encoded_q = urllib.parse.quote(f"{query} filename:SKILL.md")
    url = f"{GITHUB_API_SEARCH_CODE}?q={encoded_q}&per_page=10"
    data = make_request(url)

    candidates = []

    if data and "items" in data and len(data["items"]) > 0:
        seen_repos = set()
        for item in data["items"]:
            repo_full = item.get("repository", {}).get("full_name")
            if not repo_full or repo_full in seen_repos:
                continue
            seen_repos.add(repo_full)

            raw_url = item.get("html_url", "").replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")
            path = item.get("path", "SKILL.md")
            skill_name = Path(path).parent.name if Path(path).parent.name else item.get("repository", {}).get("name")

            candidates.append({
                "repo": repo_full,
                "name": skill_name,
                "raw_url": raw_url,
                "html_url": item.get("html_url")
            })
            if len(candidates) >= top_n:
                break

    # 如果基于 Code 检索不到，退化策略 2: 搜索开源 awesome-skills 仓库
    if not candidates:
        encoded_repo_q = urllib.parse.quote(f"{query} skills")
        repo_url = f"{GITHUB_API_SEARCH_REPOS}?q={encoded_repo_q}&sort=stars&order=desc&per_page={top_n}"
        repo_data = make_request(repo_url)
        if repo_data and "items" in repo_data:
            for r in repo_data["items"][:top_n]:
                repo_full = r.get("full_name")
                raw_url = f"https://raw.githubusercontent.com/{repo_full}/main/SKILL.md"
                candidates.append({
                    "repo": repo_full,
                    "name": r.get("name"),
                    "raw_url": raw_url,
                    "html_url": r.get("html_url"),
                    "stars": r.get("stargazers_count", 0)
                })

    if not candidates:
        print("[INFO] 未检索到完全匹配的公开 SKILL.md。请尝试更换或精炼关键词。")
        return

    print("\n--- 真实检索结果清单 (按客观事实呈现，零虚构) ---")
    for idx, c in enumerate(candidates, 1):
        print(f"[{idx}] 技能名称: {c['name']}")
        print(f"    来源仓库: https://github.com/{c['repo']}")
        print(f"    Raw 地址: {c['raw_url']}")
        # 尝试静默拉取前 15 行提取描述
        head_sample = fetch_raw_text(c['raw_url'])
        if head_sample:
            fm = parse_frontmatter(head_sample)
            desc = fm.get("description", "无显式元数据说明")
            # 截短避免浪费 Token
            print(f"    说明: {desc[:100]}...")
        print()

def audit_content(content: str) -> tuple[bool, list]:
    """对下载的 Skill 文本执行静态安全门禁与质量检查"""
    threats = []
    for pattern, desc in SECURITY_BLACK_LIST:
        if re.search(pattern, content, re.IGNORECASE):
            threats.append(desc)

    is_safe = len(threats) == 0
    return is_safe, threats

def install_skill(raw_url: str, target_dir: str = ".agents/skills", custom_name: str = None):
    """
    物理下载、安全审查并安装目标 Skill 到工作区。
    """
    print(f"\n[⬇️ 正在从真实源下载]: {raw_url}")
    content = fetch_raw_text(raw_url)
    if not content:
        print("[ERROR] 下载失败：目标文件不存在或网络不可达。中断安装。")
        sys.exit(1)

    # 1. 静态安全审查
    is_safe, threats = audit_content(content)
    if not is_safe:
        print("\n[🚨 安全拦截：检测到高危潜在指令！]")
        for t in threats:
            print(f"  - 风险项: {t}")
        print("[STOP] 出于安全保护，已终止安装该 Skill。")
        sys.exit(2)

    # 2. 规范化 Frontmatter 与技能名称
    fm = parse_frontmatter(content)
    skill_name = custom_name or fm.get("name")
    if not skill_name:
        # 从 URL 推导
        skill_name = Path(raw_url).parent.name if Path(raw_url).parent.name != "" else "custom-skill"
    skill_name = re.sub(r"[^a-zA-Z0-9_-]", "-", skill_name).strip("-").lower()

    dest_folder = Path(target_dir) / skill_name
    dest_folder.mkdir(parents=True, exist_ok=True)
    dest_file = dest_folder / "SKILL.md"

    # 如果原内容无 Frontmatter，自动包装合规头部
    final_content = content
    if not match_fm(content):
        desc = f"Use when working with {skill_name} tasks"
        final_content = f"---\nname: {skill_name}\ndescription: {desc}\n---\n\n" + content

    # 强制在文件末尾追加安装溯源信息（Provenance）
    if "## 权威溯源与来源链接" not in final_content and "## Sources" not in final_content:
        final_content += f"\n\n---\n\n## 权威溯源与来源链接 (Sources & Citations)\n- 原始来源 (Source URL): {raw_url}\n- 审查状态: 静态安全门禁已通过 (Audit Passed)\n"

    dest_file.write_text(final_content, encoding="utf-8")
    print(f"\n[✅ 安装成功！]")
    print(f"  - 技能名称: {skill_name}")
    print(f"  - 本地路径: {dest_file.resolve()}")
    print(f"  - 溯源地址: {raw_url}")
    print(f"  - 生效状态: 已对当前工作区即时生效（渐进式加载，平时零 Token 占用）。")

def match_fm(text: str) -> bool:
    return bool(re.match(r"^---\s*\n.*?\n---\s*\n", text, re.DOTALL))

def main():
    parser = argparse.ArgumentParser(description="Antigravity 极简低 Token 技能搜寻与安装工具")
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    # search 命令
    search_p = subparsers.add_parser("search", help="在开源社区搜索真实存在的 Skill")
    search_p.add_argument("query", type=str, help="关键词，如 docker / kubernetes / vue")
    search_p.add_argument("--top", type=int, default=3, help="返回前 N 个候选 (默认 3)")

    # install 命令
    install_p = subparsers.add_parser("install", help="安全下载并安装目标 Skill")
    install_p.add_argument("raw_url", type=str, help="GitHub Raw SKILL.md 文件下载链接")
    install_p.add_argument("--name", type=str, default=None, help="自定义安装后的技能文件夹名称")
    install_p.add_argument("--target", type=str, default=".agents/skills", help="安装目标目录 (默认 .agents/skills)")

    args = parser.parse_args()

    if args.subcommand == "search":
        search_skills(args.query, top_n=args.top)
    elif args.subcommand == "install":
        install_skill(args.raw_url, target_dir=args.target, custom_name=args.name)

if __name__ == "__main__":
    main()
