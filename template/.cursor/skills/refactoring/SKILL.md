---
name: refactoring
description: "Use when task requires Improves code structure, readability, and modularity without changing observable behavior"
---

# Refactoring

name:refactoring|pri:M|deps:[correctness-validation,clean-code-solid]|flags:[test-creation-strategy,regression-prevention,design-pattern-selection,technical-debt-management,correctness-validation]|rules:[TQ-3,MF-1,DA-1,DT-1,GM-2]
SCOPE: Improves code structure, readability, and modularity without changing observable behavior
ENFORCE: Verify test coverage adequate before refactoring begins; Establish baseline: run all tests, ensure green before starting; Plan refactoring in small, incremental steps; Run regression suite after each step per TQ-3; Preserve observable behavior throughout - no functional changes per MF-1; Move code toward SOLID/Clean Code principles per DA-1; Document structural improvements made; Log any deferred refactoring with timeline per DT-1
PROHIBIT: Refactoring code with insufficient test coverage; Large-bang refactoring without incremental steps; Changing behavior during refactoring; Skipping test runs between refactoring steps; Scope creep turning refactor into feature rewrite; Refactoring based on style preference without measurable benefit; Premature optimization disguised as refactoring
ON_VIOLATION: coverage_insufficient → flag test-creation-strategy → defer_refactor. behavioral_regression → revert_change → investigate_test_gap. arch_debt_revealed → flag technical-debt-management. behavior_uncertain → halt_refactor → request_clarification. scope_expanding → halt → reassess_scope. pattern_opportunity → flag design-pattern-selection. code_refactored → flag:correctness-validation → flag:regression-prevention

## Reference
- See [reference.md](reference.md) for distilled source details.
