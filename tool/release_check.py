#!/usr/bin/env python3
"""Check the candidate's source-release inventory before publishing an archive."""
from pathlib import Path
import json
import subprocess
import struct
import hashlib
import re
import plistlib

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
    manifest = json.loads((ROOT / 'docs/screenshots/manifest.json').read_text())
    version = re.search(r'^version:\s*(\S+)', (ROOT / 'flutter_todo_flutter/pubspec.yaml').read_text(), re.MULTILINE)
    if version is None or manifest.get('appVersion') != version.group(1):
        raise SystemExit('Screenshot manifest does not identify the current application version.')
    expected = {f'docs/screenshots/{device}-{panel}.png'
                for device in ['iphone', 'ipad', 'ipad-landscape', 'macos']
                for panel in ['my-day', 'details', 'details-keyboard', 'suggestions', 'lists']}
    expected.add('docs/screenshots/ipad-landscape-auto-details.png')
    images = {item['file']: item for item in manifest['images']}
    actual = {str(path.relative_to(ROOT)) for path in (ROOT / 'docs/screenshots').glob('*.png')}
    if set(images) != expected or actual != expected:
        raise SystemExit('Current native screenshot inventory is incomplete or contains an old capture.')
    for name, metadata in images.items():
        data = (ROOT / name).read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n':
            raise SystemExit(f'Capture is not an original PNG: {name}')
        width, height = struct.unpack('>II', data[16:24])
        if min(width, height) < 700 or (width, height) != (metadata['width'], metadata['height']) or hashlib.sha256(data).hexdigest() != metadata['sha256']:
            raise SystemExit(f'Native capture metadata/digest mismatch: {name}')
        if 'ipad-landscape' in name and width <= height:
            raise SystemExit('Requested iPad landscape capture is not landscape.')
    for name, digest in manifest['sourceFiles'].items():
        source = (ROOT / name).resolve()
        if not source.is_relative_to(ROOT) or hashlib.sha256(source.read_bytes()).hexdigest() != digest:
            raise SystemExit(f'Screenshot source changed: {name}')
    for name in ['DebugProfile.entitlements', 'Release.entitlements']:
        entitlements = plistlib.loads((ROOT / 'flutter_todo_flutter/macos/Runner' / name).read_bytes())
        if not entitlements.get('com.apple.security.app-sandbox') or not entitlements.get('com.apple.security.print'):
            raise SystemExit(f'Printing or sandbox declaration missing: {name}')
    for name in ['README.md', 'CHANGELOG.md', 'LICENSE', 'docs/app-guide.md', 'docs/development.md', 'docs/architecture.md', 'docs/security.md', 'docs/trial/final-report.md', 'docs/trial/issue-9-report.md', 'docs/trial/issue-9-verification.json']:
        if not (ROOT / name).is_file():
            raise SystemExit(f'Required release document absent: {name}')
    manifest = json.loads((ROOT / 'docs/design/icon-variants/manifest.json').read_text())
    if manifest.get('status') != 'final':
        raise SystemExit('Icon selection is not final.')
    print(f'Source-release inventory passed: {len(set(filter(None, files)))} files; native captures and final icon present; no app binaries/private configuration.')


if __name__ == '__main__':
    main()
