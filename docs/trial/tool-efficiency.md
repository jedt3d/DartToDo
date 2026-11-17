# Reviewed tool-efficiency ledger

This is an observational account of the DartToDo real-project trial, using the actual command ledger and retained correction chains. It makes no B/C, time-saved, cost-reduction, statistical-effect or human-rating claim.

## Snapshot and identities

The command snapshot has **133 events across 116 labels**, from `20261117T135849128343Z` through `20261117T145709583454Z` (UTC). Newer events may exist in the live private ledger; this table is a fixed review checkpoint. Selected identities: DartNFlutter 0.1.0 / Node 26.12.1; Flutter 3.41.7 / Dart 3.11.5; flutter_riverpod 3.3.1 with riverpod 3.2.1; Serverpod runtime/client/project CLI 3.4.5; Widgetbook 3.23.0; PostgreSQL 17.11; Xcode 27.2. This writer runs Python 3.12.10; recorded script interpreter identities are limited to what each command captured. [Setup/version scope](../development.md).

The [runner](../../tool/trial_run.py) records exact argv, cwd, stage, duration, exit code/status and raw pointer in [events.jsonl](../../.dartnflutter/trial/events.jsonl). Raw logs remain excluded from Git. Its `retries=0`, `manualCorrection=null` and pending usefulness are per-event defaults, **not observations of zero retries/manual effort**. Below, P/F is each label's ordered recorded status sequence; multiple calls may use changed source or a broader test scope. Explicit retry labels and their causes are linked in correction chains. Uninstrumented read-only calls, computer interactions and model deliberation are outside these command totals.

## Measured cost and useful outcomes

Fourteen serial `widgets record` calls totalled **332.731s** (21.068–26.667s each; median 23.796s). Their before/after full semantic scans and child tests are already inside those durations. Separate scan/init/generate/validate calls add setup/validation overhead. The final focused frontend run passed 76 tests in 5.477s; 33 individual previews and 14 grouped repeats represent overlapping assertions, not 47 independent feature tasks. The catalog validated 37/37 declarations and 73/73 mappings. [UI scope](widget-coverage.md).

Long-lived backend start entries measure service lifetime, including waiting while other work ran. Do not add their durations to development or repair effort. Parallel/nested commands likewise cannot be summed into end-to-end time. Task-level repair boundaries were not comprehensively instrumented, so a single total repair-effort number is unknown. Model usage/cost and a matched unassisted baseline are unknown.

## Recorded command labels

Each row preserves all recorded statuses/durations for that label and links its latest raw output. Exact per-attempt argv and earlier raw pointers remain in JSONL. A failed label without a reviewed cause is retained without assigning an invented root cause. “None recorded” is a recording limit, not proof no correction occurred.

