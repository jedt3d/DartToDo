# Local data and security

DartToDo stores one local user's tasks in PostgreSQL on this Mac. It has no Microsoft account, application login, tenant separation or multi-user authorization. A display name is a preference, not an identity check. Other processes or users able to reach the local service/database are trusted by this configuration. Do not expose this deployment as a shared network service.

## Implemented boundaries

- The API listens on **127.0.0.1:8870**. `LoopbackIoOverrides` changes the actual Dart server-socket bind; `publicHost` by itself would not restrict the inspected Serverpod 3.4.5/3.4.12 default all-interface listener. Insights and web listeners are not configured.
- Native-only middleware rejects requests containing a browser `Origin`, non-loopback host names and non-POST task operations. Serverpod's wildcard CORS response headers are removed. This reduces browser-origin and DNS-rebinding access; it does not authenticate another local process.
- PostgreSQL is accessed at `localhost:5432` as `worajedt` with an empty password, using the user's existing local authentication setup. The trial does not change PostgreSQL's authentication rules or imply its other listeners/databases are isolated.
- Generated query APIs and database foreign keys enforce relationships. The only authored raw SQL statements use fixed text for a local advisory lock and sequence initialization; user input is not interpolated into them.
- Endpoint validation rejects invalid identifiers, missing/deleted parents, empty/oversized titles, impossible dates, unsupported recurrence/sort/theme values, duplicate step/file IDs, invalid base64 and excessive files. Attachment bytes on one task total at most 10 MB. Filenames cannot contain directory separators/control characters and are never used as server paths.

The UI reads and writes attachments through native user-selected dialogs. Removing an attachment changes the task's stored data; it does not delete the original imported file or a previously exported copy.

## Patched ORM dependency

The release candidate pins Serverpod runtime, client, Flutter adapter, test helper and CLI together at **3.4.12**. The initial 3.4.5 graph was affected by [GHSA-868m-gf4j-xr8g](https://github.com/serverpod/serverpod/security/advisories/GHSA-868m-gf4j-xr8g): ordinary user-controlled text with binary-decode markers could be inserted into SQL without normal string escaping. Task titles/notes, list/group titles and display names reached that shared ORM boundary; using typed query methods did not prevent the vulnerability.

The official advisory's structured patch metadata conflicts with its 3.4.12 prose. The actual registry 3.4.12 archive and changelog were inspected: the string-content bypass is removed, genuine ByteData uses hex encoding, and Uri values use the normal escaping path. All coordinated package constraints remain compatible with Dart 3.11.5. No task-string filtering or destructive data migration was introduced.

A real PostgreSQL regression stores harmless `decode('c2FmZQ==', 'base64')` text. On 3.4.5 it incorrectly returned the decoded-byte text `\x73616665`; on 3.4.12 it roundtrips literally through insert/update/filter operations and the affected application text fields. Ordinary apostrophe-containing text remains unchanged. The security-patch checkpoint passed 48 backend tests and generation consistency. The final release suite passes 49 tests, including DEL/C1 filename/MIME rejection and ordinary Unicode filename preservation. The test runs against the separate rollback test database and performs no destructive SQL. This verifies the affected application string paths; it is not a general security certification or end-to-end Uri-column test, since the app declares no Uri database column.

## Privacy and storage

Tasks, notes, steps, settings and attachment bytes are in `flutter_todo`; tests use the separate `flutter_todo_test` database. The app adds no application-level encryption. Protect the Mac account, PostgreSQL data directory and backups according to their sensitivity. Native reminder notifications contain task titles and can appear in system notification history or on a lock screen, subject to OS settings. Clipboard commands deliberately copy task text to the system clipboard.

The app has no task cloud-sync, advertising or task-analytics service. My Day's requested Unsplash background feature contacts the public homepage/image CDN and shows attribution; no task data is sent. Homepage scripts/cookies are not executed/imported. An optional configured API adapter additionally sends a photo-selection download event; the default no-key mode does not. See [Unsplash boundaries](unsplash.md). Development dependency downloads still contact package registries, and the optional Serverpod CLI is invoked with analytics disabled. No claim is made about telemetry in the user's operating system, installed reference app or unrelated tooling.

`config/passwords.yaml`, `.dartnflutter/` logs/evidence, private reference material and proprietary theme PNGs are excluded from Git. Raw command output can contain whatever a command prints: inspect it before sharing. The source repository/release ZIP must not include the live database, backups, credentials, private screenshots or Microsoft account/task data. Reference theme extraction reads only shipped image assets; it does not import account or task data. See the [theme provenance](../flutter_todo_flutter/assets/themes/README.md).

## Deletion and recovery

Task/list deletion is soft deletion. The immediate Undo action restores it; there is no deleted-items screen or automatic retention purge. Dissolving a group retains lists/tasks but has no restore endpoint. Removing a file/step or replacing note text does not retain an application revision history. Back up the database if those changes need later recovery.

## Back up without touching other databases

The running server observed on 17 November 2026 is PostgreSQL **17.11**. Postgres.app's `latest` directory currently points to **18.6** tools, so these examples use the explicit matching major-version directory. Replace the backup filename with a new one for each backup; `pg_dump --file` can overwrite an existing file. Store backups outside Git and protect them as task data.

Run from a terminal on this Mac:

```sh
mkdir -p "$HOME/Documents/DartToDo-backups"
/Applications/Postgres.app/Contents/Versions/17/bin/pg_dump \
  --host=localhost --port=5432 --username=worajedt \
  --format=custom \
  --file="$HOME/Documents/DartToDo-backups/flutter_todo-2026-11-17-2130.dump" \
  flutter_todo
```

The dump includes the selected database's schema and data, including attachments; it does not back up every database on the server. Inspect the archive table of contents without restoring it:

```sh
/Applications/Postgres.app/Contents/Versions/17/bin/pg_restore \
  --list "$HOME/Documents/DartToDo-backups/flutter_todo-2026-11-17-2130.dump"
```

To rehearse recovery, restore into a **new, empty database**, never over the live app database:

```sh
/Applications/Postgres.app/Contents/Versions/17/bin/createdb \
  --host=localhost --port=5432 --username=worajedt darttodo_restore_check
/Applications/Postgres.app/Contents/Versions/17/bin/pg_restore \
  --host=localhost --port=5432 --username=worajedt \
  --dbname=darttodo_restore_check --no-owner --no-privileges \
  --single-transaction --exit-on-error \
  "$HOME/Documents/DartToDo-backups/flutter_todo-2026-11-17-2130.dump"
```

If `createdb` says the destination exists, stop and choose a different new name; do not continue into an existing database. These recovery commands are documented, not executed trial evidence. Inspect the restored schema/data before any deliberate cutover. Stop the app/backend and preserve another live backup before changing its configured database. This guide does not drop, clean or overwrite a database.

## Verification scope

The backend suite currently exercises real PostgreSQL validation/rollback, recurrence, deletion/restore and attachment boundaries. Separate real HTTP checks verify loopback binding, browser-origin/host rejection and generated-client decoding. These checks are useful evidence, not a security certification, penetration test, encryption guarantee or independent assessment of every native plugin. Build, simulator, signing and notification-delivery outcomes require their own release evidence.
