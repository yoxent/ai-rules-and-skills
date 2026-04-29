```yaml
---
name: dependency-suitability-selection
description: Evaluates third-party dependencies for technical suitability, maintenance health, and security posture before adoption, and reviews existing dependencies for continued suitability.
version: 1.1.0
category: DevOps
tags: [dependencies, packages, supply-chain, security, evaluation]
priority: Medium

depends_on: []
flags_skills: [dependency-license-compliance, ci-cd-pipeline-automation, incident-response]

inputs: [dependency-candidates, project-requirements, existing-dependency-inventory]
outputs: [dependency-evaluation-report, adoption-decision, migration-recommendations]

rules_applied:
  - DD-3
  - DA-5
  - DT-1
  - DT-2

documents_needed: [requirements-specification, existing-dependency-manifest, security-policy]

execution_context: Runs when new dependencies are proposed or existing dependencies are reviewed for continued suitability; complements dependency-license-compliance.

---
```

---

# Skill: Dependency Suitability & Selection

---

## Purpose

**What this skill does:**
Evaluates proposed third-party dependencies against technical suitability criteria — maintenance health, community support, security posture, API stability, and fit for the specific use case — before adoption. It also reviews existing dependencies for continued suitability when maintenance health declines or security issues emerge.

Prevents adoption of abandoned or poorly maintained dependencies that become technical debt or security liabilities. Reduces supply chain risk by ensuring dependencies have active maintenance and transparent ownership. Avoids over-dependency on packages that could be replaced by standard library solutions.

Provides a structured evaluation framework that makes dependency adoption a deliberate, documented decision rather than a casual `npm install`. Creates an auditable record of adoption reasoning. Catches supply chain risks (typosquatting, malicious packages, abandoned maintainers) before they enter the codebase.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new dependency is being proposed for adoption
* An existing dependency has become unmaintained or deprecated
* A dependency has a known security vulnerability with no patch available
* A major version upgrade changes the dependency's API or architecture significantly
* A dependency audit is being conducted for a service or project
* Supply chain security review is required

### Do NOT use this skill for:

* License compliance assessment — handled by Dependency License Compliance
* Security vulnerability scanning — handled by Build & Packaging Automation and CI/CD Pipeline Automation
* General code quality review — handled by Clean Code & SOLID skill (Phase 1)

---

## Inputs

**Required inputs:**

* **Dependency candidate details** — Package name, version, repository URL, and the specific use case it is intended to serve.
* **Project requirements** — Technical requirements the dependency must meet (performance, API stability, compatibility).
* **Existing dependency inventory** — To assess overlap with existing dependencies and identify consolidation opportunities.

**Optional inputs:**

* **Comparable alternatives** — Other packages evaluated as alternatives, for comparison.
* **Prior evaluation reports** — If a previous evaluation was done on this or similar packages.

---

## Outputs

**Primary outputs:**

* **Dependency evaluation report** — Assessment of the candidate dependency across all evaluation criteria with overall recommendation.
* **Adoption decision with documented rationale** — ADOPT, ADOPT WITH CONDITIONS, or REJECT — with explicit reasoning logged via DT-1.
* **Migration recommendations** — For reviews of existing dependencies: RETAIN, MIGRATE, or URGENT REPLACE — with timeline and migration path.

---

## Evaluation Criteria

The following criteria are assessed for each dependency:

**1. Maintenance Health**
- When was the last commit? (>12 months with no activity is a warning sign)
- Are issues and PRs being actively responded to?
- Is there a clear maintainer or maintaining organisation?
- Is the project explicitly marked as deprecated or archived?

**2. Community and Adoption**
- Weekly download counts / GitHub stars as a proxy for community health
- Used by well-known projects or organisations (credibility signal)
- Active community (Stack Overflow questions answered, active Discord/forum)

**3. Security Posture**
- Are security vulnerabilities disclosed and patched promptly?
- Is there a security policy (SECURITY.md)?
- Does the package have a history of supply chain incidents?
- Are dependencies of the dependency themselves well-maintained?

**4. API Stability and Quality**
- Does the package follow semantic versioning?
- Is the public API well-documented?
- Is there a clear changelog?
- Does the API match the project's requirements without requiring workarounds?

