---

```yaml
---
name: ci-cd-pipeline-automation
description: Designs and manages CI/CD pipelines to ensure rapid, safe, repeatable releases with enforced quality gates and rollback capability.
version: 1.1.0
category: DevOps
tags: [ci-cd, pipeline, automation, deployment, quality-gates]
priority: High

depends_on: [build-packaging-automation]
flags_skills: [deployment-management, monitoring-alerts, infrastructure-as-code, secrets-management]

inputs: [source-repository, build-scripts, quality-gate-definitions, deployment-targets, environment-configurations]
outputs: [automated-pipelines, deployment-logs, release-artifacts-with-audit-trail]

rules_applied:
  - DD-1  # CI/CD Enforcement — pipelines must enforce tests and quality gates; no production deploy without passing pipeline
  - DD-2  # Rollback Readiness — every pipeline must include a tested rollback path
  - DD-4  # Release Coordination — pipeline releases must coordinate with dependent service schedules
  - DT-2  # Confirmation Gate — production deployments require explicit approval in the pipeline

documents_needed: [pipeline-definition, branch-strategy, environment-configurations, deployment-manifests]

execution_context: Runs at pipeline design, modification, or failure diagnosis; wraps and orchestrates build-packaging-automation and deployment-management.

---
```

---

# Skill: CI/CD Pipeline Automation

---

## Purpose

**What this skill does:**
Designs, implements, and manages continuous integration and deployment pipelines that automate the full build-test-deploy lifecycle. It ensures every code change passes defined quality gates before progressing toward production, that rollback capability is built into every pipeline, and that production deployments require explicit approval.

Eliminates manual release processes that introduce human error and inconsistency. Provides an auditable, repeatable release trail. Shortens time-to-production for validated changes while reducing deployment-related incidents through enforced gates and rollback readiness.

Centralises release governance in version-controlled pipeline definitions. Ensures quality gates cannot be bypassed by individual developers. Provides deployment observability and failure recovery paths as first-class pipeline concerns rather than afterthoughts.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new service or application needs its first CI/CD pipeline defined
* An existing pipeline is failing, degraded, or blocking releases
* A pipeline is missing rollback capability or a production approval gate
* Pipeline configuration is being reviewed for quality gate coverage or security
* A new deployment environment or strategy (blue-green, canary, rolling) is being introduced
* Pipeline performance is degrading and restructuring is needed
* A release coordination problem is identified (dependent services deploying out of order)

### Do NOT use this skill for:

* Executing a specific deployment — that is handled by Deployment Management
* Building or packaging application artifacts — that is handled by Build & Packaging Automation
* Provisioning the infrastructure the pipeline deploys to — that is handled by Infrastructure as Code
* Monitoring post-deployment health — that is handled by Monitoring & Alerts

**Execution Context Details:**
This skill operates at pipeline design and maintenance time, and at failure diagnosis time. It wraps Build & Packaging Automation (which it depends on) and orchestrates into Deployment Management. It is triggered by new pipeline needs, pipeline failures, or quality governance reviews.

---

## Inputs

**Required inputs:**

* **Source code repository and branch strategy** — Repository URL, branching model (trunk-based, GitFlow, etc.), and trigger rules (push to main, PR merge, tag creation). Determines pipeline trigger configuration.
* **Build scripts and quality gate definitions** — Existing build tool configuration and the set of quality gates required (unit tests, integration tests, linting, security scan, coverage thresholds). Determines pipeline stage design.
* **Deployment targets and environment configurations** — Target environments (dev, staging, production), their configurations, and any environment-specific pipeline behaviour (e.g. manual approval only for production).

**Optional inputs:**

* **Existing pipeline definition** — For modification or diagnosis tasks; the current pipeline file (`.github/workflows/*.yml`, `Jenkinsfile`, `.gitlab-ci.yml`, etc.).
* **SLA or pipeline performance budget** — If build time targets exist, these constrain stage parallelism design.

