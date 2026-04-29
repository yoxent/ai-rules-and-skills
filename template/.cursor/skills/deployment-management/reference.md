```yaml
---
name: deployment-management
description: Plans, executes, and monitors application deployments to ensure reliability, minimal downtime, and safe rollout with validated rollback capability.
version: 1.1.0
category: DevOps
tags: [deployment, rollout, blue-green, canary, rollback]
priority: High

depends_on: [build-packaging-automation, ci-cd-pipeline-automation]
flags_skills: [rollback-management, monitoring-alerts]

inputs: [build-artifacts, deployment-manifests, target-environment-config, release-schedule, deployment-strategy]
outputs: [deployed-applications, deployment-reports, health-validation-results, rollback-procedures]

rules_applied:
  - DD-2
  - DD-4
  - DT-2
  - MF-1

documents_needed: [deployment-manifests, rollback-plan, environment-config, release-schedule]

execution_context: Runs after build and pipeline stages; executes deployment strategies and validates post-deployment health before marking release complete.

---
```

---

# Skill: Deployment Management

---

## Purpose

**What this skill does:**
Plans and executes application deployments using strategies that minimise blast radius — blue-green, canary, rolling — validates deployment health before marking a release complete, and ensures rollback procedures are tested and ready before every production deployment.

Reduces deployment-related incidents through controlled rollout strategies. Minimises user-facing downtime through zero-downtime or low-downtime deployment patterns. Provides a clear go/no-go decision point backed by health validation rather than assumption.

Separates deployment execution from pipeline orchestration. Provides structured health validation gates that prevent broken deployments from being marked successful. Ensures rollback is a first-class concern, not an afterthought discovered during an incident.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new deployment to any environment is being planned or executed
* A deployment strategy (blue-green, canary, rolling) is being selected or reviewed
* Post-deployment health validation is failing or absent
* A deployment is partially complete and needs assessment
* Rollback procedures for an upcoming release are being validated
* A production deployment requires coordination with dependent services
* Deployment patterns are being reviewed for a service migrating to containers or Kubernetes

### Do NOT use this skill for:

* Building or packaging artifacts — handled by Build & Packaging Automation
* CI/CD pipeline configuration — handled by CI/CD Pipeline Automation
* Executing rollbacks for failed deployments — handled by Rollback Management
* Post-deployment ongoing monitoring — handled by Monitoring & Alerts
* Infrastructure provisioning — handled by Infrastructure as Code

**Execution Context Details:**
This skill runs after Build & Packaging Automation and CI/CD Pipeline Automation have produced a validated artifact and approved pipeline run. It executes the deployment and hands off to Monitoring & Alerts for ongoing health tracking, and to Rollback Management if recovery is needed.

---

## Inputs

**Required inputs:**

* **Build artifacts and deployment manifests** — The versioned artifact produced by Build & Packaging Automation and the deployment configuration (Kubernetes manifests, Helm charts, ECS task definitions, etc.).
* **Target environment configuration** — Environment-specific configuration injected at deployment time (not hardcoded in manifests).
* **Release schedule and deployment strategy** — Whether to use blue-green, canary, rolling, or recreate strategy; timing constraints; dependent service release schedule.

**Optional inputs:**

* **Feature flags** — If deployment uses feature flags for incremental rollout rather than infrastructure-level traffic shifting.
* **Performance baseline** — Pre-deployment performance metrics to compare against post-deployment health checks.

---

## Outputs

**Primary outputs:**

* **Successfully deployed applications** — Running, health-validated application instances in the target environment.
* **Deployment reports** — Deployment timeline, strategy used, health check results, and go/no-go decision record.
* **Rollback procedures and readiness confirmation** — Documented and tested rollback path for the deployment, confirmed ready before release is marked complete.

---

## Preconditions

**Conditions that must be met before execution:**

* Artifact is available and retrievable from registry (Build & Packaging Automation completed)
* Pipeline approval gate has been passed (CI/CD Pipeline Automation completed)
* Rollback procedure is documented and tested in staging
* Production deployment has received DT-2 confirmation
* Dependent service release schedule has been reviewed

