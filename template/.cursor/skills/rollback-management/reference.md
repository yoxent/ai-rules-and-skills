```yaml
---
name: rollback-management
description: Plans and executes rollbacks for failed deployments to restore system stability rapidly, with post-rollback validation and incident documentation.
version: 1.1.0
category: DevOps
tags: [rollback, recovery, deployment, incident, stability]
priority: High

depends_on: [deployment-management]
flags_skills: [incident-response, monitoring-alerts]

inputs: [deployment-logs, failure-indicators, rollback-plan, previous-stable-artifact]
outputs: [restored-system-state, rollback-execution-report, post-rollback-validation-results]

rules_applied:
  - DD-2
  - MF-4
  - DT-1

documents_needed: [rollback-plan, deployment-logs, previous-artifact-version, schema-migration-state]

execution_context: Triggered by deployment-management on health check failure, or directly during incident response; executes rollback and validates system recovery.

---
```

---

# Skill: Rollback Management

---

## Purpose

**What this skill does:**
Executes rollbacks for failed deployments — restoring the system to the last known stable state — and validates system health after rollback completion. It also documents the failure and rollback execution for post-incident review and root cause analysis.

Minimises user impact duration when deployments fail by providing a fast, reliable path back to stability. Prevents extended outages caused by failed forward-fix attempts under time pressure. Builds confidence in the release process by making recovery predictable.

Separates rollback execution from deployment execution, making each a focused, well-defined operation. Ensures rollback is tested before it is needed — not discovered to be broken during an incident. Feeds root cause analysis that prevents the same failure from recurring.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A deployment has failed health checks and recovery is needed
* Deployment Management flags rollback-management during a failed rollout
* Incident Response requires deployment reversal as part of remediation
* A rollback procedure needs to be tested in staging before production use
* Post-rollback validation is needed to confirm system recovery
* A rollback decision needs to be documented (rollback vs forward-fix)

### Do NOT use this skill for:

* Executing new deployments — handled by Deployment Management
* Diagnosing the root cause of the failure that triggered the rollback — handled by Bug Diagnosis and Incident Response
* Managing database schema migrations — the schema compatibility plan is an input, not produced here
* Ongoing post-rollback monitoring — handed off to Monitoring & Alerts

**Execution Context Details:**
This skill is triggered reactively — by Deployment Management on health check failure, or by Incident Response during active incidents. It executes the rollback, validates recovery, and produces a post-rollback report that feeds root cause analysis.

---

## Inputs

**Required inputs:**

* **Deployment logs and failure indicators** — The specific health check failures, error messages, or alerts that triggered the rollback decision.
* **Rollback plan** — The documented procedure for reverting to the previous stable state, including artifact version, any schema considerations, and execution steps.
* **Previous stable artifact version** — Confirmed retrievable from the artifact registry.

**Optional inputs:**

* **Application state snapshots** — For stateful services where data consistency during rollback needs to be managed.
* **SLA window** — The time budget within which rollback must complete.

---

## Outputs

**Primary outputs:**

* **Restored system state** — System running the previous stable artifact version, passing health checks.
* **Rollback execution report** — Timeline of rollback steps, duration, any issues encountered, and final health status.
* **Post-rollback validation results** — Health check results confirming system recovery, with comparison to pre-failure baseline.

---

## Preconditions

**Conditions that must be met before execution:**

* Previous stable artifact version is confirmed retrievable from registry
* Rollback plan is documented and has been tested (ideally in staging)
* Failure indicators are documented — what failed and when
* For schema migrations: compatibility plan or downward migration is confirmed

**Validation checks:**

* [ ] Previous artifact retrievable from registry
* [ ] Rollback plan documented
* [ ] Schema migration state confirmed — rollback will not cause data loss or corruption
* [ ] SLA window is known and rollback is estimated to complete within it

---

## Step-by-Step Execution Procedure

### Step 1: Assess Rollback vs Forward-Fix Decision

**Questions to answer:**
- Is rollback the right recovery path, or is a forward fix faster and safer?
- Is the previous stable artifact available?
- Is rollback possible given any schema migrations?

**Actions:**
- [ ] Assess whether rollback or forward-fix is the faster path to stability
- [ ] Confirm previous artifact version is retrievable from registry
- [ ] Check schema migration state — confirm rollback will not cause data inconsistency
- [ ] Log decision criteria via DT-1: what made rollback the chosen path

**Red flags / Warning signs:**
- Previous artifact version garbage-collected from registry — rollback blocked
- Schema migration applied that is not reversible — rollback may cause data loss
- Forward-fix estimated as faster and lower risk than rollback

**Decision points:**
- If rollback is impossible due to schema state, escalate to incident-response with documented risk.
- If forward-fix is clearly faster and safer, log decision via DT-1 and proceed with forward-fix instead.
- Log rollback vs forward-fix decision always via DT-1.

---

### Step 2: Execute Rollback

