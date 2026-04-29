---
name: skill-dependency-resolution
description: "Use when task requires ORCH-1 Stage 3 — activated when skill_count>1 OR any selected skill declares depends_on. Builds dependency graph from skill header metadata, detects cycles and ordering violations, produces valid topological execution order."
---

# Skill Dependency Resolution

name:skill-dependency-resolution|pri:H|deps:[skill-orchestration]|flags:[skill-orchestration,decision-confirmation-gate,skill-gap-detection]|rules:[DA-4,MF-3,DT-1]

SCOPE: ORCH-1 Stage 3 — activated when skill_count>1 OR any selected skill declares depends_on. Builds dependency graph from skill header metadata, detects cycles and ordering violations, produces valid topological execution order.

ENFORCE: Read depends_on exclusively from loaded skill header metadata — never from skill_registry.md or inference; build full dependency graph before running conflict detection; apply topological sort to resolve ordering violations; block execution on any unresolved circular dependency; log reorderings affecting >2 skills via DT-1; produce dependency resolution report on every execution.

PROHIBIT: Inferring or assuming dependencies not explicitly declared in skill header metadata; removing governance skills from the chain to break a cycle; substituting skills without explicit Confirmation Gate approval; allowing execution to proceed with an unresolved ordering violation.

ON_VIOLATION: circular_dependency_detected→flag:decision-confirmation-gate→block execution. missing_prerequisite_not_in_registry→flag:skill-gap-detection→block dependent skill. significant_reorder_unlogged→log via DT-1→continue. governance_skill_removal_attempted→block→surface violation→abort.

## Reference
- See [reference.md](reference.md) for distilled source details.
