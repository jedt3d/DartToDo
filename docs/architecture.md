# Architecture

DartToDo uses three Dart workspace packages. The product name is DartToDo; the existing `flutter_todo_*` package names and local `FlutterToDo` folder remain unchanged.

```text
Flutter UI and Riverpod controller
        │ typed TodoRepository calls
        ▼
Generated Serverpod client ── HTTP 127.0.0.1:8870 ── TodoEndpoint
                                                        │ transactions
                                                        ▼
                                          PostgreSQL localhost:5432
                                              database flutter_todo
```

## Source map

| Location | Responsibility |
|---|---|
| `flutter_todo_flutter/lib/app_entry.dart` | Initializes Flutter and the Riverpod provider scope. |
| `flutter_todo_flutter/lib/ui/todo_app.dart` | App theme, navigation, adaptive pane layout, shortcuts and orchestration. Its `part` files contain private sidebar, task-list, detail and dialog widgets. |
| `flutter_todo_flutter/lib/data/task_queries.dart` | Pure smart-list filtering, global search, stable sorting, counts and suggestion priority. |
| `flutter_todo_flutter/lib/data/todo_controller.dart` | Serialized asynchronous mutations, visible snapshot and recoverable error state. |
| `flutter_todo_flutter/lib/data/todo_repository.dart` | Typed persistence interface and generated-client adapter. |
| `flutter_todo_flutter/lib/services/reminders.dart` | Permission requests, native scheduling, and validated notification-response/cold-launch callbacks to task navigation. |
| `flutter_todo_flutter/lib/services/backgrounds.dart` | Once-per-launch background request and bounded image/metadata cache. |
| `flutter_todo_server/lib/src/background/` | Public Featured-photo retrieval, guarded JSON parsing, attribution and metadata fallback. |
| `flutter_todo_flutter/lib/ui/catalog_previews.dart` | In-library preview access to private UI; production classes remain private. |
| `flutter_todo_client/lib/src/protocol/` | Generated wire models and endpoint client. |
| `flutter_todo_server/lib/src/todo/` | Authored `.spy.yaml` model definitions and endpoint/domain rules. |
| `flutter_todo_server/lib/src/generated/` | Generated models, table/query APIs and endpoint dispatch. |
| `flutter_todo_server/lib/server.dart` | Native-only HTTP boundary and actual loopback socket binding. |
| `flutter_todo_server/migrations/` | Versioned PostgreSQL schema migrations. |

## State and ownership

The repository provider owns and closes the Serverpod client. `TodoController` loads a `TodoSnapshot` and queues writes in order. Field-edit callbacks run against the latest queued task rather than the task object originally shown by the UI. Save methods refetch the aggregate; complete/delete/restore methods return an aggregate directly. Failed operations retain the last visible snapshot and report a recoverable error. A provider disposed during work is not updated afterward.

The queue is process-local and in memory. It does not provide persistent offline writes or cross-process edit conflict resolution. Different app/simulator instances share the same backend, refresh every 20 seconds when idle and on resume, and can still make competing edits. Whole-task updates from different processes use the last accepted value.

Wide layouts use a 244-pixel sidebar. At 720 logical pixels, with a viewport shortest side of at least 600, the UI changes from single-pane navigation to sidebar/content; at 1050 it can display a separate 320-pixel detail/suggestion pane. Full-page details expose a top back button. Each panel protects controls with SafeArea while its background extends to the edge. Below 360 available vertical pixels, list/sidebar/suggestion headers condense and details scroll, preserving navigation while a keyboard is visible. The issue-9 finite run passed 163 frontend tests, including responsive and inspector regressions. Current-source native core replay passed on all three targets, and retained iPad landscape captures are 2420×1668 pixels. These checks do not establish every possible text scale or window size.

In the three-pane iPad landscape layout, the current view automatically selects its first visible unfinished task, or an eligible visible completed task when no unfinished task is available. An empty view retains a useful inspector prompting the user to add a task. Closing details suppresses automatic reopening until view navigation or a new entry into landscape. Search and Suggestions retain their explicit interaction state.

A dedicated move handle carries only task/source-list identity to sidebar list drop targets; the separate reorder handle operates within the current manual order. Touch moving uses a long press and reveals Lists on compact screens. `_moveTask` flushes pending details, validates an active destination, queues the update against the latest task, appends its destination position and opens the same task in the owning destination. Dropping on its current list is ignored. The detail dropdown remains available.

## Data model and invariants

