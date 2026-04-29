---
name: abstraction-domain-modeling
description: "Use when task requires Models business concepts into coherent code structures aligned with domain language and logical boundaries"
---

# Abstraction Domain Modeling

name:abstraction-domain-modeling|pri:M|deps:[correctness-validation,clean-code-solid]|flags:[design-pattern-selection,clean-code-solid,api-design,system-design]|rules:[DA-2,DA-4,DA-5,PS-1,GM-2]
SCOPE: Models business concepts into coherent code structures aligned with domain language and logical boundaries
ENFORCE: Choose abstraction level based on business meaning per DA-2, not technical convenience; Align code vocabulary with domain language (ubiquitous language); Maintain logical boundaries that reflect real domain separations; Define clear ownership: class changes only when business responsibility changes per DA-4; Reject abstractions that don't map to real domain concepts per DA-5; Validate domain model with business requirements per PS-1; Explain modeling decisions before implementing per GM-2; Map domain entities, value objects, and aggregates to business concepts
PROHIBIT: Abstractions named after technical concerns instead of domain concepts; Splitting domain concepts across multiple classes without clear ownership; Creating anemic domain models where entities have no behavior; Using technical jargon in business layer code; Mixing multiple domains in single class; Ignoring domain expert vocabulary; Over-abstracting simple concepts; Choosing convenience over business meaning
ON_VIOLATION: domain_unclear → request_clarification. domain_reveals_svc_bounds → flag system-design. abstraction_level_unclear → verify_with_domain_expert. vocab_mismatch → update_to_ubiquitous_language. domain_pattern_opportunity → flag design-pattern-selection. model_needs_solid_validation → flag clean-code-solid. domain_boundaries_define_apis → flag api-design

## Reference
- See [reference.md](reference.md) for distilled source details.
