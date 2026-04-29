---

```yaml
---
name: test_reporting_observability
description: Captures, structures, and communicates test results across all tiers to provide actionable visibility into quality trends, coverage gaps, and flakiness patterns.
version: 1.0.0
category: Testing & QA
tags: [test-reporting, observability, flakiness, coverage, quality-trends]
priority: High

depends_on: []
flags_skills: [test-interpretation-failure-diagnosis, monitoring-alerts]

inputs: [test-execution-logs, coverage-reports, historical-run-data, flakiness-records, ci-pipeline-metadata]
outputs: [per-run-reports, trend-dashboards, flaky-test-register, release-quality-snapshots]

rules_applied:
  - TQ-1  # Test Coverage Requirement — reporting must surface gaps, not just pass/fail totals
  - TQ-2  # Test Failure Diagnosis — reports must distinguish real failures from flakiness and env issues
  - PS-2  # Risk Communication — quality regressions must be surfaced to stakeholders in business terms
  - DT-1  # Explicit Tradeoff Logging — coverage threshold relaxations must be logged

documents_needed: [ci-pipeline-config, coverage-threshold-policy, stakeholder-communication-plan]

execution_context: Invoked after test suite execution to aggregate and publish results; also triggered on trend degradation, release gating, or when stakeholders need quality visibility.

---
```

---

# Skill: Test Reporting & Observability

---

## Purpose

**What this skill does:**
Aggregates test results across all test tiers (unit, integration, E2E, load, stress), structures them into per-run and trend reports, identifies flaky tests and coverage gaps, and surfaces quality regressions to stakeholders in business terms. It transforms raw test output into actionable signals — distinguishing real failures from noise, and tracking quality trends over time rather than just snapshots.

Invisible quality regressions are the most dangerous kind. A test suite that runs but whose results are never meaningfully reviewed provides false assurance. This skill ensures quality signals reach the people who need them, in terms they can act on — before regressions reach users. It also provides the evidence base for release decisions.

Aggregated trend data reveals patterns that per-run results hide: a test that fails 10% of the time is invisible in any single run but obvious in trend data. Flakiness registers prevent flaky tests from being ignored until they cause release blocks. Coverage gap reports prevent critical paths from going dark silently after refactors.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A test suite has completed execution and results need to be structured and published
* A release decision requires a quality snapshot with stakeholder-ready communication
* Test pass rates or coverage metrics are trending downward across runs
* Flaky tests are accumulating without being tracked or prioritized
* Coverage gaps in business-critical paths need to be surfaced
* Stakeholders require visibility into quality health in non-technical terms

### Do NOT use this skill for:

* Diagnosing why a specific test is failing — use `test-interpretation-failure-diagnosis`
* Fixing flaky tests — identify and register them here; remediation is elsewhere
* Configuring CI/CD pipeline stages — use `ci-cd-pipeline-automation`
* Defining coverage thresholds — that is a policy decision; this skill enforces and reports against them

**Execution Context Details:**
This skill runs after test suite execution and before release decisions. It flags `test-interpretation-failure-diagnosis` when specific failures require root cause analysis beyond what aggregated reports can provide. It flags `monitoring-alerts` when test metrics should flow into production observability dashboards. Coverage threshold policy decisions are escalated to the prompt engineer — not resolved by this skill.

---

## Inputs

**Required inputs:**

* **Test execution logs** — Raw results from all test tiers: pass/fail per test, execution time, error messages, and stack traces for failures.
* **Code coverage reports** — Line, branch, and path coverage data mapped to the codebase, ideally with historical comparison.
* **Historical test run data** — Prior run results enabling trend analysis: pass rate over time, execution time trends, flakiness frequency per test.

**Optional inputs:**

* **Flakiness records** — Prior classifications of known flaky tests, used to distinguish new flakiness from existing registered flakiness.
* **CI/CD pipeline metadata** — Branch, commit, author, and deployment context, used to correlate quality changes with code changes.
* **Stakeholder communication plan** — Defines who needs what information and at what threshold — used to calibrate report granularity and escalation triggers.

**Documents/Context needed:**

