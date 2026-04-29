---

```yaml
---
name: e2e_test_creation
description: Designs and implements end-to-end tests covering complete user workflows to ensure business-critical paths work correctly from entry to outcome.
version: 1.1.0
category: Testing & QA
tags: [e2e-testing, workflow-validation, regression, ci-cd, user-journeys]
priority: High

depends_on: []
flags_skills: [feature-validation, test-interpretation-failure-diagnosis, ci-cd-pipeline-automation]

inputs: [feature-specifications, acceptance-criteria, user-journey-maps, system-architecture]
outputs: [e2e-test-scripts, coverage-reports, workflow-improvement-recommendations]

rules_applied:
  - TQ-1  # Test Coverage Requirement — business-critical workflows must have E2E coverage
  - TQ-4  # Test Quality Rule — tests must reflect real user journeys, not implementation paths
  - TQ-3  # Regression Prevention — E2E suite must run before every production release
  - DD-1  # CI/CD Enforcement — E2E tests must be integrated as a pipeline quality gate

documents_needed: [feature-specifications, user-journey-maps, system-architecture-diagram, ci-pipeline-config]

execution_context: Invoked when implementing new critical user workflows, before production release, or when regressions are suspected in workflow coverage.

---
```

---

# Skill: End-to-End Test Creation

---

## Purpose

**What this skill does:**
Designs and implements automated end-to-end tests that verify complete user workflows across the full system stack — from the user-facing entry point through all intermediate layers to the final business outcome. It ensures critical paths are covered, test scripts are resilient to minor implementation changes, and the suite runs reliably inside the CI/CD pipeline.

End-to-end tests are the final safety net before production. They catch failures that unit and integration tests miss by exercising real workflows end-to-end. Missing coverage on critical paths (checkout, login, onboarding) exposes the business to undetected regressions that reach users, with direct impact on revenue, trust, and compliance.

Properly designed E2E tests document intended system behavior at the workflow level, serve as living acceptance criteria, and provide regression coverage that survives refactors. Abstracting tests away from implementation details reduces maintenance burden and false failures.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new user-facing feature or workflow is being implemented and acceptance criteria exist
* A business-critical workflow (checkout, login, registration, payment, data export) has no automated E2E coverage
* A production release is approaching and E2E regression coverage needs to be validated
* A recurring production incident suggests an existing workflow is not covered by tests
* E2E tests are absent from the CI/CD pipeline as a quality gate
* A major refactor has invalidated or broken existing E2E tests that need to be rewritten

### Do NOT use this skill for:

* Unit-level testing of individual functions or classes — use `test-creation-strategy`
* Integration testing between two services without end-user workflow context — use `contract-api-testing`
* Performance or load validation — use `load-test-creation`
* Diagnosing why an existing test is failing — use `test-interpretation-failure-diagnosis`

**Execution Context Details:**
This skill runs after business requirements and user journey maps are available. It precedes production deployment as a quality gate. It coordinates with `test-environment-management` to ensure a suitable isolated environment exists, and may flag `feature-validation` if the workflow being tested does not match the stated business requirements.

---

## Inputs

**Required inputs:**

* **Feature specifications** — Acceptance criteria and expected behavior for the workflow under test. Used to determine what constitutes a correct outcome.
* **User journey maps** — Documented step-by-step paths users take through the system, including happy path and critical edge cases.
* **System architecture** — Overview of integration points (databases, APIs, third-party services) that the E2E test must traverse or mock.

**Optional inputs:**

* **Existing test suite inventory** — Helps avoid duplicating coverage that already exists at unit or integration level.
* **Historical failure data** — Indicates which workflow areas have been flaky or regression-prone, informing priority.

**Documents/Context needed:**

* **CI pipeline config** — Required to integrate the test suite as a pipeline gate.

---

## Outputs

**Primary outputs:**

