```yaml
---
name: language-specific-implementation
description: Implements features using the idioms, best practices, and runtime nuances of the target language, producing correct, maintainable, idiomatic code.
version: 1.1.0
category: Engineering
tags: [language, idioms, runtime, implementation, platform]
priority: Medium
depends_on: []
flags_skills: [framework-mastery, regression-prevention, correctness-validation, test-creation-strategy]
inputs: [functional-requirements, platform-runtime-constraints, language-version]
outputs: [idiomatic-production-code, language-gotcha-notes, tradeoff-log]
rules_applied:
  - DA-1
  - PC-1
  - DT-1
documents_needed: [language-version-docs, project-style-guide, existing-codebase-conventions]
execution_context: Activates at Stage 7 on any feature implementation where language-specific idioms, runtime behavior, or platform constraints are relevant.
---
```

---

# Skill: Language-Specific Implementation

---

## Purpose

**What this skill does:**
Implements features using idiomatic constructs, stdlib capabilities, and runtime-aware patterns of the target language. Ensures code is functionally correct, natural to the language ecosystem, and free from language-specific anti-patterns.

Reduces maintenance cost and incident rate from language-specific bugs; accelerates team onboarding.

Correct idiom use enables compiler and runtime optimizations, reducing memory pressure without requiring later optimization passes.

---

## When to Use This Skill

### Triggers:

* New feature implementation where the target language has idiomatic solutions
* Language-specific runtime behavior (GC, GIL, async model, ownership) must be accounted for
* Code review flags non-idiomatic constructs causing correctness or maintainability issues
* Porting logic between languages — idioms do not translate directly
* Performance concern suspected to stem from a language anti-pattern rather than algorithmic inefficiency
* Adopting a new language version with updated idiomatic patterns

### Do NOT use this skill for:

* Framework lifecycle patterns → **framework-mastery**
* Algorithmic optimization → **performance-optimization**
* Cross-cutting architecture decisions → **system-design** or **modularity**
* Static analysis setup → **static-analysis**

**Execution Context:**
Runs at Stage 7 (feature development). Flags **framework-mastery** if framework integration is needed; flags **regression-prevention**, **correctness-validation**, and **test-creation-strategy** after code is produced.

---

## Inputs

**Required:**

* **Functional requirements** — Expected behavior, inputs, and outputs of the feature.
* **Platform and runtime constraints** — Language version, runtime environment, and performance or memory bounds.
* **Language features and stdlib** — Constructs available and permitted in the project.

**Optional:**

* **Project style guide** — Team conventions that may constrain idiom choices.
* **Existing codebase conventions** — Established patterns; new code must be consistent unless deviation is deliberate and logged.

**Documents needed:**

* **Language version release notes** — To identify available idioms and deprecated constructs.
* **Project coding standards** — To resolve conflicts between idiomatic practice and team convention.

---

## Outputs

**Primary:**

* **Production-ready idiomatic code** — Implementation using correct idioms, stdlib where appropriate, and runtime-aware patterns.
* **Language-specific gotcha notes** — Non-obvious language behaviors encountered during implementation.
* **Tradeoff log** — DT-1 entries for cases where language constraints forced design deviations.

**Output format:**

* Inline comments where language behavior requires explanation
* DT-1 log entry per constraint-forced deviation: deviation, reason, alternatives considered

---

## Preconditions

* Language and version confirmed from project config.
* Functional requirements clear enough to determine idiomatic approach.
* Language-version constraints (minimum version, deprecated features) known.

**Validation checks:**

* [ ] Language version confirmed and documented
* [ ] Existing codebase patterns reviewed for consistency (DA-1)
* [ ] Language-specific performance or correctness constraints identified

---

## Step-by-Step Execution Procedure

### Step 1: Identify Language and Version Context

**Questions to answer:**
- What language/version is the target runtime, and are modern idioms available and permitted?
- Does the codebase establish conventions that constrain idiom selection?

**Actions:**
- [ ] Confirm language version from project config (pyproject.toml, pom.xml, package.json, etc.)
- [ ] Review existing codebase for established patterns (DA-1)
- [ ] Note language-specific runtime characteristics relevant to this feature