| Label / executable | Stage | P/F sequence | Seconds per call | Usefulness / result boundary | Correction | Latest evidence |
| --- | --- | --- | --- | --- | --- | --- |
| `serverpod-create` / `serverpod` | discover | P | 47.226 | Compatible scaffold; generated Docker advice not used | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T135849128343Z-serverpod-create.log) |
| `workspace-pub-get` / `flutter` | discover | P | 1.454 | Installed API/version evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T135957284801Z-workspace-pub-get.log) |
| `frontend-dependencies` / `flutter` | discover | P | 12.847 | Dependency/tool setup; selected graph retained | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140115600549Z-frontend-dependencies.log) |
| `backend-generate` / `serverpod` | implement | P/P | 7.080, 8.231 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140218580033Z-backend-generate.log) |
| `state-installed-source` / `node` | inspect | P | 0.105 | Installed API/version evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140218364360Z-state-installed-source.log) |
| `reference-assets` / `swift` | discover | P | 4.606 | Private local reference assets; no task import | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140236009559Z-reference-assets.log) |
| `backend-generate-api` / `serverpod` | implement | P | 6.113 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140421795660Z-backend-generate-api.log) |
| `resolved-workspace` / `flutter` | discover | P | 2.181 | Installed API/version evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140451942303Z-resolved-workspace.log) |
| `backend-generate-settings` / `serverpod` | implement | P | 6.242 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140519810153Z-backend-generate-settings.log) |
| `backend-migration` / `serverpod` | implement | P | 0.651 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140657214057Z-backend-migration.log) |
| `backend-tests` / `dart` | verify | P | 4.046 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140702005823Z-backend-tests.log) |
| `backend-analyze` / `dart` | verify | P | 1.035 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140711556898Z-backend-analyze.log) |
| `state-tests` / `flutter` | verify | P/P | 5.541, 1.697 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140823430523Z-state-tests.log) |
| `state-analysis` / `dart` | verify | F/P | 1.122, 1.322 | Actionable after reviewed correction | [C1](#c1) | [raw](../../.dartnflutter/trial/raw/20261117T140822361209Z-state-analysis.log) |
| `backend-analyze-final` / `dart` | verify | P | 0.596 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140721202034Z-backend-analyze-final.log) |
| `generated-client-live` / `dart` | verify | P | 0.909 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140817932770Z-generated-client-live.log) |
| `client-analyze` / `dart` | verify | P | 0.566 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140851029244Z-client-analyze.log) |
| `backend-final-tests` / `dart` | verify | P | 3.592 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140925191729Z-backend-final-tests.log) |
| `backend-analyze-stable` / `dart` | verify | P | 0.882 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140946248275Z-backend-analyze-stable.log) |
| `backend-http-security-tests` / `dart` | verify | P | 2.905 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141105285951Z-backend-http-security-tests.log) |
| `backend-security-analyze` / `dart` | verify | P | 0.766 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141108221163Z-backend-security-analyze.log) |
| `completed-count-analysis` / `dart` | verify | P | 1.153 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141123851435Z-completed-count-analysis.log) |
| `completed-count-test` / `flutter` | verify | P | 1.785 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141123851436Z-completed-count-test.log) |
| `backend-live-start` / `dart` | verify | P | 219.050 | Setup/service lifetime; readiness separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T140751468017Z-backend-live-start.log) |
| `backend-live-http-security` / `dart` | verify | F | 0.199 | Actionable after reviewed correction | [C3](#c3) | [raw](../../.dartnflutter/trial/raw/20261117T141131765474Z-backend-live-http-security.log) |
| `backend-live-http-security-retry` / `dart` | verify | P | 0.237 | Actionable after reviewed correction | [C3](#c3) | [raw](../../.dartnflutter/trial/raw/20261117T141138644213Z-backend-live-http-security-retry.log) |
| `generated-client-hardened-live` / `dart` | verify | P | 0.780 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141138605766Z-generated-client-hardened-live.log) |
| `backend-codegen-consistency` / `python3` | verify | P | 6.215 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141200400177Z-backend-codegen-consistency.log) |
| `backend-final-analysis` / `dart` | verify | F | 0.762 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T141206642678Z-backend-final-analysis.log) |
| `backend-final-analysis-retry` / `dart` | verify | P | 0.834 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T141229468974Z-backend-final-analysis-retry.log) |
| `backend-canonical-sort-tests` / `dart` | verify | P | 1.992 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141324078428Z-backend-canonical-sort-tests.log) |
| `backend-canonical-sort-analysis` / `dart` | verify | P | 0.757 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141326096195Z-backend-canonical-sort-analysis.log) |
| `backend-hardened-live-start` / `dart` | verify | P | 145.822 | Setup/service lifetime; readiness separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141130519852Z-backend-hardened-live-start.log) |
| `backend-canonical-live-security` / `dart` | verify | P | 0.223 | Finite live transport/boundary evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141414475993Z-backend-canonical-live-security.log) |
| `generated-client-final-live` / `dart` | verify | P | 0.720 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141414439482Z-generated-client-final-live.log) |
| `first-ui-analysis` / `flutter` | implement | F | 3.283 | Actionable after reviewed correction | [C2](#c2) | [raw](../../.dartnflutter/trial/raw/20261117T141546745165Z-first-ui-analysis.log) |
| `corrected-ui-analysis` / `flutter` | implement | F | 2.254 | Actionable after reviewed correction | [C2](#c2) | [raw](../../.dartnflutter/trial/raw/20261117T141627502769Z-corrected-ui-analysis.log) |
| `native-ready-analysis` / `flutter` | implement | F | 1.825 | Actionable after reviewed correction | [C2](#c2) | [raw](../../.dartnflutter/trial/raw/20261117T141703681605Z-native-ready-analysis.log) |
| `dnf-profile` / `node` | plan | P | 0.269 | Configured plan/state; execution separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141751947251Z-dnf-profile.log) |
| `dnf-task-create` / `node` | plan | P | 0.086 | Configured plan/state; execution separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141752244834Z-dnf-task-create.log) |
| `ui-analysis-clean` / `flutter` | implement | P | 2.360 | Actionable after reviewed correction | [C2](#c2) | [raw](../../.dartnflutter/trial/raw/20261117T141810633702Z-ui-analysis-clean.log) |
| `widget-scan` / `node` | ui | P | 12.036 | Semantic mapping/provenance; see coverage limits | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141851541216Z-widget-scan.log) |
| `macos-first-build` / `flutter` | verify | F | 8.696 | Actionable after reviewed correction | [C4](#c4) | [raw](../../.dartnflutter/trial/raw/20261117T141914277217Z-macos-first-build.log) |
| `backend-myday-sort-tests` / `dart` | verify | P | 3.179 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141942023056Z-backend-myday-sort-tests.log) |
| `backend-myday-sort-analysis` / `dart` | verify | P | 0.897 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141945231210Z-backend-myday-sort-analysis.log) |
| `ios-first-build` / `flutter` | verify | F | 4.009 | Actionable after reviewed correction | [C4](#c4) | [raw](../../.dartnflutter/trial/raw/20261117T141955643993Z-ios-first-build.log) |
| `navigation-analysis` / `flutter` | implement | F | 1.883 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142201066061Z-navigation-analysis.log) |
| `ui-acceptance-tests` / `flutter` | ui | F/F/F/P | 5.381, 5.672, 5.112, 5.474 | Actionable after reviewed correction | [C5](#c5) | [raw](../../.dartnflutter/trial/raw/20261117T143312385010Z-ui-acceptance-tests.log) |
| `backend-canonical-live-start` / `dart` | verify | P | 559.716 | Setup/service lifetime; readiness separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T141356360249Z-backend-canonical-live-start.log) |
| `backend-myday-live-security` / `dart` | verify | P | 0.267 | Finite live transport/boundary evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142334061157Z-backend-myday-live-security.log) |
| `generated-client-myday-live` / `dart` | verify | P | 0.878 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142334020488Z-generated-client-myday-live.log) |
| `ios-compatible-build` / `flutter` | verify | F | 20.646 | Actionable after reviewed correction | [C4](#c4) | [raw](../../.dartnflutter/trial/raw/20261117T142328899473Z-ios-compatible-build.log) |
| `macos-compatible-build` / `flutter` | verify | P | 31.977 | Actionable after reviewed correction | [C4](#c4) | [raw](../../.dartnflutter/trial/raw/20261117T142327751408Z-macos-compatible-build.log) |
| `catalog-analysis` / `dart` | ui | P | 4.868 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142523508852Z-catalog-analysis.log) |
| `ui-note-regression` / `flutter` | ui | P | 2.865 | Observed result retained; utility needs task context | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142554378492Z-ui-note-regression.log) |
| `iphone-target-build` / `xcodebuild` | verify | P | 31.558 | Actionable after reviewed correction | [C4](#c4) | [raw](../../.dartnflutter/trial/raw/20261117T142617552875Z-iphone-target-build.log) |
| `catalog-runtime-tests` / `flutter` | ui | F/P | 4.030, 3.608 | Actionable after reviewed correction | [C6](#c6) | [raw](../../.dartnflutter/trial/raw/20261117T142733006551Z-catalog-runtime-tests.log) |
| `catalog-help` / `node` | ui | P/P | 0.553, 0.186 | Observed result retained; utility needs task context | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144619841461Z-catalog-help.log) |
| `catalog-scan` / `node` | ui | P/P | 12.300, 10.403 | Semantic mapping/provenance; see coverage limits | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144620052211Z-catalog-scan.log) |
| `catalog-init` / `node` | ui | P/P | 12.079, 10.351 | Semantic mapping/provenance; see coverage limits | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144630482676Z-catalog-init.log) |
| `widgetbook-generate` / `node` | ui | P/P | 12.008, 10.460 | Semantic mapping/provenance; see coverage limits | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144640867209Z-widgetbook-generate.log) |
| `widgetbook-analysis` / `dart` | ui | P | 2.196 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143053429337Z-widgetbook-analysis.log) |
| `catalog-state-batch-tests` / `flutter` | ui | P | 3.679 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143052385570Z-catalog-state-batch-tests.log) |
| `interaction-final-analysis` / `flutter` | implement | F | 2.521 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T143105721323Z-interaction-final-analysis.log) |
| `widgetbook-navigation-test` / `flutter` | ui | F/P | 3.477, 3.023 | Actionable after reviewed correction | [C7](#c7) | [raw](../../.dartnflutter/trial/raw/20261117T143159576831Z-widgetbook-navigation-test.log) |
| `final-ui-analysis` / `dart` | ui | P/P | 1.683, 1.953 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144341838686Z-final-ui-analysis.log) |
| `mobile-accessibility-test` / `flutter` | ui | F/P | 2.703, 2.273 | Actionable after reviewed correction | [C5](#c5) | [raw](../../.dartnflutter/trial/raw/20261117T143811867460Z-mobile-accessibility-test.log) |
| `manual-reorder-test` / `flutter` | ui | F/F/F/P | 2.724, 2.639, 2.552, 2.309 | Actionable after reviewed correction | [C8](#c8) | [raw](../../.dartnflutter/trial/raw/20261117T143805453186Z-manual-reorder-test.log) |
| `widgetbook-runtime-dependency` / `flutter` | discover | P | 5.514 | Observed result retained; utility needs task context | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143544064768Z-widgetbook-runtime-dependency.log) |
| `native-print-analysis` / `flutter` | implement | F | 3.152 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T143633675410Z-native-print-analysis.log) |
| `unsplash-generate` / `serverpod` | implement | P | 6.044 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143633937689Z-unsplash-generate.log) |
| `pinned-serverpod-cli` / `flutter` | discover | P | 4.672 | Dependency/tool setup; selected graph retained | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143829111200Z-pinned-serverpod-cli.log) |
| `unsplash-unit-tests` / `dart` | verify | P | 1.261 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T143955940760Z-unsplash-unit-tests.log) |
| `unsplash-frontend-analysis` / `flutter` | implement | F | 2.967 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T143956455623Z-unsplash-frontend-analysis.log) |
| `unsplash-live-homepage` / `dart` | verify | F | 10.564 | Actionable after reviewed correction | [C11](#c11) | [raw](../../.dartnflutter/trial/raw/20261117T144029850170Z-unsplash-live-homepage.log) |
| `stable-ui-analysis` / `flutter` | implement | P | 2.519 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T144048491358Z-stable-ui-analysis.log) |
| `photo-preview-test` / `flutter` | ui | P | 2.470 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144108912762Z-photo-preview-test.log) |
| `unsplash-analysis` / `dart` | verify | P | 0.919 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144115620510Z-unsplash-analysis.log) |
| `unsplash-full-tests` / `dart` | verify | P | 1.646 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144208214324Z-unsplash-full-tests.log) |
| `ui-final-source-analysis` / `flutter` | verify | P | 2.700 | Actionable after reviewed correction | [C13](#c13) | [raw](../../.dartnflutter/trial/raw/20261117T144209668208Z-ui-final-source-analysis.log) |
| `unsplash-codegen-consistency` / `python3` | verify | F | 8.999 | Actionable after reviewed correction | [C10](#c10) | [raw](../../.dartnflutter/trial/raw/20261117T144209891111Z-unsplash-codegen-consistency.log) |
| `background-service-tests` / `flutter` | ui | F | 1.856 | Actionable after reviewed correction | [C9](#c9) | [raw](../../.dartnflutter/trial/raw/20261117T144257761085Z-background-service-tests.log) |
| `unsplash-codegen-pinned-repeat` / `python3` | verify | P | 5.806 | Actionable after reviewed correction | [C10](#c10) | [raw](../../.dartnflutter/trial/raw/20261117T144308816431Z-unsplash-codegen-pinned-repeat.log) |
| `unsplash-final-analysis` / `dart` | verify | P | 0.974 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144314654040Z-unsplash-final-analysis.log) |
| `background-source-analysis` / `flutter` | verify | P | 1.036 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144356843560Z-background-source-analysis.log) |
| `unsplash-live-homepage-retry` / `dart` | verify | P | 3.825 | Actionable after reviewed correction | [C11](#c11) | [raw](../../.dartnflutter/trial/raw/20261117T144428492502Z-unsplash-live-homepage-retry.log) |
| `backend-myday-live-start` / `dart` | verify | P | 1313.725 | Setup/service lifetime; readiness separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T142316079682Z-backend-myday-live-start.log) |
| `unsplash-client-analysis` / `dart` | verify | P | 0.560 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144510960319Z-unsplash-client-analysis.log) |
| `unsplash-live-http-boundary` / `dart` | verify | P | 0.233 | Finite live transport/boundary evidence | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144521793248Z-unsplash-live-http-boundary.log) |
| `unsplash-live-typed-client` / `dart` | verify | P | 2.817 | Actionable after reviewed correction | [C11](#c11) | [raw](../../.dartnflutter/trial/raw/20261117T144522115841Z-unsplash-live-typed-client.log) |
| `final-frontend-ui-tests` / `flutter` | ui | P | 5.477 | Declared behavior assertions; scope in log | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log) |
| `catalog-record-default` / `node` | ui | P | 26.667 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144651354466Z-catalog-record-default.log) |
| `catalog-record-custom` / `node` | ui | P | 26.323 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144718057252Z-catalog-record-custom.log) |
| `catalog-record-dark` / `node` | ui | P | 26.327 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144744419664Z-catalog-record-dark.log) |
| `final-icon-catalogs` / `swift` | implement | F | 3.609 | Actionable after reviewed correction | [C12](#c12) | [raw](../../.dartnflutter/trial/raw/20261117T144808975946Z-final-icon-catalogs.log) |
| `catalog-record-selected` / `node` | ui | P | 24.484 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144810777802Z-catalog-record-selected.log) |
| `catalog-record-active` / `node` | ui | P | 21.068 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144835297009Z-catalog-record-active.log) |
| `catalog-record-completed` / `node` | ui | P | 22.567 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144856399180Z-catalog-record-completed.log) |
| `native-test-analysis` / `flutter` | verify | P | 1.947 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144924616984Z-native-test-analysis.log) |
| `catalog-record-unchecked` / `node` | ui | P | 21.414 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144919001436Z-catalog-record-unchecked.log) |
| `catalog-record-checked` / `node` | ui | P | 23.614 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T144940450048Z-catalog-record-checked.log) |
| `final-icon-native-packaging` / `swift` | implement | P | 0.849 | Actionable after reviewed correction | [C12](#c12) | [raw](../../.dartnflutter/trial/raw/20261117T145004847035Z-final-icon-native-packaging.log) |
| `catalog-record-saving` / `node` | ui | P | 23.978 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145004104535Z-catalog-record-saving.log) |
| `macos-final-icon-build` / `flutter` | verify | P | 13.626 | Target/artifact evidence; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145020026902Z-macos-final-icon-build.log) |
| `ios-final-icon-build` / `python3` | verify | P | 13.392 | Target/artifact evidence; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145021188558Z-ios-final-icon-build.log) |
| `catalog-record-error` / `node` | ui | P | 22.413 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145028115587Z-catalog-record-error.log) |
| `catalog-record-search-empty` / `node` | ui | P | 24.150 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145050563820Z-catalog-record-search-empty.log) |
| `catalog-record-empty` / `node` | ui | P | 22.358 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145114748475Z-catalog-record-empty.log) |
| `catalog-record-photo` / `node` | ui | P | 23.333 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145137140863Z-catalog-record-photo.log) |
| `catalog-record-loading` / `node` | ui | P | 24.035 | Current exact named state evidence; scan overhead | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145200509551Z-catalog-record-loading.log) |
| `catalog-validate` / `node` | ui | P | 10.591 | Semantic mapping/provenance; see coverage limits | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145224587275Z-catalog-validate.log) |
| `generated-widgetbook-analysis` / `dart` | ui | P | 1.383 | Static diagnostics; runtime separate | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145341291397Z-generated-widgetbook-analysis.log) |
| `generated-widgetbook-navigation` / `flutter` | ui | P | 2.800 | Generated/schema coherence check or setup | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145341291397Z-generated-widgetbook-navigation.log) |
| `final-icon-pixel-compare` / `node` | ui | P | 0.238 | Actionable after reviewed correction | [C12](#c12) | [raw](../../.dartnflutter/trial/raw/20261117T145418305646Z-final-icon-pixel-compare.log) |
| `iphone-native-integration` / `flutter` | verify | P | 30.736 | Observed result retained; utility needs task context | None recorded | [raw](../../.dartnflutter/trial/raw/20261117T145418305645Z-iphone-native-integration.log) |
| `ipad-native-integration` / `flutter` | verify | F | 38.344 | Observed result retained; utility needs task context | [C14](#c14) | [raw](../../.dartnflutter/trial/raw/20261117T145709583454Z-ipad-native-integration.log) |

## Correction chains

### C1

**Agent test-author correction.** An unused test import produced an analysis warning. The intended generated-client-close test was added; focused analysis then passed. Labels: `state-analysis`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T140822361209Z-state-analysis.log).

### C2

**Implementation/API compatibility.** Remembered FilePicker instance/pickFiles/bytes APIs and leftover scaffold-auth imports failed actual analysis. Installed static pickFile/readAsByteStream APIs and the required imports replaced those assumptions. Labels: `first-ui-analysis`, `corrected-ui-analysis`, `native-ready-analysis`, `ui-analysis-clean`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T141810633702Z-ui-analysis-clean.log).

