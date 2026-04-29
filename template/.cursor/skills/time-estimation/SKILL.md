---
name: time-estimation
description: "Use when task requires At sprint planning or on stakeholder commitment request. Produce risk-adjusted estimates covering full delivery scope; always expressed as ranges with explicit assumptions."
---

# Time Estimation

name:time-estimation|pri:M|deps:[]|flags:[risk-analysis,stakeholder-communication]|rules:[PS-2,DT-1,PS-4]

SCOPE: At sprint planning or on stakeholder commitment request. Produce risk-adjusted estimates covering full delivery scope; always expressed as ranges with explicit assumptions.

ENFORCE: Audit task breakdown before estimating — dev, testing, review, integration, and deployment must all be covered. Produce best/likely/worst range per task and feature rollup — no point estimates. Document every assumption with sensitivity per PS-4. Apply dependency and risk-register adjustments to worst case. State confidence HIGH/MEDIUM/LOW. Never present a range as a commitment per PS-2. Log compressed estimates per DT-1 with original and accepted risk. Flag unresolved external dependencies to risk-analysis before committing.

PROHIBIT: Point estimates. Best case treated as plan. Estimates omitting testing or deployment. Committing with unresolved external dependency. Silent compression without DT-1 log.

ON_VIOLATION: point_estimate_requested→produce_range. scope_in_flux→rough_order_only→flag. unresolved_dependency→flag:risk-analysis→mark_CONDITIONAL. compression→log:DT-1→flag:stakeholder-communication.

## Reference
- See [reference.md](reference.md) for distilled source details.
