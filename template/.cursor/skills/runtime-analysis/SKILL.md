---
name: runtime-analysis
description: "Use when task requires On performance complaint or pre-optimization audit. Profile application under representative load to identify CPU, memory, and I/O bottlenecks."
---

# Runtime Analysis

name:runtime-analysis|pri:M|deps:[]|flags:[performance-optimization,memory-management]|rules:[PC-1,PC-2,DA-5]

SCOPE: On performance complaint or pre-optimization audit. Profile application under representative load to identify CPU, memory, and I/O bottlenecks.

ENFORCE: Require profiling under representative load before any recommendation (PC-1); Document tool, sampling rate, and load profile; Reject recommendations lacking measurable business-impact justification (DA-5); Flag code hotspots to performance-optimization; Flag memory findings to memory-management; Confirm via PC-2 when optimization compromises SOLID.

PROHIBIT: Optimizations without profiling evidence; High-frequency production instrumentation without overhead assessment; Microbenchmarks treated as production equivalents.

ON_VIOLATION: no_profiling→block→require_evidence. unrepresentative_load→flag_gap→request_re_profile. SOLID_tradeoff→request:PC-2. no_impact→reject→log:DA-5.

## Reference
- See [reference.md](reference.md) for distilled source details.
