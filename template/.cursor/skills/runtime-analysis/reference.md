```yaml
---
name: runtime-analysis
description: Monitors and evaluates application execution to identify bottlenecks, memory issues, and resource inefficiencies with evidence-based optimization guidance.
version: 1.0.0
category: Language & Platform Skills
tags: [profiling, performance, runtime, bottleneck, memory]
priority: Medium

depends_on: []
flags_skills: [performance-optimization, memory-management]

inputs: [running-application, profiling-tools, performance-baselines]
outputs: [profiling-report, hotspot-identification, optimization-recommendations]

rules_applied:
  - PC-1  # Analyze Complexity — require empirical evidence before optimization begins
  - PC-2  # Tradeoff Confirmation — optimization actions compromising SOLID require confirmation
  - DA-5  # Avoid Overengineering — only act on findings with measurable business impact

documents_needed: [performance-requirements, profiling-tool-docs, production-workload-profile]
execution_context: Activated on a performance complaint, pre-optimization audit, or when a memory/CPU regression is suspected.
---
```

# Skill: Runtime Analysis

---

## Purpose

**What this skill does:**
Profiles a running application under representative load to identify CPU hotspots, memory bottlenecks, and resource inefficiencies. Produces evidence-based recommendations that quantify impact before any optimization work begins.

Premature or misdirected optimization is expensive and often counterproductive. Runtime analysis ensures optimization effort is directed at the actual bottleneck, not the perceived one.

Evidence-based optimization prevents "optimizing the wrong thing." Profiling data also establishes a baseline for regression detection — future changes can be validated against it.

---

## When to Use This Skill

### Triggers:
* Performance complaint from users or monitoring
* Pre-optimization audit before beginning performance work
* Memory leak suspected (gradual degradation under load)
* CPU or I/O spike with no obvious cause
* Regression suspected after a recent code change

### Do NOT use this skill for:
* Code-level optimization implementation — delegate to `performance-optimization`
* Memory-specific analysis and remediation — delegate to `memory-management`
* Platform-level tuning (JVM flags, V8 settings) — delegate to `platform-specific-optimization`

---

## Inputs

**Required inputs:**
* **Running application under representative load** — idle profiling is meaningless
* **Profiling tools configured** — APM, sampling profiler, heap analyzer
* **Performance requirements and baselines** — what "acceptable" means

---

## Outputs

**Primary outputs:**
* **Profiling report** — hotspots by CPU %, memory allocation rate, I/O wait
* **Optimization recommendations** — prioritized by measured impact, not intuition
* **Benchmark methodology** — documented so results are reproducible

**Skill flags:**
* Flag **performance-optimization** for code-level hotspots requiring refactoring
* Flag **memory-management** for memory allocation patterns and leak findings

---

## Preconditions

* Application running under production-representative load
* [ ] Profiling tool configured and overhead assessed
* [ ] Performance baseline documented

---

## Step-by-Step Execution Procedure

### Step 1: Validate Profiling Setup

**Actions:**
- [ ] Confirm load is representative of production traffic pattern
- [ ] Assess profiler overhead — sampling profilers add <1% overhead; instrumentation profilers add 5–15%
- [ ] Document tool, sampling rate, and workload characteristics

**Red flags:**
- Profiling an idle application or with synthetic microbenchmarks
- Instrumentation profiler left on in production at full rate

---

### Step 2: Collect Profiling Data

**Actions:**
- [ ] Run CPU profiler for sufficient duration (≥5 min under steady load)
- [ ] Capture heap allocation snapshot and GC metrics
- [ ] Capture I/O wait and thread contention metrics if applicable

---

### Step 3: Identify Hotspots

**Actions:**
- [ ] Rank functions by CPU % (flame graph or call tree)
- [ ] Identify top allocation sites by volume and frequency
- [ ] Identify GC pressure patterns (allocation rate vs. collection frequency)

---

### Step 4: Assess Business Impact

**Actions:**
- [ ] Map hotspots to user-visible latency or cost impact
- [ ] Reject optimization proposals with no measurable business impact (DA-5)
- [ ] Rank recommendations by expected gain-to-effort ratio

---

### Step 5: Flag to Downstream Skills

**Actions:**
- [ ] Flag code-level hotspots to `performance-optimization`
- [ ] Flag memory allocation patterns to `memory-management`

---

### Final Step: Generate Report

```markdown
## Runtime Analysis Report

**Application:** [Service/component name]
**Profiling Tool:** [Tool + sampling rate]
**Load Profile:** [Requests/sec, data volume, representative: Y/N]
**Status:** ✅ ACTIONABLE FINDINGS / ℹ️ NO SIGNIFICANT ISSUES

### CPU Hotspots
| Function | CPU% | Location | Recommendation |
|----------|------|----------|----------------|

### Memory Analysis
| Pattern | Allocation Rate | GC Impact | Recommendation |

### I/O Analysis
[If applicable]

### Prioritized Recommendations
1. [Highest impact: expected gain, effort, skill to engage]
2. ...

### Skills Flagged
- **performance-optimization**: [code-level hotspots]
- **memory-management**: [memory findings]

### Baseline Reference
[Metrics before optimization — for regression comparison]
```

---

## Core Responsibilities

1. Profile under representative load only — reject synthetic workloads
2. Identify and rank hotspots by measured impact
3. Assess business impact before recommending optimization
4. Document methodology for reproducibility
5. Flag findings to `performance-optimization` and `memory-management`

---

## Constraints (Rules Applied)

* **PC-1** — Profiling data must provide empirical evidence before optimization begins
* **PC-2** — Optimization actions that compromise SOLID require explicit confirmation
* **DA-5** — Only act on findings with measurable business impact; reject micro-optimizations without justification

---

## Tradeoff Handling

### Tradeoff 1: Profiling Accuracy vs. Overhead

```
Conflict: Instrumentation profiler is more accurate but adds 10% latency in production
→ Use sampling profiler for production; instrumentation profiler in staging
→ Document measurement error range in output
→ Log if production profiling deferred to staging
```

---

## Anti-Patterns to Catch

❌ **Profiling an idle or lightly loaded application**
✅ Profile under production-representative load; document load characteristics

❌ **Recommending optimization based on code inspection rather than data**
✅ Block; require profiling data first

❌ **Optimizing a function that is 0.1% of runtime**
✅ Focus on the top-3 hotspots; below 2% CPU contribution, optimization rarely matters

❌ **Leaving high-overhead instrumentation profiler in production continuously**
✅ Use sampling profiler in production; turn instrumentation profiler off after data collection

---

## Non-Goals

* ❌ Code-level optimization implementation — handled by `performance-optimization`
* ❌ Memory leak remediation — handled by `memory-management`
* ❌ Platform-level tuning — handled by `platform-specific-optimization`

---

## Metadata Summary

```yaml
name: runtime-analysis
category: Language & Platform Skills
priority: Medium
depends_on: []
flags_skills: [performance-optimization, memory-management]
rules_applied: [PC-1, PC-2, DA-5]
documents_needed: [performance-requirements, profiling-tool-docs, production-workload-profile]
tags: [profiling, performance, runtime, bottleneck, memory]
```
