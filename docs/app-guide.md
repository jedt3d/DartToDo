# Using DartToDo

DartToDo is a personal task app for this Mac and its iPhone/iPad simulators. The Flutter app uses a Serverpod service and PostgreSQL on the Mac. Keep both services running: this version has no separate offline database or durable offline write queue.

## Find and add tasks

The sidebar contains these views:

| View | Contents |
|---|---|
| My Day | Tasks you selected for today's local calendar date. |
| Important | Starred tasks. |
| Planned | Tasks with a due date. A reminder alone does not add a task here. |
| All | Tasks from all active lists. |
| Completed | Completed tasks from active lists. |
| Tasks | The default list for tasks without a custom destination. |

Choose a view, type in **Add a Task**, then press Return or select the plus button. Adding from My Day also selects the task for today; adding from Important also stars it. Adding from a custom list uses that list. Other smart views create tasks in Tasks.

On a narrow screen, use **Lists** to reach the sidebar. Selecting a task opens its details. Wider windows can show the sidebar, task list and details together. In a wide iPad landscape layout, the first visible task opens in the right inspector automatically. An empty list shows an add-task prompt there. Closing the inspector keeps it closed until you navigate to a view or leave and re-enter landscape; you can still select a task explicitly.

Use the circle to complete or reopen a task and the star to change importance. Completed items can be expanded/collapsed and shown/hidden through list options or Settings. Sidebar counts normally count unfinished tasks; Completed counts completed tasks.

## Plan today's work

Open a task and choose **Add to My Day**, or use its context menu. **Suggestions** in My Day offers unfinished tasks outside today's selection, prioritizing due/overdue work, previous My Day tasks and important tasks.

My Day uses the device's local calendar date. A task selected yesterday stops appearing in today's My Day after refresh; its list, notes and completion state remain stored. This is a daily selection, not a task deletion.

## Edit task details