* **E2E test scripts** — Automated test code covering each critical user workflow from entry to outcome, structured for reliable execution in the CI/CD pipeline.
* **Coverage report mapped to user journeys** — Documents which journeys are covered, partially covered, or missing; aligned to business criticality.
* **Workflow improvement recommendations** — Issues surfaced during test design (ambiguous flows, missing states, unclear acceptance criteria) that should be addressed in the product or implementation.

**Output format:**

* Test scripts in the project's established E2E framework (Playwright, Cypress, Selenium, or equivalent).
* Coverage report as structured markdown with a journey-to-test mapping table.
* Recommendations as a prioritized list with business impact noted per item.

**Skill flags (if applicable):**

* Flag **feature-validation** when the workflow being tested does not match stated business requirements — the acceptance criteria or journey map may need revision before tests can be finalized.
* Flag **test-interpretation-failure-diagnosis** when newly created tests fail on the first run for non-obvious reasons suggesting environment or configuration issues.

---

## Preconditions

**Conditions that must be met before execution:**

* Acceptance criteria or user journey maps must be available — tests cannot be authored without a definition of correct behavior.
* A test environment must be available or provisioned — reference `test-environment-management`.
* The system under test must be deployable to the test environment in a stable state.

**Validation checks:**

* [ ] Business-critical workflows have been identified and prioritized
* [ ] Acceptance criteria are specific and testable (not vague or subjective)
* [ ] Test environment is isolated from production data
* [ ] CI/CD pipeline has a slot for E2E gate integration

---

## Step-by-Step Execution Procedure

### Step 1: Identify and Prioritize Workflows

**Questions to answer:**
- Which workflows are business-critical and carry the highest risk if broken?
- What is the existing E2E coverage gap — which journeys have no automated coverage?
- What is the realistic execution time budget for this suite in CI?

**Actions:**
- [ ] List all user-facing workflows from the journey maps
- [ ] Rank by business criticality and regression risk
- [ ] Identify coverage gaps against existing test inventory
- [ ] Select workflows to cover in this skill execution, scoped to time budget

**Red flags / Warning signs:**
- No user journey maps exist — workflows are ambiguous and tests will be unreliable
- Too many workflows selected, threatening CI execution time budget
- Workflows depend on production-only data or third-party services with no mock strategy

**Decision points:**
- If journey maps are missing or incomplete, flag `feature-validation` and request clarification before proceeding
- If coverage scope exceeds time budget, apply business-criticality ranking and defer lower-priority journeys

---

### Step 2: Design Test Scenarios

**Questions to answer:**
- What is the happy path for each selected workflow?
- What are the critical failure and edge case paths that must also be covered?
- What level of abstraction protects the test from UI or implementation churn?

**Actions:**
- [ ] Define happy path scenario for each workflow
- [ ] Identify critical edge cases (boundary inputs, error states, partial completion)
- [ ] Design page objects or abstraction layers to decouple tests from implementation details
- [ ] Document which third-party calls will be mocked vs real

**Red flags / Warning signs:**
- Tests are tightly coupled to CSS selectors or DOM structure — fragile and high-maintenance
- Edge cases are not covered, leaving error paths untested
- No decision on mocking strategy for external dependencies

**Decision points:**
- If external dependencies are non-deterministic in test environment, mock them and document the gap
- If acceptance criteria are ambiguous for an edge case, flag `feature-validation` for clarification

---

### Step 3: Implement Test Scripts

**Questions to answer:**
- Does the implementation follow the project's established E2E framework and conventions?
- Are tests deterministic — do they produce the same result on every run?
- Are waits and async operations handled correctly to prevent flakiness?

**Actions:**
- [ ] Implement test scripts per scenario defined in Step 2
- [ ] Use page objects or equivalent abstraction layer
- [ ] Replace all hard-coded waits with event-driven or condition-based waits
- [ ] Ensure each test cleans up state and is independently runnable (no test ordering dependency)

