# Round 2 — Dart formatter

**Result: PASS — all 73 tracked Dart files require 0 formatting changes.** The baseline was already clean. One workflow gap was found: the existing formatter gate omitted the server launcher. [Issue #16](https://github.com/jedt3d/DartToDo/issues/16) tracks the target-list correction and linked PR; this round changes no Dart source or formatting policy.

Final routine-gate measurement: **18 November 2026, 04:27:47 Asia/Bangkok**, **exit 0**, **0.236s wall time**. The complete explicit-file check separately confirms 73 `Unchanged` records. The original 72-file check and the broader baseline are both retained before the fix.

## Source, tool and configuration

| Binding | Recorded value |
| --- | --- |
| Application | `jedt3d/DartToDo`, local checkout `FlutterToDo` |
| Base HEAD | `fb501717b1615165076dc8efe222df8198044458` |
| Baseline branch/state | `main`, clean, including non-ignored untracked files |
| Implementation branch | `codex/issue-16-formatter-round-02` |
| Flutter / selected Dart | `3.41.7` stable / `3.11.5`, macOS arm64 |
| SDK revision | `c70f78e7d682c158c15ca0c26c729b3ccb932284` |
| Executed formatter version | `dart format --version`: **dart_style 3.1.4** |
| Workspace dependency named `dart_style` | **3.1.7**; separate from the SDK-bundled executable |
| Package language versions | Frontend `3.11`; backend/client `3.8`, from shared package resolution |
| Trailing commas | `formatter.trailing_commas: preserve` in all three packages |
| Page width | No explicit package/file override; installed CLI target default **80** |
| Per-file format/language directives | No format-control/width markers or `@dart` overrides found in the 73 sources |

The [frontend](../../flutter_todo_flutter/analysis_options.yaml), [backend](../../flutter_todo_server/analysis_options.yaml) and [client](../../flutter_todo_client/analysis_options.yaml) options were read, together with their inherited lint includes. The includes supply no additional formatter settings. Root/ancestor options presence and absence, manifests, lockfile and shared resolution were recorded; no dependency resolution or upgrade was performed. No command-line page-width, trailing-comma, language-version or experiment override was supplied.

The installed verbose CLI help was verified before measurement. `--output=none` discards formatted output instead of overwriting source; `--set-exit-if-changed` returns 1 if formatting changes would be needed; `--show=all` adds visited-file names for inventory reconciliation. These are separate output/reporting choices, not stronger style rules. See the [official formatter documentation](https://dart.dev/tools/dart-format). SDK-local help and the measured executable take precedence over newer online examples.

## Check first: baseline and final results

All runs used the application repository root. Wall time includes command startup/shutdown; the formatter's own duration is retained separately.

| Evidence stage | Formatter-reported files | Would change | Exit | Wall time | Formatter time |
| --- | ---: | ---: | ---: | ---: | ---: |
| `baseline-current` | 72 | 0 | 0 | 0.243s | 0.17s |
| `baseline-all` | 73 | 0 | 0 | 0.223s | 0.16s |
| `final-current` | 73 | 0 | 0 | 0.236s | 0.17s |
| `final-all` | 73 | 0 | 0 | 0.223s | 0.16s |

Both `*-current` runs execute the formatter argv extracted from `tool/verify.py`; no other command in that compound runner was executed. The baseline used its original nine target directories; the final gate uses ten. Both `*-all` runs pass all 73 sorted tracked Dart paths explicitly, with `--show=all`. The exact expanded argv is in each retained `result.json`.

Final routine formatter command:

```sh
dart format --output=none --set-exit-if-changed \
  flutter_todo_flutter/lib \
  flutter_todo_flutter/test \
  flutter_todo_flutter/integration_test \
  flutter_todo_flutter/test_driver \
  flutter_todo_server/bin \
  flutter_todo_server/lib \
  flutter_todo_server/test \
  flutter_todo_server/tool \
  flutter_todo_client/lib \
  flutter_todo_client/tool
```

Reproduce the explicit tracked-file inventory check from the repository root, preserving the formatter's exit status:

```sh
python3 - <<'PY'
import subprocess
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', '*.dart']).decode().split('\0')
argv = ['dart', 'format', '--output=none', '--set-exit-if-changed', '--show=all']
raise SystemExit(subprocess.call(argv + [path for path in paths if path]))
PY
```

No formatter write mode was used. The final complete-check summary is:

```text
Formatted 73 files (0 changed) in 0.16 seconds.
```

Here, the word `Formatted` is the tool's summary label; `--output=none`, 73 `Unchanged` records, and before/after source hashes establish that no source was rewritten. Standard error was empty for every run. Changed-file distributions are empty for each package and file; the formatter does not supply analyzer-style rule/severity counts, complexity metrics or an overall quality score.

## Scope, generated files and the finding

| Package | Tracked Dart files | Hand-maintained | Serverpod-generated | Generated Widgetbook entrypoint | Routine gate before → after | Would change |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Frontend | 33 | 32 | 0 | 1 | 33 → 33 | 0 |
| Backend | 26 | 14 | 12 | 0 | 25 → 26 | 0 |
| Client | 14 | 3 | 11 | 0 | 14 → 14 | 0 |
| **Total** | **73** | **49** | **23** | **1** | **72 → 73** | **0** |

Ownership and target counts are inventory observations, not formatter-provided metrics. The 23 Serverpod files carry generated headers; [Widgetbook's entrypoint](../../flutter_todo_flutter/lib/widgetbook.dart#L1) has its own generated header and producer in the [catalog rebuild script](../../flutter_todo_flutter/tool/catalog/rebuild.py). The preview harness is hand-maintained. There were no additional non-cache application Dart files outside the tracked inventory.

All 24 generator-owned files were checked and already matched the formatter. The backend/client analyzer exclusions still match 23 Serverpod files, but the formatter runs visited them. Analyzer exclusion and formatter scope are therefore separate in this measured workflow. The analyzer report's 50 non-excluded paths include the generated Widgetbook entrypoint; this report separately classifies 49 hand-maintained plus 24 generator-owned files. Generated output was not hand-edited or regenerated.

**Finding: one omitted path, not a formatting defect.** The [baseline verification target list](https://github.com/jedt3d/DartToDo/blob/fb501717b1615165076dc8efe222df8198044458/tool/verify.py#L15) included backend `lib`, `test` and `tool`, but not `bin`. Consequently, [the server launcher](../../flutter_todo_server/bin/main.dart#L1) was outside that routine check even though its contents were correctly formatted. The smallest fix adds **`flutter_todo_server/bin`** to the [existing list](../../tool/verify.py#L15). No other verification commands, formatter options or runtime behavior changed.

After the fix, the directory target set covers the current 73-file inventory and its extracted formatter command reports 73 files, 0 changes, exit 0. The explicit list still visits each tracked file exactly once. The gate remains an explicit directory list: future Dart directories need a target/inventory review rather than an assumption that every new path is covered.

## Verification and limits

All **94 recorded formatter inputs** were unchanged during each measurement. Across baseline and final measurements, the sole input change is the intended `tool/verify.py` target addition. Every Dart source hash remains identical to the baseline, including all generated files; package policy, manifests, lockfile, shared resolution and SDK inputs are unchanged.

The verification runner was syntax/AST checked and its formatter argv was executed independently. Other checks in that script were confirmed unchanged. Report links, command reproduction, counts, hashes and the intended Git diff were reviewed. No new unit test was added for a one-path target-list change; the actual expanded gate and inventory comparison verify it directly.

The formatter parsed test/driver files, including printing-related source, without executing their bodies. The combined verification suite, analyzer, unit/widget/database/native/printing tests, code generation, widget recording, coverage, profiling and CI were **not run in this round**. Production Dart did not change, so no widget-state refresh was required. Earlier runtime/analyzer/release evidence remains a separate dated checkpoint.

A clean formatter does not prove type safety, runtime correctness, test coverage, performance, or generated-code consistency with generator inputs. No hook or CI job was installed. The DartNFlutter toolchain and `/dnf-*` skills are unchanged. Round 3 or any later formal tool round has not started; the user chooses the next tool.

## Retained evidence and delivery

Local raw evidence is ignored by `.gitignore`, not published with this report:

```text
.dartnflutter/quality/round-02-20261117T212625Z-fb501717b161/
```

`identity.json` records source/state/executable identity; `scope.json` holds the complete file inventory, ownership, original argv and omission. `configuration-audit.json` records configuration observations. Each of the four measurement directories contains original stdout/stderr, argv/timing/exit metadata, and before/after path/size/SHA-256 manifests. `tracked.before.json` preserves the starting tracked-file hashes. CLI help/versions and the inspection-helper output are retained separately; the helper's previously documented workspace-resolution limitation is not treated as missing root resolution.

The 94-input manifest covers all 73 Dart sources, relevant configuration/manifests/lockfile, shared resolution, inherited option files, the verification runner and SDK executable/snapshots. Reports and ignored raw evidence are outside those inputs. `validation.json` and `SHA256SUMS` record the final audit; the issue/PR is the authority for delivery status.

| Selected SHA-256 binding | Digest |
| --- | --- |
| Baseline input manifest | `fd0d881d5c7ea990589525875afc0fca7028ee5c3306cb177022dbd4d7b619d6` |
| Final input manifest | `a01ecee4b9515c89ff263fcbcec073db0f0697a604c28b73efe0a44d4f4b7310` |
| Baseline complete-file stdout | `e4ca30f9c00d7801c51e628fa4821b437ee15401b0fed476c4860f013a919ce4` |
| Final routine-gate stdout | `a61b4328419626cd1c4693844586d7bc0dd220b8b48909666d496c0f34740321` |
| Final complete-file stdout | `e4ca30f9c00d7801c51e628fa4821b437ee15401b0fed476c4860f013a919ce4` |
| Empty stderr for every run | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Unchanged root lockfile | `0a22c1b1cba7c78c39fc7c37952d3e2c992e401e2a93580e8d14b9e4d8b92406` |

The [quality-tools guide](README.md) describes configuration, cadence and later proposed tracks. [Issue #16](https://github.com/jedt3d/DartToDo/issues/16) records the coverage-gap fix, verification and linked PR under the documented issue → review/verification → merge → closure workflow. The earlier [Analyzer Round 1 report](01-dart-analyzer.md) is preserved unchanged.
