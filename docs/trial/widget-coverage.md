# UI coverage and Widgetbook evidence

The app's production UI remains private to `lib/ui/todo_app.dart` and its parts. The marked `catalog_previews.dart` part supplies public preview functions within that library; it does not make private widgets public. Preview fixtures contain invented tasks and use an isolated in-memory repository. They do not read or modify the local user's PostgreSQL data.

## What is measured

The actual DartNFlutter semantic helper uses analyzer 9.0.0 with Flutter 3.41.7 / Dart 3.11.5. For source version **1.1.0+2**, the inventory contains **42 declarations**: widget classes, their named widget-returning build members, and the private sidebar list helper. All 42 are mapped, including every private declaration. The catalog contains **78 declaration/state cases**. These counts include owner methods separately; they are not 42 independent UI features. The historical v1.0.0 inventory had 37 declarations and 73 cases.

The runtime tests assert rendered content and applicable state: selected navigation, checked completion, completed titles, empty search, grouped lists, notes/steps/attachment metadata, suggestions, settings, custom recurrence, loading, failure, composer success/pending/error, and image decoding with paired attribution. The current inventory also covers the move handle and empty inspector. The image fixture is synthetic and makes no photo-fidelity claim. App acceptance tests independently exercise persistence through a fake repository: creation, importance, completion, cross-list search, notes and steps, due dates, reminders, monthly intervals, rapid edits followed by navigation, delete confirmation/undo, settings, task drag, list/group ordering and native print adapter arguments. Isolated background-service tests exercise persistent pairing, previous-photo identity, network-failure fallback, URL validation, size bounds, malformed caches and write failure. Fake-repository tests do not establish real database or native-printer execution; those require separate evidence.

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

For recording, exact named state-group tests each render and assert every preview mapped to that state. The same declaration can have several required states. Each report names all covered declarations and preserves the actual machine log, command, exit code and before/after semantic fingerprints. Fourteen state groups avoid running the full analyzer twice for each individual builder. The individual builder tests remain available for diagnosis. Grouping is a reduction in repeated setup, not evidence of improved model productivity.

Reports and raw logs stay local in `flutter_todo_flutter/.dartnflutter/evidence/catalog`. The release runner now places each recording in a UTC/fingerprint subdirectory with its input, catalog snapshot and summary, so subsequent runs retain its case payloads. Earlier fixed-path recording preserved wrapper logs but overwrote case report/raw-machine payloads; no historical artifact-freshness claim is made for those overwritten files. They are intentionally excluded from Git. The tracked catalog references their digests; a fresh checkout must regenerate them. Source, package, SDK or harness changes require new evidence. A historical passing report is not proof that a changed source tree is current.

## Historical first complete checkpoint

Before the v1.0.0 release on 17 November 2026, the actual `widgets validate` command exited zero with **37/37 declaration coverage and 73/73 runtime cases**. All fourteen state-group runs passed without skipped or ambiguous tests and retained the same inventory fingerprint, `ae3f075530868d506df1abbecae78f612c8527d9758f830f70f6daa142a3eed5`. The local [catalog report](../../flutter_todo_flutter/.dartnflutter/catalog-report.json) tracks the latest complete run; later release checkpoints supersede this earlier fingerprint. Figma design was not provided to this validator; its passing runtime verdict does not approve the authored board or measure fidelity.

The focused frontend run passed **76 tests**: 20 app/entrypoint/Widgetbook-navigation checks, nine isolated background tests, 33 individual preview tests and fourteen grouped-state runs. The groups repeat those preview assertions to provide bounded evidence units; these are not 76 independent effectiveness tasks. The [captured run](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log) took 5.477 seconds. Actual model token usage and cost were not exposed by this lane.

The fourteen serial `widgets record` calls took **332.731 seconds** in total, ranging from 21.068 to 26.667 seconds per call. This includes their child tests and semantic scans; nested durations should not be added again when calculating end-to-end time. Scan/init/generate/final-validate overhead is recorded separately in the event ledger. These are observed command costs, with no unassisted baseline or savings estimate.

## Historical v1.0.0 release checkpoint

