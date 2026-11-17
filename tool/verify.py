#!/usr/bin/env python3
"""Run finite local checks; optional native tests require installed simulators."""
import argparse
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--native', action='store_true')
    args = parser.parse_args()
    checks = [
        ('.', ['dart', 'format', '--output=none', '--set-exit-if-changed', 'flutter_todo_flutter/lib', 'flutter_todo_flutter/test', 'flutter_todo_flutter/integration_test', 'flutter_todo_flutter/test_driver', 'flutter_todo_server/lib', 'flutter_todo_server/test', 'flutter_todo_server/tool', 'flutter_todo_client/lib', 'flutter_todo_client/tool']),
        ('.', ['flutter', 'analyze', '--no-pub', '--fatal-infos']),
        ('flutter_todo_flutter', ['flutter', 'test', '--no-pub']),
        ('flutter_todo_server', ['dart', 'test']),
        ('flutter_todo_server', ['python3', 'tool/check_codegen.py']),
        ('.', ['python3', 'tool/run.py', '--backend-only']),
        ('flutter_todo_client', ['dart', 'run', 'tool/live_smoke.dart']),
        ('flutter_todo_server', ['dart', 'run', 'tool/http_security_smoke.dart']),
    ]
    if args.native:
        checks.append(('flutter_todo_flutter', ['flutter', 'build', 'macos', '--debug', '--no-pub']))
        checks.append(('.', ['python3', 'tool/build_ios.py']))
        for target in ['macos', '02ED3EB4-23A2-41AB-8D17-49E352A076D3', '62507A81-E969-448F-8510-136600AB8DC6']:
            checks.append(('flutter_todo_flutter', ['flutter', 'test', '--no-pub', 'integration_test/app_test.dart', '-d', target]))
    for directory, command in checks:
        print(f'Checking {directory}: {command}', flush=True)
        subprocess.run(command, cwd=ROOT / directory, check=True)
    print('All requested checks passed.')


if __name__ == '__main__':
    main()
