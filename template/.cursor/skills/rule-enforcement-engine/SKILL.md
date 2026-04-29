---
name: rule-enforcement-engine
description: "Use when task requires ORCH-1 Stage 5 (always, pre-execution) and Stage 8 (when persistent_state_modified=TRUE or deployment_or_migration=TRUE). Evaluates execution plans against rules_applied from loaded skill headers; blocks or escalates on violations."
---

# Rule Enforcement Engine

name:rule-enforcement-engine|pri:H|deps:[intent-parsing,skill-orchestration]|flags:[decision-confirmation-gate,engineering-decision-logging]|rules:[DT-2,CL-1,MF-3]

SCOPE: ORCH-1 Stage 5 (always, pre-execution) and Stage 8 (when persistent_state_modified=TRUE or deployment_or_migration=TRUE). Evaluates execution plans against rules_applied from loaded skill headers; blocks or escalates on violations.

ENFORCE: Collect union of all rules_applied IDs from every loaded skill header; load each rule file via view rules/<CATEGORY>/<RULE-ID>.md — never speculatively; evaluate every loaded rule against the execution plan with specific evidence; classify each outcome as PASS, VIOLATION (hard), or WARNING (soft/overridable); produce BLOCK on any hard violation and surface rule ID, constraint, and plan location; produce ESCALATE on soft violations and flag decision-confirmation-gate; at Stage 8 re-evaluate all rules against actual post-execution state, not just plan; flag engineering-decision-logging after every approved override.

PROHIBIT: Silently skipping any rule in rules_applied — unresolvable rules must be flagged as WARNING; self-approving any rule override — all overrides require decision-confirmation-gate; treating CL-1 or CL-3 compliance violations as soft constraints — they are always hard blocks; loading rules not declared in rules_applied.

ON_VIOLATION: hard_constraint_violated→BLOCK→surface rule_id and constraint→require plan revision. soft_constraint_violated→ESCALATE→flag:decision-confirmation-gate→await confirmation. compliance_rule_violated→BLOCK→no override path→require plan revision. override_approved→flag:engineering-decision-logging→record rule_id and justification. post_execution_state_violation→BLOCK completion→escalate_to_confirmation.

## Reference
- See [reference.md](reference.md) for distilled source details.