**5. Scope and Fit**
- Is this the right tool for the specific use case?
- Could this be solved with the standard library or existing dependencies?
- Is the package doing too much (violates single responsibility, creating unnecessary coupling)?

**6. Supply Chain Risk**
- Is the package owned by a known, trustworthy maintainer or organisation?
- Is the package name similar to a well-known package (typosquatting risk)?
- Does the install script execute arbitrary code?
- Are the number of transitive dependencies proportionate to the package's scope?

---

## Step-by-Step Execution Procedure

### Step 1: Necessity Check

**Questions to answer:**
- Is this dependency actually necessary?
- Can the requirement be met by the standard library or existing dependencies?
- Does the benefit justify the addition of a new dependency?

**Actions:**
- [ ] Identify exactly what functionality the dependency provides
- [ ] Check if the standard library covers the requirement
- [ ] Check if an existing dependency already provides the functionality
- [ ] Assess whether the functionality could be implemented simply without a dependency

**Red flags / Warning signs:**
- Dependency being added for a single utility function that could be a 5-line implementation
- Dependency duplicating functionality already provided by an existing package
- Dependency added for convenience without considering long-term maintenance burden

**Decision points:**
- If standard library suffices, recommend against adoption (DA-5).
- If existing dependency covers the case, recommend using it instead.

---

### Step 2: Evaluate Maintenance Health and Community

**Questions to answer:**
- Is this package actively maintained?
- Does it have sufficient community adoption to be viable long-term?
- Is there a credible maintainer or organisation behind it?

**Actions:**
- [ ] Check last commit date, release frequency, and open issue/PR responsiveness
- [ ] Review maintainer profile and organisational backing
- [ ] Check download statistics and usage by known projects
- [ ] Assess whether the package is in active development or maintenance-only mode

**Red flags / Warning signs:**
- No releases in >18 months with open unresolved issues
- Single maintainer with no organisational backing for a critical dependency
- Package explicitly deprecated or archived by maintainer
- Dramatic drop in download counts without explanation

**Decision points:**
- If abandoned (no activity >12 months, unresolved issues): REJECT or flag for URGENT REPLACE.
- If single maintainer with no succession plan: classify as MEDIUM risk, document via DT-1.

---

### Step 3: Assess Security Posture and Supply Chain Risk

**Questions to answer:**
- Does this package have a history of security vulnerabilities?
- Are there any known active vulnerabilities?
- Does the package present supply chain risks?

**Actions:**
- [ ] Check known vulnerability databases (Snyk, OSV, NVD) for the package
- [ ] Review the package's security disclosure history — are vulnerabilities patched promptly?
- [ ] Check for typosquatting risk — is the package name similar to a well-known package?
- [ ] Review install scripts for arbitrary code execution
- [ ] Assess transitive dependency count — packages with hundreds of transitive deps have large attack surface

**Red flags / Warning signs:**
- Known unpatched CVE in current version
- History of slow or no security response
- Package name one character different from a popular package
- Install script executing curl | bash or equivalent
- Excessive transitive dependency count relative to package scope

**Decision points:**
- Known unpatched CVE: REJECT until patched version available.
- Supply chain indicators present: escalate for security review before adoption.

---

### Step 4: Evaluate API Stability and Fit

**Questions to answer:**
- Does the package API meet the project's requirements?
- Is the API stable and well-documented?
- Does adopting this package create tight coupling or workarounds?

**Actions:**
- [ ] Review API documentation for completeness and quality
- [ ] Check changelog for breaking changes frequency and semver adherence
- [ ] Assess API fit for the specific use case — no workarounds required
- [ ] Evaluate whether the package does too much (scope creep risk)

**Red flags / Warning signs:**
- Breaking changes in minor or patch versions (semver non-compliance)
- Sparse or outdated documentation
- Required workarounds to make the package fit the use case
- Package scope far exceeds the specific functionality needed

---

### Step 5: Document Decision and Flag Complementary Skills

**Questions to answer:**
- What is the overall recommendation: ADOPT, ADOPT WITH CONDITIONS, or REJECT?
- Have all evaluation criteria been documented?
- Does the dependency require license compliance review?

