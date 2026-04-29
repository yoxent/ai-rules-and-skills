---

```yaml
---
name: load_test_creation
description: Designs and executes load tests validating system performance under expected and peak traffic, identifying throughput limits and latency degradation before production.
version: 1.0.0
category: Testing & QA
tags: [load-testing, performance, throughput, slo, scalability]
priority: High

depends_on: []
flags_skills: [performance-optimization, monitoring-alerts]

inputs: [load-projections, critical-workflows, slo-definitions, performance-requirements]
outputs: [load-test-scripts, throughput-latency-error-metrics, bottleneck-recommendations]

rules_applied:
  - PC-1  # Analyze Complexity — results must characterize capacity limits and scaling behavior
  - PC-4  # Performance Budget — tests must validate system meets defined SLOs
  - TQ-1  # Test Coverage Requirement — performance-critical paths need load coverage before launch
  - DT-1  # Explicit Tradeoff Logging — perf vs cost tradeoffs from load tests must be documented

documents_needed: [load-projections, slo-definitions, system-architecture-diagram, ci-pipeline-config]

execution_context: Invoked before production launch of performance-sensitive features, after bottlenecks are suspected, or as part of capacity planning cycles.

---
```

---

# Skill: Load Test Creation

---

## Purpose

**What this skill does:**
Designs and executes load tests that simulate realistic user traffic at expected and peak volumes, measuring system throughput, response latency, and error rates under load. It validates that the system meets its defined SLOs before users encounter degradation in production, and identifies the specific bottlenecks responsible for any observed degradation.

Performance failures under load are among the most visible and damaging production incidents — they affect all users simultaneously and are hard to fix under fire. Load testing before launch gives the business confidence that the system will hold under expected demand, and surfaces the cost-vs-capacity tradeoffs that need business-level decisions.

Load test results provide empirical, evidence-based capacity data rather than estimates. They reveal bottlenecks that are invisible under development traffic, validate scaling assumptions, and serve as regression benchmarks — ensuring future changes do not silently degrade performance.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new feature or service is being launched and performance-critical paths have no load test coverage
* SLOs are defined but have never been validated under realistic traffic volumes
* A performance incident in production suggests load was not tested adequately before release
* A capacity planning exercise requires empirical throughput and latency data
* A significant code or infrastructure change may have altered performance characteristics
* The CI/CD pipeline has no load test gate for performance-sensitive releases

### Do NOT use this skill for:

* Finding breaking points or failure modes under extreme load — use `stress-test-creation`
* E2E workflow correctness validation — use `e2e-test-creation`
* Diagnosing why a specific test is failing — use `test-interpretation-failure-diagnosis`
* Runtime performance analysis of individual algorithms — use `performance-optimization`

**Execution Context Details:**
This skill runs after SLOs and traffic projections are available, typically as part of pre-launch readiness or capacity planning. It precedes production deployment for performance-sensitive features. It flags `performance-optimization` when bottlenecks are identified that require code or architecture changes, and `monitoring-alerts` when load test metrics should be integrated into production observability.

---

## Inputs

**Required inputs:**

* **Load projections** — Expected and peak concurrent user counts, request rates, and traffic patterns (ramp-up profiles, sustained load durations, burst scenarios). Used to design realistic simulation parameters.
* **Critical workflows** — The specific user paths to simulate under load (login, search, checkout, data export). Performance-critical paths must be identified before test design.
* **SLO definitions** — Defined thresholds for response latency (p50, p95, p99), error rate, and throughput that the system must meet. Tests are pass/fail against these thresholds.

**Optional inputs:**

* **Production traffic samples** — Real traffic distributions (request mix, think times, geographic spread) for more accurate simulation fidelity.
* **Infrastructure topology** — Database, cache, and service dependency layout to help interpret where bottlenecks occur.

**Documents/Context needed:**

* **System architecture diagram** — Identifies layers likely to constrain throughput (database connections, cache hit rates, external API calls).
* **CI pipeline config** — Required to integrate load gate into deployment pipeline.

---

## Outputs

**Primary outputs:**

* **Load test scripts** — Automated scripts simulating realistic traffic patterns at defined load levels, parameterized for different scenarios (baseline, peak, spike).
* **Throughput, latency, and error rate metrics** — Per-scenario measurements at p50/p95/p99 latency, requests-per-second, and error rate, compared against SLO thresholds.
* **Bottleneck identification and recommendations** — Specific components (database connection pool, cache layer, specific endpoint) causing degradation, with ranked improvement recommendations.

