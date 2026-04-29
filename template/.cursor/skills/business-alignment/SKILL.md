---
name: business-alignment
description: "Use when task requires At planning cadence or when strategic relevance is unclear. Validate work maps to active OKRs before significant resource commitment."
---

# Business Alignment

name:business-alignment|pri:M|deps:[]|flags:[roadmap-awareness,stakeholder-communication,priority-negotiation]|rules:[PS-1,PS-4,DT-3,CL-4]

SCOPE: At planning cadence or when strategic relevance is unclear. Validate work maps to active OKRs before significant resource commitment.

ENFORCE: Validate OKR currency first — stale or missing OKRs marked PROVISIONAL; request refresh. Flag CL-4 ethical/values conflicts immediately on detection — not at report end. Classify each item ALIGNED/PARTIAL/MISALIGNED against active objectives only — prior-cycle deprioritised OKRs do not count. For MISALIGNED: state which OKR would need to exist to qualify. Escalate disputes per DT-3 — do not adjudicate. Log decisions with rationale and reviewer per PS-4. Flag roadmap-awareness for misaligned items; stakeholder-communication for leadership notification.

PROHIBIT: Technical soundness accepted as alignment. Deprioritised OKR treated as active. Stale OKRs used without provisional flag. CL-4 conflict deferred to report end. Dispute resolved unilaterally.

ON_VIOLATION: CL4_detected→flag_immediately→block. stale_okrs→mark_PROVISIONAL→request_refresh. misaligned→flag:roadmap-awareness→defer. persistent_misalignment→flag:stakeholder-communication. dispute→flag:priority-negotiation.

## Reference
- See [reference.md](reference.md) for distilled source details.
