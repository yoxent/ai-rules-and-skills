---
name: design-pattern-selection
description: "Use when task requires Selects appropriate design patterns based on problem domain, balancing abstraction, extensibility, and simplicity"
---

# Design Pattern Selection

name:design-pattern-selection|pri:M|deps:[correctness-validation,clean-code-solid]|flags:[refactoring,abstraction-domain-modeling,technical-debt-management,architecture-consistency]|rules:[DA-5,DA-2,DA-3,DA-7,DT-1,GM-2]
SCOPE: Selects appropriate design patterns based on problem domain, balancing abstraction, extensibility, and simplicity
ENFORCE: Analyze problem structure: identify what varies, what stays stable, extension points needed; Check existing patterns for consistency per DA-7 before recommending new pattern; Evaluate pattern candidates against problem fit and complexity cost; Reject patterns that add complexity without real requirement per DA-5; Verify pattern aligns with business domain concepts per DA-2; Prefer patterns over high-level conditionals per DA-3; Document why pattern chosen over simpler alternatives per DT-1; Compare alternatives and explain tradeoffs per GM-2
PROHIBIT: Recommending patterns for non-existent problems (speculative future-proofing); Pattern selection based on technical convenience instead of business meaning; Introducing patterns inconsistent with existing architecture without justification; Suggesting complex patterns when simple solution sufficient; Applying patterns before problem recurs or structure clear; Recommending patterns without implementation guidance
ON_VIOLATION: overengineering → reject_pattern → recommend_simpler_solution. pattern_inconsistent → flag architecture-consistency → request_adr. pattern_replacement → flag refactoring. domain_needed → flag abstraction-domain-modeling. patterns_equal → request_business_priority_clarification. pattern_deferred → flag technical-debt-management → document_future_migration

## Reference
- See [reference.md](reference.md) for distilled source details.
