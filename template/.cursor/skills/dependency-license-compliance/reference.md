```yaml
---
name: dependency-license-compliance
description: Audits third-party dependency licenses to identify obligations, incompatibilities, and risks before they reach production or create legal liability.
version: 1.0.0
category: DevOps
tags: [licensing, compliance, dependencies, legal, open-source]
priority: Medium

depends_on: []
flags_skills: [ci-cd-pipeline-automation]

inputs: [dependency-manifests, license-policy, product-distribution-model]
outputs: [license-audit-report, approved-dependency-list, violation-remediation-plan]

rules_applied:
  - CL-1
  - CL-2
  - DD-1
  - DT-1

execution_context: Runs as a pipeline gate on dependency changes and periodically as a full audit; prerequisite for production deployment of any software with third-party dependencies.

---
```

---

# Skill: Dependency License Compliance

---

## Purpose

**What this skill does:**
Audits all third-party dependencies for their license types, identifies obligations (attribution, source disclosure, copyleft propagation), and flags incompatibilities with the product's distribution model. It ensures problematic licenses are caught before they reach production and create legal liability.

Prevents costly license compliance failures that can result in legal action, forced open-sourcing of proprietary code, or product withdrawal. Provides an auditable record of license review for due diligence (M&A, investor review, compliance certification). Reduces legal review burden by catching issues early in the development cycle.

Automates license auditing that would otherwise require manual legal review of every dependency. Integrates into CI/CD pipelines to catch new problematic dependencies at the point of introduction. Maintains a continuously updated approved dependency list that speeds future reviews.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new dependency is being added to any project
* A periodic full license audit is being conducted
* A dependency is being upgraded to a new major version (license may have changed)
* A compliance audit requires license documentation
* A project is preparing for M&A due diligence
* A copyleft or unknown license has been flagged in an automated scan
* The product distribution model is changing (e.g. from internal to commercial distribution)

### Do NOT use this skill for:

* Assessing technical suitability of dependencies — handled by Dependency Suitability & Selection
* Managing security vulnerabilities in dependencies — handled by Build & Packaging Automation (security scanning) and CI/CD Pipeline Automation
* Legal advice — this skill identifies risks and escalates; legal counsel provides advice

---

## Inputs

**Required inputs:**

* **Dependency manifests and lock files** — `package-lock.json`, `requirements.txt`, `pom.xml`, `go.sum`, etc. The complete, locked dependency tree including transitive dependencies.
* **License policy** — The organisation's approved license list, prohibited license list, and escalation policy for unlisted licenses.
* **Product distribution model** — How the software is distributed: internal use only, SaaS (not distributed), commercial distribution (shipped to customers), or open-source. Determines which license obligations apply.

**Optional inputs:**

* **Prior audit report** — To identify changes since last audit.
* **Legal counsel guidance** — For handling edge cases or ambiguous licenses.

---

## Outputs

**Primary outputs:**

* **License audit report** — Complete list of dependencies with their identified license, obligation classification, and compliance status.
* **Approved dependency list** — Current list of dependencies confirmed as compliant for the distribution model.
* **Violation remediation plan** — For each problematic dependency: the specific issue, risk level, and recommended remediation (replace, remove, isolate, or escalate).

---

## Preconditions

**Conditions that must be met before execution:**

* Complete dependency lock files are available (not just top-level manifests — transitive dependencies must be included)
* License policy is documented and available
* Distribution model is confirmed

**Validation checks:**

* [ ] Lock files include transitive dependency tree
* [ ] License policy is available and current
* [ ] Distribution model is confirmed
* [ ] License scanning is configured as a blocking pipeline step (or being added)

---

## License Classification Reference

This classification guides risk assessment during audits:

**Category A — Permissive (generally safe for all distribution models):**
- MIT, BSD (2-clause, 3-clause), Apache 2.0, ISC, Unlicense
- Obligations: attribution in documentation; Apache 2.0 requires NOTICE file preservation

**Category B — Weak Copyleft (safe for most use cases; review required for embedded/distributed use):**
- LGPL 2.1/3.0, MPL 2.0, EPL 2.0, CDDL
- Obligations: modifications to the licensed component must be released; linking is generally permitted without copyleft propagation
- Risk: may propagate to encompassing work in some distribution models

