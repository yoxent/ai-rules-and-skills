---
name: task-planning
description: "Use when task requires ORCH-1 Stage 4 — conditional: risk_level∈{MEDIUM,HIGH} OR multi_step=TRUE OR persistent_state_modified=TRUE. Decomposes the ordered skill chain into an atomic step-by-step execution roadmap with checkpoints and rollback markers."
---

# Task Planning

name:task-planning|pri:H|deps:[intent-parsing,skill-orchestration]|flags:[decision-confirmation-gate,engineering-decision-logging]|rules:[PS-3,DD-2,DT-1]

SCOPE: ORCH-1 Stage 4 — conditional: risk_level∈{MEDIUM,HIGH} OR multi_step=TRUE OR persistent_state_modified=TRUE. Decomposes the ordered skill chain into an atomic step-by-step execution roadmap with checkpoints and rollback markers.

ENFORCE: Verify Stage 4 activation condition before producing any plan — skip if unmet; decompose each skill in the ordered chain into atomic steps with one action and one testable outcome each; insert a validation checkpoint before and after every state-modifying step; mark every irreversible step IRREVERSIBLE and flag decision-confirmation-gate; define a concrete rollback action for every reversible state-modifying step (DD-2); keep all plan steps within the intent model's scope boundary (PS-3); log granularity and rollback strategy decisions via DT-1.

PROHIBIT: Producing a plan when no Stage 4 activation condition is met; steps that are not atomic — no multiple concerns in one step; vague checkpoints ("check it works") — must be concrete and testable; omitting rollback actions for reversible state-modifying steps; embedding out-of-scope steps silently in the plan.

ON_VIOLATION: irreversible_step_detected→flag:decision-confirmation-gate→mark IRREVERSIBLE in roadmap. out_of_scope_step_detected→remove from plan→log via DT-1→surface as follow-up. rollback_undefined_for_reversible_step→define rollback OR reclassify as irreversible→flag:decision-confirmation-gate. activation_condition_unmet→skip Task Planning→proceed to Stage 5. architectural_decision_in_plan→flag:engineering-decision-logging.

## Reference
- See [reference.md](reference.md) for distilled source details.