---

## Outputs

**Primary outputs:**

* **Automated build, test, and deploy pipelines** — Complete pipeline definitions (as code) covering all stages from trigger to deployment with quality gates and approval steps.
* **Deployment logs and notifications** — Per-run logs for each pipeline stage, with failure notifications routed to appropriate teams.
* **Release artifacts with audit trail** — Pipeline runs produce a traceable record linking source commit → build artifact → deployment event → environment.

**Output format:**

* Pipeline definition files in the target CI/CD platform format (YAML, Groovy, HCL)
* Structured stage logs parseable by monitoring tools
* Release audit records (commit SHA, artifact version, approver, deployment timestamp)

**Skill flags (if applicable):**

* Flag **deployment-management** when a pipeline stage requires deployment strategy decisions (blue-green, canary) beyond pipeline configuration scope.
* Flag **monitoring-alerts** when pipeline failure notifications or post-deployment health checks need instrumentation.
* Flag **infrastructure-as-code** when a pipeline change requires new or modified infrastructure to be provisioned.
* Flag **secrets-management** when hardcoded credentials are found in pipeline definitions.

---

## Preconditions

**Conditions that must be met before execution:**

* Build & Packaging Automation skill has been applied or a build stage is already defined
* Target deployment environments exist or are being provisioned in parallel
* Branch strategy is documented and agreed
* Quality gate definitions (test suites, coverage thresholds) are available

**Validation checks:**

* [ ] Pipeline trigger rules correctly map to branch strategy
* [ ] All required pipeline stages are present (build, test, quality gates, approval, deploy)
* [ ] Production stage includes a manual approval gate
* [ ] Rollback step is defined and has been tested

---

## Step-by-Step Execution Procedure

### Step 1: Audit or Define Pipeline Stages

**Questions to answer:**
- What stages does the pipeline need (or currently have)?
- Are all quality gates present and configured as blocking?
- Is there a manual approval gate before production deployment?

**Actions:**
- [ ] Map required stages: trigger → build → unit test → integration test → lint/static analysis → security scan → approval gate (production) → deploy → post-deploy health check
- [ ] Verify each stage is blocking (failure halts pipeline progression)
- [ ] Confirm production approval gate is present and requires a named approver

**Red flags / Warning signs:**
- Missing approval gate before production deployment
- Quality gate stages configured as non-blocking warnings
- No post-deploy health check stage

**Decision points:**
- If approval gate is absent, block and require addition before proceeding.
- If quality gates are non-blocking, log via DT-1 and request DT-2 confirmation.

---

### Step 2: Verify Rollback Capability

**Questions to answer:**
- Is a rollback step defined in the pipeline?
- Has the rollback step been tested against a real deployment?
- Does the rollback path cover database schema changes if applicable?

**Actions:**
- [ ] Confirm rollback step exists in pipeline definition
- [ ] Verify rollback references a retrievable prior artifact version
- [ ] Check that rollback is executable without manual intervention (automated trigger on health check failure, or documented manual procedure)
- [ ] Confirm rollback has been tested in staging before production release

**Red flags / Warning signs:**
- Rollback step defined but never tested
- Rollback references artifact versions that may have been garbage collected from registry
- No rollback path for database migrations

**Decision points:**
- If rollback is untested, flag as HIGH risk and request confirmation before production deployment proceeds.
- If rollback is impossible (e.g. irreversible schema migration), escalate to deployment-management for migration strategy.

---

### Step 3: Validate Environment Configuration and Parity

**Questions to answer:**
- Does the pipeline correctly map stages to target environments?
- Are environment-specific configurations injected via secrets/variables, not hardcoded?
- Does the pipeline enforce staging deployment before production?

**Actions:**
- [ ] Verify pipeline stage-to-environment mapping (dev → staging → production progression enforced)
- [ ] Confirm all environment-specific values are injected via CI/CD secrets or variable stores, not committed to the pipeline file
- [ ] Verify staging environment is a required gate before production promotion

