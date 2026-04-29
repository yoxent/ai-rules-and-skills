---

```yaml
---
name: stress_test_creation
description: Evaluates system behavior under extreme load and failure conditions to identify breaking points, failure modes, and recovery behavior before production.
version: 1.1.0
category: Testing & QA
tags: [stress-testing, resilience, breaking-points, failure-modes, recovery]
priority: High

depends_on: [load-test-creation]
flags_skills: [performance-optimization, risk-analysis, test-environment-management]

inputs: [system-architecture, load-test-baselines, capacity-limits, critical-workflows]
outputs: [stress-test-scripts, breaking-point-report, failure-mode-documentation, recovery-time-measurements]

rules_applied:
  - PC-1  # Analyze Complexity — must characterize failure envelope, not just confirm breakage
  - PC-4  # Performance Budget — results set upper bounds of the performance budget
  - TQ-1  # Test Coverage Requirement — SLA systems must be stress tested for recovery behavior
  - DT-2  # Confirmation Gate — destructive tests on shared infra require explicit approval

documents_needed: [load-test-results, system-architecture-diagram, sla-definitions, infrastructure-topology]

execution_context: Invoked after load test baselines exist, before production launch of SLA-governed services, or when resilience characteristics of a system are unknown or untested.

---
```

---

# Skill: Stress Test Creation

---

## Purpose

**What this skill does:**
Designs and executes stress tests that push the system beyond its normal operating parameters to find breaking points, characterize failure modes, and measure recovery behavior. It builds on load test baselines to extend into the failure envelope — answering not just "does it work under expected load?" but "how does it fail, and how does it recover?"

Systems fail. Stress testing ensures that failures happen on schedule — in a controlled test environment rather than during a peak production event. Knowing a system's breaking point, failure mode, and recovery time enables the business to set realistic SLAs, plan capacity, and build incident response runbooks before they're needed.

Stress tests surface resilience weaknesses (connection pool exhaustion, cascading timeouts, memory leaks under sustained load, ungraceful shutdowns) that only appear at extreme conditions. The resulting failure mode documentation becomes the foundation for circuit breakers, retry policies, auto-scaling thresholds, and disaster recovery procedures.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A service is governed by an SLA and has never been stress tested to confirm recovery behavior
* Load test baselines exist and the team needs to understand the system's failure envelope
* A new resilience pattern (circuit breaker, retry logic, auto-scaling) has been added and needs validation under extreme conditions
* Pre-launch readiness for a high-stakes release requires confidence beyond normal load testing
* An architecture change may have altered failure or recovery characteristics
* Chaos engineering or disaster recovery exercises require a defined failure baseline

### Do NOT use this skill for:

* Validating behavior under expected or peak load — use `load-test-creation`
* E2E workflow correctness — use `e2e-test-creation`
* Fixing identified bottlenecks — use `performance-optimization`
* Defining SLAs or SLOs — that is a product and business decision

**Execution Context Details:**
This skill runs after load test baselines exist (`load-test-creation` must have completed). It escalates findings to `performance-optimization` for bottleneck remediation and to `risk-analysis` when failure modes have business-level impact. Destructive tests against shared infrastructure always require a confirmation gate (DT-2) before execution.

---

## Inputs

**Required inputs:**

* **Load test baselines** — Results from `load-test-creation` that establish the normal operating envelope. Stress tests extend from this baseline into the failure envelope — without it, the starting point is arbitrary.
* **System architecture** — Topology of services, databases, caches, and external dependencies. Required to design targeted stress scenarios and interpret failure signals.
* **Critical workflows** — The specific paths to stress beyond normal operating parameters. Prioritized by business criticality and SLA scope.

**Optional inputs:**

* **SLA definitions** — If the system has defined availability or recovery time targets (RTO/RPO), stress tests validate whether recovery behavior meets them.
* **Known capacity limits** — Infrastructure-level constraints (DB connection pool size, instance memory ceiling) that can be used to design targeted saturation scenarios.

**Documents/Context needed:**

* **Infrastructure topology** — For correlation between stress signals and infrastructure resource metrics.

---

## Outputs

**Primary outputs:**

* **Stress test scripts** — Automated scripts exceeding normal operating capacity, targeting specific failure scenarios (saturation, resource exhaustion, cascading failure).
* **Breaking point report** — The load level at which each tested component or workflow fails, with failure mode classification (graceful degradation, hard crash, cascade, timeout storm).
* **Failure mode documentation** — Detailed characterization of each failure: what fails first, what cascades, what error surfaces to the user, what logging/observability captures it.
* **Recovery time measurements** — Time-to-recovery after each failure condition, compared against SLA targets where defined.

