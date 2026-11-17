# Round 1 — Dart Analyzer

Updated after the approved analyzer-policy changes. **Final result: PASS — 0 errors, 0 warnings, 0 informational diagnostics; exit status 0.** Final measurement: **18 November 2026, 03:13:08 +07 (UTC+07:00)**. Wall time: **3.551s**.

The original policy passed, but enabling additional checks exposed **8 findings across 5 source files: 1 raw-type warning and 7 async informational diagnostics**. Each policy change was measured separately, and its findings were addressed before the next change. These findings are not eight demonstrated runtime failures; one is an intentionally nonblocking preview dialog made explicit.

## Source and command binding

| Item | Recorded value |
| --- | --- |
| Application repository | `jedt3d/DartToDo`, local checkout `FlutterToDo` |
| Base HEAD | `352b5f7cb6a454c5f5bf75dd7723a911eda42318` |
| Branch | `codex/quality-round-01-dart-analyzer` |
| Starting working tree | Tracked files clean; the earlier Round 1 report was already untracked |
| Measured candidate | Working-tree policy/source edits, bound to the final input manifest and implementation diff below |
| Flutter | `3.41.7` stable, framework revision `cc0734ac716fbb8b90f3f9db8020958b1553afa7` |
| Flutter-selected Dart | `3.11.5`, macOS arm64; SDK revision `c70f78e7d682c158c15ca0c26c729b3ccb932284` |
| Lint packages | Existing `flutter_lints 6.0.0` and `lints 6.1.0` |
| Root lockfile | Unchanged; no dependency versions were upgraded |

Every analyzer measurement used the same command from the application repository root:

```sh
flutter analyze --no-pub --fatal-infos --fatal-warnings
```

The installed CLI help was checked before use. Fatal flags fail the command for reported warnings/infos; enabled rules and strict modes come from configuration. Flutter launches the analysis-server snapshot bundled with the selected SDK, not the workspace's transitive `analyzer 10.0.1` package. The [Dart CLI reference](https://dart.dev/tools/dart-analyze) and [analysis guide](https://dart.dev/tools/analysis) explain the distinction between severity gates and configured policy; installed SDK/source evidence takes precedence over newer online documentation.

## One change at a time

| Evidence stage | Change/check | Errors | Warnings | Infos | Exit | Wall time |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| `00-baseline` | Fresh baseline, original policy | 0 | 0 | 0 | 0 | 3.717s |
| `01-client-lints` | Client recommended lint baseline | 0 | 0 | 0 | 0 | 3.500s |
| `02-strict-casts` | Enable strict-casts in all packages | 0 | 0 | 0 | 0 | 4.366s |
| `03-strict-inference` | Enable strict-inference in all packages | 0 | 0 | 0 | 0 | 3.192s |
| `04-strict-raw-types` | Enable strict-raw-types in all packages | 0 | 1 | 0 | 1 | 4.449s |
| `04-strict-raw-types-fixed` | Fix stored-photo parser element type | 0 | 0 | 0 | 0 | 3.598s |
| `05-unawaited-futures` | Enable unawaited_futures in frontend/client | 0 | 0 | 3 | 1 | 4.477s |
| `05-unawaited-futures-fixed` | Await three list-navigation operations | 0 | 0 | 0 | 0 | 3.935s |
| `06-discarded-futures` | Enable discarded_futures in all packages | 0 | 0 | 4 | 1 | 4.606s |
| `06-discarded-futures-fixed` | Handle editing callbacks and preview dialog | 0 | 0 | 0 | 0 | 3.797s |
| `07-cancel-subscriptions` | Enable cancel_subscriptions in all packages | 0 | 0 | 0 | 0 | 4.524s |
| `08-close-sinks` | Enable close_sinks in all packages | 0 | 0 | 0 | 0 | 4.055s |
| `11-final-analysis` | Final analysis after catalog refresh | 0 | 0 | 0 | 0 | 3.551s |

Only `unawaited_futures` was already enabled in the backend. The resource rules found no additional diagnostics. Failed intermediate measurements are retained, including their original stdout/stderr and source/configuration manifests; they were not replaced by the later passing runs.

The client now declares `lints: ^6.1.0` as a development dependency. `flutter pub get --offline --enforce-lockfile` succeeded using the existing resolution: only ignored `.dart_tool/package_graph.json` changed during that command. The root lockfile and shared package-config mapping stayed unchanged. There was no installation or upgrade of a new lint tool.

## Findings and fixes

