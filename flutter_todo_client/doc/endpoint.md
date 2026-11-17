# Local endpoint contract

The generated `Client.todo` endpoint exposes typed `TodoTask`, `TodoList`, `TodoGroup`, `TodoSettings` and `TodoSnapshot` objects. `fetch()` returns the current active lists/groups and tasks in active lists. The inbox and singleton settings IDs are both 1.

`saveTask`, `saveList`, `saveGroup` and `saveSettings` return the saved object; refetch for the full aggregate. `completeTask`, `deleteTask`, `restoreTask`, `deleteList`, `restoreList` and `deleteGroup` return a complete snapshot. Use `completeTask` rather than mutating the completed flag when saving a task, because completion owns recurrence and timestamps. Completion takes the client's local calendar date in `YYYY-MM-DD` form.

Task and list deletion support restore. Group deletion dissolves the group while preserving its lists and tasks. Validation errors are serialized as `TodoException`. No account login or cloud endpoint is registered.

Steps require an ID and title. Attachments require an ID, filename, MIME type and base64 file contents. Do not send a server file path. Files on a task total at most 10 MB. `TodoSettings` requires `smartThemes: {}` when constructing a fresh value because Serverpod 3.4.5 does not support generated map defaults.

The local server URL is `http://127.0.0.1:8870/`. Close `Client` when its owning provider is disposed. `tool/live_smoke.dart` checks real HTTP transport and generated decoding without printing task contents.
