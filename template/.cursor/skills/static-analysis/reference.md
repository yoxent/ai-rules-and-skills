```yaml
---
name: static-analysis
description: Uses static analysis tools to detect code defects, security vulnerabilities, and quality violations without executing the code.
version: 1.1.0
category: Language & Platform Skills
tags: [static-analysis, code-quality, defects, security, ci-gate]
priority: Medium

depends_on: []
flags_skills: [security, bug-diagnosis, build-systems]

inputs: [source-code, quality-rule-sets, security-rule-sets]
outputs: [analysis-report, severity-ranked-findings, remediation-recommendations]

rules_applied:
  - TQ-1  # Test Coverage Requirement — static analysis complements but does not replace test coverage
  - DD-1  # CI/CD Enforcement — critical violations must block pipeline progression
  - CL-3  # Data Privacy — flag code patterns that risk exposing sensitive data
  - DT-1  # Explicit Tradeoff Logging — document any suppressed warnings with justification

documents_needed: [static-analysis-tool-docs, security-rule-sets, project-quality-standards]
execution_context: Activated on code commit, PR creation, or as a mandatory CI quality gate step.
---
```

# Skill: Static Analysis

---

## Purpose

**What this skill does:**
Runs automated static analysis tools against source code to detect defects, security vulnerabilities, code smells, and quality policy violations — before the code is executed. Integrates findings into the pipeline as blocking gates for critical issues.

Static analysis catches entire categories of bugs that tests miss: null pointer paths never exercised in tests, SQL injection vectors, unused sensitive data exposure. Catching these pre-merge is dramatically cheaper than post-deployment.

Provides a systematic, repeatable quality baseline that scales without reviewer bandwidth. Frees code reviewers to focus on design and logic rather than mechanical error patterns.

---

## When to Use This Skill

### Triggers:
* Setting up a new project's quality pipeline
* Adding or modifying static analysis rules
* Diagnosing a static analysis failure in CI
* Reviewing suppression patterns for legitimacy
* Security or compliance audit requiring code-level evidence

### Do NOT use this skill for:
* Runtime performance analysis — delegate to `runtime-analysis`
* Linting and formatting style checks — delegate to `linting-and-formatting`
* Security configuration beyond code-level findings — delegate to `security`

---

## Inputs

**Required inputs:**
* **Source code** — code to analyze
* **Quality and security rule sets** — which rules apply
* **CI/CD context** — where analysis gates run

---

## Outputs

**Primary outputs:**
* **Analysis report** — severity-ranked findings with location and category
* **Remediation recommendations** — fix guidance per finding
* **Suppression audit** — findings suppressed without documented justification

**Skill flags:**
* Flag **security** for security-category findings
* Flag **bug-diagnosis** for defect-category findings indicating logic bugs
* Flag **build-systems** when static analysis is absent from the CI pipeline

---

## Preconditions

* Static analysis tool configured and version-controlled
* [ ] Rule sets reviewed and tuned (false-positive rate acceptable)
* [ ] CI integration in place

---

## Step-by-Step Execution Procedure

### Step 1: Run Analysis

**Actions:**
- [ ] Execute static analysis against full codebase (or changed files if incremental is configured)
- [ ] Capture all findings with severity, category, location

---

### Step 2: Classify and Triage Findings

**Actions:**
- [ ] Classify by severity: CRITICAL / HIGH / MEDIUM / LOW
- [ ] Classify by category: security / defect / code-smell / style
- [ ] Flag security-category findings to `security`
- [ ] Flag defect-category findings to `bug-diagnosis`

---

### Step 3: Audit Suppressions

**Actions:**
- [ ] Identify all suppression annotations in the codebase
- [ ] Verify each has documented justification
- [ ] Block any suppression of CRITICAL/HIGH findings without DT-2 confirmation

---

### Step 4: Validate CI Gate Integration

**Actions:**
- [ ] Confirm CRITICAL and HIGH findings block pipeline progression
- [ ] Verify analysis runs on every CI execution (not only scheduled)

---

### Final Step: Generate Report

```markdown
## Static Analysis Report

**Tool:** [e.g. SonarQube, Pylint+Bandit, ESLint Security Plugin]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Findings Summary
| Severity | Count | Blocking |
|----------|-------|---------|
| CRITICAL | N | Yes |
| HIGH     | N | Yes |
| MEDIUM   | N | Advisory |
| LOW      | N | Advisory |

### Top Findings
[Finding: location: category: recommended fix]

### Suppression Audit
[Suppressed without justification: N findings]

### CI Gate Status
[CRITICAL/HIGH blocking: Y/N]

### Skills Flagged
- **security**: [security-category findings]
- **bug-diagnosis**: [defect-category findings]
```

---

## Core Responsibilities

1. Run analysis and classify findings by severity and category
2. Ensure CRITICAL and HIGH findings block pipeline (DD-1)
3. Flag security findings to `security`, defect findings to `bug-diagnosis`
4. Audit suppressions for justification
5. Integrate analysis into CI as a non-optional gate

---

## Constraints (Rules Applied)

* **TQ-1** — Static analysis supplements tests; it does not replace coverage
* **DD-1** — Critical violations must block pipeline; not advisory for CRITICAL/HIGH
* **CL-3** — Data exposure patterns must be flagged immediately
* **DT-1** — Every suppressed finding requires logged justification

---

## Tradeoff Handling

### Tradeoff 1: Analysis Depth vs. Pipeline Speed

```
Conflict: Deep analysis catches more issues but slows CI significantly
→ Apply full analysis to CRITICAL/HIGH rule sets always
→ Apply medium/low rules on schedule or PR only
→ Log via DT-1 if any CRITICAL rule set is reduced for speed
```

### Tradeoff 2: False Positive Rate vs. Developer Trust

```
Conflict: Poorly tuned rules generate noise; developers disable analysis
→ Require tuning before enforcement
→ Track false-positive rate; recalibrate if >15% of findings are FP
```

---

## Failure & Escalation Behavior

### Security Finding

**Trigger:** Finding classified as security category

**Action:** Flag `security` immediately; block pipeline until security skill has reviewed

### Defect Finding

**Trigger:** Finding classified as logic-defect category

**Action:** Flag `bug-diagnosis`; continue pipeline unless CRITICAL severity

---

### Analysis Not Integrated in CI

**Trigger:** Static analysis is absent from the CI pipeline or not enforced as a required gate

**Action:** Flag build-systems. Pipeline must include static analysis as a non-optional quality gate.

---

## Anti-Patterns to Catch

❌ **Static analysis configured as advisory only**
✅ CRITICAL/HIGH must block; configure as required status check

❌ **`@SuppressWarnings` / `# noqa` without explanation**
✅ Require inline comment; audit suppressions in each release

❌ **Analysis only runs on changed files when full scan is needed**
✅ Run full-codebase scan for security rules; incremental only for style/smell

❌ **Rules not tuned — 40% false positive rate**
✅ Tune rule sets before enforcing; track FP rate

❌ **Security findings deferred to a later sprint**
✅ Security findings are blockers; no deferral without DT-2 and risk acceptance

---

## Non-Goals

* ❌ Runtime defects requiring execution — handled by `runtime-analysis`
* ❌ Style and formatting — handled by `linting-and-formatting`
* ❌ Security configuration — handled by `security`

---
