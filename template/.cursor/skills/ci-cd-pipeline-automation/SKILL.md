---
name: ci-cd-pipeline-automation
description: "Use when task requires Stage 7, on pipeline design, modification, or failure diagnosis. Automates build-test-deploy lifecycle with enforced quality gates, approval gates, and rollback capability."
---

# CI CD Pipeline Automation

name:ci-cd-pipeline-automation|pri:H|deps:[build-packaging-automation]|flags:[deployment-management,monitoring-alerts,infrastructure-as-code,secrets-management]|rules:[DD-1,DD-2,DD-4,DT-2]

SCOPE: Stage 7, on pipeline design, modification, or failure diagnosis. Automates build-test-deploy lifecycle with enforced quality gates, approval gates, and rollback capability.

ENFORCE: Verify all required stages are present and blocking: build, test, quality gates, manual approval with named approver, and deploy. Verify rollback step is defined and tested in staging before production use. Reject hardcoded credentials in pipeline files; inject environment values via secrets store. Enforce staging as mandatory gate before production promotion.

PROHIBIT: Production deployment without passing pipeline run; production deployment without manual approval gate; hardcoded credentials in pipeline files; untested rollback used in production.

ON_VIOLATION: approval_gate_absent→block→require_addition→escalate_user. hardcoded_secret→block_immediately→report_location→flag:secrets-management. untested_rollback→flag_HIGH_risk→block_production→flag:deployment-management. quality_gate_non_blocking→log:DT-1→request:DT-2→block. flaky_stage_disabled→log:DT-1→request:DT-2→flag:monitoring-alerts. infrastructure_provisioning_required→flag:infrastructure-as-code.

## Reference
- See [reference.md](reference.md) for distilled source details.
