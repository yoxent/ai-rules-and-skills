---
name: correctness-validation
description: "Use when task requires Validates functional correctness of code changes against business requirements and prevents regressions"
---

# Correctness Validation

name:correctness-validation|pri:H|deps:[]|flags:[performance-optimization,clean-code-solid,security,design-pattern-selection,error-handling-resilience,backward-compatibility,bug-diagnosis,test-creation-strategy]|rules:[PC-5,TQ-1,MF-1,GM-2,GM-4]
SCOPE: Validates functional correctness of code changes against business requirements and prevents regressions
ENFORCE: Verify logic matches business requirements exactly; Run complete existing test suite and catch all failures; Validate all edge cases and boundary conditions explicitly; Ensure no existing functionality is broken by changes; Require tests for all validation claims per TQ-1; Block approval if correctness compromised without explicit confirmation per PC-5; Surface all correctness deviations for confirmation gate per DT-2
PROHIBIT: Approving code without test coverage backing validation; Accepting correctness compromises silently without logging per DT-1; Making assumptions about requirements - escalate ambiguities; Ignoring test failures as "flaky" without investigation; Validating against outdated documentation instead of requirements; Approving changes when requirements are ambiguous
ON_VIOLATION: correctness_compromised → block_approval → request_confirmation → log_decision. ambiguous_req → halt_execution → request_clarification. regression_detected → fail_validation → flag bug-diagnosis. coverage_inadequate → flag test-creation-strategy. perf_degradation → flag performance-optimization. security_concern → flag security. quality_poor → flag clean-code-solid. high_complexity → flag design-pattern-selection. error_handling_absent → flag error-handling-resilience. breaking_change_found → flag backward-compatibility

## Reference
- See [reference.md](reference.md) for distilled source details.
