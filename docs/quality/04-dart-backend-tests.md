# Round 4 — Dart backend tests

**Result: PASS — all 51 tests in the normal backend suite and the separate 1-test HTTP attachment probe passed, with 0 failures and 0 skips.** The earlier independent 27-test unit run also passed; those 27 tests are already included in the 51, so this is **52 distinct existing test registrations**, not 79 different tests.

In plain English, the checked backend logic and real test-database operations worked: task details survived saving/reloading, recurrence and undo behaved as asserted, invalid inputs were rejected, and a full 25 MiB attachment survived a generated-client HTTP roundtrip. No failing backend test surfaced and no application fix was needed.

The initial PostgreSQL readiness probe failed because the existing service was stopped. This was a prerequisite/setup result, not an application test failure. The existing PostgreSQL 17 cluster was started for the checks and returned to its original stopped state afterward. No database was created, dropped, recreated or reset.

## Baseline identity and configuration

All checks ran before tracked-file edits, from clean `main` at **`099a36e8c2c72cf4bc10f88bf7ea69da97f974d3`**. Measurements occurred on **18 November 2026, Asia/Bangkok**. The report branch is `codex/round-04-dart-backend-tests`; GitHub records delivery status.

| Binding | Recorded value |
| --- | --- |
| Application / test cwd | `jedt3d/DartToDo` / `flutter_todo_server` |
| Selected Dart | **3.11.5**, from the installed Flutter SDK, macOS arm64 |
| Serverpod runtime/client/serialization/test helper | **3.4.12** |
| Test runner libraries | `test 1.30.0`, `test_api 0.7.10`, `test_core 0.6.16` |
| PostgreSQL Dart driver | `postgres 3.6.0` |
| Actual database server | **PostgreSQL 17.12 (Postgres.app)**; observed existing installation, not an upgrade performed by this round |
| Test database | Existing **`flutter_todo_test`**, localhost port 5432 |
| Application database | **`flutter_todo`**, preserved; only read-only verification snapshots were taken |
| Test API listener | Loopback, ephemeral port 0; no normal application server was launched |
| Test configuration | [config/test.yaml](../../flutter_todo_server/config/test.yaml), [dart_test.yaml](../../flutter_todo_server/dart_test.yaml) and per-file harnesses |

The [server manifest](../../flutter_todo_server/pubspec.yaml), [workspace manifest](../../pubspec.yaml), [lockfile](../../pubspec.lock), shared root package resolution, installed package manifests and CLI help were inspected. The `dnf-inspect` helper's package-local resolution limitation remains; actual shared workspace resolution supplied the installed versions. No explicit dependency resolution or upgrade command was run; the lockfile and shared resolution hashes stayed unchanged.

