```yaml
---
name: migration-strategy
description: Plans and governs system migrations with phased execution, data integrity validation, rollback readiness, and coordinated cross-team execution to minimize downtime and risk.
version: 1.1.0
category: Architecture
tags: [migration, data-integrity, rollback, phased-migration, coordination]
priority: High

depends_on: [system-design]
flags_skills: [language-specific-implementation, dependency-management, performance-optimization, backward-compatibility, observability, incident-response]

inputs: [current-architecture, target-architecture, data-dependencies, downtime-tolerance, sla-requirements]
outputs: [migration-plan, risk-assessment, rollback-strategy, success-criteria]

rules_applied:
  - DD-2
  - DD-4
  - MF-4
  - DT-2
  - DT-1
  - GM-2
  - GM-4

documents_needed: [current-architecture, target-architecture, sla-requirements, dependency-map]

execution_context: Runs when a significant structural, data, or platform migration is planned. Always requires stakeholder approval before execution begins.

---
```

---

# Skill: Migration Strategy

---

## Purpose

**What this skill does:**
Plans and governs system migrations — database schema changes, platform upgrades, service re-architectures, data migrations — with explicit phasing, data integrity validation, per-phase rollback capability, and coordinated cross-team execution.

Failed migrations cause data loss, extended downtime, and emergency rollback under pressure. A migration with no rollback path can leave a system inconsistent for hours or days. This skill prevents that by making every phase reversible and every risk identified before execution begins.

Phased migrations reduce blast radius. Per-phase rollback enables controlled recovery. Explicit success criteria prevent ambiguous "done" states. Pre-migration risk assessment surfaces integration problems before they appear mid-migration.

---

## When to Use This Skill

### Triggers:

* A database schema change affects live data or consumer integrations
* A service platform is being upgraded or replaced (e.g., EC2 to EKS, major framework upgrade)
* A monolith is being decomposed into services requiring data and traffic migration
* A third-party integration is being replaced (e.g., migrating payment processors)
* A data format or storage system is being changed
* A major dependency upgrade requires coordinated changes across multiple services
* Backward Compatibility flags that a breaking change requires a formal migration plan

### Do NOT use this skill for:

* Small, single-service, fully reversible deployments (standard deployment practices apply)
* API versioning strategy — that is Versioning's responsibility
* Code-level refactoring within a service with no external coordination — that is Refactoring's responsibility

**Execution Context:** Invoked after System Design when re-architecture requires coordinated data or service migration. Precedes Deployment Management for execution. Always gated by stakeholder approval (DT-2) before execution begins.

---

## Inputs

**Required inputs:**

* **Current and target architectures** — Both must be explicitly defined; no target state means no migration plan.
* **Data and service dependencies** — What depends on the system being migrated; determines coordination scope.
* **Downtime tolerance and SLA requirements** — Primary constraint determining migration pattern (big-bang vs. phased).

**Optional inputs:**

* **Existing data volume and schema complexity** — Affects duration estimates and validation strategy.
* **Regulatory requirements** — Data residency, retention, and audit trail requirements during migration.

**Documents needed:**

* **Current and target architecture diagrams** — Required to define scope and delta.
* **SLA requirements** — Determines acceptable downtime per phase.
* **Dependency map** — Identifies all teams and services requiring coordination per DD-4.

---

## Outputs

**Primary outputs:**

* **Migration plan with phased timeline** — Per phase: what changes, validation gate, rollback procedure, estimated duration.
* **Risk assessment** — Pre-identified failure modes with probability, impact, and mitigation. Key risks: data loss, extended downtime, integration breakage, performance degradation at cutover.
* **Rollback strategy** — Per phase: rollback trigger, steps, estimated duration, and post-rollback system state.
* **Success criteria** — Measurable criteria for declaring each phase and the overall migration complete.

**Output format:** Migration Plan Document — see Final Step for required sections.

---

## Preconditions

* Current and target architecture are both explicitly defined
* Downtime tolerance is stated by stakeholder
* Stakeholder approval obtained per DT-2 before execution begins

**Validation checks:**

* [ ] Migration scope fully defined — no "to be determined" components
* [ ] All dependent teams identified (DD-4)
* [ ] Rollback procedure tested in staging before production execution

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:** At execution start, determine whether migration planning involves code-level implementation.
- If yes → flag **language-specific-implementation** and co-invoke before planning begins
- If no (pure migration architecture/phasing design) → continue to Step 1

