---

```yaml
---
name: regression_test_suite_management
description: Maintains, curates, and optimizes the regression test suite to keep it trustworthy, fast, and aligned with current system behavior as the codebase evolves.
version: 1.0.0
category: Testing & QA
tags: [regression-testing, suite-health, flakiness, test-curation, ci-optimization]
priority: High

depends_on: []
flags_skills: [test-interpretation-failure-diagnosis, ci-cd-pipeline-automation]

inputs: [existing-regression-suite, recent-code-changes, execution-history, flakiness-data, coverage-reports]
outputs: [curated-regression-suite, removal-recommendations, optimization-strategy, suite-health-report]

rules_applied:
  - TQ-3  # Regression Prevention — the suite is the primary mechanism; its health is critical
  - TQ-4  # Test Quality Rule — bloated/stale suites create false confidence; curation is as important as creation
  - MF-4  # Root Cause Analysis — recurring regressions must trigger root cause analysis, not just re-runs
  - MF-2  # Technical Debt Tracking — test debt (flaky, slow, obsolete tests) must be tracked in the debt register

documents_needed: [test-execution-history, flakiness-register, coverage-reports, business-criticality-map]

execution_context: Invoked after major refactors, on accumulated flakiness or slow suite alerts, before capacity planning, or as a periodic maintenance activity to keep suite health current.

---
```

---

# Skill: Regression Test Suite Management

---

## Purpose

**What this skill does:**
Audits, curates, and optimizes the regression test suite to ensure it remains a trustworthy, fast, and accurate signal of system health as the codebase evolves. It removes obsolete, redundant, and flaky tests; adds regression coverage for newly discovered edge cases and bug fixes; optimizes execution through prioritization and parallelization; and tracks test debt as a first-class engineering concern.

A bloated or stale regression suite is worse than no suite — it slows delivery, erodes engineer trust through false failures, and hides real regressions behind noise. A curated, healthy suite is a genuine safety net: fast enough to run on every change, reliable enough to trust, and comprehensive enough to catch what matters.

Test curation pays compound interest. Every obsolete test removed reduces CI time and noise. Every flaky test resolved restores trust in the suite. Every well-targeted regression test for a fixed bug prevents the same defect from recurring silently. A well-maintained regression suite is the single most important factor in sustainable delivery velocity.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A major refactor has invalidated or made obsolete a significant portion of existing tests
* The CI pipeline is too slow — the regression suite is the primary bottleneck
* Flaky tests are accumulating faster than they are being remediated
* Coverage gaps appear in recently changed areas — the suite has not kept pace with code changes
* A recurring bug suggests a missing regression test for a previously fixed defect
* Periodic maintenance is due — the suite has not been audited in more than one release cycle

### Do NOT use this skill for:

* Creating new E2E tests for new features — use `e2e-test-creation`
* Diagnosing why a specific test is currently failing — use `test-interpretation-failure-diagnosis`
* Reporting on test results across runs — use `test-reporting-observability`
* Configuring CI pipeline parallelization beyond suite-level optimization — use `ci-cd-pipeline-automation`

**Execution Context Details:**
This skill performs maintenance on the regression suite as a whole. It flags `test-interpretation-failure-diagnosis` for recurring failures that require root cause analysis, and `ci-cd-pipeline-automation` when suite-level speed optimizations require pipeline restructuring. Business-critical test removals always require prompt engineer confirmation before execution.

---

## Inputs

**Required inputs:**

* **Existing regression test suite** — The current set of tests, including test names, tier, execution time, and last pass/fail status.
* **Test execution history** — Historical pass/fail data across multiple runs: required for flakiness analysis and trend detection.
* **Flakiness data** — Known flaky tests from the flaky test register (produced by `test-reporting-observability`), with frequency and impact.

**Optional inputs:**

* **Recent code changes** — Commit history and changed modules, used to identify tests covering removed features and gaps in coverage for changed areas.
* **Coverage reports** — Module-level coverage data, used to find coverage gaps introduced by code changes.
* **Business criticality map** — Mapping of workflows to business priority, used to calibrate which coverage gaps are urgent vs deferrable.

---

## Outputs

**Primary outputs:**

