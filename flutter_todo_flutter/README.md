# DartToDo Flutter frontend

Native Flutter/Riverpod UI for macOS and iPhone/iPad simulators. It uses the sibling generated Serverpod client and the local PostgreSQL service.

From the repository root, run `python3 tool/setup.py`, then `python3 tool/run.py macos`, `python3 tool/run.py iphone` or `python3 tool/run.py ipad`.

See the [project README](../README.md), [app guide](../docs/app-guide.md), [development commands](../docs/development.md) and [UI evidence methodology](../docs/trial/widget-coverage.md). `lib/widgetbook.dart` is the private-component preview entrypoint; `integration_test` uses the real native app/backend, while `test` uses isolated fixtures.
