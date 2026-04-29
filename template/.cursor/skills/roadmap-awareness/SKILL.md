---
name: roadmap-awareness
description: "Use when task requires During sprint planning or on new feature request. Validate planned items map to an active roadmap initiative; flag deviations and milestone risks before commitment."
---

# Roadmap Awareness

name:roadmap-awareness|pri:M|deps:[]|flags:[priority-negotiation,stakeholder-communication]|rules:[PS-1,PS-3,PS-4]

SCOPE: During sprint planning or on new feature request. Validate planned items map to an active roadmap initiative; flag deviations and milestone risks before commitment.

ENFORCE: Verify roadmap freshness first — flag stale if not updated within last sprint. Map every item to a current initiative; classify unmatched as deviations per PS-3. Assess partial matches as extension vs scope creep — not auto-aligned. Flag milestone risk when scope or timeline changes detected. Escalate unaligned items to priority-negotiation; milestone risk to stakeholder-communication. Document deviation decisions with rationale and approver per PS-4.

PROHIBIT: Silent deviation acceptance. Validating against stale roadmap without flagging. Treating partial match as full alignment. Verbal-only roadmap override without documentation. Sprint commitment with unresolved deviations.

ON_VIOLATION: item_unaligned→flag:priority-negotiation→block_sprint_commit. milestone_at_risk→flag:stakeholder-communication. stale_roadmap→flag→request_refresh→block_validation. override_undocumented→log:PS-4.

## Reference
- See [reference.md](reference.md) for distilled source details.
