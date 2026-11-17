# Development setup and verification

The observed local setup on 17 November 2026 is macOS arm64, Flutter **3.41.7**, Dart **3.11.5**, Xcode **27.2**, project-pinned Serverpod CLI/runtime/client/test **3.4.12**, and PostgreSQL **17.11** from Postgres.app. The source release contains code, not a prebuilt application. The server's dev_dependencies pin its generator, so a global Serverpod install/upgrade is unnecessary after workspace dependency resolution. Product branding is DartToDo; the workspace package names remain `flutter_todo_*`.

The trial initially used Serverpod 3.4.5. Before release, the coordinated 3.4.12 patch closed the ORM string-encoding vulnerability in [GHSA-868m-gf4j-xr8g](https://github.com/serverpod/serverpod/security/advisories/GHSA-868m-gf4j-xr8g), while retaining the same Flutter/Dart SDK. Historical trial records mentioning 3.4.5 describe the earlier checkpoint.

## Inspect before changing the environment

```sh
flutter --version
dart --version
xcodebuild -version
dart pub global list
flutter devices
xcrun simctl list devices available
/Applications/Postgres.app/Contents/Versions/17/bin/psql --version
```

Use the Flutter-selected Dart SDK. The pinned compatibility set is intentional: observed newer Serverpod 4.1.2 requires Dart 3.12.2, Flutter Riverpod 3.5.0 requires Dart 3.12, and newer Widgetbook/notification releases require a newer Flutter SDK. Do not replace the project's versions with the latest package versions without a coordinated compatibility change.

The workspace lockfile is at the repository root. From `/Users/worajedt/GitHub/FlutterToDo`:

```sh
flutter pub get
```

This resolves all three workspace packages. Retain and review the lockfile; do not create independent, conflicting dependency selections in each package.

## PostgreSQL and local configuration

The backend expects a running existing PostgreSQL service. Check it first:

```sh
/Applications/Postgres.app/Contents/Versions/17/bin/psql \
  --host=localhost --port=5432 --username=worajedt --dbname=postgres \
  --command='select version(), current_user;'
```

This installation uses `worajedt` without a password. Create the app/test databases only if they do not already exist:

```sh
/Applications/Postgres.app/Contents/Versions/17/bin/createdb \
  --host=localhost --port=5432 --username=worajedt flutter_todo
/Applications/Postgres.app/Contents/Versions/17/bin/createdb \
  --host=localhost --port=5432 --username=worajedt flutter_todo_test
```

Do not recreate or drop an existing database. On a fresh source checkout, create the ignored `flutter_todo_server/config/passwords.yaml` if absent:

```yaml
shared:
  database: ''
```

An empty string is deliberate; an absent/null database password is rejected by Serverpod's configuration parser. Development configuration selects `flutter_todo`; test configuration selects `flutter_todo_test`. There is no Docker or Redis requirement.

## Start the service and app

Keep the backend running in its own terminal:

```sh
cd /Users/worajedt/GitHub/FlutterToDo/flutter_todo_server
dart bin/main.dart --apply-migrations
```

This applies the checked-in schema migrations and listens on `127.0.0.1:8870`. It does not launch PostgreSQL. In another terminal:

```sh
cd /Users/worajedt/GitHub/FlutterToDo/flutter_todo_flutter
flutter run -d macos
```

For iPhone/iPad, boot an installed simulator, use `flutter devices` to obtain its actual ID, and replace `SIMULATOR_ID` below:

```sh
flutter run -d SIMULATOR_ID
```

The simulator and macOS app use the same database on the host Mac. This loopback configuration does not connect a physical iPhone/iPad to the Mac. A successful macOS build does not establish simulator success; a simulator launch does not establish physical-device behavior.

## Optional local reference photographs

The original Microsoft To Do photographs are not redistributed in Git or the source ZIP. With the reference app already installed at `/Applications/Microsoft To Do.app`, run this existing importer from the repository root:

```sh
swift tool/import_reference_assets.swift flutter_todo_flutter/assets/themes
```

It extracts the nine explicitly named shipped theme images, not user tasks or account data. Keep the resulting PNGs private and ignored. Without them, the app uses solid theme fallbacks. Original-code licensing does not grant rights to third-party photographs. See [theme provenance](../flutter_todo_flutter/assets/themes/README.md).

My Day's default Unsplash Featured source needs no API key and uses public hotlinked photos. Metadata/cache/dated-seed sources stay distinct; see [Unsplash setup and evidence](unsplash.md). The optional Microsoft reference photographs above are a separate theme source.

The [Figma file](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO) contains the editable trial specification. Its Inter fallback differs from the native Apple font; see [font evidence](design/font-limitation.md). Do not call its existence a design-fidelity pass.

## Change the protocol coherently

Edit authored model definitions in `flutter_todo_server/lib/src/todo/*.spy.yaml` or endpoint signatures in `todo_endpoint.dart`. Then, from the server directory:

```sh
dart run serverpod_cli:serverpod_cli --no-analytics --no-interactive generate
```

For a schema change, create and inspect a migration before applying it:

```sh
dart run serverpod_cli:serverpod_cli --no-analytics --no-interactive create-migration
```

Commit authored inputs, generated server/client/test-helper changes and migrations together. Do not hand-edit generated protocol files. `python3 tool/check_codegen.py` from the server directory regenerates and compares the declared outputs; it fails if they change, leaving the generated candidate available for inspection.

## Run focused checks

From `flutter_todo_server`:

```sh
dart analyze --fatal-infos lib bin test tool
dart test --reporter expanded
python3 tool/check_codegen.py
```

Backend tests use real PostgreSQL in `flutter_todo_test`, apply migrations and roll back each test's data. The **v1.0.0 release backend checkpoint** had 49 passing tests, including a non-destructive literal `decode(...)` string regression that failed on 3.4.5 and passes on 3.4.12. They cover persistence, malformed inputs, foreign references, soft deletion/restore, group dissolution, recurrence, duplicate identity, sort contracts and file limits. HTTP boundary tests run a real local listener. They do not use the app database for test tasks.

With the normal backend running, these finite checks verify live transport without printing task contents:

```sh
dart run tool/http_security_smoke.dart
cd ../flutter_todo_client
dart run tool/live_smoke.dart
```

From `flutter_todo_flutter`:

```sh
flutter analyze
flutter test
flutter build macos
python3 ../tool/build_ios.py
```

Frontend data tests cover smart-list dates/search/sorting, serialized writes, latest-state field edits, failed refresh, deletion/undo and disposal. Widget tests, native builds, simulator flows, screenshot comparisons, accessibility, Widgetbook runtime coverage and signing remain separate checks. Report their actual results individually; do not infer one from another. See the final trial report for current cross-device outcomes.

Trial command logs and measured durations are stored locally under `.dartnflutter/trial/`; `tool/trial_run.py` records them. The [trial protocol](trial/protocol.md) explains the acceptance criteria and why this single project cannot establish causal time savings or model-cost improvements.

## Issue-9 behavior and current verification status

The current source raises the aggregate attachment allowance to **25 MiB (26,214,400 decoded bytes)**, with a **40 MiB (41,943,040-byte)** Serverpod request-body bound in all configurations. This maps the published “25 MB” label to an explicit local byte contract. The transport allowance accommodates base64/JSON overhead; it is not an additional per-file allowance.

The separate real-HTTP attachment test commits through generated-client sessions and removes only its own temporary test rows. Run from the server package after confirming the isolated test configuration/database:

```sh
cd /Users/worajedt/GitHub/FlutterToDo/flutter_todo_server
dart test tool/attachment_http_test.dart
```

The main suite and this HTTP probe serve different purposes. Exact-cap/over-cap and aggregate rejection, HTTP roundtrip and cleanup all need actual results; their existence in source is not a pass. From the frontend package, the existing focused files provide the notification-service and responsive checks:

```sh
cd /Users/worajedt/GitHub/FlutterToDo/flutter_todo_flutter
flutter test --no-pub test/services/reminders_test.dart
flutter test --no-pub test/ui/responsive_test.dart
```

Current source also implements separate cross-list move/manual reorder handles, compact touch Lists reveal, automatic first-visible-task details on wide iPad landscape and cold/warm notification task navigation. Verify each against the real backend and relevant native target. A successful move must retain the task ID and open its destination/details; a closed automatic inspector must stay closed until navigation or a new landscape entry. Notification proof must distinguish permission, pending/delivered state, actual tap and navigation to the stored owning task. Do not use a fixture callback as evidence of OS delivery.

**Final issue-9 command/native results and refreshed catalog evidence are pending.** The v1.0.0 test counts above describe the earlier release candidate and must remain historical. These commands are replay instructions, not a record of new passing results.

## Native screenshot evidence

Xcode 27.2 supplies the interactive simulator GUI at `/Applications/Xcode.app/Contents/Applications/DeviceHub.app`; the older `Simulator.app` path is absent. Select the booted device in Device Hub and use **Controls → Rotate Left/Right** or **Device → Orientation** for a genuine landscape run. The app retains iPad multitasking; a completed Flutter preferred-orientation call alone does not prove a rotated framebuffer. Inspect the resulting native image dimensions and panel state. See [installed/official reference evidence](trial/issue-9-reference-research.md).

The official Flutter integration screenshot driver also captures the running native app window and saves its PNG bytes on the host:

```sh
flutter drive --no-pub --driver test_driver/screenshots.dart \
  --target integration_test/screenshots_test.dart -d SIMULATOR_ID
```

Run from `flutter_todo_flutter`. The capture uses the real backend, a temporary synthetic list, and the real Unsplash background; teardown soft-deletes that list. These are native app-window captures; OS status-bar text is outside the captured app window. The screenshot test waits for photo decoding before capture. App-container files are removed by the normal test runner, so screenshots must be retained by the host driver.

## Native printing prerequisites

Use one short synthetic list, one page and one copy for the authorized physical check. The configured Brother DCP-1610W macOS CUPS queue is distinct from an AirPrint destination: Brother documents that this model lacks AirPrint. Exercise the app’s macOS native sheet and record the actual submitted/completed queue job separately from observed paper output. On iPhone/iPad, inspect the real native print preview and available destinations; do not report an iOS physical-print pass from this Brother queue or from a canceled sheet. PDF/Printer Simulator output verifies that destination and rendering only. No installed Printer Simulator was found in the researched tool locations. [Prerequisites and primary sources](trial/issue-9-reference-research.md) record those hardware/tool limits; the actual print outcome belongs in the final verification record.

## Troubleshooting observed failures

| Symptom | Diagnosis and next action |
|---|---|
| `psql` is not on PATH | Postgres.app is installed; use the verified absolute `Versions/17/bin` tools above. Its `latest` tools currently belong to PostgreSQL 18.6. |
| Serverpod reports a missing database password | Check that the ignored passwords file contains the empty string shown above; missing is different from empty. |
| App says it cannot connect | Confirm PostgreSQL is running, then start Serverpod from its package directory. Check `lsof -nP -iTCP:8870 -sTCP:LISTEN`; the listener must be `127.0.0.1`, not a wildcard. Select Try again in the app. |
| A live smoke gets connection refused immediately after startup | The process has not necessarily opened its listener yet. Check the startup log/listener before rerunning; process launch alone is not readiness. |
| Cached Serverpod command reports `Invalid kernel binary format version` | The installed CLI snapshot was built by another Dart SDK. In this trial Pub rebuilt the same pinned 3.4.5 executable. Use the Flutter-selected Dart SDK and the project-pinned `dart run serverpod_cli:serverpod_cli ...`; retain the version rather than upgrading to silence the error. |
| Dependency solver rejects a latest version | Compare the package's SDK/Flutter constraints with the observed SDK. Keep runtime/client/generator versions coherent; an SDK upgrade is a separate change. |
| Photograph is absent | Source releases intentionally omit third-party PNGs. Use a color theme or the optional local importer. |
| Reminder is stored but not visible | Check DartToDo notification permission and OS notification settings. Inspect any reminder warning; scheduling and actual delivery need separate native evidence. |
| A write fails while content remains visible | The controller retains the last good snapshot. Restore the service connection and retry the edit; there is no durable offline outbox. |

See [security and backup](security.md) before sharing logs, changing listeners or restoring data.
