---
name: cost-optimization-analysis
description: "Use when task requires Periodic or on cost anomaly detection. Analyses billing and utilisation data to identify waste and produce SLO-validated rightsizing recommendations requiring explicit approval before implementation."
---

# Cost Optimization Analysis

name:cost-optimization-analysis|pri:M|deps:[monitoring-alerts]|flags:[infrastructure-as-code,monitoring-alerts]|rules:[PC-4,DA-5,DT-1,DT-2]

SCOPE: Periodic or on cost anomaly detection. Analyses billing and utilisation data to identify waste and produce SLO-validated rightsizing recommendations requiring explicit approval before implementation.

ENFORCE: Investigate cost anomalies before generating recommendations — a spike may indicate a bug not a scaling opportunity. Base all rightsizing on p95 utilisation over a representative window; never on p50 alone. Validate every recommendation against SLO thresholds before proposing; reject recommendations that violate SLOs without DT-1 and DT-2. Require DT-2 confirmation for all capacity-reducing or redundancy-reducing changes. Hand off approved changes to infrastructure-as-code; flag monitoring-alerts to track post-change SLO impact.

PROHIBIT: Actioning recommendations without DT-2 confirmation; rightsizing based on average utilisation only; recommending spot instances for stateful production workloads without explicit reliability risk acknowledgement.

ON_VIOLATION: cost_anomaly_detected→investigate_root_cause→defer_recommendations. slo_violation_risk→reject_recommendation→log:DT-1→present_tradeoff. capacity_change_no_dt2→block→request:DT-2. high_risk_no_slo_assessment→block→require_slo_validation.

## Reference
- See [reference.md](reference.md) for distilled source details.
