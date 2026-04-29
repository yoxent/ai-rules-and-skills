---
name: tradeoff-communication
description: "Use when task requires When a technical decision requires stakeholder input. Translate tradeoffs into business-language options; produce recommendation; log decision."
---

# Tradeoff Communication

name:tradeoff-communication|pri:M|deps:[]|flags:[risk-analysis,priority-negotiation]|rules:[PS-2,PS-4,DT-1,DT-3]

SCOPE: When a technical decision requires stakeholder input. Translate tradeoffs into business-language options; produce recommendation; log decision.

ENFORCE: State decision in one business-language sentence. Present 2–4 options; prune or group beyond four. Translate every technical consequence to business impact per PS-2. Label recommendation as recommendation, not decision. Log per DT-1 with approver identity. Surface business-vs-engineering conflicts explicitly per DT-3. Require written confirmation per DT-3 if HIGH-risk option selected. Document decision with rationale and approver per PS-4.

PROHIBIT: Unilateral decision. Technical jargon in output. More than four options. Asymmetric option framing. Verbal-only approval on HIGH-risk. DT-1 entry without approver.

ON_VIOLATION: HIGH_risk_selected→escalate_to_confirmation per DT-3→require_written_approval. priority_conflict→flag:priority-negotiation. compliance_unassessed→flag:risk-analysis→block. decision_undocumented→log:DT-1. no_stakeholder→block_execution.

## Reference
- See [reference.md](reference.md) for distilled source details.
