---
name: networking-security-configuration
description: "Use when task requires Stage 7, on network provisioning or security review. Enforces least-privilege network access, environment isolation, and version-controlled security policies compliant with applicable regulations."
---

# Networking Security Configuration

name:networking-security-configuration|pri:H|deps:[infrastructure-as-code]|flags:[incident-response,secrets-management,infrastructure-as-code]|rules:[CL-1,CL-3,DD-3,DT-2]

SCOPE: Stage 7, on network provisioning or security review. Enforces least-privilege network access, environment isolation, and version-controlled security policies compliant with applicable regulations.

ENFORCE: Audit ingress and egress rules for overly permissive patterns; block on 0.0.0.0/0 ingress beyond load balancers or undeclared cross-service paths. Enforce default-deny posture with only explicitly permitted paths allowed. Verify production is fully isolated from staging and development tiers. Require DT-2 for all production network security rule changes. Ensure all network configurations are version-controlled IaC; treat manual console changes as drift requiring immediate remediation.

PROHIBIT: Overly permissive rules in production without DT-2; cross-environment routing between production and other tiers without justification; network configurations outside version control; production rule changes without DT-2.

ON_VIOLATION: permissive_rule_production→block→request:DT-2→log:DT-1. cross_env_routing_no_justification→block→request:DT-2. suspected_unauthorised_access→flag:incident-response→preserve_logs. manual_change_outside_iac→flag:infrastructure-as-code→flag_drift→request:DT-2_if_production. compliance_requirement_not_met→block_production→escalate_user. credential_injection_review_needed→flag:secrets-management.

## Reference
- See [reference.md](reference.md) for distilled source details.
