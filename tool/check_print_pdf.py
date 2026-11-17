#!/usr/bin/env python3
"""Independently check every synthetic task marker in a native print export."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('pdf', type=Path)
    parser.add_argument('--tasks', type=int, default=120)
    parser.add_argument('--record', type=Path, help='Retained PDF/source hash record from the actual native export')
    args = parser.parse_args()
    if args.tasks < 1:
        parser.error('--tasks must be positive')
    for executable in ['pdftotext', 'pdfinfo']:
        if shutil.which(executable) is None:
            raise SystemExit(f'{executable} is required for this optional native PDF check.')
    data = args.pdf.read_bytes()
    if not data.startswith(b'%PDF-'):
        raise SystemExit('The native export is not a PDF.')
    content = subprocess.check_output(['pdftotext', '-layout', str(args.pdf), '-'], text=True)
    missing = [i for i in range(1, args.tasks + 1)
               if f'PRINT TRIAL {i:03d} of {args.tasks}' not in content]
    duplicates = [i for i in range(1, args.tasks + 1) if content.count(f'PRINT TRIAL {i:03d} of {args.tasks}') > 1]
    if duplicates:
        raise SystemExit(f'Native PDF repeats task markers: {duplicates[:8]}')
    if missing:
        raise SystemExit(f'Native PDF clipped or omitted {len(missing)} task markers; first missing: {missing[:8]}')
    info = subprocess.check_output(['pdfinfo', str(args.pdf)], text=True)
    pages = re.search(r'^Pages:\s+(\d+)', info, flags=re.MULTILINE)
    if pages is None:
        raise SystemExit('Cannot establish the native PDF page count.')
    if args.record is not None:
        record = json.loads(args.record.read_text())
        if record.get('sha256') != hashlib.sha256(data).hexdigest():
            raise SystemExit('Native PDF differs from its recorded export.')
        files = record.get('sourceFiles')
        if not isinstance(files, dict) or not files:
            raise SystemExit('Native PDF source binding is absent.')
        root = Path(__file__).resolve().parents[1]
        for name, digest in files.items():
            source = (root / name).resolve()
            if not source.is_relative_to(root) or hashlib.sha256(source.read_bytes()).hexdigest() != digest:
                raise SystemExit(f'Native print source changed: {name}')
    print(json.dumps({'tasks': args.tasks, 'allMarkersPresent': True,
                      'pages': int(pages.group(1)), 'bytes': len(data),
                      'sha256': hashlib.sha256(data).hexdigest(),
                      'scope': 'PDF content, not physical paper output'}))


if __name__ == '__main__':
    main()
