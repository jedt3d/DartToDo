#!/usr/bin/env python3
"""Rebuild semantic mappings and optionally record current named test evidence."""
import argparse
import collections
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[2]
runner = root.parent / 'tool/trial_run.py'
cli = Path('/Users/worajedt/.codex/skills/dnf-ui/scripts/dnf.mjs')
state = root / '.dartnflutter'
state.mkdir(exist_ok=True)

groups = {
    'TodoApp': [('default', 'previewAppDefault'), ('loading', 'previewAppLoading'), ('error', 'previewAppError')],
    '_TodoHome': [('default', 'previewAppDefault'), ('loading', 'previewAppLoading'), ('error', 'previewAppError')],
    '_FailurePage': [('error', 'previewFailure')],
    '_Sidebar': [('default', 'previewSidebar')],
    '_NavTile': [('default', 'previewNavigationDefault'), ('selected', 'previewNavigationSelected')],
    '_TaskPane': [('default', 'previewTaskPane'), ('empty', 'previewTaskPaneEmpty'), ('search-empty', 'previewTaskPaneSearch'), ('completed', 'previewTaskPaneCompleted'), ('photo', 'previewTaskPanePhoto')],
    '_HeaderButton': [('default', 'previewHeaderButton')],
    '_TaskRow': [('default', 'previewTaskRow'), ('selected', 'previewTaskRowSelected'), ('completed', 'previewTaskRowCompleted')],
    '_CheckCircle': [('unchecked', 'previewCheckOpen'), ('checked', 'previewCheckComplete')],
    '_Composer': [('default', 'previewComposer'), ('saving', 'previewComposerSaving'), ('error', 'previewComposerError')],
    '_EmptyState': [('search-empty', 'previewEmptyState')],
    '_SuggestionsPanel': [('default', 'previewSuggestions'), ('empty', 'previewSuggestionsEmpty')],
    '_TaskDetails': [('default', 'previewTaskDetails'), ('completed', 'previewTaskDetailsCompleted')],
    '_DetailAction': [('default', 'previewDetailAction'), ('active', 'previewDetailActionActive')],
    '_SettingsDialog': [('default', 'previewSettings'), ('dark', 'previewSettingsDark')],
    '_ThemeDialog': [('default', 'previewThemeDialog')],
    '_RepeatDialog': [('custom', 'previewRepeatDialog')],
    '_NameDialog': [('default', 'previewNameDialog')],
}

# These are coordination links to the authored board, not approval/fidelity.
# No approved design snapshot is imported by this script.
figma_links = {
    'TodoApp': '7:35', '_TodoHome': '7:35', '_Sidebar': '7:35',
    '_TaskPane': '7:35', '_TaskDetails': '7:558',
    '_NavTile': '5:85', '_TaskRow': '5:116', '_CheckCircle': '5:72',
    '_Composer': '5:133', '_DetailAction': '5:127',
}

def run(label, *args):
    command = [sys.executable, str(runner), 'ui', label, 'node', str(cli), *args, '--root', str(root)]
    subprocess.run(command, cwd=root, check=True)

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')

parser = argparse.ArgumentParser()
parser.add_argument('--record', action='store_true', help='Execute every exact named widget test and bind raw evidence')
options = parser.parse_args()
run('catalog-help', '--help')
run('catalog-scan', 'widgets', 'scan', '--out', str(state / 'inventory.json'))
run('catalog-init', 'widgets', 'init', '--out', str(state / 'catalog-initial.json'))
inventory = json.loads((state / 'inventory.json').read_text())
if inventory['engine'] != 'dart-analyzer' or not inventory['complete']:
    raise SystemExit('Complete semantic analysis is required; lexical hints cannot certify coverage.')
catalog_path = root / 'widget-catalog.json'
old = json.loads(catalog_path.read_text()) if catalog_path.exists() else {'entries': []}
old_entries = {entry['widgetId']: entry for entry in old['entries']}
entries = []
cases = collections.defaultdict(list)
for widget in inventory['widgets']:
    owner = widget['ownerWidgetId'].split('#')[-1] if widget.get('ownerWidgetId') else widget['name']
    if owner not in groups:
        raise SystemExit('Unmapped declaration needs reviewed harness and tests: ' + widget['id'])
    owner_context = widget['kind'] == 'widget-builder'
    entry = {
        'widgetId': widget['id'],
        'access': {'kind': 'owner-context', 'ownerWidgetId': widget['ownerWidgetId']} if owner_context else
                  {'kind': 'in-library', 'harnessFile': widget['libraryFile']} if widget['visibility'] == 'private' else {'kind': 'direct'},
        'requiredStates': [state for state, _ in groups[owner]],
        'cases': [],
    }
    if old_entries.get(widget['id'], {}).get('figmaNodeId'):
        entry['figmaNodeId'] = old_entries[widget['id']]['figmaNodeId']
    elif owner in figma_links:
        entry['figmaNodeId'] = figma_links[owner]
    for case_state, builder in groups[owner]:
        case = {
            'id': 'catalog-' + case_state, 'name': case_state.replace('-', ' ').title(), 'state': case_state,
            'builder': {'import': 'package:flutter_todo_flutter/ui/todo_app.dart', 'function': builder, 'source': 'lib/ui/catalog_previews.dart'},
            'requiredEvidence': ['widget-test'],
        }
        entry['cases'].append(case)
        cases[case_state].append((widget['id'], case))
    entries.append(entry)
catalog = {'schemaVersion': 1, 'inventoryFingerprint': inventory['fingerprint'], 'entries': entries}
design = state / 'design.json'
if design.exists():
    catalog['designRevision'] = json.loads(design.read_text())['source']['revision']
write(catalog_path, catalog)
run('widgetbook-generate', 'widgets', 'generate', '--catalog', str(catalog_path), '--out', str(root / 'lib/widgetbook.dart'))
subprocess.run(['dart', 'format', str(root / 'lib/widgetbook.dart')], cwd=root, check=True)
if options.record:
    for case_state, mapped in cases.items():
        input_path = state / 'catalog-input' / (case_state + '.json')
        report_file = '.dartnflutter/evidence/catalog/' + case_state + '.json'
        write(input_path, {
            'caseId': 'catalog-' + case_state, 'widgetIds': [widget_id for widget_id, _ in mapped],
            'state': case_state, 'method': 'widget-test',
            'command': {'executable': 'flutter', 'args': ['test', '--no-pub', '--machine', 'test/ui/catalog_test.dart', '--plain-name', 'catalog state ' + case_state], 'timeoutMs': 120000},
            'testName': 'catalog state ' + case_state, 'reportFile': report_file,
        })
        output_path = state / 'catalog-input' / (case_state + '-result.json')
        run('catalog-record-' + case_state, 'widgets', 'record', '--file', str(input_path), '--out', str(output_path))
        reference = json.loads(output_path.read_text())['reference']
        for _, case in mapped:
            case['evidence'] = reference
    write(catalog_path, catalog)
    run('catalog-validate', 'widgets', 'validate', '--catalog', str(catalog_path), '--out', str(state / 'catalog-report.json'))
print(json.dumps({'semanticDeclarations': len(entries), 'evidenceStateGroups': len(cases), 'mappedCases': sum(len(entry['cases']) for entry in entries), 'recorded': options.record}))
