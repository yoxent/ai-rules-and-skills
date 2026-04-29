```yaml
---
name: async-design-patterns
description: Designs and implements asynchronous workflows with correct error propagation, cancellation semantics, and resource management using language-appropriate async patterns.
version: 1.1.0
category: Language & Platform Skills
tags: [async, non-blocking, error-propagation, cancellation, promises]
priority: Medium

depends_on: [language-specific-implementation]
flags_skills: [concurrency-handling, error-handling-resilience, test-creation-strategy, correctness-validation, regression-prevention]

inputs: [functional-requirements, framework-async-capabilities, resource-constraints]
outputs: [async-implementation, error-propagation-strategy, task-scheduling-design]

rules_applied:
  - DA-1
  - PC-2
  - TQ-1
  - GM-2

documents_needed: [language-async-model-docs, framework-async-docs, existing-async-patterns]
execution_context: Activated on non-blocking feature implementation, async refactoring, or when responsiveness concerns make synchronous code inadequate.
---
```

# Skill: Async Design Patterns

---

## Purpose

**What this skill does:**
Designs and implements asynchronous workflows using language-appropriate patterns (async/await, promises, observables, reactive streams) with correct error propagation, cancellation handling, and resource lifecycle management.

Async patterns are essential for responsive systems — blocking I/O on a request thread degrades throughput dramatically under load. Incorrect async implementation (swallowed errors, unbounded queues) creates hard-to-diagnose production failures.

Correct async error propagation is notoriously difficult. Explicit handling of cancellation, timeouts, and resource cleanup in async code prevents entire classes of resource leak and silent failure bugs.

---

## When to Use This Skill

### Triggers:
* Implementing a non-blocking operation (I/O, HTTP call, database query)
* Refactoring synchronous code to async for responsiveness
* Designing a task pipeline or event-driven workflow
* Reviewing async code for error handling and resource management
* Diagnosing swallowed errors or resource leaks in async code

### Do NOT use this skill for:
* Thread-based concurrency (locks, shared state) — delegate to `concurrency-handling`
* Error handling framework design — delegate to `error-handling-resilience`
* Language-level async primitive selection — first consult `language-specific-implementation`

---

## Inputs

**Required inputs:**
* **Functional requirements for non-blocking operations** — what must be async and why
* **Framework and language async capabilities** — async/await, Promises, RxJS, asyncio, etc.
* **Resource and concurrency constraints** — max concurrent tasks, queue bounds

---

## Outputs

**Primary outputs:**
* **Async implementation** — non-blocking code with correct error handling and cancellation
* **Error propagation strategy** — documented plan for how errors surface from async boundaries
* **Task scheduling design** — bounded queues, backpressure, resource limits

**Skill flags:**
* Flag **concurrency-handling** when thread-based coordination is needed alongside async, or when async scope cannot be contained and leaks across layers requiring thread-level coordination
* Flag **error-handling-resilience** when async error propagation strategy has gaps
* Flag **test-creation-strategy** when cancellation, timeout, or error path tests are absent
* Flag **correctness-validation** when async implementation is complete and requires correctness verification
* Flag **regression-prevention** when async code is modified and existing behavior must be verified

---

## Preconditions

* Language and runtime async model confirmed
* [ ] Synchronous equivalent reviewed (is async actually needed?)
* [ ] Resource bounds defined (max concurrent tasks, queue size)

---

## Step-by-Step Execution Procedure

### Step 1: Justify Async (GM-2)

**Actions:**
- [ ] Confirm async is warranted — synchronous code is simpler; async must justify its complexity
- [ ] Explain error propagation consequences to stakeholders before implementing (GM-2)
- [ ] Document the async boundary: where synchronous code hands off to async

---

### Step 2: Design Error Propagation

**Actions:**
- [ ] Map all error paths across async boundaries
- [ ] Verify every async call site has an explicit error handler
- [ ] Document how errors surface to the caller

**Red flags:**
- `.catch()` / `except` missing at async call sites
- `try/except` not wrapping async calls
- Promise chains with no terminal error handler

---

### Step 3: Design Cancellation and Timeout

**Actions:**
- [ ] Implement cancellation token / AbortController / asyncio.CancelledError handling
- [ ] Set explicit timeouts on all external async calls
- [ ] Ensure resources are cleaned up on cancellation

---

### Step 4: Bound Resource Usage

**Actions:**
- [ ] Define maximum concurrent task count (semaphore, bounded executor)
- [ ] Define queue size bound with backpressure strategy
- [ ] Reject fire-and-forget patterns without explicit resource bound

---

### Step 5: Contain Async Scope (DA-1)

