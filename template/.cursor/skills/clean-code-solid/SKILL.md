---
name: clean-code-solid
description: "Use when task requires Enforces SOLID and Clean Code principles pragmatically to improve readability and reduce coupling"
---

# Clean Code Solid

name:clean-code-solid|pri:H|deps:[]|flags:[refactoring,design-pattern-selection,abstraction-domain-modeling,technical-debt-management]|rules:[DA-1,DA-5,DA-6,DA-7,PC-3,MF-2,GM-2]
SCOPE: Enforces SOLID and Clean Code principles pragmatically to improve readability and reduce coupling; dual-mode: designing as dep before code, reviewing via correctness-validation quality_poor
ENFORCE: Apply and evaluate SRP/OCP/LSP/ISP/DIP with abstraction-level principle (business perception + logical separation) as primary lens; In method-level clean-code checks, keep abstraction levels consistent (never mixed in one method); Diagnostic: limit indent level within method to 2 where possible — 3 only when genuinely unavoidable; >3 never acceptable; Verify architectural consistency per DA-7 and pragmatic application per DA-6; log deliberate principle violations as technical debt per MF-2
PROHIBIT: Dogmatic SOLID application adding unnecessary complexity; Accepting god classes with unrelated responsibilities; Premature abstraction for hypothetical requirements per DA-5; Violating architectural consistency without documented justification; Shipping SOLID violations without technical debt tracking; Hard-coding concrete dependencies in business logic without justification
ON_VIOLATION: srp_violation → fail_validation → flag refactoring. severe_structural → flag refactoring → recommend_decomposition. growing_conditionals → flag design-pattern-selection. responsibility_unclear → flag abstraction-domain-modeling. justified_violation → allow_with_documentation → flag technical-debt-management. arch_inconsistency → fail_validation → request_alignment_or_adr. principles_conflict → escalate_to_confirmation → apply PC-3

## Reference
- See [reference.md](reference.md) for distilled source details.