---

### Step 1: Migration Scope and Pattern Selection

**Questions:** What is the full scope (services, data, dependencies)? Is zero-downtime required? Which pattern fits?

**Actions:**
- [ ] Define full scope: services, databases, schemas, integrations changing
- [ ] Confirm downtime tolerance with stakeholder — determines migration pattern
- [ ] Select migration pattern: **Big-bang** (single cutover, high risk, needs maintenance window — only for low-traffic/high-downtime-tolerance systems); **Expand-contract** (parallel writes, zero-downtime, preferred for schema migrations); **Blue-green** (atomic traffic switch, zero-downtime for service migrations); **Strangler fig** (gradual traffic routing, lowest risk, longest timeline, preferred for monolith decompositions); **Dual-write** (write to both stores, validate, decommission old — for data store migrations)

**Watch-fors:** Big-bang proposed for >99.9% SLA system; scope "to be determined"; zero-downtime requirement without dual-write or blue-green strategy.

**Decisions:** Scope undefined → halt per Escalation Scenario 1. Constraints conflict → escalate per PC-3.

---

### Step 2: Phase Definition and Rollback Design

**Questions:** What changes in each phase? What is the validation gate? What triggers rollback and how long does it take?

**Actions:**
- [ ] Per phase define: what changes, duration, validation gate condition, rollback trigger, rollback steps, rollback duration
- [ ] Apply DD-2: every phase must have a **tested** rollback — "restore from backup" is last-resort recovery, not a rollback plan
- [ ] Validate rollback duration against SLA — rollback taking 4 hours when SLA allows 1 hour is an inadequate plan
- [ ] Define phase gate: observable condition verified before proceeding (data integrity check, smoke test, traffic validation)

**Watch-fors:** Phase with no rollback and potential data loss (requires redesign); rollback duration exceeding SLA window.

**Decisions:** Phase has no rollback path → redesign before proceeding.

---

### Step 3: Risk Assessment

**Questions:** What are failure modes per phase? What is the data loss risk? Which integrations could break?

**Actions:**
- [ ] Per phase: enumerate failure modes (data corruption, timeout, integration failure, performance degradation)
- [ ] Data integrity risk: any phase where data could be lost without recovery path is CRITICAL — requires mitigation
- [ ] Integration breakage: which consumers experience failures during each phase?
- [ ] Estimate worst-case duration at degraded performance — does it breach the maintenance window?

**Watch-fors:** Phase with no rollback and data loss risk; no monitoring plan; integration dependencies unidentified before migration begins.

---

### Step 4: Coordination and Communication Plan

**Actions:**
- [ ] Apply DD-4: identify all teams whose services depend on the migrated system
- [ ] Notify all dependent teams before migration: timeline, potential impact, required actions
- [ ] Define communication channel and status update cadence during migration
- [ ] Define escalation path: who has authority to abort if risk threshold is crossed?
- [ ] Define go/no-go criteria: all tests passing, backup verified, rollback tested in staging, monitoring in place, all gates defined

---

### Step 5: Success Criteria and Post-Migration Validation

**Actions:**
- [ ] Define measurable success criteria: data integrity (row counts, checksums), SLA metrics within baseline, no elevated error rate
- [ ] Apply MF-4: define post-migration observation window (typically 24–48 hours) — old system remains available for rollback
- [ ] Schedule post-migration review: capture what went wrong or was harder than expected

---

### Final Step: Generate Migration Plan Document

**Required sections:** Migration Scope · Migration Pattern + justification · Phase Plan table (phase / description / duration / validation gate / rollback / rollback duration) · Risk Assessment table (risk / phase / probability / impact / mitigation) · Go/No-Go Criteria checklist · Success Criteria · Skills Flagged · Overall Status (✅ APPROVED / ⚠️ NEEDS REVISION / ❌ BLOCKED) · Stakeholder Approval record (required per DT-2).

---

## Core Responsibilities

1. Define migration scope, pattern, and phase structure before execution begins
2. Design a tested rollback procedure for every migration phase
3. Produce a risk assessment identifying all failure modes with mitigations
4. Apply DD-4: coordinate with all dependent teams before execution
5. Define explicit go/no-go criteria and success criteria
6. Gate migration execution through DT-2 stakeholder approval