**Category C — Strong Copyleft (requires review; may be incompatible with proprietary distribution):**
- GPL 2.0, GPL 3.0, AGPL 3.0
- Obligations: GPL requires source disclosure if distributing; AGPL extends this to SaaS (network use triggers copyleft)
- Risk: AGPL is particularly high risk for SaaS products using the dependency

**Category D — Prohibited / Requires Legal Review:**
- Commercial licenses restricting use, SSPL, BUSL (Business Source License), proprietary with redistribution restrictions
- Unlicensed code (no license = all rights reserved by default)
- Unknown or unresolvable license

---

## Step-by-Step Execution Procedure

### Step 1: Extract and Classify All Dependency Licenses

**Questions to answer:**
- What are all direct and transitive dependencies?
- What license does each dependency use?
- Are any licenses unknown or unresolvable?

**Actions:**
- [ ] Extract full dependency tree including transitive dependencies
- [ ] Resolve license for each dependency (from package metadata, LICENSE file, or repository)
- [ ] Classify each license into Category A, B, C, or D
- [ ] Flag any dependency with unknown or unresolvable license as Category D

**Red flags / Warning signs:**
- Transitive dependency with GPL/AGPL license not visible in direct dependency audit
- Dependency with no LICENSE file and no license in package metadata
- License changed between versions (check on major version upgrades)

**Decision points:**
- Any Category D dependency requires escalation before proceeding.
- Unknown licenses must be treated as Category D (all rights reserved) until resolved.

---

### Step 2: Assess Obligations Against Distribution Model

**Questions to answer:**
- Which license obligations apply given the product's distribution model?
- Are any copyleft licenses present that could propagate to proprietary code?
- Are attribution obligations documented and being met?

**Actions:**
- [ ] For each Category B/C dependency: assess whether distribution model triggers copyleft obligations
- [ ] For AGPL: flag immediately if product is SaaS — network use triggers source disclosure obligation
- [ ] For GPL: flag if product is distributed to customers — binary distribution triggers source disclosure
- [ ] For all permissive licenses: verify attribution obligations are documented

**Red flags / Warning signs:**
- AGPL dependency in a SaaS product — strong copyleft triggered by network use
- GPL dependency in a product distributed to customers without source disclosure plan
- Attribution obligations not tracked — missing NOTICE files or attribution documentation

**Decision points:**
- AGPL in SaaS: flag immediately, escalate to legal via CL-2.
- GPL in commercial distribution: flag and escalate to legal via CL-2.
- Attribution not tracked: require remediation — this is a CL-1 obligation.

---

### Step 3: Check Against License Policy

**Questions to answer:**
- Does each dependency's license appear on the approved list?
- Does any dependency's license appear on the prohibited list?
- Are any licenses not on either list, requiring review?

**Actions:**
- [ ] Check each dependency against approved license list — document as compliant
- [ ] Check each dependency against prohibited license list — flag and block
- [ ] For unlisted licenses: flag for review; treat as blocked until cleared
- [ ] Generate violation list with specific dependencies, licenses, and risk classification

**Red flags / Warning signs:**
- Prohibited license in production codebase
- Multiple dependencies with unlisted licenses — policy may need updating
- License policy not updated to include recently common licenses (e.g. EUPL, CERN-OHL)

**Decision points:**
- Prohibited license: block pipeline, require replacement or removal.
- Unlisted license: escalate for policy decision — do not approve without review.

---

### Step 4: Verify License Scanning in CI/CD Pipeline

**Questions to answer:**
- Is automated license scanning configured as a blocking pipeline step?
- Does the scanner detect transitive dependencies, not just direct ones?
- Is the scanner configured against the current license policy?

**Actions:**
- [ ] Verify license scanner is in CI/CD pipeline as a blocking step
- [ ] Confirm scanner resolves full transitive dependency tree
- [ ] Verify scanner is configured with current approved/prohibited lists
- [ ] Flag ci-cd-pipeline-automation if scanner is absent or non-blocking