### C3

**Environment/lifecycle orchestration.** The first finite probe saw connection refused before the listener was ready. A readiness-aligned retry passed. Service uptime itself was not the check. Labels: `backend-live-http-security`, `backend-live-http-security-retry`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T141138644213Z-backend-live-http-security-retry.log).

### C4

**Native environment/target compatibility.** Scaffold deployment minima failed under Xcode 27 and selected plugins. The compatible macOS build passed. The generic iOS simulator route still failed its architecture condition; a selected iPhone destination compiled. Do not relabel the generic build as passed. Labels: `macos-first-build`, `ios-first-build`, `ios-compatible-build`, `macos-compatible-build`, `iphone-target-build`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T142617552875Z-iphone-target-build.log).

### C5

**Implementation and test-author corrections.** App assertions exposed unlabeled/undersized controls. Later coverage included sidebar/details targets. One intermediate Custom repeat tap targeted deliberately ignored child text; tapping CheckedPopupMenuItem corrected the test. Final frontend scope passed. Labels: `ui-acceptance-tests`, `mobile-accessibility-test`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log).

### C6

**Agent test-author correction.** The first 32 preview tests failed because a SemanticsHandle was disposed too late through addTearDown. try/finally disposal fixed the harness; 33 final builders now pass individual and grouped tests. Labels: `catalog-runtime-tests`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log).

