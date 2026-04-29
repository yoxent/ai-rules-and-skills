```yaml
---
name: concurrency-handling
description: Designs, implements, and audits concurrent execution for thread safety, correctness, and efficient resource utilization using language-appropriate primitives.
version: 1.0.0
category: Language & Platform Skills
tags: [concurrency, thread-safety, synchronization, deadlock, race-condition]
priority: Medium

depends_on: [language-specific-implementation]
flags_skills: [async-design-patterns, runtime-analysis]

inputs: [functional-requirements, concurrency-model, data-consistency-requirements, existing-concurrency-patterns]
outputs: [thread-safe-implementations, concurrency-audit-report, race-condition-findings]

rules_applied:
  - DA-1  # SOLID & Clean Code First — concurrency must be encapsulated, not scattered
  - PC-1  # Analyze Complexity — include concurrency overhead and contention in analysis
  - PC-2  # Tradeoff Confirmation — correctness/throughput conflicts require confirmation
  - TQ-1  # Test Coverage Requirement — concurrent code requires concurrency-aware tests

documents_needed: [language-concurrency-model-docs, codebase-concurrency-patterns]
execution_context: Activated when implementing concurrent features, auditing existing concurrency, or diagnosing non-deterministic bugs.
---
```

# Skill: Concurrency Handling

---

## Purpose

**What this skill does:**
Designs, implements, and audits concurrent execution patterns — threading, locking, synchronization — to ensure shared state is protected, deadlocks are prevented, and lock granularity is optimized without sacrificing correctness.

Race conditions and deadlocks are among the most expensive defects in production — they are non-deterministic, environment-dependent, and notoriously difficult to reproduce and fix. Prevention at implementation time is far cheaper than diagnosis in production.

Correct concurrency is a prerequisite for reliable multi-threaded systems. Lock granularity directly affects throughput. Encapsulating concurrency concerns prevents synchronization leaking throughout the codebase.

---

## When to Use This Skill

### Triggers:
* Implementing a feature that involves shared mutable state
* Auditing existing concurrent code for correctness
* Diagnosing a non-deterministic or load-dependent bug
* Reviewing a proposed lock-free data structure or pattern
* Contention or throughput bottleneck under concurrent load

### Do NOT use this skill for:
* Non-blocking async patterns (event loop, async/await) — delegate to `async-design-patterns`
* Performance profiling of concurrency bottlenecks — delegate to `runtime-analysis`
* Language-level concurrency primitive selection — first consult `language-specific-implementation`

---

## Inputs

**Required inputs:**
* **Functional requirements involving concurrent execution** — what needs to run concurrently and why
* **Language and runtime concurrency model** — threads, fibers, coroutines, actors, CSP
* **Data consistency and ordering requirements** — what invariants must hold under concurrency
* **Existing concurrency patterns** — for consistency with codebase (DA-7 via DA-1)

---

## Outputs

**Primary outputs:**
* **Thread-safe implementation** — correct synchronization with documented contract
* **Concurrency audit report** — race conditions, deadlock risks, contention points identified
* **Test requirements** — race detection tests and stress scenarios

**Skill flags:**
* Flag **async-design-patterns** when non-blocking patterns are more appropriate
* Flag **runtime-analysis** when contention manifests as a performance bottleneck

---

## Preconditions

* Language and runtime concurrency model confirmed
* [ ] Consistency and ordering requirements understood
* [ ] Existing concurrency patterns in the codebase reviewed

---

## Step-by-Step Execution Procedure

### Step 1: Identify Shared Mutable State

**Actions:**
- [ ] Enumerate all shared state that will be accessed from multiple threads
- [ ] Classify each as read-heavy, write-heavy, or mixed
- [ ] Identify consistency invariants that must hold under concurrent access

**Red flags:**
- Shared state with no synchronization annotation or contract
- Mutable global state accessed from multiple threads

---

### Step 2: Select Synchronization Strategy

**Actions:**
- [ ] Choose appropriate primitive: mutex, read-write lock, atomic, immutable, message-passing
- [ ] Minimize lock scope — hold locks for the shortest necessary duration
- [ ] Verify strategy is language-idiomatic (consult `language-specific-implementation` if needed)

**Decision points:**
- If async/non-blocking model is more appropriate: flag `async-design-patterns`
- If correctness and throughput conflict: request PC-2 confirmation

---

