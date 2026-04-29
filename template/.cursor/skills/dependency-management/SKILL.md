---
name: dependency-management
description: "Use when task requires Analyzes dependency graphs to detect circular deps, coupling risks, version conflicts, and license violations"
---

# Dependency Management

name:dependency-management|pri:H|deps:[]|flags:[refactoring,system-design,backward-compatibility,security,dependency-license-compliance,modularity]|rules:[DA-1,DA-4,MF-3,CL-2,DT-1,GM-2,GM-4]
SCOPE: Analyzes dependency graphs to detect circular deps, coupling risks, version conflicts, and license violations
ENFORCE: Validate against lock files, not manifests — transitive tree must be fully resolved before analysis; Detect all circular dependencies; block approval until each has a concrete break strategy; Verify license of every new or updated dependency per CL-2 before merge; Check all direct and transitive dependencies against known CVEs; Classify coupling risk per module using fan-in/fan-out; flag high-instability modules; Require changelog review for all major and minor version upgrades — semver alone is not sufficient; Log all accepted coupling tradeoffs with rationale and remediation timeline per DT-1
PROHIBIT: Passing any circular dependency without a documented break strategy and escalation; Approving production deployment with Critical or High CVEs in direct dependencies; Accepting new dependencies without license verification
ON_VIOLATION: circular_dep → block_approval → recommend_break_strategy → flag refactoring. cve_direct_dep → flag security → block_production_deployment_approval. license_conflict → flag dependency-license-compliance → escalate_to_legal_review. coupling_domain_violation → flag system-design → block_approval. breaking_version → flag backward-compatibility → escalate_to_confirmation (DT-2). high_coupling_poor_modularity → flag:modularity → evaluate_module_boundary_redesign

## Reference
- See [reference.md](reference.md) for distilled source details.
