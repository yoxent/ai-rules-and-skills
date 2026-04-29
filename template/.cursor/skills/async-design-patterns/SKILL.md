---
name: async-design-patterns
description: "Use when task requires On non-blocking feature implementation or async refactor. Design async workflows with correct error propagation, cancellation, and contained scope."
---

# Async Design Patterns

name:async-design-patterns|pri:M|deps:[language-specific-implementation]|flags:[concurrency-handling,error-handling-resilience,test-creation-strategy,correctness-validation,regression-prevention]|rules:[DA-1,PC-2,TQ-1,GM-2]

SCOPE: On non-blocking feature implementation or async refactor. Design async workflows with correct error propagation, cancellation, and contained scope.

ENFORCE: Explain async error propagation consequences before implementing (GM-2); Require explicit error handler on every async call site — no swallowed rejections; Require cancellation and timeout on async operations; Define queue bound and backpressure strategy (DA-1); Require tests for cancellation, timeout, and error paths (TQ-1); Confirm PC-2 when async complexity is introduced.

PROHIBIT: Unhandled async exceptions or promise rejections; Unbounded task queues; Mixing sync and async at the same layer without adapter.

ON_VIOLATION: unhandled_rejection→block→require_error_handler. unbounded_queue→block→require_bound. sync_async_mixed→require_adapter. async_scope_leak→flag:concurrency-handling. async_error_propagation_gaps→flag:error-handling-resilience→redesign_propagation_strategy. async_tests_absent→flag:test-creation-strategy→require_cancellation_timeout_error_tests. async_impl_complete→flag:correctness-validation→validate_async_correctness. async_code_modified→flag:regression-prevention→verify_no_regression.

## Reference
- See [reference.md](reference.md) for distilled source details.
