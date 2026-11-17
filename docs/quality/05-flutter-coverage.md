# Round 5 — Flutter line coverage

**Measured result: 81.40% → 83.46% of reported executable lines in hand-maintained app code.** The selected suite increased from **162 to 170 passing tests**, with 0 failures/skips. [Issue #20](https://github.com/jedt3d/DartToDo/issues/20) tracks eight new attachment-workflow widget tests. They found no production defect requiring a behavior change.

In plain English, most reported app lines already ran during tests, but the frontend file-selection/export path was largely untouched. New tests now check real UI interactions with a fake picker: bytes survive import/export, cancel/error paths retain task data, removal detaches a file, the exact 25 MiB allowance is accepted, and an aggregate excess is rejected.

**This is a measured baseline and improvement, not a coverage-threshold pass.** No minimum percentage has been agreed. Two startup files are absent from LCOV and remain explicitly **unmeasured**. Including generated Widgetbook and preview support, the raw reported-library result is **77.89% → 79.51%**.

## Source, tool and predeclared scope

The first measurement ran before tracked-file edits, from clean `main` at **`aa40d47a4e07d22d7fab2f2ecdb957e74e8a2523`**. All user-facing times below are **18 November 2026, Asia/Bangkok**. The implementation branch is `codex/issue-20-flutter-coverage-round-05`; the issue/PR records delivery status.

| Binding | Recorded value |
| --- | --- |
| Application / cwd | `jedt3d/DartToDo` / `flutter_todo_flutter` |
| SDK | Flutter **3.41.7 stable**, Dart **3.11.5**, macOS arm64 |
| Collector/formatter dependency | Installed `coverage 1.16.0`, invoked by the SDK's Flutter test tool |
| Test libraries | SDK-pinned `flutter_test`; `test 1.30.0` |
| File picker fixture APIs | Installed `file_picker 13.4.0`, platform interface `4.3.0` |
| Package selection | `--coverage-package=^flutter_todo_flutter$` |
| Test selection | Default `test/` discovery; existing `--name '^(?!.*[Pp]rint)'` filter |
| Metric | LCOV line entries with hits > 0 / reported executable line entries |
| Branch/function coverage | Not measured; no branch flag or branch records |
| Threshold / CI gate | None added |

[Manifest](../../flutter_todo_flutter/pubspec.yaml), [options](../../flutter_todo_flutter/analysis_options.yaml), [workspace lockfile](../../pubspec.lock), shared root resolution, installed SDK help and collector source were inspected. The existing `dnf-inspect` helper's package-local resolution limitation does not mean the shared root config is absent. No dependency resolution or upgrade was performed.

Before measurement, `scope.before.json` declared all **14 tracked frontend library files**, with two separate support files: generated [Widgetbook](../../flutter_todo_flutter/lib/widgetbook.dart) and authored [catalog preview harness](../../flutter_todo_flutter/lib/ui/catalog_previews.dart). They remain in the raw LCOV and are shown separately because this round's primary question is application-code execution. Their exclusion from the primary subtotal is not a source suppression or a claim that the authored harness is generated.

That leaves **12 app-source inventory files**. LCOV reports **10**; [main.dart](../../flutter_todo_flutter/lib/main.dart) and [app_entry.dart](../../flutter_todo_flutter/lib/app_entry.dart) are absent in both runs. Their executable-line totals were not invented, added to the denominator as zero, or treated as covered. Consequently **83.46% is coverage of reported app lines, not a whole-application coverage guarantee**.

The analyzer's generated exclusions do not define this coverage scope. No coverage-ignore marker, collector exclusion, test skip, dependency or production source was changed.

## Baseline, fix and final measurements

| Population | Baseline hit / reported lines | Baseline | Final hit / reported lines | Final |
| --- | ---: | ---: | ---: | ---: |
| Hand-maintained app code, reported 10 of 12 files | 1540 / 1892 | **81.40%** | 1579 / 1892 | **83.46%** |
| Separate Widgetbook/preview support, 2 files | 334 / 514 | 64.98% | 334 / 514 | 64.98% |
| All reported frontend library files, 12 of 14 | 1874 / 2406 | **77.89%** | 1913 / 2406 | **79.51%** |

Percentages use summed lines, not an average of file percentages. All reported executable-line sets are unchanged. The gain is **39 app lines, 2.06 percentage points**, entirely in task details; no reported line lost coverage.

| File, relative to frontend | Baseline hit / found | Baseline | Final hit / found | Final |
| --- | ---: | ---: | ---: | ---: |
| `lib/data/task_queries.dart` | 60 / 60 | 100.00% | 60 / 60 | 100.00% |
| `lib/data/todo_controller.dart` | 111 / 122 | 90.98% | 111 / 122 | 90.98% |
| `lib/data/todo_repository.dart` | 3 / 26 | 11.54% | 3 / 26 | 11.54% |
| `lib/services/backgrounds.dart` | 52 / 72 | 72.22% | 52 / 72 | 72.22% |
| `lib/services/reminders.dart` | 82 / 82 | 100.00% | 82 / 82 | 100.00% |
| `lib/ui/dialogs.dart` | 124 / 136 | 91.18% | 124 / 136 | 91.18% |
| `lib/ui/sidebar.dart` | 170 / 187 | 90.91% | 170 / 187 | 90.91% |
| `lib/ui/task_details.dart` | 256 / 333 | **76.88%** | 295 / 333 | **88.59%** |
| `lib/ui/task_list.dart` | 303 / 335 | 90.45% | 303 / 335 | 90.45% |
| `lib/ui/todo_app.dart` | 379 / 539 | 70.32% | 379 / 539 | 70.32% |
| `lib/ui/catalog_previews.dart` — separate authored support | 168 / 271 | 61.99% | 168 / 271 | 61.99% |
| `lib/widgetbook.dart` — separate generated support | 166 / 243 | 68.31% | 166 / 243 | 68.31% |

The actionable gap was [task-detail attachment import/export](../../flutter_todo_flutter/lib/ui/task_details.dart#L204). Existing tests rendered metadata or moved attachment-bearing tasks; they did not select/save a file through the UI or assert its frontend byte contract. Backend limit/persistence evidence from Round 4 checks a different boundary.

Issue #20 was opened before implementation. The new [attachments_test.dart](../../flutter_todo_flutter/test/ui/attachments_test.dart) adds eight behavior tests: import byte fidelity/removal; pending selection/cancellation/retry; exact **26,214,400-byte** acceptance; combined existing/new excess rejection; failed stream/retry; export filename/bytes; canceled export; and export failure/retry. The fake picker is restored after each test; byte streams and output URIs are synthetic. Tests exercise public UI interactions and inspect stored task data, without native dialogs or actual file writes.

## Execution and supporting checks

| Execution | Start, Asia/Bangkok | Visible passes | Failures / skips | Exit | Wall time |
| --- | --- | ---: | --- | ---: | ---: |
| Original coverage baseline | 06:40:36 | 162 | 0 / 0 | 0 | 8.008s |
| Intermediate coverage after adding tests | 06:44:51 | 170 | 0 / 0 | 0 | 7.990s |
| Final coverage after fixture lint cleanup | 06:46:11 | 170 | 0 / 0 | 0 | 8.847s |

The focused eight-test run passed before full remeasurement. Supporting static analysis then found two redundant imports and two callback return-type inference findings in the new fixture; these were corrected with no suppressions. The first failed analysis and intermediate coverage are retained. Since the test source changed, the final coverage was rerun and rebound to it. The two 170-test runs produced identical LCOV hashes; this is not a general flake-resistance or performance claim.

Final supporting commands passed: `flutter analyze --no-pub --fatal-infos --fatal-warnings test/ui/attachments_test.dart` from the frontend, and `dart format --output=none --set-exit-if-changed flutter_todo_flutter/test/ui/attachments_test.dart` from the repository root. The former found no issues; the latter reported 0 changes.

The authoritative coverage argv was:

```text
flutter test --no-pub --coverage --coverage-path=<absolute-evidence>/final-verified/lcov.info --coverage-package=^flutter_todo_flutter$ --reporter expanded --name '^(?!.*[Pp]rint)' --file-reporter json:<absolute-evidence>/final-verified/events.jsonl
```

Only the machine-specific evidence prefix is abbreviated; exact argv/cwd/timing are retained. `--no-pub` uses existing resolution; the anchored package regex keeps sibling/backend/SDK dependencies outside this frontend measurement; the two reporters retain readable and per-test output from the same run. Installed test defaults were retained. The existing filter excludes one known mocked print-adapter test; 0 skipped applies to selected tests. Hidden successful suite-loading events numbered 10 at baseline and 11 finally and are not added to test counts. No error events or stderr output occurred in the coverage runs.

For reproduction from the frontend package, choose a fresh ignored directory:

```sh
mkdir -p ../.dartnflutter/quality/round-05-replay
flutter test --no-pub --coverage \
  --coverage-package='^flutter_todo_flutter$' \
  --coverage-path=../.dartnflutter/quality/round-05-replay/lcov.info \
  --reporter expanded --name '^(?!.*[Pp]rint)' \
  --file-reporter json:../.dartnflutter/quality/round-05-replay/events.jsonl
```

To reproduce the weighted subtotals and absent-file inventory against that output:

```sh
python3 - <<'PY'
from pathlib import Path
import subprocess

rows = {}
for record in Path('../.dartnflutter/quality/round-05-replay/lcov.info').read_text().split('end_of_record'):
    lines = record.strip().splitlines()
    if not lines:
        continue
    source = next(line[3:] for line in lines if line.startswith('SF:'))
    name = Path(source).resolve().relative_to(Path.cwd()).as_posix()
    entries = [line[3:].split(',') for line in lines if line.startswith('DA:')]
    found = len(entries)
    hit = sum(int(entry[1]) > 0 for entry in entries)
    assert int(next(line[3:] for line in lines if line.startswith('LF:'))) == found
    assert int(next(line[3:] for line in lines if line.startswith('LH:'))) == hit
    assert name not in rows
    rows[name] = (hit, found)
support = {'lib/widgetbook.dart', 'lib/ui/catalog_previews.dart'}
for label, names in [('all reported lib', set(rows)), ('reported app', set(rows) - support)]:
    hit = sum(rows[name][0] for name in names)
    found = sum(rows[name][1] for name in names)
    print(f'{label}: {hit}/{found} ({100 * hit / found:.2f}%)')
inventory = {name for name in subprocess.check_output(['git', 'ls-files', '--', 'lib'], text=True).splitlines() if name.endswith('.dart')}
print('Unmeasured library files:', sorted(inventory - rows.keys()))
PY
```

## Interpretation, remaining gaps and workflow

Line hits mean execution, not correctness of every input, assertion quality or every branch. Query/reminder lines reaching 100% does not establish complete behavior or OS delivery. Native UI, real PostgreSQL and live transport are separate evidence dimensions; see the [official Flutter testing guide](https://docs.flutter.dev/testing/overview) and [coverage package documentation](https://pub.dev/packages/coverage).

The production repository adapter remains **3/26**, since most UI/controller tests inject a fake repository. Background service lines remain **52/72**, with live RPC/CDN paths outside the injected transport fixtures. Some application lifecycle/menu and detail actions remain unexecuted. Startup entrypoints remain absent from LCOV. These are explicit measurement gaps, not reproduced bugs or failures of an agreed threshold; this round fixes the concrete attachment-regression gap rather than claiming all uncovered paths are solved.

No percentage threshold, new rule, coverage suppression, CI job, hook or dependency was added. App behavior, all 14 frontend library files, generated output, package configuration, lockfile, sibling toolchain and `/dnf-*` skills are unchanged. Only the new test file and report/affected documentation are delivered. No production Dart edit required widget-catalog regeneration.

Baseline's **90 selected file inputs** stayed stable during measurement. Final's **91** add only the new test file; all 90 common inputs retain their original hashes. Each coverage run's own inputs stayed stable. The starting manifest hashes all 333 tracked files, including all 73 existing Dart files. Final validation binds the new test hash and documentation separately. Missing startup-file line totals are not silently supplied by this manifest.

This round did not run backend coverage/tests, native/database/printing integration, full project verification, code generation, widget recording, goldens, runtime profiling or CI. No application or database service was started. Scoped analysis and formatting are supporting checks, not new formal tool rounds. Round 6 has not started.

## Retained evidence and delivery

Raw evidence remains ignored under:

```text
.dartnflutter/quality/round-05-20261117T234018Z-aa40d47a4e07/
```

`scope.before.json` declares populations before measurement. Baseline/intermediate/final directories retain LCOV, JSON test events, stdout/stderr, command/timing/exit metadata and before/after file-input manifests. Coverage summaries reconcile every `DA`, `LF`, `LH` record, ownership subtotal and missing file. Focused test, failed/final analysis and formatting logs remain separate. Final validation/review/delivery records and `SHA256SUMS` bind the retained evidence.

| SHA-256 binding | Digest |
| --- | --- |
| Baseline LCOV | `baf97ac8dfee2cbb67a64eb7e1382d43af2b14e1bc28cae8c78dea3eb9a70639` |
| Final LCOV | `679b5c145ab6cf246d29478b0eec6f3f19a978f24e47b3ea92531881aa1813db` |
| Baseline file-input manifest | `98b46c8ab2728763ef189d48077bf388da52f8a85d76868cae3f37718839d45a` |
| Final file-input manifest | `6d7b966db4eb3f77582a2581d0a1b3d79971cbeb1807f2b0ea920e0f5f1e0c30` |
| Final JSON test events | `b5853c003f37c46c087d808d862fdd8d77df225b14797822203ece1e85e2b638` |

[Issue #20](https://github.com/jedt3d/DartToDo/issues/20) and its linked PR are authoritative for review, merge and closure. Earlier round reports remain unchanged. The [quality-tools guide](README.md) records configuration, cadence and later proposed tools.
