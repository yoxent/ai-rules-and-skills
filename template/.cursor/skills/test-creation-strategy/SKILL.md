---
name: test-creation-strategy
description: "Use when task requires Creates tests validating business behavior and preventing regressions using appropriate test types"
---

# Test Creation Strategy

name:test-creation-strategy|pri:H|deps:[correctness-validation,abstraction-domain-modeling]|flags:[test-interpretation-failure-diagnosis,correctness-validation,regression-prevention,test-environment-management]|rules:[TQ-1,TQ-4,DA-2,MF-1]
SCOPE: Creates tests validating business behavior and preventing regressions using appropriate test types
ENFORCE: Generate unit tests for every new feature by default per TQ-1; Determine when integration tests required vs unit tests with mocks; Ensure tests reflect business intent per DA-2, not implementation details; Cover happy paths, edge cases, and failure modes; Make tests meaningful, maintainable, intention-revealing per TQ-4; Ensure new tests don't conflict with existing correct behavior per MF-1; Document test tier selection rationale; Avoid brittle tests tied to internal structure; Test error paths with same rigor as happy paths
PROHIBIT: Skipping tests for new features or bug fixes per TQ-1; Tests coupled to implementation details (break on refactor); Over-mocking that prevents catching real regressions; Tests with unclear intent; Coverage gaps in error paths and edge cases; Tests that pass but don't validate business behavior
ON_VIOLATION: coverage_inadequate → create_tests per TQ-1. tests_coupled → refactor_tests per TQ-4. intent_unclear → request_clarification. integration_infra → flag test-environment-management. test_failure_encountered → flag test-interpretation-failure-diagnosis. regression_risk → flag regression-prevention. tests_break_behavior → flag correctness-validation per MF-1

## Reference
- See [reference.md](reference.md) for distilled source details.