**Output format:**

* Stress test scripts in the project's established framework, parameterized for different intensity levels.
* Breaking point report as a structured table: scenario, breaking point load, failure mode, recovery time, SLA result.
* Failure mode documentation as per-scenario writeups suitable for use in incident runbooks.

**Skill flags (if applicable):**

* Flag **performance-optimization** when a breaking point is caused by a fixable bottleneck (inefficient query, connection pool size, missing cache layer) rather than a fundamental capacity constraint.
* Flag **risk-analysis** when failure modes could have direct business-level impact (data loss, compliance exposure, cascading failures affecting multiple services).

---

## Preconditions

**Conditions that must be met before execution:**

* Load test baselines must exist — stress tests are relative to a known normal operating envelope.
* Test environment must be completely isolated from production — destructive tests must never reach live systems or shared infrastructure.
* Any shared infrastructure (staging databases, shared message queues) must be excluded or explicitly approved via DT-2 confirmation gate before use.
* Destructive or irreversible test scenarios (data corruption tests, kill-process scenarios) require explicit confirmation before execution.

**Validation checks:**

* [ ] Load test baselines available from `load-test-creation`
* [ ] Test environment confirmed isolated from production
* [ ] Shared infrastructure exclusion confirmed or DT-2 approval obtained
* [ ] Recovery measurement plan defined before executing any destructive scenario
* [ ] Observability instrumentation active — failure detection requires metrics, logs, and traces during stress

---

## Step-by-Step Execution Procedure

### Step 1: Define Stress Scenarios from Load Baselines

**Questions to answer:**
- Where does the load test show the first signs of degradation? That is the stress test starting point.
- Which components are most likely to fail first based on architecture review?
- What failure modes are most dangerous for the business (data corruption, cascade, silent error)?

**Actions:**
- [ ] Review load test degradation onset points — stress starts where load tests end
- [ ] Identify candidate failure scenarios: resource saturation, dependency failure injection, sustained overload, spike beyond peak
- [ ] Prioritize scenarios by business risk (SLA scope, data integrity risk, cascade potential)
- [ ] Define recovery measurement methodology before any destructive scenario runs

**Red flags / Warning signs:**
- No load test baselines exist — cannot design meaningful stress scenarios without knowing the normal envelope
- Stress scenarios are arbitrary ("let's try 10x load") rather than grounded in architecture analysis
- No recovery measurement plan — a test that breaks the system without measuring recovery is incomplete

**Decision points:**
- If no load test baselines exist, invoke `load-test-creation` first and block stress test design
- If a scenario targets shared infrastructure, trigger DT-2 confirmation gate before proceeding

---

### Step 2: Confirm Isolation and Approval Gates

**Questions to answer:**
- Is the test environment fully isolated from production and shared infrastructure?
- Do any planned scenarios require explicit approval (DT-2)?
- Is the observability stack active and capturing during test execution?

**Actions:**
- [ ] Verify test environment isolation — confirm no traffic can reach production systems
- [ ] Identify scenarios classified as destructive (kill processes, exhaust connections, inject corruption)
- [ ] Obtain DT-2 confirmation for any destructive scenario on shared or production-adjacent infrastructure
- [ ] Confirm monitoring, logging, and tracing are active before execution begins

**Red flags / Warning signs:**
- Environment isolation unconfirmed — do not proceed
- Destructive scenarios planned without DT-2 approval — do not proceed
- Observability not active — failure signals will be undetectable and results untrustworthy

**Decision points:**
- If environment isolation cannot be confirmed, halt and escalate to `test-environment-management`
- If DT-2 approval is withheld, exclude the scenario and document it as untested with risk noted

---

### Step 3: Implement Stress Test Scripts

**Questions to answer:**
- Are scripts parameterized to allow controlled intensity escalation?
- Do scripts include automated recovery detection — or is recovery measured manually?
- Are failure injection scripts (dependency kill, resource exhaustion) safe to execute without side effects on the environment itself?

**Actions:**
- [ ] Implement load escalation scripts starting from the load test baseline and stepping up
- [ ] Implement failure injection scripts where applicable (kill service, exhaust DB connections, inject network latency)
- [ ] Add automated recovery detection: script should detect when the system returns to baseline metrics post-failure
- [ ] Include kill switches — scripts must be safely stoppable mid-execution

