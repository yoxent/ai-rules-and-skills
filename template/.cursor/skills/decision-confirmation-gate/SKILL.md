---
name: decision-confirmation-gate
description: "Use when task requires ORCH-1 Stage 6 — risk_level=HIGH, rule_requires_confirmation=TRUE, or irreversible_operation=TRUE; also invoked by rule-enforcement-engine on soft violations and any skill ON_VIOLATION escalation. Presents structured impact summary and requires explicit user approval before execution proceeds."
---

# Decision Confirmation Gate

name:decision-confirmation-gate|pri:H|deps:[intent-parsing,rule-enforcement-engine]|flags:[engineering-decision-logging]|rules:[DT-2,PS-2,CL-4]

SCOPE: ORCH-1 Stage 6 — risk_level=HIGH, rule_requires_confirmation=TRUE, or irreversible_operation=TRUE; also invoked by rule-enforcement-engine on soft violations and any skill ON_VIOLATION escalation. Presents structured impact summary and requires explicit user approval before execution proceeds.

ENFORCE: Validate proposed action is precisely defined before presenting confirmation; include in every confirmation the exact action, what is irreversible, rollback options, and affected scope; state rule override context explicitly when invoked by rule-enforcement-engine; require explicit APPROVE or REJECT — never infer approval from ambiguous response; flag engineering-decision-logging immediately after every APPROVED decision; record every outcome (approval or rejection) with timestamp and full context; batch only related violations from the same task chain — never unrelated ones.

PROHIBIT: Presenting a confirmation for a vague or undefined action; defaulting to APPROVE on ambiguous, absent, or unclear user response; suppressing confirmation for HIGH risk or irreversible operations regardless of user preference; accepting hard-constraint rule violations (CL-1, CL-3) for override — return REJECTED immediately; proceeding with execution before receiving explicit APPROVE.

ON_VIOLATION: undefined_proposed_action→request clarification from invoking skill→do not present to user. ambiguous_user_response→re-present with direct binary question→after two attempts default to REJECTED. hard_constraint_escalated_incorrectly→return REJECTED→surface no_override_path explanation. approval_not_logged→flag:engineering-decision-logging→block task completion until logged.

## Reference
- See [reference.md](reference.md) for distilled source details.
