# Skill Human Spec: Clean Code & SOLID

```yaml
---
name: clean-code-solid
description: Enforces Clean Code and SOLID principles pragmatically to improve readability and reduce coupling
version: 1.6.0
category: Design Governance
tags: [solid, clean-code, design-principles, readability, maintainability]
priority: High
depends_on: []
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
execution_context: Two modes — designing: invoked as dep of code-producing skills before code is written, applies SOLID+CC to guide implementation; reviewing: invoked via correctness-validation flag on quality_poor, evaluates adherence post-change
---
```

# Skill: Clean Code & SOLID

## Purpose

Enforces Clean Code and SOLID principles pragmatically to improve readability, reduce coupling, and ensure each class has a single, well-defined responsibility.

**End goal:** All principles serve one objective — maintainability and flexibility. Principles are means, not ends. Pragmatic application, never dogma.

**Business value:** Reduces long-term maintenance costs, accelerates future development, decreases bug introduction rate, improves team velocity.

**Engineering value:** Creates predictable, testable code structures, reduces coupling, enables confident refactoring, improves comprehension.

## Abstraction Level Principle

The appropriate level of abstraction for any class, method, or interface is determined by two factors:

1. **Business perception of the concept** — how the business understands and delineates the concept
2. **Logical separation of the concept** — how technically distinct the operations are

This applies across all SOLID and Clean Code decisions — class scope, interface granularity, method design — not to any single principle alone. When the right level of abstraction is unclear, this is the first diagnostic to apply.

## When to Use This Skill

**Designing mode (pre-change dep):**
* Code-producing skill about to run — guides SOLID+CC in implementation design
* New classes or modules being created

**Reviewing mode (post-change, via correctness-validation flag on quality_poor):**
* Existing code modified and structural quality should be reviewed
* Refactoring performed
* Code review reveals potential SOLID violations
* Architectural changes introduce new patterns
* Complex business logic implemented

**Do NOT use for:**
* Simple scripts or one-off utilities
* Configuration files
* Generated code or boilerplate
* Performance-critical hotspots with deliberate principle relaxation

**Execution Context:** Two modes — designing: invoked as dep before code is written, guides SOLID+CC in design; reviewing: invoked via correctness-validation flag on quality_poor, evaluates adherence post-change.

## Inputs & Outputs

**Required inputs:**
* Source code under design or review 
* Design intent and business context
* Existing architectural patterns in codebase

**Primary outputs:**
* Design assessment with SOLID adherence evaluation
* Violations list with severity and location
* Refactoring suggestions with before/after examples
* Approval status

## Step-by-Step Execution

1. **Apply & Evaluate Single Responsibility Principle (SRP)** — Design each class with one reason to change; check existing classes for violations
   - Business context drives the split, not logical separation alone. The same concept can be SRP-compliant at one abstraction level and a violation at another. Example: an engine is one concept when driving a car; it is many separate concepts when servicing it.
   - Diagnostic: if the class cannot be described in ~25 words without conjunctions (and/or/if/but) → SRP violation signal
   - Diagnostic: vague names (Manager, Handler, Helper, Utility) signal SRP violation — a class that cannot be named precisely probably carries multiple responsibilities
   - Cohesion check: flag class variables used in fewer than ~30% of the class's methods (excluding data objects) as a split candidate
   - Cohesion decline during evolution: as a class evolves under business change, watch for cohesion decline — when a subset of methods consistently shares only a subset of the class's variables, those methods and variables want to become their own class. Declining cohesion is the natural split signal; act on it.
   - Function extraction as class discovery: when breaking a large function into smaller ones, watch for groups of extracted functions that cluster around a subset of variables — this reveals a class that was already there. Function extraction is an opportunity to split out smaller, better-organized classes with more transparent structure.

2. **Apply & Evaluate Open/Closed Principle (OCP)** — Design classes open to bug-fixes and business-context changes only; check existing classes for impl-minutiae modifications
   - OCP does not mean "freeze the class." A class is open to bug fixes and business-context changes; it is closed to implementation minutiae.
   - Achievement mechanism: design high-level classes around interfaces so that when implementation details change, the interface or pattern absorbs the change, not the class itself. Only a genuine business-context change should require modifying the class.

3. **Apply & Evaluate Liskov Substitution Principle (LSP)** — Design derived classes to fully substitute their base; verify existing subclasses satisfy all 7 requirements
   - Check abstraction first: if a subclass cannot satisfy LSP, the abstraction may be wrong rather than the implementation. Flag abstraction-domain-modeling before attempting LSP enforcement on the implementation.
   - Formal requirements — a compliant subclass must satisfy all of:
     1. Contravariant params: parameter types match or are more abstract than the superclass method
     2. Covariant returns: return type matches or is a subtype of the superclass method
     3. No new exception types beyond what the base method declares
     4. No stronger preconditions than the superclass
     5. No weaker postconditions than the superclass
     6. Preserve superclass invariants
     7. Do not mutate private fields of the superclass

