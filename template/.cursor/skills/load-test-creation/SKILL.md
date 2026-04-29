---
name: load-test-creation
description: "Use when task requires Before performance-sensitive launches or capacity planning. Design and execute load tests validating throughput and latency against defined SLO thresholds."
---

# Load Test Creation

name:load-test-creation|pri:H|deps:[]|flags:[performance-optimization,monitoring-alerts]|rules:[PC-1,PC-4,TQ-1,DT-1]

SCOPE: Before performance-sensitive launches or capacity planning. Design and execute load tests validating throughput and latency against defined SLO thresholds.

ENFORCE: Block if SLOs undefined. Ground VU counts in traffic projections; reject arbitrary levels. Provision representative test data distribution. Apply realistic think times unless raw throughput ceiling is explicit goal. Capture p50/p95/p99 latency, RPS, error rate per endpoint. Report degradation onset — not only peak pass/fail. Name bottleneck component with correlated metric evidence. Log mocking decisions, env delta, and deferrals via DT-1.

PROHIBIT: Executing without SLOs; testing against production or shared infra; all VUs hitting one record; accepting >20% run-to-run variance without investigation.

ON_VIOLATION: no_slo→block→escalate_prompt_engineer. prod_env→halt→escalate_confirmation. high_variance→suspend→investigate_env. slo_breach→flag:performance-optimization→log:DT-1. load_thresholds_need_alert_update→flag:monitoring-alerts.

## Reference
- See [reference.md](reference.md) for distilled source details.