* **Coverage threshold policy** — Defined minimum coverage percentages per tier (overall, per module, per business-critical path). Required to assess gap severity.
* **CI pipeline config** — Required to integrate report publishing as a pipeline step.

---

## Outputs

**Primary outputs:**

* **Per-run test report** — Structured result for each CI run: total tests, pass rate, coverage delta, new failures, flaky test occurrences, and release recommendation.
* **Trend report** — Pass rate, execution time, coverage percentage, and flakiness index over the last N runs. Surfaces degradation patterns invisible in single-run snapshots.
* **Flaky test register** — Running registry of tests with flakiness history: frequency, last occurrence, impact (blocking or non-blocking), and prioritization.
* **Release quality snapshot** — Stakeholder-facing summary for release decisions: business-critical path coverage, unresolved failures, risk assessment in non-technical language.

**Output format:**

* Per-run reports as CI pipeline artifacts (HTML, JUnit XML, or equivalent) surfaced in the pipeline dashboard.
* Trend reports as dashboards (Grafana, Datadog, or equivalent) updated per run.
* Flaky test register as a maintained document or tracking system entry.
* Release quality snapshot as a structured summary consumable by non-engineering stakeholders.

**Skill flags (if applicable):**

* Flag **test-interpretation-failure-diagnosis** when specific test failures require root cause analysis — not just aggregation.
* Flag **monitoring-alerts** when test metrics (latency distributions, error rate trends from load tests) should be wired into production observability alert thresholds.

---

## Preconditions

**Conditions that must be met before execution:**

* Test execution must be complete — reporting against partial results produces misleading quality signals.
* Historical baseline must exist for trend comparison — at least 5 prior runs for meaningful trend analysis.
* Coverage threshold policy must be defined — gaps cannot be assessed without thresholds.

**Validation checks:**

* [ ] All test suite results are complete and available
* [ ] Coverage thresholds are defined and current
* [ ] Historical run data is accessible for trend comparison
* [ ] Stakeholder communication thresholds are defined (what triggers escalation)

---

## Step-by-Step Execution Procedure

### Step 1: Aggregate Results Across All Tiers

**Questions to answer:**
- Are results available from all test tiers (unit, integration, E2E, load, stress)?
- Are there any tiers that did not run — and is that expected or a pipeline gap?
- What is the overall pass rate and coverage for this run vs the prior run?

**Actions:**
- [ ] Collect results from all tiers available in the pipeline
- [ ] Note any missing tier results and classify: expected skip vs unintended gap
- [ ] Compute: total tests, pass rate, coverage percentage, execution time
- [ ] Compute delta vs prior run: pass rate change, coverage change, execution time change

**Red flags / Warning signs:**
- A test tier did not run and it is not marked as intentional skip — pipeline gap, not data to ignore
- Pass rate dropped more than 5% from prior run — regression requiring investigation
- Coverage dropped more than the defined threshold — gap requiring surfacing

**Decision points:**
- If a tier's absence is a pipeline gap (not intended), surface as a required action — do not publish a report that silently omits a tier
- If coverage drops below threshold, surface immediately — do not bury in report appendix

---

### Step 2: Classify Failures — Real vs Flaky vs Environment

**Questions to answer:**
- Are new failures consistent across runs, or do they vary (flakiness indicator)?
- Are failures correlated with a specific code change, or are they isolated to infrastructure?
- Are known flaky tests in the registry causing this run's failures?

**Actions:**
- [ ] Cross-reference failures against the flaky test register — separate known-flaky from new failures
- [ ] For new failures: check if they are consistent across multiple runs or appear randomly (flakiness)
- [ ] For environment-correlated failures: flag to `test-environment-management` context; do not classify as code failures
- [ ] Classify each new failure: genuine regression / new flakiness / environment-induced / infrastructure issue

**Red flags / Warning signs:**
- A "new failure" that matches the pattern of a previously registered flaky test — likely the same underlying issue
- All failures in the same test tier but not others — suggests environment or infrastructure, not code
- Failures only on specific CI agents or specific times of day — flakiness signal

