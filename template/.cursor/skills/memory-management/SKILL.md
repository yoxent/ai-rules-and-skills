---
name: memory-management
description: "Use when task requires After runtime-analysis identifies memory as a bottleneck. Ensure efficient allocation, deallocation, and usage patterns to prevent leaks, control footprint, and maintain stability under load."
---

# Memory Management

name:memory-management|pri:M|deps:[runtime-analysis]|flags:[platform-specific-optimization]|rules:[PC-1,PC-4,DA-5]

SCOPE: After runtime-analysis identifies memory as a bottleneck. Ensure efficient allocation, deallocation, and usage patterns to prevent leaks, control footprint, and maintain stability under load.

ENFORCE: Require runtime profiling data before memory optimization begins (PC-1); Quantify memory usage in space-complexity terms; Validate footprint fits within defined performance budget (PC-4); Reject memory micro-optimizations without measurable evidence (DA-5); Flag GC tuning requirements to platform-specific-optimization; Require DT-2 confirmation for manual memory management in GC languages.

PROHIBIT: Memory optimization without profiling evidence; Manual memory management in GC languages without DT-2 confirmation; Recommending object pooling without allocation rate evidence.

ON_VIOLATION: optimization_without_profile→block→require runtime-analysis data. manual_mem_in_gc→request:DT-2→log:DT-1. pool_without_evidence→block→require allocation rate data. exceeds_budget→flag:PC-4→escalate.

## Reference
- See [reference.md](reference.md) for distilled source details.