**Red flags / Warning signs:**
- No kill switch mechanism — if a test spirals, it must be stoppable immediately
- Recovery detection is manual — introduces measurement error and observer bias
- Scripts cannot be re-run cleanly — environment must be resettable after each destructive scenario

**Decision points:**
- If environment cannot be reset after a destructive scenario, redesign to be non-destructive or obtain explicit approval and document the one-shot nature

---

### Step 4: Execute Scenarios and Measure Breaking Points

**Questions to answer:**
- At what exact load level or failure injection does the system fail?
- What is the failure mode — graceful degradation, hard crash, timeout storm, cascade?
- How long does recovery take, and is it automatic or manual?

**Actions:**
- [ ] Execute each scenario from baseline, stepping up intensity incrementally
- [ ] Record the precise breaking point: load level, failure trigger, time to failure onset
- [ ] Classify failure mode: graceful (errors returned, core functionality preserved) vs hard (crash, data loss risk, cascade)
- [ ] Measure time-to-recovery: from failure onset to restored baseline metrics
- [ ] Compare recovery time against SLA targets (RTO) where defined

**Red flags / Warning signs:**
- System does not recover automatically — manual intervention required is a resilience gap
- Cascade failure: one component failure propagates to unrelated components
- Silent failure: system appears healthy but returns wrong data or drops requests without error
- Recovery is slower than SLA RTO target

**Decision points:**
- If cascade failure is detected, flag `risk-analysis` — cross-service impact has business-level implications
- If silent failure is detected (data correctness at risk), escalate immediately — highest severity failure mode
- If recovery exceeds SLA RTO, flag `risk-analysis` and document gap explicitly

---

### Step 5: Document Failure Modes and Recommendations

**Questions to answer:**
- Is each failure mode documented with enough detail to inform an incident runbook?
- Are resilience improvements recommended and ranked by risk reduction impact?
- Are fixable breaking points (bottlenecks vs fundamental capacity limits) distinguished?

**Actions:**
- [ ] Write failure mode documentation for each scenario: trigger, failure sequence, user-visible impact, observability signals
- [ ] Classify each breaking point: fixable bottleneck (flag `performance-optimization`) vs fundamental capacity limit (document as architectural constraint)
- [ ] Rank resilience recommendations by risk reduction: circuit breakers, connection pool sizing, retry budgets, auto-scaling thresholds
- [ ] Log all findings via DT-1 where tradeoffs apply (cost vs resilience, complexity vs reliability)

---

### Final Step: Generate Stress Test Report

**Report/Output structure:**

