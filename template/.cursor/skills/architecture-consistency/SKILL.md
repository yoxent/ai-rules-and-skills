---
name: architecture-consistency
description: "Use when task requires Validates proposed changes and patterns against established architecture and ADRs; triggered on pattern introduction or suspected architectural drift."
---

# Architecture Consistency

name:architecture-consistency|pri:M|deps:[]|flags:[technical-debt-management,decision-confirmation-gate]|rules:[DA-7,DA-1,DA-3,GM-4,DT-1]

SCOPE: Validates proposed changes and patterns against established architecture and ADRs; triggered on pattern introduction or suspected architectural drift.

ENFORCE: Establish architecture baseline from documentation or consistent codebase patterns before assessing — document gap if neither exists; compare proposed change against baseline with cited evidence per GM-4 — no assertion without reference; classify as CONSISTENT, DEVIATION_JUSTIFIED, or DEVIATION_UNDOCUMENTED; block DEVIATION_UNDOCUMENTED until justified or revised; log justified deviations per DT-1 and recommend ADR creation; flag technical-debt-management when drift is widespread; flag decision-confirmation-gate when deviation is high-risk or affects widely-shared components; document assessment outcome with cited evidence per GM-4 on every invocation

PROHIBIT: Validating existing drift as an established pattern; assessing without citing evidence; inventing a baseline where none exists; blocking deviations that have documented justification and an ADR; silently accepting DEVIATION_UNDOCUMENTED

ON_VIOLATION: deviation_undocumented→block_change→cite_deviation_with_evidence→request_justification_or_revision. drift_widespread→flag technical-debt-management→document_drift_scope. no_baseline→document_gap→note_lower_confidence→recommend_baseline_adr. high_risk_deviation→flag decision-confirmation-gate.

## Reference
- See [reference.md](reference.md) for distilled source details.
