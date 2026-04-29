```yaml
---
name: platform-specific-optimization
description: Applies platform-aware optimizations leveraging OS, hardware, runtime, or cloud environment to achieve measurable gains beyond general-purpose improvements.
version: 1.0.0
category: Language & Platform Skills
tags: [platform, optimization, performance, portability, runtime-tuning]
priority: Low

depends_on: [runtime-analysis, performance-optimization]
flags_skills: []

inputs: [platform-profile, profiling-data, workload-characteristics, general-implementation]
outputs: [platform-optimized-code, benchmark-comparisons, portability-impact-assessment]

rules_applied:
  - PC-1  # Analyze Complexity — quantify gains with benchmarks before applying changes
  - PC-2  # Tradeoff Confirmation — platform-specific code reduces portability; confirm explicitly
  - DA-5  # Avoid Overengineering — apply only after profiling data justifies complexity
  - DT-1  # Explicit Tradeoff Logging — log every platform-specific deviation

documents_needed: [platform-profile, runtime-tuning-docs, performance-profiling-data]
execution_context: Activated only after runtime-analysis has identified a bottleneck and performance-optimization has been exhausted for general improvements.
---
```

# Skill: Platform-Specific Optimization

---

## Purpose

**What this skill does:**
Applies platform-aware optimizations that exploit specific OS features, hardware architecture, runtime capabilities, or cloud environment characteristics to deliver measurable performance gains that cannot be achieved through general-purpose code improvements alone.

Platform-specific optimizations are the last resort — highest complexity, highest risk, but capable of delivering gains that no amount of algorithmic improvement can match (e.g. SIMD vectorization, `io_uring`, JVM GC tuning). They are justified only after all other optimization paths are exhausted.

Platform-specific code introduces tight coupling to the target environment. When justified and properly isolated, it provides capabilities that generic code cannot. When not isolated, it becomes a maintenance liability that breaks silently on platform changes.

---

## When to Use This Skill

### Triggers (all conditions must be met):
* `runtime-analysis` has identified a specific bottleneck with profiling data
* `performance-optimization` has been applied and general improvements are exhausted
* The target platform has specific features that address the identified bottleneck
* Business impact justifies the added complexity and portability cost

### Do NOT use this skill for:
* Any optimization work before `performance-optimization` is exhausted
* GC pressure and memory pattern work — start with `memory-management`
* Code-level algorithmic improvements — handled by `performance-optimization`

---

## Inputs

**Required inputs:**
* **Target platform profile** — OS, hardware architecture, runtime version, cloud provider
* **Performance profiling data** — from `runtime-analysis`; specific bottleneck identified
* **Workload characteristics** — CPU-bound, I/O-bound, memory-intensive
* **Existing general-purpose implementation** — the baseline being optimized

---

## Outputs

**Primary outputs:**
* **Platform-optimized code or configuration** — with isolation in platform-specific modules
* **Benchmark comparisons** — before/after with methodology documented
* **Portability impact assessment** — what breaks and on which platforms if this optimization is deployed

---

## Preconditions

* `runtime-analysis` profiling report available
* `performance-optimization` has been applied and general improvements exhausted
* [ ] Target platform confirmed
* [ ] Portability requirements understood

---

## Step-by-Step Execution Procedure

### Step 1: Validate Prerequisites

**Actions:**
- [ ] Confirm `runtime-analysis` data exists identifying the specific bottleneck
- [ ] Confirm `performance-optimization` has been applied
- [ ] Block if prerequisites not met

---

### Step 2: Identify Platform-Specific Capability

**Actions:**
- [ ] Map bottleneck type to platform feature (I/O → `io_uring`; CPU → SIMD; memory → NUMA-aware allocation; GC → tuning flags)
- [ ] Verify feature is available on all required deployment targets
- [ ] Assess portability impact across non-primary targets

---

### Step 3: Isolate Platform-Specific Code

