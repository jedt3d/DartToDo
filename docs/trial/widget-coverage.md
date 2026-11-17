# UI coverage and Widgetbook evidence

The app's production UI remains private to `lib/ui/todo_app.dart` and its parts. The marked `catalog_previews.dart` part supplies public preview functions within that library; it does not make private widgets public. Preview fixtures contain invented tasks and use an isolated in-memory repository. They do not read or modify the local user's PostgreSQL data.

## What is measured

The actual DartNFlutter semantic helper uses analyzer 9.0.0 with Flutter 3.41.7 / Dart 3.11.5. The inventory contains 37 declarations: widget classes, their named widget-returning build members, and the private sidebar list helper. All 37 are mapped, including every private declaration. The catalog contains 73 declaration/state cases supplied by 33 preview builders. These counts include owner methods separately; they are not 37 independent UI features.

The runtime tests assert rendered content and applicable state: selected navigation, checked completion, completed titles, empty search, grouped lists, notes/steps/attachment metadata, suggestions, settings, custom recurrence, loading, failure, composer success/pending/error, and image decoding with paired attribution. The image fixture is synthetic and makes no photo-fidelity claim. App acceptance tests independently exercise persistence through a fake repository: creation, importance, completion, cross-list search, notes and steps, due dates, reminders, monthly intervals, rapid edits followed by navigation, delete confirmation/undo, settings, task drag, list/group ordering and native print adapter arguments. Nine isolated background-service tests exercise persistent pairing, previous-photo identity, network-failure fallback, URL validation, size bounds, malformed caches and write failure. Fake-repository tests do not establish real database or native-printer execution; those require separate evidence.

The generated Widgetbook 3.23 entrypoint is `lib/widgetbook.dart`. A real Flutter test starts Widgetbook and selects the private name dialog through its navigation, then verifies an editable preview. This is an automated navigation check, not a measured human comprehension result.

The authored [Figma review board](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-28) supplies real coordination links: Completion `5:72`, Sidebar Item `5:85`, Task Row `5:116`, Detail Action `5:127`, Composer `5:133`, desktop `7:35` and phone details `7:558`. The catalog records these where applicable, including owner members. Dialogs, failure/empty views, suggestions and the standalone header button have no separately reviewed counterpart in that board and remain unmapped. The board has no human-approved revision; the script does not import it as an approved design snapshot. Its authoring and links do not establish image or typography fidelity.

## Reproducing the catalog

From `flutter_todo_flutter`, run:

```sh
flutter test --no-pub test/ui/catalog_test.dart
python3 tool/catalog/rebuild.py --record
flutter run -d macos -t lib/widgetbook.dart
```

The rebuild script invokes the installed dnf-ui launcher with explicit project roots. It runs `widgets scan`, `init`, `generate`, `record` and `validate`. Unknown production declarations stop the script and require a reviewed preview/test mapping. A lexical fallback never counts as complete.

For recording, exact named state-group tests each render and assert every preview mapped to that state. The same declaration can have several required states. Each report names all covered declarations and preserves the actual machine log, command, exit code and before/after semantic fingerprints. Fourteen state groups avoid running the full analyzer twice for each of the 33 individual builders. The individual builder tests remain available for diagnosis. Grouping is a reduction in repeated setup, not evidence of improved model productivity.

Reports and raw logs stay local in `flutter_todo_flutter/.dartnflutter/evidence/catalog`. The release runner now places each recording in a UTC/fingerprint subdirectory with its input, catalog snapshot and summary, so subsequent runs retain its case payloads. Earlier fixed-path recording preserved wrapper logs but overwrote case report/raw-machine payloads; no historical artifact-freshness claim is made for those overwritten files. They are intentionally excluded from Git. The tracked catalog references their digests; a fresh checkout must regenerate them. Source, package, SDK or harness changes require new evidence. A historical passing report is not proof that a changed source tree is current.

## First complete checkpoint

On 17 November 2026, the actual `widgets validate` command exited zero with **37/37 declaration coverage and 73/73 runtime cases**. All fourteen state-group runs passed without skipped or ambiguous tests and retained the same inventory fingerprint, `ae3f075530868d506df1abbecae78f612c8527d9758f830f70f6daa142a3eed5`. The local [catalog report](../../flutter_todo_flutter/.dartnflutter/catalog-report.json) tracks the latest complete run; the release checkpoint below supersedes this earlier fingerprint. Figma design was not provided to this validator; its passing runtime verdict does not approve the authored board or measure fidelity.