* **Curated regression suite** — The updated suite after removals, additions, and reorganization.
* **Removal recommendations** — Tests recommended for removal, with justification: obsolete (feature removed), redundant (coverage duplicated at a lower tier), or misaligned (tests implementation not behavior).
* **Execution optimization strategy** — Recommendations for parallelization, tier splitting (fast/full), and test impact analysis integration.
* **Suite health report** — Current state: total tests, coverage, average execution time, flakiness index, and trend vs prior audit.

**Output format:**

* Removal recommendations as a table with justification, risk assessment, and confirmation status (prompt engineer confirmation required for business-critical removals).
* Optimization strategy as a prioritized list of changes with estimated time savings per change.
* Suite health report as a structured summary comparable across audit cycles.

**Skill flags (if applicable):**

* Flag **test-interpretation-failure-diagnosis** when recurring failures suggest a root cause that is not addressed by suite curation alone.
* Flag **ci-cd-pipeline-automation** when suite optimization requires pipeline restructuring (tier splitting, parallelization configuration) beyond suite-level changes.

---

## Preconditions

**Conditions that must be met before execution:**

* Test execution history must be available (minimum 10 runs) for flakiness analysis.
* Business criticality map must be available before any removal decisions on potentially critical paths.
* A flakiness register must exist (or be created as part of this audit) before removals are made.

**Validation checks:**

* [ ] Execution history available for minimum 10 prior runs
* [ ] Flakiness register current (updated within last 5 runs)
* [ ] Business criticality map available for assessing removal risk
* [ ] Prompt engineer availability confirmed for business-critical removal decisions

---

## Step-by-Step Execution Procedure

### Step 1: Audit for Obsolete and Redundant Tests

**Questions to answer:**
- Which tests cover features or code paths that no longer exist?
- Which tests duplicate coverage already provided at a lower, faster tier?
- Which tests are testing implementation details rather than observable behavior?

**Actions:**
- [ ] Cross-reference test coverage with current codebase — identify tests covering removed or renamed modules
- [ ] Identify tests duplicating coverage already present at unit or integration tier (E2E tests for unit-level concerns)
- [ ] Identify tests asserting internal implementation details rather than user-observable outcomes
- [ ] Produce removal candidate list with justification per test

**Red flags / Warning signs:**
- Tests referencing classes, methods, or endpoints that no longer exist — clearly obsolete
- E2E tests asserting internal state (database field values, internal method calls) — wrong tier
- Multiple tests asserting identical behavior with different names — redundant

**Decision points:**
- Removal of any test covering a business-critical workflow requires prompt engineer confirmation — do not remove unilaterally
- Tests covering recently changed areas should be reviewed for staleness, not automatically removed

---

### Step 2: Assess and Triage Flaky Tests

**Questions to answer:**
- Which tests are failing non-deterministically, and at what frequency?
- Are flaky tests blocking releases or only creating noise?
- What is the root cause pattern — environment, data, timing, or test design?

**Actions:**
- [ ] Review flakiness register for accumulated flaky tests and their frequency
- [ ] Classify impact: blocking (causes release blocks) vs non-blocking (noise only)
- [ ] Identify flakiness root cause pattern where determinable from execution history
- [ ] For high-frequency blocking flaky tests: flag `test-interpretation-failure-diagnosis` for root cause analysis
- [ ] Log all identified test debt (flaky tests) in the technical debt register via MF-2

**Red flags / Warning signs:**
- Flaky test frequency increasing across recent runs — the problem is worsening, not stable
- Blocking flaky tests in business-critical E2E workflows — release risk
- No root cause pattern identifiable from execution history alone — deeper diagnosis required

**Decision points:**
- High-frequency blocking flaky tests must be flagged to `test-interpretation-failure-diagnosis` — do not accept as "known" without a remediation path
- Non-blocking flaky tests: register and track; remediate on priority based on frequency trend

---

### Step 3: Add Regression Coverage for Bug Fixes and Edge Cases

**Questions to answer:**
- For each recently fixed bug: does a regression test now exist that would have caught it?
- Are there recently discovered edge cases that are not covered by the current suite?
- Are there coverage gaps in recently changed areas (areas of the codebase with high churn)?

