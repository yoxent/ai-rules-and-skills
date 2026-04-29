# Skill Human Spec: Clean Code & SOLID

```yaml
---
name: clean-code-solid
description: Enforces Clean Code and SOLID principles pragmatically to improve readability and reduce coupling
version: 1.0.0
category: Design Governance
tags: [solid, clean-code, design-principles, readability, maintainability]
priority: High
depends_on: [correctness-validation]
flags_skills: [refactoring, design-pattern-selection, abstraction-domain-modeling, technical-debt-management]
inputs: [source_code, design_intent, business_context, architectural_patterns]
outputs: [design_assessment, violations_list, refactoring_suggestions, approval_status]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-5  # Avoid Overengineering
  - DA-6  # Pragmatic Application
  - DA-7  # Architectural Consistency
  - PC-3  # Business Priority Override
  - MF-2  # Technical Debt Tracking
  - GM-2  # Explain Before Acting
documents_needed: [existing-architectural-decisions, design-patterns-in-use]
execution_context: Runs after correctness validation; evaluates design quality for new classes and refactoring
---
```

# Skill: Clean Code & SOLID

## Purpose

Enforces Clean Code and SOLID principles pragmatically to improve readability, reduce coupling, and ensure each class has a single, well-defined responsibility.

## When to Use This Skill

**Triggers:**
* New classes or modules created
* Existing code modified and structural quality should be reviewed
* Refactoring performed
* Code review reveals potential SOLID violations
* Architectural changes introduce new patterns
* Complex business logic implemented

**Do NOT use for:**
* Code not passing correctness validation
* Simple scripts or one-off utilities
* Configuration files
* Generated code or boilerplate
* Performance-critical hotspots with deliberate principle relaxation

**Execution Context:** Runs after correctness-validation. Focuses on how correct behavior is structured.

## Inputs & Outputs

**Required inputs:**
* Source code under review
* Design intent and business context
* Existing architectural patterns in codebase

**Primary outputs:**
* Design assessment with SOLID adherence evaluation
* Violations list with severity and location
* Refactoring suggestions with before/after examples
* Approval status

## Step-by-Step Execution

1. **Evaluate Single Responsibility Principle (SRP)** - Check each class has one reason to change
2. **Evaluate Open/Closed Principle (OCP)** - Check if extension requires modifying existing code
3. **Evaluate Liskov Substitution Principle (LSP)** - Verify derived classes can substitute base
4. **Evaluate Interface Segregation Principle (ISP)** - Check interfaces are focused and role-specific
5. **Evaluate Dependency Inversion Principle (DIP)** - Verify high-level modules depend on abstractions
6. **Evaluate Clean Code Principles** - Check names, method sizes, duplication, complexity
7. **Check Architectural Consistency (DA-7)** - Verify new code follows established patterns

## Core Responsibilities

1. Ensure single responsibility at class and method level
2. Minimize coupling between modules and services
3. Improve readability through naming, structure, intent clarity
4. Apply SOLID principles pragmatically per DA-6, not dogmatically
5. Maintain architectural consistency per DA-7

## Constraints (Rules Applied)

* **DA-1**: Apply SOLID pragmatically; may be relaxed for performance-critical paths if documented
* **DA-5**: Reject unnecessary abstractions that don't serve real requirements
* **DA-6**: Apply principles with business context; dogmatic adherence without justification is itself a violation
* **DA-7**: New patterns must align with established architectural decisions unless deviation justified
* **PC-3**: When principles conflict with business constraints, escalate for resolution
* **MF-2**: When principles intentionally relaxed, log as technical debt
* **GM-2**: Risky structural changes require explanation

## Tradeoff Handling

**Principle Adherence vs Performance:** Flag violation but acknowledge performance context; allow with documentation if justified
**Ideal Design vs Delivery Constraints:** Surface violations with severity assessment for business decision

## Failure & Escalation

* Business context unclear → request clarification → flag abstraction-domain-modeling
* Conflicting principles → document conflict → present options → request guidance
* Architectural inconsistency justified by new requirements → verify necessity → request ADR

## Skills Flagged

* **refactoring** - when SOLID violations severe enough for structural refactoring
* **design-pattern-selection** - when violations suggest pattern would solve issue
* **abstraction-domain-modeling** - when responsibility ambiguity relates to domain modeling
* **technical-debt-management** - when deliberate violations need tracking

## Anti-Patterns to Catch

1. Dogmatic SOLID application adding unnecessary complexity
2. God classes accumulating unrelated responsibilities
3. Using inheritance for code reuse instead of polymorphism
4. Fat interfaces forcing stub implementations
5. Hard-coding concrete dependencies in business logic
6. Premature abstraction for hypothetical requirements
7. Violating architectural consistency without justification
8. Accepting violations under delivery pressure without logging
9. Classes with vague names (Manager, Handler, Helper, Utility)
10. Deep inheritance hierarchies (>3 levels)
