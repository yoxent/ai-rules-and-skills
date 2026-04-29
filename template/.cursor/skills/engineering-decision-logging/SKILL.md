---
name: engineering-decision-logging
description: "Use when task requires ORCH-1 Stage 9 — architectural_decision=TRUE, tradeoff_applied=TRUE, or rule_override_approved=TRUE; also invoked directly by decision-confirmation-gate after every APPROVED confirmation."
---

# Engineering Decision Logging

name:engineering-decision-logging|pri:H|deps:[decision-confirmation-gate]|flags:[memory-management]|rules:[PS-4,DT-1,MF-2]

SCOPE: ORCH-1 Stage 9 — architectural_decision=TRUE, tradeoff_applied=TRUE, or rule_override_approved=TRUE; also invoked directly by decision-confirmation-gate after every APPROVED confirmation.

ENFORCE: Classify every entry as ARCHITECTURAL, TRADEOFF, RULE_OVERRIDE, TECHNICAL_DEBT, or GAP_DETECTION; validate all required fields before writing — type, scope, summary, rationale, rule refs, impacted skills, decision-maker, timestamp; require specific rationale — "per user request" is not sufficient, record the constraint or priority that drove the decision; record a time-box or explicit "permanent" justification for every RULE_OVERRIDE and TRADEOFF entry; record a remediation plan for every TECHNICAL_DEBT entry; flag memory-management for every ARCHITECTURAL entry; update the historical decision index on every log write.

PROHIBIT: Writing partial log entries — all required fields must be present or write an INCOMPLETE placeholder; overwriting existing entries — corrections are addenda only, entries are immutable; logging a rule override without a time-box or explicit permanent justification; omitting rule references — every entry must link to at least one rule ID.

ON_VIOLATION: missing_required_fields→write INCOMPLETE placeholder→flag invoking skill to supply missing context. rule_override_without_time_box→write entry with WARNING flag→surface to user for time-box assignment. log_write_failure→surface failure→block task completion until resolved.

## Reference
- See [reference.md](reference.md) for distilled source details.
