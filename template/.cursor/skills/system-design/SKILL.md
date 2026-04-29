---
name: system-design
description: "Use when task requires Defines component boundaries, communication patterns, and technology choices aligned with business requirements"
---

# System Design

name:system-design|pri:H|deps:[]|flags:[dependency-management,scalability,modularity,security,technical-debt-management,performance-optimization,architecture-consistency]|rules:[DA-2,DA-5,DA-7,PC-3,DT-1,GM-2,GM-4]
SCOPE: Defines component boundaries, communication patterns, and technology choices aligned with business requirements
ENFORCE: Validate all component boundaries reflect business domain semantics, not technical layers (DA-2); Verify every technology decision includes alternatives considered and selection rationale (DT-1); Verify NFRs are measurable before committing to a pattern — reject unmeasured targets; Block architectural patterns that add complexity not justified by specific requirements (DA-5); Request business priority resolution when scalability, cost, and maintainability conflict (PC-3); Escalate proposed patterns inconsistent with existing conventions before proceeding (DA-7); Assign data ownership to exactly one component per data entity — no shared writes
PROHIBIT: Selecting architectural patterns without tracing justification to a specific NFR or constraint; Proceeding with design when requirements are too vague to derive component boundaries; Silently resolving conflicting stakeholder constraints without escalation
ON_VIOLATION: reqs_vague → halt → request clarification from stakeholder → block design output. conflicting_constraints → escalate_to_confirmation (DT-2) → present options → await resolution. pattern_inconsistent_with_existing_architecture → flag architecture-consistency → request_approval (DA-7) → log_decision (DT-1). shared_ownership → flag dependency-management → block_approval. security_component → flag security → require_review_before_finalization. sla_requires_scaling → flag scalability. component_interface_needed → flag modularity. existing_debt_constrains_design → flag technical-debt-management. latency_critical_path → flag performance-optimization

## Reference
- See [reference.md](reference.md) for distilled source details.
