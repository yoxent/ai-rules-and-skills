```yaml
---
name: memory-management
description: Ensures efficient memory allocation, deallocation, and usage patterns to prevent leaks, control footprint, and maintain stability under load.
version: 1.0.0
category: Language & Platform Skills
tags: [memory, gc, leaks, object-lifecycle, footprint]
priority: Medium

depends_on: [runtime-analysis]
flags_skills: [platform-specific-optimization]

inputs: [runtime-environment, application-data-structures, workload-characteristics]
outputs: [memory-usage-report, leak-identification, gc-tuning-parameters]

rules_applied:
  - PC-1  # Analyze Complexity — quantify memory in space-complexity terms
  - PC-4  # Performance Budget — memory footprint must fit within defined budgets
  - DA-5  # Avoid Overengineering — micro-optimizations require measurable evidence

documents_needed: [runtime-gc-model-docs, memory-profiling-data, performance-budget]
execution_context: Activated after runtime-analysis identifies memory as a bottleneck, or when memory leaks or GC pressure is suspected.
---
```

# Skill: Memory Management

---

## Purpose

**What this skill does:**
Analyzes application memory usage patterns to detect leaks, excessive GC pressure, and inefficient allocation strategies. Produces evidence-based recommendations for improving memory efficiency and stability under sustained load.

Memory leaks cause gradual performance degradation that manifests as production incidents. GC pressure causes latency spikes that directly affect user experience. Memory budget overruns increase infrastructure cost.

Understanding object lifecycle and allocation patterns is fundamental to building systems that remain stable under sustained load. Memory management decisions have non-linear consequences — a small allocation pattern change can halve GC frequency.

---

## When to Use This Skill

### Triggers:
* Runtime analysis has identified memory as the bottleneck
* GC pause times are causing latency spikes
* Application exhibits gradual memory growth under sustained load
* Memory footprint exceeds defined performance budget
* Object pool or caching strategy is being considered

### Do NOT use this skill for:
* Runtime profiling collection — that is `runtime-analysis` (dep)
* GC configuration tuning (JVM flags, .NET settings) — delegate to `platform-specific-optimization`
* Architectural data model decisions — delegate to `abstraction-domain-modeling`

---

## Inputs

**Required inputs:**
* **Runtime environment and GC model** — managed (JVM, .NET, Python), reference-counted (Swift, Rust), or manual (C/C++)
* **Memory profiling data** — from `runtime-analysis`; allocation rate, heap snapshot, GC metrics
* **Workload characteristics** — allocation rate, object lifetimes, load pattern

---

## Outputs

**Primary outputs:**
* **Memory usage report** — allocation patterns, GC frequency, heap snapshot analysis
* **Leak identification** — objects growing without bound; reference chains preventing collection
* **GC tuning parameters** — recommendations for GC configuration (passed to `platform-specific-optimization`)

**Skill flags:**
* Flag **platform-specific-optimization** when GC tuning requires runtime-level configuration changes

---

## Preconditions

* Runtime profiling data available from `runtime-analysis`
* [ ] Runtime environment and GC model identified
* [ ] Memory budget defined

---

## Step-by-Step Execution Procedure

### Step 1: Analyze Allocation Patterns

**Actions:**
- [ ] Review top allocation sites by volume and frequency
- [ ] Classify objects by lifetime (short-lived, medium, long-lived)
- [ ] Identify allocation patterns causing GC pressure (high-frequency short-lived allocations)

---

### Step 2: Detect Leaks

**Actions:**
- [ ] Compare heap snapshots taken at t=0, t=10min, t=30min under steady load
- [ ] Identify object types growing monotonically
- [ ] Trace reference chains preventing GC collection

---

### Step 3: Assess GC Configuration

**Actions:**
- [ ] Review GC algorithm in use vs. workload characteristics
- [ ] Identify tuning parameters that could reduce pause frequency or duration
- [ ] Flag GC tuning to `platform-specific-optimization`

---

### Step 4: Validate Recommendations Against Budget

**Actions:**
- [ ] Verify recommendations result in footprint within PC-4 budget
- [ ] Reject micro-optimizations without measured impact (DA-5)

---

### Final Step: Generate Report

```markdown
## Memory Management Report

**Runtime:** [JVM 17 / .NET 7 / CPython 3.11 / etc.]
**GC Model:** [G1GC / GC generational / reference counting]
**Status:** ✅ STABLE / ⚠️ LEAK DETECTED / ❌ BUDGET EXCEEDED

### Allocation Pattern Analysis
[Top allocators by volume; object lifetime distribution]

### Leak Analysis
[Objects growing without bound; reference chains]

### GC Metrics
[Pause frequency, pause duration, allocation rate vs. collection rate]

### Recommendations
1. [Highest impact: expected improvement: evidence basis]

### GC Tuning Flags (if applicable)
[Pass to platform-specific-optimization]

### Skills Flagged
- **platform-specific-optimization**: [GC tuning parameters needed]
```

---

## Core Responsibilities

1. Analyze allocation patterns using runtime profiling data
2. Detect memory leaks via heap snapshot comparison
3. Assess GC pressure and identify tuning opportunities
4. Validate recommendations fit within performance budget
5. Flag GC tuning to `platform-specific-optimization`

---

## Constraints (Rules Applied)

* **PC-1** — Quantify memory in space-complexity terms; require profiling data before recommendations
* **PC-4** — Memory footprint must stay within defined infrastructure and reliability budget
* **DA-5** — Reject micro-optimizations without measurable evidence; object pooling requires allocation rate justification

---

## Tradeoff Handling

### Tradeoff 1: Memory Efficiency vs. CPU Usage

```
Conflict: Object pooling reduces allocation rate (memory win) but adds pool-management CPU overhead
→ Require allocation rate evidence to justify pool overhead cost
→ Log via DT-1
→ Fallback: Do not pool without evidence
```

### Tradeoff 2: Optimization Complexity vs. Maintainability

```
Conflict: Manual memory management in a GC language (unsafe Rust, JNI direct buffers)
→ Require DT-2 confirmation
→ Log via DT-1 with performance justification
→ Fallback: Use GC-managed path; accept measured performance difference
```

---

## Anti-Patterns to Catch

❌ **Object pooling without measured allocation rate**
✅ Profile first; pool only when per-request allocation rate justifies pool overhead

❌ **Cache with no eviction policy — memory grows without bound**
✅ All caches must have explicit eviction (LRU, TTL, max size)

❌ **Event listener registered but never deregistered**
✅ Deregister in teardown; use WeakReference where appropriate

❌ **Closures capturing large objects longer than needed**
✅ Release references explicitly when the closure lifecycle exceeds the captured object's needed lifetime

❌ **Ignoring GC pause metrics as "just GC"**
✅ GC pauses directly affect user-facing latency; treat as first-class performance metric

---

## Non-Goals

* ❌ Runtime profiling collection — handled by `runtime-analysis`
* ❌ GC flag tuning — handled by `platform-specific-optimization`
* ❌ Architectural data model changes — handled by `abstraction-domain-modeling`

---

## Metadata Summary

```yaml
name: memory-management
category: Language & Platform Skills
priority: Medium
depends_on: [runtime-analysis]
flags_skills: [platform-specific-optimization]
rules_applied: [PC-1, PC-4, DA-5]
documents_needed: [runtime-gc-model-docs, memory-profiling-data, performance-budget]
tags: [memory, gc, leaks, object-lifecycle, footprint]
```