**Output format:**

* Load test scripts in the project's established framework (k6, Locust, Gatling, JMeter, or equivalent).
* Results as a structured report with per-scenario SLO pass/fail table and time-series graphs.
* Bottleneck analysis as a prioritized list with evidence (which metric degrades at which load level, which component is responsible).

**Skill flags (if applicable):**

* Flag **performance-optimization** when load test results identify a specific bottleneck that requires code or architecture changes to resolve.
* Flag **monitoring-alerts** when load test metrics (latency histograms, error rate trends) should be wired into production observability dashboards.

---

## Preconditions

**Conditions that must be met before execution:**

* SLOs must be defined — tests cannot be assessed as pass/fail without thresholds.
* Traffic projections must be available — arbitrary load levels produce unactionable results.
* Test environment must be isolated from production — load tests must never run against production systems or shared infrastructure that could affect live users.
* Infrastructure must be representative of production capacity — under-provisioned test environments produce misleading results.

**Validation checks:**

* [ ] SLOs are defined with specific numeric thresholds (not "fast enough")
* [ ] Traffic projections are based on real data or justified estimates — not guesses
* [ ] Test environment is isolated from production
* [ ] Test environment capacity is documented (to contextualize results vs production)
* [ ] No load test infrastructure can affect production data or traffic

---

## Step-by-Step Execution Procedure

### Step 1: Define Load Scenarios

**Questions to answer:**
- What is the expected baseline load, peak load, and spike profile?
- Which workflows are performance-critical and must be validated under load?
- What is the realistic user think-time and request mix?

**Actions:**
- [ ] Document baseline, peak, and spike load levels from projections
- [ ] List workflows to load test, ranked by performance criticality
- [ ] Define ramp-up profile (gradual ramp vs step vs constant)
- [ ] Determine think-time model (constant, random distribution, zero for throughput testing)
- [ ] Confirm SLO thresholds for each scenario

**Red flags / Warning signs:**
- Load levels are arbitrary or not grounded in traffic projections
- No SLO thresholds defined — results will be unassessable
- Only the happy path is tested — burst and spike behavior not modeled

**Decision points:**
- If SLOs are not defined, block and escalate to prompt engineer — a threshold decision, not a technical one
- If traffic projections are unavailable, request them before designing scenarios; do not substitute guesses

---

### Step 2: Design Realistic Traffic Simulation

**Questions to answer:**
- Does the simulation reflect real user behavior (request mix, think times, session structure)?
- Are external dependencies (third-party APIs, payment gateways) handled correctly?
- Is test data representative of production data volume and distribution?

**Actions:**
- [ ] Model request mix across endpoints proportional to production traffic
- [ ] Apply realistic think times (not zero-delay hammering unless throughput ceiling test is intended)
- [ ] Mock or stub external dependencies that cannot be load tested safely
- [ ] Provision representative test data volume (not a single shared record hit by all virtual users)
- [ ] Configure virtual user count ramp-up to match defined load scenario profiles

**Red flags / Warning signs:**
- All virtual users hit the same data record — not representative; produces cache artifacts
- No think time — unrealistically hammers the system; overstates degradation
- External APIs included without rate limit awareness — may hit third-party limits, not system limits

**Decision points:**
- If external APIs cannot be safely included, mock them and document the fidelity gap in the report
- If test data volume is insufficient, coordinate with `test-data-management` before proceeding

---

### Step 3: Implement and Validate Test Scripts

**Questions to answer:**
- Are scripts parameterized for different load levels without code duplication?
- Do scripts capture the right metrics at the right granularity?
- Do scripts fail fast on unexpected errors to avoid wasting test time on broken scenarios?

**Actions:**
- [ ] Implement scripts in the project's established load testing framework
- [ ] Parameterize virtual user count, ramp-up duration, and test duration as configurable variables
- [ ] Add assertions for error rate thresholds — fail the test if error rate exceeds SLO during ramp
- [ ] Validate scripts against a low-load smoke run before executing full load scenario
- [ ] Confirm metric capture: latency histograms (p50/p95/p99), throughput (RPS), error rate per endpoint

**Red flags / Warning signs:**
- Scripts hardcoded to a single load level — cannot be reused for different scenarios
- No assertions — scripts run to completion even when error rate is 100%
- No smoke validation — full load run may fail due to script errors, not system behavior

