---
name: requirement-interpretation
description: "Use when task requires Stage 1 / On new requirement or feature request. Extract primary objective, decompose into sprint-sized tasks with testable acceptance criteria, map dependencies."
---

# Requirement Interpretation

name:requirement-interpretation|pri:H|deps:[]|flags:[feature-validation,risk-analysis,roadmap-awareness]|rules:[PS-1,DA-2,DT-1,GM-2]

SCOPE: Stage 1 / On new requirement or feature request. Extract primary objective, decompose into sprint-sized tasks with testable acceptance criteria, map dependencies.

ENFORCE: State primary objective as one testable sentence in domain language; block decomposition if not achievable. Validate against roadmap per PS-1 before decomposition. Write acceptance criteria in observable business behavior per DA-2—not technical terms. Log all assumptions per DT-1. One clarification question per turn per GM-2. Flag compliance or data-sensitivity to risk-analysis before finalizing affected tasks.

PROHIBIT: Decomposing before roadmap validation. Technical language in acceptance criteria. Silent assumption resolution. Multiple clarifying questions per turn. Implementation guidance in output.

ON_VIOLATION: ambiguous_obj→clarify_one_q→block_decomposition. roadmap_misaligned→flag:roadmap-awareness→block_S3. compliance_detected→flag:risk-analysis→hold_affected_tasks. assumption_unlogged→log:DT-1. feasibility_risk→flag:feature-validation.

## Reference
- See [reference.md](reference.md) for distilled source details.
