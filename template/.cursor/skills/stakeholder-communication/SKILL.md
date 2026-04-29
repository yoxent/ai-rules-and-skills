---
name: stakeholder-communication
description: "Use when task requires On risk finding, milestone risk, incident, or decision requiring stakeholder notification. Deliver communications calibrated to audience depth; log all outcomes."
---

# Stakeholder Communication

name:stakeholder-communication|pri:M|deps:[]|flags:[risk-analysis,priority-negotiation]|rules:[PS-4,PS-2,DT-3]

SCOPE: On risk finding, milestone risk, incident, or decision requiring stakeholder notification. Deliver communications calibrated to audience depth; log all outcomes.

ENFORCE: Classify audience depth (executive/product/engineering) before writing. Lead with business impact per PS-2 — not technical detail. Every communication includes explicit required action and deadline. Translate technical content to business language for non-engineering audiences. Surface priority conflicts per DT-3; escalate to priority-negotiation — never resolve in communication. Log recipient, date, content, and response per PS-4. Re-escalate with urgency framing if no response by deadline.

PROHIBIT: Jargon in executive or product output. Critical risk delayed to fit cadence. Decision request without deadline. Priority conflict resolved in communication. Log missing response status.

ON_VIOLATION: no_response_by_deadline→re-communicate→escalate_to_manager. priority_conflict→flag:priority-negotiation. unassessed_risk→flag:risk-analysis→block_send. communication_unlogged→log:PS-4.

## Reference
- See [reference.md](reference.md) for distilled source details.
