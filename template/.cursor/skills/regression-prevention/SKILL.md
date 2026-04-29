---
name: regression-prevention
description: "Use when task requires Activated on code modification, fix, or refactor; detects behavioral regressions and blocks completion until resolved or change is reverted."
---

# Regression Prevention

name:regression-prevention|pri:H|deps:[]|flags:[test-creation-strategy,test-interpretation-failure-diagnosis,correctness-validation]|rules:[TQ-3,TQ-1,MF-1,GM-2]

SCOPE: Activated on code modification, fix, or refactor; detects behavioral regressions and blocks completion until resolved or change is reverted.

ENFORCE: Identify risk surface; verify coverage per TQ-1 — flag test-creation-strategy on gaps and block; run test suite against modified and adjacent paths; block on regression; test-failure: classify before fixing; manual: fix then ensure coverage; revert per MF-1 if out of scope; document CLEAR or REGRESSION_FOUND per GM-2

PROHIBIT: CLEAR without evidence; shipping known regression; silent coverage gaps; reverting without root cause; fixing test failure before classification

ON_VIOLATION: test_failure_regression→flag test-interpretation-failure-diagnosis→classify. code_defect→fix_code→out_of_scope:revert→document→flag correctness-validation. test_defect→flag test-creation-strategy. manual_regression→fix_code→out_of_scope:revert→document→flag correctness-validation→flag test-creation-strategy. coverage_gap→flag test-creation-strategy→block. scope_unclear→request_clarification.

## Reference
- See [reference.md](reference.md) for distilled source details.
