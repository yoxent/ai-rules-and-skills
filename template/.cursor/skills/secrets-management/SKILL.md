---
name: secrets-management
description: "Use when task requires Stage 7, on secret provisioning, rotation, or leak detection. Manages credential lifecycle ensuring secrets never appear outside approved vault and access is least-privilege with full audit trail."
---

# Secrets Management

name:secrets-management|pri:H|deps:[]|flags:[incident-response,infrastructure-as-code]|rules:[CL-3,CL-1,DD-3,DT-2]

SCOPE: Stage 7, on secret provisioning, rotation, or leak detection. Manages credential lifecycle ensuring secrets never appear outside approved vault and access is least-privilege with full audit trail.

ENFORCE: Scan code, config files, Dockerfiles, and pipeline definitions for secrets before any other action; block and treat as leaked on any finding. Enforce least-privilege access policies scoped to specific service identities; reject wildcard or multi-service access policies. Validate secret injection patterns in deployment pipeline before production. Require DT-2 confirmation for all access policy changes. Configure automated rotation and test in staging before production; confirm zero-disruption.

PROHIBIT: Secrets in version control, config files, container images, or plain text environment variables; shared credentials between services; access policy changes without DT-2; rotation deployed to production without staging test; audit logging disabled on secret vault.

ON_VIOLATION: secret_in_vcs→treat_as_leaked→rotate_immediately→flag:incident-response. secret_outside_vault→block→require_migration. unauthorised_access_in_audit_log→rotate_immediately→flag:incident-response. access_policy_change_no_dt2→block→request:DT-2. rotation_causes_disruption→block_production→require_redesign. vault_provisioning_needed→flag:infrastructure-as-code.

## Reference
- See [reference.md](reference.md) for distilled source details.
