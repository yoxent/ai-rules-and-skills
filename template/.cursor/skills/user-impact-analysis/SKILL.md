---
name: user-impact-analysis
description: "Use when task requires Before release of user-facing changes or on UX risk flag. Assess effects per user segment; recommend mitigations; surface ethical and accessibility risks."
---

# User Impact Analysis

name:user-impact-analysis|pri:M|deps:[]|flags:[feature-validation,risk-analysis,stakeholder-communication]|rules:[PS-1,PS-2,CL-4]

SCOPE: Before release of user-facing changes or on UX risk flag. Assess effects per user segment; recommend mitigations; surface ethical and accessibility risks.

ENFORCE: Identify all affected segments — always include accessibility and mobile users. Assess positive and negative effects per segment with severity H/M/L. Flag CL-4 ethical risks (dark patterns, manipulation) immediately before rest of assessment. Validate against user requirements per PS-1. Specific actionable mitigation per HIGH/MEDIUM negative finding. Communicate HIGH-severity negatives to stakeholders before release per PS-2. Distinguish perceived experience from measured metrics when performance changes are in scope.

PROHIBIT: Silently excluding a segment. Low-impact approval on metrics alone when perceived experience differs. Suppressing CL-4 for business reasons. Deferring HIGH-severity communication to post-release. Vague mitigations.

ON_VIOLATION: CL4_detected→flag:risk-analysis→block_release. HIGH_severity_negative→flag:feature-validation→require_stakeholder_ack. accessibility_violation→flag:risk-analysis. impact_undisclosed→flag:stakeholder-communication.

## Reference
- See [reference.md](reference.md) for distilled source details.