**Red flags / Warning signs:**
- Hardcoded credentials or environment-specific values in pipeline definition file
- Pipeline allows direct production deployment without passing staging
- Staging and production pipeline stages use different quality gate configurations

**Decision points:**
- If hardcoded secrets are found, block immediately — treat as CL-3 violation.
- If staging gate is absent, log via DT-1 and require confirmation.

---

### Step 4: Validate Release Coordination

**Questions to answer:**
- Does this service have dependent services that must deploy in coordination?
- Are downstream pipeline triggers or manual coordination steps defined?
- Is there a notification step to alert dependent teams before production deployment?

**Actions:**
- [ ] Identify dependent service deployment dependencies
- [ ] Verify pipeline includes coordination steps (downstream triggers, notification steps, or documented manual coordination)
- [ ] Confirm release schedule alignment with dependent services

**Red flags / Warning signs:**
- No coordination mechanism for services with known deployment dependencies
- Pipeline deploys to production without notifying dependent service owners

**Decision points:**
- If coordination is missing for a service with known dependencies, log via DT-1 and flag deployment-management.

---

### Step 5: Assess Pipeline Performance and Reliability

**Questions to answer:**
- What is the current pipeline duration? Does it meet the team's feedback loop requirements?
- Are there flaky stages causing intermittent failures?
- Is pipeline configuration DRY and maintainable?

**Actions:**
- [ ] Measure or estimate total pipeline duration per stage
- [ ] Identify stages that can be parallelised without compromising gate ordering
- [ ] Flag flaky test stages for remediation
- [ ] Check pipeline definition for duplicated configuration that should be extracted to shared templates

**Red flags / Warning signs:**
- Pipeline duration exceeding team SLA without justification
- Identical stage configuration repeated across multiple pipeline files (maintainability risk)
- Flaky stages causing frequent false failures

**Decision points:**
- If parallelism is proposed that could allow a failing gate to be bypassed, reject and redesign stage ordering.
- If pipeline complexity is high, apply DA-5 (Avoid Overengineering) — recommend simplification.

---

### Final Step: Generate CI/CD Pipeline Report

**Report/Output structure:**