**Decision points:**
- New flakiness must be added to the flaky test register with frequency and impact classification immediately — not deferred
- Environment-correlated failures should not count as code quality regressions in the report

---

### Step 3: Surface Coverage Gaps

**Questions to answer:**
- Which business-critical paths have coverage below threshold?
- Have any previously-covered paths gone dark — coverage dropped to zero after a refactor?
- Is coverage trending downward across runs even if still above current threshold?

**Actions:**
- [ ] Map coverage report to business-critical paths — not just overall percentage
- [ ] Identify paths with coverage below defined thresholds
- [ ] Identify paths with zero coverage that previously had coverage — coverage regression
- [ ] Surface trend: is coverage declining gradually even if still above threshold?

**Red flags / Warning signs:**
- A business-critical path (checkout, login, payment) has zero coverage — highest priority gap
- Overall coverage is above threshold but a specific critical module is below — aggregate metrics hide path-level gaps
- Coverage has declined in 3+ consecutive runs — trajectory matters, not just current snapshot

**Decision points:**
- Coverage gaps in business-critical paths must be surfaced prominently — not buried in a coverage percentage table
- If a threshold relaxation is proposed, require DT-1 logging and prompt engineer confirmation

---

### Step 4: Update Flaky Test Register

**Questions to answer:**
- Are flaky tests accumulating without being addressed?
- Are any flaky tests now blocking releases or causing false failure noise?
- What is the trend for each registered flaky test — improving, stable, or worsening?

**Actions:**
- [ ] Add newly identified flaky tests to the register with: test name, tier, frequency, first occurrence, impact (blocking/non-blocking)
- [ ] Update frequency for existing registered flaky tests based on this run's data
- [ ] Flag flaky tests whose frequency has crossed the "blocking" threshold for prioritized remediation
- [ ] Surface flaky tests that have been in the register for more than N runs without resolution

**Red flags / Warning signs:**
- Flaky test register growing rapidly — accumulation without remediation erodes suite trust
- A flaky test that was non-blocking is now failing on every other run — impact has escalated
- High-frequency flaky tests in business-critical E2E workflows — direct trust impact

**Decision points:**
- Flaky tests in critical workflows that exceed frequency threshold must be flagged to `test-interpretation-failure-diagnosis` for root cause analysis — registration alone is insufficient
- Flaky tests that are blocking releases must be treated as failures until remediated or explicitly accepted via DT-1

---

### Step 5: Generate Stakeholder-Facing Release Quality Snapshot

**Questions to answer:**
- What is the risk profile for the proposed release — in business language?
- Are there any unresolved failures or coverage gaps that should block the release?
- What do stakeholders need to know to make an informed release decision?

**Actions:**
- [ ] Summarise: test pass rates, critical path coverage, unresolved failures, active flaky tests in critical workflows
- [ ] Express quality risk in business terms: "The checkout workflow has no automated test coverage" — not "branch coverage is 0% for OrderService"
- [ ] Issue a release recommendation: PASS, FAIL, or NEEDS REVIEW with explicit rationale
- [ ] For FAIL or NEEDS REVIEW: list specific required actions before release can proceed

---

### Final Step: Publish Reports

**Report/Output structure:**

