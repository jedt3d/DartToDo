# GitHub work tracking

Work began locally before issues were published. These are the actual tracking links; implementation and validation evidence is retained with each release.

This page retains trial/release links. For the ongoing tool sequence, configuration and check cadence, use the [quality-tools guide](../quality/README.md); GitHub is the authority for live issue and PR status.

- [Build the local To Do application and PostgreSQL backend](https://github.com/jedt3d/DartToDo/issues/1)
- [Verify macOS, iPhone and iPad simulator behavior](https://github.com/jedt3d/DartToDo/issues/2)
- [Coordinate editable Figma screens and select Dart/check-mark icon](https://github.com/jedt3d/DartToDo/issues/3)
- [Document app use, setup, architecture and real trial findings](https://github.com/jedt3d/DartToDo/issues/4)
- [Cover every widget in Widgetbook with current runtime evidence](https://github.com/jedt3d/DartToDo/issues/5)
- [Publish reviewed source release with version tag and ZIP only](https://github.com/jedt3d/DartToDo/issues/6)

- [Randomize My Day using free Unsplash Featured photos](https://github.com/jedt3d/DartToDo/issues/7)

## 1.1.0

- [Remaining parity and native acceptance — issue #9](https://github.com/jedt3d/DartToDo/issues/9) stays open for actual macOS notification activation and human visual approval. Physical paper testing was skipped by the user.
- [Implementation/review — PR #10](https://github.com/jedt3d/DartToDo/pull/10) · [source version v1.1.0](https://github.com/jedt3d/DartToDo/releases/tag/v1.1.0) · [current report](issue-9-report.md).

## Quality tools

- Dart Analyzer policy/findings: [issue #11](https://github.com/jedt3d/DartToDo/issues/11) · [PR #12](https://github.com/jedt3d/DartToDo/pull/12) · [Round 1 report](../quality/01-dart-analyzer.md).
- Proposed analyzer CI: [issue #13](https://github.com/jedt3d/DartToDo/issues/13).
- Tool configuration/workflow documentation: [issue #14](https://github.com/jedt3d/DartToDo/issues/14) · [guide](../quality/README.md).
- Dart formatter scope/results: [issue #16](https://github.com/jedt3d/DartToDo/issues/16) · [Round 2 report](../quality/02-dart-formatter.md).
- Flutter unit/widget tests: [Round 3 report](../quality/03-flutter-unit-widget-tests.md); 162 selected tests passed, with the printing-name exclusion retained. No actionable failing-test finding required a fix issue.
- Dart backend tests: [Round 4 report](../quality/04-dart-backend-tests.md); 51 normal-suite tests plus the separate HTTP attachment test passed. Existing PostgreSQL service setup was restored afterward; no application fix or defect issue was needed.
- Flutter coverage/attachment regression tests: [issue #20](https://github.com/jedt3d/DartToDo/issues/20) · [Round 5 report](../quality/05-flutter-coverage.md). Reported app-line coverage is 83.46%, with 170 selected tests passing; the report preserves raw totals and unmeasured files.
