---
name: senior-software-engineer-performance-optimization
description: "Use when task requires Improves runtime efficiency through evidence-based analysis without compromising correctness or design"
---

# Senior Software Engineer Performance Optimization

name:performance-optimization|pri:M|deps:[correctness-validation,clean-code-solid]|flags:[correctness-validation,complexity-analyzer,tradeoff-communication,platform-specific-optimization,regression-prevention,test-creation-strategy]|rules:[PC-1,PC-2,PC-4,PC-5,DA-5,DT-1,DT-2]
SCOPE: Improves runtime efficiency through evidence-based analysis without compromising correctness or design
ENFORCE: Measure before changing - never optimize based on assumption, get baseline metrics; Identify bottleneck using profiling to find actual slow path; Analyze complexity per PC-1: calculate current Big-O time and space; Propose optimization with clear algorithmic or implementation improvement; Verify correctness preserved throughout per PC-5 - never compromise; Benchmark improvement: measure actual gain, compare to baseline; Document any SOLID/Clean Code tradeoffs per PC-2, DT-1; Request confirmation for design quality sacrifices per DT-2; Ensure solution fits performance budget per PC-4; Reject micro-optimizations without measurable gain per DA-5
PROHIBIT: Speculative optimization without profiling data; Optimizing based on assumptions about bottlenecks; Sacrificing correctness for performance without explicit approval per PC-5; Silently trading away SOLID principles without documentation; Micro-optimizations that harm readability for negligible gain; Not measuring before/after to verify improvement
ON_VIOLATION: correctness_risk → reject_optimization → preserve_correctness per PC-5. no_improvement → reject_change per DA-5. design_quality_risk → escalate_to_confirmation per DT-2 → log_decision per DT-1. no_profiling → require_profiling_data_first. general_opt_exhausted → flag:platform-specific-optimization. tradeoff_identified → flag:tradeoff-communication → document_tradeoff → log per DT-1. complex_analysis_needed → flag:complexity-analyzer. optimization_complete → flag:correctness-validation → flag:regression-prevention → flag:test-creation-strategy

## Reference
- See [reference.md](reference.md) for distilled source details.
