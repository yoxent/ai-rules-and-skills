---
name: clean-code-solid
description: "Use when task requires Enforces SOLID and Clean Code principles pragmatically to improve readability and reduce coupling"
---

# Clean Code Solid

name:clean-code-solid|pri:H|deps:[correctness-validation]|flags:[refactoring,design-pattern-selection,abstraction-domain-modeling,technical-debt-management]|rules:[DA-1,DA-5,DA-6,DA-7,PC-3,MF-2,GM-2]
SCOPE: Enforces SOLID and Clean Code principles pragmatically to improve readability and reduce coupling
ENFORCE: Evaluate Single Responsibility: each class has one reason to change aligned with business domain; Evaluate Open/Closed: check if extension requires modifying existing code; Evaluate Liskov Substitution: verify derived classes can substitute base without surprises; Evaluate Interface Segregation: ensure interfaces focused, not forcing stub implementations; Evaluate Dependency Inversion: verify high-level modules depend on abstractions, not concrete classes; Check readability: names intention-revealing, methods appropriately sized, minimal duplication; Verify architectural consistency per DA-7: new patterns align with existing decisions; Apply principles pragmatically per DA-6: context matters, dogmatic adherence is itself a violation; Log deliberate principle violations as technical debt per MF-2
PROHIBIT: Dogmatic SOLID application adding unnecessary complexity; Accepting god classes with unrelated responsibilities; Premature abstraction for hypothetical requirements per DA-5; Violating architectural consistency without documented justification; Shipping SOLID violations without technical debt tracking; Hard-coding concrete dependencies in business logic without justification
ON_VIOLATION: srp_violation → fail_validation → flag refactoring. severe_structural → flag refactoring → recommend_decomposition. growing_conditionals → flag design-pattern-selection. responsibility_unclear → flag abstraction-domain-modeling. justified_violation → allow_with_documentation → flag technical-debt-management. arch_inconsistency → fail_validation → request_alignment_or_adr. principles_conflict → escalate_to_confirmation → apply PC-3

## Reference
- See [reference.md](reference.md) for distilled source details.