**Actions:**
- [ ] Review recent bug fix commits — verify each has a corresponding regression test; add if missing
- [ ] Review recently changed modules for coverage gaps introduced by the changes
- [ ] Identify edge cases discovered in production (incidents, support tickets) not yet covered
- [ ] Coordinate with `e2e-test-creation` if the gap is at the workflow level

**Red flags / Warning signs:**
- A bug that recurred suggests the original fix had no regression test
- High-churn modules with declining coverage — changes are outpacing test maintenance
- Production incidents revealing untested edge cases — suite is not protecting against real-world failures

**Decision points:**
- If a coverage gap is in a business-critical workflow at the E2E level, flag for `e2e-test-creation` rather than attempting to fill it with lower-tier tests

---

### Step 4: Optimize Suite Execution

**Questions to answer:**
- What is the total suite execution time, and what is the target?
- Which tests are the slowest, and is their execution time justified by their coverage value?
- Can the suite be split into a fast tier (per-PR) and a full tier (pre-release or nightly)?

**Actions:**
- [ ] Profile suite execution time by test and tier
- [ ] Identify the slowest tests and assess whether their execution time is justified
- [ ] Propose tier split: fast tier (< 10 minutes, highest-value tests) and full tier (complete suite, pre-release)
- [ ] Identify parallelization opportunities — tests with no shared state can run concurrently
- [ ] If parallelization requires pipeline changes, flag `ci-cd-pipeline-automation`

**Red flags / Warning signs:**
- Single test taking >2 minutes — likely testing at the wrong tier or with inefficient setup
- Suite execution time >45 minutes on main CI path — engineers will begin to bypass
- No tier split strategy — full suite runs on every PR regardless of change scope

**Decision points:**
- If proposed tier split requires pipeline configuration changes beyond this skill's scope, flag `ci-cd-pipeline-automation`
- Removing a slow test to improve speed requires a coverage impact assessment first — speed is not a valid reason to remove coverage without a replacement

---

### Step 5: Track and Report Test Debt

**Questions to answer:**
- Is all identified test debt (flaky, slow, obsolete tests) registered in the technical debt register?
- Are debt items time-boxed with remediation owners?
- Is the suite health improving or declining across audit cycles?

**Actions:**
- [ ] Register all identified test debt items in the technical debt register via MF-2
- [ ] Assign priority and remediation owner per debt item
- [ ] Compare suite health metrics to prior audit: flakiness index, execution time, coverage, test count
- [ ] Surface trend: is the suite getting healthier or accumulating more debt between audits?

---

### Final Step: Generate Suite Health Report

