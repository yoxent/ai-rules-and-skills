---
name: security
description: "Use when task requires Identifies and mitigates architectural security vulnerabilities; enforces auth, encryption, and compliance"
---

# Security

name:security|pri:H|deps:[system-design]|flags:[system-design,observability,dependency-management,logging,incident-response]|rules:[CL-1,CL-3,CL-4,DT-2,DT-1,GM-2,GM-4]
SCOPE: Identifies and mitigates architectural security vulnerabilities; enforces auth, encryption, and compliance
ENFORCE: Map all sensitive data flows and classify against applicable regulatory regimes before designing controls (CL-1); Block any custom authentication or cryptographic protocol — require established standards (OAuth 2.0, TLS 1.3); Apply least privilege: every principal starts with zero permissions; justify each grant; Specify encryption with named algorithms, key lengths, and key management approach — never accept vague "use encryption"; Produce explicit compliance gap analysis mapping each requirement to a specific verifiable control (CL-3); Require encryption keys to be managed separately from the data they protect; Escalate all security tradeoffs to stakeholder via confirmation gate — never resolve silently (DT-2); Log all residual risk acceptance decisions with approval authority (DT-1)
PROHIBIT: Proceeding with custom authentication or cryptographic implementations under any circumstances; Accepting vague compliance claims without control-to-requirement mapping; Sensitive data in logs, even in encrypted storage; Marking compliance gaps as resolved without evidence of implemented controls
ON_VIOLATION: active_vuln → flag incident-response → halt_all_design_work. custom_auth_crypto → block_immediately → require_standard_replacement → escalate_to_confirmation (DT-2). compliance_isolation → flag system-design → block_production_approval. compliance_gap_blocking → document_gap → halt_production_approval → escalate_to_stakeholder. sensitive_in_logs → flag logging → require_field_exclusion_implementation. security_controls_require_monitoring → flag:observability → design_audit_logging_and_anomaly_detection. cve_in_dependency → flag:dependency-management → require_patch_or_mitigation

## Reference
- See [reference.md](reference.md) for distilled source details.