| Diagnostic | Count | Location and practical change |
| --- | ---: | --- |
| `strict_raw_type` | 1 | [Stored-photo parser:278](../../flutter_todo_server/lib/src/background/unsplash_service.dart#L278): specify `List<Object?>` instead of raw `List`. JSON elements remain individually validated before use; parsing/URL guards were preserved. |
| `unawaited_futures` | 3 | [List creation:360](../../flutter_todo_flutter/lib/ui/todo_app.dart#L360), [deletion:441](../../flutter_todo_flutter/lib/ui/todo_app.dart#L441), [duplication:525](../../flutter_todo_flutter/lib/ui/todo_app.dart#L525): await navigation, whose implementation flushes pending detail edits. Check `mounted` again before the deletion message after that asynchronous gap. |
| `discarded_futures` | 4 | Await operations in [step renaming:402](../../flutter_todo_flutter/lib/ui/task_details.dart#L402), [task destination editing:648](../../flutter_todo_flutter/lib/ui/task_details.dart#L648) and [task reordering:260](../../flutter_todo_flutter/lib/ui/task_list.dart#L260). Mark the intentionally nonblocking [preview dialog:248](../../flutter_todo_flutter/lib/ui/catalog_previews.dart#L248) with `unawaited`. |
| **Total** | **8** | **5 affected source files; no new ignore comments or severity reductions.** |

Observed initial findings by package: frontend 7 infos, backend 1 warning, client 0. By file: `todo_app.dart` 3; `task_details.dart` 2; `task_list.dart`, `catalog_previews.dart` and `unsplash_service.dart` 1 each. These distributions reconcile with the intermediate command records, not with the final zero-diagnostic result.

## Final configured policy and measured result

| Package | Lint baseline | Unique enabled declarations before → after | Strict type modes | Async/resource rules |
| --- | --- | ---: | --- | --- |
| Frontend | `flutter_lints` → recommended → core | 102 → 106 | All three enabled | All four enabled |
| Backend | Recommended → core | 94 → 97 | All three enabled | All four enabled; `avoid_print` preserved |
| Client | Recommended → core, newly included | 0 → 96 | All three enabled | All four enabled |

The strict modes are `strict-casts`, `strict-inference` and `strict-raw-types`. The four explicit rules are `unawaited_futures`, `discarded_futures`, `cancel_subscriptions` and `close_sinks`. Source: [frontend options](../../flutter_todo_flutter/analysis_options.yaml#L12), [backend options](../../flutter_todo_server/analysis_options.yaml#L18), [client options](../../flutter_todo_client/analysis_options.yaml#L1), and [client development dependency](../../flutter_todo_client/pubspec.yaml#L12).

Rule totals are configuration observations, not analyzer-provided execution counts. Recursive installed includes were read and deduplicated; `no_wildcard_variable_uses` occurs in both core and recommended. All enabled declarations have registered implementations in the previously audited source at the installed Dart revision. Feature-dependent applicability and the SDK's experimental label on `use_super_parameters` still apply. There are no rule-disabling overrides, severity changes or analyzer plugins. Formatter `trailing_commas: preserve` is unchanged.

| Final reported diagnostics | Errors | Warnings | Infos | Total | Affected files |
| --- | ---: | ---: | ---: | ---: | ---: |
| Frontend | 0 | 0 | 0 | 0 | 0 |
| Backend | 0 | 0 | 0 | 0 | 0 |
| Client | 0 | 0 | 0 | 0 | 0 |
| Other workspace paths | 0 | 0 | 0 | 0 | 0 |
| **Total** | **0** | **0** | **0** | **0** | **0** |

Final distributions by code and by file are empty (`{}`). The original final command streams confirm `No issues found!`, empty stderr and exit status 0. Inputs were unchanged during each analyzer measurement; intentional edits between stages have separate snapshots. All 124 final manifest entries were checked after report authoring at the recorded measurement checkpoint. The later delivery-only instruction change is checked separately below.

## Scope and remaining limitations

The repository contains 73 versioned Dart sources: 33 frontend, 26 backend and 14 client. Explicit exclusions still match 23 generated Dart files, leaving 50 authored files not matched by those exclusions. This is an inventory count; the CLI does not report an exact visited-file count, and excluded dependencies can still be loaded for import resolution.

| Unchanged exclusion, relative to its package | Matched versioned files |
| --- | --- |
| Backend `lib/src/generated/**` | 11 Dart files plus non-Dart `protocol.yaml` |
| Backend `test/integration/test_tools/serverpod_test_tools.dart` | 1 generated Dart file |
| Client `lib/src/protocol/**` | 11 generated Dart files |
| Frontend | No explicit exclusions |

Complete matched paths and their hashes remain in the original `policy-audit.json` and input manifest. All excluded Dart files carry the generated-code header. The original 185 file-level suppression comments remain in those 23 excluded files; authored code still has no suppression comments. A generated ignore declaration is not an observed finding and does not establish that its named rule is enabled.

Strict modes and the added lints expand static checks; a clean result does not prove runtime correctness or leak freedom. Subscription/sink checks have documented tracking limits. The installed Flutter implementation also filters diagnostics of type `TODO` before reporting; no TODO count was measured. Complexity, performance, coverage percentage and an overall quality score were not measured.

## Verification of the fixes

| Check | Fresh result | Wall time |
| --- | --- | ---: |
| Frontend unit/widget suite, printing names excluded | **162 passed** | 7.539s |
| Isolated backend photo-service tests | **17 passed** | 2.190s |
| Non-writing format check of the 5 edited Dart files | **5 checked, 0 changes** | 0.177s |
| Required widget declaration/state refresh | **42/42 declarations, 78/78 cases; 14 state groups** | 355.002s |
| Final fatal-warning/fatal-info analysis | **0/0/0, exit 0** | 3.551s |

The frontend command was `flutter test --no-pub --reporter expanded --name '^(?!.*[Pp]rint)'` from the frontend package. The backend command was `dart test test/unit/unsplash_service_test.dart --reporter expanded` from the server package; it uses synthetic payloads, temporary files and an injected transport, with no database or live Unsplash request. The photo tests were first run at the raw-type fix, then rebound to the final source/policy after all rule changes.

After UI edits, the repository-required `python3 tool/catalog/rebuild.py --record` refreshed the app's [widget catalog](../../flutter_todo_flutter/widget-catalog.json#L1), retaining declaration IDs, required states and Figma mappings. It used the existing dnf-ui tool without changing it. Current inventory fingerprint: `25f252d450562fc64e760a53435dd3a8254bd967333d6c1f090e97dc564554a4`. Raw state evidence is under `flutter_todo_flutter/.dartnflutter/evidence/catalog/` and referenced by the catalog. This establishes the declared widget-state checks, not design approval, exhaustive UX coverage or native-device behavior. The state recordings overlap tests in the frontend suite; their counts are not added as independent product scenarios.

The combined verify suite, database/integration/native/printing tests, native builds, live smokes and dependency upgrades were not run. Existing release/native results remain historical. The DartNFlutter toolchain source and `/dnf-*` skill files are unchanged. The measurement preceded publication of the changes; no release is included.

## Issue and pull-request workflow

[Issue #11](https://github.com/jedt3d/DartToDo/issues/11) tracks the policy gaps, eight findings, acceptance checks and linked implementation PR. It was opened after the local implementation/verification at the user's request, without backdating the work. GitHub is the authority for the current merge and issue status.

The [repository instructions](../../AGENTS.md) now require the same issue → linked PR → review and verification → merge → issue closure workflow for actionable findings in later quality-tool rounds, under the user's authorization. This delivery instruction does not change application behavior or analyzer settings.

A fresh pre-publication analysis on **18 November 2026, 03:47:46 Asia/Bangkok** passed with **0 errors, 0 warnings and 0 infos**, exit 0, in **3.721s**. The only measured-input difference from the earlier checkpoint is the new `AGENTS.md` workflow instruction; application Dart sources, analyzer policy, dependency resolution and SDK inputs are identical. Its command streams, 124-input manifest and delivery verification remain ignored under `.dartnflutter/quality/round-01-delivery-20261117T204639Z/`.

## Original baseline and local evidence

The initial measurement on **18 November 2026, 02:42:29–02:42:33 Asia/Bangkok**, at the unmodified base HEAD passed with 0/0/0, exit 0, in 3.584832s. That result describes the earlier policy. Its raw evidence remains unchanged under:

```text
.dartnflutter/quality/round-01-20261117T194104Z-352b5f7cb6a4/
```

The original report text is also retained byte-for-byte as `report.before.md.txt` in the new ignored evidence directory:

```text
.dartnflutter/quality/round-01-policy-20261117T200118Z-352b5f7cb6a4/
```

Each numbered stage has `stdout.txt`, `stderr.txt`, `result.json` and before/after input manifests. Command metadata includes argv, cwd, base HEAD, UTC timestamps, elapsed time, exit status and stream/manifest digests. `initial-state.json` records the starting tracked-file hashes and existing untracked report. `policy-audit.json` reconciles the newly exposed findings and final rule configuration. `implementation.diff`, `validation.json` and `SHA256SUMS` bind the reviewed edits and retained evidence. Raw records are intentionally ignored, not published with this report; private configuration contents are not copied into the report.

| Selected SHA-256 binding | Digest |
| --- | --- |
| Final analyzer input manifest (124 inputs) | `1613017c25c2eb03785b6835a76a86aabea13f5d63867511937140c273ffc03a` |
| Final analyzer stdout | `9a79dcf64c290d35cb6a04824dd7c6faf87beb6bf47773ea23bccd1c27879177` |
| Final analyzer stderr (empty) | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Analyzer-policy diff at the measurement checkpoint, before delivery instructions | `63a221df710dbd6bdd97cb086454f654add0d6b8dac23ae384984c7a50cc2eaf` |
| Original report text | `0245b8343f34f0c38439bb1c844f9035e5f4bad3bacde449e90318fb55697302` |
| Unchanged root lockfile | `0a22c1b1cba7c78c39fc7c37952d3e2c992e401e2a93580e8d14b9e4d8b92406` |

The input manifests enumerate all repository Dart sources, analyzer/configuration/manifests/lockfile inputs, existing shared resolution, inherited lint files and relevant SDK/tool identity. The report and ignored raw evidence are outside measured inputs. The final review verifies source links, diagnostic/count arithmetic, hashes, preserved exclusions and unchanged dependency versions/toolchain/skills. This completes the analyzer-policy follow-up within Round 1; no next-tool round has started.
