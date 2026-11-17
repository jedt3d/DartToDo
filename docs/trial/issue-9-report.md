# Issue 9 verification report · 1.1.0

DartToDo `1.1.0+2` completes the implemented local interaction work from [issue #9](https://github.com/jedt3d/DartToDo/issues/9), with current macOS, iPhone and iPad checks and 21 real-app screenshots. The source is reviewed in [PR #10](https://github.com/jedt3d/DartToDo/pull/10) and associated with [source release v1.1.0](https://github.com/jedt3d/DartToDo/releases/tag/v1.1.0). GitHub records the publication timestamp, final tagged commit and attached source ZIP. No application binaries are included.

Updated 18 November 2026 (Asia/Bangkok); retained command timestamps use 17 November UTC. The implementation checkpoint is `3dd5c36fd89be78f9247bb75f769500f2dcd1c83`. [Selected verification metadata](issue-9-verification.json) binds the implementation files, evidence digests and catalog fingerprint; the [screenshot manifest](../screenshots/manifest.json) binds captures to their actual source. The [v1.0.0 report](final-report.md) remains historical. Raw logs, PDFs and private reference captures stay local.

## Recorded results

| Area | Result | Evidence boundary |
|---|---|---|
| Finite project verification | **Passed** in 29.556 seconds: 163 frontend tests, 51 backend tests and one separate real-HTTP attachment test. | Formatting, fatal-info analysis, generated-protocol consistency, generated-client live smoke and local HTTP security smoke passed. |
| Current native core workflows | **Passed: 2/2 each** on macOS, iPhone simulator and iPad simulator, in 22.066, 33.059 and 27.991 seconds. | Real task/notes/steps/importance/completion persistence and cross-list drag, with independent backend readback; after the queue correction. |
| OS notification delivery | **Passed** on all three targets. | Native delivered-notification evidence is separate from a stored reminder date. |
| Actual notification activation | **Passed** on iPhone/iPad, including normal-app cold launch; **unverified** on macOS through the permitted UI tool surface. | Each simulator's old app process was stopped before its due date. Activating the real OS notification started a new process and opened the correct owning list and task details. Only synthetic fixtures were removed afterward. |
| Native printing interface | **Passed** on all three targets before the user's skip instruction. | Strict drivers observed native forwarding and return. Preview/cancellation or queue submission does not establish paper output. |
| Long-list PDF | **Passed:** all 120 unique synthetic task markers in order across seven pages. | Final macOS native PDF: 17,835 bytes, SHA-256 `098c8d58163b10c8ff7cd7408cb5642ec3ed9235c691a5e99c5931d37d660bc9`; source hashes match. Short three-task preview was one page. |
| Physical paper output | **Skipped at the user's request.** | Earlier Mac trial job 64 remained “Looking for printer”; only that one-page/one-copy job was canceled at 18:00:40 UTC. Phone/tablet preview sheets were canceled without a selected printer. No paper output is claimed and no further hardware tests were run. |
| Current widget catalog | **Passed: 42/42 declarations, 78/78 cases, 14 state groups.** | Stable run `20261117T181404Z-45979cc9af7c`, fingerprint `45979cc9af7cc0cd7db518db49196016909b85da218d3b72bb431d1af91d8cca`. Runtime coverage does not establish visual approval. |
| Native screenshots | **Passed: 21 original PNGs.** | Mac 5, iPhone 5, iPad portrait 5, iPad landscape 6. [Landscape automatic inspector](../screenshots/ipad-landscape-auto-details.png) is 2420×1668. Capture methods and source/PNG hashes are in the manifest. |
| Source inventory | **Passed.** | Original source/assets, docs, synthetic screenshots and selected icon; excludes app binaries, private configuration, raw evidence and imported Microsoft photographs. The GitHub release supplies the final downloadable archive digest. |

## Implemented behavior

Attachments total at most **25 MiB (26,214,400 decoded bytes) per task**, an explicit local mapping of the reference app's marketed “25 MB” label. A 40 MiB request envelope accommodates base64/JSON overhead. Exact-cap, over-cap and aggregate rejection checks pass, including a generated-client real HTTP/PostgreSQL roundtrip. No database schema migration is added.

The task move handle is separate from manual reordering. A touch long press reveals Lists on compact screens; dropping onto an active destination preserves task identity/content and opens the destination/details. Destination validation and append positions resolve inside the mutation queue against the latest snapshot. The detail dropdown retains its existing view behavior.

Wide iPad landscape automatically opens the first visible task's inspector. Empty lists show a useful empty inspector; explicit closure persists until navigation or a new landscape entry. Phone landscape retains phone navigation. Details, Suggestions and Lists have responsive checks for keyboard-reduced space and failed-save drafts.

Reminder responses resolve the stored task's actual owning list/details after data loads and pending edits finish. Strict versioned payloads, duplicate occurrences, missing/deleted tasks, loading failures and callback races have regression coverage. Actual iOS cold-launch observations complement those unit checks.

Native printing exposed a missing macOS entitlement and clipped long-list text. Debug and Release now permit printing while retaining App Sandbox. AppKit sizes the text view from full laid-out content; minimum height 1 avoids the short-case blank page. The user subsequently skipped physical printing; the feature remains available.

## Review, design and remaining acceptance

The [two-axis review](issue-9-code-review.md) records three resolved Standards findings and no further delta finding. Spec review found no implementation mismatch or material scope creep. Current implementation/native/source evidence is separate from the two remaining acceptance items: actual macOS notification activation and human visual approval.

The [editable Figma tablet frame](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-347) is 1210×834 logical pixels, with inspector `28:347`, 182 descendants and 51 instances. There are no flattened UI rasters. Figma uses Inter; native UI uses Apple system typography. [Figma evidence](../design/figma-parity-9.json) marks typography unverified and human approval false. The [official mobile reference](issue-9-reference-research.md#microsoft-published-mobile-visual-references) is marketing artwork rather than a matched full-screen baseline. The selected bordered Folded Check icon is approved and applied; this does not imply approval of every screen.

Issue #9 remains open for these explicitly unverified dimensions. Physical paper testing is excluded at the user's request. These limits do not turn a runtime/build pass into exact Microsoft pixel parity, physical-device distribution, notarization or hardware-output certification.

## Toolchain observations

The project exercised inspection, planning, UI catalog, verification, native macOS, Figma coordination, parallel scoped implementation/reviews and PR workflows. Strict native drivers, immutable catalog run paths, source-bound screenshot checks and independent PDF marker validation are delivered in this application repository. [Next-round proposals](next-round-improvements.md) capture the observed reusable improvements; the sibling DartNFlutter tool source, benchmark fixtures and installed skills were preserved for a separately verified toolchain round.

The failed mid-edit catalog attempt and timed-out native attempts remain retained as negative evidence; they are superseded only by the named successful runs. Observed command durations are not total development time. No matched human baseline, model cost or causal productivity result is available.
