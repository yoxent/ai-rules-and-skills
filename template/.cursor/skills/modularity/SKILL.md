---
name: modularity
description: "Use when task requires Decomposes system into cohesive, loosely coupled modules with explicit interfaces and domain-aligned boundaries"
---

# Modularity

name:modularity|pri:H|deps:[system-design]|flags:[dependency-management,refactoring,abstraction-domain-modeling,api-design,technical-debt-management]|rules:[DA-1,DA-2,DA-4,DA-5,DA-7,DT-1,GM-2,GM-4]
SCOPE: Decomposes system into cohesive, loosely coupled modules with explicit interfaces and domain-aligned boundaries
ENFORCE: design involves code-level implementation → flag:refactoring → co_invoke before design; Validate every module boundary reflects a domain concern, not a technical function (DA-2); Require every module responsibility statement to fit one sentence with no conjunctions; Define explicit public interface for each module; default all symbols to private; Verify dependency direction flows high-level to low-level only — flag upward dependencies; Assign ownership of every domain concern to exactly one module — no overlaps, no gaps; Classify all existing boundary violations by severity and produce remediation plan (DA-4); Log all deliberate boundary tradeoffs with rationale and remediation timeline (DT-1)
PROHIBIT: Modules named or organized by technical layer instead of domain concern; Proceeding with circular module dependencies under any circumstances; Accepting boundary violations without a documented remediation plan; Defining module interfaces based on implementation convenience rather than consumer need
ON_VIOLATION: circular_mod_dep → block_approval → recommend_break_strategy → flag dependency-management. boundary_ambiguity → flag abstraction-domain-modeling → halt_boundary_decisions → await_resolution. blocking_violations → block_new_feature_work → escalate_to_stakeholder. numerous_violations → flag technical-debt-management → log_debt_register (MF-2). complex_api_interface → flag:api-design → require_formal_interface_design

## Reference
- See [reference.md](reference.md) for distilled source details.
