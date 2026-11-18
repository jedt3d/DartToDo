# Round 8 — app-specific custom-lint assessment

Assessed **18 November 2026**, with the check bound to `94bff06d0ec8c09790de0f7a1f1dbaed276d487f`. **Decision: no custom lint is justified by the inspected evidence.** This conditional round is complete as an assessment. No `custom_lint` plugin was installed or executed; a custom-lint pass is not claimed.

## Check first

From the application repository root:

```sh
flutter analyze --no-pub --fatal-infos --fatal-warnings
```

Flutter **3.41.7** / Dart **3.11.5** reported **No issues found**, exit **0**, in **4.133s** including process overhead. All **337 tracked before/after input hashes matched; stderr was empty. This is the standard workspace analyzer with the three packages' existing options, not a new app-rule engine.

## What was assessed

| Candidate constraint | Existing enforcement / evidence inspected | Decision |
| --- | --- | --- |
| Native-only loopback API; reject browser origins, rebinding hosts and wrong methods | [server.dart](../../flutter_todo_server/lib/server.dart), [five request-policy tests](../../flutter_todo_server/test/unit/local_requests_test.dart) | Keep centralized middleware and behavior tests; a syntax rule cannot establish the actual socket/listener boundary. |
| 25 MiB aggregate decoded attachments; preserve bytes and existing task state on failure | [task endpoint](../../flutter_todo_server/lib/src/todo/todo_endpoint.dart), [detail UI](../../flutter_todo_flutter/lib/ui/task_details.dart), [eight attachment widget regressions](../../flutter_todo_flutter/test/ui/attachments_test.dart), [HTTP probe](../../flutter_todo_server/tool/attachment_http_test.dart) | Test the byte boundary and failure behavior; no repeated literal/policy drift was established in this inspection. |
| Allowed photo hosts, capped responses, redirects/timeouts and client disposal | [photo service](../../flutter_todo_server/lib/src/background/unsplash_service.dart), [transport](../../flutter_todo_server/lib/src/background/unsplash_transport.dart), [service tests](../../flutter_todo_server/test/unit/unsplash_service_test.dart), [transport tests](../../flutter_todo_server/test/unit/unsplash_transport_test.dart) | Keep policy in the transport/service and check behavior with deterministic fixtures. |
| Strict typing and intentional async/resource ownership | Three `analysis_options.yaml` files; official strict-casts/inference/raw-types and `unawaited_futures`, `discarded_futures`, `cancel_subscriptions`, `close_sinks` from Round 1 | Use the configured standard rules before inventing overlapping app rules. A clean analyzer does not prove every resource path. |

These implementation/test sources were read; the tests were not rerun in this round. Their actual execution/coverage belongs to [Rounds 3–6](README.md). No static search or clean analyzer certifies security, correct runtime limits, UI fidelity or platform acceptance. The absence of a demonstrated repeated violation is a decision to avoid an unsupported rule, not a claim that future mistakes are impossible.

Round 7's large widget builders and nested parser are maintainability observations. A custom lint would not automatically simplify them and a framework alone would supply no app-specific rule.

## Workflow and configuration

Keep the existing standard analyzer command in everyday editing and PR validation. Revisit custom lints only after a concrete repeated violation is documented and a static rule would catch it more effectively than centralized code or a behavior test. Open an issue containing positive/negative examples, exact detection scope, generated exclusions, false-positive policy, compatibility/maintenance cost and rule tests before implementing a plugin. Assess SDK/library compatibility in that scoped change; no plugin API or dependency version is guessed here.

No actionable failing finding required a fix issue. This report/guide update follows the documentation PR path. No SDK/dependency/lockfile, app source, standard rule, threshold, CI job, toolchain or `/dnf-*` skill changed. ProDOS was not used. Rounds 11–13 remain deferred by the user.

Ignored raw evidence: `.dartnflutter/quality/round-08-20261118T011449Z-94bff06d0ec8/`, with premeasurement scope, argv/cwd/UTC/exit/duration, stdout/stderr and all tracked input SHA-256 manifests. Analyzer stdout SHA-256: `d67157da8a75718c01bc7b8c05f83fc5f1b0bc045a06ba34a291b87e83b783e1`. The [quality guide](README.md) and [tracking](../trial/github-tracking.md) record the conditional result and delivery.