### C7

**Agent test-author correction.** A leaf component opened its sole use case immediately. An extra click hit the modal barrier and dismissed it. The test now follows observed 3.23 navigation; final generated-entrypoint navigation passed. Labels: `widgetbook-navigation-test`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T145341291397Z-generated-widgetbook-navigation.log).

### C8

**Interaction implementation plus test-author correction.** The original row drag path did not persist order. An explicit handle supplied an unambiguous path. Two later hold/move variants still failed; the standard 120-pixel handle drag passed the actual persisted-position assertion. Failed gestures are retained; not every one is attributed to the app. Labels: `manual-reorder-test`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T143805453186Z-manual-reorder-test.log).

### C9

**Implementation validation mismatch.** Cached metadata accepted a user-info image URL that the fresh path rejected. Shared URL validation now covers image and attribution hosts, user-info and nonstandard ports. All 9 isolated background cases pass within the final frontend run. Labels: `background-service-tests`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T144602137176Z-final-frontend-ui-tests.log).

### C10

**Generator/tool graph compatibility.** Regeneration under a different resolved global graph changed formatting despite the same3.4.5 CLI version. Project-pinned generator execution and a repeat consistency comparison passed. Labels: `unsplash-codegen-consistency`, `unsplash-codegen-pinned-repeat`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T144308816431Z-unsplash-codegen-pinned-repeat.log).