**Red flags / Warning signs:**
- `sleep()` or fixed-duration waits instead of condition-based waits — major flakiness source
- Tests that depend on execution order — indicates hidden shared state
- No teardown — tests leave environment in modified state for subsequent runs

**Decision points:**
- If an existing shared state pattern is discovered, escalate to test environment management review
- If implementation diverges from stated acceptance criteria, flag `feature-validation`

---

### Step 4: Integrate into CI/CD Pipeline

**Questions to answer:**
- Is the E2E suite configured to run as a mandatory gate before production deployment?
- Are test results surfaced in the pipeline dashboard with clear pass/fail status?
- What is the expected execution time and is it within the pipeline budget?

**Actions:**
- [ ] Add E2E suite to pipeline configuration at the correct stage (after integration tests, before deployment)
- [ ] Configure pipeline to block deployment on E2E failure
- [ ] Set up result reporting so failures surface with context (screenshots, logs, trace)
- [ ] Validate suite execution time is within acceptable CI budget

**Red flags / Warning signs:**
- E2E tests configured as optional or informational — not enforced as a gate
- No artifact capture on failure (no screenshots, no logs) — failures are undiagnosable
- Suite too slow for CI — developers will disable or bypass it

**Decision points:**
- If pipeline budget is exceeded, apply prioritization and split into fast and full tiers
- If pipeline does not yet have an E2E stage, surface this as a required configuration change

---

### Final Step: Generate E2E Test Creation Report

**Report/Output structure:**

```markdown
## E2E Test Creation Report

**Target Workflow(s):** [List of workflows covered]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Workflow Coverage Summary

| Workflow | Scenarios Covered | Happy Path | Edge Cases | CI Integrated |
|---|---|---|---|---|
| [Workflow 1] | N | ✅ | ✅ / ⚠️ | ✅ |

### Coverage Gaps
[Workflows identified but deferred, with priority and reason]

### Workflow Improvement Recommendations
[Issues surfaced during test design requiring product or implementation attention]

### Skills Flagged for Follow-up
- **[Skill]**: [Reason with specific context and evidence]

### Overall Assessment
**Decision:**
- ✅ PASS: All selected workflows covered, suite integrated in CI, no critical gaps
- ❌ FAIL: Business-critical workflow has no coverage or CI integration missing
- ⚠️ NEEDS REVIEW: Coverage present but edge cases missing or acceptance criteria unclear

### Required Actions
- [ ] [Action 1]
- [ ] [Action 2]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Identify all business-critical workflows that require E2E coverage and prioritize by risk
2. Design deterministic, resilient test scenarios covering happy paths and critical edge cases
3. Implement test scripts using project-established framework with proper abstraction and no flaky wait patterns
4. Ensure tests are independent — no shared state, no execution-order dependencies
5. Integrate the suite into the CI/CD pipeline as a mandatory quality gate before deployment

**Quality criteria:**

* Every business-critical workflow identified in the journey map has at least one E2E test
* All tests pass consistently across ≥5 consecutive runs (flakiness gate)
* Suite is integrated in CI as a blocking gate — not optional
* Test scripts are decoupled from implementation details through appropriate abstraction

---

## Constraints (Rules Applied)

* **TQ-1: Test Coverage Requirement** — Business-critical workflows must have E2E coverage before production release; coverage is measured against the journey map, not code lines.
* **TQ-4: Test Quality Rule** — E2E tests must reflect actual user journeys and business outcomes, not implementation details; abstract at the user-intent level.
* **TQ-3: Regression Prevention** — The E2E suite must run before every production release; a suite not integrated in CI provides no regression protection.
* **DD-1: CI/CD Enforcement** — E2E tests must be a blocking gate — not optional. Failures block deployment; results must be visible in the pipeline dashboard.

---

## Tradeoff Handling

### Tradeoff 1: Coverage Breadth vs Execution Time

E2E tests are slow. Comprehensive coverage of every workflow would make CI impractically slow.

**Resolution:** Apply business-criticality ranking — cover P0 (checkout, login, payment) in fast tier; defer P1 workflows to full suite; log deferred workflows via DT-1. If prioritization is unclear, escalate for business priority decision.

### Tradeoff 2: Test Stability vs Realism

Tests tied to real UI and real data are realistic but fragile.

**Resolution:** Apply abstraction (page objects, data factories) to decouple from implementation; mock external dependencies and document gap in report; log mocking decisions via DT-1. If mocking is not feasible, escalate to `test-environment-management`.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Missing or Incomplete User Journey Maps

**Trigger:** Workflow to be tested has no documented acceptance criteria or journey map, making test design ambiguous.

**Action:**
- Block test implementation
- Flag `feature-validation` to clarify the workflow definition
- Document the gap in the test creation report under "Required Actions"

**Escalation format:**
```
⚠️ CLARIFICATION NEEDED