```markdown
## Stress Test Report

**Target System:** [Service or workflow under test]
**Date:** [YYYY-MM-DD]
**Load Test Baseline Reference:** [Link or reference to load-test-creation results]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Breaking Points Summary

| Scenario | Breaking Point | Failure Mode | Recovery Time | SLA RTO | Result |
|---|---|---|---|---|---|
| [Scenario 1] | [N VU / N RPS] | [Graceful/Hard/Silent/Cascade] | [Xs] | [Xs] | ✅/❌ |

### Failure Mode Documentation

#### Scenario: [Name]
**Trigger:** [What caused the failure]
**Failure sequence:** [Step-by-step what happened]
**User-visible impact:** [What the user experienced]
**Observability signals:** [What metrics/logs/traces fired]
**Recovery:** [Automatic/Manual, time, procedure]

### Resilience Recommendations (Ranked by Risk Reduction)
1. [Recommendation 1 — evidence, risk reduction, complexity]
2. [Recommendation 2]

### Untested Scenarios (with Risk Notes)
[Scenarios excluded due to isolation constraints or withheld DT-2 approval]

### Skills Flagged for Follow-up
- **[Skill]**: [Reason with evidence]

### Overall Assessment
- ✅ PASS: All failure modes are graceful; recovery within SLA RTO; no cascade or silent failures
- ❌ FAIL: Hard crash, silent failure, cascade, or SLA RTO breach detected
- ⚠️ NEEDS REVIEW: Graceful failures but recovery marginal against SLA; fixable bottlenecks identified

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Build stress scenarios from load test baselines — not arbitrary numbers
2. Confirm environment isolation and obtain DT-2 approval for destructive scenarios before execution
3. Execute scenarios with incremental intensity escalation and automated recovery detection
4. Classify every failure mode: graceful, hard crash, silent, or cascade
5. Document failure modes with enough detail for incident runbooks; distinguish fixable bottlenecks from capacity limits

**Quality criteria:**

* Every stress scenario has a defined recovery measurement methodology before execution
* Failure mode documentation is specific enough to support incident runbook authoring
* Breaking points are expressed as precise load levels or failure injection conditions — not "roughly 5x load"
* Cascade and silent failure modes are treated as highest severity and escalated immediately

---

## Constraints (Rules Applied)

* **PC-1: Analyze Complexity** — Stress tests must characterize the failure envelope: at what load, in what sequence, with what recovery behavior. Confirming breakage without characterizing recovery is incomplete.
* **PC-4: Performance Budget** — Results set the upper bound of the performance budget; breaking points inform auto-scaling thresholds, circuit breaker trip points, and SLA ceiling commitments.
* **TQ-1: Test Coverage Requirement** — Any SLA-governed system must be stress tested to confirm recovery meets RTO/RPO; SLA commitments without stress test validation are unverified promises.
* **DT-2: Confirmation Gate** — Destructive tests on shared infrastructure or scenarios with irreversible side effects require explicit approval before execution. This is a hard gate.

---

## Tradeoff Handling

### Tradeoff 1: Test Intensity vs Environment Safety

Extreme stress tests risk damaging test infrastructure (filling disks, corrupting databases, exhausting OS resources).

**Resolution:** Require DT-2 confirmation before proceeding; design environment reset procedure before any destructive scenario. If reset is not possible, redesign to non-destructive or document as untested; log via DT-1.

### Tradeoff 2: Thoroughness vs Production Relevance

Scenarios at 20x peak load are theoretically interesting but may have no realistic production analog.

**Resolution:** Prioritize scenarios within 3–5x peak as production-relevant; label beyond as theoretical; log scope decision via DT-1.

### Tradeoff 3: Shared Infrastructure Access vs Isolation

Fully representative environments may require shared databases or services.

**Resolution:** Trigger DT-2 confirmation gate; if withheld, use mocked/sandboxed dependency and document fidelity gap via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: No Load Test Baselines Available

**Trigger:** Stress test design requested but no load test results exist.

**Action:**
- Block stress test design
- Invoke `load-test-creation` first
- Resume after baselines are available

---

### Escalation Scenario 2: Cascade Failure Detected

**Trigger:** One component failure propagates to unrelated services or components.

**Action:**
- Record cascade sequence in detail (which component, what propagated to where, what the blast radius was)
- Flag `risk-analysis` — cross-service cascade has business-level impact requiring stakeholder awareness
- Flag `performance-optimization` if the cascade is caused by a fixable bottleneck (timeout misconfiguration, missing circuit breaker)

**Escalation format:**
```
⚠️ CASCADE FAILURE DETECTED