```markdown
## CI/CD Pipeline Automation Report

**Target:** [Service/Pipeline Name]
**Platform:** [GitHub Actions / Jenkins / GitLab CI / etc.]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Stage Coverage
| Stage | Present | Blocking | Notes |
|-------|---------|----------|-------|
| Build | ✅ | ✅ | |
| Unit Tests | ✅ | ✅ | |
| Integration Tests | ✅ | ✅ | |
| Security Scan | ⚠️ | ❌ | Non-blocking — DT-1 required |
| Production Approval Gate | ✅ | ✅ | Named approver required |
| Rollback Step | ✅ | N/A | Tested in staging ✅ |
| Post-Deploy Health Check | ❌ | — | Missing |

### Skills Flagged for Follow-up
- **deployment-management**: [Reason if flagged]
- **monitoring-alerts**: [Reason if flagged]

### Overall Assessment
**Decision:**
- ✅ PASS: All required stages present and blocking; rollback tested; approval gate enforced.
- ❌ FAIL: Required stage missing or approval gate absent.
- ⚠️ NEEDS REVIEW: Non-blocking quality gate or untested rollback detected.

### Required Actions
- [ ] [Action 1 — if any]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Ensure all pipeline stages are present, correctly ordered, and configured as blocking.
2. Enforce a manual approval gate before every production deployment.
3. Verify rollback capability is defined, tested, and references retrievable artifacts.
4. Prevent secrets and environment-specific values from being hardcoded in pipeline definitions.
5. Coordinate release timing with dependent service pipelines.

**Quality criteria:**

* Every required stage is blocking (failure halts progression to next stage)
* Production approval gate requires a named human approver
* Rollback step has been tested in staging before production use
* No secrets or credentials in pipeline definition files
* Pipeline definition is version-controlled and reviewable

---

## Constraints (Rules Applied)

* **DD-1: CI/CD Enforcement** — Every pipeline must enforce tests and quality gates as blocking stages; no production deployment without a passing pipeline run. Manual bypasses require DT-1 + DT-2.
* **DD-2: Rollback Readiness** — Every pipeline must include a tested rollback step. An untested rollback is treated as incomplete; pipelines must not be used for production releases until rollback is validated.
* **DD-4: Release Coordination** — Pipeline releases must account for dependent service deployment schedules; coordination can be automated or manual but must exist.
* **DT-2: Confirmation Gate** — Production deployments require explicit human approval. Fully automated production deployments without approval gates require DT-2 confirmation; removal requires explicit justification.

---

## Tradeoff Handling

### Tradeoff 1: Pipeline Speed vs Deployment Safety

**Conflict:** Fast pipelines improve developer feedback but may reduce quality gate coverage or remove approval gates for speed.

**Resolution:** Detect removed quality gate or bypassed approval gate → log via DT-1 (what removed, speed gain, risk) → request DT-2 confirmation → block until received; restore gate if confirmation not provided.

---

### Tradeoff 2: Automation Complexity vs Reliability

**Conflict:** Highly optimised pipelines (dynamic matrix builds, conditional stage logic, shared template libraries) fail in non-obvious ways and are hard to debug.

**Resolution:** Detect complexity growing beyond team's maintainability → recommend simplest pipeline satisfying requirements (DA-5) → log complexity tradeoff via DT-1 if justified.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Missing Production Approval Gate

**Trigger:** Pipeline definition has no manual approval step before production deployment.

**Action:**
- Block pipeline approval immediately
- Report missing gate with specific stage location
- Require addition of approval gate before pipeline is used for production

**Escalation format:**
```
⚠️ PIPELINE COMPLIANCE FAILURE

Issue: No manual approval gate before production deployment stage.
Context: DD-1 and DT-2 require explicit human approval for production deployments.
Options:
  A. Add manual approval step between staging deploy and production deploy stages.
  B. Request DT-2 confirmation to proceed without approval gate (exceptional cases only).

Recommendation: Option A — add approval gate as a standard pipeline stage.

