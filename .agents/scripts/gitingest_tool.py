#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gitingest Tool for AI Agent
将 Git 仓库 (远程 URL 或本地目录) 精炼打包为结构化上下文，供 LLM 单次摄取。
支持按文件大小、通配符包含/排除过滤，并输出预估 Token 统计。
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Optional, Set

try:
    from gitingest import ingest
except ImportError:
    print("[Error] gitingest 未安装，请先执行 `pip install gitingest`", file=sys.stderr)
    sys.exit(1)


def parse_patterns(pattern_str: Optional[str]) -> Optional[Set[str]]:
    if not pattern_str:
        return None
    patterns = set()
    for item in pattern_str.split(","):
        clean = item.strip()
        if clean:
            patterns.add(clean)
    return patterns or None


def run_ingest(
    source: str,
    output_path: Optional[str] = None,
    include_patterns: Optional[str] = None,
    exclude_patterns: Optional[str] = None,
    max_file_size: int = 50_000,
) -> dict:
    inc = parse_patterns(include_patterns)
    exc = parse_patterns(exclude_patterns)

    summary, tree, content = ingest(
        source,
        include_patterns=inc,
        exclude_patterns=exc,
        max_file_size=max_file_size,
    )

    result = {
        "source": source,
        "summary": summary,
        "tree": tree,
        "content_length": len(content),
    }

    if output_path:
        out_file = Path(output_path).resolve()
        out_file.parent.mkdir(parents=True, exist_ok=True)
        full_text = f"{summary}\n\nDirectory structure:\n{tree}\n\n{content}"
        out_file.write_text(full_text, encoding="utf-8")
        result["output_file"] = str(out_file)

    return result, content


def main():
    parser = argparse.ArgumentParser(
        description="Gitingest Tool - 仓库代码结构与上下文极速提取器"
    )
    parser.add_argument("source", help="目标仓库 URL 或本地文件目录路径")
    parser.add_argument("-o", "--output", help="输出打包上下文的目标文件路径")
    parser.add_argument("-i", "--include", help="包含通配符模式，逗号分隔，如 '*.py,*.md'")
    parser.add_argument("-e", "--exclude", help="排除通配符模式，逗号分隔，如 '*test*,*docs*'")
    parser.add_argument(
        "--max-size",
        type=int,
        default=50_000,
        help="单个文件最大字节限制 (默认 50000 字节)",
    )
    parser.add_argument("--json", action="store_true", help="仅输出 JSON 摘要元信息")

    args = parser.parse_args()

    try:
        meta, content = run_ingest(
            source=args.source,
            output_path=args.output,
            include_patterns=args.include,
            exclude_patterns=args.exclude,
            max_file_size=args.max_size,
        )
    except Exception as e:
        print(f"[Error] 执行 gitingest 失败: {e}", file=sys.stderr)
        sys.exit(1)

    if args.json:
        print(json.dumps(meta, ensure_ascii=False, indent=2))
    else:
        print("=== 摄取摘要 ===")
        print(meta["summary"])
        print("\n=== 目录树 ===")
        print(meta["tree"])
        if "output_file" in meta:
            print(f"\n[OK] 完整上下文已保存至: {meta['output_file']}")
        else:
            print("\n=== 源码正文预览 (前 500 字符) ===")
            print(content[:500] + ("..." if len(content) > 500 else ""))


if __name__ == "__main__":
    main()
