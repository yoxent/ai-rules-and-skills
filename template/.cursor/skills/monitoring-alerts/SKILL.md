---
name: monitoring-alerts
description: "Use when task requires Stage 7, on deployment or monitoring gap identification. Instruments services with calibrated alerts, SLO-derived thresholds, runbook-linked routing, and PII-free monitoring data."
---

# Monitoring Alerts

name:monitoring-alerts|pri:H|deps:[]|flags:[incident-response,performance-optimization]|rules:[DD-1,CL-3,PS-2,DT-1]

SCOPE: Stage 7, on deployment or monitoring gap identification. Instruments services with calibrated alerts, SLO-derived thresholds, runbook-linked routing, and PII-free monitoring data.

ENFORCE: Map all critical failure modes to alert coverage; classify uncovered failure modes as monitoring gaps and communicate via PS-2. Derive alert thresholds from SLO error budget burn rates; document rationale via DT-1. Verify no PII in metric labels, log fields, or trace data; block on any finding. Require every alert to have a linked runbook and correct severity classification before deployment. Deploy monitoring instrumentation in the pipeline alongside application changes.

PROHIBIT: Alert thresholds set to arbitrary fixed values without SLO derivation; deploying alerts without linked runbooks; PII in metrics, logs, or traces; monitoring added as manual post-deployment step.

ON_VIOLATION: pii_in_monitoring_data→block_immediately→report_field_location. critical_gap_no_alert→log:DT-1→communicate:PS-2→flag:incident-response. alert_no_runbook→block_deployment→require_runbook. alert_fatigue_threshold→log:DT-1→recalibrate_from_SLO→escalate:PS-2. monitoring_not_in_pipeline→block→require_pipeline_inclusion. performance_degradation_detected→log:DT-1→flag:performance-optimization.

## Reference
- See [reference.md](reference.md) for distilled source details.
