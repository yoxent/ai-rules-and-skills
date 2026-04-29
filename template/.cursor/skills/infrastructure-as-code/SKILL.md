---
name: infrastructure-as-code
description: "Use when task requires Stage 7, on infrastructure provisioning, modification, or drift remediation. Defines and applies version-controlled infrastructure ensuring idempotent, secret-free, drift-free environments."
---

# Infrastructure As Code

name:infrastructure-as-code|pri:H|deps:[]|flags:[ci-cd-pipeline-automation,containerization,secrets-management]|rules:[DD-3,DD-1,CL-3,DT-2]

SCOPE: Stage 7, on infrastructure provisioning, modification, or drift remediation. Defines and applies version-controlled infrastructure ensuring idempotent, secret-free, drift-free environments.

ENFORCE: Scan IaC definitions for hardcoded secrets before any other action; block on any finding. Run dry-run or plan step before every apply; review output for unexpected changes. Identify all destructive operations in plan output; require DT-2 confirmation before executing any destruction. Verify IaC definitions are version-controlled and reviewed before application. Validate idempotency — non-idempotent scripts or provisioners are a blocking defect.

PROHIBIT: Hardcoded secrets or credentials in any IaC file; applying without a reviewed plan; executing destructive operations without DT-2 confirmation; manual infrastructure changes outside IaC.

ON_VIOLATION: hardcoded_secret→block_immediately→report_location→flag:secrets-management. destruction_no_confirmation→block→present_blast_radius→request:DT-2. plan_apply_mismatch→halt→investigate_drift. non_idempotent_script→block→require_remediation. iac_not_version_controlled→block→require_vcs_before_apply. pipeline_integration_needed→flag:ci-cd-pipeline-automation. container_runtime_provisioning→flag:containerization.

## Reference
- See [reference.md](reference.md) for distilled source details.
