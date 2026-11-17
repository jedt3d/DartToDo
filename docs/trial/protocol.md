# FlutterToDo real-project trial

Declared before implementation, 17 November 2026 (Asia/Bangkok).

## Brief and reference

Recreate the locally installed Microsoft To Do's design, functions and behavior for one local user, excluding Microsoft account/cloud integrations. Flutter frontend; Serverpod backend; existing PostgreSQL at localhost:5432 as worajedt with an empty password. Dedicated databases: flutter_todo and flutter_todo_test. Targets: macOS, iPhone simulator and iPad simulator. Repository: /Users/worajedt/GitHub/FlutterToDo, branch codex/microsoft-todo-local.

Inspect the installed reference without editing or importing the user's real tasks. Keep private screenshots and runtime artifacts out of Git. Source app themes may be reused for this local trial with provenance and without redistribution claims. No Figma reference has been supplied: Figma fidelity is not measured.

## Acceptance and independent checks

- Persistent task/list/group create, read, edit, reorder and delete; undo recoverable deletions; task completion, importance, My Day date, due dates, reminders, recurrence, steps, notes, search, sorting, list themes, completed visibility and local settings.
- Smart lists derive from stored task data. My Day resets by local calendar date. Completing a recurring task retains the completed occurrence and creates the next occurrence; month/year boundaries must be tested.
- Serverpod generated client/server agree; real PostgreSQL integration exercises persistence, invalid input, transactions and cross-list operations. Use disposable test rows; never modify unrelated databases.
- Loopback-only HTTP services and PostgreSQL access, no Microsoft login, no cloud telemetry. Test invalid identifiers and malformed input. This is single OS-user local service access, not multi-user network hosting.
- Flutter analysis and behavior tests, desktop and mobile adaptive layouts, keyboard actions, accessibility semantics, error/retry states; macOS build and codesign verification; iOS simulator build and launches on both device types.
- Semantic inventory covers every production widget/page/private class/named helper. Widgetbook registration and runtime case evidence remain separate from visual comparison, token consistency, golden regression and accessibility.

## Measurements

The event ledger records argv/version or skill path, lifecycle stage, wall-clock seconds, result, exit status, retries, manual correction, usefulness and evidence path. Raw output is local under .dartnflutter/trial. Record correctness, regressions, API/module organization, security findings, development/repair time and limitations in the report. Model usage/cost is unknown unless actual host data becomes available.

No paid benchmark is authorized. No matched unassisted baseline exists for this full project: do not claim causal improvement, time saved, statistical significance, security certification or human ratings. Independently authored acceptance tests assess behavior rather than counting commands. Human comprehension activities will specify find/understand/change/verify tasks; measured human feedback/time stays unknown until provided.

## Documentation and learning

Compare current Effective Dart Style, Documentation, Usage and Design guidance with the toolchain and this project's evidence. Preserve DO/DON'T, PREFER/AVOID and CONSIDER strength. First amend the existing outline-only documents with observed trial lessons, then finish supported guide content. Preserve historical research/status files and all parent pilot fixtures/evidence. Tool/skill improvements are proposals for the next round unless a demonstrated blocking defect requires a focused fix.

## Added user deliverables

Create and coordinate a new editable Figma Design file; publish source to https://github.com/jedt3d/DartToDo with a tagged version and source ZIP only. Include real native-app screenshots and Markdown/HTML documentation. Figma file created: https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO. Do not redistribute the installed reference app’s raw image assets in the source release.
