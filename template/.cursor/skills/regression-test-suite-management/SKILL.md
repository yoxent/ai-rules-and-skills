---
name: regression-test-suite-management
description: "Use when task requires Post-refactor, on flakiness accumulation or slow-suite alerts, or as periodic maintenance. Audit, curate, and optimize the regression suite for trustworthiness, speed, and behavioral alignment."
---

# Regression Test Suite Management

name:regression-test-suite-management|pri:H|deps:[]|flags:[test-interpretation-failure-diagnosis,ci-cd-pipeline-automation]|rules:[TQ-3,TQ-4,MF-4,MF-2]

SCOPE: Post-refactor, on flakiness accumulation or slow-suite alerts, or as periodic maintenance. Audit, curate, and optimize the regression suite for trustworthiness, speed, and behavioral alignment.

ENFORCE: Require coverage impact assessment before any removal. Require prompt engineer confirmation before removing business-critical workflow tests. Triage flaky tests by frequency and impact; escalate blocking flaky tests — never remove instead of remediating. Add regression test for every fixed bug. Flag recurring regressions per MF-4 — root cause required, not only a new test. Register all test debt via MF-2. Measure suite health trend across audits.

PROHIBIT: Test removal without coverage impact assessment; removing flaky tests as remediation; blocking flakiness without a remediation path; recurring regression closed without root cause.

ON_VIOLATION: critical_workflow_removal_no_confirm→block→escalate_prompt_engineer. blocking_flaky→flag:test-interpretation-failure-diagnosis→log:MF-2. recurring_regression→flag:test-interpretation-failure-diagnosis→log:MF-4. pipeline_change_needed→flag:ci-cd-pipeline-automation. test_debt_unregistered→log:MF-2.

## Reference
- See [reference.md](reference.md) for distilled source details.
