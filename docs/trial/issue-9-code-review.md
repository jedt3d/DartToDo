# Issue 9 code review

Reviewed the feature branch against v1.0.0 and the scoped delta after `86371bb5301171d925a9b67ab51869c100c9dfe3`, using repository instructions, architecture/security rules, [issue #9](https://github.com/jedt3d/DartToDo/issues/9) and the [acceptance plan](issue-9-plan.md). Final implementation checkpoint: `3dd5c36fd89be78f9247bb75f769500f2dcd1c83`. Standards and Spec reviews ran independently; native/capture inspection was separate.

## Standards

Three P2 findings at the earlier checkpoint were corrected:

- Destination append positions were calculated before the serialized mutation. `TodoController.moveTask` now validates and calculates inside `_enqueue`; delayed reverse-ID moves independently verify arrival positions 5 and 6.
- The guide overstated destination navigation by the existing details dropdown. It now distinguishes dropdown and drag behavior.
- The capture harness classified wide phones by width. It now checks logical shortest side; the strict driver requires completed flow evidence and every expected PNG.

The subsequent scoped delta review found no further documented-standard violation or smell-based change to recommend. Formatting/analysis checks and whitespace validation are separate executed gates.

## Spec

No new implementation mismatch or material scope creep was found in attachments, cross-list dragging, reminder routing or automatic iPad landscape details. Account/cloud/Outlook integration remains excluded. The chosen icon is preserved. Source-only publication is maintained with no schema migration.

Acceptance limits remain separate: macOS OS notification activation is unverified through the permitted tool surface; controlled visual comparison/human approval is unavailable. Physical printing was skipped by the user. iPhone/iPad actual terminated-app notification launch has since been observed successfully.

## Native and capture inspection

Independent inspection found all 120 PDF markers unique and in order across seven pages, with final artifact/source hashes matching. The Mac and iPad landscape captures showed readable controls without visible clipping. Strict capture logs and the 21-PNG inventory agree. macOS captures show the actual running Flutter surface; OS chrome is excluded. No physical paper output or full Figma pixel/font parity is inferred.

Standards: 3 earlier findings resolved, 0 new delta findings. Spec: 0 implementation defects; 2 explicitly unverified acceptance dimensions, with hardware printing excluded at user request.