The v1.0.0 release recording passed 37/37 declarations and 73/73 runtime cases at fingerprint `149d5d4fb5ee1ac7ec9d48dfa1bac65ee813a0a847f544d5198fa2f122a30776`. Its 14 named state-group recordings took 362.244s in aggregate; repeated semantic scans and child tests are included. Reports, raw machine logs, inputs and the catalog snapshot are retained under `.dartnflutter/evidence/catalog/20261117T160838Z-149d5d4fb5ee/`. These paths are relative to the frontend package. The latest summary at `.dartnflutter/catalog-report.json` now describes the newer checkpoint below.

The v1.0.0 frontend suite passed 130 tests: 19 data, 83 app/background/catalog and 28 responsive checks, including all four dialogs at phone sizes and seven final date/image regressions. Native persistence passed separately on macOS/iPhone/iPad, and its screenshot flows rendered the actual app/photo. No full-screen approved Figma snapshot or initial golden baseline was inferred. Its source-bound lifecycle record hashed that release candidate, including its tests and screenshot artifacts; it does not certify later edits.

## Current 1.1.0 checkpoint

The fresh complete recording passes **42/42 declarations and 78/78 runtime cases** across **14 state groups**, at fingerprint `45979cc9af7cc0cd7db518db49196016909b85da218d3b72bb431d1af91d8cca`. Its retained input, catalog snapshot, reports and machine logs are under `flutter_todo_flutter/.dartnflutter/evidence/catalog/20261117T181404Z-45979cc9af7c/`. The validator's runtime verdict is passed; its design dimension remains incomplete because no approved design snapshot was supplied. The earlier interrupted 42/78 refresh failed when a screenshot-driver edit changed the source fingerprint during recording. That failure remains recorded and is superseded by this complete stable run.

The final finite project run passed **163 frontend tests, 51 backend tests and one separate real-HTTP attachment test** in **29.556s**. Current-source native core replay passed **2/2 on each target**: macOS 22.066s, iPhone 33.059s and iPad 27.991s. OS notification delivery passed on all three targets; actual taps and terminated-app cold launch passed on iPhone/iPad. macOS actual tap/cold launch remain unverified. These native observations are separate from catalog assertions.

The final [screenshot manifest](../screenshots/manifest.json) verifies **21 captures**: five macOS, five iPhone, five iPad portrait and six iPad landscape. The 2420×1668 landscape captures include the first-visible-task inspector. iOS images capture the native app window; macOS captures the running Flutter layer at native pixel ratio, excluding window chrome. OS status-bar and keyboard pixels are not included in the iOS app-window captures. The manifest labels human visual approval false. Figma's editable landscape frame uses Inter while the native application uses Apple system typography; font fidelity and full mobile baseline approval remain unverified. No initial approved golden baseline exists.

Native print interfaces and a seven-page PDF containing all 120 synthetic task markers passed before the user skipped physical printing verification. Paper output is unverified. See the [issue-9 report](issue-9-report.md) and [verification record](issue-9-verification.json) for the separate native, printing, source and acceptance evidence.

## Separate evidence dimensions

| Dimension | Scope and limit |
| --- | --- |
| Semantic inventory | Resolved production classes and named Widget-returning members; anonymous builders are exercised through owning widgets rather than independently enumerated. |
| Widgetbook/runtime | Explicit declared states, named assertions and current machine logs. Not exhaustive combinations of every field or locale. |
| Layout | Automated desktop 1100×720, iPad 834×1194 and iPhone 390×844 navigation/detail checks at enlarged text, plus current landscape/inspector regressions. The native gallery separately records 1210×834 logical-pixel iPad landscape output. These checks do not exhaust all sizes or text scales. |
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
- A declaration inventory alone does not audit assertion sources. Reports bind the exact command/test name and raw log digest; source-bound checks must also bind the graded test source. Explicit test-source hashes in each case report remain a possible improvement.
- Widgetbook's leaf-component navigation can select its sole use case directly. Assuming an extra click on its use-case label dismissed the already open modal; the navigation test now follows the observed 3.23 behavior.
- Cached and fetched background metadata need the same URL policy. An independent cache test reproduced acceptance of user-info URLs in the earlier cache reader; the shared validation guard now rejects those and nonstandard ports consistently.

Suggested human activity: find the private task row in Widgetbook, switch between selected/completed states, locate its source, change one visible label, and verify the result using the named test and catalog rebuild. Human time, mistakes, clarification requests and ratings remain unknown until a person performs this activity.