**Watch-fors:** Requirements written for a different language (e.g., Java-style getter/setter design in Python); missing version constraint — risk of using unavailable features.

**Decisions:** If modern idiom is available and permitted → use it. If it conflicts with existing patterns → match existing and log deviation via DT-1.

---

### Step 2: Design the Idiomatic Implementation

**Questions to answer:**
- What is the idiomatic solution, and does it need to account for runtime behavior (GC, GIL, async)?
- Is there a stdlib construct that avoids reinventing the wheel?

**Actions:**
- [ ] Identify applicable idioms: generators, comprehensions, destructuring, pattern matching, type inference, etc.
- [ ] Assess runtime implications: allocation rate, blocking calls, ownership transfer
- [ ] Prefer stdlib over custom implementation (DA-5)

**Watch-fors:** Custom implementation of something in stdlib; blocking I/O inside async code; mutable shared state without synchronization rationale.

**Decisions:** If idiom conflicts with cross-module consistency → assess whether existing pattern is itself an anti-pattern; if yes, use idiom and flag technical-debt-management; if no, match existing and log via DT-1. If performance idiom reduces readability → confirm via PC-2 before proceeding.

---

### Step 3: Implement and Validate Correctness

**Questions to answer:**
- Does the implementation handle language-specific edge cases (integer overflow, None coercion, lazy evaluation)?
- Are there hidden language-specific failure modes?

**Actions:**
- [ ] Implement using chosen idioms
- [ ] Verify correctness against known language-specific edge cases
- [ ] Check runtime characteristics if performance-sensitive (PC-1)

**Watch-fors:** Silent failure modes (Python `None` from mutation methods, JS `undefined`); copy vs reference confusion in collection assignments.

**Decisions:** If correctness cannot be guaranteed → block (PC-5) → surface the language behavior → require confirmation. If language constraint forces non-ideal design → log via DT-1.

---

### Step 4: Document Language-Specific Behaviors

**Questions to answer:**
- What non-obvious language behaviors did this rely on, and what would break if ported?

**Actions:**
- [ ] Add inline comments on non-obvious idioms
- [ ] Note version-specific behaviors or constraints
- [ ] Write DT-1 entry if design deviated due to language constraints
- [ ] Flag **regression-prevention**, **correctness-validation**, **test-creation-strategy**

---

### Final Step: Generate Output Report

**Output structure:**

```markdown
## Language-Specific Implementation Report

**Target:** [Feature or module implemented]
**Language/Version:** [e.g., Python 3.11, Java 17, TypeScript 5.x]
**Status:** ✅ COMPLETE / ⚠️ TRADEOFFS LOGGED / ❌ BLOCKED

### Idioms Applied
- [Idiom]: [Where applied and why]

### Language-Specific Gotchas
- [Gotcha]: [Description and how handled]

### Tradeoff Log (DT-1)
- [Deviation]: [What deviated, why, alternatives considered]

### Skills Flagged for Follow-up
- **framework-mastery**: [If framework adaptation needed]
- **regression-prevention / correctness-validation / test-creation-strategy**: [After code produced]

### Overall Assessment
- ✅ COMPLETE: Implementation is idiomatic, correct, and consistent with codebase
- ⚠️ TRADEOFFS LOGGED: Language constraint forced non-ideal design; logged and approved
- ❌ BLOCKED: Language constraint cannot be resolved without stakeholder input
```

---

## Core Responsibilities

1. Confirm language version from project config before selecting idioms
2. Validate idiom against existing codebase patterns (DA-1)
3. Prefer stdlib over custom implementations
4. Account for runtime behavior (GC, GIL, async model, ownership)
5. Log language-constraint deviations via DT-1
6. Flag framework-mastery when framework lifecycle integration is needed; flag regression-prevention, correctness-validation, and test-creation-strategy after code is produced

**Quality criteria:** Code is idiomatic with no language-specific anti-patterns; tradeoff log present if any compromise was made; runtime implications documented for performance-sensitive paths.