`TodoTask`, `TodoList`, `TodoGroup` and `TodoSettings` map to PostgreSQL tables. Lists reference groups; tasks reference lists through generated foreign-key relationships. Task steps and attachment objects are typed JSON fields. Attachments contain base64 bytes, filenames and MIME metadata; no server file paths are accepted. Frontend streaming and endpoint validation both enforce an aggregate **25 MiB (26,214,400 decoded bytes) per task**, mapping the published “25 MB” label to an explicit local byte contract. All server configurations use a **40 MiB (41,943,040-byte)** request-body bound to accommodate base64/JSON transport; that larger transport limit does not raise the decoded attachment allowance. `TodoSnapshot` is a transport aggregate, not another database table.

The built-in Tasks list and settings row have ID 1 and are initialized transactionally. Tasks/lists/groups have soft-deletion flags. Snapshot reads omit deleted tasks/lists/groups and tasks whose list is deleted. Deleting a list preserves its tasks for restoration; dissolving a group clears its lists' group reference and preserves their contents. There is no group-restore endpoint.

Task writes preserve server-owned identity, creation time, completion status and recurrence linkage. New tasks start unfinished with a fresh server timestamp. Completion has a separate endpoint because it owns completion timestamps and recurring-successor creation. The successor link is server-only and is excluded from the client protocol.

Every endpoint operation runs in a database transaction and takes one fixed PostgreSQL advisory transaction lock. This serializes the small local workload and keeps compound recurrence/list operations atomic. It is not an optimistic concurrency token, distributed synchronization engine or authorization check.

Titles, dates, recurrence names/intervals, positions, IDs, step IDs and attachment data are validated at the endpoint. Serverpod 3.4.12 is the required ORM encoding boundary: allowed text must stay literal even when it resembles an SQL/binary expression. Application title validation alone is not a substitute for the patched encoder. Calendar dates use `YYYY-MM-DD`; instants such as reminders and creation times use `DateTime`. My Day is derived from a stored local calendar-date string, so midnight changes membership without deleting a task. See the [recurrence contract](app-guide.md#repeating-tasks) for the tested boundary behavior.

## Native and design boundaries

The frontend connects to `127.0.0.1:8870`. This supports macOS and simulators on the same Mac; a physical iPhone/iPad's loopback address refers to that device, so physical-device access requires a separately designed deployment.

Native notification scheduling belongs to each app instance and its OS permissions. The backend stores reminder data; it does not send cloud notifications. Warm response callbacks and cold-launch notification details pass a validated task ID to the UI. Versioned payloads include task ID and scheduled UTC instant; legacy positive-ID payloads remain readable. Dismissed, malformed, mismatched and repeated response payloads are ignored. Navigation waits for task data, flushes pending detail edits, clears search/Suggestions and opens the task’s actual owning list/details. A missing/deleted task produces an unavailable message instead of selecting unrelated data. Disposing a UI owner releases its callback without deleting scheduled reminders. Native method-channel handlers open the macOS/iOS print interface for the current text task list. Custom repeat intervals use the existing daily/weekly/monthly/yearly kind plus repeatEvery; the UI accepts 1–365 units.

My Day's public-photo path is independent of the task repository. The frontend asks once per launch; the server retrieves the public Unsplash Featured homepage data without executing scripts and returns validated attribution/hotlink metadata. Cached metadata and a dated seed cover network/layout failures. This adds requested public-photo connections while keeping task data local. See [source and fallback contracts](unsplash.md). The macOS release sandbox permits outbound networking and user-selected file read/write; debug additionally permits JIT and development networking. iOS permits local networking through its App Transport Security configuration.

The installed Microsoft To Do app is the behavior/visual reference. The [editable Figma specification](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO) was authored during this trial. It uses Inter where Figma could not reliably edit SF Pro; Flutter uses the Apple system typeface. See [the font limitation](design/font-limitation.md). Figma tokens, native screenshots, golden regression, Widgetbook execution and accessibility are distinct checks; none implies the others passed.

For source version **1.1.0+2**, the [current issue-9 report](trial/issue-9-report.md) records passing finite checks, current-source native core workflows and OS delivery on all three targets. Actual taps and terminated-app cold launches passed on iPhone/iPad; macOS tap/cold launch remain unverified. The fresh catalog passes 42/42 declarations and 78/78 cases. Native printing uses full laid-out AppKit content height, with print entitlement in both macOS configurations while preserving the sandbox; the 120-task export contains all markers across seven pages. Physical printing verification was skipped at the user's request; paper output and human visual approval are not established. Issue 9 adds no schema migration. Earlier release checkpoints remain historical.

The current release-candidate toolchain is Flutter 3.41.7, Dart 3.11.5, Serverpod 3.4.12 and PostgreSQL 17.11. The earlier 3.4.5 trial graph was upgraded coherently before release to fix GHSA-868m-gf4j-xr8g; no application schema change was needed. Generated outputs and the workspace lockfile preserve the selected compatibility set. Newer package releases were not assumed compatible with this SDK.