### C11

**External source/freshness criterion.** The first run returned a working cached fallback for its second selection, so its grader correctly refused a fresh-homepage claim. Later live/typed-client checks observed distinct fresh homepage selections. No permanent network availability is implied. Labels: `unsplash-live-homepage`, `unsplash-live-homepage-retry`, `unsplash-live-typed-client`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T144522115841Z-unsplash-live-typed-client.log).

### C12

**Native artifact conversion.** Initial native image conversion failed. The corrected packaging produced 33 asset-catalog entries; separate build and pixel-comparison checks passed for the selected icon. This is asset-scoped approval/evidence. Labels: `final-icon-catalogs`, `final-icon-native-packaging`, `final-icon-pixel-compare`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T145418305646Z-final-icon-pixel-compare.log).

### C13

**Authored-code lint/configuration correction.** Retained diagnostics include missing braces, a null-aware-element suggestion and a lib import of Widgetbook while it was only a dev dependency. Authored code/configuration was corrected and later scoped analysis passed. Labels: `backend-final-analysis`, `backend-final-analysis-retry`, `interaction-final-analysis`, `native-print-analysis`, `unsplash-frontend-analysis`, `stable-ui-analysis`, `ui-final-source-analysis`. Latest linked result: [raw](../../.dartnflutter/trial/raw/20261117T145341291397Z-generated-widgetbook-analysis.log).

