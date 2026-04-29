```yaml
---
name: linting-and-formatting
description: Applies automated style checks and code formatting to enforce consistent, readable code standards without manual enforcement.
version: 1.0.0
category: Language & Platform Skills
tags: [linting, formatting, code-style, automation, ci-enforcement]
priority: Medium

depends_on: []
flags_skills: [build-systems]

inputs: [source-code, style-guide, ci-cd-requirements]
outputs: [linting-report, auto-formatted-code, pipeline-config]

rules_applied:
  - DA-1  # SOLID & Clean Code First — linting enforces structural and readability principles
  - DD-1  # CI/CD Enforcement — linting failures must block pipeline progression
  - MF-1  # Feature Consistency — linting rule changes must be applied uniformly

documents_needed: [project-style-guide, linting-tool-docs, ci-pipeline-config]
execution_context: Activated on code commit, PR creation, or when linting rules are being added or changed.
---
```

# Skill: Linting & Formatting

---

## Purpose

**What this skill does:**
Configures, runs, and enforces automated code style and structural checks. Ensures every engineer produces code that meets the project's style standards — not through review overhead, but through automated pipeline gates.

Consistent code style reduces cognitive load during code review. Reviewers spend time on logic, not formatting. Style-inconsistent codebases are harder to search, harder to read, and more error-prone.

Linting catches an entire class of issues automatically: unreachable code, unused variables, dangerous patterns, naming violations. Formatting automation eliminates style debates entirely.

---

## When to Use This Skill

### Triggers:
* Setting up linting and formatting for a new project
* Adding or modifying linting rules
* Diagnosing linting failures or suppression patterns
* CI pipeline review for code quality gates
* Onboarding a new developer who needs tooling setup

### Do NOT use this skill for:
* Deeper code defect detection — delegate to `static-analysis`
* Build pipeline design — delegate to `build-systems`
* Security-specific static checks — delegate to `security`

---

## Inputs

**Required inputs:**
* **Source code** — code to lint and format
* **Style guide** — team conventions to enforce
* **CI/CD requirements** — where checks run

---

## Outputs

**Primary outputs:**
* **Linting report** — violations with severity and location
* **Auto-formatted code** — formatted output
* **Pipeline integration configuration** — pre-commit and CI config

**Skill flags:**
* Flag **build-systems** when pipeline integration for linting is missing or broken

---

## Preconditions

* Style guide or conventions documented
* [ ] Linting tools selected for language stack
* [ ] CI pipeline available for integration

---

## Step-by-Step Execution Procedure

### Step 1: Configure Tools

**Actions:**
- [ ] Select appropriate linter and formatter for the language
- [ ] Configure rules to match style guide
- [ ] Commit configuration to source control

---

### Step 2: Integrate into Pipeline

**Actions:**
- [ ] Add linting step to CI pipeline as a quality gate (DD-1)
- [ ] Configure pre-commit hooks to mirror CI checks
- [ ] Verify configuration is identical in both contexts

---

### Step 3: Run and Triage Violations

**Actions:**
- [ ] Run linting against full codebase
- [ ] Classify violations by severity
- [ ] Identify suppressed violations without justification

**Decision points:**
- Suppressed without justification: block, require inline justification
- New rule with no migration plan for existing files: request migration plan, log DT-1

---

### Step 4: Validate Uniform Application

**Actions:**
- [ ] Confirm new rules apply to all files, not just new ones
- [ ] If existing violations are too numerous, require a migration plan with deadline

---

### Final Step: Generate Report

```markdown
## Linting & Formatting Report

**Linter/Formatter:** [Tool + version]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Violations Summary
[Severity breakdown and top violation categories]

### Suppression Audit
[Unjustified suppressions found]

### CI Integration
[Pre-commit + CI gate: configured/missing]

### Skills Flagged
- **build-systems**: [if CI integration is missing or broken]
```

---

## Core Responsibilities

1. Configure linting and formatting tools aligned to style guide
2. Integrate checks into pre-commit hooks and CI pipeline
3. Ensure violations block pipeline progression
4. Audit suppressions for justification
5. Ensure new rules are applied uniformly with migration plan if needed

---

## Constraints (Rules Applied)

* **DA-1** — Linting enforces structural principles automatically
* **DD-1** — Linting failures must block pipeline; manual bypass is a violation
* **MF-1** — Rule changes must not alter behavior selectively; uniform application required

---

## Tradeoff Handling

### Tradeoff 1: Strict Rules vs. Developer Productivity

```
Conflict: Highly strict rules slow development; too lenient rules provide no value
→ Calibrate to rules that catch real issues (not just aesthetics)
→ Log via DT-1 when rules are relaxed for productivity reasons
```

---

## Anti-Patterns to Catch

❌ **Linting disabled entirely for legacy files**
✅ Apply at minimum a baseline rule set; create migration plan for full compliance

❌ **Pre-commit hooks not matching CI checks**
✅ Use shared config referenced by both

❌ **`eslint-disable` / `# noqa` without explanation**
✅ Require inline comment explaining why suppression is justified

❌ **Formatter producing different output locally vs CI**
✅ Pin formatter to exact version; share config file

❌ **New linting rules added mid-sprint creating noise for unrelated PRs**
✅ Stage new rules with a migration sprint or batch-fix PR

---

## Non-Goals

* ❌ Deep code defect detection — handled by `static-analysis`
* ❌ Security checks — handled by `security`
* ❌ Build pipeline design — handled by `build-systems`

---

## Metadata Summary

```yaml
name: linting-and-formatting
category: Language & Platform Skills
priority: Medium
depends_on: []
flags_skills: [build-systems]
rules_applied: [DA-1, DD-1, MF-1]
documents_needed: [project-style-guide, linting-tool-docs, ci-pipeline-config]
tags: [linting, formatting, code-style, automation, ci-enforcement]
```