- Edit the title and **Add Note** text. Notes save after a short pause; finishing editing or closing details also saves title/notes. Watch for a save error before assuming a change reached the database.
- Type a step and press Return or the plus button. Steps have their own completion circles and remove buttons. Press Return to commit a step rename.
- **Add Due Date** offers today, tomorrow, next week and a calendar picker. Use its remove action to clear the date.
- **Remind Me** offers one hour from now, tomorrow at 9:00, next week at 9:00, or a chosen date and time. The app requests native notification permission when a reminder is set. A reminder can be stored even if permission is denied; enable DartToDo notifications in system settings to allow delivery.
- **Move task to** changes the owning list while retaining the current view and the task’s identity. Dragging to a list, described below, opens the destination with the task’s details.
- **Add File** copies a selected file's bytes into PostgreSQL. Select an attachment's name to save a copy through the native file dialog; its remove button detaches it from the task. Files on one task must total **25 MiB (26,214,400 bytes) or less**, measured after base64 decoding across all attachments. The interface uses Microsoft’s [published “25 MB” label](https://apps.apple.com/us/app/microsoft-to-do/id1212616790); DartToDo maps that label to this explicit binary-byte contract. It is not a separate allowance for each file.

Notification scheduling exists in the native app. Delivery depends on OS permissions and scheduling behavior; a stored date, a passing widget test, or a simulator launch alone does not prove a notification was delivered. Tapping a notification is designed to open that task in its owning list and show its details, whether the app is already running or launched by the notification. Opening waits for task data; an unavailable task shows a message. OS delivery and actual warm/cold tap behavior remain separate native verification results.

## Repeating tasks

Choose daily, weekdays, weekly, monthly, yearly, or custom. **Custom accepts an interval from 1 through 365 and a unit of days, weeks, months or years.** It is not a custom weekday-set or ordinal-month-rule editor.

Completing a repeating task keeps that completed occurrence and creates a new unfinished occurrence. The new occurrence clears My Day and step completion. Its next date is calculated from the later of the existing due date and the completion's local calendar date. Monthly/yearly dates clamp to the destination month's last day: 31 January 2024 becomes 29 February, and 29 February 2024 plus one year becomes 28 February 2025. Weekdays skip Saturday and Sunday. A reminder shifts by the same date interval.

Repeated completion requests do not create another occurrence. Reopening the completed occurrence hides its generated unfinished successor; completing it again reuses that successor. An already-completed successor is retained. This is DartToDo's tested local contract; exact Microsoft behavior for every recurrence edge case has not been established.

## Organize lists and groups

Use **New List** or **New group** at the sidebar's bottom. Custom-list options include rename, move into/out of a group and delete. Group options include creating a list in the group, renaming and **Ungroup lists**. Ungrouping preserves the lists and their tasks, removes the group, and has no Undo action. The built-in Tasks list cannot be renamed, grouped or deleted.

Task context menus offer My Day, importance, complete/reopen, duplicate, copy and delete. **Copy task** copies its title. **Copy List** copies task titles with text checkboxes; notes and files are not included. Duplicating a task creates a new unfinished task. Duplicating a custom list copies its tasks as unfinished tasks and clears their My Day selection.

List options provide manual, importance, alphabetical, due-date, creation-date and My Day sorting, plus reverse order. The sort preference is shared across views. Use the **Drag to reorder** handle on unfinished tasks while using manual order without a search. The separate **Drag to another list** handle moves a task between lists: drag it to Tasks or a custom list in the sidebar. On iPhone and other touch layouts, long-press that move handle; Lists appears on a compact screen so you can drop onto a destination. The destination highlights while accepting the task. After a successful move, the same task opens in its owning destination/details. Dropping onto its current list does nothing. **Move task to** in details remains available. List and group options provide Move up/Move down actions; list movement stays within its current group or the ungrouped section.

My Day selects a random free Unsplash Featured photograph when the app opens, with attribution and a cached/dated-seed fallback when fresh retrieval is unavailable. No API key is needed; see [Featured backgrounds](unsplash.md). Use **Change Theme** for colors or locally available reference photographs. Source releases omit proprietary photographs; a solid background is used when a photograph is absent. See [development setup](development.md#optional-local-reference-photographs).

## Search, settings and shortcuts

Search is global across active lists and matches titles, notes and step titles without case sensitivity. Each space-separated search term must match somewhere in that combined text. Clear the field to return to the selected view. Hashtags are searchable text; there is no separate tag/category manager or natural-language date parser.

Select your name in the sidebar to change the local display name, dark appearance, completed-task visibility, delete confirmation and completion-sound preference. No Microsoft profile is changed.

| Keyboard action | Shortcut |
|---|---|
| Focus Add a Task | Command+N |
| Focus search | Command+F |
| Open My Day | Command+D |
| Open Settings | Command+, |
| Close selection/suggestions and clear search | Escape |

## Delete, undo and connection failures

Task and custom-list deletion show **Undo** immediately afterward. Deleting a list hides its tasks; undo restores the list and those tasks. Storage uses soft deletion, but there is no deleted-items browser after the Undo notice disappears. Ungrouping has no equivalent restore operation.

If initial loading fails, start PostgreSQL and the local Serverpod service, then select **Try again**. A later failed write keeps the last visible snapshot and reports an error; the failed edit is not an offline save. Retry once the service is available. Other running instances refresh periodically and when resumed, rather than receiving cloud push updates.

This app intentionally has no Microsoft login, shared-list invitations, assignment to other members, Flagged Email, Outlook recovery or cloud synchronization. **Print List** opens the native print interface for a text list of task titles/check boxes; notes and attachments are not printed. Physical printer delivery is separate from opening that interface. The configured Brother DCP-1610W is a macOS printer queue and does not support AirPrint; iPhone/iPad physical printing needs a compatible destination. Canceling the native sheet is not a completed print job. Home-screen widgets, physical-device networking and exact cross-platform Microsoft parity are not delivered by this local trial.

For source version **1.1.0+2**, the [current issue-9 report](trial/issue-9-report.md) records passing attachment-boundary/HTTP tests and current-source native core workflows on macOS/iPhone/iPad. OS notification delivery passed on all three targets; actual taps and cold launch after terminating the previous app process passed on iPhone/iPad, opening the task's owning list/details. The current catalog covers 42 declarations and 78 cases, and the [gallery](screenshots/README.md) contains 21 final captures. Native print previews/interfaces and the long-list PDF passed; physical printing verification was skipped at the user's request and paper output is unverified. macOS notification tap/cold launch and human visual approval remain unverified. The [v1.0.0 report](trial/final-report.md) remains historical.
