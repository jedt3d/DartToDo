#!/usr/bin/env python3
"""Build for one actual simulator, avoiding generic multi-architecture builds."""
import argparse
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--device', default='02ED3EB4-23A2-41AB-8D17-49E352A076D3')
    args = parser.parse_args()
    listing = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '-j'], text=True))
    if not any(d['udid'] == args.device for devices in listing['devices'].values() for d in devices):
        raise SystemExit('Requested simulator is not installed/available.')
    subprocess.run(['flutter', 'build', 'ios', '--simulator', '--debug', '--config-only', '--no-pub'], cwd=ROOT / 'flutter_todo_flutter', check=True)
    subprocess.run(['xcodebuild', '-workspace', 'ios/Runner.xcworkspace', '-scheme', 'Runner', '-configuration', 'Debug',
                    '-sdk', 'iphonesimulator', '-destination', f'id={args.device}', '-derivedDataPath', 'build/ios-target',
                    'ONLY_ACTIVE_ARCH=YES', 'CODE_SIGNING_ALLOWED=NO', 'build'], cwd=ROOT / 'flutter_todo_flutter', check=True)


if __name__ == '__main__':
    main()
