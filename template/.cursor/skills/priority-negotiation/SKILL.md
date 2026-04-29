---
name: priority-negotiation
description: "Use when task requires When competing priorities conflict. Structure with explicit criteria; produce documented decision; escalate if unresolvable."
---

# Priority Negotiation

name:priority-negotiation|pri:M|deps:[]|flags:[stakeholder-communication,scope-control]|rules:[PS-3,DT-3,PS-4,DT-2]

SCOPE: When competing priorities conflict. Structure with explicit criteria; produce documented decision; escalate if unresolvable.

ENFORCE: State conflict in one sentence before scoring. Require business rationale per item — no rationale, ineligible. Score all items on same criteria (business value, strategic alignment, effort, time-sensitivity) symmetrically. Written confirmation required for decisions affecting committed items per DT-2. Deferral requires specific next-review point or trigger — "later" rejected. Log decision with criteria, rationale, approver per PS-4. Log executive overrides explicitly — not silently applied. Escalate unresolvable conflicts to next authority. Flag scope-control if sprint changes; stakeholder-communication for notification.

PROHIBIT: Unilateral decision. Asymmetric criteria. Verbal confirmation on committed-item change. Deferral without reconsideration conditions. Team absorbing unresolvable conflict.

ON_VIOLATION: no_rationale→ineligible. verbal_on_committed→require_written. unresolvable→escalate→block. undocumented→log:PS-4. silent_override→log:PS-4. sprint_change→flag:scope-control.

## Reference
- See [reference.md](reference.md) for distilled source details.