4. **Apply & Evaluate Interface Segregation Principle (ISP)** — Design interfaces so callers need no implementation internals; check existing interfaces for semantic coupling
   - Flag semantic coupling: a caller must not need to know implementation internals to use the interface correctly. If they do, the interface is leaking implementation detail.
   - Interface granularity follows the Abstraction Level Principle — determined by business perception and logical separation, not technical convenience.

5. **Apply & Evaluate Dependency Inversion Principle (DIP)** — Design high-level modules to own their interfaces; verify existing modules do not depend on low-level-defined abstractions
   - High-level module owns the interface; the low-level implementer depends on the interface, not the reverse. Ownership is the key — an interface defined by the low-level class is not DIP-compliant even if the high-level class uses it.

6. **Apply & Evaluate Clean Code Principles** — Design with correct naming, abstraction consistency, cohesion, and structure; check existing code for violations

   **Class:**
   - Naming must reveal intent; a class name that requires reading the class body to understand its purpose is a naming failure

   **Method:**
   - Naming: arguments should be evident from the method name without reading the signature. Prefer `assertExpectedEqualsActual(expected, actual)` over `assertEquals` — the former eliminates ambiguity about argument order.
   - Abstraction level consistency: a high-level method invokes only all-high- or all-mid-level methods; a mid-level method invokes only all-mid- or all-low-level methods. Never mix levels within a single method.
     - Diagnostic: limit indent level within a method to 2 wherever possible — 3 is occasionally acceptable when there is genuinely no other option; >3 is never acceptable
     - Method length of 3–5 lines is the natural result of applying abstraction consistency correctly. When reviewing, Flag methods >5 lines as a signal that abstraction level consistency was not maintained.
   - CQS (Command-Query Separation): a method either transforms and returns (command) OR answers a question (query) — never both. Side effects hidden inside a query are lies.
   - One abstract name per intention: `add` means one operation across all classes using that name; use a different name for a different operation (e.g., `insert`). Mixing semantics under one name breaks predictability.
   - Special Case Pattern: prefer returning a typed special-case object over null. Null forces callers to know internal implementation details to handle it safely.
   - Function arguments: 3 or more arguments is a SRP/abstraction violation signal — diagnose whether the arguments belong in an object or whether the method is doing too much. Example: `write(stream, msg)` should become `stream.write(msg)` or have `stream` encapsulated.

   **General:**
   - Law of Demeter: `a.b()` is acceptable; `a.b().c()` should be avoided (sometimes unavoidable); `a.b().c().d()` or deeper is never acceptable.
   - Prefer polymorphism over if/else and switch/case. If/else should appear only in low-level classes or inside a factory method that decides which object to create. Once the correct object is injected, it does its job without conditional branching. Simple predicates are acceptable.
   - Separate construction from use: decouple system initialization from runtime business logic using a DI pattern. A class should not create its own dependencies.
   - Postpone decisions: defer design decisions to the last responsible moment; assign the decision to the object with the most context for it.
   - Concurrency as decoupling signal: when a feature involves large-scale or long-duration work, prompt whether async decoupling is appropriate (background task + notify over blocking). This raises a design question — not a rule to enforce unilaterally.

7. **Apply Design Rules** — Apply only when evaluating a new project or a codebase lacking structural capability. In priority order. Best case for code is all 4 are valid; worst case is only the number 1 is valid:
   1. Runs all tests
   2. No duplication
   3. Expresses intent
   4. Minimizes classes and methods

8. **Check Architectural Consistency (DA-7)** — Verify code follows established patterns

## Core Responsibilities

1. Ensure single responsibility at class and method level
2. Minimize coupling between modules and services
3. Improve readability through naming, structure, and intent clarity
4. Apply SOLID principles pragmatically per DA-6, not dogmatically
5. Maintain architectural consistency per DA-7
6. Prefer composition (has-a) over inheritance (is-a); use inheritance only when a subclass is truly is-a and cannot be has-a — inheritance creates tight coupling, worst case: parallel inheritance hierarchies. A subclass must add behavior, not nullify it; it cannot reduce the parent interface.
7. Program to interfaces, not implementations; DI enables this naturally

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
* LSP violation detected → check abstraction domain first before flagging implementation → flag abstraction-domain-modeling if abstraction is wrong

## Skills Flagged

* **refactoring** — when SOLID violations are severe enough to warrant structural refactoring
* **design-pattern-selection** — when violations suggest a pattern would resolve the issue
* **abstraction-domain-modeling** — when responsibility ambiguity relates to domain modeling, or when LSP/ISP violation traces to a wrong abstraction
* **technical-debt-management** — when deliberate violations need tracking

