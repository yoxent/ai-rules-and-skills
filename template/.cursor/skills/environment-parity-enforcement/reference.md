```yaml
---
name: environment-parity-enforcement
description: Ensures consistency between development, staging, and production environments to prevent deployment failures caused by configuration or dependency drift.
version: 1.0.0
category: DevOps
tags: [environment, parity, drift, consistency, staging]
priority: Medium

depends_on: [infrastructure-as-code]
flags_skills: [deployment-management, ci-cd-pipeline-automation]

inputs: [environment-configuration-definitions, deployment-scripts, versioned-artifacts]
outputs: [validated-environment-snapshots, drift-detection-reports, parity-documentation]

rules_applied:
  - DD-3
  - MF-1
  - DD-1
  - DT-1

execution_context: Runs as a pipeline gate before production promotion and reactively when environment-specific failures are reported.

---
```

---

# Skill: Environment Parity Enforcement

---

## Purpose

**What this skill does:**
Detects and remediates configuration drift between development, staging, and production environments. It validates that dependencies, runtime versions, and configurations are consistent across tiers before promotion, and documents any intentional differences with explicit justification.

Prevents the class of production failures that only appear in production because staging does not accurately represent it. Reduces time wasted debugging environment-specific issues that would have been caught earlier with parity validation. Increases confidence in staging as a reliable pre-production gate.

Makes environment differences explicit and intentional rather than accidental. Provides a repeatable validation step that can be automated in CI/CD pipelines. Surfaces drift before it causes deployment failures rather than after.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A deployment fails in production but not in staging
* Pre-production promotion parity check is being added to a pipeline
* Environment configurations are being reviewed for consistency
* A new environment tier is being established
* Dependency or runtime version differences are suspected between environments
* An existing parity check is producing false positives or missing real drift

### Do NOT use this skill for:

* Provisioning environment infrastructure — handled by Infrastructure as Code
* Executing deployments — handled by Deployment Management
* Designing CI/CD pipeline stages — handled by CI/CD Pipeline Automation
* Diagnosing application-level bugs — handled by Bug Diagnosis

---

## Inputs

**Required inputs:**

* **Environment configuration definitions** — The declared configuration for each environment tier (runtime versions, dependency versions, environment variables, resource limits).
* **Deployment scripts and manifests** — Kubernetes manifests, Helm values files, Docker Compose files, or equivalent per environment.
* **Versioned application artifacts** — The artifact versions deployed to each environment tier.

**Optional inputs:**

* **Prior drift detection reports** — To identify recurring drift patterns.
* **Intentional difference documentation** — Previously documented and approved differences between environment tiers.

---

## Outputs

**Primary outputs:**

* **Validated environment snapshots** — Point-in-time record of configuration state per environment tier, confirmed consistent.
* **Drift detection reports** — Specific differences found between environment tiers, classified as intentional (documented) or unintentional (blocking).
* **Configuration parity documentation** — Updated record of intentional differences with justification, for reference and compliance.

---

## Preconditions

**Conditions that must be met before execution:**

* Environment configuration definitions are available for all tiers being compared
* Deployment manifests are version-controlled and current
* Intentional difference documentation is available (or acknowledged as absent)

**Validation checks:**

* [ ] Environment configurations are version-controlled
* [ ] Deployment manifests are available for all tiers
* [ ] Intentional differences are documented with justification
* [ ] Parity validation step is in CI/CD pipeline before production promotion

---

## Step-by-Step Execution Procedure

### Step 1: Compare Runtime and Dependency Versions

**Questions to answer:**
- Are runtime versions (Node.js, JVM, Python, etc.) identical across tiers?
- Are dependency versions pinned identically across tiers?
- Are any dependencies present in one environment but absent in another?

**Actions:**
- [ ] Compare runtime version specifications across environment manifests
- [ ] Compare dependency lock files or version manifests across tiers
- [ ] Identify any dependency present in staging but absent in production or vice versa
- [ ] Classify each difference: intentional (documented) or unintentional (blocking)

**Red flags / Warning signs:**
- Runtime minor version differences that can affect behaviour (e.g. Node.js 18.17 vs 18.19)
- Dependency version differences not reflected in lock files
- Development-only dependencies present in production manifests

**Decision points:**
- If unintentional runtime difference found, block production promotion and require remediation.
- If intentional difference found without documentation, require DT-1 log before proceeding.

---

### Step 2: Compare Configuration and Environment Variables

**Questions to answer:**
- Are configuration schemas identical across tiers (same keys, expected value differences)?
- Are any configuration keys present in one environment but absent in another?
- Are any configuration values hardcoded in manifests rather than injected?

