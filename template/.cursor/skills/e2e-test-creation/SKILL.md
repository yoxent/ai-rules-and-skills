---
name: e2e-test-creation
description: "Use when task requires On new workflow impl, pre-release, or coverage gap. Design deterministic E2E tests covering complete user journeys from entry to business outcome."
---

# E2E Test Creation

name:e2e-test-creation|pri:H|deps:[]|flags:[feature-validation,test-interpretation-failure-diagnosis,ci-cd-pipeline-automation]|rules:[TQ-1,TQ-4,TQ-3,DD-1]

SCOPE: On new workflow impl, pre-release, or coverage gap. Design deterministic E2E tests covering complete user journeys from entry to business outcome.

ENFORCE: Rank workflows by criticality; measure gap against journey map before authoring. Block if acceptance criteria absent. Use semantic locators; condition-based waits; each test owns setup/teardown with no ordering deps. Integrate as blocking CI gate; capture failure artifacts. Map each test to a journey. Log deferrals and mocking decisions via DT-1.

PROHIBIT: Tests without acceptance criteria; production data without anonymization; fixed waits; shared state between tests; E2E suite as optional CI step.

ON_VIOLATION: no_criteria→flag:feature-validation→block. spec_mismatch→flag:feature-validation→mark_BLOCKED. env_failure→flag:test-interpretation-failure-diagnosis→suspend. no_ci_gate→surface_required_action→flag:ci-cd-pipeline-automation→block. prod_data→block→escalate_confirmation.

## Reference
- See [reference.md](reference.md) for distilled source details.
