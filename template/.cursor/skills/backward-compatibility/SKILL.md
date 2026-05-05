---
name: backward-compatibility
description: "Use when task requires Validates change compatibility with existing consumers across APIs, services, and products; designs migration paths when breaking changes are unavoidable"
---

# Backward Compatibility

name:backward-compatibility|pri:H|deps:[system-design]|flags:[language-specific-implementation,api-design,stakeholder-communication,migration-strategy]|rules:[MF-3,MF-1,PS-2,DT-2,DT-1,GM-4]
SCOPE: Validates change compatibility with existing consumers across APIs, services, and products; designs migration paths when breaking changes are unavoidable
ENFORCE: analysis involves code-level implementation → flag:language-specific-implementation → co_invoke before analysis; Inventory all interface contracts and their consumers before evaluating any proposed change (MF-3); Classify each change per consumer as COMPATIBLE, MIGRATION REQUIRED, or UNKNOWN — block UNKNOWN until resolved; Design a concrete migration path (additive, versioned, or compatibility shim) for every breaking change; Gate every unavoidable breaking change through stakeholder confirmation before proceeding (DT-2); Produce migration guides with before/after examples for every consumer-impacting change (PS-2); Specify contract tests preventing future regression of the compatibility guarantee; Treat silent behavioral changes (same interface, changed semantics) as breaking changes — not just structural changes (MF-1); Treat product-facing changes as breaking when consumers must actively adapt — feature removal, route change without redirect, exported format change, or workflow disruption; When invoked in aggregate mode, output a structured classification table — one row per change, BREAKING/COMPATIBLE/UNKNOWN per consumer
PROHIBIT: Approving a breaking change without a designed migration path; Classifying enum expansions or required field additions as backward-compatible without consumer validation; Removing or renaming any field, endpoint, or parameter without a deprecation period; Silently extending deprecation deadlines without documented stakeholder approval
ON_VIOLATION: breaking_no_migration → block_change → design_migration_path → escalate_to_confirmation (DT-2). consumer_not_migrated → flag stakeholder-communication → escalate_for_cutoff_decision → log_per_DT-1. api_defect → flag api-design → evaluate_additive_redesign_before_accepting_break. migration_complex → flag migration-strategy → require_formal_migration_plan

## Reference
- See [reference.md](reference.md) for distilled source details.
