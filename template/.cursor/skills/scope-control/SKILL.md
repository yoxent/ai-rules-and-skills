---
name: scope-control
description: "Use when task requires When a scope addition, modification, or compression is requested mid-sprint or at planning. Gate all changes against capacity, roadmap alignment, and milestone impact."
---

# Scope Control

name:scope-control|pri:H|deps:[]|flags:[priority-negotiation,stakeholder-communication]|rules:[PS-3,DT-2,MF-2,PS-1]

SCOPE: When a scope addition, modification, or compression is requested mid-sprint or at planning. Gate all changes against capacity, roadmap alignment, and milestone impact.

ENFORCE: Apply gate to every request — no silent acceptance per PS-3. Reject requests with no business rationale. Estimate effort including testing and deployment. Validate roadmap alignment per PS-1. Activate DT-2 for any change affecting a committed milestone. Require displacement plan on every approval — approval without identified displaced work is blocked. Log scope compressions with shortcuts as technical debt per MF-2. Log all decisions with rationale and approver per PS-3.

PROHIBIT: Silent scope acceptance. Approval without displacement plan. Urgency or requester seniority as gate exemption. Missing debt log on compressions with shortcuts.

ON_VIOLATION: milestone_affected→activate:DT-2→block_until_confirmed. no_rationale→reject. no_displacement→block_approval. scope_conflict→flag:priority-negotiation. rejection_or_deferral→flag:stakeholder-communication. compression_shortcuts→log:MF-2.

## Reference
- See [reference.md](reference.md) for distilled source details.
