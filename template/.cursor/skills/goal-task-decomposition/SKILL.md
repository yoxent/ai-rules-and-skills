---
name: goal-task-decomposition
description: "Use when task requires Post-Stage-1, on goal-level flag from intent-parsing. Decomposes goal into sub-goals→tasks via iterative user approval loop; writes approved state file to goals/goal-[id].md; blocks Stage 2 until file confirmed written."
---

# Goal Task Decomposition

name:goal-task-decomposition|pri:H|deps:[intent-parsing]|flags:[skill-gap-detection,decision-confirmation-gate]|rules:[GM-2,GM-4,DT-1,DT-2,PS-1,PS-2,PS-3,CL-4]

SCOPE: Post-Stage-1, on goal-level flag from intent-parsing. Decomposes goal into sub-goals→tasks via iterative user approval loop; writes approved state file to goals/goal-[id].md; blocks Stage 2 until file confirmed written.

ENFORCE: Verify goal-level flag from intent-parsing before activating; verify no existing state file for same goal. Elicit if vague OR unknowns block sub-goals; batch max 5 per turn; prioritize by sub-goal impact. Decompose until every leaf task passes certainty test: NOT reducible to one atomic certain action; evaluate via signals: seq-step-dependency, deferred-decisions, context-drift, ambiguous-done, silent-cascade (any one→recurse deeper); warn if sub-goals>7 or tasks-per-sub-goal>6; escalate to decision-confirmation-gate at depth 10. Each task must have one testable objective, declared deps, and a risk-hint. Validate every task against skill_registry.md before presenting. Flag:skill-gap-detection for any task with no matching skill. Annotate tasks with legal or ethical risk with CL-4 warning before presenting. Flag undeclared costs or delivery risks discovered during decomposition→surface per PS-2 before presenting breakdown. Present full breakdown to user before writing any file (GM-2). State assumptions explicitly; never present inferred scope as confirmed (GM-4). Iterate max 2 cycles; on no approval after 2 cycles flag:decision-confirmation-gate. Require unambiguous approval before writing state file (DT-2). Log decomposition decisions and scope exclusions→DT-1; all accepted scope or tooling changes→log in goal state file decisions section AND DT-1. Detect circular deps before presenting; block approval until resolved. Write goals/goal-[id].md only after approval; confirm write succeeded before returning first pending task to orchestrator. Validate sub-goal traceability to stated goal (PS-1); IF no prior project goals exist→treat approved goal file as project goals definition→PS-1 satisfied on approval. Flag scope additions during iteration (PS-3).

PROHIBIT: Activating without goal-level flag from intent-parsing; writing state file before explicit user approval; proceeding to Stage 2 on file write failure; stopping decomposition before leaf-task certainty test passes; exceeding depth 10 without escalating to decision-confirmation-gate; silently resolving dependency conflicts; activating when a state file for the same goal already exists; proceeding with decomposition before elicited unknowns are resolved.

ON_VIOLATION: vague_goal_after_elicitation→halt→request_scope_narrowing→block_Stage2. circular_dep_detected→block_approval→surface_cycle. skill_gap_detected→flag:skill-gap-detection→surface_gap_in_breakdown. iteration_limit_reached→flag:decision-confirmation-gate→block_file_write. file_write_failure→halt→report_error→block_Stage2. existing_goal_file_detected→surface_file→trigger:goal-task-tracking. depth_cap_reached→flag:decision-confirmation-gate→block_decomposition. elicitation_unanswered→halt→await_response→block_decomposition.

## Reference
- See [reference.md](reference.md) for distilled source details.
