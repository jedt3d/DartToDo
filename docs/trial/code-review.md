# Two-axis source review

Reviewed fixed candidate `d997b9ea8b7328fe2d2a72d7dcc9203c77d790c2` against the remote's original `38604f37c443d5f50293e67093808e8a50588945`, using `git diff BASE...CANDIDATE`. Commits: `519300c` (application) and `d997b9e` (mobile dialogs). Independent read-only agents reviewed Standards and Spec in parallel. The coordinator inspected the subsequent fixes and their focused regressions. This is source review, not human design approval or a claim of exact Microsoft parity.

## Standards

**Documented violation:** attachment filename validation rejected C0 characters but accepted DEL/C1, despite the security contract prohibiting control characters. The authored endpoint now rejects U+007F–009F in filenames and MIME metadata. A real PostgreSQL regression failed before the change and passes after it, including Thai/Japanese/accented/emoji filename roundtrips. Final backend suite: 49/49; analysis and generated consistency pass. No schema or protocol change.

**Possible smells, judgment calls:** Unsplash API/homepage normalization repeats a mapping shape; a future shared extractor could prevent drift while preserving different eligibility/tracking rules. Simulator UUIDs occur in four launcher/profile locations, requiring coordinated replacement. These are maintenance observations, not documented-standard violations. No speculative refactor was introduced during delivery.

## Spec

**Expired/out-of-range calendar dates:** the reminder picker used a stored date outside its supported first/last date; due dates shared the same invariant. The initial date is now clamped to each picker's existing range. Four regressions open expired/future reminder and early/late due-date pickers, check the boundary selection, and verify cancellation preserves the stored value. The original assertion failures were reproduced before the fix.

**Invalid photo responses:** a nonempty byte array could replace the last good image/credit cache before decoding. The service now decodes a frame before promotion or cached use and disposes the validation image/codec. Three regressions use real PNG bytes and malformed/truncated data: failed new images retain the previous exact record/credits, bad cached images are omitted, and invalid first downloads create no record. These failures were reproduced before the fix.

**Partial original requirements:** the brief asks to “clone exactly design, functions, behavior.” Full cross-platform fidelity, attachment-limit parity, cross-list dragging and notification-tap deep links remain outside the delivered local trial. They are explicit in the [delivery limits](final-report.md#reference-parity-and-limits); documenting them does not establish exact parity. No material unasked feature scope was identified.

Standards: one documented violation repaired; two non-blocking heuristic observations. Spec: two new defects repaired, plus disclosed partial parity requirements. The worst new finding in each axis is covered by a regression; the remaining Spec boundary is exact-reference parity, which is not claimed.
