---
name: metrics-and-kpis
description: "Use when task requires At sprint planning (define KPIs) and post-launch cadence (report, detect anomalies). Define success criteria before commitment; monitor actuals; flag underperformance."
---

# Metrics And Kpis

name:metrics-and-kpis|pri:M|deps:[]|flags:[feature-validation,stakeholder-communication]|rules:[PS-1,PS-4,DT-1]

SCOPE: At sprint planning (define KPIs) and post-launch cadence (report, detect anomalies). Define success criteria before commitment; monitor actuals; flag underperformance.

ENFORCE: Define KPIs before sprint commit per PS-1 — post-launch definition is a gap. Anchor every KPI to a business goal or OKR. Each KPI requires: measurement method, specific time-bound target, baseline, owner, cadence. Max one primary + two secondary per feature. Primary KPI instrumentation is a launch blocker. Log deferrals per DT-1 with reason and recovery sprint. Classify actuals: ON-TRACK/AT-RISK/UNDERPERFORMING/ANOMALY. Underperforming KPI requires hypothesis and recommended action. Document KPI-driven decisions with data per PS-4.

PROHIBIT: KPI defined post-launch. Vanity metric (activity not outcome) as primary. Target without number and timeframe. Underperformance without hypothesis. Primary instrumentation treated as optional.

ON_VIOLATION: kpi_undefined_at_commit→block→require_definition. instrumentation_missing→block_or_log:DT-1. underperformance→flag:feature-validation. anomaly→flag:stakeholder-communication. deferral→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
