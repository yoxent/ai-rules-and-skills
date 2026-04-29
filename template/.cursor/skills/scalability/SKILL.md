---
name: scalability
description: "Use when task requires Designs per-component scaling strategies, bottleneck mitigations, and capacity models to meet SLA targets"
---

# Scalability

name:scalability|pri:H|deps:[system-design]|flags:[performance-optimization,system-design,observability,dependency-management,technical-debt-management]|rules:[PC-1,PC-4,DA-5,DA-7,PC-3,DT-1,GM-2,GM-4]
SCOPE: Designs per-component scaling strategies, bottleneck mitigations, and capacity models to meet SLA targets
ENFORCE: Block execution if SLA targets are not measurable — halt and request specific metrics (PC-1); Quantify all scaling estimates with numbers: throughput, latency, instance counts, cost; Identify and explicitly mitigate or document risk-acceptance for every single point of failure; Verify scaling strategy complexity is proportional to actual load requirements, not speculative maxima (DA-5); Design caching layers only with explicit consistency requirements and invalidation strategy; Escalate cost-vs-SLA conflicts to stakeholder — do not resolve silently (PC-3); Log all scaling decisions with alternatives considered and SLA targets referenced (DT-1)
PROHIBIT: Designing infrastructure scaling as a substitute for code-level algorithmic bottleneck fixes; Proceeding with scaling design without measurable SLA targets; Accepting single points of failure in systems with availability SLAs without documented risk acceptance
ON_VIOLATION: sla_undefined → halt → request_measurable_targets_from_stakeholder. algo_bottleneck → flag performance-optimization → block_infrastructure_scaling_design. needs_redesign → flag system-design → halt_scaling_for_that_component. cost_sla_conflict → escalate_to_confirmation (PC-3) → present_options_with_tradeoffs. scaling_needs_monitoring → flag observability → require_instrumentation_plan. new_coupling_introduced → flag:dependency-management → validate_new_dependencies. debt_causing_bottleneck → flag:technical-debt-management → require_debt_remediation_plan

## Reference
- See [reference.md](reference.md) for distilled source details.
