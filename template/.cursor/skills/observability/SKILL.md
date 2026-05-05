---
name: observability
description: "Use when task requires Designs monitoring, distributed tracing, and SLO-based alerting for actionable production visibility"
---

# Observability

name:observability|pri:H|deps:[system-design]|flags:[language-specific-implementation,logging,security,performance-optimization,incident-response,scalability]|rules:[DD-1,CL-3,DT-1,PS-2,MF-5,GM-2,GM-4]
SCOPE: Designs monitoring, distributed tracing, and SLO-based alerting for actionable production visibility
ENFORCE: design involves code-level implementation → flag:language-specific-implementation → co_invoke before design; Require SLO definitions before designing alerts — halt and request if absent; Define all four golden signals (latency, traffic, errors, saturation) for every critical-path component; Design SLO burn rate alert pairs (fast-burn page + slow-burn ticket) for every SLO-bearing component; Audit all metric labels, trace attributes, and log fields for PII before approving collection (CL-3); Document every known failure mode with no corresponding detectable signal as a blocking observability gap; Require instrumentation to be included in deployment pipeline definitions per DD-1 — never post-deployment; Log all sampling rate and retention tradeoffs with cost/diagnostic value rationale (DT-1)
PROHIBIT: Deploying a critical-path service to production with undetectable critical failure modes; Collecting PII in metric labels, trace attributes, or log fields without explicit compliance review; Using only infrastructure metrics (CPU, memory) as primary alerting signals — user-facing signals required
ON_VIOLATION: slo_undefined → halt_alert_design → request_slo_from_stakeholder → instrument_golden_signals_as_interim. failure_undetectable → document_gap → block_production_deployment → escalate_as_risk → flag:incident-response. pii_in_obs → flag security → block_instrumentation_implementation → require_redesign. instrumentation_post_deploy → block → require_pipeline_inclusion (DD-1). metric_bottleneck → flag performance-optimization → document_finding. log_format_standardization_required → flag:logging. metric_cardinality_exceeds_infra → flag:scalability

## Reference
- See [reference.md](reference.md) for distilled source details.