**Red flags / Warning signs:**
- License scanner present but non-blocking — violations are reported but not prevented
- Scanner only checking direct dependencies — transitive copyleft can propagate undetected
- Scanner using outdated license policy configuration

**Decision points:**
- If scanner is absent or non-blocking, flag ci-cd-pipeline-automation before proceeding.

---

### Step 5: Document and Track Obligations

**Questions to answer:**
- Are all license obligations tracked and being actively met?
- Is the approved dependency list current?
- Are risk acceptance decisions documented?

**Actions:**
- [ ] Update approved dependency list with audit results
- [ ] Document all active license obligations (attribution, NOTICE files, source availability)
- [ ] Record any risk acceptance decisions via DT-1
- [ ] Escalate Category C/D findings to legal via CL-2 where required

---

### Final Step: Generate License Audit Report

```markdown
## Dependency License Compliance Report

**Project:** [Project Name]
**Date:** [YYYY-MM-DD]
**Distribution model:** [Internal / SaaS / Commercial]
**Status:** ✅ COMPLIANT / ❌ VIOLATIONS FOUND / ⚠️ ESCALATION REQUIRED

### Summary
- Total dependencies audited: [N]
- Category A (permissive): [N]
- Category B (weak copyleft): [N]
- Category C (strong copyleft): [N]
- Category D (prohibited/unknown): [N]

### Violations and Required Actions
| Dependency | License | Category | Issue | Action |
|------------|---------|----------|-------|--------|
| example-lib | AGPL-3.0 | C | SaaS distribution — source obligation | Escalate: CL-2 |
| another-dep | Unknown | D | No license found | Replace or resolve |

### Obligations Tracking
| Dependency | License | Obligation | Status |
|------------|---------|-----------|--------|
| react | MIT | Attribution | ✅ Documented |

### Skills Flagged
- **ci-cd-pipeline-automation**: [If scanner needs adding/updating]

### Required Actions
- [ ] Escalate AGPL finding to legal
- [ ] Replace or resolve unknown license dependency
```

---

## Core Responsibilities

1. Extract and classify all direct and transitive dependency licenses before production deployment.
2. Flag any AGPL, GPL, or strong copyleft dependency against the product distribution model.
3. Treat unknown licenses as prohibited until resolved — never assume permissive.
4. Escalate Category C/D findings to legal via CL-2 — do not make legal determinations.
5. Ensure automated license scanning is a blocking pipeline step.

---

## Constraints (Rules Applied)

* **CL-1: Regulatory Compliance** — License obligations (attribution, source disclosure, NOTICE files) must be identified and met; untracked obligations are compliance failures.
* **CL-2: Legal Risk Escalation** — Category C (strong copyleft) and Category D (prohibited/unknown) findings must be escalated to legal counsel; this skill identifies risks, not legal advice.
* **DD-1: CI/CD Enforcement** — License scanning must be a blocking pipeline step; non-blocking scans allow prohibited licenses to reach production.
* **DT-1: Explicit Tradeoff Logging** — License risk acceptance decisions must be logged with explicit justification and legal review reference.

---

## Tradeoff Handling

### Tradeoff 1: Ideal Dependency vs License Compatibility

**Conflict:** The best technical solution may use a dependency with a copyleft or restrictive license incompatible with the distribution model.

**Resolution:** Flag the license incompatibility against the distribution model obligation; escalate to legal via CL-2 — do not make the legal determination; legal decides if risk is acceptable, an alternative is needed, or isolation is possible.

### Tradeoff 2: License Compliance Strictness vs Development Velocity

**Conflict:** Blocking every dependency with an unlisted license slows development; being too permissive creates legal risk.

**Resolution:** Maintain an approved list covering common safe licenses; unlisted licenses enter a review queue — not auto-blocked forever but not auto-approved; risk acceptance for edge cases documented via DT-1 with legal reference.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: AGPL Dependency in SaaS Product

**Trigger:** AGPL-licensed dependency found in a SaaS product's dependency tree.

**Action:**
- Flag immediately — AGPL triggered by network use, not just binary distribution
- Escalate to legal via CL-2
- Block deployment until legal guidance received
- Prepare: either replace the dependency or obtain a commercial license

---

### Escalation Scenario 2: Unknown License Dependency