**Validation checks:**

* [ ] Artifact version matches the approved pipeline run
* [ ] Rollback procedure tested in staging environment
* [ ] DT-2 confirmation received for production deployment
* [ ] Health check definitions exist for post-deployment validation
* [ ] Dependent service coordination confirmed

---

## Step-by-Step Execution Procedure

### Step 1: Select and Validate Deployment Strategy

**Questions to answer:**
- What deployment strategy is appropriate for this service and release?
- Does the chosen strategy match the risk level of the change?
- Is the infrastructure ready to support the chosen strategy?

**Actions:**
- [ ] Assess change risk: LOW (config change), MEDIUM (new feature), HIGH (breaking change, schema migration)
- [ ] Select strategy: canary or blue-green for HIGH risk; rolling for MEDIUM; recreate only for stateless LOW risk
- [ ] Verify infrastructure supports the chosen strategy (e.g. load balancer for blue-green, traffic splitting for canary)
- [ ] Confirm rollback procedure is compatible with the chosen strategy

**Red flags / Warning signs:**
- Recreate strategy proposed for a stateful service or HIGH risk change
- Canary strategy proposed without defined promotion criteria or automated rollback triggers
- Blue-green proposed without load balancer or traffic shifting capability confirmed

**Decision points:**
- If HIGH risk change is proposed with recreate strategy, escalate — require safer strategy or DT-2 justification.

---

### Step 2: Confirm Rollback Readiness

**Questions to answer:**
- Is the rollback procedure documented and tested in staging?
- Is the previous stable artifact version available in the registry?
- Does the rollback path account for any database schema changes?

**Actions:**
- [ ] Verify previous stable artifact is retrievable from registry
- [ ] Confirm rollback procedure has been executed successfully in staging
- [ ] Check for schema migrations — if present, confirm rollback plan accounts for data compatibility
- [ ] Verify rollback can be executed within the SLA window

**Red flags / Warning signs:**
- Previous artifact version garbage-collected from registry
- Rollback procedure untested — only documented but never executed
- Schema migration with no downward migration or compatibility plan
- Rollback estimated to exceed SLA window

**Decision points:**
- If rollback is untested, block production deployment and flag rollback-management.
- If schema migration makes rollback impossible, escalate — require DT-2 with documented risk acceptance.

---

### Step 3: Execute Deployment with Health Gates

**Questions to answer:**
- Are health check endpoints defined and reachable?
- What is the promotion criteria for canary or blue-green deployments?
- What triggers automatic rollback?

**Actions:**
- [ ] Execute deployment using the approved strategy
- [ ] Monitor health check endpoints during rollout
- [ ] For canary: verify traffic percentage, monitor error rate and latency against baseline
- [ ] For blue-green: validate new environment fully before switching traffic
- [ ] Apply promotion criteria — only promote if health checks pass within the defined window

**Red flags / Warning signs:**
- No health check endpoints defined — deployment marked successful without validation
- Promotion criteria undefined for canary — traffic shifted without success signal
- Error rate or latency degrading during rollout without triggering rollback

**Decision points:**
- If health checks fail during rollout, initiate rollback immediately — flag rollback-management.
- If promotion criteria are not met within the defined window, flag rollback-management.

---

### Step 4: Validate Post-Deployment Health

**Questions to answer:**
- Are all instances healthy and serving traffic correctly?
- Are error rates and latency within acceptable bounds?
- Are any dependent services impacted?

**Actions:**
- [ ] Confirm all deployment instances pass readiness and liveness checks
- [ ] Verify error rate and latency are within pre-defined thresholds
- [ ] Check dependent service health — confirm no cascading impact
- [ ] Mark deployment complete only after health validation passes

**Red flags / Warning signs:**
- Deployment marked complete before health checks pass
- Increased error rate in dependent services post-deployment
- Latency degradation not detected because no baseline comparison was made

**Decision points:**
- If post-deployment health fails, do not mark release complete — initiate rollback via rollback-management.
- If dependent services show degradation, escalate immediately.

---

