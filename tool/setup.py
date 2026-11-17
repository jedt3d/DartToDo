#!/usr/bin/env python3
"""Prepare this checkout without replacing SDKs, global CLIs or existing data."""
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def run(argv, cwd=ROOT, **kwargs):
    subprocess.run(argv, cwd=cwd, check=True, **kwargs)


def postgres_bin():
    installed = shutil.which('psql')
    if installed:
        return Path(installed).resolve().parent
    observed = Path('/Applications/Postgres.app/Contents/Versions/17/bin')
    if (observed / 'psql').exists():
        return observed
    raise SystemExit('PostgreSQL client tools were not found. Add their bin directory to PATH.')


def main():
    if not shutil.which('flutter') or not shutil.which('dart'):
        raise SystemExit('Flutter and its Dart SDK must be on PATH.')
    run(['flutter', '--version'])
    run(['xcodebuild', '-version'])
    pg = postgres_bin()
    environment = {**os.environ, 'PGPASSWORD': '', 'PGCONNECT_TIMEOUT': '5'}
    base = [str(pg / 'psql'), '-X', '-w', '-h', 'localhost', '-p', '5432', '-U', 'worajedt', '-d', 'postgres', '-Atc']
    run(base + ['select version();'], env=environment)
    for name in ['flutter_todo', 'flutter_todo_test']:
        exists = subprocess.check_output(base + [f"select 1 from pg_database where datname='{name}';"], env=environment, text=True).strip()
        if exists != '1':
            run([str(pg / 'createdb'), '-w', '-h', 'localhost', '-p', '5432', '-U', 'worajedt', name], env=environment)
    passwords = ROOT / 'flutter_todo_server/config/passwords.yaml'
    if not passwords.exists():
        passwords.write_text("# Local PostgreSQL trust authentication.\nshared:\n  database: ''\n")
        passwords.chmod(0o600)
    run(['flutter', 'pub', 'get', '--enforce-lockfile'])
    run(['dart', 'run', 'serverpod_cli:serverpod_cli', '--no-analytics', '--no-interactive', 'generate'], ROOT / 'flutter_todo_server')
    reference = Path('/Applications/Microsoft To Do.app')
    if reference.exists():
        run(['swift', 'tool/import_reference_assets.swift', 'flutter_todo_flutter/assets/themes'])
    else:
        print('Optional Microsoft photo themes are absent; solid themes and Unsplash My Day work without them.')
    print('Setup complete. Start with: python3 tool/run.py macos')


if __name__ == '__main__':
    main()