**Decision points:**
- If smoke run fails, diagnose and fix script errors before running full load scenario
- If metric collection is not capturing per-endpoint breakdown, reconfigure before proceeding

---

### Step 4: Execute and Analyze Results

**Questions to answer:**
- Do results meet SLO thresholds at baseline and peak load?
- At what load level does latency or error rate breach SLO thresholds?
- Which system component is the bottleneck — is it CPU, DB connections, cache, or a specific endpoint?

**Actions:**
- [ ] Execute baseline load scenario; compare latency and error metrics against SLOs
- [ ] Execute peak load scenario; record degradation profile
- [ ] Identify the load level at which SLO thresholds are first breached (degradation onset point)
- [ ] Correlate application metrics with infrastructure metrics (CPU, memory, DB connections, cache hit rate) to identify bottleneck component
- [ ] Classify bottleneck by type: connection pool saturation, query performance, cache miss storm, CPU ceiling, external API latency

**Red flags / Warning signs:**
- Results vary significantly between identical runs — environment instability invalidates results
- Bottleneck is not identified — "it gets slow" without root cause is not actionable
- Results only compared to SLO thresholds, not to each other — no degradation curve documented

**Decision points:**
- If result variance is high (>20% across identical runs), investigate environment stability before trusting results
- If bottleneck is a specific code path or query, flag `performance-optimization`
- If bottleneck is infrastructure capacity (not code), log as a capacity planning recommendation

---

### Step 5: Integrate into CI/CD Pipeline (where applicable)

**Questions to answer:**
- Should load tests run on every PR, on merge to main, or only pre-release?
- What is the acceptable pipeline execution time budget for load tests?
- What threshold triggers a pipeline failure vs a warning?

**Actions:**
- [ ] Configure load test pipeline stage at the appropriate trigger (pre-release, nightly, or post-merge)
- [ ] Set pipeline failure threshold: fail if p95 latency breaches SLO or error rate exceeds threshold
- [ ] Configure result reporting visible in pipeline dashboard
- [ ] Document which scenarios are in CI vs manual-only (full peak scenarios may be too slow for CI)

**Red flags / Warning signs:**
- Load tests configured to run on every PR — typically too slow and resource-intensive
- No failure threshold — load tests run but never block deployment on degradation
- Full peak load scenario in CI — will slow pipelines; scope to a representative smoke-load scenario

**Decision points:**
- If full peak scenario is too slow for CI, use a scaled-down but representative scenario as CI gate; run full scenarios manually pre-release
- Log the difference between CI scenario and full scenario as a documented gap

---

### Final Step: Generate Load Test Report

**Report/Output structure:**

