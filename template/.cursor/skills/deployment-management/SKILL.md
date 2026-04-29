---
name: deployment-management
description: "Use when task requires Stage 7, on deployment execution or planning. Executes deployment strategies with health-gated promotion and tested rollback, ensuring safe, coordinated releases."
---

# Deployment Management

name:deployment-management|pri:H|deps:[build-packaging-automation,ci-cd-pipeline-automation]|flags:[rollback-management,monitoring-alerts]|rules:[DD-2,DD-4,DT-2,MF-1]

SCOPE: Stage 7, on deployment execution or planning. Executes deployment strategies with health-gated promotion and tested rollback, ensuring safe, coordinated releases.

ENFORCE: Require DT-2 confirmation before every production deployment. Verify rollback procedure is tested in staging before production deployment. Execute health checks as blocking promotion gates — deployment is not complete until health checks pass. Select deployment strategy appropriate to change risk; HIGH risk requires canary or blue-green. Verify artifact version matches the approved pipeline run before deploying.

PROHIBIT: Marking deployment complete before health checks pass; production deployment without DT-2 confirmation; production deployment with untested rollback; fully automated production promotion without approval gate.

ON_VIOLATION: health_check_fail→halt_rollout→flag:rollback-management. untested_rollback→block_production→flag:rollback-management. no_dt2_confirmation→block→request:DT-2. high_risk_recreate_strategy→block→require_safer_strategy_or_DT2. schema_migration_no_rollback_path→log:DT-1→request:DT-2. post_deployment_alerting_not_confirmed→flag:monitoring-alerts.

## Reference
- See [reference.md](reference.md) for distilled source details.
