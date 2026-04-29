---
name: code-maintenance
description: "Use when task requires Ensures long-term codebase health by identifying and addressing dead code, outdated patterns, and structural drift"
---

# Code Maintenance

name:code-maintenance|pri:M|deps:[correctness-validation]|flags:[refactoring,technical-debt-management,regression-prevention,architecture-consistency,correctness-validation,test-creation-strategy]|rules:[DA-1,MF-2,MF-1,TQ-3,GM-2]
SCOPE: Ensures long-term codebase health by identifying and addressing dead code, outdated patterns, and structural drift
ENFORCE: Identify dead code: unused imports, methods, classes, dependencies; Detect outdated patterns: compare current code to evolved architectural standards; Find obsolete references: deprecated API usages, orphaned configs, legacy constructs; Assess removal safety: check test coverage, usage analysis, impact scope; Execute cleanup incrementally to reduce risk; Run regression suite after maintenance changes per TQ-3; Maintain alignment with SOLID/Clean Code per DA-1; Log all deferred maintenance as technical debt per MF-2; Coordinate with refactoring skill when structural changes needed
PROHIBIT: Removing code without verifying it's truly unused; Updating patterns without regression testing; Breaking behavior while cleaning up; Removing code lacking tests without investigation; Deferring maintenance indefinitely; Reintroducing SOLID violations during cleanup; Making large-scale changes without incremental plan
ON_VIOLATION: structural_exceed_cleanup → flag refactoring. decay_needs_arch → flag technical-debt-management. removal_uncertain → request_guidance → defer_or_add_tests. regression_detected → revert_change → investigate. large_scope → create_incremental_plan → prioritize_by_risk. outdated_patterns → flag architecture-consistency. code_modified → flag:correctness-validation → flag:regression-prevention → flag:test-creation-strategy

## Reference
- See [reference.md](reference.md) for distilled source details.