Trigger: [Component that failed first]
Propagation: [Component A → Component B → Component C]
Blast radius: [Services/users affected]
Recovery: [Automatic/Manual; time]
Risk: [Business impact — data loss? user-facing outage? SLA breach?]
Recommendation: [Circuit breaker at X, timeout budget at Y, isolation of Z]
```

---

### Escalation Scenario 3: Silent Failure Detected

**Trigger:** System appears healthy (no errors, metrics within range) but returns incorrect data or silently drops requests.

**Action:**
- Treat as highest severity — escalate immediately
- Flag `risk-analysis` — data correctness risk is a compliance and trust issue
- Do not continue stress testing until silent failure is understood and documented

---

### Escalation Scenario 4: Recovery Exceeds SLA RTO

**Trigger:** Measured recovery time after a failure condition exceeds the defined SLA Recovery Time Objective.

**Action:**
- Document recovery time gap with precision (measured vs target)
- Flag `risk-analysis` — SLA RTO breach is a business commitment violation
- Recommend specific resilience changes (auto-recovery, automated failover, health check tuning)

---

### Escalation Scenario 5: Isolation Cannot Be Confirmed

**Trigger:** Environment isolation cannot be confirmed before stress scenario execution.

**Action:**
- Halt execution — do not proceed with any stress scenario
- Flag test-environment-management to provision or confirm an isolated environment
- Do not resume until isolation is guaranteed

---

### When to halt execution:

* Environment isolation cannot be confirmed — do not execute any stress scenario
* DT-2 approval is required and has not been obtained — do not execute destructive scenarios
* Silent failure detected — halt remaining scenarios and escalate before proceeding
* Test environment is damaged or in an unrecoverable state — halt and restore before continuing

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs after `load-test-creation` has established baselines. Depends on `test-environment-management` for isolation guarantees and `test-data-management` for resettable state. Flags `performance-optimization` for fixable bottlenecks and `risk-analysis` for business-impact failure modes. Stress test results feed into incident runbooks, auto-scaling configuration, and SLA commitments.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Fixable bottleneck at breaking point | performance-optimization | Code or config change can raise the breaking point |
| Cascade failure or silent failure | risk-analysis | Business-level impact requires stakeholder awareness |
| Recovery exceeds SLA RTO | risk-analysis | SLA commitment is at risk; business decision required |
| Environment isolation cannot be confirmed | test-environment-management | Provision or confirm isolated environment before stress execution |

---

## Related Skills

**Skills this skill depends on:**

* **load-test-creation** — Must complete first. Stress scenarios are designed relative to load test degradation onset points. Without baselines, stress scenarios are arbitrary.
* **test-environment-management** — Provides isolation guarantees and environment reset capability after destructive scenarios.

**Skills this skill cooperates with:**

* **test-data-management** — Resettable data state is required after destructive scenarios that modify or corrupt test data.
* **monitoring-alerts** — Stress test failure signals (cascade patterns, recovery thresholds) should inform production alert thresholds.

**Skills this skill may invoke/flag:**

* **performance-optimization** — When breaking points are caused by fixable code or configuration bottlenecks.
* **risk-analysis** — When failure modes have business-level impact (cascade, silent failure, SLA RTO breach).

---

## Governance Hooks

* [ ] Obtain DT-2 confirmation before any destructive scenario on shared or production-adjacent infrastructure
* [ ] Log all failure mode findings, tradeoff decisions, and untested scenarios via DT-1
* [ ] Never execute stress tests without confirmed environment isolation
* [ ] Document recovery measurement methodology before executing any destructive scenario
* [ ] Treat silent failures as highest severity — halt and escalate immediately
* [ ] Flag `risk-analysis` for any cascade failure or SLA RTO breach — do not bury in report

**Audit trail requirements:**

* DT-2 approval records for all destructive scenarios
* Environment isolation confirmation record per test run
* Per-scenario breaking point, failure mode, and recovery time measurements
* All untested scenarios with reason and risk assessment

---

## Example Use Cases

### Example 1: Database Saturation Stress Test

**Scenario:** An API service has a DB connection pool of 50. Load tests show degradation at 800 RPS. Stress test targets pool exhaustion.

**Inputs provided:**
- Load test baseline: degradation onset at 800 RPS, pool usage at 80% at 600 RPS
- Architecture: single Postgres instance, pool size 50, no read replica

**Execution steps:**
1. Design saturation scenario: ramp from 800 RPS to 1,500 RPS in 60-second steps
2. Confirm isolated test environment; no DT-2 needed (isolated Postgres instance)
3. Execute: at 1,100 RPS, connection pool exhausts; API returns 503; DB connections queue
4. Failure mode: graceful (503 returned, no data loss); recovery: automatic in 45 seconds after load reduction
5. SLA RTO = 60s; recovery at 45s ✅; flag `performance-optimization` (pool size increase + read replica recommendation)

**Result:** ⚠️ NEEDS REVIEW — graceful failure, recovery within SLA RTO; fixable bottleneck identified
**Skills flagged:** `performance-optimization` (connection pool sizing)

---

### Example 2: Cascade Failure via Dependency Timeout

**Scenario:** A payment service calls an inventory service synchronously. Stress test injects 5-second latency into the inventory service.

**Execution steps:**
1. Inject 5s latency into inventory service responses using fault injection proxy
2. Payment service thread pool exhausts waiting for inventory responses; all payment requests begin timing out
3. Cascade: order service (which calls payment) also starts timing out; 3-service cascade detected
4. Flag `risk-analysis` immediately — cross-service cascade affects revenue-critical path

**Result:** ❌ FAIL — cascade failure detected; silent timeout propagation with no circuit breaker
**Skills flagged:** `risk-analysis` (cascade, revenue-critical), `performance-optimization` (missing circuit breaker)

---

### Example 3: Stress Test Blocked by Missing Isolation

**Scenario:** Team requests stress testing of the staging environment, which shares a database with a QA team running concurrent tests.

**Execution steps:**
1. Review environment: staging DB is shared with QA automation suite running in parallel
2. Shared infrastructure detected — trigger DT-2 confirmation gate
3. DT-2 approval withheld — QA suite would be disrupted
4. Document scenario as untested with risk noted; recommend dedicated stress environment

**Result:** ⚠️ BLOCKED — environment isolation not confirmed; scenario deferred pending dedicated environment

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Stress testing without load test baselines**
Picking "10x load" arbitrarily has no relationship to actual system behavior or production relevance.
✅ Always start from load test degradation onset points. Stress starts where load tests end.

❌ **Anti-pattern 2: Running destructive tests without DT-2 approval**
Exhausting connections or killing processes on shared infrastructure can corrupt other teams' work and production-adjacent state.
✅ Identify destructive scenarios in advance; obtain explicit DT-2 approval before execution.

❌ **Anti-pattern 3: No recovery measurement plan**
A test that breaks the system without measuring recovery time is half a test. Recovery behavior is often the most business-critical finding.
✅ Define recovery measurement methodology before any destructive scenario executes.

❌ **Anti-pattern 4: Treating all failure modes as equivalent**
A graceful degradation (errors returned, data intact) and a silent failure (wrong data returned) have completely different risk profiles.
✅ Classify every failure mode. Silent failures are always highest severity — halt and escalate.

❌ **Anti-pattern 5: Stress testing against production**
Even "read-only" stress tests can saturate shared infrastructure and cause production incidents.
✅ Confirm environment isolation before any test execution. No exceptions.

❌ **Anti-pattern 6: Vague breaking point documentation**
"It falls over at high load" is not actionable for capacity planning, SLA setting, or incident response.
✅ Document the precise breaking point: load level, failure trigger, failure sequence, recovery time.

❌ **Anti-pattern 7: Missing kill switches in test scripts**
A runaway stress test with no kill switch can destroy test infrastructure and require hours of manual recovery.
✅ Every stress test script must have an immediate kill mechanism testable before the full run.

❌ **Anti-pattern 8: Cascade failures ignored as "expected"**
A cascade is a design defect, not an expected behavior. It indicates missing circuit breakers, timeout budgets, or isolation.
✅ Treat cascade failures as high-severity findings; flag `risk-analysis` immediately.

❌ **Anti-pattern 9: No environment reset between destructive scenarios**
Running a second destructive scenario against an environment already damaged by the first produces unreliable results.
✅ Reset environment to known state between each destructive scenario.

❌ **Anti-pattern 10: Stress test results not used for SLA validation**
Stress test data collected but not compared to SLA RTO/RPO commitments misses the primary governance value.
✅ Every recovery time measurement must be explicitly compared to SLA targets where they exist.

---

## Non-Goals

* ❌ **Validating behavior under expected load** — handled by `load-test-creation`
* ❌ **E2E correctness testing** — handled by `e2e-test-creation`
* ❌ **Fixing identified bottlenecks** — handled by `performance-optimization`
* ❌ **Defining SLAs or RTO/RPO targets** — business and product decision, not in scope
* ❌ **Production chaos engineering** — this skill operates only in isolated test environments

**Boundary clarifications:**

* Stress tests find breaking points; load tests validate normal operating envelopes. Both are required; neither replaces the other.
* This skill identifies and documents failure modes; it does not fix them. Remediation is `performance-optimization`.
* Production chaos engineering (GameDay, fault injection in production) is out of scope — this skill operates only against isolated test environments.

---

## Notes for LLM Implementation

1. **Always require load test baselines before designing scenarios.** Stress testing without a known normal envelope produces arbitrary, uncontextualised results.
2. **Treat the DT-2 gate as a hard stop.** Do not execute any destructive scenario on shared or production-adjacent infrastructure without recorded approval — not even a "quick test."
3. **Classify every failure mode explicitly.** The distinction between graceful, hard crash, silent, and cascade is not cosmetic — it determines the severity, escalation path, and remediation priority.
4. **Silent failures are always halt conditions.** Data correctness at risk is a compliance and trust issue. Do not continue stress testing after detecting a silent failure until it is fully understood.
5. **Recovery time is as important as the breaking point.** The breaking point tells you when; the recovery time tells you the business impact. Always measure both.

6. Express breaking points as precise metrics; structure failure mode documentation for reuse in incident runbooks; highlight cascade failures prominently.
7. Be systematic — execute in defined order, document before proceeding; be conservative — if isolation is uncertain, halt; be specific — vague failure descriptions are not actionable.

---
