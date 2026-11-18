# Round 9 — Widgetbook and declaration/state catalog

Measured **18 November 2026**, starting at `fe178d8572b48889661aa0e6c4fd9b69d84e9c11`. **Result: 42/42 declarations registered, 78/78 mapped cases verified, and 14/14 newly recorded state tests passed.** The baseline already passed; this round refreshes execution evidence. No application fix or defect issue was needed.

## Check first, then refresh

Fresh validation of the existing catalog exited **0** in **10.596s**, with no stale mappings/evidence, missing declarations or runtime findings. Validation checks prior report identities; it does not rerun their tests. The full [rebuild script](../../flutter_todo_flutter/tool/catalog/rebuild.py) then performed new scans, regenerated/formatted Widgetbook, recorded fourteen exact named tests and validated the resulting catalog. The wrapper exited **0** in **356.816s**. Times include semantic-scan/tool overhead and are not production performance measurements.

The installed `/dnf-ui` launcher invokes DartNFlutter **0.1.0**. Its semantic helper uses **analyzer 9.0.0**, distinct from the app-resolved analyzer 10.0.1 used in Round 7. Flutter remains **3.41.7**, Dart **3.11.5**, Widgetbook **3.23.0**. No installation, resolution, toolchain or skill change was performed.

Inventory engine is `dart-analyzer`, `complete: true`, with **0 gaps**: **20 widget classes + 22 widget builders**. Fingerprint: `25f252d450562fc64e760a53435dd3a8254bd967333d6c1f090e97dc564554a4`. The semantic scan lists fifteen source files (twelve maintained app files and three test-driver files); its exclusions/harness handling and declaration population differ from Round 7's runtime metrics inventory. Private widgets remain private and use the [in-library preview harness](../../flutter_todo_flutter/lib/ui/catalog_previews.dart).

## Actual recordings

Each command selects exactly one `catalog state <state>` test in [catalog_test.dart](../../flutter_todo_flutter/test/ui/catalog_test.dart). Together the fourteen tests exercise **35 named previews**. **78 is the mapped case count, not 78 independent tests**: shared owner-context previews cover multiple declarations. Each report has matching before/after fingerprints, exit 0 and a raw-machine-log SHA-256 verified again during review.

| State | Exact matched test result | Recorded test duration |
| --- | --- | ---: |
| `active` | 1 passed / 0 failed / 0 skipped | 12.218s |
| `checked` | 1 passed / 0 failed / 0 skipped | 11.835s |
| `completed` | 1 passed / 0 failed / 0 skipped | 12.932s |
| `custom` | 1 passed / 0 failed / 0 skipped | 11.360s |
| `dark` | 1 passed / 0 failed / 0 skipped | 12.321s |
| `default` | 1 passed / 0 failed / 0 skipped | 12.500s |
| `empty` | 1 passed / 0 failed / 0 skipped | 11.605s |
| `error` | 1 passed / 0 failed / 0 skipped | 12.643s |
| `loading` | 1 passed / 0 failed / 0 skipped | 11.755s |
| `photo` | 1 passed / 0 failed / 0 skipped | 12.317s |
| `saving` | 1 passed / 0 failed / 0 skipped | 12.287s |
| `search-empty` | 1 passed / 0 failed / 0 skipped | 11.895s |
| `selected` | 1 passed / 0 failed / 0 skipped | 12.283s |
| `unchecked` | 1 passed / 0 failed / 0 skipped | 11.696s |

Tests assert visible states, selected/checked semantics, relevant interactions and absence of Flutter exceptions; hit-test warnings are fatal. They use synthetic fixtures/fake repositories at 1100×800 logical pixels. PostgreSQL, native devices, photos from the network and printing are outside these recordings. New references use the unique run directory `.dartnflutter/evidence/catalog/20261118T011825Z-25f252d45056/`; older reports remain retained.

## Meaning and limits

Every declaration identified by this inventory has a registered preview and every configured state mapping has valid execution evidence. The regenerated/formatted `lib/widgetbook.dart` is byte-for-byte unchanged. Only `widget-catalog.json` changes among the **339 preexisting tracked inputs** monitored by the wrapper. The source fingerprint stays unchanged because this is a fresh execution of the same production source.

The validator reports design `provided: false`, `complete: false`. Authored Figma links are coordination material, without human visual approval or an image comparison. Selected semantics assertions are not a complete accessibility audit. Native interactions/device coverage, notification activation, goldens and physical printing remain separate. This pass does not complete those dimensions.

## Reproduction and workflow

From the repository root with the installed/resolved launcher:

```sh
node /Users/worajedt/.codex/skills/dnf-ui/scripts/dnf.mjs widgets validate \
  --root "$PWD/flutter_todo_flutter" \
  --catalog "$PWD/flutter_todo_flutter/widget-catalog.json" \
  --out "$PWD/.dartnflutter/quality/catalog-baseline.json"
python3 flutter_todo_flutter/tool/catalog/rebuild.py --record
```

The first command scans current source and checks existing references. The second writes mappings/generated registration, formats that entry and runs fourteen machine-output tests through [trial_run.py](../../tool/trial_run.py). Keep production source fixed while recording; an unknown declaration requires a reviewed harness/mapping. After production Dart changes, repeat fresh scan/record/validation. Test files outside the semantic source scope do not automatically change the production fingerprint.

Raw evidence is ignored and local: a fresh clone must record its own evidence before claiming validation. Preserve failed and successful runs separately. No unapproved design was imported, golden baseline updated, threshold added or later visual/profiling/CI round executed. Rounds 11–13 remain deferred.

## Evidence and delivery

Ignored `.dartnflutter/quality/round-09-20261118T011721Z-fe178d8572b4/` retains baseline/refresh argv, cwd, UTC, exits/durations, stdout/stderr, all tracked before/after manifests and review/digest results. The frontend `.dartnflutter/evidence/catalog/` directory retains the immutable catalog snapshot, final report and fourteen report/raw-log pairs; wrapper logs remain in root `.dartnflutter/trial/`. Final catalog report SHA-256: `8396a7653e1ab673030620ace4817d62e98a8f5dfcd13757cd586b13f201578e`.

Runtime Dart, tests, dependencies/SDK, backend/data, sibling toolchain and `/dnf-*` skills stayed unchanged. The report/guide/catalog update follows the reviewed documentation/catalog PR path; [tracking](../trial/github-tracking.md) records the round. Root self-review is not an independent GitHub approval.