---

## Constraints (Rules Applied)

* **DA-1: SOLID & Clean Code First** — Idiomatic code must respect structural principles; language idioms are a style layer, not a structural override.
* **PC-1: Analyze Complexity** — Estimate language-runtime complexity: GIL contention, GC pause frequency, allocation rate.
* **DT-1: Explicit Tradeoff Logging** — Log all cases where language constraints force non-ideal design — deviation, reason, alternatives considered.

---

## Tradeoff Handling

### Language Idiom vs Cross-Module Consistency

**Scenario:** Idiomatic approach conflicts with an existing module pattern.

**Default stance:** Assess whether the existing pattern is itself an anti-pattern before deferring to it.

**Resolution:** If existing pattern is a language anti-pattern → use idiom; recommend migration; flag technical-debt-management. If intentional → match it; log deviation via DT-1. If inconsistency scope is large → escalate before proceeding.

---

### Performance Idiom vs Readability

**Scenario:** A language-level performance technique significantly reduces readability.

**Default stance:** Prefer readability; log performance debt unless impact is confirmed material.

**Resolution:** If impact is material → confirm via PC-2; if confirmed, implement with inline comments; if not, use readable version and log via DT-1.

---

## Failure & Escalation Behavior

### Framework-Specific Adaptation Required

**Trigger:** Implementation requires framework lifecycle integration beyond pure language idioms.

**Action:** Flag **framework-mastery** with context of what integration is needed. Continue pure language layer; mark framework integration point as pending.

**Escalation format:** *(use only when user decision is required)*
```
⚡ FRAMEWORK MASTERY NEEDED

Issue: Implementation requires [framework] lifecycle integration
Context: [Specific hook/annotation/config needed]
Language layer: Complete
Framework layer: Pending

Question: Should framework integration proceed in this task or be scoped separately?
```

---

### Language Constraint Forces Non-Ideal Design

**Trigger:** Language runtime or feature gap forces a design deviation from clean code principles.

**Action:** Log via DT-1. Explain the constraint. Request confirmation if impact is non-trivial (PC-2).

---

### Correctness Cannot Be Guaranteed

**Trigger:** Language-specific behavior introduces a correctness risk that cannot be fully mitigated.

**Action:** Block (PC-5). Surface the specific language behavior. Require explicit confirmation before proceeding.

---

### When to halt:

* Language version unconfirmed and version-specific idioms are in play
* Language-specific correctness risk cannot be mitigated
* Idiom produces design inconsistency requiring architectural review

---

## Skill Integration & Orchestration

**Role in pipeline:** Runs at Stage 7; independent of other skills at runtime. Flags framework-mastery when integration is needed, then gates into regression-prevention, correctness-validation, and test-creation-strategy as mandatory post-implementation checks.

### How This Skill Integrates

**Does NOT directly call other skills.** Instead, this skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes this skill based on implementation intent
2. This skill implements the feature using correct language idioms
3. This skill **flags framework-mastery** if framework integration is needed
4. **Orchestrator** invokes framework-mastery if flagged; this skill then flags regression-prevention, correctness-validation, test-creation-strategy after code is produced

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Framework lifecycle integration needed | framework-mastery | Language idioms alone insufficient; framework conventions required |
| Implementation complete | regression-prevention | Validate no regressions in existing paths |
| Implementation complete | correctness-validation | Validate against business requirements |
| New code paths produced | test-creation-strategy | Ensure new paths have coverage |
| Performance anomaly traced to language pattern | runtime-analysis | Profiling needed to confirm language-level cause |
| Language constraint produces non-ideal design | technical-debt-management | Constraint-forced deviation should be tracked as debt |

---

## Related Skills

**Skills this skill depends on:** None.

**Skills this skill cooperates with:**

* **framework-mastery** — Language idioms are the base layer; framework patterns are the integration layer.
* **performance-optimization** — Language anti-patterns detected here may trigger deeper algorithmic optimization.
* **correctness-validation** — Validates that idiomatic implementations are also correct against requirements.

---

