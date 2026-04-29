---
name: incident-response
description: "Use when task requires Triggered by monitoring-alerts on active incidents. Coordinates triage, remediation, stakeholder communication, and post-incident review to minimise business impact."
---

# Incident Response

name:incident-response|pri:H|deps:[monitoring-alerts]|flags:[rollback-management,infrastructure-as-code]|rules:[MF-4,PS-2,DD-2,DT-1]

SCOPE: Triggered by monitoring-alerts on active incidents. Coordinates triage, remediation, stakeholder communication, and post-incident review to minimise business impact.

ENFORCE: Classify incident severity using defined matrix before any other action. Communicate status to stakeholders within 15 minutes of SEV1/SEV2 declaration and at defined cadence throughout. For deployment-related incidents, flag rollback-management as first recovery option. Prioritise service stabilisation before root cause investigation. Document all remediation decisions via DT-1 during the incident. Conduct blameless post-incident review after every SEV1/SEV2 incident; produce tracked action items.

PROHIBIT: Declaring resolution before metrics return to pre-incident baseline; running multiple uncoordinated remediation attempts in parallel; skipping post-incident review for SEV1/SEV2 incidents; communicating in technical jargon to non-technical stakeholders.

ON_VIOLATION: no_stakeholder_update_15min→escalate_communication_immediately. remediation_not_improving→escalate_severity→add_responders. rollback_unavailable→switch_forward_fix→log:DT-1→escalate_if_exceeds_SLA. pir_not_scheduled→block_incident_closure→require_pir. data_loss_detected→halt_all_changes→escalate_immediately. infrastructure_provisioning_failure→flag:infrastructure-as-code.

## Reference
- See [reference.md](reference.md) for distilled source details.
