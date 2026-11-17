# Issue 9 implementation and validation plan

Requested 18 November 2026: finish the remaining local parity work, verify macOS/iPhone/iPad, publish the next source-only release, and show the iPad landscape inspector automatically. The user chose the first task's details as the landscape default.

## Acceptance and lanes

- Align aggregate attachments with Microsoft's published/installed 25 MB contract; define implementation bytes explicitly, test exact boundary/aggregate failure and real HTTP/PostgreSQL roundtrip. Backend lane owns endpoint/configuration tests; frontend limit and documents stay with root.
- Support task-to-list dragging with distinct move/reorder gestures, including touch navigation to a destination; retain context menus, selected-task drafts and task identity. Root owns UI, responsive inspector and regression/native flows.
- Route notification taps, including cold launch, to the stored task's owning list/details. Use actual OS-delivered notifications on all three targets; distinguish denied permission, pending, delivered and tapped. Service/testing lane owns plugin code, root wires app navigation and native permission UI.
- Observe the installed Microsoft macOS layout and use official iOS reference material for controlled comparisons. Keep private reference captures local. Figma coordination and source/runtime evidence remain separate from human visual approval.
- Exercise native print interfaces and one synthetic physical print job where the available hardware can accept it. The configured Brother DCP-1610W has no AirPrint support; OS-panel acceptance, queue completion and observed paper output must remain distinct. No claim is made before executing the probe.
- Verify real iPad landscape dimensions in Device Hub, showing the first visible task selected and its right inspector expanded; empty lists retain a useful empty inspector. Closing/reopening and portrait transitions must remain usable.

## Delivery

Use `codex/issue-9-parity`, preserve the existing databases and selected icon, and retain v1.0.0 evidence as historical. Complete focused regressions and source review before refreshing every-widget evidence. Record actual simulator/native/print/reference outcomes, update documents/screenshots, then publish a tagged 1.1.0 source ZIP through an issue-linked PR. No application binaries are released. Any human approval or hardware condition that cannot be completed is reported explicitly, never promoted to a pass.

## Accepted scope update

The user subsequently asked to skip physical printing because they could not test the printer. No further hardware jobs are required. Retain the earlier native-interface/PDF outcomes and queue cancellation as narrower evidence; physical paper output remains unverified.
