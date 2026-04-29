---
name: rollback-management
description: "Use when task requires Triggered by deployment-management on health check failure or incident-response during active incidents. Executes rollbacks, validates recovery, and triggers root cause analysis."
---

# Rollback Management

name:rollback-management|pri:H|deps:[deployment-management]|flags:[incident-response,monitoring-alerts]|rules:[DD-2,MF-4,DT-1]

SCOPE: Triggered by deployment-management on health check failure or incident-response during active incidents. Executes rollbacks, validates recovery, and triggers root cause analysis.

ENFORCE: Confirm previous stable artifact is retrievable from registry before initiating rollback. Assess and log rollback vs forward-fix decision via DT-1 before executing. Execute rollback per documented plan; monitor each step for failure. Validate post-rollback health against pre-failure baseline before declaring recovery. Flag incident-response for root cause analysis after every rollback.

PROHIBIT: Declaring recovery before post-rollback health checks pass; executing rollback without confirming previous artifact available; skipping DT-1 decision log under time pressure.

ON_VIOLATION: artifact_not_retrievable→block_rollback→escalate_user. rollback_steps_failing→halt→flag:incident-response. schema_migration_blocks_rollback→block→log:DT-1→flag:incident-response. health_checks_pass_but_errors_elevated→do_not_declare_recovery→flag:incident-response. no_rca_initiated→flag:incident-response. post_rollback_alerting_not_confirmed→flag:monitoring-alerts.

## Reference
- See [reference.md](reference.md) for distilled source details.