**Questions to answer:**
- What are the exact rollback steps for this service and deployment strategy?
- Are there dependencies that need to be rolled back in coordination?
- Is rollback automated or manual?

**Actions:**
- [ ] Execute rollback steps per the documented rollback plan
- [ ] For blue-green: switch traffic back to previous environment
- [ ] For canary: drain canary traffic, scale down new version
- [ ] For rolling: redeploy previous artifact version
- [ ] Monitor each rollback step for errors
- [ ] Confirm previous version instances are running and serving traffic

**Red flags / Warning signs:**
- Rollback steps failing or producing errors
- Traffic not shifting back to previous version as expected
- Dependent services not recovering after rollback completes

**Decision points:**
- If rollback steps are failing, escalate immediately to incident-response.
- If dependent services remain impacted after rollback, flag incident-response.

---

### Step 3: Validate Post-Rollback Health

**Questions to answer:**
- Are all instances of the previous version healthy?
- Are error rates and latency back to pre-failure baseline?
- Are dependent services recovered?

**Actions:**
- [ ] Confirm all instances pass readiness and liveness checks
- [ ] Verify error rate and latency match pre-failure baseline
- [ ] Check dependent service health
- [ ] Confirm no data inconsistency introduced by rollback

**Red flags / Warning signs:**
- Health checks passing but error rate still elevated — rollback may not have addressed root cause
- Data inconsistency detected post-rollback
- Dependent services not recovering

**Decision points:**
- If health checks pass but error rate remains elevated, flag incident-response — rollback may not be sufficient.
- If data inconsistency detected, escalate immediately.

---

### Step 4: Document and Hand Off

**Questions to answer:**
- Is the rollback execution documented with sufficient detail for post-incident review?
- Has root cause analysis been initiated?
- Is monitoring confirmed active for the restored system state?

**Actions:**
- [ ] Generate rollback execution report
- [ ] Document failure trigger, rollback decision, execution timeline, and outcome
- [ ] Flag incident-response to initiate root cause analysis (MF-4)
- [ ] Flag monitoring-alerts to confirm alerting is active on restored system

---

### Final Step: Generate Rollback Report

```markdown
## Rollback Management Report

**Service:** [Service Name]
**Failed Version:** [version that was rolled back]
**Restored Version:** [previous stable version]
**Date:** [YYYY-MM-DD HH:MM UTC]
**Status:** ✅ RECOVERED / ❌ ROLLBACK FAILED / ⚠️ PARTIAL RECOVERY

### Rollback Timeline
| Step | Time | Status |
|------|------|--------|
| Failure detected | HH:MM | — |
| Rollback initiated | HH:MM | — |
| Traffic restored | HH:MM | ✅ |
| Health checks pass | HH:MM | ✅ |

### Post-Rollback Health
| Check | Status | Value |
|-------|--------|-------|
| Error rate | ✅ | 0.01% (pre-failure: 0.01%) |
| Latency p95 | ✅ | 142ms (pre-failure: 140ms) |
| Data consistency | ✅ | No inconsistency detected |

### Decision Log
- **Rollback vs forward-fix decision:** [Documented via DT-1]
- **Root cause:** [Pending — flagged incident-response]

### Skills Flagged
- **incident-response**: Root cause analysis required
- **monitoring-alerts**: Confirm alerting active on restored system

### Required Actions
- [ ] Root cause analysis (incident-response)
- [ ] Fix defective deployment before re-releasing
```

---

## Core Responsibilities

1. Assess rollback vs forward-fix and log the decision via DT-1 before executing.
2. Confirm previous stable artifact is retrievable and schema state permits rollback before starting.
3. Execute rollback per the documented plan and monitor each step for failures.
4. Validate post-rollback health against pre-failure baseline before declaring recovery.
5. Trigger root cause analysis via incident-response after every rollback.

---

## Constraints (Rules Applied)

* **DD-2: Rollback Readiness** — Rollback capability must be tested before deployment, not discovered during an incident; this skill also executes rollback tests in staging on behalf of Deployment Management.
* **MF-4: Root Cause Analysis** — Every rollback must trigger a post-incident root cause analysis; rollback without RCA allows the same failure to recur.
* **DT-1: Explicit Tradeoff Logging** — The rollback vs forward-fix decision must always be logged with explicit criteria; time pressure during incidents does not exempt this requirement.

---

## Tradeoff Handling

### Tradeoff 1: Rollback Speed vs Completeness

**Conflict:** Automated rollbacks are faster but may not handle all failure states; manual validation adds safety but takes time.

**Resolution:** Execute automated rollback first for speed; validate health manually after automated steps complete; if automated rollback fails partway, escalate to incident-response immediately.

### Tradeoff 2: Rollback vs Forward-Fix

**Conflict:** Under time pressure, teams may attempt a forward fix rather than rollback, potentially extending downtime.

**Resolution:** Default to rollback as the first recovery option for deployment-related failures; choose forward-fix only if the fix is trivial, tested, and faster; log decision criteria via DT-1 regardless of which path is chosen.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Rollback Failing Mid-Execution