```markdown
## Test Run Report

**Run:** [CI run ID / commit / branch]
**Date:** [YYYY-MM-DD]
**Tiers Executed:** [Unit ✅ | Integration ✅ | E2E ✅ | Load ⚠️ skipped | Stress ✅]
**Release Recommendation:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Results Summary

| Tier | Tests | Pass Rate | vs Prior | Coverage | vs Prior |
|---|---|---|---|---|---|
| Unit | N | X% | ±X% | X% | ±X% |
| E2E | N | X% | ±X% | X% | ±X% |

### New Failures
| Test | Tier | Classification | Action Required |
|---|---|---|---|
| [test name] | E2E | Genuine regression | Investigate before release |
| [test name] | Unit | New flakiness | Added to register |

### Coverage Gaps (Business-Critical Paths)
| Path | Coverage | Threshold | Status |
|---|---|---|---|
| Checkout workflow | 0% | 80% | ❌ CRITICAL GAP |

### Flaky Test Register (Updated)
| Test | Tier | Frequency | Impact | In Register Since |
|---|---|---|---|---|
| [test name] | E2E | 3/10 runs | Non-blocking | [date] |

### Skills Flagged
- **[Skill]**: [Reason]

### Release Quality Snapshot (Stakeholder Summary)
[2-3 sentence plain-language summary of quality status and release risk]

**Release Recommendation:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Required Actions Before Release
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Aggregate results across all test tiers — surface missing tiers as gaps, not silences
2. Classify failures: genuine regression, new flakiness, environment-induced, or infrastructure — never aggregate them as undifferentiated failures
3. Surface coverage gaps against defined thresholds, especially on business-critical paths
4. Maintain the flaky test register — new flakiness is logged immediately; accumulating flakiness is escalated
5. Generate stakeholder-facing quality snapshots in business language for release decisions

**Quality criteria:**

* Reports distinguish failure types — pass/fail totals with no classification are insufficient
* Coverage gaps in critical paths are surfaced prominently, not buried in aggregate percentages
* Flaky test register is updated every run — not only when flakiness causes a failure
* Stakeholder snapshots use business language — no raw coverage percentages without business context

---

## Constraints (Rules Applied)

* **TQ-1: Test Coverage Requirement** — Reporting must surface coverage gaps, not just pass/fail totals. Coverage must be path-level, not aggregate — 100% pass rate with 0% checkout coverage is false assurance.
* **TQ-2: Test Failure Diagnosis** — Reports must distinguish genuine regressions from flakiness and environment issues; aggregating them into a single count conflates signals requiring different responses.
* **PS-2: Risk Communication** — Quality regressions must be surfaced to stakeholders in business terms. "The checkout workflow has no test coverage" is actionable; "branch coverage is 43%" is not.
* **DT-1: Explicit Tradeoff Logging** — Coverage threshold relaxations must be logged with rationale; silent relaxation is invisible technical debt accumulation.

---

## Tradeoff Handling

### Tradeoff 1: Report Granularity vs Signal-to-Noise

Exhaustive reporting creates noise engineers stop reading.

**Resolution:** Calibrate to meaningful thresholds — surface failures, flakiness above N%, coverage below threshold; focus per-run reports on delta from prior run; reserve drill-down for flagged issues; log calibration via DT-1.

### Tradeoff 2: Real-Time Reporting vs Pipeline Throughput

Real-time streaming adds overhead; batch reporting delays feedback.

**Resolution:** Default to batch at pipeline stage completion; use real-time only for long-running suites (load, stress) where early visibility has high value; log strategy via DT-1.

### Tradeoff 3: Coverage Threshold Enforcement vs Delivery Pressure

Teams under pressure may request threshold relaxation.

**Resolution:** Surface the gap explicitly — do not silently accept; require DT-1 logging (gap scope, risk, remediation timeline); require prompt engineer approval before relaxation takes effect.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Critical Path Coverage Gap

**Trigger:** A business-critical workflow has coverage below threshold — or zero coverage.

**Action:**
- Surface prominently in the report as a FAIL condition — not a warning
- Translate to business impact: which user workflow is unprotected
- Block release recommendation unless explicitly overridden via DT-1 + prompt engineer confirmation

---

### Escalation Scenario 2: Flakiness Accumulation Without Remediation

**Trigger:** Flaky test register has tests that have been registered for more than N runs without resolution, or a flaky test's frequency has crossed the blocking threshold.

**Action:**
- Flag `test-interpretation-failure-diagnosis` for root cause analysis on high-frequency flaky tests
- Surface in release quality snapshot as an active risk
- Do not accept high-frequency flakiness as "known and tolerated" without DT-1 logging

---

### Escalation Scenario 3: Quality Regression Post-Release

**Trigger:** Test metrics (pass rate, coverage) degrade significantly after a recent deployment.

**Action:**
- Flag `test-interpretation-failure-diagnosis` with the specific regression context and correlated deployment
- Surface to stakeholders immediately — post-release regressions have user impact
- Provide release rollback recommendation if coverage drop is in a critical path

---

### When to halt execution:

* Test results are incomplete (a tier did not run for unknown reasons) — do not publish a release recommendation against partial results; surface the gap first

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs at the end of the test pipeline, after all test tiers have executed. It is the aggregation and communication layer — it does not run tests or diagnose failures, but it ensures results are visible, actionable, and reach the right audience. It flags `test-interpretation-failure-diagnosis` for specific failures and `monitoring-alerts` for metrics that should flow to production observability.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Specific failure needs root cause | test-interpretation-failure-diagnosis | Aggregated report cannot diagnose; individual analysis needed |
| Load/stress metrics → prod alerts | monitoring-alerts | Test threshold data should become production alert baselines |

---

## Related Skills

**Skills this skill depends on:**

* None — it consumes outputs of other test skills but has no hard execution dependency.

**Skills this skill cooperates with:**

* **e2e-test-creation, load-test-creation, stress-test-creation, test-creation-strategy** — Produce the test results this skill aggregates and reports on.
* **ci-cd-pipeline-automation** — Report publishing is integrated as a pipeline step by this skill in coordination with pipeline automation.

**Skills this skill may invoke/flag:**

* **test-interpretation-failure-diagnosis** — For specific failures requiring root cause analysis.
* **monitoring-alerts** — When test metrics should feed production observability.

---

## Governance Hooks

* [ ] Surface coverage gaps in critical paths prominently — never bury in aggregate metrics
* [ ] Classify all failures before reporting — never aggregate genuine regressions with flakiness
* [ ] Update flaky test register every run — not only when flakiness causes a visible failure
* [ ] Require DT-1 logging and prompt engineer approval for coverage threshold relaxation
* [ ] Express stakeholder snapshots in business language — not raw engineering metrics
* [ ] Log all reporting threshold and granularity decisions via DT-1

**Audit trail requirements:**

* Per-run report archived as CI artifact
* Flaky test register versioned — frequency and impact updated each run
* Coverage threshold relaxation decisions: logged with rationale, approver, and remediation timeline
* Stakeholder snapshot distribution log: who received what, when

---

## Example Use Cases

### Example 1: Pre-Release Quality Snapshot

**Scenario:** A release candidate is ready. Engineering and product leadership need a quality assessment before approving deployment.

**Inputs provided:**
- Unit: 1,200 tests, 99.1% pass, coverage 87%
- E2E: 45 tests, 97.8% pass, coverage 72% (threshold: 80%)
- Load: passed SLO at peak
- Flaky register: 3 tests, all non-blocking

**Execution steps:**
1. Aggregate: all tiers ran; no missing tier gaps
2. Classify failures: 1 E2E failure = genuine regression (confirmed consistent across 3 runs); flaky register unchanged
3. Surface coverage gap: E2E 72% < 80% threshold — identify which paths are uncovered (search workflow: 0%)
4. Generate snapshot: "The search workflow has no E2E coverage. One genuine regression in the user profile update flow. Recommend: FAIL — resolve regression and close search workflow coverage gap before release."

**Result:** ❌ FAIL — 1 genuine regression + critical path coverage gap
**Skills flagged:** `test-interpretation-failure-diagnosis` (profile update regression)

---

### Example 2: Flakiness Accumulation Detected

**Scenario:** Over the past 10 CI runs, the same E2E test for the notification service has failed 4 times with different error messages. It is not in the flaky register.

**Execution steps:**
1. Detect pattern in historical data: same test, 4/10 runs, varied errors — flakiness signature
2. Add to flaky test register: notification-service-e2e-delivery-confirmation, frequency 40%, impact non-blocking
3. Surface in trend report as accumulating flakiness; flag `test-interpretation-failure-diagnosis` for root cause

**Result:** ⚠️ NEEDS REVIEW — flakiness registered; root cause analysis flagged

---

### Example 3: Coverage Threshold Relaxation Request

**Scenario:** Under delivery pressure, team requests releasing with E2E coverage at 71% (threshold: 80%) with a commitment to close the gap in the next sprint.

**Execution steps:**
1. Surface gap explicitly in report: checkout workflow sub-path uncovered at 0%
2. Require DT-1 logging: gap scope, business risk, remediation timeline, approver
3. Require prompt engineer confirmation before issuing PASS recommendation
4. Log relaxation in audit trail with time-boxed remediation commitment

**Result:** ⚠️ NEEDS REVIEW — threshold relaxation logged and approved; remediation time-boxed

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Reporting pass/fail totals only**
"1,200 tests passed, 3 failed" tells engineers nothing about what failed, why, or what risk it represents.
✅ Classify every failure: genuine regression, flakiness, environment-induced, infrastructure.

❌ **Anti-pattern 2: Aggregate coverage hiding path-level gaps**
"Overall coverage is 85%" while checkout has zero coverage is a false safety signal.
✅ Always report coverage at the business-critical path level — not just aggregate.

❌ **Anti-pattern 3: Flaky tests tracked informally or not at all**
"Everyone knows that test is flaky" — until it blocks a release and nobody has data on it.
✅ Register every flaky test the first time it is identified; update frequency every run.

❌ **Anti-pattern 4: Stakeholder reports in engineering metrics**
"Branch coverage dropped from 87% to 83%" is not actionable to a product manager.
✅ Translate to business impact: "The order history page now has no automated test coverage."

❌ **Anti-pattern 5: Publishing reports against incomplete test runs**
A report with E2E results missing because the pipeline stage silently failed is misleading — it shows higher confidence than warranted.
✅ Surface missing tier results as gaps — never publish a release recommendation against partial data.

❌ **Anti-pattern 6: Coverage threshold silently relaxed**
A CI config change bumps the minimum coverage down from 80% to 70% without documentation — test debt accumulates invisibly.
✅ Require DT-1 logging and explicit approval for any threshold change.

❌ **Anti-pattern 7: Treating flakiness as acceptable background noise**
Flaky tests erode trust in the suite; over time engineers stop taking failures seriously.
✅ Every flaky test is a registered issue with frequency tracking and a remediation path.

❌ **Anti-pattern 8: No trend reporting — only per-run snapshots**
A test that fails 1 in 20 runs is invisible in any single run but obvious in trend data.
✅ Maintain trend data across at least the last 10 runs for meaningful pattern detection.

---

## Non-Goals

* ❌ **Diagnosing why a specific test is failing** — handled by `test-interpretation-failure-diagnosis`
* ❌ **Fixing flaky tests** — identify and register here; remediation is handled by other skills
* ❌ **Configuring CI/CD pipeline stages** — handled by `ci-cd-pipeline-automation`
* ❌ **Defining coverage thresholds** — a policy decision; this skill enforces and reports against them

**Boundary clarifications:**

* This skill aggregates, classifies, and communicates. It does not diagnose individual failures — that is `test-interpretation-failure-diagnosis`.
* Threshold policy is input, not output — this skill enforces thresholds, it does not set them.
* Flaky test registration is in scope; flaky test remediation is not — remediation follows from `test-interpretation-failure-diagnosis`.

---

## Notes for LLM Implementation

1. **Classify failures before aggregating.** Genuine regressions and flaky tests require completely different responses. Mixing them into a "failures" count is misleading and produces bad decisions.
2. **Path-level coverage is what matters.** Aggregate coverage percentages are vanity metrics. Coverage on the checkout workflow is what determines whether users are protected.
3. **Translate to business language for stakeholders.** Every coverage gap and every regression should be expressible as a sentence a product manager can act on.
4. **Update the flaky test register every run.** Flakiness that is not tracked is flakiness that accumulates until it causes a crisis.
5. **Never publish against incomplete results.** A missing tier is a gap, not an absence of data to worry about.

6. Results summary as a table (pass rates, coverage, deltas); coverage gaps as a named-path table; flaky register as a maintained table with frequency and impact; stakeholder snapshot as 2-3 sentences in plain language.
7. Be precise about failure classification — never hedge; be direct about gaps; be business-oriented in stakeholder communication.

---
