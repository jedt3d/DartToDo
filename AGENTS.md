# DartToDo

This repository is the local To Do application. DartNFlutter is a separate sibling toolchain; its benchmark fixtures and historical reports are outside application work.

- Read [architecture](docs/architecture.md) when changing UI/state/RPC/database boundaries. Read [security](docs/security.md) before changing listeners, validation, attachments or local storage, and [Unsplash behavior](docs/unsplash.md) before changing photo retrieval.
- Use the Flutter-selected Dart SDK and committed workspace lockfile. The current compatible Serverpod CLI is a project dependency. Run `dart run serverpod_cli:serverpod_cli --no-analytics --no-interactive generate` from `flutter_todo_server`; edit `.spy.yaml`/endpoint inputs and regenerate server, client and test helpers together.
- Preserve the loopback-only native API and browser-origin restrictions. Keep task content in local PostgreSQL; the homepage/photo requests send no task, note or account data.
- Backend integration tests use `flutter_todo_test`. Preserve the application database and all unrelated databases. Missing PostgreSQL, simulators or platform checks remain explicit failures/not-run results.
- Keep private widgets private. Their previews live in the marked in-library catalog harness. After production Dart changes, rescan and refresh the declaration/state evidence; [coverage methodology](docs/trial/widget-coverage.md) explains the separate runtime/design/accessibility dimensions.
- The selected icon is the bordered Folded Check in [the final asset manifest](docs/design/icon-variants/folded-check-themes/manifest.json). Regenerate native sizes with `swift tool/apply_icons.swift "$PWD"`; preserve the user's final geometry and borders.
- `python3 tool/verify.py` runs the project checks; `--native` additionally exercises the configured native targets. Inspect [development](docs/development.md) for actual prerequisites and the simulator-specific Xcode build limitation.
- Keep credentials, raw private captures, database files and `.dartnflutter` evidence out of Git. Microsoft theme PNGs are imported locally and excluded from source releases. Publish only original source/design assets and screenshots containing synthetic task data.
- For quality-tool configuration, cadence and round selection, read the [quality-tools guide](docs/quality/README.md). Open a GitHub issue for each coherent set of actionable findings before fixing it. Link the report and PR, record actual verification, merge after review and required checks pass, then update and close the issue. The user authorizes this workflow for subsequent tool rounds; preserve the agreed scope for each tool.

Versioned source and tests establish behavior. Figma coordination, source inspection and a successful build each have narrower meanings than an application acceptance pass.