## Governance Hooks

* [ ] Log all tradeoff decisions via DT-1 when language constraints force non-ideal design
* [ ] Explain risks before implementing non-obvious language behavior (GM-2)
* [ ] Do not proceed past a correctness risk without explicit confirmation (PC-5)
* [ ] Maintain codebase consistency unless deviation is documented (DA-1)
* [ ] Always flag regression-prevention, correctness-validation, test-creation-strategy after producing code

---

## Example Use Cases

### General: Python Generator for Memory-Efficient Streaming

A Lambda function must process a 10M-row CSV in a 512 MB memory-constrained environment. The initial implementation loads the full file into memory, causing OOM. This skill identifies the Python generator idiom (`yield` row-by-row) as the correct solution, reducing peak memory from ~2 GB to ~50 MB. An inline comment explains the GC behavior; regression-prevention, correctness-validation, and test-creation-strategy are flagged after implementation.

### Edge Case: Mutable Default Argument Bug in Python

A utility function uses `def process(items=[])` — state persists across calls, a common trap for developers from other language backgrounds. This skill applies the `None` sentinel idiom, adds an inline comment explaining why mutable defaults are dangerous in Python, and logs DT-1 with the deviation context.

---

## Anti-Patterns to Catch

❌ **Mutable defaults (Python):** `def f(x=[])` mutates the default for all future callers. ✅ Use `None` sentinel: `if x is None: x = []`.

❌ **Blocking I/O in async:** Calling a blocking function inside `async def` without offloading. ✅ Use `asyncio.to_thread()` (Python), `Task.Run` (C#), or truly non-blocking calls.

❌ **Reference aliasing:** `a = b` for lists/dicts copies the reference; mutations to `a` affect `b`. ✅ Use `copy.deepcopy()` (Python) or `{ ...obj }` (JS) when independent copies needed.

❌ **Java-style getters/setters in Python:** Explicit `getX()`/`setX()` instead of `@property`. ✅ Use `@property` and `@attr.setter`.

❌ **Bare Exception/Throwable:** Suppresses system exits and unrelated errors. ✅ Catch specific types; re-raise or log others.

❌ **Autoboxing in loops (Java):** `Integer` in tight loops causes repeated heap allocation. ✅ Use primitives (`int[]` over `List<Integer>`) in hot paths.

❌ **`var` in JS closures:** `var` is function-scoped; closures in loops share the same binding. ✅ Use `let` or `const` for block-scoped bindings per iteration.

❌ **Modifying collection while iterating:** Undefined behavior or `ConcurrentModificationException`. ✅ Collect changes separately, apply after iteration.

❌ **Reinventing stdlib:** Custom retry/parse/serialize instead of well-tested stdlib. ✅ Prefer stdlib or ecosystem-standard constructs.

❌ **Ignoring runtime model:** Assuming identical performance across runtimes when porting. ✅ Account for JVM warm-up, Python GIL, Node.js single-threaded event loop.

---

## Non-Goals

* ❌ Framework lifecycle patterns — **framework-mastery**
* ❌ Algorithmic optimization — **performance-optimization**
* ❌ Concurrency primitives and thread safety — **concurrency-handling**
* ❌ Async design architecture — **async-design-patterns**
* ❌ Platform-level tuning (JVM flags, GC config) — **platform-specific-optimization**

**Boundary clarifications:**

* Language idioms end where framework conventions begin — lifecycle hooks, decorators, or DI containers delegate to framework-mastery.
* Language-level performance (allocation, GC, GIL) is in scope; algorithmic complexity and data structure choice are not.

---

## Notes for LLM Implementation

1. Confirm language version first — never assume; check project config before selecting idioms; specify version when behavior is version-specific.
2. Prefer stdlib — look for standard library equivalents before proposing custom implementations.
3. Be explicit about runtime implications — mention GC, GIL, ownership, or async model impact when it matters; add inline comments for non-obvious idioms.
4. Cite the specific anti-pattern by name — "mutable default argument", not just "bug".
5. Log DT-1 on every language-constraint deviation.

---
