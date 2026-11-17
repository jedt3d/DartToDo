# FlutterToDo local backend

Serverpod 3.4.12 and PostgreSQL 17, without Docker or account services. The generated typed client is the sibling `flutter_todo_client` package. Source models and endpoint operations are in `lib/src/todo`; generated outputs are in `lib/src/generated`.

From this directory, start with `dart bin/main.dart --apply-migrations`. Only the API listener on `127.0.0.1:8870` is configured. `LoopbackIoOverrides` enforces loopback binding because Serverpod 3.4.12 otherwise binds all interfaces despite `publicHost`. Insights and web servers are absent. Native-only API middleware rejects browser Origin headers, non-loopback Host names and non-POST task operations; CORS wildcard headers are removed. Other local OS processes are trusted in this no-account setup. This is a local OS-user service, not authenticated multi-user hosting.

The existing PostgreSQL service uses `localhost:5432`, role `worajedt`, no password, database `flutter_todo`. `config/passwords.yaml` is ignored by Git and must contain `shared:
  database: ''` on a fresh checkout. The separate `flutter_todo_test` database holds test schema and disposable test transactions. No unrelated databases are used.

Regenerate after editing endpoint signatures or `.spy.yaml` models:

```sh
dart run serverpod_cli:serverpod_cli --no-analytics --no-interactive generate
dart run serverpod_cli:serverpod_cli --no-analytics --no-interactive create-migration
```

Run `dart analyze --fatal-infos lib bin test` and `dart test --reporter expanded` from this directory. Integration tests apply migrations to `flutter_todo_test` and roll back each test's data. Unit checks include actual loopback socket binding.

Tasks, lists and groups use generated models with database foreign keys. Steps and attachment bytes are stored as typed JSON fields; total attachment bytes per task are bounded to 10 MB, filenames cannot contain paths, and file contents never name server filesystem locations. Delete/restore is soft deletion; deleting a group preserves its lists. A transaction and one fixed advisory lock serialize compound operations. Input failures use the generated `TodoException` type.

Recurrence retains the completed occurrence, creates a new uncompleted occurrence, resets steps and My Day, and clamps month/year boundaries. Repeated completion calls are idempotent; undo/redo reuses the generated occurrence. `custom` means every N days; other intervals use daily/weekly/monthly/yearly recurrence. The recurrence anchor is the later of the existing due date and the completion calendar date. This declared rule is tested; it is not a claim that every Microsoft recurrence edge case was independently observed.
