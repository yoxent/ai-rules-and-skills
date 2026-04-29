# Skill Human Spec: Design Pattern Selection

```yaml
---
name: design-pattern-selection
description: Selects appropriate design patterns based on problem domain, balancing abstraction, extensibility, and simplicity
version: 1.0.0
category: Design Governance
tags: [design-patterns, architecture, abstraction, extensibility, anti-overengineering]
priority: Medium
depends_on: [correctness-validation, clean-code-solid]
flags_skills: [refactoring, abstraction-domain-modeling, technical-debt-management, architecture-consistency]
inputs: [problem_description, constraints, current_code_structure, existing_patterns, nonfunctional_requirements]
outputs: [pattern_recommendation, rationale, alternatives_compared, implementation_guidance]
rules_applied:
  - DA-5  # Avoid Overengineering
  - DA-2  # Abstraction by Business Meaning
  - DA-3  # Conditional Logic Placement
  - DA-7  # Architectural Consistency
  - DT-1  # Explicit Tradeoff Logging
  - GM-2  # Explain Before Acting
documents_needed: [architectural-decisions, existing-patterns-catalog]
execution_context: Runs when architectural questions arise or complex logic structures need organization
---
```

# Skill: Design Pattern Selection

## Purpose

Selects appropriate design patterns based on the problem domain, balancing abstraction level, extensibility, and simplicity to avoid overengineering.

## When to Use This Skill

**Triggers:**
* Growing conditional logic (if/else, switch/case chains) suggesting need for polymorphism
* Complex logic structures needing organization
* Architectural questions about how to structure solution
* Code review reveals structural issues pattern could solve
* Existing pattern needs replacement
* New feature requires extension point
* Multiple similar implementations suggest abstraction opportunity

**Do NOT use for:**
* Simple CRUD operations
* Straightforward linear logic
* Code already using appropriate patterns
* Problems without clear recurring structure
* Speculative future-proofing

**Execution Context:** Runs when architectural questions arise. Typically after clean-code-solid identifies structural complexity. Does not run for simple operations.

## Inputs & Outputs

**Required inputs:**
* Problem description and constraints
* Current code structure and existing patterns in use
* Non-functional requirements (performance, extensibility, testability)

**Primary outputs:**
* Recommended pattern with rationale
* Comparison of alternatives considered
* Implementation guidance

## Step-by-Step Execution

1. **Analyze Problem Structure** - Identify what varies, what stays stable, extension points needed
2. **Check Existing Patterns** - Review what patterns already in use for consistency per DA-7
3. **Evaluate Pattern Candidates** - Match problem to pattern catalog, assess fit
4. **Assess Complexity vs Benefit** - Reject if pattern adds more complexity than problem per DA-5
5. **Verify Business Alignment** - Ensure pattern aligns with business domain per DA-2
6. **Generate Recommendation** - Document pattern choice, alternatives, implementation guidance

## Core Responsibilities

1. Match pattern to abstraction level required by problem
2. Avoid overengineering by rejecting patterns that solve non-existent problems
3. Ensure pattern choice consistent with existing architectural decisions
4. Justify complexity introduced by pattern against real extensibility needs

## Constraints (Rules Applied)

* **DA-5**: Reject patterns that add complexity without real requirement driving them
* **DA-2**: Pattern selection must align with business domain concepts, not technical convenience
* **DA-3**: Prefer patterns (strategy, factory) over high-level conditionals
* **DA-7**: Pattern choice must be consistent with established architectural decisions
* **DT-1**: Document why pattern chosen over simpler alternatives
* **GM-2**: Explain risks and alternatives before recommending complex patterns

## Tradeoff Handling

**Complexity vs Extensibility:** More powerful patterns add indirection; justify with concrete future requirements, not speculation
**Consistency vs Best Fit:** Most appropriate pattern may differ from existing codebase; resolve explicitly with architectural decision

## Failure & Escalation

* Multiple patterns equally valid → request business priority to break tie
* Existing pattern needs replacement → flag refactoring skill
* Pattern choice requires domain understanding → flag abstraction-domain-modeling
* Pattern introduces architectural change → require ADR documenting decision

## Skills Flagged

* **refactoring** - when existing code needs restructuring to apply recommended pattern
* **abstraction-domain-modeling** - when pattern selection requires clearer domain understanding
* **technical-debt-management** - when simpler pattern chosen with plan to upgrade later
* **architecture-consistency** - when pattern introduces new architectural approach

## Anti-Patterns to Catch

1. Overengineered solutions with unnecessary abstraction layers
2. Pattern misapplication causing more complexity than original problem
3. Inconsistency - different patterns for same problem type across codebase
4. Premature abstraction before problem recurs
5. Using inheritance when composition would be simpler
6. Abstract Factory when simple Factory Method sufficient
7. Singleton as global state disguised as pattern
8. Observer pattern for simple one-to-one notification
9. Strategy pattern with single strategy implementation
10. Template Method with no variation across implementations
