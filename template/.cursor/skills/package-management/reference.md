```yaml
---
name: package-management
description: Manages internal and external packages for consistency, security, license compliance, and reproducible installs across all environments.
version: 1.1.0
category: Language & Platform Skills
tags: [packages, dependencies, lock-files, security, license]
priority: Medium

depends_on: []
flags_skills: [dependency-safety-integration, security, dependency-license-compliance]

inputs: [dependency-list, lock-files, registry-sources, license-requirements]
outputs: [locked-dependency-versions, update-recommendations, dependency-resolution-report]

rules_applied:
  - CL-2  # License Validation — every new package requires license compatibility check
  - MF-3  # Backward Compatibility — upgrades assessed for breaking API changes
  - DD-3  # Infrastructure Validation — configurations must produce consistent installs
  - DT-2  # Confirmation Gate — major version upgrades require explicit approval

documents_needed: [package-manager-docs, project-license, vulnerability-advisory-db]
execution_context: Activated when adding, removing, or updating packages; or when running a periodic dependency audit.
---
```

# Skill: Package Management

---

## Purpose

**What this skill does:**
Manages all package and dependency operations — addition, removal, upgrade, and audit — ensuring the project's dependency graph is consistent, secure, license-compliant, and reproducible across every environment.

Vulnerable or license-incompatible packages are legal and security liabilities. Non-reproducible installs are a leading cause of environment-specific failures that are expensive to diagnose.

Lock files and pinned versions eliminate "works on my machine" for dependency-related failures. License validation prevents open-source compliance risk from entering the codebase silently.

---

## When to Use This Skill

### Triggers:
* Adding a new package dependency
* Upgrading an existing package (any version bump)
* Running a periodic security or license audit
* Resolving version conflicts or dependency resolution failures
* Reviewing lock file for completeness or staleness

### Do NOT use this skill for:
* Architectural dependency coupling concerns — delegate to `dependency-management` (Phase 2)
* Security configuration beyond vulnerability flagging — delegate to `security` (Phase 2)
* Build pipeline design — delegate to `build-systems`

---

## Inputs

**Required inputs:**
* **Dependency list and lock files** — current state of the dependency graph
* **Registry sources** — which registries are used (npm, PyPI, Maven, etc.)
* **License requirements** — project license and compatibility constraints

---

## Outputs

**Primary outputs:**
* **Locked dependency versions** — updated lock file with all changes
* **Update recommendations** — prioritized list with impact assessment
* **Dependency resolution report** — conflict resolutions and vulnerability findings

**Skill flags:**
* Flag **security** when CVEs or known vulnerabilities are detected
* Flag **dependency-safety-integration** when major upgrade requires architectural impact review
* Flag **dependency-license-compliance** when a license incompatibility or missing license check is detected

---

## Preconditions

* Package manager configured and in use
* [ ] Lock files present and committed
* [ ] Project license identified

---

## Step-by-Step Execution Procedure

### Step 1: License Check (for new packages)

**Actions:**
- [ ] Identify package license
- [ ] Assess compatibility with project license
- [ ] Block addition if incompatible; log via CL-2

---

### Step 2: Security Audit

**Actions:**
- [ ] Run package manager audit (`npm audit`, `pip-audit`, `mvn dependency:analyze`)
- [ ] Classify findings by severity
- [ ] Flag HIGH/CRITICAL findings to `security`

---

### Step 3: Assess Upgrade Breaking Changes (for upgrades)

**Actions:**
- [ ] Review package changelog for breaking changes between current and target version
- [ ] Map breaking changes against project usage
- [ ] Require DT-2 for major version bumps

---

### Step 4: Validate Lock File Consistency

**Actions:**
- [ ] Confirm lock file is committed
- [ ] Confirm lock file is up to date after changes
- [ ] Verify install from lock file produces same result on clean environment

---

### Final Step: Generate Report

```markdown
## Package Management Report

**Package Manager:** [npm/pip/Maven/etc.]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### New Package Additions
[Package: license: compatible: Y/N]

### Security Findings
[CVE / severity / affected package / fix available]

### Upgrade Assessment
[Package: current → target: breaking changes: impact]

### Lock File Status
[Present: Y/N | Up to date: Y/N]

### Skills Flagged
- **security**: [if vulnerabilities found]
- **dependency-safety-integration**: [if architectural impact suspected]
```

---

## Core Responsibilities

1. Validate license compatibility for every new package
2. Run security audit and flag vulnerabilities
3. Assess breaking changes before major version upgrades
4. Ensure lock files are present, committed, and current
5. Gate major upgrades behind DT-2

---

## Constraints (Rules Applied)

* **CL-2** — Every new package requires a license compatibility check; incompatible licenses block addition
* **MF-3** — Package upgrades are API contract changes; breaking changes must be assessed
* **DD-3** — Package configurations must produce consistent installs (lock files required)
* **DT-2** — Major version upgrades require explicit stakeholder confirmation

---

## Tradeoff Handling

### Tradeoff 1: Latest Version vs. Stability

```
Conflict: Security patch in major version requires breaking changes to adopt
→ Assess impact of breaking changes
→ Request DT-2 confirmation with impact assessment
→ Log decision via DT-1
→ Fallback: Apply mitigating controls if upgrade is deferred
```

---

## Failure & Escalation Behavior

### Critical Vulnerability Found

**Trigger:** HIGH or CRITICAL CVE in a direct dependency

**Action:** Flag `security` immediately; do not defer to next audit cycle; present remediation options

---

### License Incompatibility Detected

**Trigger:** Package license is incompatible with project license, or no license check was performed before addition

**Action:** Flag dependency-license-compliance. Block package addition until CL-2 assessment is complete.

---

## Anti-Patterns to Catch

❌ **Adding package without license check**
✅ Check license before `npm install` / `pip install`; block copyleft in proprietary projects

❌ **Committing without updated lock file**
✅ Lock file must be updated and committed as part of the same PR as the dependency change

❌ **Using `*` or `latest` as version spec**
✅ Pin to exact or compatible range; let the lock file manage exact resolution

❌ **Upgrading major version without reading changelog**
✅ Read CHANGELOG/MIGRATION guide; map breaking changes to project usage before approving

❌ **Ignoring audit warnings as noise**
✅ Triage every finding; close each explicitly (fix, accept, or mitigate)

---

## Non-Goals

* ❌ Architectural dependency coupling — handled by `dependency-management` (Phase 2)
* ❌ Security configuration beyond vulnerability detection — handled by `security` (Phase 2)

---