**Actions:**
- [ ] Create isolated module or build target for platform-specific code
- [ ] Implement feature-detection fallback to general-purpose path
- [ ] Ensure shared modules remain portable

---

### Step 4: Benchmark

**Actions:**
- [ ] Run before/after benchmark under production-representative load
- [ ] Document methodology: load profile, environment, measurement duration
- [ ] Reject optimization if measured gain does not justify complexity cost

---

### Step 5: Confirm and Log

**Actions:**
- [ ] Request PC-2 confirmation on portability tradeoff
- [ ] Log every platform-specific deviation via DT-1
- [ ] Require prompt engineer approval before merging non-portable code

---

### Final Step: Generate Report

```markdown
## Platform-Specific Optimization Report

**Platform:** [OS / hardware / runtime version / cloud provider]
**Bottleneck Addressed:** [From runtime-analysis report]
**Status:** ✅ APPROVED / ⚠️ PENDING CONFIRMATION / ❌ INSUFFICIENT EVIDENCE

### Benchmark Results
| Metric | Before | After | Delta |
|--------|--------|-------|-------|

### Portability Impact
[Platforms affected: what breaks: mitigation]

### Isolation Assessment
[Platform-specific code isolated: Y/N | Shared modules portable: Y/N]

### Tradeoff Log (DT-1)
- [Deviation]: [Platform constraint]: [Justification]

### Confirmation Required
- PC-2 portability tradeoff confirmation: [OBTAINED / PENDING]
```

---

## Core Responsibilities

1. Block activation until `runtime-analysis` and `performance-optimization` prerequisites are met
2. Identify platform features that address the specific measured bottleneck
3. Isolate all platform-specific code from shared modules
4. Produce before/after benchmarks with documented methodology
5. Log all deviations via DT-1 and obtain PC-2 confirmation

---

## Constraints (Rules Applied)

* **PC-1** — Quantify gains with benchmarks; reject without measurement evidence
* **PC-2** — Platform-specific code reduces portability; explicit confirmation required
* **DA-5** — Apply only after profiling data justifies added complexity
* **DT-1** — Log every platform-specific deviation from the general implementation

---

## Tradeoff Handling

### Tradeoff 1: Performance Gains vs. Portability

```
Conflict: Platform optimization delivers 40% throughput gain but ties code to Linux 5.1+
→ Require PC-2 confirmation with explicit acknowledgment of portability loss
→ Require isolation in platform-specific build target
→ Log via DT-1
→ Fallback: Accept general-purpose performance if portability is non-negotiable
```

### Tradeoff 2: Optimization Depth vs. Maintainability

```
Conflict: Micro-optimization significantly increases code complexity
→ Require benchmark evidence showing measurable gain
→ Request DA-5 justification: is the gain worth the maintenance cost?
→ Log via DT-1
```

---

## Anti-Patterns to Catch

❌ **Platform optimization before profiling**
✅ Block; require `runtime-analysis` data first

❌ **Non-portable code in shared modules**
✅ Isolate in platform-specific module with feature-detection fallback

❌ **GC flags applied without staged testing**
✅ Test in staging under representative load; measure pause times and throughput before production

❌ **SIMD/vectorization without verification it fires**
✅ Use profiling or hardware counters to confirm vectorization actually occurred

❌ **Platform optimization silently regressing on runtime version upgrade**
✅ Add CI check for platform feature availability; test on version upgrade path

---

## Non-Goals

* ❌ Code-level algorithmic optimization — handled by `performance-optimization`
* ❌ Memory pattern optimization — handled by `memory-management`
* ❌ General profiling — handled by `runtime-analysis`

---

## Metadata Summary

```yaml
name: platform-specific-optimization
category: Language & Platform Skills
priority: Low
depends_on: [runtime-analysis, performance-optimization]
flags_skills: []
rules_applied: [PC-1, PC-2, DA-5, DT-1]
documents_needed: [platform-profile, runtime-tuning-docs, performance-profiling-data]
tags: [platform, optimization, performance, portability, runtime-tuning]
```