**Actions:**
- [ ] Produce adoption decision with explicit reasoning via DT-1
- [ ] For ADOPT WITH CONDITIONS: document the specific conditions and review timeline
- [ ] Flag dependency-license-compliance for license assessment (always required for new adoptions)
- [ ] Flag ci-cd-pipeline-automation if dependency scanning needs updating

---

### Final Step: Generate Dependency Evaluation Report

```markdown
## Dependency Evaluation Report

**Package:** [package-name@version]
**Proposed use:** [specific use case]
**Date:** [YYYY-MM-DD]
**Decision:** ✅ ADOPT / ⚠️ ADOPT WITH CONDITIONS / ❌ REJECT

### Evaluation Summary
| Criterion | Score | Notes |
|-----------|-------|-------|
| Maintenance health | ✅ | Last release 2 months ago, active issues |
| Community adoption | ✅ | 2M weekly downloads |
| Security posture | ⚠️ | 1 patched CVE in past year, prompt fix |
| API stability | ✅ | Semver compliant, well-documented |
| Scope fit | ✅ | Solves exactly the use case |
| Supply chain risk | ✅ | Backed by known org, minimal transitive deps |

### Decision Rationale
[Explicit reasoning — DT-1 logged]

### Conditions (if applicable)
- [Condition 1 if ADOPT WITH CONDITIONS]
- [Review at: date]

### Skills Flagged
- **dependency-license-compliance**: Always required for new adoptions
- **ci-cd-pipeline-automation**: [If scanner needs updating]

### Alternatives Considered
| Package | Reason Not Selected |
|---------|-------------------|
| [alternative] | [reason] |
```

---

## Core Responsibilities

1. Apply the necessity check first — prefer standard library or existing dependencies over new adoption.
2. Reject dependencies with known unpatched CVEs or clear supply chain risk indicators.
3. Flag all new dependency adoptions to dependency-license-compliance.
4. Document all adoption decisions and tradeoffs via DT-1.
5. Require DT-2 for dependencies with known risks being adopted under conditions.

---

## Constraints (Rules Applied)

* **DD-3: Infrastructure Validation** — Dependencies must be evaluated for suitability before adoption; unevaluated dependencies in production are an unvalidated external dependency risk.
* **DA-5: Avoid Overengineering** — New dependencies add maintenance burden, attack surface, and coupling; standard library or simple implementations should be preferred when they suffice.
* **DT-1: Explicit Tradeoff Logging** — Dependency adoption decisions must be documented with explicit reasoning; the reasoning at time of adoption becomes valuable context for future maintenance.
* **DT-2: Confirmation Gate** — Adopting a dependency with known risk (MEDIUM/HIGH classification) requires explicit human approval; risk should be a conscious choice, not an accidental one.

---

## Tradeoff Handling

### Tradeoff 1: Best Tool vs Maintenance Risk

**Conflict:** The most capable package for a use case may be maintained by a single person with no succession plan.

**Resolution:** Assess how critical the dependency is and the migration cost if abandoned; classify as MEDIUM risk if single-maintainer and critical; document via DT-1 and consider vendoring or forking as contingency with a review date.

### Tradeoff 2: Velocity vs Due Diligence

**Conflict:** Evaluation takes time; development velocity favours fast adoption.

**Resolution:** Automate maintenance health checks, CVE checks, and download stats; focus human review on supply chain indicators, API fit, and necessity check; a brief DT-1 entry suffices for low-risk adoptions, deep review for high-risk.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Supply Chain Incident Detected

**Trigger:** A dependency is found to have been compromised (malicious code injected, maintainer account taken over).

**Action:**
- Remove dependency immediately from all builds
- Flag ci-cd-pipeline-automation to block all builds using affected version
- Escalate to incident-response
- Assess exposure — was the compromised version used in production?

---

### Escalation Scenario 2: Critical Dependency Becomes Abandoned

**Trigger:** A production dependency shows no maintenance activity for >12 months and has open security issues.

**Action:**
- Classify as URGENT REPLACE
- Assess migration complexity and timeline
- Document risk via DT-1
- Escalate to engineering lead if migration complexity is high

