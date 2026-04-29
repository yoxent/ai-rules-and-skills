# Skill Human Spec: API Design

```yaml
---
name: api-design
description: Designs clear, stable, business-aligned APIs that are consistent, predictable, and maintainable across versions
version: 1.1.0
category: Engineering
tags: [api-design, contracts, versioning, backward-compatibility, interface-design]
priority: Medium
depends_on: [correctness-validation, abstraction-domain-modeling]
flags_skills: [backward-compatibility, documentation-knowledge-transfer, error-handling-resilience, contract-testing, versioning]
inputs: [business_requirements, consumer_use_cases, existing_api_contracts, versioning_history, nonfunctional_requirements]
outputs: [api_specification, endpoint_definitions, versioning_strategy, compatibility_assessment]
rules_applied:
  - MF-3  # Backward Compatibility
  - DA-2  # Abstraction by Business Meaning
  - PS-1  # Requirement Validation
  - DT-2  # Confirmation Gate
  - PS-4  # Decision Transparency
  - GM-2  # Explain Before Acting
documents_needed: [api-contracts, consumer-requirements]
execution_context: Runs for new service endpoints, public interface design, SDK/library APIs, or breaking change considerations
---
```

# Skill: API Design

## Purpose

Designs clear, stable, and business-aligned APIs that are consistent, predictable, and maintainable across versions, minimizing the cost of change for consumers.

## When to Use This Skill

**Triggers:**
* New service endpoints or public APIs
* SDK or library API design
* Breaking change considerations
* API versioning decisions
* Contract modifications
* REST/GraphQL/gRPC interface design

**Do NOT use for:**
* Internal private methods
* Temporary integration points
* Prototype APIs not yet public
* Configuration schemas

**Execution Context:** Runs for new service endpoints, public interface design, SDK/library APIs, or breaking change considerations.

## Inputs & Outputs

**Required inputs:**
* Business requirements and consumer use cases
* Existing API contracts and versioning history
* Non-functional requirements (latency, payload size, auth model)

**Primary outputs:**
* API specification with endpoint definitions, request/response schemas, error contracts
* Versioning strategy
* Backward compatibility assessment

## Step-by-Step Execution

1. **Understand Consumer Use Cases** - Validate requirements with actual consumer needs per PS-1
2. **Design Interface** - Create endpoint definitions, schemas, error contracts
3. **Apply Domain Abstraction** - Ensure API reflects business concepts per DA-2, not implementation
4. **Assess Backward Compatibility** - Check for breaking changes per MF-3
5. **Plan Versioning** - Define strategy for evolution and migration
6. **Document Contracts** - Clear specification for consumers

## Core Responsibilities

1. Ensure consistency and predictability across all API surfaces
2. Apply appropriate abstraction levels — hide implementation, expose intent per DA-2
3. Enforce backward compatibility where consumers exist per MF-3
4. Design for evolvability, not just current requirements

## Constraints (Rules Applied)

* **MF-3**: Preserve API contracts or provide migration paths when changes unavoidable
* **DA-2**: API surfaces must reflect domain concepts, not internal implementation
* **PS-1**: API design must be validated against real consumer requirements
* **DT-2**: Breaking changes require explicit approval before proceeding
* **PS-4**: Document API decisions and reasoning transparently
* **GM-2**: Explain risks before introducing breaking changes

## Tradeoff Handling

**Simplicity vs Extensibility:** Minimal API easier to use but may require breaking changes sooner; justify design horizon
**Strict Compatibility vs Clean Evolution:** Maintaining old contracts indefinitely creates burden; version thoughtfully

## Failure & Escalation

* Breaking changes proposed → request confirmation per DT-2 → require migration plan
* Consumer use cases unclear → validate requirements with stakeholders
* Contract changes impact many consumers → coordinate migration
* API design for validation → flag contract-testing skill
* Breaking change design requires version classification → flag versioning to validate semver bump and deprecation timeline

## Skills Flagged

* **backward-compatibility** - when breaking changes detected, need compatibility guard
* **documentation-knowledge-transfer** - when API needs comprehensive documentation
* **error-handling-resilience** - when API error contracts need design
* **contract-testing** - when designed API needs validation against consumer contracts
* **versioning** - when API design involves breaking changes, to validate semver classification and deprecation strategy

## Anti-Patterns to Catch

1. Exposing internal implementation details through API
2. Breaking changes without migration path
3. Inconsistent naming or patterns across endpoints
4. Leaking technical concerns into API surface
5. Versioning every minor change
6. No error handling strategy
7. Designing for current consumer only, ignoring evolution
8. Ignoring existing API patterns in same system
