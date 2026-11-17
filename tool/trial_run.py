#!/usr/bin/env python3
"""Run an argv command and keep local trial evidence with measured duration."""
import datetime
import json
import pathlib
import subprocess
import sys
import time

root = pathlib.Path(__file__).resolve().parents[1]
stage, label, *command = sys.argv[1:]
evidence = root / '.dartnflutter/trial'
(evidence / 'raw').mkdir(parents=True, exist_ok=True)
stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
log = evidence / 'raw' / f'{stamp}-{label}.log'
start = time.monotonic()
with log.open('w') as stream:
    result = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT)
event = dict(at=stamp, stage=stage, tool=label, argv=command, cwd=str(pathlib.Path.cwd()),
             elapsedSeconds=round(time.monotonic()-start, 3), exitCode=result.returncode,
             status='passed' if result.returncode == 0 else 'failed', retries=0,
             manualCorrection=None, usefulness='pending review', evidence=str(log.relative_to(root)))
with (evidence / 'events.jsonl').open('a') as stream:
    stream.write(json.dumps(event)+'\n')
print(json.dumps(event))
print(log.read_text()[-16000:])
sys.exit(result.returncode)