**Trigger:** Dependency with no detectable license found in transitive dependency tree.

**Action:**
- Treat as all-rights-reserved — assume not permitted
- Block pipeline
- Require either: license resolution (find the actual license), dependency replacement, or explicit legal sign-off

---

### Escalation Scenario 3: License Changed on Dependency Upgrade

**Trigger:** A major version upgrade introduces a license change (e.g. MIT → SSPL or MIT → AGPL).

**Action:**
- Block upgrade
- Flag the license change explicitly
- Escalate to legal if new license is Category C or D
- Assess whether remaining on the old version is viable

---

### When to halt execution:

* AGPL/GPL in commercial distribution — escalate immediately before any other recommendation
* Unknown license — treat as prohibited; block until resolved
* Prohibited license on the organisation's policy list — block pipeline, no exceptions

---

## Skill Integration & Orchestration

This skill runs as a pipeline gate and periodically as a full audit. It flags ci-cd-pipeline-automation when scanning infrastructure needs to be added or improved.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| License scanner absent or non-blocking | ci-cd-pipeline-automation | Add blocking scanner to pipeline |

---

## Related Skills

**Skills this skill depends on:** None — foundational compliance skill.

**Skills this skill cooperates with:**
* **ci-cd-pipeline-automation** — License scanning is a pipeline stage this skill depends on.
* **dependency-suitability-selection** — Technical suitability and license compliance are complementary assessments run together when evaluating new dependencies.

---

## Governance Hooks

* [ ] Block pipeline on any prohibited or unknown license
* [ ] Escalate Category C/D findings to legal via CL-2
* [ ] Never assume an unknown license is permissive
* [ ] Document all license risk acceptance decisions via DT-1
* [ ] Verify license scanning is blocking in CI/CD pipeline

---

## Example Use Cases

### Example 1: New Dependency with AGPL License

**Scenario:** A developer proposes adding `some-library` to a SaaS product. The library is AGPL-3.0 licensed.

**Execution steps:**
1. Classify as Category C (strong copyleft).
2. Assess against distribution model: SaaS — AGPL network use provision applies.
3. Block pipeline immediately.
4. Escalate to legal via CL-2.
5. Present options: replace with permissively licensed alternative, or obtain commercial license from library vendor.

**Result:** BLOCKED — escalated to legal.

---

### Example 2: Transitive GPL Dependency Found in Audit

**Scenario:** Full dependency tree audit finds a transitive dependency (dependency of a dependency) using GPL-2.0 that was not visible in the direct dependency list.

**Execution steps:**
1. Classify as Category C via transitive chain.
2. Identify which direct dependency pulls in the GPL transitive dependency.
3. Assess distribution model: commercial — binary distribution triggers GPL obligations.
4. Block affected builds.
5. Escalate to legal. Recommend: update the direct dependency to a version that no longer uses the GPL transitive dep, or find an alternative.

**Result:** BLOCKED — transitive GPL found, escalated.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Auditing only direct dependencies**
✅ **Correct approach:** Transitive dependencies carry the same license obligations as direct ones. Always resolve the full dependency tree.

❌ **Anti-pattern 2: Treating unknown licenses as permissive**
✅ **Correct approach:** No license means all rights reserved. An unknown license is more restrictive than a known copyleft license until resolved.

❌ **Anti-pattern 3: Making legal determinations about license compatibility**
✅ **Correct approach:** This skill identifies risks and classifications. Actual compatibility determinations for ambiguous cases require legal counsel.

❌ **Anti-pattern 4: Non-blocking license scan in CI/CD**
✅ **Correct approach:** License scanning must be blocking. A scan that reports violations without blocking allows prohibited licenses to reach production.

❌ **Anti-pattern 5: Not checking licenses on major version upgrades**
✅ **Correct approach:** Licenses can and do change between major versions. Always recheck license on major version upgrades.

---

## Non-Goals

* ❌ Technical suitability assessment of dependencies — handled by Dependency Suitability & Selection
* ❌ Security vulnerability scanning — handled by Build & Packaging Automation
* ❌ Providing legal advice — this skill escalates to legal; it does not replace legal counsel

---