Question: Should the approval gate be added, or is there a documented reason to proceed without one?
```

---

### Escalation Scenario 2: Untested Rollback

**Trigger:** Rollback step is defined in the pipeline but has not been tested in staging.

**Action:**
- Flag as HIGH risk
- Block production deployment until rollback is tested
- Escalate to deployment-management for rollback validation

---

### Escalation Scenario 3: Hardcoded Secret in Pipeline Definition

**Trigger:** A credential, API key, or environment-specific secret is found committed directly in the pipeline file.

**Action:**
- Block pipeline use immediately (CL-3 violation)
- Report specific location of the hardcoded value (line number, stage name) without reproducing the value
- Flag secrets-management; require remediation via proper secrets store before pipeline can be used

---

### Escalation Scenario 4: Flaky Pipeline Causing False Failures

**Trigger:** A pipeline stage fails intermittently without corresponding code defects.

**Action:**
- Flag the flaky stage for remediation
- Do not permanently disable or demote the flaky stage to non-blocking without DT-1 + DT-2
- Escalate to monitoring-alerts if flakiness pattern suggests infrastructure instability

---

### When to halt execution:

* Hardcoded secret found in pipeline definition — immediate block
* Production approval gate absent and no confirmation provided
* Rollback is impossible (e.g. irreversible migration) and no mitigation plan exists
* Pipeline allows direct production deployment without passing staging

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

CI/CD Pipeline Automation sits above Build & Packaging Automation (which it depends on) and orchestrates into Deployment Management. It is the governance layer for the full release lifecycle — it does not execute deployments itself but ensures the pipeline that does is correctly structured.

### How This Skill Integrates

1. **Orchestrator** invokes this skill when a pipeline needs design, review, or diagnosis
2. This skill audits or defines pipeline stages, gates, rollback, and coordination
3. This skill **flags** deployment-management, monitoring-alerts, or infrastructure-as-code as needed
4. **Orchestrator** invokes flagged skills for their specific concerns

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Deployment strategy decision needed (blue-green, canary) | deployment-management | Strategy selection is beyond pipeline config scope |
| Post-deployment health check instrumentation needed | monitoring-alerts | Alert rules and health check setup is monitoring domain |
| Pipeline requires new infrastructure to be provisioned | infrastructure-as-code | Infrastructure provisioning is IaC domain |

---

## Related Skills

**Skills this skill depends on:**
* **build-packaging-automation** — Produces the artifacts that this skill's pipelines deploy. Pipeline design depends on understanding the build stage outputs and quality gates.

**Skills this skill cooperates with:**
* **deployment-management** — Deployment Management executes the deployment strategies that this skill's pipelines trigger. Close coordination on deployment stage design.
* **monitoring-alerts** — Post-deployment health checks and pipeline failure notifications require monitoring instrumentation.
* **rollback-management** — Rollback steps in pipelines are designed in coordination with Rollback Management.

**Skills this skill may invoke/flag:**
* **deployment-management** — When deployment strategy decisions are needed.
* **monitoring-alerts** — When notification or health check instrumentation is needed.
* **infrastructure-as-code** — When pipeline changes require infrastructure provisioning.

---

## Governance Hooks

* [ ] Log all quality gate bypass decisions via DT-1 with compensating control
* [ ] Never approve a production deployment pipeline without a tested rollback step
* [ ] Enforce DT-2 confirmation for production approval gate removal
* [ ] Block immediately on hardcoded secrets in pipeline definitions
* [ ] Document all release coordination decisions
* [ ] Validate pipeline definition is version-controlled before approving

**Audit trail requirements:**

* Every pipeline run must produce a release record (commit, artifact, approver, timestamp)
* Quality gate bypass decisions must be logged with rationale
* Rollback test results must be documented before production use

---

## Example Use Cases

### Example 1: GitHub Actions Pipeline for Node.js Microservice

**Scenario:** A team needs a new CI/CD pipeline for a Node.js microservice deploying to AWS ECS across dev, staging, and production environments.

**Inputs provided:**
- GitHub repository with trunk-based branching
- `package.json` with test and lint scripts defined
- ECS task definitions for dev, staging, production
- No existing pipeline

**Execution steps:**
1. Define stages: push trigger → build (npm ci + webpack) → unit tests → lint → security scan (npm audit) → deploy to dev → deploy to staging → manual approval → deploy to production → health check.
2. Verify all stages are blocking.
3. Define rollback step: revert ECS task definition to previous revision.
4. Configure production approval gate with named approver requirement.
5. Inject AWS credentials via GitHub Actions secrets, not hardcoded.

**Result:** PASS — complete pipeline defined with all gates, approval, and rollback.

**Skills flagged:** monitoring-alerts (post-deploy health check instrumentation needed).

---

### Example 2: Jenkins Pipeline Missing Approval Gate

**Scenario:** An existing Jenkins pipeline for a payment service deploys directly to production after passing staging tests — no manual approval gate.

**Inputs provided:**
- Existing `Jenkinsfile` with build → test → deploy-staging → deploy-production stages
- Payment service — compliance-sensitive

**Execution steps:**
1. Audit stages — approve gate absent before deploy-production.
2. Classify as DD-1 and DT-2 violation.
3. Block pipeline for production use.
4. Request addition of `input` step before deploy-production stage.

**Result:** FAIL — approval gate absent; pipeline blocked for production use until remediated.

**Skills flagged:** None (remediation is pipeline configuration change within this skill's scope).

---

### Example 3: Pipeline with Hardcoded Database Credentials

**Scenario:** A GitLab CI pipeline for a data service has a hardcoded database password in the `.gitlab-ci.yml` file committed to the repository.

**Execution steps:**
1. Detect hardcoded credential in pipeline file during audit.
2. Block pipeline use immediately — CL-3 violation.
3. Report stage name and line number of violation without reproducing the credential value.
4. Require migration to GitLab CI/CD variable store before pipeline is re-enabled.

**Result:** FAIL — CL-3 violation; pipeline blocked immediately.

**Skills flagged:** secrets-management (for credential rotation and vault integration).

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Fully automated production deployment with no approval gate**
✅ **Correct approach:** Always require a named human approver before production deployment. Even low-risk services benefit from a deliberate promotion decision.

❌ **Anti-pattern 2: Hardcoded credentials in pipeline definition files**
✅ **Correct approach:** All secrets must be injected via the CI/CD platform's secret store (GitHub Actions secrets, GitLab CI variables, Jenkins credentials store). Pipeline files are version-controlled and must never contain sensitive values.

❌ **Anti-pattern 3: Rollback step defined but never tested**
✅ **Correct approach:** A rollback step that has never been executed is not a rollback capability — it is a false confidence risk. Test rollback in staging before every production release cycle.

❌ **Anti-pattern 4: Quality gate stages configured as warnings rather than failures**
✅ **Correct approach:** Every quality gate must be blocking. A non-blocking security scan or test stage is not a quality gate — it is noise that teams learn to ignore.

❌ **Anti-pattern 5: Pipeline allows direct production deployment without passing staging**
✅ **Correct approach:** Staging must be a mandatory gate before production promotion. Direct production deploys bypass the environment parity that staging provides.

❌ **Anti-pattern 6: Skipping CI with commit message flags (`[skip ci]`)**
✅ **Correct approach:** CI skip flags are acceptable only for documentation-only changes where no code is modified. Any code change that skips CI must be explicitly confirmed via DT-2.

❌ **Anti-pattern 7: Over-engineered pipeline with complex conditional logic**
✅ **Correct approach:** Apply DA-5. Pipelines should be readable and maintainable by any team member. Complex conditional matrix logic should be replaced with simple, explicit stage definitions unless the complexity is justified by a real requirement.

❌ **Anti-pattern 8: Single pipeline file covering all services in a monorepo without path filtering**
✅ **Correct approach:** Use path filters to trigger only the relevant pipeline for changed services. A single pipeline that rebuilds all services on any change creates unnecessary build load and obscures failure attribution.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Executing deployment steps — handled by Deployment Management
* ❌ Building or packaging application artifacts — handled by Build & Packaging Automation
* ❌ Provisioning infrastructure the pipeline deploys to — handled by Infrastructure as Code
* ❌ Defining or executing rollback procedures — handled by Rollback Management
* ❌ Post-deployment monitoring and alerting — handled by Monitoring & Alerts

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Audit before designing:** For existing pipelines, always audit the current state before proposing changes. Identify what is present, what is missing, and what is misconfigured.
2. **Treat approval gate absence as a blocking defect:** Never suggest workarounds for a missing production approval gate — require it.
3. **Never reproduce secret values:** When a hardcoded secret is detected, report its location (stage, line) but never echo the value.
4. **Distinguish pipeline failures from code failures:** A failing build stage caused by a code defect is not a pipeline problem. A failing stage caused by misconfigured environment variables is.
5. **Be specific about stage ordering:** Vague advice like "add more gates" is not actionable. Specify exactly where in the stage sequence a gate should be added.

6. Use stage coverage tables for pipeline audits: ❌ missing/non-blocking, ✅ compliant, ⚠️ needs review. Provide pipeline definition code snippets for recommended changes; reference specific stage names and line numbers.

---
