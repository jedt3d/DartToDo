# Round 3 — Flutter unit/widget tests

**Result: PASS — 162 selected tests passed across all 10 frontend test files; 0 failures and 0 skips within that selection.** No failing test or actionable application defect surfaced. The existing printing-name exclusion was preserved: one known mocked print-adapter test was filtered out, which is different from a runner-reported skip.

In plain English, the checked task logic and screen interactions worked as expected with fake data and platform adapters. This round requires no application fix, dependency upgrade or test-policy change. The delivery is this report and updated documentation, through a reviewed PR. The [repository workflow](README.md#findings-reports-and-delivery) calls for issues for actionable findings and a report for a clean result; no defect ticket was invented.

## Baseline identity and command

The check ran **before any tracked-file edits**, starting from clean `main` at **`3c417c1baff96bb35f3f2b6d578fe4f3cf8ed1e4`**. This report is on `codex/round-03-flutter-unit-widget-tests`; the PR records final delivery status.

| Binding | Measured value |
| --- | --- |
| Application | `jedt3d/DartToDo`, local checkout `FlutterToDo` |
| Test working directory | `flutter_todo_flutter` |
| Test started | **18 November 2026, 06:07:22 Asia/Bangkok** (`2026-11-17T23:07:22.448048+00:00`) |
| Flutter / Dart | **3.41.7 stable / 3.11.5**, macOS arm64 |
| Flutter framework revision | `cc0734ac716fbb8b90f3f9db8020958b1553afa7` |
| Test libraries | SDK-pinned `flutter_test`; `test 1.30.0`, `test_api 0.7.10`, `test_core 0.6.16` |
| Other resolved test dependencies | `matcher 0.12.19`, `fake_async 1.3.3`, `flutter_riverpod 3.3.1`, `widgetbook 3.23.0` |
| Backend | Installed default `tester` / VM headless Flutter engine; no device selected |
| Exit status / wall time | **0 / 8.005s** |
| JSON reporter duration | **7.478s**, nested within wall time |
| Selected outcome | **162 passed, 0 failed, 0 skipped** |

The [frontend manifest](../../flutter_todo_flutter/pubspec.yaml), [workspace manifest](../../pubspec.yaml), [lockfile](../../pubspec.lock), shared `.dart_tool/package_config.json`, installed package manifests and verbose CLI help were inspected. The `dnf-inspect` helper again reported unavailable package-local resolution; actual shared root resolution exists and supplied the installed versions. No pub resolution or upgrade was performed.

The executed argv was:

```text
flutter test --no-pub --reporter expanded --name '^(?!.*[Pp]rint)' --file-reporter json:<absolute-evidence-directory>/baseline-run/events.jsonl
```

Only the machine-specific absolute evidence-directory prefix is abbreviated above; the original argv and cwd are retained in `baseline-run/result.json`. The command uses the [documented selection](README.md#tests-generated-consistency-and-ui-evidence), with an additional reporter:

- `--no-pub` uses existing resolution without automatically running pub get.
- `--reporter expanded` retains readable progress; `--file-reporter json:...` also records per-test events from that same execution.
- `--name '^(?!.*[Pp]rint)'` preserves the existing name filter. It is a selection policy, not a native-printer safety mechanism.
- No test paths were supplied; the observed discovery covered all 10 tracked `test/**/*_test.dart` files. Files under `integration_test/` were outside this run.
- Installed default concurrency, declaration order, assets and test timeouts were retained. No coverage, random-order, retry, golden-update, device or timeout override was supplied.

For a new reproduction, from the frontend package, choose a fresh ignored output directory rather than overwriting the retained baseline:

```sh
mkdir -p ../.dartnflutter/quality/round-03-replay
flutter test --no-pub --reporter expanded \
  --name '^(?!.*[Pp]rint)' \
  --file-reporter json:../.dartnflutter/quality/round-03-replay/events.jsonl
```

## What passed

These are actual visible test completions reconciled from the JSON log and readable summary:

| Test file, relative to frontend | Passed | What it checks |
| --- | ---: | --- |
| [test/data/task_queries_test.dart](../../flutter_todo_flutter/test/data/task_queries_test.dart) | 8 | Date boundaries, search, views and task ordering |
| [test/data/todo_controller_test.dart](../../flutter_todo_flutter/test/data/todo_controller_test.dart) | 13 | State changes, queued saves/moves, failure recovery and client ownership |
| [test/services/reminders_test.dart](../../flutter_todo_flutter/test/services/reminders_test.dart) | 14 | Reminder scheduling/selection, malformed payloads and failure/disposal paths through mocked channels |
| [test/ui/background_service_test.dart](../../flutter_todo_flutter/test/ui/background_service_test.dart) | 12 | Paired image/attribution caching, fallback, URL/size/image validation and write failures |
| [test/ui/app_acceptance_test.dart](../../flutter_todo_flutter/test/ui/app_acceptance_test.dart) | 21 | Task entry/editing, search, dates, notes/steps, undo, settings and ordering with a fake repository |
| [test/ui/catalog_test.dart](../../flutter_todo_flutter/test/ui/catalog_test.dart) | 49 | Individual private-widget previews and grouped state assertions |
| [test/ui/parity_test.dart](../../flutter_todo_flutter/test/ui/parity_test.dart) | 15 | Moving tasks, retaining content and detail/selection behavior |
| [test/ui/responsive_test.dart](../../flutter_todo_flutter/test/ui/responsive_test.dart) | 28 | Phone/tablet layouts, simulated insets/keyboards, dialogs and editing/navigation regressions |
| [test/ui/widgetbook_test.dart](../../flutter_todo_flutter/test/ui/widgetbook_test.dart) | 1 | Opening an editable private preview through Widgetbook navigation |
| [test/widget_test.dart](../../flutter_todo_flutter/test/widget_test.dart) | 1 | App startup and actionable task composer |
| **Total** | **162** | **47 unit/service tests and 115 widget tests** |

The JSON stream also contains **10 hidden successful suite-loading events**. They are excluded from the 162 test count. There were no error events, print events or stderr output. The readable log contains no reported warnings.

Catalog's 49 tests comprise **35 individual previews and 14 grouped state tests**; the groups repeat preview assertions. The 162 count describes test registrations, not 162 independent product scenarios, declaration/state coverage or a code-coverage percentage.

## Exclusion and execution boundaries

The reviewed filter excludes [print action sends the current task list to the native print adapter](../../flutter_todo_flutter/test/ui/app_acceptance_test.dart#L506). That test mocks the `darttodo/native` channel and checks adapter arguments; it is not physical printing. It was not executed in this round. No other test declaration in the current test tree names printing, and all 10 files supplied successful selected tests. New or renamed tests require reviewing this name-based selection.

The [UI harness](../../flutter_todo_flutter/test/ui/support.dart) injects [an in-memory repository](../../flutter_todo_flutter/test/data/fixtures.dart) and disables application platform services. Reminder tests replace notification channels/platform instances; background tests inject fetch/download functions and use cleaned-up temporary cache directories. These checks establish the asserted behavior in their test environment. They do not establish real PostgreSQL persistence, live photo retrieval, OS notification delivery, native device behavior or physical printing.

No `dart_test.yaml` or `flutter_test_config.dart` custom frontend test configuration was found. The existing per-file setup/teardown and installed Flutter defaults remain the configuration. No suppressions, skips, tags, assertions or timeout settings were added or weakened.

## Findings, changes and verification

**No actionable failing-test finding was observed.** No Dart source, tests, generated output, assets, package policy, dependencies, lockfile, verification script, toolchain or `/dnf-*` skill was changed.

All **88 selected recorded inputs** were identical before and after the run: all 73 tracked Dart sources, package manifests/options, lockfile, tracked frontend asset files, shared resolution, the runner and selected SDK/test executables. The starting manifest hashes all 331 tracked files; no tracked file changed during the check. This is an explicit selected-input manifest, not a hash of every transitive dependency or optional local asset.

Documentation alone was then updated: this report, the quality-tools guide, README entry points and GitHub tracking page. Those files are outside the recorded test inputs. Final validation reconciles source/input hashes, JSON results, commands, links and the delivered diff; repeating the suite for documentation-only edits would test the same measured inputs.

No production Dart changed, so no catalog regeneration or declaration/state refresh was required. Catalog assertions ran as part of this suite; a new formal Widgetbook/declaration round did not run. The compound verification suite, analyzer, formatter, backend tests, database/HTTP/native/printing integration, coverage, goldens, profiling and CI were not run. No CI job, hook, threshold or later formal round was introduced.

This is one observed run with the installed defaults. It establishes neither repeated-run flake resistance nor performance improvement, exhaustive behavior, accessibility/design approval or a coverage percentage. [Flutter's official testing guide](https://docs.flutter.dev/testing/overview) explains the separate unit, widget and integration boundaries.

## Retained evidence and delivery

Raw evidence remains ignored under:

```text
.dartnflutter/quality/round-03-20261117T230652Z-3c417c1baff9/
```

`identity.json` records the clean base, environment, executable paths and test inventory. SDK/help/inspection outputs are retained. `baseline-run/` contains original stdout/stderr, JSON events, argv/cwd/exit/timing metadata and before/after input manifests; `test-summary.json` reconciles visible/hidden results and file counts. An initial evidence-preparation attempt used a nonexistent engine-artifact path and stopped before launching tests; its setup-failure record is retained separately and is not a test failure. The actual installed runner was inspected and recorded before the successful run.

| SHA-256 binding | Digest |
| --- | --- |
| Baseline before/after input manifest | `0f9cd170e57d3597505ff9d7cdf16e1d6a152c333362be8376cfe97a9f590d58` |
| Readable stdout | `4db35bbb01a70ec2db2853b1a7a79b1b39bf2c62d89dced3cdef0a8630595e86` |
| JSON test events | `bee6dc3442885c7573588cdbefa298beae93f1b271c00c8bb89a1d2013e82330` |
| Empty stderr | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

The final validation, review and delivery records and `SHA256SUMS` are retained locally. The PR is the authority for review/merge status. Earlier [Analyzer Round 1](01-dart-analyzer.md) and [formatter Round 2](02-dart-formatter.md) remain unchanged historical snapshots. The [guide](README.md) records cadence and proposed later tools; Round 4 has not started.
