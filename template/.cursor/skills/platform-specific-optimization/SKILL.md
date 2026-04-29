---
name: platform-specific-optimization
description: "Use when task requires Only after runtime-analysis and performance-optimization exhausted. Apply platform-aware optimizations with benchmark justification."
---

# Platform Specific Optimization

name:platform-specific-optimization|pri:L|deps:[runtime-analysis,performance-optimization]|flags:[]|rules:[PC-1,PC-2,DA-5,DT-1]

SCOPE: Only after runtime-analysis and performance-optimization exhausted. Apply platform-aware optimizations with benchmark justification.

ENFORCE: Block until runtime-analysis data and performance-optimization exhaustion confirmed; Quantify with before/after benchmarks under representative load (PC-1); Request PC-2 — portability reduced by platform-specific code; Isolate platform code in separate modules with fallback; Log every deviation via DT-1; Require portability impact assessment; Require approval before non-portable code reaches shared modules (DA-5).

PROHIBIT: Applying before general improvements exhausted; Non-portable code in shared modules without isolation; Changes without benchmark evidence; Runtime flags without staged testing.

ON_VIOLATION: prerequisites_not_met→block→confirm_exhaustion. no_benchmark→block→require_measurement. portability_undocumented→block→require_assessment. non_portable_in_shared→block→require_isolation.

## Reference
- See [reference.md](reference.md) for distilled source details.