The focused frontend run passed **76 tests**: 20 app/entrypoint/Widgetbook-navigation checks, nine isolated background tests, 33 individual preview tests and fourteen grouped-state runs. The groups repeat those preview assertions to provide bounded evidence units; these are not 76 independent effectiveness tasks. The [captured run](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log) took 5.477 seconds. Actual model token usage and cost were not exposed by this lane.

The fourteen serial `widgets record` calls took **332.731 seconds** in total, ranging from 21.068 to 26.667 seconds per call. This includes their child tests and semantic scans; nested durations should not be added again when calculating end-to-end time. Scan/init/generate/final-validate overhead is recorded separately in the event ledger. These are observed command costs, with no unassisted baseline or savings estimate.

## Release checkpoint

The complete release recording passes 37/37 declarations and 73/73 runtime cases at fingerprint `149d5d4fb5ee1ac7ec9d48dfa1bac65ee813a0a847f544d5198fa2f122a30776`. Its 14 named state-group recordings took 362.244s in aggregate; repeated semantic scans and child tests are included. Reports, raw machine logs, inputs and the catalog snapshot are retained under `.dartnflutter/evidence/catalog/20261117T160838Z-149d5d4fb5ee/`. The latest summary is also copied to `.dartnflutter/catalog-report.json`.

The full frontend suite now passes 130 tests: 19 data, 83 app/background/catalog and 28 responsive checks, including all four dialogs at phone sizes and seven final date/image regressions. Native persistence passes separately on macOS/iPhone/iPad, and both reviewed screenshot flows render the actual app/photo. No full-screen approved Figma snapshot or initial golden baseline is inferred. The source-bound lifecycle check hashes the complete current project, including these tests and screenshot artifacts.

## Separate evidence dimensions

| Dimension | Scope and limit |
| --- | --- |
| Semantic inventory | Resolved production classes and named Widget-returning members; anonymous builders are exercised through owning widgets rather than independently enumerated. |
| Widgetbook/runtime | Explicit declared states, named assertions and current machine logs. Not exhaustive combinations of every field or locale. |
| Layout | Automated desktop 1100×720, iPad 834×1194 and iPhone 390×844 navigation/detail checks at 1.5× text. Native simulator launches remain separate. |
| Accessibility | Automated selected/checked semantics, labeled tap targets, and the iOS minimum target guideline. This does not establish complete VoiceOver, keyboard or contrast conformance. |
| Tokens | Requires a separately declared and checked token source. Catalog coverage does not prove token consistency. |
| Figma fidelity | Requires a real approved reference, explicit node mappings and controlled image comparison. No node identifiers are invented. |
| Golden regression | No approved historical golden baseline exists for this new application. Initial screenshots are review artifacts and do not establish regression fidelity. |

## Observations for the next tool round

- Runtime assertions found an unlabeled task row, a 42-pixel composer input, a narrow list-options target, a short task-title input and a short move-list dropdown. The corresponding semantics and target-size tests cover the task list, sidebar and detail view.
- A route-owned name controller was necessary to avoid disposing an editable field before its dialog transition finished. Rapid note edits also need an explicit flush before switching tasks or lists.
- `CheckedPopupMenuItem` deliberately ignores pointer events in its child content. Tests should tap the menu item, not silence hit-test warnings on its text.
- The initial row long-press drag path did not persist ordering. An explicit drag handle now gives reordering its own gesture path; the test verifies stored positions after a standard Flutter drag. Long-press context menus remain available on the row.
- The semantic scan takes roughly 12 seconds on this host in the observed commands. The current `widgets record` repeats the full scan before and after every case. A future batch command could share a stable scan around multiple independent exact named tests while retaining all case-specific logs and digests. This is a proposal; the current trial uses the existing CLI.
- Widget inventory fingerprints exclude test sources. The current reports bind the exact command/test name and raw log digest; final lifecycle checks must also bind the graded test source. A future UI-evidence schema should record test-source hashes directly.
- Widgetbook's leaf-component navigation can select its sole use case directly. Assuming an extra click on its use-case label dismissed the already open modal; the navigation test now follows the observed 3.23 behavior.
- Cached and fetched background metadata need the same URL policy. An independent cache test reproduced acceptance of user-info URLs in the earlier cache reader; the shared validation guard now rejects those and nonstandard ports consistently.

Suggested human activity: find the private task row in Widgetbook, switch between selected/completed states, locate its source, change one visible label, and verify the result using the named test and catalog rebuild. Human time, mistakes, clarification requests and ratings remain unknown until a person performs this activity.
