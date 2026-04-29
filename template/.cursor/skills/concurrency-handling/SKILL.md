---
name: concurrency-handling
description: "Use when task requires On concurrent feature implementation or audit. Design and audit concurrent execution for thread safety, correctness, and resource utilization."
---

# Concurrency Handling

name:concurrency-handling|pri:M|deps:[language-specific-implementation]|flags:[async-design-patterns,runtime-analysis]|rules:[DA-1,PC-1,PC-2,TQ-1]

SCOPE: On concurrent feature implementation or audit. Design and audit concurrent execution for thread safety, correctness, and resource utilization.

ENFORCE: Validate shared mutable state has a documented sync contract; Encapsulate concurrency — sync must not leak across abstraction boundaries (DA-1); Detect deadlock risk via lock-order analysis; Document thread-safety contracts on public concurrent APIs; Require concurrency-aware tests for race and stress (TQ-1); Include contention cost in analysis (PC-1); Request PC-2 when correctness and throughput conflict.

PROHIBIT: Shared mutable state without sync contract; Lock-free patterns without correctness proof or benchmark; Undocumented thread-safety on public APIs.

ON_VIOLATION: unprotected_state→block→require_sync_contract. correctness_throughput→request:PC-2. async_more_appropriate→flag:async-design-patterns. contention_bottleneck→flag:runtime-analysis.

## Reference
- See [reference.md](reference.md) for distilled source details.