---

### When to halt execution:

* Known unpatched CVE in candidate — reject immediately
* Active supply chain compromise detected — escalate to incident-response immediately
* Typosquatting risk present — block and investigate before any consideration

---

## Skill Integration & Orchestration

This skill complements Dependency License Compliance — both should be applied when evaluating new dependencies. It flags CI/CD Pipeline Automation when scanning configuration needs updating.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| New dependency adoption | dependency-license-compliance | Always required alongside suitability |
| Scanner config needs updating | ci-cd-pipeline-automation | Update dependency scanning |
| Supply chain compromise | incident-response | Active security incident |

---

## Related Skills

**Skills this skill depends on:** None — foundational evaluation skill.

**Skills this skill cooperates with:**
* **dependency-license-compliance** — Always run together for new dependency adoptions.
* **ci-cd-pipeline-automation** — Dependency scanning is a pipeline stage.
* **build-packaging-automation** — Security vulnerability scanning of dependencies.

---

## Governance Hooks

* [ ] Apply necessity check before evaluating any new dependency
* [ ] Flag dependency-license-compliance for all new adoptions
* [ ] Document all adoption decisions via DT-1
* [ ] Require DT-2 for MEDIUM/HIGH risk adoptions
* [ ] Treat unknown supply chain indicators as blocking until investigated

---

## Example Use Cases

### Example 1: Evaluating a New HTTP Client Library

**Scenario:** A team proposes adding `axios` to a Node.js service for HTTP requests. The standard library `fetch` is available in Node 18+.

**Execution steps:**
1. Necessity check — `fetch` is available in the runtime. Does `axios` provide needed functionality beyond `fetch`?
2. Team confirms they need request interceptors and automatic JSON parsing — `fetch` requires manual implementation.
3. Evaluate axios: 40M weekly downloads, active maintenance, backed by wide community, no current CVEs.
4. Supply chain: no concerns.
5. Decision: ADOPT. Document via DT-1: necessity confirmed, evaluation passed.
6. Flag dependency-license-compliance — MIT license, expected to be straightforward.

**Result:** ADOPT — documented.

---

### Example 2: Abandoned Utility Package Flagged for Replacement

**Scenario:** Routine audit finds `legacy-util@1.2.3` in a production service. Last commit: 3 years ago. 2 open CVEs with no fix. 50k weekly downloads declining.

**Execution steps:**
1. Classify as URGENT REPLACE — abandoned, unpatched CVEs.
2. Assess migration complexity — utility functions used in 12 files.
3. Identify replacement: standard library `crypto` covers 3 of 4 functions; `modern-util` covers the 4th.
4. Document via DT-1 — risk, timeline, migration plan.
5. Flag ci-cd-pipeline-automation — add CVE blocking for this package to pipeline immediately.

**Result:** URGENT REPLACE — migration plan documented.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Adding a dependency for a single small utility function**
✅ **Correct approach:** Apply the necessity check. A 5-line implementation owned by the team is often preferable to a dependency with its own maintenance burden.

❌ **Anti-pattern 2: Adopting a package without checking maintenance health**
✅ **Correct approach:** Check last commit date, open issues, and maintainer responsiveness before adoption. Today's active package is tomorrow's abandoned liability.

❌ **Anti-pattern 3: Ignoring transitive dependency count**
✅ **Correct approach:** A package with 300 transitive dependencies for a simple task has a large attack surface. Transitive count should be proportionate to scope.

❌ **Anti-pattern 4: Not re-evaluating existing dependencies after security incidents**
✅ **Correct approach:** Supply chain incidents require immediate re-evaluation of affected dependencies. Passive monitoring is insufficient.

❌ **Anti-pattern 5: Treating download counts as a quality signal**
✅ **Correct approach:** High download counts indicate adoption, not quality or security. Evaluate maintenance health and security posture directly.

---

## Non-Goals

* ❌ License compliance assessment — handled by Dependency License Compliance
* ❌ Security vulnerability scanning in builds — handled by Build & Packaging Automation
* ❌ Code quality review of the dependency's source — out of scope for pre-adoption evaluation

---
