---
name: logging
description: "Use when task requires Defines structured log format, PII exclusion, severity taxonomy, retention policy, and aggregation architecture"
---

# Logging

name:logging|pri:M|deps:[system-design]|flags:[language-specific-implementation,observability,security,configuration,technical-debt-management]|rules:[CL-3,CL-1,DA-1,MF-5,DT-1,GM-4]
SCOPE: Defines structured log format, PII exclusion, severity taxonomy, retention policy, and aggregation architecture
ENFORCE: design involves code-level implementation → flag:language-specific-implementation → co_invoke before design; Audit all proposed log fields for PII before approving — apply explicit exclusion list (CL-3); Require structured JSON format with universal fields: timestamp, service, severity, trace_id, environment; Map every compliance-required audit event category to a mandatory log definition (CL-1); Set INFO as production default; block DEBUG in production environments except time-bounded diagnostic windows; Define retention per log category with compliance minimum as the floor — never below; Require log writes to be non-blocking with bounded queue; logging failure must not impact application (MF-5); Log all verbosity-vs-performance and retention-vs-cost tradeoffs (DT-1)
PROHIBIT: Logging request bodies, auth headers, or raw user input without explicit field-level whitelist; Unstructured string-concatenated log messages in production services; Log entries without a correlation/trace ID field
ON_VIOLATION: sensitive_in_logs → flag security → assess_breach_notification_obligation → rotate_leaked_credentials. audit_log_missing → document_blocking_gap → block_production_deployment. log_blocking → redesign_as_async_non_blocking (MF-5) → flag observability. logs_inconsistent → flag technical-debt-management → produce_remediation_plan. env_specific_log_settings → flag:configuration → manage_log_env_config

## Reference
- See [reference.md](reference.md) for distilled source details.