**Quality criteria:** Every phase has a tested rollback; every risk has a mitigation; all dependent teams notified; go/no-go criteria met before execution; success criteria are measurable.

---

## Constraints (Rules Applied)

* **DD-2: Rollback Readiness** — Every phase must have a tested rollback path. Untested rollbacks fail under pressure. "Restore from backup" is not a rollback plan.
* **DD-4: Release Coordination** — Migrations must be coordinated across all dependent services. Unannounced migration impacts are a governance failure.
* **MF-4: Root Cause Analysis** — Post-migration incidents must be investigated. Migrations expose pre-existing issues; RCA prevents recurrence.
* **DT-2: Confirmation Gate** — Explicit stakeholder approval required before execution. Mid-execution failures are difficult to reverse.
* **DT-1: Explicit Tradeoff Logging** — Speed vs. safety tradeoffs must be documented and stakeholder-approved.
* **GM-2: Explain Before Acting** — For any phase with data loss risk, explain consequences and alternatives before proceeding.
* **GM-4: Behavioral Transparency** — All plan outputs must be traceable to inputs. Assumptions must be stated explicitly.

---

## Tradeoff Handling

### Speed vs. Safety

**Default stance:** Phased migrations are always preferred. The additional time is justified by the ability to validate and roll back at each phase.

**Exception:** Big-bang acceptable only when: system has low traffic or a maintenance window is available; data volume completes within the window; tested rollback is possible within the window; stakeholder explicitly approves the higher risk profile.

**Resolution:** Log tradeoff with stakeholder approval per DT-1.

---

### Complexity vs. Risk Mitigation

**Default stance:** Elaborate rollback strategies add complexity but are essential for high-stakes migrations. Implementation cost is paid once; a failed migration with no rollback can mean days of incident response.

**Resolution:** Never reduce rollback complexity to save planning time. If rollback is too complex to implement, the migration should be broken into smaller phases.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Migration Scope Undefined

**Trigger:** Migration cannot proceed without explicit current and target architecture definitions.

**Action:** Halt planning. Require explicit definition of both current and target state before any migration work begins.

---

### Escalation Scenario 2: Phase Gate Failure Mid-Migration

**Trigger:** A migration phase validation gate fails or a risk threshold is crossed during execution.

**Action:** Execute the phase rollback immediately per the pre-defined procedure — do not improvise. After rollback: assess root cause per MF-4, update the migration plan, and reschedule.

---

### Escalation Scenario 3: Rollback Itself Fails

**Trigger:** The rollback procedure fails to restore the system to its pre-migration state.

**Action:** CRITICAL incident. Flag **incident-response** immediately and escalate to stakeholder. Do not attempt improvised recovery — the plan had an inadequately tested rollback. Backup restoration may be required (data loss possible).

---

### Escalation Scenario 4: Scope Expands During Execution

**Trigger:** Dependencies or data relationships discovered mid-migration require expanding scope.

**Action:** Halt. Re-plan with expanded scope. Obtain fresh stakeholder approval per DT-2 before resuming.

---

### When to halt:

* Migration scope undefined — no target architecture specified
* Rollback procedure untested in staging before production execution
* Go/no-go criteria not met at execution time

---

## Skill Integration & Orchestration

**Role in pipeline:** Invoked after System Design when re-architecture requires coordinated data or service migration. Produces the migration plan that Deployment Management executes. Flags Observability before execution and Incident Response if rollback fails.

**Integration workflow:**
1. **Orchestrator** invokes Migration Strategy when system design output includes a migration requirement
2. Skill produces migration plan, risk assessment, rollback strategy, and success criteria
3. Skill flags dependency-management, backward-compatibility, observability, performance-optimization as needed
4. **Orchestrator** gates execution on DT-2 approval; invokes Deployment Management for execution phases

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Migration reveals dependency conflicts or tight coupling | dependency-management | Coupling risks must be resolved before or during migration |
| Migration creates performance concerns at cutover | performance-optimization | Cold cache, index rebuild, or latency spikes need analysis |
| Migration changes consumer-facing interfaces | backward-compatibility | Breaking changes require formal compatibility strategy |
| Migration phases need enhanced near-real-time monitoring | observability | Failure modes must be detectable during execution |
| Rollback fails and system cannot be restored | incident-response | Critical incident response required immediately |

