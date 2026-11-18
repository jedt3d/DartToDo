# Quality tools, configuration and workflow

This is the operating guide for DartToDo's quality tools: what each checks, where its configuration lives, when to run it, and how findings become verified changes. Individual reports are measurement snapshots; this guide describes the workflow around them.

Configuration and availability were inspected on **18 November 2026**, using Flutter **3.41.7** and its Dart **3.11.5** SDK. The repository's manifests, lockfile, scripts and installed CLI help take precedence over newer online examples. This guide does not install tools, change rules, run later rounds or configure CI.

## Current state and proposed sequence

Completed formal reports in this series:

- **Round 1, Dart Analyzer:** [results and policy changes](01-dart-analyzer.md), [issue #11](https://github.com/jedt3d/DartToDo/issues/11), [merged PR #12](https://github.com/jedt3d/DartToDo/pull/12). The stricter policy exposed eight findings, addressed before final clean analysis.
- **Round 2, Dart formatter:** [baseline, scope correction and final result](02-dart-formatter.md), [issue #16](https://github.com/jedt3d/DartToDo/issues/16). All 73 tracked Dart files already matched formatting; the routine gate was extended to include the omitted server `bin` directory.
- **Round 3, Flutter unit/widget tests:** [baseline and findings](03-flutter-unit-widget-tests.md). All 162 selected tests passed across 10 frontend files, with 0 failures and 0 skips within that selection. One known mocked printing test was excluded by the existing name filter. No application fix was needed.
- **Round 4, Dart backend tests:** [baseline, database safeguards and findings](04-dart-backend-tests.md). All 51 normal-suite tests and the separate HTTP attachment test passed, with 0 failures/skips. The initial stopped PostgreSQL service was started for the checks and returned to its stopped state; no application fix was needed.
- **Round 5, Flutter coverage:** [baseline, attachment tests and final measurement](05-flutter-coverage.md), [issue #20](https://github.com/jedt3d/DartToDo/issues/20). Reported app-line coverage improved from 81.40% to 83.46% after eight attachment widget tests; 170 selected tests passed. Raw reported-library coverage is 79.51%; two startup files remain unmeasured and no threshold was added.
- **Round 6, Dart backend coverage:** [separate test tracks, transport tests and measurements](06-dart-backend-coverage.md), [issue #22](https://github.com/jedt3d/DartToDo/issues/22). Eight new transport tests raised reported hand-written runtime coverage from 89.06% to 93.27%; 59 normal-suite tests plus the separate HTTP test passed. Combined raw coverage is 73.35%; the launcher remains unmeasured and no threshold was added.

- **Round 7, complexity survey:** [metrics and reviewed watchlist](07-complexity-metrics.md). All 43 runtime files parsed through installed analyzer 10.0.1; large UI builders and nested feed parsing are review targets. DCM was unavailable; no new dependency, refactor or threshold was added.

Supporting tests and widget recordings do not mean those tools have completed their own formal quality rounds.

The sequence below covers the original analysis → formatting → tests/coverage → deeper checks → runtime profiling → CI/review workflow. It also identifies the app's existing UI and native checks. Apart from the completed first seven rounds, the order is proposed: select one tool or focused track per round, rather than starting the remaining rows automatically.

| Tool or focused track | Configuration and scope | When to use it | Current state |
| --- | --- | --- | --- |
| **1. Dart Analyzer** | Three package `analysis_options.yaml` files; workspace resolution | IDE feedback, after Dart edits, before PR/merge | Round 1 complete; expanded policy configured |
| **2. Dart formatter** | Package `formatter` options; explicit Dart file targets | Format edited files; non-writing check before PR | Round 2 complete; 73 files, 0 changes; routine gate now includes backend `bin` |
| **3. Flutter unit/widget tests** | Frontend `flutter_test`, files under `test/`, fake repositories/platform adapters | Frontend behavior changes and affected PRs | Round 3 complete; 162 selected tests passed; printing-name filter retained |
| **4. Dart backend tests** | Server `test` dependency, `dart_test.yaml`, unit/integration targets | Backend changes; database tests only with the intended test service/configuration | Round 4 complete; 51 normal-suite tests plus 1 separate HTTP test passed |
| **5. Flutter coverage** | `flutter test` coverage flags, declared source populations and output path | Dedicated measurement; update after relevant test/code changes | Round 5 measured 83.46% of reported app lines; 79.51% raw reported lib; no threshold |
| **6. Dart backend coverage** | `dart test --coverage-path`, declared runtime populations, unit/full/HTTP tracks | Dedicated measurement; keep database prerequisites and test tracks explicit | Round 6 measured 93.27% of reported hand-written lines; 73.35% combined raw; no threshold |
| **7. Complexity metrics** | Tool/version, metrics, exclusions and thresholds chosen at that round | Investigate difficult functions, nesting and maintainability | Round 7 complete using an explicit read-only AST survey; DCM unrun; no gate |
| **8. App-specific custom lints, if needed** | A reviewed custom rule implementation and tests | Repeated architectural mistakes that official rules/tests do not adequately address | No custom-lint package, plugin or app-specific rule configured |
| **9. Widgetbook and declaration/state catalog** | Private preview harness, `widget-catalog.json`, catalog rebuild script | Production Dart changes require the repository's declaration/state refresh | Existing workflow; Round 1 refreshed 42 declarations and 78 cases |
| **10. Native integration checks** | `integration_test`, target IDs, native build/service configuration | Platform-sensitive changes and scoped release checks | Existing macOS/iOS flows; prerequisites and actual targets must be verified |
| **11. Golden/visual regression** | Reviewed reference images, fixed rendering conditions and test assertions | Visual regressions after an approved baseline exists | No approved golden baseline or golden assertions found in the frontend test tree |
| **12. Flutter/Dart DevTools** | Selected target/build mode, scenario, fixture and recording settings | Layout investigation, CPU/memory/frame/network profiling | SDK provides DevTools; no performance baseline established by this series |
| **13. CI gates and code review** | Future `.github/workflows` jobs; separate required-check settings; PR review | CI on approved events, review on every PR | Analyzer CI proposed in [issue #13](https://github.com/jedt3d/DartToDo/issues/13); no Actions workflows currently configured |

Code review applies throughout the sequence, not only at its final row. A metrics tool and a custom-lint framework answer different questions; selecting one does not configure the other.

## When checks belong in everyday work

| Moment | Checks and decisions |
| --- | --- |
| While editing | Use the Dart/Flutter IDE extension's diagnostics. Format touched Dart files. IDE setup is editor-specific; this repository does not install editor extensions or format-on-save hooks. |
| After a coherent group of Dart changes | Run root workspace analysis and relevant focused tests. Check formatting for the edited paths. |
| After production Dart changes | Refresh the declaration/state evidence required by [AGENTS.md](../../AGENTS.md) and the [widget methodology](../trial/widget-coverage.md). Record the actual source fingerprint. |
| Before opening/updating a PR | Use an issue for actionable findings, run the scoped checks against the candidate source, and report passes, failures and exclusions. Documentation-only changes need link/content/scope checks rather than application execution. |
| Before merging | Review the actual final diff and head commit; required configured checks must pass. Changed inputs expire the affected evidence. The user's quality-tool workflow authorization is recorded in `AGENTS.md`. |
| Before a native/release claim | Run the explicitly scoped platform, service, integration and artifact checks. A clean analyzer or widget test is not native acceptance. |
| In CI, when implemented | Run the configured jobs on their documented events. Issue #13 proposes analyzer checks on pull requests and pushes to `main`; an installed workflow and a required merge check are separate settings. |

These are workflow requirements, not a claim that automation currently enforces them. There is no configured Actions workflow, required status-check gate, pre-commit formatter hook or coverage threshold in this repository at this checkpoint.

## Analyzer: official checks and our policy choices

Use the application repository root as the working directory:

```sh
flutter analyze --no-pub --fatal-infos --fatal-warnings
```

Dependencies must already be resolved. `--no-pub` skips automatic resolution during analysis; it is not an SDK/version selector. Fatal flags make warnings and informational diagnostics fail the command without changing their displayed severity. Both fatal settings default to on in the installed Flutter CLI; spelling them out makes the intended gate explicit. Rules and strict types come from options files, not these flags. See the [official analysis guide](https://dart.dev/tools/analysis) and [CLI severity documentation](https://dart.dev/tools/dart-analyze).

| Policy | Source of truth | Reason |
| --- | --- | --- |
| Frontend baseline | [Frontend options](../../flutter_todo_flutter/analysis_options.yaml): `package:flutter_lints/flutter.yaml` | Official Flutter recommendations, including the recommended/core Dart sets |
| Server/client baseline | [Server options](../../flutter_todo_server/analysis_options.yaml), [client options](../../flutter_todo_client/analysis_options.yaml): `package:lints/recommended.yaml` | Official Dart recommendations for the authored code in these packages |
| Lint package versions | Package manifests and [root lockfile](../../pubspec.lock) | Currently resolved `flutter_lints 6.0.0` and `lints 6.1.0`; no implicit upgrade |
| Strict type settings | `analyzer.language` in all three package options files | `strict-casts`, `strict-inference`, `strict-raw-types` are enabled; they are official optional analyzer modes |
| Async/resource checks | `linter.rules` in all three packages | `unawaited_futures`, `discarded_futures`, `cancel_subscriptions`, `close_sinks` are official optional rules selected for a consistent policy |
| Other retained policy | Inherited Flutter rules and server overrides | Existing `avoid_print` enforcement is preserved; it was not added to the client's console smoke scripts |
| Generated exclusions | Server/client `analyzer.exclude` entries | Generated protocol and test-helper exclusions remain; the report inventories their scope |

All enabled rules are official Dart/Flutter rules. Choosing optional modes, overrides and exclusions is our policy; none of these checks encodes DartToDo business rules. Task identity, attachment limits and local-storage boundaries still require implementation, tests and review. An explicit [`unawaited`](https://api.dart.dev/dart-async/unawaited.html) call records an intentional nonblocking operation; it does not handle its errors or prove safety. Resource rules also have tracking limits.

Do not add a rule, a suppression or a new preset just to change a score. Measure its findings, inspect the source, choose the smallest complete fixes, and rerun the same gate. The root [verification runner](../../tool/verify.py) and [lifecycle recipe](../../tool/lifecycle-task.json) already invoke analysis; they omit the redundant `--fatal-warnings` flag but use its installed default.

## Formatter: configuration and separate write/check modes

All three package options files set `formatter.trailing_commas: preserve`. The [Dart formatter](https://dart.dev/tools/dart-format) owns formatting; analyzer success does not establish formatter compliance.

Example from the repository root, using a real authored file:

```sh
# Check without writing. Substitute the actual edited Dart paths as needed.
dart format --output=none --set-exit-if-changed flutter_todo_flutter/lib/ui/todo_app.dart

# Apply formatting to that file when formatting changes are intended.
dart format flutter_todo_flutter/lib/ui/todo_app.dart
```

The current broader target list lives in `tool/verify.py`. [Round 2](02-dart-formatter.md) checked all 73 tracked Dart files, including generated output, and added backend `bin` to that routine list. New Dart directories need a target/inventory review; explicit lists do not automatically cover every future path. The earlier five-file Round 1 check remains a narrower historical result. No formatter hook or formatter CI job is installed by these rounds.

## Tests, generated consistency and UI evidence

[Flutter's testing guide](https://docs.flutter.dev/testing/overview) distinguishes function/class, widget and integration tests. Each has a different execution boundary. Commands below are documented entry points, not tests executed by this documentation change.

| Check | Working directory | Existing entry point | Preconditions and effects |
| --- | --- | --- | --- |
| Frontend unit/widget suite | `flutter_todo_flutter` | `flutter test --no-pub --reporter expanded --name '^(?!.*[Pp]rint)'` | Uses the existing test harnesses; preserves the printing-test exclusion used in Rounds 1 and 3. Report the filter, not a claim of full unfiltered coverage. |
| Backend unit/middleware subset | `flutter_todo_server` | `dart test test/unit --reporter expanded` | No PostgreSQL required; includes a temporary real loopback middleware listener and injected photo-service transport/cache fixtures |
| Isolated backend photo-service tests | `flutter_todo_server` | `dart test test/unit/unsplash_service_test.dart --reporter expanded` | Injected transport and temporary files; no database or live Unsplash request |
| Backend suite | `flutter_todo_server` | `dart test --reporter expanded` | Includes PostgreSQL integration tests; verify `flutter_todo_test` configuration and preserve other databases |
| Real-HTTP attachment probe | `flutter_todo_server` | `dart test tool/attachment_http_test.dart` | Separate test-configuration/HTTP run with its own fixture cleanup; not implied by the ordinary suite |
| Generated protocol consistency | `flutter_todo_server` | `python3 tool/check_codegen.py` | Regenerates declared outputs and compares hashes. It can leave changed generated files for inspection; it is not read-only. |
| Widget declaration/state recording | `flutter_todo_flutter` | `python3 tool/catalog/rebuild.py --record` | Scans, regenerates catalog/entrypoint and records exact named state tests; writes app catalog files and ignored evidence |
| Native application flow | `flutter_todo_flutter` | `flutter test --no-pub integration_test/app_test.dart -d macos` | Requires the real local backend and native target. Creates and removes its own synthetic lists through the application service; inspect scope before running. |

[Round 3](03-flutter-unit-widget-tests.md) ran the frontend command before edits and added `--file-reporter json:<fresh-ignored-path>` for exact per-test accounting. The same run passed 47 unit/service tests and 115 widget tests. Its 10 hidden successful suite-loading events are not additional tests; the 49 catalog tests include repeated preview assertions in 14 state groups. Zero runner-reported skips applies to selected tests; the known mock-print test was filtered out. Review this name-based filter when adding or renaming tests.

Use focused test files while editing; run the selected frontend suite after changes to shared UI/state/harness behavior and before merging affected PRs. A documentation-only update can retain current evidence when its test inputs are unchanged. These headless tests use fakes/mocks and temporary caches; real PostgreSQL, OS notifications, native devices, coverage and flake measurements require their separately scoped checks. This round changes no test configuration and installs no automation.

[Round 4](04-dart-backend-tests.md) measured 27 backend unit/middleware tests, then the complete 51-test suite (including those same 27 and 24 PostgreSQL tests), then the separate HTTP attachment test. The total is 52 distinct test registrations; loading/setup/teardown events and the repeated unit baseline are not additional scenarios. All passed without filters or skipped tests on the existing PostgreSQL 17.12 installation.

After backend logic edits, run the relevant unit files. Before merging endpoint/model/persistence changes, verify the [test database prerequisites](../development.md#postgresql-and-local-configuration) and run the normal suite against `flutter_todo_test`. A stopped/missing service is a setup result, not a pass or an application defect. Do not drop/recreate existing databases to obtain a clean run. The rollback harness applies pending migrations in test mode and rolls back test transactions; sequence counters can still advance.

For attachment/transport changes, run the separate HTTP probe after the normal suite, sequentially: its HTTP sessions commit and its cleanup deletes only its own synthetic rows. It is outside default `test/` discovery. Round 4 verified the checked application/test schema and data digests and restored the service's original stopped state; that snapshot is narrower than a complete database audit. Neither command starts the normal application backend or requires running `tool/verify.py`.

For iOS, verify installed devices and the target configuration in [development](../development.md), [native profile](../../tool/flutter-profile.json) and [verification runner](../../tool/verify.py); stored simulator UUIDs are machine-specific. Notification taps, terminated-app launches, screenshots and human visual acceptance have separate evidence. Physical printing remains skipped at the user's request.

Widgetbook/declaration-state details belong in the [widget methodology](../trial/widget-coverage.md), [catalog rebuild script](../../flutter_todo_flutter/tool/catalog/rebuild.py) and [current catalog](../../flutter_todo_flutter/widget-catalog.json). A current named state recording does not establish Figma approval, complete accessibility or every possible interaction. Preserve private widgets and their in-library preview access.

For a future golden round, first agree the reference image, fonts, target/rendering environment, dimensions, pixel ratio, theme, locale and synthetic data. Review baseline images before accepting them. The existing screenshot gallery is runtime/reference evidence, not an automatically approved golden baseline; no golden-update command is part of the current workflow.

## Coverage: measure first, choose thresholds afterward

Coverage records which scoped code executes during selected tests. It does not measure assertion quality or prove correct behavior. Define the package/source denominator, generated exclusions, test selection and line/branch treatment before reporting a percentage or proposing a threshold.

The following options were verified in the installed CLI help. Rounds 5 and 6 executed frontend and backend coverage respectively. These commands write ignored reports. From `flutter_todo_flutter`, for selected frontend tests with printing excluded, use a fresh output directory when retaining a snapshot:

```sh
mkdir -p ../.dartnflutter/quality/frontend-coverage
flutter test --no-pub --coverage \
  --coverage-package='^flutter_todo_flutter$' \
  --coverage-path=../.dartnflutter/quality/frontend-coverage/lcov.info \
  --reporter expanded --name '^(?!.*[Pp]rint)' \
  --file-reporter json:../.dartnflutter/quality/frontend-coverage/tests.jsonl
```

Separately, from `flutter_todo_server`, keep the unit/full/HTTP tracks distinct. The first needs no PostgreSQL; confirm the [test database prerequisites](../development.md#postgresql-and-local-configuration) before the last two, which run sequentially. Use a fresh output directory for retained measurements:

```sh
mkdir -p ../.dartnflutter/quality/backend-coverage
dart test test/unit --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/backend-coverage/unit.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/backend-coverage/unit.jsonl
dart test --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/backend-coverage/suite.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/backend-coverage/suite.jsonl
dart test tool/attachment_http_test.dart --coverage-package='^flutter_todo_server$' \
  --coverage-path=../.dartnflutter/quality/backend-coverage/http.info \
  --reporter expanded --file-reporter json:../.dartnflutter/quality/backend-coverage/http.jsonl
```

[Round 5](05-flutter-coverage.md) declares the denominator and supplies a reproducible subtotal script. Its primary view includes the reported executable lines of maintained app code: 1579/1892, **83.46%**, across 10 of 12 inventory files. Generated Widgetbook and authored preview support remain visible separately; including them gives 1913/2406, **79.51%**, across 12 of 14 library files. `main.dart` and `app_entry.dart` are absent from LCOV and explicitly unmeasured. No source ignore marker or analyzer exclusion defines these subtotals.

The eight attachment widget tests added in that round join the ordinary frontend suite, bringing its printing-filtered selection to 170 passes. Rerun focused tests while editing and coverage when changing tests/code relevant to a recorded result. Keep the same package/filter/source populations for before/after comparisons; changed inputs expire affected evidence. Review uncovered behavior and add assertions for concrete regression risks, rather than excluding inconvenient lines or counting test code as app coverage.

[Round 6](06-dart-backend-coverage.md) adds eight deterministic photo HTTP-transport tests. The backend unit subset now passes 35 tests and reports 319/594 hand-written lines (53.70%); the full suite passes 59, including those same 35 and 24 PostgreSQL tests, and reports 554/594 (93.27%). The separate HTTP probe adds one test. Its union with the suite reports 1252/1707 runtime lines (73.35%) including 11 generated files; hits are merged by source/line, not by adding percentages or double-counting repeated tests.

The launcher `bin/main.dart` is absent and explicitly unmeasured; the optional photo endpoint wrapper remains 0/3 lines. Runtime startup, some domain paths and live endpoint/photo behavior remain separate gaps. Read the per-track/file report before interpreting the low unit-only percentage as the complete backend result. The report supplies a reproducible union/subtotal script. Generated code and analyzer exclusions are separate coverage concerns; no source suppression or minimum gate was added.

The current Dart test runner can produce LCOV directly. The [official `coverage` package](https://pub.dev/packages/coverage) is resolved transitively and used by the installed collectors; no global CLI installation was needed. Reuse installed capabilities before adding another tool. Rounds 5 and 6 establish measured line percentages; no minimum threshold, branch/function acceptance level, coverage CI gate or pre-commit hook has been approved or installed. A percentage is not proof of assertion quality or native behavior.

## Metrics and custom lints: conditional additions

[DCM metrics](https://dcm.dev/docs/metrics/) can measure complexity, nesting and related properties. Before choosing it, verify installed availability, compatible SDK/version, access/licensing requirements, supported commands, authored/generated scope, metrics and thresholds. Establish an observed baseline before setting a gate. No DCM executable, project metrics configuration or threshold was established by Round 1; this guide supplies no unverified command or configuration block.

[`custom_lint`](https://pub.dev/packages/custom_lint) is a framework for implementing custom rules. Consider it only for a specific repeated app/architecture constraint with a defined detection rule, examples, false-positive policy and tests. It is not a complexity measurement by itself. No custom-lint dependency/plugin is configured here; installing a framework does not create an app rule. Select and verify any addition in its own issue/round, preserving the current SDK until an upgrade is explicitly scoped.

## DevTools: runtime investigation

[Flutter/Dart DevTools](https://docs.flutter.dev/tools/devtools) provides layout inspection and CPU, memory, frame and network investigation. It needs a running target; static analysis cannot supply those measurements.

For each profiling round, record the device/OS, SDK, build mode, scenario, synthetic dataset, warm-up/repetitions and exported trace. Use [profile-mode measurements on a supported actual target](https://docs.flutter.dev/testing/build-modes) for performance conclusions; debug inspection has a different purpose, and mobile profile mode is unavailable on the emulator/simulator. Verify launch/attachment options against the installed SDK and actual available target at that round. No runtime profiler, app, simulator or native flow is launched by this guide, and no performance threshold or improvement is inferred from test duration.

## Routine verification, CI and the existing `/dnf-*` workflow

`python3 tool/verify.py` is a compound local runner: it checks its formatter targets and analyzer, runs frontend/backend/attachment tests, regenerates protocol output, starts or reuses the backend, and runs HTTP smokes. `--native` additionally builds and exercises configured native targets. Even the ordinary runner requires real services and can execute the unfiltered frontend mock-print test; it is not the command for a single-tool baseline or for preserving a printing-test exclusion. Inspect the script and [development prerequisites](../development.md) before choosing it.

The app's lifecycle/native recipe files describe configured checks; they are not execution evidence. In particular, `tool/lifecycle-task.json` contains historical catalog artifact paths. Rebind required artifacts to the current catalog/source before reusing a recipe, and report missing or stale evidence honestly.

The existing `/dnf-inspect`, `/dnf-plan`, `/dnf-verify` and `/dnf-ui` skills respectively support environment/source inspection, scoped acceptance/check planning, execution/evidence assessment and UI declaration/state evidence. They orchestrate configured commands; the SDK analyzer still reads this app's options files. Pass the application root explicitly, keep setup separate from measurement and inspect command side effects. The Round 1 report records the inspection helper's workspace-resolution limitation; the shared root package config/lockfile establishes actual resolution. This guide changes none of those skills, recipes or the sibling toolchain.

Analyzer CI is tracked in [issue #13](https://github.com/jedt3d/DartToDo/issues/13). A future job should identify the checked commit, use the selected SDK/lockfile and run the same fatal-warning/fatal-info gate on the approved events. Native/database jobs need separately provisioned prerequisites. Defining a workflow, observing a passing run and making a check required for merge are separate steps; none is implied by this document.

## Findings, reports and delivery

Follow the quality-tool issue/PR rule in [AGENTS.md](../../AGENTS.md):

1. Select one tool and state its question, scope, prerequisites and unchanged inputs. Read actual implementation/configuration before recommendations.
2. Measure the current baseline before fixes. Record commit and dirty state, SDK/tool versions, resolved dependencies, exact argv/cwd, stdout/stderr, exit status, duration and input hashes. Report configured rules/exclusions separately from observed findings.
3. For each coherent actionable finding set, open an issue before changes. Include source locations, practical implications, scope/non-goals and acceptance checks. A clean tool result needs a report, not an invented defect ticket.
4. Make the smallest complete fix on an issue-linked `codex/` branch. Change one policy/rule at a time where attribution matters, rerun it, and run the relevant regression checks. Required supporting checks do not silently start another formal tool round.
5. Publish the readable round report in `docs/quality/`; keep raw evidence, private captures and credentials under ignored storage. Retain failed/interrupted attempts and the original baseline. Link the issue and PR; keep source/configuration/exclusions and unavailable measurements explicit.
6. Review the final diff and exact PR head, address feedback, and merge only when the scoped verification and required repository checks pass under the user's authorization. Update and close the issue after the merge; create separate follow-ups instead of expanding the completed ticket.
7. Stop for the user's next tool selection. Update this guide when configuration, availability or cadence changes; preserve earlier reports as dated evidence rather than rewriting them to claim new results.

The first report predates the user's issue-first instruction; [issue #11](https://github.com/jedt3d/DartToDo/issues/11) explicitly records that chronology. Later rounds follow the issue-first fix workflow. Guide maintenance is tracked in [issue #14](https://github.com/jedt3d/DartToDo/issues/14); GitHub holds live ticket/merge status. Historical app release evidence remains under `docs/trial/` and does not verify later commits.
