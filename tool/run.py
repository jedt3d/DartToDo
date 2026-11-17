#!/usr/bin/env python3
"""Start the local backend, then run the selected native Flutter target."""
import argparse
import json
import os
from pathlib import Path
import socket
import subprocess
import time
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / '.dartnflutter/runtime'
APP = ROOT / 'flutter_todo_flutter'
TARGETS = {
    'macos': 'macos',
    'iphone': '02ED3EB4-23A2-41AB-8D17-49E352A076D3',
    'ipad': '62507A81-E969-448F-8510-136600AB8DC6',
}


def healthy():
    try:
        request = urllib.request.Request('http://127.0.0.1:8870/todo/fetch', data=b'{}', headers={'Content-Type': 'application/json'}, method='POST')
        with urllib.request.urlopen(request, timeout=2) as response:
            result = json.load(response)
        return isinstance(result, dict) and all(key in result for key in ['tasks', 'lists', 'groups', 'settings'])
    except (OSError, ValueError, urllib.error.URLError):
        return False


def start_backend():
    if healthy():
        print('Local Serverpod is ready at 127.0.0.1:8870.')
        return
    with socket.socket() as probe:
        if probe.connect_ex(('127.0.0.1', 8870)) == 0:
            raise SystemExit('Port 8870 is occupied by a service that did not pass the DartToDo check.')
    STATE.mkdir(parents=True, exist_ok=True)
    log = (STATE / 'server.log').open('ab')
    process = subprocess.Popen(['dart', 'bin/main.dart', '--apply-migrations'], cwd=ROOT / 'flutter_todo_server',
                               stdout=log, stderr=subprocess.STDOUT, start_new_session=True, env=os.environ.copy())
    log.close()
    (STATE / 'server.pid').write_text(str(process.pid))
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise SystemExit(f'Server stopped. Inspect {STATE / "server.log"}.')
        if healthy():
            print('Local Serverpod is ready at 127.0.0.1:8870.')
            return
        time.sleep(0.2)
    raise SystemExit(f'Server did not become ready. Inspect {STATE / "server.log"}.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=TARGETS, nargs='?', default='macos')
    parser.add_argument('--backend-only', action='store_true')
    args = parser.parse_args()
    start_backend()
    if args.backend_only:
        return
    target = TARGETS[args.target]
    if args.target != 'macos':
        listing = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '-j'], text=True))
        device = next((d for devices in listing['devices'].values() for d in devices if d['udid'] == target), None)
        if device is None:
            raise SystemExit(f'The configured {args.target} simulator is absent; choose an installed UUID in tool/run.py.')
        if device['state'] != 'Booted':
            subprocess.run(['xcrun', 'simctl', 'boot', target], check=True)
    subprocess.run(['flutter', 'run', '--no-pub', '-d', target], cwd=APP, check=True)


if __name__ == '__main__':
    main()