```markdown
## Load Test Report

**Target System:** [Service or workflow under test]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Scenarios Executed

| Scenario | Virtual Users | Duration | p50 Latency | p95 Latency | Error Rate | SLO Result |
|---|---|---|---|---|---|---|
| Baseline | N | Xs | Xms | Xms | X% | ✅/❌ |
| Peak | N | Xs | Xms | Xms | X% | ✅/❌ |

### Degradation Profile
[At what load level does SLO breach occur; degradation curve description]

### Bottleneck Analysis
| Component | Evidence | Severity | Recommendation |
|---|---|---|---|
| [DB connection pool] | [pool saturation at Nrps] | HIGH | [Increase pool size / add read replica] |

### Coverage Gaps and Simulation Fidelity Notes
[Mocked dependencies, environment delta from production, any known fidelity gaps]

### Skills Flagged for Follow-up
- **[Skill]**: [Reason with evidence]

### Overall Assessment
**Decision:**
- ✅ PASS: All scenarios meet SLO thresholds at baseline and peak load
- ❌ FAIL: SLO breach at or below peak load; bottleneck identified
- ⚠️ NEEDS REVIEW: SLO met at baseline; marginal headroom at peak; monitoring recommended

### Required Actions
- [ ] [Action 1]
- [ ] [Action 2]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Define realistic load scenarios grounded in traffic projections and SLO thresholds — not arbitrary numbers
2. Design representative traffic simulation: correct request mix, think times, and test data volume
3. Implement scripts with parameterized load levels, assertions on error thresholds, and full metric capture
4. Execute scenarios and produce a degradation profile — not just a pass/fail at peak
5. Identify and name the specific bottleneck component with evidence, and flag for remediation

**Quality criteria:**

* Every performance-critical workflow is covered by at least one load scenario before production launch
* Results include a degradation onset point — not only a peak-load snapshot
* Bottleneck identification is evidence-based: correlated metrics, not speculation
* Simulation fidelity gaps (mocked dependencies, environment delta) are documented in the report

---

## Constraints (Rules Applied)

* **PC-1: Analyze Complexity** — Results must characterize capacity behavior: throughput saturation, latency scaling with concurrency, and degradation onset. A report stating only "it passed" is insufficient.
* **PC-4: Performance Budget** — Tests validate against defined SLO thresholds. If no SLOs exist, obtain them before testing — they are the only objective basis for pass/fail.
* **TQ-1: Test Coverage Requirement** — All performance-critical paths must have load coverage before production launch; performance-critical means any path where degradation would cause visible user impact or SLO breach.
* **DT-1: Explicit Tradeoff Logging** — Log all tradeoffs surfaced by load tests (coverage vs cost, mock fidelity vs accuracy) with rationale; do not silently accept coverage gaps.

---

## Tradeoff Handling

### Tradeoff 1: Test Coverage vs Infrastructure Cost

Comprehensive load testing requires significant infrastructure. Covering every endpoint at full peak load is expensive.

**Resolution:** Rank by performance criticality — cover P0 paths (checkout, login, search) in full; defer P1/P2 to lighter smoke-load scenarios; log deferred paths and risk via DT-1. If prioritization is unclear, escalate for business priority decision.

### Tradeoff 2: Simulation Realism vs Execution Complexity

Realistic simulation may involve third-party APIs with rate limits or cost implications.

**Resolution:** Mock the dependency; document fidelity gap in report noting which failure modes are unexercised; log mocking decision via DT-1. If gap is business-critical, escalate for explicit acceptance.

### Tradeoff 3: CI Load Test Scope vs Pipeline Speed

Full peak load scenarios are often too slow and resource-intensive for per-PR CI execution.

**Resolution:** Design a representative scaled-down CI scenario (e.g. 20% of peak, 2-minute duration); run full scenarios manually pre-release or nightly; log CI vs full scenario gap via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: SLOs Not Defined

**Trigger:** No numeric SLO thresholds exist for the system or workflow being tested.

**Action:**
- Block test execution — results cannot be assessed without thresholds
- Escalate to prompt engineer to define SLOs before proceeding

**Escalation format:**
```
⚠️ CLARIFICATION NEEDED

Issue: No SLO thresholds defined for [workflow/service]. Load test results cannot be assessed as pass/fail.
Context: Without defined latency, error rate, and throughput targets, test results are arbitrary.
Options:
  A. Define SLOs now based on user expectations and business requirements, then proceed.
  B. Run load test as an exploratory baseline with no pass/fail assessment.