**Actions:**
- [ ] Compare configuration key sets across environment manifests — same keys required
- [ ] Verify value differences are expected (e.g. different DB endpoints per environment)
- [ ] Check for missing configuration keys in any tier — missing keys cause runtime failures
- [ ] Confirm no hardcoded environment-specific values in shared manifests

**Red flags / Warning signs:**
- Configuration key present in staging but missing in production — guaranteed runtime failure
- Hardcoded database URLs or API endpoints in shared manifests
- Different feature flag configurations between staging and production without documentation

**Decision points:**
- If configuration key is missing in production that exists in staging, block promotion immediately.
- If feature flag differences exist, require DT-1 documentation before proceeding.

---

### Step 3: Compare Resource Limits and Infrastructure Sizing

**Questions to answer:**
- Are resource limits (CPU, memory) representative between staging and production?
- Are significant sizing differences documented and intentional?
- Could staging resource constraints mask production performance issues?

**Actions:**
- [ ] Compare CPU and memory limits across environment manifests
- [ ] Identify significant sizing differences (e.g. staging running at 10% of production capacity)
- [ ] Document sizing differences with justification via DT-1
- [ ] Flag if staging resource constraints could mask production-only performance issues

**Red flags / Warning signs:**
- Staging running with 10x less memory than production — performance issues won't surface in staging
- No resource limits defined in any environment — unbounded resource consumption risk
- Production resource limits lower than staging — accidental reversal

**Decision points:**
- If staging is significantly under-provisioned relative to production, log via DT-1 as a known parity limitation.

---

### Step 4: Validate Parity Check Is in Pipeline

**Questions to answer:**
- Is parity validation automated as a pipeline step before production promotion?
- Is the parity check blocking — does it prevent promotion on failure?
- Is the parity check comprehensive enough to catch the most common drift patterns?

**Actions:**
- [ ] Verify parity validation step exists in CI/CD pipeline before production promotion stage
- [ ] Confirm parity check is blocking — failures prevent promotion
- [ ] Assess coverage of parity check — runtime, dependencies, configuration keys, resource limits
- [ ] Flag ci-cd-pipeline-automation if parity check needs to be added or improved

**Red flags / Warning signs:**
- Parity check absent from pipeline — promotion happens without validation
- Parity check present but non-blocking — drift is reported but not prevented
- Parity check only covers a subset of drift types

**Decision points:**
- If parity check absent, flag ci-cd-pipeline-automation to add it before next production promotion.

---

### Final Step: Generate Parity Report

```markdown
## Environment Parity Report

**Environments compared:** [dev / staging / production]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Drift Summary
| Component | Staging | Production | Status | Intentional |
|-----------|---------|------------|--------|-------------|
| Node.js version | 20.11.0 | 20.11.0 | ✅ | — |
| DB endpoint | staging-db | prod-db | ✅ | ✅ DT-1 |
| Memory limit | 512Mi | 2Gi | ⚠️ | ✅ DT-1 |
| Config key: FEATURE_X | present | absent | ❌ | ✗ |

### Skills Flagged
- **deployment-management**: [If parity failure blocks promotion]
- **ci-cd-pipeline-automation**: [If parity check missing from pipeline]

### Required Actions
- [ ] Add missing FEATURE_X config key to production before promotion
```

---

## Core Responsibilities

1. Detect all configuration, dependency, and runtime differences between environment tiers.
2. Classify each difference as intentional (documented via DT-1) or unintentional (blocking).
3. Block production promotion on any unintentional drift.
4. Ensure parity validation is automated as a blocking pipeline step.
5. Document all intentional differences with explicit justification.

---

## Constraints (Rules Applied)

* **DD-3: Infrastructure Validation** — Environment configurations must be version-controlled and validated before promotion; drift discovered manually after production failures is a gap.
* **MF-1: Feature Consistency** — Environment drift causing behavioural differences between tiers (different feature flags, dependency versions, or runtime behaviour) is a violation.
* **DD-1: CI/CD Enforcement** — Parity validation must be a blocking pipeline step before production promotion, not a manual check.
* **DT-1: Explicit Tradeoff Logging** — Intentional environment differences must be logged with justification; undocumented differences are treated as unintentional drift.

---

## Tradeoff Handling

### Tradeoff 1: Strict Parity vs Development Flexibility

**Conflict:** Strict environment parity is necessary for reliable staging, but development environments need flexibility for experimentation.

**Resolution:** Allow flexibility in development but document intentional differences; enforce strict parity between staging and production; document staging-to-development differences via DT-1.

