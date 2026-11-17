#!/usr/bin/env python3
"""Fail if regenerating the declared protocol changes committed candidate files."""
import hashlib
import pathlib
import subprocess
import sys

root = pathlib.Path(__file__).resolve().parents[1]
outputs = [root / 'lib/src/generated', root / '../flutter_todo_client/lib', root / 'test/integration/test_tools']

def digests():
    return {str(path.resolve()): hashlib.sha256(path.read_bytes()).hexdigest()
            for directory in outputs for path in directory.rglob('*') if path.is_file()}

before = digests()
result = subprocess.run(['dart', 'run', 'serverpod_cli:serverpod_cli', '--no-analytics', '--no-interactive', 'generate'], cwd=root)
if result.returncode:
    sys.exit(result.returncode)
after = digests()
if before != after:
    print('Protocol outputs changed; inspect and commit the generated candidate before rechecking.')
    for path in sorted(set(before) | set(after)):
        if before.get(path) != after.get(path):
            print(path)
    sys.exit(1)
print('Generated protocol matches endpoint/model sources.')
