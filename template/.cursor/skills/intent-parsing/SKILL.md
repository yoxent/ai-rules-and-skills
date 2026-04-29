---
name: intent-parsing
description: "Use when task requires Stage 1, always. Extract objective, constraints, task-type, risk, candidate skills, goal flag, and continuation signal."
---

# Intent Parsing

name:intent-parsing|pri:H|deps:[]|flags:[skill-gap-detection,decision-confirmation-gate,goal-task-decomposition,goal-task-tracking]|rules:[PS-1,PS-2,DT-1]

SCOPE: Stage 1, always. Extract objective, constraints, task-type, risk, candidate skills, goal flag, and continuation signal.

ENFORCE: Objective=one testable sentence; if indeterminate clarify; flag goal-level when task has meaningful probability of error or context loss if executed in a single pass — NOT reducible to one atomic certain action; evaluate via signals: seq-step-dependency, deferred-decisions, context-drift, ambiguous-done, silent-cascade (any one sufficient)→set Goal-Level Flag=TRUE→flag:goal-task-decomposition→block_S2→omit candidate list; when uncertain after signals prefer goal-level. Detect explicit continuation signal→flag:goal-task-tracking→omit candidate list; if ambiguous clarify first. Label inferred constraints with reasoning. Task-type: feature|refactor|migration|architecture|debugging|analysis|devops|hybrid|goal. Classify risk LOW/MEDIUM/HIGH via ORCH-1 model; default higher when uncertain. Validate all candidate skills vs skill_registry.md. Log detections and resolutions→DT-1. Risk required; never omit. ≤1 clarifying question/turn for intent clarification only; once flag:goal-task-decomposition fires questioning authority transfers to it; highest-impact=unknown most affecting intent model correctness for Stage 2.

PROHIBIT: Silent ambiguity unlogged; understated risk; unregistered skills in candidate list; Stage 2 with empty candidate list; re-parse mid-execution without scope change; classifying as task-level based solely on statable objective when decomposition signals present; inferring continuation signal without explicit goal reference.

ON_VIOLATION: ambiguous_obj→clarify→block_S2. empty_list→flag:skill-gap-detection→block_S2. HIGH_risk→flag:decision-confirmation-gate→gate_active. undocumented_assumption→log:DT-1. unregistered_skill→remove→flag:skill-gap-detection if empty. goal_level→flag:goal-task-decomposition→block_S2. continuation_signal→flag:goal-task-tracking→omit_candidate_list. ambiguous_continuation→clarify→block_flagging.

## Reference
- See [reference.md](reference.md) for distilled source details.
