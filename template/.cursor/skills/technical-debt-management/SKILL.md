---
name: technical-debt-management
description: "Use when task requires Identifies, quantifies, and governs technical debt with business impact framing and scoped remediation plans"
---

# Technical Debt Management

name:technical-debt-management|pri:H|deps:[]|flags:[refactoring,system-design,performance-optimization,modularity]|rules:[MF-2,DA-1,PC-3,PS-3,DT-1,GM-4]
SCOPE: Identifies, quantifies, and governs technical debt with business impact framing and scoped remediation plans
ENFORCE: Log every shortcut at the time it is taken — retroactive logging is insufficient, unlogged debt is unmanaged debt (MF-2); Classify each debt item by severity with evidence: incident data, complexity metrics, delivery slowdown — not subjective impressions (GM-4); Frame every debt item with business impact: delivery slowdown, incident contribution, or feature risk; Score and rank debt: priority = (business_impact × incident_probability) / remediation_effort; Scope all remediation work explicitly with defined exit criteria — open-ended refactoring sprints are not acceptable (PS-3); Set maximum deferral periods per severity: CRITICAL ≤ 1 sprint, HIGH ≤ 2 sprints; Present debt-vs-delivery tradeoffs to stakeholder with quantified impact — do not resolve unilaterally (PC-3); In persistent mode: read `.ai/<project-name>/debt-register.md` before discovery — skip Active duplicates and Waived items; write register after assessment; in check-debt-register mode: read git log, propose removals for resolved items, confirm before writing
PROHIBIT: Accepting shortcuts without logging them in the debt register at the time they are taken; Open-ended refactoring allocations without defined scope and exit criteria; Adding new features to modules with CRITICAL-severity debt without stakeholder approval
ON_VIOLATION: unlogged_shortcut → log_retroactively → investigate_process_gap → require_immediate_logging_discipline. critical_debt → stop_feature_work_in_affected_module → escalate_to_stakeholder → flag:refactoring → flag:system-design. perf_degradation_from_debt → flag:performance-optimization. module_boundary_violations_unregistered → flag:modularity. debt_vs_delivery → escalate_to_confirmation (PC-3) → present_quantified_options

## Reference
- See [reference.md](reference.md) for distilled source details.