**Trigger:** Rollback steps are producing errors or system is not recovering as expected.

**Action:**
- Escalate immediately to incident-response
- Document current system state (partial rollback, mixed versions)
- Do not attempt to re-run failed rollback steps without incident-response guidance

---

### Escalation Scenario 2: Schema Migration Prevents Rollback

**Trigger:** Applied schema migration has no downward migration and rollback would cause data loss or corruption.

**Action:**
- Block rollback execution
- Document via DT-1 — rollback impossibility, data at risk, mitigation options
- Escalate to incident-response for forward-fix coordination

---

### Escalation Scenario 3: Health Checks Pass But System Not Fully Recovered

**Trigger:** Post-rollback health checks pass but error rate remains elevated or dependent services are still impacted.

**Action:**
- Do not declare recovery
- Flag incident-response — rollback may not have addressed root cause
- Flag monitoring-alerts for enhanced monitoring during investigation

---

### When to halt execution:

* Rollback steps are failing and system is in inconsistent state — escalate to incident-response
* Schema migration makes rollback data-destructive without DT-1 documentation and escalation
* Previous artifact not retrievable from registry

---

## Skill Integration & Orchestration

This skill is triggered by Deployment Management (health check failure) or Incident Response (deployment-related incident). It hands off to Incident Response for root cause analysis and to Monitoring & Alerts for post-rollback health tracking.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Rollback failing or system in inconsistent state | incident-response | Complex recovery needed |
| Health checks pass but recovery incomplete | incident-response | Root cause may be deeper |
| Post-rollback monitoring confirmation needed | monitoring-alerts | Alerting verification |

---

## Related Skills

**Skills this skill depends on:**
* **deployment-management** — Triggers this skill on health check failure; provides deployment context and rollback plan.

**Skills this skill cooperates with:**
* **incident-response** — Takes over if rollback fails or root cause analysis is needed.
* **monitoring-alerts** — Confirms alerting is active on the restored system after rollback.

---

## Governance Hooks

* [ ] Log rollback vs forward-fix decision via DT-1 before executing
* [ ] Confirm previous artifact retrievable before starting rollback
* [ ] Validate post-rollback health against baseline before declaring recovery
* [ ] Flag incident-response for root cause analysis after every rollback
* [ ] Document rollback execution timeline with sufficient detail for post-incident review

---

## Example Use Cases

### Example 1: Automated Rollback on Failed Health Check

**Scenario:** A Kubernetes rolling deployment fails — new pods are crashing on startup due to a missing environment variable. Health checks fail. Deployment Management flags rollback-management.

**Execution steps:**
1. Confirm previous ReplicaSet is available in cluster.
2. Log rollback decision via DT-1: health check failure, previous version stable, rollback faster than forward-fix.
3. Execute `kubectl rollout undo deployment/service-name`.
4. Monitor pod restarts — all pods return to previous version and pass health checks within 2 minutes.
5. Validate error rate and latency back to baseline.
6. Flag incident-response for root cause. Flag monitoring-alerts to confirm alerting active.

**Result:** RECOVERED.

---

### Example 2: Rollback Blocked by Schema Migration

**Scenario:** A deployment included a database migration adding a NOT NULL column. The deployment fails post-migration. Rolling back the application code would leave the schema in a state incompatible with the previous application version.

**Execution steps:**
1. Assess rollback — schema migration applied, no downward migration exists.
2. Determine rollback would cause application errors with new schema.
3. Block rollback execution.
4. Log via DT-1 — rollback impossible, forward-fix required.
5. Escalate to incident-response with schema state documented.

**Result:** Rollback blocked — escalated to incident-response for forward-fix.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Attempting rollback without confirming previous artifact is available**
✅ **Correct approach:** Always confirm the previous artifact version is retrievable from the registry before initiating rollback. A missing artifact makes rollback impossible mid-execution.

❌ **Anti-pattern 2: Declaring recovery before post-rollback health checks pass**
✅ **Correct approach:** Recovery is confirmed by health checks matching the pre-failure baseline — not by the rollback steps completing without error.

❌ **Anti-pattern 3: No root cause analysis after rollback**
✅ **Correct approach:** Every rollback must trigger root cause analysis. Without RCA, the same deployment failure will recur.

❌ **Anti-pattern 4: Attempting forward-fix under time pressure without logging the decision**
✅ **Correct approach:** Log the rollback vs forward-fix decision via DT-1 regardless of time pressure. The decision criteria are part of the incident record.

❌ **Anti-pattern 5: Rollback plan that has never been tested**
✅ **Correct approach:** Test rollback in staging before every production release cycle. An untested rollback plan is a false confidence risk.

---

## Non-Goals

* ❌ Executing new deployments — handled by Deployment Management
* ❌ Root cause analysis of the failure — handled by Incident Response and Bug Diagnosis
* ❌ Ongoing post-rollback monitoring — handled by Monitoring & Alerts
* ❌ Schema migration design — handled by Migration Strategy

---
