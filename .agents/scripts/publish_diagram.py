#!/usr/bin/env python3
"""
publish_diagram.py - 架构工程图云端安全发布器
连接 Cloudflare Access 保护的图管理中心 Worker (https://adm-k7e2b1.28870721.xyz/api/publish)
将本地 Archify / TopoFlow 生成的 HTML 交互式图纸发布到 R2，并获取 CDN 嵌入直链。
"""

import os
import sys
import json
import re
import argparse
import urllib.request
import urllib.error

# 敏感信息扫描正则模式
SENSITIVE_PATTERNS = [
    ('OpenAI API Key', re.compile(r'sk-[a-zA-Z0-9]{32,}')),
    ('Anthropic API Key', re.compile(r'sk-ant-[a-zA-Z0-9_-]{32,}')),
    ('AWS Access Key', re.compile(r'AKIA[0-9A-Z]{16}')),
    ('GitHub Token', re.compile(r'gh[pousr]_[A-Za-z0-9_]{36,}')),
    ('Cloudflare Token', re.compile(r'cfoat_[a-zA-Z0-9_-]{40,}|cfort_[a-zA-Z0-9_-]{40,}')),
    ('JWT Token', re.compile(r'eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}')),
    ('Private IP', re.compile(r'\b(?:10|127|192\.168)\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\b')),
    ('Windows Local Path', re.compile(r'[a-zA-Z]:[\\/](?:Users|Windows|Program Files)[\\/][^\s"\'<>]+', re.IGNORECASE)),
]

def load_dotenv(path):
    if not os.path.exists(path):
        return
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue
            k, v = line.split('=', 1)
            k, v = k.strip(), v.strip().strip('"').strip("'")
            if k not in os.environ:
                os.environ[k] = v

def scan_sensitive(content):
    findings = []
    lines = content.split('\n')
    for line_idx, line in enumerate(lines, 1):
        for p_name, regex in SENSITIVE_PATTERNS:
            for match in regex.finditer(line):
                findings.append({
                    'type': p_name,
                    'line': line_idx,
                    'match': match.group(0)[:4] + '****' + match.group(0)[-4:] if len(match.group(0)) > 8 else '****'
                })
    return findings

def publish(file_path, title, project, tags, expires_days=0, dry_run=False):
    # 加载环境变量
    env_paths = [
        os.path.join(os.getcwd(), '.env'),
        os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '.env')
    ]
    for ep in env_paths:
        load_dotenv(ep)

    endpoint = os.environ.get('ADMIN_PUBLISH_URL', 'https://adm-k7e2b1.28870721.xyz/api/publish')
    client_id = os.environ.get('CF_ACCESS_CLIENT_ID')
    client_secret = os.environ.get('CF_ACCESS_CLIENT_SECRET')

    if not client_id or not client_secret:
        return {'success': False, 'error': 'Missing CF_ACCESS_CLIENT_ID or CF_ACCESS_CLIENT_SECRET in .env'}

    if not os.path.exists(file_path):
        return {'success': False, 'error': f'Target file not found: {file_path}'}

    _, ext = os.path.splitext(file_path)
    ext = ext.lower().lstrip('.')

    if ext in ['png', 'jpg', 'jpeg', 'webp']:
        import base64
        with open(file_path, 'rb') as f:
            raw_bytes = f.read()
        mime = f'image/{ext if ext != "jpg" else "jpeg"}'
        content = f'data:{mime};base64,{base64.b64encode(raw_bytes).decode("ascii")}'
        format_type = ext if ext != 'jpg' else 'jpeg'
    else:
        with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        format_type = 'svg' if ext == 'svg' or content.strip().startswith(('<svg', '<?xml')) else 'html'

        # 文本格式本地脱敏预检
        findings = scan_sensitive(content)
        if findings:
            return {
                'success': False,
                'error': f'Sensitive information detected ({len(findings)} items). Publishing blocked.',
                'findings': findings
            }

        # Antigravity 资产与主题公网适配
        if format_type == 'html':
            content = re.sub(
                r'https://www\.gstatic\.com/antigravity/web/dev/tailwindcss\.min\.js',
                'https://v-8f3a9c.cdn-core.28870721.xyz/assets/antigravity/tailwindcss.min.js',
                content
            )

    expires_at = None
    if expires_days > 0:
        import time
        expires_at = int(time.time() * 1000) + expires_days * 86400 * 1000

    payload = {
        'title': title,
        'project': project,
        'tags': tags,
        'format': format_type,
        'expires_at': expires_at,
        'content': content
    }

    if dry_run:
        return {
            'success': True,
            'dry_run': True,
            'title': title,
            'project': project,
            'format': format_type,
            'media_type': 'image' if format_type in ['svg', 'png', 'jpg', 'jpeg'] else 'html',
            'size_bytes': len(content.encode('utf-8'))
        }

    req_data = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(endpoint, data=req_data, method='POST')
    req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
    req.add_header('Content-Type', 'application/json')
    req.add_header('CF-Access-Client-Id', client_id)
    req.add_header('CF-Access-Client-Secret', client_secret)

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            resp_body = resp.read().decode('utf-8')
            data = json.loads(resp_body)
            return data
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode('utf-8', errors='replace')
        return {'success': False, 'status': e.code, 'error': err_msg}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def main():
    parser = argparse.ArgumentParser(description='Publish architecture diagrams to Cloudflare Worker Diagram Center')
    parser.add_argument('--file', '-f', required=True, help='Path to HTML diagram file')
    parser.add_argument('--title', '-t', default='系统设计架构图', help='Diagram title')
    parser.add_argument('--project', '-p', default='lucid-hertz', help='Project key')
    parser.add_argument('--tags', default='architecture,production', help='Comma-separated tags')
    parser.add_argument('--expires-days', type=int, default=0, help='Expiry in days (0 for permanent)')
    parser.add_argument('--dry-run', action='store_true', help='Validate locally without uploading')

    args = parser.parse_args()
    res = publish(args.file, args.title, args.project, args.tags, args.expires_days, args.dry_run)
    print(json.dumps(res, indent=2, ensure_ascii=False))
    if not res.get('success'):
        sys.exit(1)

if __name__ == '__main__':
    main()