## Anti-Patterns to Catch

1. Dogmatic SOLID application adding unnecessary complexity
2. God classes accumulating unrelated responsibilities
3. Using inheritance for code reuse instead of composition
4. Fat interfaces forcing stub implementations
5. Hard-coding concrete dependencies in business logic
6. Premature abstraction for hypothetical requirements
7. Violating architectural consistency without justification
8. Accepting violations under delivery pressure without logging
9. Classes with vague names (Manager, Handler, Helper, Utility)
10. Unjustified inheritance — using inheritance where composition would suffice, or where the relationship is not truly is-a
11. High coupling: needing one class forces importing unrelated others

## Notes for LLM Implementation

* **Dual-mode execution:** This skill runs in two modes — design mode (designing code) and review mode (existing code). In design mode, apply positive principles proactively. In review mode, actively run all detection checks against every class and method touched.
* **ENFORCE vs ON_VIOLATION for detection signals:** Items labeled "Diagnostic:" in the Step-by-Step are active detection checks the AI runs in both modes — they belong in ENFORCE using the `Flag` verb, not in ON_VIOLATION. ON_VIOLATION is reserved for post-detection escalation: what to do after a violation is confirmed (flag a related skill, request clarification, log technical debt). The distinction: ENFORCE `Flag X if Y` = the AI actively runs this check; ON_VIOLATION `condition→action` = the AI responds to a confirmed finding. Use this note as guide when distilling.
* **When designing, target the principle — not the diagnostic threshold:** In design mode, apply the underlying principle directly (SRP, abstraction consistency, etc.) — not the diagnostic signal. Do not aim to "keep methods under 5 lines" or "keep a class describable in 25 words"; aim to apply abstraction level consistency and SRP. The diagnostic thresholds exist in ENFORCE to detect violations during review — when the principle is applied correctly in design, they will not fire.
* **Abstraction level is the primary lens:** When responsibility boundaries are unclear, apply the Abstraction Level Principle before evaluating any individual SOLID principle. Business perception of the concept — not technical convenience — determines the correct split.

## Version History

* **v1.6.0** (2026-04-30): Dual-mode invocation model — designing mode (pre-change dep of code-producing skills) and reviewing mode (post-change via correctness-validation flag on quality_poor); `depends_on` cleared; "activating before correctness-validation passes" removed from PROHIBIT; When to Use section reorganized by mode; execution_context updated
* **v1.5.1** (2026-04-30): Compact SCOPE updated to reflect end-goal framing already present in Purpose — objective:maintainability+flexibility; principles are means not ends
* **v1.5.0** (2026-04-30): Abstraction level consistency clarified — high-level method invokes only high-level OR only mid-level (never mixed); same for mid-level; method length note updated to add review-mode detection flag (>5 lines as abstraction-consistency signal)
* **v1.4.3** (2026-04-30): execution_context and Execution Context updated to reflect dual-mode — "applies when designing code; evaluates when reviewing existing code"; removed implied design-mode-only-for-new-code framing
* **v1.4.2** (2026-04-30): Notes for LLM Implementation bullet 3 reworded — "When designing, target the principle — not the diagnostic threshold" replaces confusing "Do not enforce diagnostics as design goals"
* **v1.4.1** (2026-04-30): Step headers 1–6 renamed from "Evaluate" to "Apply & Evaluate" to make design-mode posture explicit alongside review-mode evaluation
* **v1.4.0** (2026-04-29): Added Notes for LLM Implementation — dual-mode execution guidance, ENFORCE vs ON_VIOLATION distillation rule for detection signals, abstraction level as primary lens
* **v1.3.0** (2026-04-29): SRP expanded with cohesion-decline-during-evolution and function-extraction-as-class-discovery signals; compact updated to match
* **v1.2.0** (2026-04-29): Core Responsibility #6 updated to require is-a justification for inheritance; Anti-Pattern #10 replaced fixed-depth rule with justification-based framing; compact updated to add postpone decisions, program to interfaces, DIP ownership nuance, SRP data-object exclusion, indent threshold correction
* **v1.1.0** (2026-04-29): Added end-goal framing; Abstraction Level Principle section; SRP business-context framing, 25-word diagnostic, cohesion threshold; OCP reframe and interface-based achievement mechanism; LSP 7 formal requirements and abstraction-first check; ISP semantic coupling; DIP interface ownership clarification; Clean Code expansion (CQS, abstraction level consistency, indent diagnostic, Special Case Pattern, function arg signal, Law of Demeter levels, polymorphism placement, separate construction, postpone decisions, concurrency signal); Beck's 4 Simple Design Rules; composition over inheritance and program-to-interface in Core Responsibilities; high coupling anti-pattern
* **v1.0.0** (2025-02-16): Initial creation
