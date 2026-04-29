---
name: test-reporting-observability
description: "Use when task requires After test suite execution or before release decisions. Aggregate results across tiers, classify failures, surface coverage gaps, maintain flaky register, and communicate quality to stakeholders."
---

# Test Reporting Observability

name:test-reporting-observability|pri:H|deps:[]|flags:[test-interpretation-failure-diagnosis,monitoring-alerts]|rules:[TQ-1,TQ-2,PS-2,DT-1]

SCOPE: After test suite execution or before release decisions. Aggregate results across tiers, classify failures, surface coverage gaps, maintain flaky register, and communicate quality to stakeholders.

ENFORCE: Surface missing tiers as gaps — never publish release recommendation against partial results. Classify every failure: genuine regression, new flakiness, environment-induced, or infrastructure. Report coverage at business-critical path level — not only aggregate. Update flaky register every run. Express quality gaps in business-impact language for stakeholder snapshots. Require DT-1 and prompt engineer approval before coverage threshold relaxation.

PROHIBIT: Aggregating regressions and flakiness into undifferentiated counts; release recommendation against incomplete results; silent threshold relaxation; stakeholder reports with raw metrics only.

ON_VIOLATION: critical_path_coverage_gap→block_release→surface_to_stakeholders. flaky_exceeds_threshold→flag:test-interpretation-failure-diagnosis. quality_regression_post_release→flag:test-interpretation-failure-diagnosis. threshold_relaxation→require:DT-1→escalate_prompt_engineer. test_metrics_need_prod_alert_coverage→flag:monitoring-alerts.

## Reference
- See [reference.md](reference.md) for distilled source details.