### C14

**Agent native-test harness correction; final execution pending.** The first iPad native run failed because a text finder matched the title still inside the editable composer before the RPC save finished. The lead traced that race and changed the wait to a rendered Text task row. The failed 38.344s attempt remains in the table; a successful iPad application/runtime result is not inferred before the corrected run completes. Source: [native test](../../flutter_todo_flutter/integration_test/app_test.dart) and the retained raw event above.

## Calls and skills outside the command table

The actual six dnf skill files/launchers supplied inspection, planning, verification, UI, compatibility and benchmark-discovery instructions. Reading/activation alone has no measured benefit. CLI installed-source lookup resolved Riverpod lifecycle and FilePicker assumptions; inspect/profile/task calls made configuration explicit; runtime record/validate supplied current named evidence. History/migration assessment did not execute a dependency upgrade. Benchmark help/discovery did not launch a paid model session; the independently managed pilot remains outside this project.

The Effective Dart diagnostic query exited 0 in 0.160s of tool-observed process time and missed the requested naming/docs/import/modifier rules. It is reported by the [source review](effective-dart-review.md), outside the wrapper JSONL. One failed query does not measure corpus recall.

[Figma tool events](../design/tool-events.json) have unknown individual-call times except the explicitly recorded 4.36s Python certificate failure. Library/font discovery, component construction, editable fallback screens and later layout repair supplied useful design coordination. Python HTTPS trust-store failure, a verified SVG filename-case 404 and SF Pro editability failure were retained; installed curl with standard validation, corrected repository casing and explicit Inter fallback were the respective corrections. No certificate verification was bypassed. The authored board still differs from native typography. Selected-icon approval and pixel comparison remain separate from whole-UI approval.

Agent orchestration separated backend, data, UI/test and research ownership. Native CUA observed real macOS task/step interaction. Individual agent/tool-call times, human comprehension, and vendor usage were not comprehensively observable. Neither parallelism nor the existence of more tools establishes a causal speed improvement.
