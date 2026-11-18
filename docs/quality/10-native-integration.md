# Round 10 — native integration checks

Measured **18 November 2026**. **Result: both core native tests passed on macOS, iPhone and iPad simulators — six successful test executions, no failures/skips.** [Issue #26](https://github.com/jedt3d/DartToDo/issues/26) records the test-isolation finding and endpoint fix. [Issue #28](https://github.com/jedt3d/DartToDo/issues/28) remains open for nonblocking macOS diagnostics. Rounds 11–13 are deferred.

## Check first: isolation prerequisite

The read-only preflight, at `fe178d8572b48889661aa0e6c4fd9b69d84e9c11`, found an existing Dart backend listening on **127.0.0.1:8870** and PostgreSQL stopped. The [core integration test](../../flutter_todo_flutter/integration_test/app_test.dart) had a fixed readback URL; the app's default repository independently used that URL. Running it directly could not select an isolated test backend while preserving that listener.

No test was run against the existing service/database. This was a **blocked isolation prerequisite**, not a failing application behavior. The source/configuration was inspected, issue #26 was opened before implementation, and the existing listener was left untouched. The implementation starts from `7baa1be` after Round 9's documentation/catalog merge; the preflight's runtime/test source was unchanged until this patch.

## Smallest complete fix

Only `integration_test/app_test.dart` changes among Dart source files. It reads the optional compile-time `DARTTODO_TEST_SERVER_URL` and uses it for both the independent readback client and a separately owned `ServerpodTodoRepository` injected through `repositoryProvider`. The UI repository closes with its provider; the readback client closes in teardown. Both tests mount that configured scope.

The existing default **http://127.0.0.1:8870/** remains for compatibility. Production repository defaults, API, database configuration, dependencies, SDK, toolchain and `/dnf-*` skills are unchanged. The option alone does not prove database isolation: the operator must start/verify a backend with the intended test configuration. The broader `tool/run.py` / `tool/verify.py --native` development workflows retain their existing defaults; this round uses explicit isolated commands rather than that compound runner.

## Actual final checks

| Native target | Start, Asia/Bangkok | Passed / failed / skipped | Exit | Wall time including build |
| --- | --- | ---: | ---: | ---: |
| macOS 27.2.1 arm64 | 08:25:34 | 2 / 0 / 0 | 0 | 19.477s |
| iPhone 16 Pro / iOS 18.5 simulator | 08:26:25 | 2 / 0 / 0 | 0 | 34.488s |
| iPad Pro 11-inch (M4) / iOS 18.5 simulator | 08:27:29 | 2 / 0 / 0 | 0 | 31.228s |

Each target ran the same **two scenarios**, not six different business scenarios:

1. Create/edit a task through the native UI, persist notes/step/importance/completion, and assert backend values through the independent generated client.
2. Drag a task to another list and assert identity, notes, step, importance and destination/details are preserved.

All three JSON event streams finished successfully. Loading, setUpAll and tearDownAll passed and are excluded from the two-test count (three hidden events per target). The app uses `platformServices: false`; native notification/photo service behavior is outside this selection. No real phone was targeted.

Each native command built its selected debug target. The macOS debug app also passed `codesign --verify --deep --strict --verbose=2` (exit 0); its signature is **ad hoc**, with no team identity. Gatekeeper release assessment, Developer ID distribution, notarization and stapling were not run. The two simulator builds completed against their concrete installed destinations; no generic simulator rebuild, SDK install or signed release was needed.

Workspace `flutter analyze --no-pub --fatal-infos --fatal-warnings` passed with **no issues**, exit 0 in **3.913s**. The non-writing formatter check of the changed integration file passed with **0 changes**, exit 0. All **340 tracked file-input hashes** stayed stable within each final check. No production Dart edit required another catalog recording; the changed integration-test path is outside the semantic scan scope, and Round 9's production fingerprint remains current.

## Retained diagnostics

macOS stderr contains **seven linker search-path warnings** about a missing mounted Metal-toolchain Swift path, and **one** `Failed to foreground app; open returned 1` message. The build, two native tests and debug signature verification still passed. iPhone/iPad stderr was empty. These are reported as nonblocking diagnostics, not hidden or converted into a visual/foreground acceptance claim.

The missing path was not found in the inspected Runner project or Flutter/Pods-Runner xcconfig files; its upstream origin remains unknown. [Issue #28](https://github.com/jedt3d/DartToDo/issues/28) tracks investigation of build settings/toolchain provisioning and the launcher result separately. No shared cause is assumed and no warning suppression, component removal, cache wipe or toolchain change was used.

## Database and service safeguards

The existing PostgreSQL **17.12** cluster was started temporarily. A separate backend ran `dart bin/main.dart --mode test`, with process-only API/public port **8871** and explicit database **flutter_todo_test** overrides. The installed Serverpod **3.4.12** configuration/argument sources were inspected before using those keys. Test configuration disables persistent session logging, Redis and future-call execution; the app's loopback socket override remains active. HTTP readiness and the actual loopback listener were checked. **No migration was applied.**

Before testing, read-only schema and selected table digests/IDs were retained for both existing databases. Each target created two owned synthetic lists and two tasks. After each run, cleanup selected only newly captured IDs with the exact native fixture title pattern, verified no original task referenced them, and removed their tasks/lists in a transaction. **Six owned lists and six tasks were removed in total.** No broad title-only deletion, drop/recreation, reset or data export was used.

After every target, both databases' schema and checked domain/migration table hashes matched the baseline. Application-domain sequences also matched. Test list/task sequences advanced **56 → 62** and **407 → 413**; they were deliberately not rewound. This preserves data and schema while acknowledging normal sequence allocation; it is not a claim that every internal database table/counter stayed byte-identical.

The owned backend was stopped after checking its process start identity and its port was released. Both simulators were initially shut down, booted for these tests and returned to shutdown. After confirming no unrelated PostgreSQL clients remained, the owned PostgreSQL start was smart-stopped, restoring the initial stopped state. The original 8870 listener matched its before snapshot and remained running.

## Reproduction and cadence

Confirm the intended existing PostgreSQL service/test schema and available simulator IDs first; [development prerequisites](../development.md#postgresql-and-local-configuration) apply. Do not recreate a database, replace a listener or use an unverified backend. Choose a free loopback port. From `flutter_todo_server`, start a separate terminal process:

```sh
SERVERPOD_API_SERVER_PORT=8871 \
SERVERPOD_API_SERVER_PUBLIC_PORT=8871 \
SERVERPOD_DATABASE_NAME=flutter_todo_test \
  dart bin/main.dart --mode test
```

This selects the existing test configuration and schema; it does not apply migrations. Verify readiness/listener and test-database identity before continuing. Boot only required available simulators if they are stopped. From `flutter_todo_flutter`, run sequentially:

```sh
flutter test --no-pub integration_test/app_test.dart -d macos \
  --dart-define=DARTTODO_TEST_SERVER_URL=http://127.0.0.1:8871/
flutter test --no-pub integration_test/app_test.dart \
  -d 02ED3EB4-23A2-41AB-8D17-49E352A076D3 \
  --dart-define=DARTTODO_TEST_SERVER_URL=http://127.0.0.1:8871/
flutter test --no-pub integration_test/app_test.dart \
  -d 62507A81-E969-448F-8510-136600AB8DC6 \
  --dart-define=DARTTODO_TEST_SERVER_URL=http://127.0.0.1:8871/
```

Recorded runs add the verified expanded/file-JSON reporters at unique ignored paths; only reporting differs from these invocations. Capture original IDs/data digests before replay. Test teardown soft-deletes its lists; retain owned fixture IDs for any further cleanup and never remove unrelated rows or reset sequences. Stop only processes/services/devices started for the run and preserve the caller's initial state.

Use these checks for platform-sensitive behavior and explicit native acceptance claims, with the exact source/device/configuration recorded. Builds, native interaction tests, notifications, screenshots/visual approval and performance answer different questions. macOS notification activation and human visual approval remain open in [issue #9](https://github.com/jedt3d/DartToDo/issues/9). Printing, new goldens, profiling, CI and Rounds 11–13 did not run.

## Evidence and delivery

Ignored `.dartnflutter/quality/round-10-20261118T011934Z-fe178d8572b4/` retains preflight and implementation identities, issue text, exact argv/cwd/UTC/exits/durations, file manifests, expanded/JSON/stdout/stderr, signature checks, simulator/backend/PostgreSQL lifecycle records, owned cleanup IDs and read-only database digests without row contents. Final integration-test SHA-256: `29629ff2df11cb4a5ce25a1610707ecc59662fe4d887f0456b42e874d46c503e`.

| Event log | SHA-256 |
| --- | --- |
| macOS | `60f23d41980d05534187b7550ed0b411801c10110309e97cbb0e9395c2879d6a` |
| iPhone | `6ef3361cce6c7745eafbbf33667f7ac7251ce67b043e888a84b13885d08bc171` |
| iPad | `8956c32b10532ad860ef8411f67e9ab7cd4cc01b2f65c9b63cf1502df1aa2e8e` |

The linked issue/PR records author review, final-head checks and actual delivery. Root self-review is not an independent GitHub approval. Issue #26 closes only after its verified fix merges; #28 and earlier acceptance/CI issues remain separate. See the [rounds 1–10 summary](rounds-01-10-summary.md) for resulting improvements and remaining scope.