---

## Related Skills

**Skills this skill depends on:**
* **system-design** — Provides the target architecture defining migration scope and destination state.

**Skills this skill cooperates with:**
* **deployment-management** — Executes the migration phases this skill plans.
* **backward-compatibility** — Consulted when migration changes consumer-facing interfaces.
* **observability** — Provides monitoring instrumentation for migration phase execution.

---

## Governance Hooks

* [ ] Obtain explicit stakeholder approval before execution begins (DT-2)
* [ ] Log all speed-vs-safety tradeoffs with stakeholder sign-off (DT-1)
* [ ] Explain consequences and alternatives for any phase with data loss risk (GM-2)
* [ ] Ensure all outputs are traceable to inputs — no undocumented assumptions (GM-4)
* [ ] Notify all dependent teams before migration execution (DD-4)
* [ ] Conduct post-migration RCA for any incident within the observation window (MF-4)

---

## Example Use Cases

### General: Database Schema Migration (Expand-Contract)

A team renames a column in a high-traffic PostgreSQL table used by three services. Big-bang is rejected given the >99.9% SLA. Expand-contract is selected: Phase 1 adds the new column and dual-writes; Phase 2 backfills existing rows; Phase 3 migrates reads; Phase 4 drops the old column. Each phase has a tested rollback and validation gate. Flagged: backward-compatibility (consuming services must update), observability (monitor read errors during Phase 3 cutover).

### Edge Case: Rollback Failure During Platform Migration

Mid-migration from EC2 to EKS, a phase gate fails and the rollback itself fails due to an untested networking assumption. Incident-response is flagged immediately; stakeholder is notified; recovery switches to restore-from-backup. Post-incident RCA reveals the rollback was never tested against the actual VPC configuration — the go/no-go checklist is updated to require network-layer rollback testing.

### Edge Case: Scope Expansion Discovered Mid-Migration

During a data store migration, an undocumented service reading directly from the old database is discovered — not in the dependency map. Migration halts immediately, scope is revised to include the undocumented consumer, and fresh stakeholder approval is obtained per DT-2 before resuming.

---

## Anti-Patterns to Catch

❌ **Big-Bang for High-Traffic Systems:** Single-step cutover on a system with strict availability SLA. ✅ Use expand-contract, blue-green, or strangler fig to keep the system available at each phase.

❌ **Untested Rollback:** Documenting a rollback without testing it in staging. Untested rollbacks fail under pressure. ✅ Every rollback must be tested in staging before production migration is approved.

❌ **No Phase Gates:** Treating migration as one continuous operation — a phase 2 problem goes undetected until phase 3 makes rollback more complex. ✅ Define explicit validation gates; proceed only when gate condition is verified.

❌ **Migration Without Monitoring:** Executing without enhanced monitoring for identified failure modes. ✅ Flag observability to instrument migration-specific metrics before execution begins.

❌ **Surprise Migration Impact:** Migrating without notifying dependent teams — they discover the impact when their services fail. ✅ Apply DD-4; notify all dependent teams with sufficient lead time.

---

## Non-Goals

* ❌ Standard deployments — handled by Deployment Management
* ❌ API versioning strategy — handled by Versioning; Migration Strategy handles execution when versioning requires coordinated migration
* ❌ Code-level refactoring within a service — handled by Refactoring

---

## Notes for LLM Implementation

1. **Never accept "TBD" scope:** If the target state is undefined, halt immediately — require explicit current and target architecture before any planning begins.
2. **Rollback duration matters as much as rollback existence:** A rollback longer than the SLA window is not acceptable. Always estimate rollback duration and validate against downtime tolerance.
3. **"Restore from backup" is not a rollback plan:** It is a last-resort recovery that may lose data and take hours. Flag this explicitly if it appears as a proposed rollback for any phase.
4. **Flag observability proactively:** Migration failure modes often require specific instrumentation — do not assume existing dashboards cover migration-specific signals.
5. **Post-migration observation window is non-negotiable:** Do not declare migration complete before it elapses. The old system must remain available for rollback throughout, even when the migration appears successful.

---
