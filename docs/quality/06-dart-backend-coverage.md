# Round 6 — Dart backend line coverage

**Measured result: 89.06% → 93.27% of reported hand-written runtime lines**, with **59 normal-suite tests plus 1 separate HTTP attachment test passing**, 0 failures/skips. [Issue #22](https://github.com/jedt3d/DartToDo/issues/22) tracks eight new HTTP-transport unit regressions. No production defect requiring a behavior change was reproduced.

In plain English, the database-backed tests already exercised most task-service code. The photo HTTP adapter had a concrete test gap around response bounds, redirects, failures and cleanup. New deterministic tests now check those paths without live Unsplash traffic. The adapter improved **15/40 lines (37.50%) → 40/40 (100.00%)**.

Including generated runtime code, the combined suite/HTTP line result is **71.88% → 73.35%**. The launcher `bin/main.dart` is absent from LCOV and remains **unmeasured**. No percentage threshold or gate was added; these percentages describe reported lines, not exhaustive backend correctness.

## Identity, configuration and scope declared before measurement

Measurements started before tracked edits, from clean `main` at **`4e1747ecee9d038fee0bb9dfcc9e17a9fa4b59aa`**. All times below are **18 November 2026, Asia/Bangkok**. The implementation branch is `codex/issue-22-backend-coverage-round-06`; issue/PR state is authoritative for delivery.

| Binding | Recorded value |
| --- | --- |
| Repository / cwd | `jedt3d/DartToDo` / `flutter_todo_server` |
| Selected Dart | **3.11.5**, installed Flutter-selected SDK, macOS arm64 |
| Test / collector libraries | `test 1.30.0`, `test_core 0.6.16`, `coverage 1.16.0` |
| Serverpod runtime/test/client | **3.4.12** |
| Database | Existing PostgreSQL **17.12 (Postgres.app)**, isolated `flutter_todo_test` |
| Package filter | `--coverage-package=^flutter_todo_server$` |
| Test configuration | [dart_test.yaml](../../flutter_todo_server/dart_test.yaml), [test service configuration](../../flutter_todo_server/config/test.yaml), existing per-file harnesses |
| Metric | Weighted LCOV executable line entries with hits > 0 / reported line entries |
| Branch/function metric / threshold | Not measured / none configured |

The [manifest](../../flutter_todo_server/pubspec.yaml), [workspace lockfile](../../pubspec.lock), shared root resolution, installed test help and collector/SDK signatures were inspected. The `dnf-inspect` helper's existing package-local resolution limitation remains distinct from the actual shared root config. No explicit dependency resolution, installation or upgrade was performed.

`scope.before.json` declared six hand-written runtime files under `lib/` and `bin/`, eleven generated runtime files under `lib/src/generated/`, and separate unit, normal-suite and explicit HTTP tracks. The primary subtotal excludes generated files but leaves them visible in raw coverage. No test/tool/helper record appeared in the package-filtered LCOV; tests do not count as app execution.

All baseline/final normal tracks report the same **594 line entries in five hand-written files**, plus **1113 entries in eleven generated files**. `bin/main.dart` is the sixth hand-written inventory file, absent in every normal track. Its executable-line total was not invented or counted as covered. The primary percentage therefore covers reported runtime lines, not every source file.

The anchored package regex selects this server package explicitly within the three-package workspace. The installed collector uses package-name filters and the shared resolution; it is not controlled by analyzer exclusions. No coverage-ignore marker, source exclusion, skip, tag filter or production file was added or changed.

## Baseline and final results by test track

| Track | Tests before → after | Hand-written hit / found before → after | Hand-written before → after | All reported runtime before → after |
| --- | --- | --- | --- | --- |
| Unit/middleware subset | 27 → 35 | 294/594 → 319/594 | **49.49% → 53.70%** | 318/1707 (18.63%) → 343/1707 (20.09%) |
| Normal `test/` suite | 51 → 59 | 529/594 → 554/594 | **89.06% → 93.27%** | 1215/1707 (71.18%) → 1240/1707 (72.64%) |
| Explicit attachment HTTP probe | 1 → 1 | 96/594 → 96/594 | 16.16% → 16.16% | 635/1707 (37.20%) → 635/1707 (37.20%) |
| **Union: normal suite + HTTP probe** | **52 → 60 distinct registrations** | **529/594 → 554/594** | **89.06% → 93.27%** | **1227/1707 (71.88%) → 1252/1707 (73.35%)** |

The full suite already contains the unit subset; focused/unit/full runs are not added as different scenarios. Final normal-suite count is **35 unit/middleware + 24 PostgreSQL tests = 59**, plus the separately selected HTTP test.

The combined row merges hits by canonical source path and line, taking the union of reported line sets. It does not sum denominators or average percentages. The HTTP probe adds twelve generated dispatch/serialization line hits beyond the normal suite, with no additional hand-written line hits. Its wire/byte assertions still check a separate boundary.

| Hand-written source | Baseline normal/combined | Final normal/combined |
| --- | --- | --- |
| [lib/server.dart](../../flutter_todo_server/lib/server.dart) | 11/20 (55.00%) | 11/20 (55.00%) |
| [lib/src/todo/todo_endpoint.dart](../../flutter_todo_server/lib/src/todo/todo_endpoint.dart) | 252/274 (91.97%) | 252/274 (91.97%) |
| [lib/src/background/unsplash_service.dart](../../flutter_todo_server/lib/src/background/unsplash_service.dart) | 251/257 (97.67%) | 251/257 (97.67%) |
| [lib/src/background/unsplash_transport.dart](../../flutter_todo_server/lib/src/background/unsplash_transport.dart) | **15/40 (37.50%)** | **40/40 (100.00%)** |
| [lib/src/background/background_endpoint.dart](../../flutter_todo_server/lib/src/background/background_endpoint.dart) | 0/3 (0.00%) | 0/3 (0.00%) |
| [bin/main.dart](../../flutter_todo_server/bin/main.dart) | Absent / unmeasured | Absent / unmeasured |

All executable-line sets remain identical. The gain is **25 hand-written lines, 4.21 percentage points** in the normal/combined view, entirely in the transport. Generated combined coverage stays **698/1113 (62.71%)**; no existing reported line lost its covered status.

## Finding and smallest complete improvement

The old tests rejected unsafe hosts and disposed use, while `UnsplashService` tests injected a transport. The real adapter's trusted request/body/timeout/active-client paths around [lines 40–85](../../flutter_todo_server/lib/src/background/unsplash_transport.dart#L40) remained unexecuted.

Issue #22 was opened before adding [unsplash_transport_test.dart](../../flutter_todo_server/test/unit/unsplash_transport_test.dart). Its eight tests assert:

- Split UTF-8 decoding and exact byte-cap acceptance, request headers, retry metadata and force-closing the client.
- Returning a homepage redirect status while keeping redirect following disabled.
- Rejecting an over-cap response before reading later chunks.
- Rejecting invalid UTF-8 and preserving connection/response-stream errors while closing clients.
- Timing out a pending request and aborting its client.
- Closing every concurrent active client on disposal and rejecting later work without another client-creation attempt.

The fixtures use zone-scoped `HttpOverrides` with fake clients, requests, response streams and headers. Unexpected client creation is counted before rejection so it cannot masquerade as expected disposed-use rejection. Unsupported fixture API calls fail; no request can fall back to a real HTTP client. These tests check application transport policy, not an actual external TLS/HTTP exchange.

The first fixture attempt failed compilation on a typed-header assertion and had two brace-style findings. Its logs and empty LCOV are retained as a **failed, invalid coverage attempt**, not zero coverage. After correction, eight focused tests and scoped analysis/formatting passed. Review then strengthened the creation counter; final coverage tracks were rerun against that final test hash. No suppression or production edit was used.

## Actual execution and database safeguards

| Coverage run | Start, Asia/Bangkok | Passes | Exit | Wall time |
| --- | --- | ---: | ---: | ---: |
| Unit baseline | 07:08:21 | 27 | 0 | 1.804s |
| Normal baseline | 07:08:45 | 51 | 0 | 3.778s |
| HTTP baseline | 07:09:04 | 1 | 0 | 3.274s |
| Final unit | 07:15:53 | 35 | 0 | 1.727s |
| Final normal | 07:16:19 | 59 | 0 | 3.610s |
| Final HTTP | 07:16:23 | 1 | 0 | 3.137s |

All successful runs ended with 0 failures/skips and empty stderr; JSON events match visible test counts. Loading/setup/teardown events are excluded: baseline unit/normal/HTTP **5/11/1**, final **6/12/1**. Intermediate and focused attempts remain separately retained. Wall times include runner/collection overhead and are not production performance measurements.

The existing PostgreSQL 17 service was initially stopped. It was temporarily started for database checks and smart-stopped after each measurement cycle once no other client sessions remained. No database was created, dropped, recreated, restored or manually reset. The existing test configuration selects `flutter_todo_test`, ephemeral loopback listeners, disabled persistent session logs/Redis/future calls, and pending-migration application; the latest migration was already applied.

Read-only checkpoints before and after all database runs retain schema digests, counts/content digests for the four task-domain tables plus migration rows, and task-table sequence values. The application's measured schema/table contents/sequences are unchanged. Test schema/row contents return to baseline: 0 groups, 1 inbox, 1 settings row, 0 tasks, 2 migration records. Test sequence values change through inserts; no manual sequence reset was used. The separate HTTP test commits independently and deletes only its own synthetic rows. These are selected-object preservation checks, not an audit of every database or unrelated process.

Final supporting checks passed: `dart analyze --fatal-infos --fatal-warnings test/unit/unsplash_transport_test.dart` from the server package, and non-writing `dart format --output=none --set-exit-if-changed flutter_todo_server/test/unit/unsplash_transport_test.dart` from the repository root.

## Reproduction and interpretation

From `flutter_todo_server`, choose a fresh ignored directory. Verify the [database prerequisites](../development.md#postgresql-and-local-configuration) before the last two commands; execute those sequentially because the HTTP probe commits its own fixtures.

```sh
mkdir -p ../.dartnflutter/quality/round-06-replay
dart test test/unit --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/round-06-replay/unit.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/round-06-replay/unit.jsonl
dart test --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/round-06-replay/suite.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/round-06-replay/suite.jsonl
dart test tool/attachment_http_test.dart --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/round-06-replay/http.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/round-06-replay/http.jsonl
```

The retained `result.json` files record exact expanded argv/cwd; only reporter/artifact paths differ from this reproduction. `--coverage-path` requests LCOV and implies the runner's debug/VM-service support. The package regex limits this measurement; reporters control output. VM, default concurrency/order/timeouts and existing HTTP-test timeout remain unchanged. No branch flag, threshold, merge-with-old-baseline option or selection filter was added. The [official test](https://pub.dev/packages/test) and [coverage](https://pub.dev/packages/coverage) documentation describe the tools; installed 1.30.0/1.16.0 behavior is authoritative here.

Reproduce the combined weighted subtotals and unmeasured runtime inventory:

```sh
python3 - <<'PY'
from pathlib import Path
import subprocess

rows = {}
for filename in ['suite.info', 'http.info']:
    text = Path('../.dartnflutter/quality/round-06-replay', filename).read_text()
    for record in text.split('end_of_record'):
        lines = record.strip().splitlines()
        if not lines:
            continue
        source = next(line[3:] for line in lines if line.startswith('SF:'))
        name = Path(source).resolve().relative_to(Path.cwd()).as_posix()
        entries = {int(line[3:].split(',')[0]): int(line[3:].split(',')[1]) for line in lines if line.startswith('DA:')}
        assert int(next(line[3:] for line in lines if line.startswith('LF:'))) == len(entries)
        assert int(next(line[3:] for line in lines if line.startswith('LH:'))) == sum(hit > 0 for hit in entries.values())
        target = rows.setdefault(name, {})
        for number, hit in entries.items():
            target[number] = target.get(number, 0) + hit
inventory = {name for name in subprocess.check_output(['git', 'ls-files', '--', 'lib', 'bin'], text=True).splitlines() if name.endswith('.dart')}
for label, names in [('all reported runtime', set(rows) & inventory), ('reported handwritten', {name for name in rows if name in inventory and not name.startswith('lib/src/generated/')})]:
    found = sum(len(rows[name]) for name in names)
    hit = sum(sum(count > 0 for count in rows[name].values()) for name in names)
    print(f'{label}: {hit}/{found} ({100 * hit / found:.2f}%)')
print('Unmeasured runtime files:', sorted(inventory - rows.keys()))
PY
```

Remaining missed lines include startup orchestration in `server.dart`, the optional photo endpoint wrapper (0/3), six photo-service lines and twenty-two task-endpoint lines. The launcher remains absent. Low unit-only task coverage does not erase the separate PostgreSQL tests; the tracks answer different execution questions. Even 100% adapter line coverage does not prove every branch/input, assertion quality, native/live behavior or security certification. No additional production fault or threshold failure was established.

## Inputs, delivery and retained evidence

All **103 preexisting selected file inputs** retain their hashes; final's **104** add only the new test file. Each run's before/after manifest is stable. The starting manifest covers all 335 tracked files and all 74 existing Dart files. All seventeen backend runtime files, generated output, configuration, dependencies/lockfile, toolchain and `/dnf-*` skills remain unchanged. No production Dart edit required widget-catalog refresh.

The delivered change is one unit-test file and affected report/documentation. No threshold, source suppression, lint rule, CI/hook or installation was added. No frontend/native/printing test, live application/photo smoke, code generation, widget recording, full verify, profiling or later formal round ran. Round 7 has not started.

Raw evidence is ignored under `.dartnflutter/quality/round-06-20261118T000759Z-4e1747ecee9d/`. It retains premeasurement scope, source/tool identities, LCOV/JSON/stdout/stderr, argv/cwd/exit/timing, input manifests, per-file summaries and merged line maps, failed/focused/intermediate attempts, read-only database digests and both service lifecycle records. Validation/review/delivery records and `SHA256SUMS` remain local.

| SHA-256 binding | Digest |
| --- | --- |
| Normal baseline LCOV | `e7414872b8bf85d1579d683e4abcfcc6f9b9aac0670fb946ea36c274d4de203c` |
| Final normal LCOV | `5541ea1cd90528cedf1f6ded3f977b02f87c68185efab361829cc06171103f80` |
| Baseline/final HTTP LCOV | `358871de038bf88c57a2b00cf9c77d4051e014fea837c524a4821e49168da354` |
| Baseline file-input manifest | `95649cf1bbf8d909fbd7654c77cf7c93e99ff4d24157d4d2b2e76b336c5e9183` |
| Final file-input manifest | `06a48311308baa26ae29a32450cdd9f08ec04a427e36c07b47e1d84f960530d6` |

[Issue #22](https://github.com/jedt3d/DartToDo/issues/22) and its linked PR record actual review/merge/closure. The [quality guide](README.md) records cadence and later tools. Earlier reports remain unchanged historical snapshots.
