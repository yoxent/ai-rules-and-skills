---
name: migration-strategy
description: "Use when task requires Plans and governs system migrations with phased execution, rollback readiness, and cross-team coordination"
---

# Migration Strategy

name:migration-strategy|pri:H|deps:[system-design]|flags:[dependency-management,performance-optimization,backward-compatibility,observability,incident-response]|rules:[DD-2,DD-4,MF-4,DT-2,DT-1,GM-2,GM-4]
SCOPE: Plans and governs system migrations with phased execution, rollback readiness, and cross-team coordination
ENFORCE: Define explicit migration scope before planning begins — migrations without a defined target state are blocked; Require stakeholder approval before any migration execution begins (DT-2); Design a tested rollback procedure for every migration phase — untested rollbacks are not rollback plans (DD-2); Define explicit validation gate condition for each phase; proceeding without gate verification is prohibited; Notify all dependent teams before migration execution per DD-4; Define go/no-go criteria: backup verified, rollback tested in staging, monitoring in place, all gates defined; Conduct post-migration root cause analysis for any incident occurring within the observation window (MF-4); Log all speed-vs-safety tradeoffs with stakeholder approval (DT-1)
PROHIBIT: Big-bang migration for systems with strict availability SLAs without explicit stakeholder risk acceptance; Expanding migration scope during execution without re-planning and fresh stakeholder approval; Executing any migration phase without a pre-defined and tested rollback procedure; Declaring migration complete before the post-migration observation window has elapsed
ON_VIOLATION: scope_undefined → halt_planning → require_explicit_current_and_target_architecture. gate_fails → execute_phase_rollback_immediately → halt → assess_root_cause → reschedule (MF-4). rollback_fails → escalate_to_critical_incident → flag:incident-response → restore_from_backup. scope_expands → halt → re_plan → obtain_fresh_stakeholder_approval (DT-2). teams_not_notified → block_migration_execution → apply_DD-4 → notify_all_dependents. dependency_conflict_found → flag dependency-management. performance_concern_at_cutover → flag performance-optimization. consumer_interface_changed → flag backward-compatibility. monitoring_gaps_identified → flag observability

## Reference
- See [reference.md](reference.md) for distilled source details.