**Actions:**
- [ ] Verify async does not leak through every layer — define the async boundary explicitly
- [ ] Provide sync-over-async adapter if legacy synchronous callers exist
- [ ] Document adapter with rationale
- [ ] If async scope cannot be contained without thread-level coordination: flag `concurrency-handling`

---

### Step 6: Require Tests

**Actions:**
- [ ] Specify test scenarios: cancellation, timeout, error path, backpressure
- [ ] Flag `test-creation-strategy` if these tests are absent

---

### Final Step: Generate Report

```markdown
## Async Design Patterns Report

**Language/Framework:** [e.g. Python/asyncio, TypeScript/Promises, C#/Task]
**Status:** ✅ CORRECT / ⚠️ GAPS IDENTIFIED / ❌ CRITICAL ERROR HANDLING MISSING

### Error Propagation Assessment
[Every async boundary: handler present Y/N]

### Cancellation & Timeout
[Cancellation implemented: Y/N | Timeout on external calls: Y/N]

### Resource Bounds
[Queue bound: defined/unbounded | Max concurrency: defined/unbounded]

### Async Scope Containment
[Async leaking to all layers: Y/N]

### Required Tests
[Cancellation / timeout / error path / backpressure scenarios]

### Skills Flagged
- **concurrency-handling**: [thread-coordination needed]
- **error-handling-resilience**: [error propagation gaps]
```

---

## Core Responsibilities

1. Justify async use before implementing (GM-2 explanation)
2. Ensure all async error paths are explicit — no swallowed errors
3. Implement cancellation and timeout on all async operations
4. Bound resource usage with explicit queue limits and backpressure
5. Contain async scope to defined boundaries (DA-1)

---

## Constraints (Rules Applied)

* **DA-1** — Async complexity must not leak through all layers; define boundaries
* **PC-2** — Trading simplicity for responsiveness must be explicitly confirmed
* **TQ-1** — Cancellation, timeout, and error paths must all have test coverage
* **GM-2** — Explain async error propagation consequences before implementing

---

## Tradeoff Handling

### Tradeoff 1: Complexity vs. Responsiveness

**Conflict:** Async code is significantly harder to reason about and debug; synchronous is simpler.
**Resolution:** Default to synchronous unless async is measurably needed. Request PC-2 confirmation before async refactor. Log via DT-1.

### Tradeoff 2: Error Handling vs. Performance

**Conflict:** Proper async error handling (explicit catch everywhere) adds verbosity and minor overhead.
**Resolution:** Never trade error handling for performance — correctness is non-negotiable (PC-5). If overhead is measurable, log via DT-1 and document the accepted cost.

---

## Anti-Patterns to Catch

❌ **Unhandled promise rejections**
✅ Every promise chain must have a terminal `.catch()` or equivalent

❌ **Fire-and-forget without resource bound**
✅ All background tasks must be tracked; define max concurrency

❌ **async/await in constructors (TypeScript/C# anti-pattern)**
✅ Use factory methods for async initialization

❌ **Callback hell — deeply nested promise chains**
✅ Flatten with async/await or compose with named functions

❌ **Async leaking through every layer of the stack**
✅ Define async/sync boundary explicitly; use adapters for legacy callers

❌ **No cancellation support on long-running async operations**
✅ Propagate CancellationToken / AbortController through the entire async chain

---

## Failure & Escalation Behavior

### Async Error Propagation Gaps

**Trigger:** Async call sites lack explicit error handlers, or errors can be swallowed across async boundaries.

**Action:** Flag error-handling-resilience. Block the implementation until a complete error propagation strategy is designed. Each async boundary must have a documented handler.

---

### Required Tests Absent

**Trigger:** Implementation is complete but cancellation, timeout, backpressure, or error path tests are missing.

**Action:** Flag test-creation-strategy. Do not mark implementation complete until test scenarios for all async failure modes are specified.

---

### Correctness Verification Required

**Trigger:** Async implementation is complete and requires validation that error propagation, cancellation, and resource cleanup behave correctly.

**Action:** Flag correctness-validation to verify the async implementation against its specified behavior.

---

### Regression Risk from Async Modification

**Trigger:** Existing async code is modified — error handling, cancellation tokens, queue bounds, or scheduling logic changed.

**Action:** Flag regression-prevention to verify existing async behavior is not broken by the modification.

---

### When to halt execution:

* A required async boundary has no error handler and none can be designed without additional architectural input
* Async complexity cannot be contained without a synchronous adapter and the caller cannot be modified

---

## Non-Goals

* ❌ Thread-based concurrency — handled by `concurrency-handling`
* ❌ Error handling framework design — handled by `error-handling-resilience`
* ❌ Language-level async primitive selection — handled by `language-specific-implementation`

---