### Step 3: Detect Deadlock and Livelock Risk

**Actions:**
- [ ] Map all lock acquisition order across the codebase
- [ ] Verify no cycles exist in lock acquisition order
- [ ] Check for locks held across blocking calls or I/O

**Red flags:**
- Two locks acquired in different orders in different code paths (deadlock precondition)
- Lock held while waiting on external resource (I/O, network)

---

### Step 4: Validate Concurrency Contracts

**Actions:**
- [ ] Document thread-safety contract in public API (thread-safe / not thread-safe / conditionally thread-safe)
- [ ] Verify concurrency contract is enforced by implementation

---

### Step 5: Require Concurrency Tests

**Actions:**
- [ ] Flag `test-creation-strategy` if no concurrency-aware tests exist
- [ ] Specify required test scenarios: race condition stress test, deadlock detection, correctness under concurrent load

---

### Final Step: Generate Report

```markdown
## Concurrency Handling Report

**Language/Runtime:** [e.g. Java 21 / virtual threads]
**Status:** ✅ SAFE / ⚠️ RISK IDENTIFIED / ❌ CORRECTNESS VIOLATION

### Shared State Inventory
[State: access pattern: synchronization primitive: contract]

### Race Condition Findings
[Finding: location: risk level: remediation]

### Deadlock Risk Assessment
[Lock acquisition order map; cycles identified]

### API Concurrency Contracts
[Public API: documented thread-safety contract]

### Required Concurrency Tests
[Test scenarios required]

### Skills Flagged
- **async-design-patterns**: [if non-blocking approach preferred]
- **runtime-analysis**: [if contention is a throughput bottleneck]
```

---

## Core Responsibilities

1. Identify all shared mutable state and require documented synchronization
2. Select appropriate synchronization primitives, minimizing lock scope
3. Detect deadlock risk through lock acquisition order analysis
4. Document concurrency contracts on all public APIs
5. Require concurrency-aware tests

---

## Constraints (Rules Applied)

* **DA-1** — Concurrency concerns must be encapsulated; synchronization primitives must not leak across abstraction boundaries
* **PC-1** — Include concurrency overhead and contention cost in complexity analysis
* **PC-2** — When correctness and throughput conflict, request explicit confirmation before proceeding
* **TQ-1** — Concurrent code requires tests covering race conditions, stress scenarios, and correctness under load

---

## Tradeoff Handling

### Tradeoff 1: Correctness vs. Throughput

```
Conflict: Fine-grained locking improves throughput but increases deadlock risk
→ Default to correctness; document throughput cost
→ Request PC-2 confirmation before accepting throughput-motivated correctness tradeoff
→ Log via DT-1
```

### Tradeoff 2: Simplicity vs. Performance

```
Conflict: Immutable data and message-passing are safer but trade memory efficiency
→ Prefer safety by default
→ Justify with benchmark data before choosing mutable shared state with locks
```

---

## Anti-Patterns to Catch

❌ **Synchronized method wrapping entire class — coarse-grained locking**
✅ Minimize lock scope; use field-level locks or concurrent data structures

❌ **Acquiring locks in inconsistent order across code paths**
✅ Establish and document a total ordering of all locks; enforce it

❌ **Holding a lock while calling a blocking external API**
✅ Release lock before external call; reacquire after

❌ **Thread-safety not documented on public API**
✅ Every public class/method must declare its thread-safety contract

❌ **Double-checked locking without volatile (Java pre-Java 5 pattern)**
✅ Use `volatile`, `AtomicReference`, or language-idiomatic lazy initialization

❌ **Using thread-local to smuggle state across async boundaries**
✅ Pass state explicitly; thread-local storage does not transfer across thread switches

---

## Non-Goals

* ❌ Async/event-loop patterns — handled by `async-design-patterns`
* ❌ Runtime profiling of contention — handled by `runtime-analysis`
* ❌ Language-specific primitive selection — handled by `language-specific-implementation`

---

## Metadata Summary

```yaml
name: concurrency-handling
category: Language & Platform Skills
priority: Medium
depends_on: [language-specific-implementation]
flags_skills: [async-design-patterns, runtime-analysis]
rules_applied: [DA-1, PC-1, PC-2, TQ-1]
documents_needed: [language-concurrency-model-docs, codebase-concurrency-patterns]
tags: [concurrency, thread-safety, synchronization, deadlock, race-condition]
```