```markdown
## Regression Suite Health Report

**Date:** [YYYY-MM-DD]
**Trigger:** [Post-refactor / Periodic / Flakiness alert / Performance]
**Status:** ✅ HEALTHY / ⚠️ NEEDS ATTENTION / ❌ CRITICAL

### Suite Metrics

| Metric | Current | Prior Audit | Trend |
|---|---|---|---|
| Total tests | N | N | ↑/↓/→ |
| Execution time | Xm | Xm | ↑/↓/→ |
| Pass rate (last 10 runs) | X% | X% | ↑/↓/→ |
| Flakiness index | X% | X% | ↑/↓/→ |
| Coverage | X% | X% | ↑/↓/→ |

### Removal Candidates

| Test | Reason | Business Risk | Confirmation Required |
|---|---|---|---|
| [test name] | Covers removed feature | Low | No |
| [test name] | Covers critical checkout flow | High | ✅ Yes — prompt engineer |

### Flaky Test Triage

| Test | Frequency | Impact | Action |
|---|---|---|---|
| [test name] | 4/10 | Blocking | flag:test-interpretation-failure-diagnosis |
| [test name] | 1/10 | Non-blocking | Registered; monitor |

### Optimization Recommendations

| Action | Estimated Saving | Complexity | Priority |
|---|---|---|---|
| Fast/full tier split | -15min on PR runs | Medium | High |
| Parallelize E2E suite | -8min | Low | High |

### Test Debt Register (New Items)
[New items logged to technical debt register this cycle]

### Skills Flagged
- **[Skill]**: [Reason]

### Overall Assessment
- ✅ HEALTHY: Flakiness index <5%, execution time within budget, coverage stable, debt register current
- ⚠️ NEEDS ATTENTION: Flakiness accumulating, or execution time drifting above budget
- ❌ CRITICAL: Blocking flaky tests, coverage regression in critical paths, or suite failing to run

### Required Actions
- [ ] [Action 1 — with owner]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Remove obsolete, redundant, and implementation-testing tests — with impact assessment and confirmation for critical-path removals
2. Triage flaky tests by frequency and impact; escalate blocking flakiness to `test-interpretation-failure-diagnosis`
3. Add regression coverage for every fixed bug and newly discovered edge case
4. Optimize execution time through tier splitting, parallelization, and removal of disproportionately slow tests
5. Track all test debt in the technical debt register; measure suite health trend across audit cycles

**Quality criteria:**

* No test is removed covering a business-critical workflow without prompt engineer confirmation
* Flaky test register is current; all blocking flaky tests have an active remediation path
* Every fixed bug has a corresponding regression test preventing silent recurrence
* Suite execution time is within the defined budget for the CI tier

---

## Constraints (Rules Applied)

* **TQ-3: Regression Prevention** — Suite health directly determines regression protection quality. A slow, flaky, or obsolete-filled suite provides progressively less protection — it is the testing equivalent of technical debt.
* **TQ-4: Test Quality Rule** — Curation is as important as creation. A bloated suite creates false confidence and masks real failures. Quality of the suite matters, not just size.
* **MF-4: Root Cause Analysis** — Recurring regressions require root cause analysis: why did the test not exist or fail to catch the defect? Just adding a test without understanding the pattern means it will repeat.
* **MF-2: Technical Debt Tracking** — All test debt (flaky, slow, obsolete, missing coverage) must be tracked in the technical debt register with owners and timelines.

---

## Tradeoff Handling

### Tradeoff 1: Suite Completeness vs Execution Speed

Larger suites provide more coverage but slow CI feedback loops. Pruning must be deliberate.

**Resolution:** Profile by test — assess coverage value vs execution cost; apply tier split (fast per-PR, full pre-release); do not remove for speed without coverage impact assessment; flag `ci-cd-pipeline-automation` if parallelization is needed; log via DT-1.

### Tradeoff 2: Aggressive Curation vs Regression Risk

Removing tests reduces noise and improves speed but may remove coverage.

**Resolution:** Require coverage impact assessment (what is lost, what alternative exists); require prompt engineer confirmation for critical workflow removals; log decision via DT-1. If risk is uncertain, mark as candidate without removing — re-assess next cycle.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Blocking Flaky Tests in Critical Workflows

**Trigger:** A flaky test in a business-critical E2E workflow is causing release blocks or significant CI noise at high frequency.

**Action:**
- Flag `test-interpretation-failure-diagnosis` with: test name, frequency data, last 5 failure patterns
- Do not remove the flaky test — removing it removes coverage; remediate instead
- Log in technical debt register as P1 if blocking releases

---

### Escalation Scenario 2: Recurring Regression Without Root Cause

**Trigger:** The same defect has appeared in multiple releases, indicating a regression test that does not exist or is not catching the issue.

**Action:**
- Flag `test-interpretation-failure-diagnosis` for root cause analysis per MF-4
- Do not close the incident by just re-adding a regression test without understanding why it was absent or failed
- Log recurring regression in technical debt register

---

### Escalation Scenario 3: Suite Optimization Requires Pipeline Changes

**Trigger:** The recommended optimization (tier splitting, parallelization) requires CI pipeline restructuring.

**Action:**
- Define the suite-level requirements (what tests go in which tier, concurrency model)
- Flag `ci-cd-pipeline-automation` with the defined requirements
- Do not attempt pipeline restructuring within this skill — that is `ci-cd-pipeline-automation` scope

---

### When to halt execution:

* Business-critical test removal is proposed and business criticality map is unavailable — do not remove without knowing the risk
* Prompt engineer is unavailable to confirm critical-path removal — defer, do not proceed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

A maintenance skill run periodically or on specific triggers (post-refactor, accumulated flakiness, CI speed alert). It depends on `test-reporting-observability` for flakiness register input and flags `test-interpretation-failure-diagnosis` for recurring failures and `ci-cd-pipeline-automation` for pipeline-level optimization.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Blocking flaky tests need root cause | test-interpretation-failure-diagnosis | Registration alone insufficient; root cause needed |
| Recurring regression pattern | test-interpretation-failure-diagnosis | MF-4 requires root cause analysis |
| Tier split needs pipeline changes | ci-cd-pipeline-automation | Pipeline restructuring out of scope here |

---

## Related Skills

**Skills this skill depends on:**

* **test-reporting-observability** — Provides the flakiness register and trend data this skill consumes. Audit quality depends on the quality of observability data.

**Skills this skill cooperates with:**

* **e2e-test-creation** — When gaps at the workflow level are identified, this skill flags `e2e-test-creation` to fill them; it does not create E2E tests itself.
* **test-reporting-observability** — Consumes flakiness register; health report feeds back into observability trend tracking.

**Skills this skill may invoke/flag:**

* **test-interpretation-failure-diagnosis** — For blocking flaky tests and recurring regression root cause.
* **ci-cd-pipeline-automation** — When suite optimization requires pipeline-level changes.

---

## Governance Hooks

* [ ] Require prompt engineer confirmation before removing any test covering a business-critical workflow
* [ ] Register all identified test debt in technical debt register via MF-2
* [ ] Flag recurring regressions to `test-interpretation-failure-diagnosis` per MF-4 — do not just re-add a test
* [ ] Log all removal decisions, tier split decisions, and tradeoffs via DT-1
* [ ] Never remove a flaky test without a coverage impact assessment — removing coverage is not remediation
* [ ] Measure suite health trend at each audit — point-in-time metrics are insufficient

**Audit trail requirements:**

* Per-audit suite health snapshot: flakiness index, execution time, coverage, test count
* Removal decision log: test, reason, coverage impact, confirmation status
* Test debt register entries: item, priority, owner, remediation timeline
* Recurring regression log: defect, root cause, regression test added

---

## Example Use Cases

### Example 1: Post-Refactor Suite Audit

**Scenario:** A major refactor renamed 40% of the service layer. CI is now showing 300 test failures, but most appear to be for removed or renamed classes, not genuine regressions.

**Execution steps:**
1. Cross-reference failing tests with removed/renamed modules — 287 are obsolete (covering renamed code)
2. Identify 13 genuine regressions in the refactored payment calculation path
3. Propose removal of 287 obsolete tests; flag 2 that touched checkout logic for prompt engineer confirmation
4. Flag `test-interpretation-failure-diagnosis` for the 13 genuine regressions
5. Document: 287 removals, 13 genuine regressions, 2 confirmations pending

**Result:** ⚠️ NEEDS ATTENTION — 287 obsolete removals proposed; 13 regressions surfaced
**Skills flagged:** `test-interpretation-failure-diagnosis` (genuine regressions)

---

### Example 2: Flakiness-Triggered Audit

**Scenario:** The flakiness index has risen from 3% to 12% over 8 runs. The flaky register shows 15 new tests added in the last month.

**Execution steps:**
1. Triage 15 flaky tests: 4 blocking (E2E checkout and login), 11 non-blocking
2. Flag `test-interpretation-failure-diagnosis` for the 4 blocking flaky tests
3. Register all 15 as test debt (MF-2); assign priority
4. Profile suite speed: the 4 blocking flaky tests add 12 minutes of retry overhead — suite time has grown from 28min to 40min

**Result:** ❌ CRITICAL — 4 blocking flaky tests; escalated for root cause
**Skills flagged:** `test-interpretation-failure-diagnosis` (4 blocking flaky tests)

---

### Example 3: Implementing Test Impact Analysis

**Scenario:** A monorepo PR CI run takes 45 minutes because the full regression suite runs regardless of which modules are changed.

**Execution steps:**
1. Profile suite: 800 tests, 45 minutes; most tests unrelated to changed modules on any given PR
2. Propose test impact analysis: run only tests covering changed modules on PR; full suite on merge to main
3. Estimated saving: 45min → 8min average per PR
4. Flag `ci-cd-pipeline-automation` for pipeline configuration of impact analysis tooling

**Result:** ✅ Optimization proposed; `ci-cd-pipeline-automation` flagged for implementation

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Removing tests for speed without coverage impact assessment**
Removing slow tests is not optimization if it removes coverage of real-world behavior.
✅ Every removal requires: what coverage is lost, what alternative coverage exists, confirmation if critical-path.

❌ **Anti-pattern 2: Treating flaky tests as background noise**
"That test is always flaky" is not an acceptable steady state. Flakiness accumulates until it causes a crisis.
✅ Every flaky test is registered, tracked, and has a remediation path — especially blocking ones.

❌ **Anti-pattern 3: Removing flaky tests instead of remediating them**
Removing a flaky test removes coverage. The underlying cause is still there — it will surface as a real failure.
✅ Diagnose and remediate flaky tests. Remove only when the coverage is confirmed duplicated at a lower tier.

❌ **Anti-pattern 4: Adding regression tests without root cause analysis for recurring defects**
"Just add a test for this bug" without understanding why the test didn't exist or didn't catch it means the pattern will repeat.
✅ Per MF-4: root cause analysis is required for recurring regressions, not just a new test.

❌ **Anti-pattern 5: No tier split — full suite on every PR**
Engineers will disable or bypass a 45-minute suite. Speed is a feature of regression suites.
✅ Split: fast tier (<10min, highest value) per-PR; full tier pre-release or nightly.

❌ **Anti-pattern 6: Suite health assessed only at crisis point**
Auditing the regression suite only when it's broken means the audit is reactive, not preventive.
✅ Periodic audits (at least once per release cycle) keep suite health from silently degrading.

❌ **Anti-pattern 7: Test debt not tracked**
"We know there are flaky tests" without a register means no ownership, no priority, no remediation.
✅ All test debt (flaky, slow, obsolete, missing coverage) must be in the technical debt register with owners and timelines.

❌ **Anti-pattern 8: Assuming a passing suite means good coverage**
A suite can be 100% green and still have zero coverage of the checkout workflow if those tests were removed.
✅ Track coverage alongside pass rate — a passing but uncovering suite is a false safety signal.

---

## Non-Goals

* ❌ **Creating new E2E tests for new features** — handled by `e2e-test-creation`
* ❌ **Diagnosing specific test failures** — handled by `test-interpretation-failure-diagnosis`
* ❌ **Reporting on test results across runs** — handled by `test-reporting-observability`
* ❌ **Configuring CI pipeline parallelization** — handled by `ci-cd-pipeline-automation`

**Boundary clarifications:**

* This skill manages the regression suite as a whole. It does not diagnose individual test failures — it flags them to `test-interpretation-failure-diagnosis`.
* Suite-level optimization is in scope; pipeline-level configuration of that optimization is `ci-cd-pipeline-automation`.
* This skill identifies coverage gaps; it does not create E2E tests to fill them — that is `e2e-test-creation`.

---

## Notes for LLM Implementation

1. **Removal requires coverage impact assessment, always.** Never remove a test for speed, cleanliness, or convenience without knowing what coverage is lost and what replaces it.
2. **Flaky tests are test debt, not background noise.** Register them, track frequency, and escalate blocking ones. Removing flaky tests removes coverage — that is not remediation.
3. **Root cause analysis is required for recurring regressions.** Per MF-4, adding a test without understanding why the defect recurred is insufficient — the pattern will repeat.
4. **Suite health trend matters more than point-in-time metrics.** A suite with 5% flakiness that was 2% last cycle is getting worse. Trend is the signal; snapshot is context.
5. **Never confirm a business-critical removal unilaterally.** Always require prompt engineer confirmation before removing any test covering a workflow that directly affects users.

6. Present suite health as a metrics table with trend vs prior audit; removal candidates as a table with justification, risk, and confirmation status; flaky test triage as a table with frequency, impact, and action.
7. Be conservative about removals — defer when in doubt; be firm about blocking flakiness; always compare to prior state, not just current snapshot.

---
