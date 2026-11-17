# DartToDo delivery and real-project trial

DartToDo is a working local Flutter/Riverpod application with Serverpod 3.4.12 and PostgreSQL 17.11, built for macOS and the installed iPhone/iPad simulators. It uses the existing local PostgreSQL service, the dedicated `flutter_todo` database, and no Microsoft account or Docker. Original source is delivered through the feature branch and versioned source release in [DartToDo on GitHub](https://github.com/jedt3d/DartToDo).

The [real native screenshots](../screenshots/README.md), [user guide](../app-guide.md), [setup](../development.md), [architecture](../architecture.md) and [security boundaries](../security.md) describe the delivered app. The [editable Figma file](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO) contains the coordinated screens, components/tokens and the user-approved bordered Folded Check icon. Its light/dark assets are applied to iOS/macOS native catalogs; macOS Dock appearance follows the system.

## Executed verification

| Check | Observed result and practical scope |
|---|---|
| Static analysis and formatting | Fatal-info Flutter analysis and formatter checks pass. Generated code is regenerated with the project-pinned CLI. |
| Frontend behavior |115 passing tests: 19 data tests, 76 app/background/catalog tests and 20 new responsive regressions. Grouped catalog assertions overlap individual previews; this is not 115 independent features. |
| Backend |48 passing backend unit/integration tests, using real PostgreSQL in `flutter_todo_test`, with rollback isolation, migrations, recurrence, validation, deletion/restore and photo-source tests. |
| Generated consistency |3.4.12 regeneration leaves declared server/client/test-helper outputs unchanged. |
| Real HTTP | Independent generated-client smoke passes; browser Origin, Host and method restrictions pass against the actual loopback service. |
| Native macOS | Debug build and native task/notes/steps/importance/completion persistence with independent readback pass. Final application opened and three-pane layout observed through native computer use. |
| Native iPhone/iPad | The same persistence flow passes on both actual iOS 18.5 simulators. Each real screenshot flow opens/closes lists, details and suggestions, adds a suggestion to My Day, and verifies stored state. |
| Responsive layout |20 focused checks cover 390×844 and 852×393 phone, 834×1194 and 1194×834 tablet layouts, safe insets, 1.5× text, keyboard-reduced viewports, scrolling, panel navigation and failed-save drafts. |
| Native icon |33 catalog entries generated from final selected assets. The selected light 1024 px raster and packaged macOS 1024 px icon compare with zero differing pixels. This proves that icon raster only. |
| Setup replay | Setup replays successfully with the locked dependencies and existing databases. It preserves unrelated databases and does not replace installed SDK/global CLI versions. |
| Widgetbook | Release catalog refresh is in progress; current source-bound results will be recorded below before publication. Runtime coverage and Figma approval remain separate. |
| Signing | Final debug macOS bundle passes `codesign --verify --deep --strict`; signature is ad hoc with no TeamIdentifier. Gatekeeper assessment rejects this unsigned-for-distribution build. No binary is distributed, and no notarization, physical-device or App Store claim is made. |

The finite `tool/verify.py` run passed in 19.644s at the recorded checkpoint. Native core runs passed separately: macOS 19.728s, iPhone 25.275s and iPad 22.704s, including compilation. Final iPhone/iPad capture flows took 29.316s and 24.861s. These are command durations, not total development time or human effort. Local exact logs remain in `.dartnflutter/trial`; they are excluded from public source to avoid incidental private data.

## Responsive behavior and repairs

On compact or short phone screens, Lists, task details and suggestions use a single navigable content pane. On iPad portrait, the sidebar stays available while the content area switches between list/details/suggestions; a visible back button returns to the list. At 1050 logical pixels with sufficient height, the app can show sidebar, task list and a separate 320 px inspector. Every panel paints its own background to the edge and protects controls with `SafeArea`. Short keyboard viewports condense decorative header content while retaining navigation/actions; task-title and detail content scroll together.

The independent responsive review found and repaired meaningful defects: missing safe insets on wide layouts, desktop-sized sidebar touch targets on iPad, short landscape keyboard overflow, details dismissed before a failed note save, blank-title restoration dropping note edits, a rebuilt compact search field losing its visible query, the Completed view respecting the wrong hide preference, and late task creation stealing editor focus. Targeted tests preserve these behaviors. The first native iPad test failure was a harness race matching composer text before the saved row existed; the corrected finder waits for the actual task-row Text. Four additional responsive-test authoring errors were corrected with real scrolling and unobscured navigation, retaining fatal hit-test warnings.

## Security patch and local trust

A release review found that the initial 3.4.5 Serverpod ORM could reinterpret text beginning/ending with binary-decode markers. The official [advisory](https://github.com/serverpod/serverpod/security/advisories/GHSA-868m-gf4j-xr8g) has contradictory patch metadata; the actual 3.4.12 registry source/changelog was inspected to verify the removed bypass. Runtime/client/Flutter/test/CLI pins and all nine Serverpod lock entries were upgraded together without an SDK change. A harmless literal-string PostgreSQL regression demonstrably fails on 3.4.5 and passes on 3.4.12. The 48-test patched suite and live HTTP checks pass. [Security details](../security.md).

The API actually binds 127.0.0.1:8870 and rejects browser-origin requests; PostgreSQL uses localhost:5432/worajedt as requested. There is no per-process authentication or encryption layer: local processes and the existing database role are trusted. Photo requests send no task data. This is useful scoped evidence, not a security certification.

## Reference parity and limits

Delivered local workflows include tasks, lists/groups, smart views, global note/step/title search, sorting, steps, files, notes, due dates, custom recurrence intervals, native reminders, delete/undo, copy/duplicate/print, themes and settings. Microsoft account, cloud collaboration, assignment, Flagged Email and Outlook recovery are excluded by the local-only architecture.

Exact cross-platform Microsoft pixel/behavior parity has not been established. Figma uses a documented Inter fallback while Flutter uses Apple system typography; there is no human-approved full-screen design revision or historical golden baseline. Recurrence follows the declared tested calendar contract. Attachments total 10 MB per task; custom intervals do not implement arbitrary weekday sets. Moving tasks uses the detail dropdown; cross-list drag/drop is not implemented. Notifications are scheduled natively, but OS-permission delivery was not observed and notification-tap deep linking is absent. Physical printing was not performed. There is no durable offline outbox, multi-process conflict resolution, deleted-items browser or physical iPhone/iPad networking deployment. These boundaries are explicit in the app guide rather than hidden behind successful build results.

My Day asks for a random free Unsplash Featured photo once per launch. Homepage, cached metadata and dated-seed fallback sources are distinct; layout changes or network failure can use fallback. No access key is required for the default path. Homepage parsing does not execute scripts or import cookies. See [photo behavior](../unsplash.md).

## Toolchains, documents and the next round

Applied workflow skills include DartNFlutter inspect/plan/UI/verify/upgrade/bench inspection, Flutter macOS, agent orchestration, lightweight ProDOS, Ponytail, Figma authoring/component-library coordination, writing-for-agents and PR preparation. The bench tools were inspected; no paid agent benchmark or unassisted control was run. The separate icon chat provided the final selected design. The backend security lane retained its fix verification artifacts locally. No claim is made that every installed skill was relevant or executed.

All 32 planned DartNFlutter guides now contain supported finished content: 13 command/tool references, 7 user guides, 6 tutorials and 6 evaluation guides. The sibling toolchain's documentation commits are `ce7ab36`, `5ea7190` and `4e76942`; benchmark fixtures, pilot evidence and source were preserved. Separate revision ledgers document [outline changes](documentation-outline-revisions.md), [user guides](user-guide-revision-ledger.md), [tutorials](tutorial-revision-ledger.md) and [evaluation guides](evaluation-guide-revision-ledger.md).

The [reviewed efficiency ledger](tool-efficiency.md) preserves actual failures, correction chains and the initial 133-event checkpoint. Fourteen catalog record calls initially cost 332.731s, largely repeated semantic scans. That cost is measured; a time-saving or cost-reduction claim is not. Model usage/cost, human comprehension scores and a matched baseline are unknown. [Effective Dart review](effective-dart-review.md) distinguishes source guidance, actual lint behavior and human clarity. [Next-round proposals](next-round-improvements.md) prioritize batch evidence recording, direct test-source hashes, separate design approval, native-version checks and coherent generator graphs. Tool/skill source changes are proposals for the next round; the documentation was improved during this trial.

The lifecycle policy was expanded before final checking to include both native targets, current catalog evidence and source-only artifact checks. The generic iOS multi-architecture build is replaced by the actual-device Xcode build after the observed lipo failure; no acceptance failure is waived. Reviews and readiness are recorded against the stable current source in the local lifecycle report.
