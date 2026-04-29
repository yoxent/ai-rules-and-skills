# Skill Human Spec: Performance Optimization

```yaml
---
name: performance-optimization
description: Improves runtime efficiency through evidence-based analysis without compromising correctness or design
version: 1.0.0
category: Performance & Complexity
tags: [performance, optimization, efficiency, complexity-analysis, benchmarking]
priority: Medium
depends_on: [correctness-validation, clean-code-solid]
flags_skills: [correctness-validation, complexity-analyzer, tradeoff-communication, platform-specific-optimization, regression-prevention, test-creation-strategy]
inputs: [performance_complaints, benchmarks, bottlenecks, profiling_results, existing_code, algorithms]
outputs: [optimized_solution, big_o_analysis, benchmark_comparison, tradeoff_documentation]
rules_applied:
  - PC-1  # Analyze Complexity
  - PC-2  # Tradeoff Confirmation
  - PC-4  # Performance Budget
  - PC-5  # Correctness Priority
  - DA-5  # Avoid Overengineering
  - DT-1  # Explicit Tradeoff Logging
  - DT-2  # Confirmation Gate
documents_needed: [performance-requirements, benchmarks]
execution_context: Runs only when performance issues identified through profiling - does not run speculatively
---
```

# Skill: Performance Optimization

## Purpose

Improves runtime efficiency of code through evidence-based analysis, ensuring optimizations are measurable, justified, and do not compromise correctness or design integrity.

## When to Use This Skill

**Triggers:**
* Performance complaints or benchmarks identifying bottlenecks
* Profiling results show specific slow code paths
* Performance budget exceeded
* Response time SLA violations
* Resource utilization exceeding thresholds

**Do NOT use for:**
* Speculative optimization without measurements
* Code that already meets performance requirements
* Micro-optimizations with negligible impact
* Optimization that compromises correctness

**Execution Context:** Runs only when performance issues identified through profiling. Does NOT run speculatively without evidence.

## Inputs & Outputs

**Required inputs:**
* Performance complaints or benchmarks identifying bottlenecks
* Profiling results and metrics
* Existing code and algorithm implementations

**Primary outputs:**
* Optimized solution with Big-O analysis per PC-1
* Before/after benchmark comparison
* Documentation of design tradeoffs introduced

## Step-by-Step Execution

1. **Measure Before Changing** - Never optimize based on assumption, get baseline metrics
2. **Identify Bottleneck** - Use profiling to find actual slow path
3. **Analyze Complexity** - Calculate current Big-O time and space per PC-1
4. **Propose Optimization** - Recommend algorithmic or implementation improvement
5. **Verify Correctness Preserved** - Ensure optimization doesn't break behavior per PC-5
6. **Benchmark Improvement** - Measure actual gain, compare to baseline
7. **Document Tradeoffs** - Explain any SOLID/Clean Code compromises per PC-2, DT-1

## Core Responsibilities

1. Measure before changing — never optimize based on assumption
2. Preserve correctness throughout optimization per PC-5
3. Explain time and space complexity of proposed solution per PC-1
4. Document any SOLID or Clean Code tradeoffs introduced per PC-2

## Constraints (Rules Applied)

* **PC-1**: Estimate Big-O time and space for every algorithm/data structure decision
* **PC-2**: When optimization violates SOLID/Clean Code, explain tradeoff and request confirmation
* **PC-4**: Ensure solution fits within defined performance constraints
* **PC-5**: Correctness is non-negotiable - never compromise for performance without explicit approval
* **DA-5**: Reject micro-optimizations that add complexity without measurable gain
* **DT-1**: Log all design compromises made for performance
* **DT-2**: Request confirmation for major correctness/design tradeoffs

## Tradeoff Handling

**SOLID Principles vs Performance:** Must be documented and confirmed per PC-2; never silently traded away
**Readability vs Efficiency:** Complex optimizations reduce maintainability; justify with benchmark evidence

## Failure & Escalation

* Sacrificing abstraction/design quality → request confirmation per DT-2
* Significant SOLID/design tradeoff identified → flag tradeoff-communication → document tradeoff → log per DT-1
* General optimization exhausted → flag platform-specific optimization
* Optimization complete → flag regression-prevention, correctness-validation, test-creation-strategy
* Correctness at risk → reject optimization, preserve correctness per PC-5
* No measurable improvement → reject change per DA-5

## Skills Flagged

* **correctness-validation** - when optimization ready for correctness verification
* **complexity-analyzer** - when detailed complexity analysis needed
* **tradeoff-communication** - when optimization introduces a significant SOLID/design tradeoff requiring stakeholder communication
* **platform-specific-optimization** - when general optimization exhausted and platform-level tuning needed
* **regression-prevention** - after optimization complete to validate no behavioral regressions introduced
* **test-creation-strategy** - after optimization complete to ensure changed paths have coverage

## Anti-Patterns to Catch

1. Premature optimization adding complexity without measurable benefit
2. Optimizing without profiling (guessing at bottlenecks)
3. Sacrificing correctness for performance without approval
4. Micro-optimizations that harm readability for negligible gain
5. Caching everything speculatively
6. Optimizing cold paths instead of hot paths
7. Not measuring before/after to verify improvement
8. Silently trading away SOLID principles
