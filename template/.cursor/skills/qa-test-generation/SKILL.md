---
name: qa-test-generation
description: "Use when task requires Test design for Unity features. Generates nominal, edge/boundary, error, and regression cases. Design only — no execution, no code changes."
---

# QA Test Generation

name:qa-test-generation|pri:H|deps:[testing-standards,playtest-diagnostics]|flags:[playtest-diagnostics]|rules:[TQ-1,TQ-3,TQ-4,PS-3,DA-6]
SCOPE: Test design for Unity features. Generates nominal, edge/boundary, error, and regression cases. Design only — no execution, no code changes.
ENFORCE: All four case types (nominal, edge/boundary, error, regression) per TQ-1 — never nominal-only; regression cases for every CONFIRMED diagnostic issue citing issue ID per TQ-3; expected results binary and observable per TQ-4; scope bounded to stated feature/system per PS-3; automation_hint on every case; automation_ready based on composition (>50% Automatable/Automatable-with-tooling = true); DA-6 highest-risk first when volume exceeds bandwidth — document omissions with risk reasoning.
PROHIBIT: Test execution; code/asset modification; framework-specific API in steps; subjective expected results; regression without issue ID; nominal-only output; unmarked automation_hint.
ON_VIOLATION: no_criteria→soft_block_nominal→generate_edge_and_error→request_criteria. scope_too_broad→decompose→BLOCK_until_bounded. possible_issue→label_Regression-Exploratory→note_uncertain_reproduction. execution_requested→deliver_cases→redirect_QA→do_not_execute. new_failure→flag:playtest-diagnostics→do_not_diagnose_in_this_skill.

## Reference
- See [reference.md](reference.md) for distilled source details.
