---
name: feature-validation
description: "Use when task requires After requirement-interpretation; before sprint commit. Four-gate validation: roadmap alignment, existing-behavior consistency, architectural fit, scope."
---

# Feature Validation

name:feature-validation|pri:H|deps:[requirement-interpretation]|flags:[risk-analysis,scope-control,roadmap-awareness]|rules:[PS-1,MF-1,PS-3,DT-2]

SCOPE: After requirement-interpretation; before sprint commit. Four-gate validation: roadmap alignment, existing-behavior consistency, architectural fit, scope.

ENFORCE: Validate roadmap+business alignment per PS-1 first. Identify existing touch points; classify regression risk per MF-1. Classify arch fit NONE/MINOR/MAJOR; recommend system-design if MAJOR. Detect scope expansion; flag scope-control per PS-3. Classify risk LOW/MEDIUM/HIGH with cited finding per gate. Produce GO/CONDITIONAL-GO/NO-GO. Activate DT-2 for every HIGH-risk finding. Escalate in business language.

PROHIBIT: Gate pass without cited finding. Downgrading HIGH risk to avoid DT-2. Vague CONDITIONAL-GO. Proceeding HIGH-risk without explicit approval.

ON_VIOLATION: HIGH_risk_no_approval→activate:DT-2→block_commit. roadmap_misaligned→flag:roadmap-awareness→NO-GO. scope_expansion→flag:scope-control→activate:DT-2. regression_risk→CONDITIONAL-GO. compliance_detected→flag:risk-analysis→hold_affected_tasks.

## Reference
- See [reference.md](reference.md) for distilled source details.