Recommendation: Option A — exploratory baselines without thresholds cannot block releases.
Question: What are the acceptable p95 latency, error rate, and throughput targets for [workflow]?
```

---

### Escalation Scenario 2: Bottleneck Identified — Code or Architecture Change Required

**Trigger:** Load test identifies a specific bottleneck (slow query, connection pool saturation, inefficient algorithm) that requires engineering changes to resolve.

**Action:**
- Document bottleneck with evidence in the report
- Flag `performance-optimization` with specific bottleneck details
- Do not attempt to fix the bottleneck within this skill — delegate to performance-optimization

---

### Escalation Scenario 3: High Result Variance Between Identical Runs

**Trigger:** Repeated identical load scenarios produce significantly different results (>20% variance in p95 latency or error rate).

**Action:**
- Do not report unstable results as conclusions — they are invalid
- Investigate environment stability (resource contention, GC pressure, background jobs)
- Resolve variance source before re-running; document in report

---

### Escalation Scenario 4: Load Test Infrastructure Risks Affecting Production

**Trigger:** Test environment is shared with production or test traffic could reach production systems.

**Action:**
- Halt immediately — do not execute load tests against production or shared infrastructure
- Escalate to `test-environment-management` for isolation
- Require explicit confirmation gate before any test execution that could affect live users

---

### When to halt execution:

* SLOs are not defined and cannot be obtained — tests produce unassessable results
* Test environment is not isolated from production
* Traffic projections are unavailable and estimates cannot be justified

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs after SLO and traffic projection inputs are available, before production launch of performance-sensitive features. Depends on `test-environment-management` for a representative, isolated environment and `test-data-management` for representative data volume. Flags `performance-optimization` for bottleneck remediation and `monitoring-alerts` for production observability integration.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Specific code or query bottleneck identified | performance-optimization | Engineering change required to resolve bottleneck |
| Load metrics should feed production dashboards | monitoring-alerts | Load test thresholds should become production alert thresholds |

---

## Related Skills

**Skills this skill depends on:**

* **test-environment-management** — Provides the isolated, representative environment. Load tests against under-provisioned or shared environments produce misleading results.
* **test-data-management** — Provides representative data volume and distribution. Insufficient test data produces unrealistic cache behavior and misleading throughput numbers.

**Skills this skill cooperates with:**

* **stress-test-creation** — Load tests establish the normal operating envelope; stress tests find the breaking points beyond it. Load test baselines are the input to stress test scenario design.
* **e2e-test-creation** — E2E tests validate correctness; load tests validate performance. They test the same workflows at different concerns and should cover the same critical paths.

**Skills this skill may invoke/flag:**

* **performance-optimization** — When a bottleneck requiring code or architecture change is identified.
* **monitoring-alerts** — When load test thresholds should become production alert baselines.

---

## Governance Hooks

* [ ] Log all tradeoff decisions (coverage deferrals, mocking choices, CI scope reductions) via DT-1
* [ ] Explain risks before recommending reducing load test coverage or accepting a mock fidelity gap
* [ ] Block execution if SLOs are undefined — do not run unassessable tests
* [ ] Never execute load tests against production or shared infrastructure without explicit confirmation
* [ ] Document environment delta from production in every report
* [ ] Flag bottlenecks to `performance-optimization` — do not silently accept degradation

**Audit trail requirements:**

* Log which scenarios were executed vs deferred, with rationale
* Document simulation fidelity gaps (mocked dependencies, environment delta)
* Record SLO thresholds used at time of testing — thresholds may change
* Log all bottleneck findings with supporting metric evidence

---

## Example Use Cases

### Example 1: Pre-Launch Load Validation for Search Feature

**Scenario:** A new search service is launching. Traffic projections estimate 2,000 concurrent users at peak with a p95 latency SLO of <500ms and error rate <0.1%.

**Inputs provided:**
- Traffic projection: 500 baseline, 2,000 peak concurrent users
- SLO: p95 < 500ms, error rate < 0.1%, throughput > 1,000 RPS
- Critical workflow: search query → results page

**Execution steps:**
1. Design three scenarios: baseline (500 VU), peak (2,000 VU), spike (5,000 VU for 60s)
2. Implement k6 script with realistic query mix and 2-second think time; parameterize VU count
3. Run baseline — p95 = 210ms, error rate 0.0% ✅. Run peak — p95 = 480ms, error rate 0.08% ✅. Run spike — p95 = 1,200ms, error rate 2.1% ❌ at 4,200 VU
4. Correlate spike failure with DB connection pool exhaustion (pool size = 50, needed 80 at 4,200 VU)
5. Flag `performance-optimization` for connection pool increase; log DT-1 for connection pool vs cost tradeoff

**Result:** ⚠️ NEEDS REVIEW — SLO met at baseline and peak; breach at 4,200 VU spike; bottleneck identified
**Skills flagged:** `performance-optimization` (DB connection pool)

---

### Example 2: Load Test Blocked by Missing SLOs

**Scenario:** Engineering team requests load testing for the payment service before a major launch. No SLOs are defined.

**Execution steps:**
1. Request SLO definitions from product team — none exist
2. Block test execution and escalate to prompt engineer with clarification request
3. After SLOs are defined (p95 < 300ms, error rate < 0.01%), proceed with test design

**Result:** ⚠️ BLOCKED — escalated for SLO definition before proceeding

---

### Example 3: Adding Load Test CI Gate for API Service

**Scenario:** An API service has passed load testing manually but has no automated load gate in the CI pipeline. The team wants regressions caught automatically.

**Inputs provided:**
- Existing load test scripts (Locust)
- CI pipeline (GitHub Actions)
- SLO: p95 < 200ms, error rate < 0.5%

**Execution steps:**
1. Scope CI scenario to 10% of peak (200 VU, 90-second duration) — representative but fast
2. Add GitHub Actions stage post-integration-test; fail pipeline if p95 > 200ms or error rate > 0.5%
3. Log full peak scenario as manual pre-release — document CI vs full gap in report via DT-1

**Result:** ✅ PASS — CI gate integrated; full peak scenario documented as manual pre-release step

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Arbitrary load levels not grounded in projections**
"Let's test with 1,000 users" without knowing what real peak traffic is produces unactionable results.
✅ Ground all VU counts in traffic projections. Document the source of projections in the report.

❌ **Anti-pattern 2: Testing without SLO thresholds**
Without defined pass/fail thresholds, results are opinions. "It felt fast" is not a gate.
✅ Require SLOs before any load test begins. Block if undefined.

❌ **Anti-pattern 3: All virtual users hitting the same data record**
10,000 VUs fetching the same user record produces unrealistic cache hit rates and hides real data distribution effects.
✅ Parameterize test data; provision a representative data volume before testing.

❌ **Anti-pattern 4: Zero think time (pure throughput hammering)**
Sending requests with no delay between them doesn't represent users — it tests raw server capacity, not real-world behavior.
✅ Apply realistic think times unless the explicit goal is finding the raw throughput ceiling (and document this intent).

❌ **Anti-pattern 5: Running load tests against production**
Even read-only load tests against production risk saturating shared resources and impacting live users.
✅ Always test in an isolated, representative environment. Halt immediately if isolation cannot be confirmed.

❌ **Anti-pattern 6: Reporting only peak pass/fail without a degradation curve**
"It passed at peak" doesn't tell you how close to the limit the system is or at what load it begins to degrade.
✅ Report the degradation onset point — when does p95 latency first start rising meaningfully?

❌ **Anti-pattern 7: Naming "it's slow" without identifying the bottleneck component**
Unactionable findings waste engineering cycles. "Performance is poor" without a root cause cannot be fixed.
✅ Correlate application metrics with infrastructure metrics to name the specific bottleneck component.

❌ **Anti-pattern 8: Including external APIs without rate limit awareness**
Hitting a third-party payment API with 2,000 VUs in a load test may violate rate limits, incur costs, or trigger fraud detection.
✅ Mock external APIs in load tests; document the fidelity gap.

❌ **Anti-pattern 9: High variance between runs accepted without investigation**
If two identical runs produce 200ms vs 400ms p95 results, the environment is unstable and neither result is trustworthy.
✅ Investigate variance source before reporting results. Never average unstable results.

❌ **Anti-pattern 10: Full peak load scenario in every PR CI run**
A 30-minute load test on every PR will be disabled by engineers within a week.
✅ Scope CI scenario to a representative subset (duration, VU count). Run full scenarios pre-release.

---

## Non-Goals

* ❌ **Finding breaking points and failure modes** — handled by `stress-test-creation`; load tests validate normal operating envelope
* ❌ **E2E correctness validation** — handled by `e2e-test-creation`; load tests measure performance, not correctness
* ❌ **Fixing identified bottlenecks** — handled by `performance-optimization`; this skill identifies and escalates
* ❌ **Managing test data provisioning** — coordinated with `test-data-management`
* ❌ **Environment provisioning** — coordinated with `test-environment-management`

**Boundary clarifications:**

* Load tests validate the system under expected operating load. Stress tests go beyond — they find where the system breaks. Do not conflate the two; use both in sequence.
* This skill identifies bottlenecks with evidence; it does not implement fixes. Remediation belongs to `performance-optimization`.
* This skill does not define SLOs — it validates against them. SLO definition is a product and business decision.

---

## Notes for LLM Implementation

1. **Always require SLOs before beginning — this is a hard block.** Running load tests without pass/fail thresholds produces data that cannot gate releases. Escalate immediately if SLOs are absent.
2. **Ground every scenario in traffic projections.** Do not invent load levels. If projections are unavailable, request them; document any estimates with explicit uncertainty.
3. **Report degradation curves, not just peak pass/fail.** The most actionable insight is the load level at which degradation begins — not whether the system survived the peak snapshot.
4. **Name the bottleneck component with evidence.** "Latency increased" is not actionable. "DB connection pool saturated at 1,200 RPS, as evidenced by connection wait time spike correlating with p95 latency onset" is actionable.
5. **Document every fidelity gap.** Mocked external APIs, under-provisioned test environments, and simplified traffic models all reduce result validity. They must be named and logged.

6. Use per-scenario SLO pass/fail tables; include degradation onset prominently; present bottleneck analysis as evidence-based table (component, metric evidence, severity, recommendation); mark fidelity gaps with ⚠️.
7. Be empirical — report what the data shows; be specific about bottlenecks; if headroom is marginal (within 15% of SLO at peak), flag it explicitly.

---