### Tradeoff 2: Parity Confidence vs Automation Complexity

**Conflict:** Comprehensive automated parity checks provide more confidence but are complex to maintain.

**Resolution:** Start with runtime versions, dependency lock files, and configuration key presence; automate these as blocking pipeline checks; expand coverage based on drift patterns observed in post-incident reviews.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Unintentional Drift Blocking Promotion

**Trigger:** Parity check finds unintentional drift that blocks production promotion.

**Action:**
- Block promotion
- Report specific drift items with environment values
- Flag deployment-management — promotion is blocked
- Require remediation before promotion proceeds

---

### Escalation Scenario 2: Parity Check Absent from Pipeline

**Trigger:** Production promotion pipeline has no parity validation step.

**Action:**
- Flag ci-cd-pipeline-automation to add parity check
- Communicate risk of promoting without parity validation
- Recommend manual parity review before next promotion until automated check is added

---

### When to halt execution:

* Missing configuration key in production that exists in staging — guaranteed runtime failure
* Unintentional runtime version difference with known behavioural impact
* Parity check is non-blocking and drift has been ignored repeatedly

---

## Skill Integration & Orchestration

This skill runs as a pipeline gate before production promotion, and reactively when environment-specific failures are reported. It flags deployment-management when drift blocks a pending promotion, and ci-cd-pipeline-automation when the parity check itself needs to be added or improved.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Unintentional drift blocks promotion | deployment-management | Promotion blocked pending remediation |
| Parity check absent from pipeline | ci-cd-pipeline-automation | Pipeline stage needs adding |

---

## Related Skills

**Skills this skill depends on:**
* **infrastructure-as-code** — Provisions the environment infrastructure whose configuration this skill validates.

**Skills this skill cooperates with:**
* **deployment-management** — Parity check is a precondition for deployment promotion.
* **ci-cd-pipeline-automation** — Parity validation should be a stage in the pipeline this skill manages.

---

## Governance Hooks

* [ ] Block promotion on any unintentional drift
* [ ] Document all intentional differences via DT-1 before allowing promotion
* [ ] Ensure parity check is a blocking pipeline step
* [ ] Flag deployment-management when drift blocks a pending promotion

---

## Example Use Cases

### Example 1: Missing Config Key Detected Before Production Promotion

**Scenario:** Pre-promotion parity check finds that `PAYMENT_GATEWAY_URL` config key exists in staging but is absent from production manifest.

**Execution steps:**
1. Detect missing key in production manifest.
2. Classify as unintentional drift — configuration key absence causes runtime failure.
3. Block promotion immediately.
4. Flag deployment-management — promotion blocked.
5. Require addition of key to production manifest before proceeding.

**Result:** FAIL — promotion blocked. Prevented a production runtime failure.

---

### Example 2: Intentional Memory Difference Documented

**Scenario:** Staging runs with 512Mi memory limit vs production's 2Gi. This is cost-driven and known.

**Execution steps:**
1. Detect memory limit difference.
2. Check intentional difference documentation — DT-1 entry exists with justification.
3. Classify as intentional — log that staging under-provisioning may mask memory-related production issues.
4. Allow promotion with documented caveat.

**Result:** PASS with documented intentional difference.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Production-only failures caused by undocumented environment differences**
✅ **Correct approach:** Any environment difference that could affect behaviour must be documented. Undocumented differences that cause production failures are preventable with parity enforcement.

❌ **Anti-pattern 2: Parity check present but non-blocking**
✅ **Correct approach:** A non-blocking parity check is a reporting tool, not a quality gate. Drift reported but not blocked will accumulate.

❌ **Anti-pattern 3: Staging significantly under-provisioned with no documentation**
✅ **Correct approach:** Document resource sizing differences via DT-1 and acknowledge that staging may not surface production performance issues. Make this risk explicit, not hidden.

❌ **Anti-pattern 4: Manual parity checks before each release**
✅ **Correct approach:** Automate parity validation as a blocking pipeline step. Manual checks are error-prone and will be skipped under time pressure.

❌ **Anti-pattern 5: Feature flag differences between staging and production without documentation**
✅ **Correct approach:** Feature flag differences make staging an unreliable representation of production. Document and justify any intentional differences; eliminate unintentional ones.

---

## Non-Goals

* ❌ Provisioning environment infrastructure — handled by Infrastructure as Code
* ❌ Executing deployments — handled by Deployment Management
* ❌ Designing pipeline stages — handled by CI/CD Pipeline Automation
* ❌ Application-level bug diagnosis — handled by Bug Diagnosis

---
