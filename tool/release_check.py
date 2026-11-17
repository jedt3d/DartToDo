#!/usr/bin/env python3
"""Check the candidate's source-release inventory before publishing an archive."""
from pathlib import Path
import json
import subprocess
import struct

ROOT = Path(__file__).resolve().parents[1]


def main():
    files = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=ROOT).decode().split('\0')
    forbidden = []
    for name in filter(None, files):
        parts = Path(name).parts
        if any(part in {'.dartnflutter', '.dart_tool', 'Pods', 'build', 'private-reference'} or part.endswith(('.app', '.framework', '.dSYM')) for part in parts):
            forbidden.append(name)
        if name.endswith(('passwords.yaml', '.dump', '.p12', '.pem', '.key', '.ipa', '.dmg', '.pkg', '.zip')) or Path(name).name.startswith('.env'):
            forbidden.append(name)
        if name.startswith('flutter_todo_flutter/assets/themes/') and name.endswith('.png'):
            forbidden.append(name)
    if forbidden:
        raise SystemExit('Excluded material in source inventory: ' + ', '.join(sorted(set(forbidden))))
    for device in ['iphone', 'ipad']:
        for panel in ['my-day', 'details', 'suggestions', 'lists']:
            path = ROOT / f'docs/screenshots/{device}-{panel}.png'
            data = path.read_bytes()
            if data[:8] != b'\x89PNG\r\n\x1a\n' or min(struct.unpack('>II', data[16:24])) < 700:
                raise SystemExit(f'Missing/full-resolution native capture: {path}')
    for name in ['README.md', 'CHANGELOG.md', 'LICENSE', 'docs/app-guide.md', 'docs/development.md', 'docs/architecture.md', 'docs/security.md', 'docs/trial/final-report.md']:
        if not (ROOT / name).is_file():
            raise SystemExit(f'Required release document absent: {name}')
    manifest = json.loads((ROOT / 'docs/design/icon-variants/manifest.json').read_text())
    if manifest.get('status') != 'final':
        raise SystemExit('Icon selection is not final.')
    print(f'Source-release inventory passed: {len(set(filter(None, files)))} files; native captures and final icon present; no app binaries/private configuration.')


if __name__ == '__main__':
    main()