The [generated test helper](../../flutter_todo_server/test/integration/test_tools/serverpod_test_tools.dart#L101) delegates to installed `serverpod_test 3.4.12`. Its inspected defaults select test mode, apply pending migrations and roll back endpoint test transactions after each test. The two integration files retain those defaults. The existing `integration` tag declaration does not exclude those tests; this round supplied no tag/name filter.

The separate [HTTP test](../../flutter_todo_server/tool/attachment_http_test.dart#L17) explicitly selects test mode, checks the actual database name and ephemeral API port, and closes its client/session/server. HTTP sessions commit independently of the endpoint-test rollback transaction, so the probe runs after the normal suite and removes only the rows belonging to its newly created test list.

## Checks first: actual results and commands

Each run used readable expanded output plus a JSON file reporter from the same process. Installed default VM platform, concurrency, declaration order and runner timeouts were retained; the HTTP test already declares its own two-minute timeout. No coverage, random-order, retry, timeout or skip override was added.

| Measurement | Start, Asia/Bangkok | Visible passed | Failed / skipped | Exit | Wall time | JSON runner time |
| --- | --- | ---: | --- | ---: | ---: | ---: |
| Independent unit baseline | 06:27:34 | 27 | 0 / 0 | 0 | 1.374s | 0.545s |
| Normal backend baseline | 06:28:17 | 51 | 0 / 0 | 0 | 3.080s | 2.336s |
| Separate HTTP attachment baseline | 06:28:35 | 1 | 0 / 0 | 0 | 2.886s | 2.100s |

The runner durations are contained within wall times; they are not extra durations or performance benchmarks. Hidden successful loading/setup/teardown events numbered **5, 11 and 1**, respectively, and are excluded from visible test counts. All three JSON streams ended in success with no error events or skipped tests. Standard error was empty. Serverpod startup/migration/shutdown messages in the HTTP stdout are retained as process output.

Executed argv, with only the machine-specific evidence-directory prefix abbreviated:

```text
dart test --reporter expanded --file-reporter json:<evidence>/unit-baseline/events.jsonl test/unit
dart test --reporter expanded --file-reporter json:<evidence>/suite-baseline/events.jsonl
dart test --reporter expanded --file-reporter json:<evidence>/http-baseline/events.jsonl tool/attachment_http_test.dart
```

The reporters change output/accounting, not assertions or selection. With no path, `dart test` discovered all five tracked test files under `test/`; the file under `tool/` needs its explicit command. The raw metadata retains the exact argv, cwd, timestamps, exit status and hashes. See [Dart's official test command documentation](https://dart.dev/tools/dart-test); installed CLI help and Serverpod 3.4.12 source take precedence over newer examples.

To reproduce from the server package after verifying the [database prerequisites](../development.md#postgresql-and-local-configuration), choose a fresh ignored output directory and run these sequentially:

```sh
mkdir -p ../.dartnflutter/quality/round-04-replay
dart test --reporter expanded \
  --file-reporter json:../.dartnflutter/quality/round-04-replay/suite.jsonl
dart test tool/attachment_http_test.dart --reporter expanded \
  --file-reporter json:../.dartnflutter/quality/round-04-replay/http.jsonl
```

For focused logic/middleware work, `dart test test/unit --reporter expanded` runs the 27-test subset without requiring PostgreSQL. Its middleware tests do open a temporary real loopback listener; the photo tests inject their transport and use cleaned-up temporary cache files, not a live Unsplash request.

## What the normal suite checks

| File, relative to server | Passed | Meaning in plain English |
| --- | ---: | --- |
| [test/unit/recurrence_test.dart](../../flutter_todo_server/test/unit/recurrence_test.dart) | 5 | Calendar boundaries, leap days, weekdays and custom recurrence intervals |
| [test/unit/local_requests_test.dart](../../flutter_todo_server/test/unit/local_requests_test.dart) | 5 | Native loopback POST is allowed; browser-origin, untrusted-host and GET task/background requests are rejected |
| [test/unit/unsplash_service_test.dart](../../flutter_todo_server/test/unit/unsplash_service_test.dart) | 17 | Photo parsing/selection, cache fallback, URL policy, cancellation/timeouts and injected API behavior |
| [test/integration/todo_endpoint_test.dart](../../flutter_todo_server/test/integration/todo_endpoint_test.dart) | 23 | Real PostgreSQL persistence, identity, validation, recurrence, deletion/restore, relationships, ordering and aggregate attachment limits |
| [test/integration/orm_string_security_test.dart](../../flutter_todo_server/test/integration/orm_string_security_test.dart) | 1 | Apostrophes and harmless SQL-looking text remain literal data through insert/update/filter operations |
| **Normal suite total** | **51** | **27 unit/middleware tests plus 24 database tests** |
| [tool/attachment_http_test.dart](../../flutter_todo_server/tool/attachment_http_test.dart), separately | **1** | A generated client sends, fetches and verifies every byte of a 25 MiB attachment through real loopback HTTP and PostgreSQL |

The endpoint tests cover an exact **26,214,400-byte** decoded attachment total, rejection one byte over that total and multiple files sharing the aggregate allowance. The separate HTTP test verifies the exact-cap payload and asserts the configured **40 MiB** transport bound; it does not send an over-40-MiB request. These are different decoded-data and transport limits.

## Database preservation and setup outcome

Readiness initially returned exit 2, `localhost:5432 - no response`. Inspection found the existing, stopped major-17 cluster at its already configured port 5432. It was started without changing PostgreSQL configuration. Both application/test databases and their applied migrations already existed; the HTTP log confirms the latest migration was already applied. Docker and Redis were not needed.

Read-only snapshots before the database suite, after it and after the HTTP probe retained schema digests, row-count/content digests for `todo_group`, `todo_list`, `todo_settings`, `todo_task` and `serverpod_migrations`, plus application-table sequence values. Row contents and credentials were not published.

- The application database's measured schema, selected table contents and sequences remained identical.
- The test database's measured schema and selected table contents returned to their baseline: 0 groups, 1 inbox list, 1 settings row, 0 tasks and 2 migration records.
- Test-database sequence counters advanced, as expected for database inserts; rollback does not imply restoring every sequence counter. They were not reset.
- After all test sessions/listeners shut down, a connection check found no other client sessions. A smart shutdown returned the PostgreSQL service to its original stopped state.

This is verification of those measured objects and reviewed test targeting, not a claim that every database object or unrelated process was audited. No database drop/recreation/restore, broad cleanup, data migration or application-server launch was performed.

## Findings, changes and workflow

**No actionable failing-test finding was observed.** Restoring an existing required service was prerequisite setup. No application/test/configuration fix or defect issue was needed. The [documented clean-result workflow](README.md#findings-reports-and-delivery) publishes a report through review; it does not invent a defect ticket for passing tests.

All **100 selected file inputs** were identical within and across the three checks. They include all 73 tracked Dart sources, manifests/options, lockfile/shared resolution, server configuration/migrations, the ignored credential-file hash, runner and selected Dart/PostgreSQL executables. Database state is measured separately and is not claimed to be an unchanged file input. The starting manifest covers all 332 tracked files; none changed during the checks.

Only this report and the affected guide/development/README/tracking documentation were then updated. Final validation reconciles source/input hashes, per-file JSON counts, commands, links and the delivered diff. Those documentation edits do not change test inputs, so the measured run remains applicable without repeating the suite.

Dart source, tests, generated files, assets, rules, dependencies, lockfile, verification script, sibling toolchain and `/dnf-*` skills are unchanged. No production Dart edit required a widget-catalog refresh. No analyzer, formatter, frontend/native/printing tests, live application smokes, code generation, coverage, profiling, CI or later formal round ran. A passing backend run establishes the checked assertions, not exhaustive correctness, native acceptance, security certification, flake resistance or a coverage percentage.

## Retained evidence and delivery

Raw evidence is ignored under:

```text
.dartnflutter/quality/round-04-20261117T232711Z-099a36e8c2c7/
```

`identity.json` and `tracked.before.json` bind the clean base and inventory. SDK/help/inspection and the initial failed readiness probe are retained. Each baseline directory contains original stdout/stderr, JSON events, command/timing/exit metadata and before/after file-input manifests. `test-summary.json` reconciles counts; database checkpoint files retain private comparison digests. Service start/stop records preserve the setup and restoration outcome. Final validation, review/delivery records and `SHA256SUMS` remain local.

| SHA-256 binding | Digest |
| --- | --- |
| Common before/after file-input manifest | `9d611e8b3c5e97ce2fa3badb11bba0e23e4ced9c78fccf44898c48d886d420d0` |
| Normal suite stdout | `93c5a0c1bb76c1dafc87c93a56d58458b92e881eabf54e1634dc0f0e1c647b00` |
| Normal suite JSON events | `57f4006da8977c68fe2fa5bd0bb2a0d4acc5ebd890ec8d4b4757f3499585e21b` |
| Separate HTTP JSON events | `aadb96ec97f1eee964cac32b5eb447d5fc2c9931b6f12f222248c119bfd3afee` |
| Empty stderr for all three checks | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

The PR is authoritative for review/merge status; no fix issue required closure. Earlier reports remain unchanged snapshots. The [quality-tools guide](README.md) records cadence and proposed later tools. Round 5 has not started.
