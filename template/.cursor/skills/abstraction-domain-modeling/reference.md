# Skill Human Spec: Abstraction & Domain Modeling

```yaml
---
name: abstraction-domain-modeling
description: Models business concepts into coherent code structures aligned with domain language and logical boundaries
version: 1.0.0
category: Design Governance
tags: [domain-modeling, abstraction, ddd, ubiquitous-language, business-alignment]
priority: Medium
depends_on: [correctness-validation, clean-code-solid]
flags_skills: [design-pattern-selection, clean-code-solid, api-design, system-design]
inputs: [business_domain_descriptions, domain_expert_input, existing_class_structures, feature_requirements]
outputs: [class_module_design, domain_vocabulary_mapping, boundary_definitions, ownership_model]
rules_applied:
  - DA-2  # Abstraction by Business Meaning
  - DA-4  # Change Boundary Rule
  - DA-5  # Avoid Overengineering
  - PS-1  # Requirement Validation
  - GM-2  # Explain Before Acting
documents_needed: [domain-glossary, business-requirements]
execution_context: Runs for new features with domain logic, unclear responsibilities, or complex business rule implementation
---
```

# Skill: Abstraction & Domain Modeling

## Purpose

Models business concepts into coherent code structures, ensuring abstractions reflect domain language and maintain logical boundaries that align with how the business thinks about the problem.

## When to Use This Skill

**Triggers:**
* New features with significant domain logic
* Class responsibilities unclear or overlapping
* Vocabulary mismatch between code and business
* Complex business rules need implementation
* Service boundaries unclear
* Domain concepts split across multiple classes

**Do NOT use for:**
* Simple CRUD operations
* Technical infrastructure code
* Utility functions
* Already well-modeled domains

**Execution Context:** Runs for new features with domain logic, unclear responsibilities, or complex business rule implementation.

## Inputs & Outputs

**Required inputs:**
* Business domain descriptions and domain expert input
* Existing class and module structures
* Feature requirements with domain context

**Primary outputs:**
* Class and module design aligned to domain concepts
* Domain vocabulary mapped to code constructs
* Boundary definitions and ownership model

## Step-by-Step Execution

1. **Understand Domain Concepts** - Gather business terminology, relationships, rules
2. **Identify Domain Entities** - Find core business objects with identity
3. **Map Domain Language** - Align code vocabulary with ubiquitous language
4. **Define Boundaries** - Establish clear ownership and responsibility per DA-4
5. **Model Relationships** - Capture business relationships in code structure
6. **Validate with Domain Experts** - Verify model reflects business reality per PS-1

## Core Responsibilities

1. Choose abstraction level based on business meaning per DA-2, not technical convenience
2. Align code vocabulary with domain language (ubiquitous language)
3. Maintain logical boundaries that reflect real domain separations
4. Avoid abstractions that are technically clever but domain-meaningless per DA-5

## Constraints (Rules Applied)

* **DA-2**: Abstraction level must be driven by domain concepts, not technical convenience
* **DA-4**: A class should only change when its business responsibility changes
* **DA-5**: Reject abstractions that don't map to real domain concepts
* **PS-1**: Domain model must reflect validated business requirements
* **GM-2**: Explain modeling decisions before implementing

## Tradeoff Handling

**Domain Purity vs Simplicity:** Fully faithful domain model may be more complex than pragmatic one; calibrate to project scale
**Business Alignment vs Technical Convenience:** Abstractions that serve developers but not domain create long-term confusion

## Failure & Escalation

* Domain unclear or expert input unavailable → request clarification
* Domain modeling reveals service boundary questions → flag system-design
* Abstraction level unclear → verify with domain expert
* Vocabulary mismatch with business → update to ubiquitous language

## Skills Flagged

* **design-pattern-selection** - when domain modeling suggests specific patterns (aggregate, repository)
* **clean-code-solid** - when domain model needs SOLID validation
* **api-design** - when domain boundaries define API surfaces
* **system-design** - when modeling reveals service boundary questions

## Anti-Patterns to Catch

1. Abstractions named after technical concerns instead of domain concepts
2. Domain concepts split across multiple classes with no clear ownership
3. Anemic domain models where entities have no behavior
4. Technical jargon in business layer code
5. God entities accumulating all business logic
6. Ignoring domain expert vocabulary
7. Over-abstracting simple concepts
8. Mixing multiple domains in single class