### Step 5: Coordinate and Communicate Release

**Questions to answer:**
- Have dependent service owners been notified of the deployment?
- Is the release timing coordinated with dependent service deployment schedules?
- Is the deployment record complete for audit purposes?

**Actions:**
- [ ] Notify dependent service owners of deployment completion
- [ ] Confirm release timing alignment with dependent service schedules
- [ ] Generate deployment report with full audit trail
- [ ] Flag monitoring-alerts to confirm post-deployment alerting is active

**Decision points:**
- If coordination was missed and a dependent service is impacted, escalate immediately.

---

### Final Step: Generate Deployment Report

```markdown
## Deployment Management Report

**Service:** [Service Name]
**Version:** [Artifact version]
**Environment:** [Target environment]
**Strategy:** [Blue-green / Canary / Rolling / Recreate]
**Date:** [YYYY-MM-DD HH:MM UTC]
**Status:** ✅ COMPLETE / ❌ FAILED / ⚠️ PARTIAL

### Deployment Health
| Check | Status | Value |
|-------|--------|-------|
| Readiness probe | ✅ | All instances passing |
| Error rate | ✅ | 0.02% (threshold: 1%) |
| Latency p95 | ✅ | 145ms (threshold: 200ms) |
| Rollback readiness | ✅ | Tested in staging |

### Release Coordination
- Dependent services notified: ✅
- Coordination confirmed: ✅

### Skills Flagged
- **rollback-management**: [Reason if flagged]
- **monitoring-alerts**: [Reason if flagged]

### Required Actions
- [ ] [Action if any]
```

---

## Core Responsibilities

1. Select deployment strategy appropriate to change risk — canary or blue-green for high-risk changes.
2. Confirm rollback is tested and ready before executing any production deployment.
3. Gate deployment completion on passing health checks — never mark complete without validation.
4. Require DT-2 confirmation for all production deployments.
5. Coordinate release timing with dependent service schedules.

---

## Constraints (Rules Applied)

* **DD-2: Rollback Readiness** — Every production deployment must have a tested rollback path; untested rollback is not rollback capability.
* **DD-4: Release Coordination** — Deployments must be coordinated with dependent service release schedules; uncoordinated deployments to shared environments risk cascading failures.
* **DT-2: Confirmation Gate** — All production deployments require explicit human approval; fully automated production promotion without approval is a violation.
* **MF-1: Feature Consistency** — Deployment must not alter behaviour outside the intended change scope; configuration-only deployments must not affect application logic.

---

## Tradeoff Handling

### Tradeoff 1: Deployment Speed vs Risk Mitigation

**Conflict:** Canary and blue-green deployments are safer but slower than rolling or recreate strategies.

**Resolution:** HIGH risk requires canary or blue-green; MEDIUM risk accepts rolling; LOW risk accepts recreate for stateless services; if a faster strategy is requested for HIGH risk, log via DT-1 and request DT-2.

### Tradeoff 2: Automation vs Human Control

**Conflict:** Fully automated deployments reduce human error but remove human judgment at critical moments.

**Resolution:** Require DT-2 — the production approval gate is non-negotiable by default; log any approval gate removal via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Health Check Failure During Rollout

**Trigger:** Health checks fail or error rate exceeds threshold during deployment.

**Action:**
- Halt rollout immediately
- Flag rollback-management with current deployment state and failure details
- Do not mark deployment complete

---

### Escalation Scenario 2: Untested Rollback Before Production

**Trigger:** Rollback procedure has not been tested in staging before production deployment.

**Action:**
- Block production deployment
- Flag rollback-management to execute rollback test in staging
- Do not proceed until rollback is validated

---

### Escalation Scenario 3: Schema Migration Making Rollback Impossible

**Trigger:** Deployment includes a database migration with no downward migration or compatibility plan.

**Action:**
- Escalate to stakeholder
- Document via DT-1 — rollback impossibility, risk, and mitigation plan
- Require DT-2 confirmation before proceeding

---

### When to halt execution:

* Health checks fail during rollout — flag rollback-management immediately
* Rollback untested and DT-2 not received to proceed without it
* Production deployment without DT-2 confirmation
* Schema migration makes rollback impossible without DT-2 risk acceptance

---

## Skill Integration & Orchestration

This skill sits downstream of Build & Packaging Automation and CI/CD Pipeline Automation, and upstream of Monitoring & Alerts (ongoing health) and Rollback Management (recovery). It is the execution layer for the release process.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Health check failure during or after deployment | rollback-management | Recovery needed |
| Rollback untested before production | rollback-management | Validation required |
| Post-deployment monitoring gaps | monitoring-alerts | Alerting instrumentation needed |

---

## Related Skills

**Skills this skill depends on:**
* **build-packaging-automation** — Produces the artifact being deployed.
* **ci-cd-pipeline-automation** — Provides the approved pipeline run that authorises deployment.

**Skills this skill cooperates with:**
* **rollback-management** — Executes rollbacks when deployment health fails.
* **monitoring-alerts** — Provides post-deployment health visibility.
* **infrastructure-as-code** — Provisions the environment being deployed to.

---

## Governance Hooks

* [ ] Require DT-2 confirmation before every production deployment
* [ ] Confirm rollback tested in staging before production deployment
* [ ] Gate deployment completion on passing health checks
* [ ] Log all strategy selection decisions and risk classifications via DT-1
* [ ] Notify dependent service owners before production deployment

---

## Example Use Cases

### Example 1: Canary Deployment for High-Risk Feature

**Scenario:** A payment service is releasing a significant change to checkout flow. Canary strategy selected — 5% traffic to new version with automated rollback on error rate > 1%.

**Execution steps:**
1. Confirm rollback tested in staging — passes.
2. Receive DT-2 confirmation for production deployment.
3. Deploy canary at 5% traffic.
4. Monitor error rate and latency for 30 minutes — both within thresholds.
5. Promote to 25% → 50% → 100% with health checks at each step.
6. Mark complete. Flag monitoring-alerts to confirm SLO alerting active.

**Result:** PASS.

---

### Example 2: Deployment Blocked — Untested Rollback

**Scenario:** A team is ready to deploy a new microservice to production. Rollback procedure is documented but has never been executed.

**Execution steps:**
1. Review pre-deployment checklist — rollback untested.
2. Block production deployment.
3. Flag rollback-management to execute rollback test in staging.
4. Rollback test completes successfully.
5. Re-run deployment with validated rollback.

**Result:** Initially blocked → PASS after rollback validation.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Marking deployment complete before health checks pass**
✅ **Correct approach:** Deployment is not complete until health checks pass. A running process is not a healthy deployment.

❌ **Anti-pattern 2: Using recreate strategy for stateful or high-risk changes**
✅ **Correct approach:** Recreate causes downtime and has no gradual rollout. Use canary or blue-green for high-risk or stateful changes.

❌ **Anti-pattern 3: Rollback procedure documented but never tested**
✅ **Correct approach:** An untested rollback is not a rollback — it is a document. Test rollback in staging before every production release cycle.

❌ **Anti-pattern 4: Fully automated production promotion without approval gate**
✅ **Correct approach:** Production deployments always require a human approval gate. Automation handles everything up to production; humans approve the final step.

❌ **Anti-pattern 5: No canary promotion criteria defined**
✅ **Correct approach:** Canary deployments must have explicit promotion criteria (error rate threshold, latency threshold, observation window). Without criteria, promotion is arbitrary.

❌ **Anti-pattern 6: Deploying without coordinating dependent service schedules**
✅ **Correct approach:** Identify dependent services before deployment and confirm release timing. Uncoordinated deployments to shared environments cause cascading failures.

---

## Non-Goals

* ❌ Building or packaging artifacts — handled by Build & Packaging Automation
* ❌ CI/CD pipeline configuration — handled by CI/CD Pipeline Automation
* ❌ Executing rollbacks — handled by Rollback Management
* ❌ Ongoing post-deployment monitoring — handled by Monitoring & Alerts
* ❌ Infrastructure provisioning — handled by Infrastructure as Code

---