Issue: User journey for [workflow name] is not documented or acceptance criteria are ambiguous.
Context: Cannot author a reliable E2E test without a testable definition of correct behavior.
Options:
  A. Pause test creation for this workflow until spec is clarified.
  B. Implement a provisional test against assumed behavior, marked as DRAFT pending spec review.
Recommendation: Option A — provisional tests against unconfirmed behavior create false confidence.
Question: Can the product owner provide or confirm the acceptance criteria for [workflow]?
```

---

### Escalation Scenario 2: Acceptance Criteria Mismatch

**Trigger:** During test implementation, observed system behavior does not match what the acceptance criteria state.

**Action:**
- Flag `feature-validation` with specific mismatch details
- Do not adjust acceptance criteria unilaterally — escalate for resolution
- Mark affected test scenarios as BLOCKED in the report

---

### Escalation Scenario 3: Tests Fail on First Run for Non-Obvious Reasons

**Trigger:** Newly created tests fail consistently but the failure appears to be infrastructure or configuration related, not a workflow defect.

**Action:**
- Flag `test-interpretation-failure-diagnosis` with failure logs and context
- Do not mark workflow as failing until environment cause is ruled out

---

### Escalation Scenario 4: E2E Suite Not Integrated in CI Pipeline

**Trigger:** E2E tests are not configured as a mandatory quality gate in the CI pipeline before production deployment.

**Action:**
- Surface the missing gate as a required action
- Flag ci-cd-pipeline-automation to add the E2E gate before production deployment
- Block completion until gate is confirmed present in pipeline configuration

---

### When to halt execution:

* No user journey maps or acceptance criteria are available after requesting them — tests cannot be authored
* Test environment is unavailable or production data is present without anonymization — do not proceed
* CI pipeline integration is blocked by infrastructure issues outside this skill's scope

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

This skill runs after requirements are defined and before production release. It depends on `test-environment-management` for a stable, isolated test environment. It operates alongside `test-data-management` for seeding test data. It flags upstream skills (`feature-validation`) when workflow definitions are unclear and flags `test-interpretation-failure-diagnosis` when failures require root cause analysis.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Workflow does not match acceptance criteria | feature-validation | Spec and implementation are misaligned; product decision required |
| Tests fail for environment/config reasons | test-interpretation-failure-diagnosis | Root cause analysis needed before results can be trusted |
| E2E suite missing from CI gate | ci-cd-pipeline-automation | Add mandatory E2E quality gate before production deployment |

---

## Related Skills

**Skills this skill depends on:**

* **test-environment-management** — Provides the isolated environment where E2E tests execute. If unavailable, this skill cannot run.
* **test-data-management** — Provides deterministic test data seeding. Without reliable data, E2E tests produce non-deterministic results.

**Skills this skill cooperates with:**

* **ci-cd-pipeline-automation** — E2E test integration into the pipeline is coordinated with this skill.
* **regression-test-suite-management** — The E2E tests created here become part of the regression suite managed by that skill.

**Skills this skill may invoke/flag:**

* **feature-validation** — When workflow under test does not match business requirements.
* **test-interpretation-failure-diagnosis** — When newly created tests fail for non-obvious reasons.

---

## Governance Hooks

* [ ] Log all tradeoff decisions (coverage deferrals, mocking choices) via DT-1
* [ ] Explain risks before recommending reducing E2E coverage scope
* [ ] Respect confirmation gate — do not proceed when acceptance criteria are absent
* [ ] Do not use production data in test environments without confirmed anonymization (CL-3)
* [ ] Block CI deployment stage if E2E gate is missing — surface as a required action
* [ ] Validate suite stability (≥5 consecutive passes) before marking coverage as complete

**Audit trail requirements:**

* Log which workflows are covered vs deferred, with business-criticality rationale
* Document all mocking decisions and their accuracy limitations
* Record acceptance criteria version used when tests were authored

---

## Example Use Cases

### Example 1: Complete Checkout Workflow Automation

**Scenario:** An e-commerce platform adds a new payment step to checkout. No E2E test exists for the full checkout flow.

**Inputs provided:**
- Journey map: add to cart → apply coupon → enter payment → confirm → verify order record
- Acceptance criteria: order must appear in order management system within 5 seconds of confirmation

**Execution steps:**
1. Map all checkout steps from journey; identify external payment gateway as third-party dependency
2. Design mock for payment gateway; implement page objects for cart, checkout, and confirmation pages
3. Implement happy path + edge cases: invalid card, coupon expiry, session timeout mid-checkout
4. Integrate as blocking gate in CI before deployment stage; capture screenshot on failure

**Result:** ✅ PASS — 6 scenarios implemented, all deterministic, integrated as CI gate
**Skills flagged:** None
**Output produced:**
```
Workflows covered: Checkout (6 scenarios)
Edge cases: invalid payment, expired coupon, mid-flow session timeout
Mocking: Payment gateway mocked (gap: real payment failure paths not exercised)
CI gate: ✅ Configured as blocking pre-deploy stage
```

---

### Example 2: Acceptance Criteria Mismatch During Test Design

**Scenario:** Implementing E2E tests for user registration. Journey map states "email verified before first login allowed." System currently allows login before verification.

**Inputs provided:**
- Journey map: register → verify email → login
- Actual system behavior: login permitted before verification

**Execution steps:**
1. Implement happy-path test per journey map — test fails because login succeeds before email verification
2. Identify mismatch: acceptance criteria require verification gate, system does not enforce it
3. Flag `feature-validation` with specific mismatch; mark registration E2E scenarios as BLOCKED

**Result:** ⚠️ NEEDS REVIEW — workflow spec and implementation are misaligned; test blocked pending resolution
**Skills flagged:** `feature-validation`

---

### Example 3: Adding E2E Regression Coverage After Production Incident

**Scenario:** A production incident reveals the password reset flow breaks when a user has multiple unverified email addresses. No E2E test existed.

**Inputs provided:**
- Incident report detailing the failure path
- Current password reset journey map (happy path only)

**Execution steps:**
1. Extend journey map with edge case: user with multiple emails (document in coverage report)
2. Implement E2E test targeting the specific failure path from the incident
3. Verify test fails against the pre-fix state, passes post-fix (confirms test validity)
4. Add to regression suite via `regression-test-suite-management` flag

**Result:** ✅ PASS — regression test created and validated against known failure
**Skills flagged:** `regression-test-suite-management` for suite inclusion

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Tests coupled to CSS selectors or DOM structure**
Selectors like `div.checkout-button:nth-child(3)` break on any UI refactor.
✅ Use semantic locators (`data-testid`, ARIA roles, accessible labels) that survive UI changes.

❌ **Anti-pattern 2: Fixed-duration sleeps as waits**
`sleep(3000)` causes both flakiness (too short on slow CI) and unnecessary slowness (too long normally).
✅ Use event-driven waits: wait for element visibility, network idle, or assertion condition.

❌ **Anti-pattern 3: Tests with shared mutable state**
Test A creates a user, Test B expects that user to exist. If tests run in isolation or order changes, B fails.
✅ Each test must own its setup and teardown — fully independent, order-agnostic.

❌ **Anti-pattern 4: E2E tests for unit-level concerns**
Using E2E tests to validate business logic in a single function is expensive and slow.
✅ Reserve E2E for end-to-end workflow validation. Delegate unit-level assertions to unit tests.

❌ **Anti-pattern 5: No failure artifacts**
A failed CI E2E test with no screenshot, log, or trace is undiagnosable.
✅ Always capture screenshot, HAR/network log, and test trace on failure.

❌ **Anti-pattern 6: E2E suite configured as optional in CI**
Optional tests are routinely skipped under delivery pressure, providing no protection.
✅ Configure E2E suite as a blocking pipeline gate — not informational.

❌ **Anti-pattern 7: Testing implementation paths, not user journeys**
"Test that the `OrderService.createOrder()` method is called" is a unit concern, not a user journey.
✅ Test from the user's perspective: initiate action → verify observable business outcome.

❌ **Anti-pattern 8: Covering every edge case with E2E tests**
E2E tests are expensive. Using them for every boundary condition makes suites slow and brittle.
✅ Cover critical happy path and the most impactful failure paths in E2E. Cover exhaustive edge cases in unit tests.

❌ **Anti-pattern 9: No coverage mapping to user journeys**
A test suite with 200 tests but no map to business journeys creates false confidence — critical paths may still be uncovered.
✅ Maintain a journey-to-test mapping table updated with every suite change.

❌ **Anti-pattern 10: Tests written without consulting acceptance criteria**
Tests written from code inspection rather than business requirements test implementation, not behavior.
✅ Author every test scenario from acceptance criteria first; verify against system behavior second.

---

## Non-Goals

* ❌ **Unit or integration testing** — not in scope; handled by `test-creation-strategy` and `contract-api-testing`
* ❌ **Load or performance testing** — not in scope; handled by `load-test-creation` and `stress-test-creation`
* ❌ **Test failure root cause analysis** — not in scope; handled by `test-interpretation-failure-diagnosis`
* ❌ **Regression suite curation** — not in scope; handled by `regression-test-suite-management`
* ❌ **Environment provisioning** — not in scope; coordinated with `test-environment-management`

**Boundary clarifications:**

* This skill creates E2E tests; it does not maintain the full regression suite — that is `regression-test-suite-management`.
* This skill flags environment problems but does not resolve them — escalate to `test-environment-management`.
* This skill does not rewrite existing E2E tests unless they are broken by a workflow change — that is maintenance work initiated by `code-maintenance`.

---

## Notes for LLM Implementation

1. **Always start from the journey map, not the code.** Tests authored from code inspection test implementation; tests authored from journey maps test behavior. The correct starting point is always the user journey.
2. **Prioritize determinism over coverage breadth.** A deterministic test covering 5 workflows is more valuable than a flaky test touching 20. Eliminate all flakiness sources before expanding scope.
3. **Abstraction level matters.** Test at the level where business meaning is stable. Workflows change less often than DOM structure. Always abstract one level above implementation details.
4. **Block on missing acceptance criteria — never assume.** If the expected outcome of a workflow is not documented, do not invent it. Escalate and block until clarified.
5. **CI integration is non-negotiable.** A test suite not integrated in CI provides zero regression protection. Never deliver E2E tests without confirming pipeline integration.

6. Use the structured report template with journey-to-test mapping table; mark gaps with ❌ or ⚠️ — never bury in prose; provide actionable next steps with owning skill per item.
7. Be systematic — work through journeys in priority order; be conservative about marking coverage complete — a flaky test is not reliable coverage.

---
