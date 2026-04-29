---

```yaml
---
name: test_environment_management
description: Provisions, maintains, and tears down isolated test environments ensuring tests run in consistent, reproducible conditions without polluting production or shared infrastructure.
version: 1.1.0
category: Testing & QA
tags: [test-environments, isolation, ci-cd, reproducibility, infrastructure]
priority: High

depends_on: []
flags_skills: [ci-cd-pipeline-automation, infrastructure-as-code, test-data-management]

inputs: [test-suite-requirements, infrastructure-dependencies, ci-cd-context, environment-variable-configs]
outputs: [provisioned-isolated-environments, teardown-reset-scripts, configuration-validation-reports]

rules_applied:
  - DD-1  # CI/CD Enforcement — environments must be reproducible within CI/CD pipeline
  - MF-1  # Feature Consistency — environment state must not carry over between test runs
  - DA-5  # Avoid Overengineering — prefer lightweight containers over full replicas where adequate
  - CL-3  # Data Privacy — test environments must not contain real PII without anonymization

documents_needed: [infrastructure-topology, ci-pipeline-config, service-dependency-map, environment-variable-manifest]

execution_context: Invoked before any test suite requiring an isolated environment; also triggered when environment drift, slow provisioning, or state leakage is detected.

---
```

---

# Skill: Test Environment Management

---

## Purpose

**What this skill does:**
Provisions isolated, reproducible test environments for each test run, manages the lifecycle of service dependencies (real or mocked), enforces environment parity with production for runtime-critical configuration, and automates environment teardown and reset. It ensures tests execute in a known, clean state every time — eliminating environment-induced non-determinism.

Test results are only trustworthy when the environment is controlled. Environment-induced flakiness erodes confidence in the test suite, causes false failures that slow delivery, and masks real bugs behind noise. Proper environment management ensures test results are reliable signals — not environmental accidents.

Isolated environments prevent test interference, enable parallel test execution, and make CI/CD pipelines reproducible. Automating lifecycle (provision, run, teardown) removes the manual toil of environment management and eliminates environment drift — the gradual divergence from production that causes tests to pass locally but fail in production.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A test suite (E2E, load, stress, integration) requires an isolated environment before execution
* Test results are non-deterministic and environment state leakage is a suspected cause
* CI pipeline environment provisioning is slow, failing, or inconsistent
* A new service dependency is added and the test environment requires updating
* Test environment drift from production is suspected (tests pass locally, fail in CI)
* Production data is present or suspected in a test environment — must be remediated

### Do NOT use this skill for:

* Provisioning production infrastructure — use `infrastructure-as-code`
* Managing CI/CD pipeline configuration beyond environment provisioning — use `ci-cd-pipeline-automation`
* Generating or seeding test data — use `test-data-management`
* Diagnosing test failures that are not environment-related — use `test-interpretation-failure-diagnosis`

**Execution Context Details:**
This skill runs before test suites that require isolation — it is a prerequisite for `e2e-test-creation`, `load-test-creation`, and `stress-test-creation`. It flags `ci-cd-pipeline-automation` when environment provisioning integration into the pipeline needs updating, and `infrastructure-as-code` when persistent environment provisioning issues require infrastructure-level solutions.

---

## Inputs

**Required inputs:**

* **Test suite requirements** — What services, databases, caches, and external dependencies the test suite needs. Determines what the environment must provision.
* **Infrastructure dependencies** — Specific versions, configuration, and topology of services the environment must include or mock.
* **CI/CD pipeline context** — Whether the environment must provision and tear down within a CI job, or is a persistent environment managed separately.

**Optional inputs:**

* **Environment variable configurations** — Service-specific configuration that must match production values (feature flags, timeouts, connection strings) for valid test results.
* **Production parity requirements** — Explicit list of runtime-critical configuration points that must match production; used to validate parity before test runs.

**Documents/Context needed:**

* **Infrastructure topology** — Defines the production environment the test environment must replicate at the relevant fidelity level.
* **CI pipeline config** — Required to integrate environment lifecycle into the pipeline (provision at job start, teardown at job end).
* **Service dependency map** — Lists all services the test suite invokes, so the environment provisions or mocks each correctly.

---

## Outputs

**Primary outputs:**

* **Provisioned isolated test environment** — A running, clean environment meeting the test suite's requirements with all dependencies available, no state from previous runs.
* **Teardown and reset scripts** — Automated scripts that restore the environment to its known-clean state between test runs (or at job end for ephemeral environments).
* **Configuration validation report** — Documentation of environment parity with production for runtime-critical configuration, including any known gaps.

**Output format:**

* Environment provisioned as Docker Compose stack, ephemeral Kubernetes namespace, or equivalent, depending on test tier and CI platform.
* Teardown scripts as idempotent shell or CI step definitions.
* Validation report as a structured checklist: service versions, configuration values, mocking decisions, known parity gaps.

**Skill flags (if applicable):**

* Flag **ci-cd-pipeline-automation** when environment provisioning needs to be integrated into or restructured within the CI pipeline — not a simple configuration change.
* Flag **infrastructure-as-code** when persistent environment provisioning issues require infrastructure-level definition (Terraform, Helm, etc.) rather than ad-hoc scripts.
* Flag **test-data-management** when PII is detected in the test environment and data anonymization is required before test execution can resume.

---

## Preconditions

**Conditions that must be met before execution:**

* Test suite requirements must be defined — the environment cannot be provisioned without knowing what services it must include.
* Environment must have no access path to production systems or production data.
* Environment isolation must be verifiable — not assumed.

**Validation checks:**

* [ ] All required service dependencies identified and versioned
* [ ] No production data present; anonymization confirmed if production snapshots are used
* [ ] Environment has no network access to production systems
* [ ] Teardown procedure defined and tested before first use

---

## Step-by-Step Execution Procedure

### Step 1: Identify Environment Requirements

**Questions to answer:**
- What services, databases, queues, and caches does the test suite require?
- Which dependencies must be real services vs safe to mock?
- What production configuration values must be replicated for valid test results?
- What is the required isolation level: ephemeral per-run, per-branch, or persistent?

**Actions:**
- [ ] List all service dependencies from the test suite and their version requirements
- [ ] Classify each dependency: real service required vs mock acceptable
- [ ] Identify runtime-critical configuration points that must match production
- [ ] Choose isolation strategy based on test tier (ephemeral container per run for E2E; persistent namespace for load tests)

**Red flags / Warning signs:**
- Dependencies not versioned — environment may diverge silently across runs
- "It should be fine with production config" — configuration drift is a primary source of environment-induced failures
- No clarity on which dependencies can be mocked — ambiguity leads to either over-engineering or under-isolation

**Decision points:**
- If a real service is required but would introduce production access risk, mock it and document the fidelity gap
- If isolation strategy conflicts with CI speed requirements, apply DA-5 (avoid overengineering) — prefer the lightest approach that gives the required isolation

---

### Step 2: Design Environment Architecture

**Questions to answer:**
- Is the environment reproducible from code (no manual setup steps)?
- Can the environment be provisioned and torn down within the CI job time budget?
- Are mocking decisions documented with their fidelity gaps?

**Actions:**
- [ ] Define environment as code (Docker Compose, Helm chart, Terraform config, or equivalent)
- [ ] Specify all service versions, port mappings, and health check endpoints
- [ ] Define mocks for dependencies that cannot be safely included (third-party APIs, payment gateways)
- [ ] Document mocking decisions and their fidelity gaps in the configuration validation report
- [ ] Define health check sequence: environment is not "ready" until all services pass health checks

**Red flags / Warning signs:**
- Manual setup steps — environment is not reproducible
- No health checks — tests start before services are ready, producing flaky results
- Mocking decisions not documented — fidelity gaps are invisible to the test consumer

**Decision points:**
- If environment-as-code does not exist, create it before any test suite is run — do not accept "it works on my machine" as a substitute
- If a service is slow to start and threatens CI time budget, implement a fast health check rather than a fixed sleep

---

### Step 3: Implement Provisioning and Teardown Automation

**Questions to answer:**
- Is provisioning idempotent — can it be run repeatedly without accumulating state?
- Does teardown guarantee a clean slate for the next run?
- Are environment variables injected securely — not hardcoded or logged?

**Actions:**
- [ ] Implement provisioning script/config as idempotent operation (docker-compose up --force-recreate, namespace delete+recreate, etc.)
- [ ] Implement teardown as a guaranteed step — runs even on test failure (CI post-step or finally block)
- [ ] Inject environment variables via CI secrets or environment variable store — never hardcode
- [ ] Validate data privacy: confirm no PII present; anonymize any production snapshot data before use
- [ ] Test teardown independently: run it against a clean environment and verify the result is a known-clean state

**Red flags / Warning signs:**
- Teardown is only run on success — failed test runs leave dirty environments for the next run
- Environment variables hardcoded in provisioning scripts — security and reproducibility risk
- PII presence unverified — compliance violation risk

**Decision points:**
- If teardown cannot be made guaranteed (e.g., CI platform limitation), use ephemeral environments that are destroyed automatically at job end
- If PII is suspected in a data source, coordinate with `test-data-management` for anonymization before proceeding

---

### Step 4: Validate Parity and Integration

**Questions to answer:**
- Does the environment match production for all runtime-critical configuration points?
- Are environment drift sources identified and documented?
- Is the environment successfully integrated into the CI pipeline as a provisioning step?

**Actions:**
- [ ] Run configuration validation checklist against production for runtime-critical values
- [ ] Document all known parity gaps (mocked services, configuration deltas, version mismatches)
- [ ] Integrate provisioning into CI pipeline: runs before test step, teardown runs after (or via post-step)
- [ ] Validate end-to-end: provision → run smoke test → teardown → verify clean state

**Red flags / Warning signs:**
- Configuration validation skipped — environment may silently diverge from production
- Parity gaps undocumented — test consumers cannot assess validity of results
- CI integration not tested — provisioning may fail silently on first real CI run

**Decision points:**
- If a parity gap is runtime-critical (e.g., auth configuration mismatch), resolve before allowing test suite to run
- If CI integration requires pipeline restructuring beyond environment provisioning, flag `ci-cd-pipeline-automation`

---

### Final Step: Generate Environment Validation Report

**Report/Output structure:**

```markdown
## Test Environment Validation Report

**Environment:** [Name/ID]
**Date:** [YYYY-MM-DD]
**Test Suite:** [Which test suite this environment serves]
**Status:** ✅ READY / ❌ NOT READY / ⚠️ READY WITH GAPS

### Service Inventory

| Service | Version | Mode | Health Check | Status |
|---|---|---|---|---|
| [Postgres] | [15.2] | [Real] | [/health] | ✅ |
| [Payment API] | [N/A] | [Mocked] | [N/A] | ✅ (gap noted) |

### Configuration Parity

| Config Point | Test Value | Production Value | Match | Notes |
|---|---|---|---|---|
| [DB pool size] | [20] | [50] | ⚠️ | [Intentional — load not representative] |

### Mocking Decisions and Fidelity Gaps
[List of mocked dependencies and what failure modes they cannot exercise]

### Data Privacy Confirmation
- [ ] No PII present in environment
- [ ] Production data snapshots anonymized (if used)

### Skills Flagged
- **[Skill]**: [Reason]

### Overall Assessment
- ✅ READY: All services healthy, isolation confirmed, no PII, parity gaps documented
- ❌ NOT READY: Isolation not confirmed, PII present, or runtime-critical parity gap unresolved
- ⚠️ READY WITH GAPS: Known parity gaps exist but are documented and accepted

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Provision isolated, reproducible environments from code — no manual setup steps
2. Enforce environment isolation: no access to production systems or production data
3. Guarantee teardown runs even on test failure — no dirty environments carried forward
4. Validate and document parity with production for runtime-critical configuration
5. Integrate environment lifecycle into the CI/CD pipeline as automated provisioning steps

**Quality criteria:**

* Environment provisions from code with no manual intervention required
* Teardown is guaranteed — runs on failure as well as success
* All mocking decisions and parity gaps are documented in the validation report
* No PII present in any test environment without confirmed anonymization

---

## Constraints (Rules Applied)

* **DD-1: CI/CD Enforcement** — Environments must be provisioned and torn down as part of the CI/CD pipeline; environments requiring manual setup are not reproducible.
* **MF-1: Feature Consistency** — Environment state must not carry over between runs; each run starts in a known-clean state. Dirty environments are a primary source of non-deterministic results.
* **DA-5: Avoid Overengineering** — Prefer the lightest isolation approach meeting the test tier's requirements; match environment complexity to isolation needs, not production fidelity aspirations.
* **CL-3: Data Privacy** — Test environments must not contain real PII without anonymization. This is a compliance requirement; any production data must be anonymized before import.

---

## Tradeoff Handling

### Tradeoff 1: Isolation Fidelity vs Provisioning Speed

Full parity increases validity but can make CI provisioning take minutes.

**Resolution:** Apply DA-5 — choose lightest isolation adequate for the test tier (E2E: Docker Compose with real DB + mocked third-party APIs; load: representative capacity); document parity delta via DT-1. If speed vs fidelity requires business input, escalate.

### Tradeoff 2: Real Service vs Mock

Real services give higher fidelity but may introduce rate limits, costs, or non-determinism.

**Resolution:** Mock the dependency; document what failure modes the mock cannot exercise (auth, payment, messaging paths); log mocking decision and gap via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: State Leakage Between Runs

**Trigger:** Test results vary between runs in ways that correlate with execution order, suggesting state from a previous run is persisting.

**Action:**
- Investigate teardown completeness — verify teardown script actually resets state
- Check database truncation/restoration, cache flushes, file system cleanup
- Escalate to `test-interpretation-failure-diagnosis` if state source is unclear
- Do not accept non-determinism as normal — escalate until root cause is found

---

### Escalation Scenario 2: PII Detected in Test Environment

**Trigger:** Real production PII found in a test environment database, file system, or log output.

**Action:**
- Halt all test execution in that environment immediately
- Flag `test-data-management` to anonymize the data
- Assess compliance exposure — this is a CL-3 violation
- Do not resume test execution until environment is confirmed clean

---

### Escalation Scenario 3: CI Provisioning Failure

**Trigger:** Environment provisioning step fails in the CI pipeline, blocking the test suite.

**Action:**
- Investigate failure cause: network, image availability, resource limits, configuration error
- Flag `ci-cd-pipeline-automation` if the failure requires pipeline restructuring
- Flag `infrastructure-as-code` if the failure requires persistent infrastructure changes
- Do not manually provision as a workaround — fix the automation

---

### When to halt execution:

* PII detected in test environment — halt all test execution immediately
* Environment isolation cannot be confirmed — halt; do not assume safety
* Teardown failure leaves environment in unknown state — halt subsequent runs until reset is confirmed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

This skill is a prerequisite for `e2e-test-creation`, `load-test-creation`, and `stress-test-creation`. It runs before test suites that require isolation and ensures the environment is valid before tests begin. It flags `ci-cd-pipeline-automation` for pipeline-level provisioning integration issues and `infrastructure-as-code` for persistent infrastructure needs.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| CI provisioning needs pipeline restructuring | ci-cd-pipeline-automation | Beyond environment config — pipeline design change required |
| Persistent environment requires IaC definition | infrastructure-as-code | Ad-hoc scripts insufficient for persistent environment needs |
| PII detected in test environment | test-data-management | Anonymization required before test execution can resume |

---

## Related Skills

**Skills this skill depends on:**

* None — this is a foundational skill invoked by other test skills.

**Skills this skill cooperates with:**

* **test-data-management** — Coordinates on data seeding, anonymization, and reset. Data management and environment management are complementary; neither replaces the other.
* **e2e-test-creation, load-test-creation, stress-test-creation** — All depend on this skill for isolation before test execution.

**Skills this skill may invoke/flag:**

* **ci-cd-pipeline-automation** — When provisioning integration requires pipeline restructuring.
* **infrastructure-as-code** — When persistent environment provisioning requires IaC-level definition.

---

## Governance Hooks

* [ ] Confirm environment isolation before any test execution — never assume
* [ ] Confirm no PII in environment before any test run — CL-3 is non-negotiable
* [ ] Guarantee teardown runs on failure as well as success
* [ ] Document all mocking decisions and parity gaps in validation report
* [ ] Never accept manual setup as a substitute for code-defined provisioning
* [ ] Log fidelity gaps and their result validity implications via DT-1

**Audit trail requirements:**

* Per-run environment validation report with service inventory and parity checklist
* PII confirmation record per environment instance
* Mocking decision log with fidelity gap documentation
* Teardown confirmation per run (especially on failure paths)

---

## Example Use Cases

### Example 1: Docker Compose E2E Environment

**Scenario:** An E2E test suite requires a real Postgres database and a mocked third-party payment API.

**Inputs provided:**
- Test suite: E2E checkout workflow tests
- Dependencies: Postgres 15.2, Payment Gateway API (third-party, cannot load test safely)

**Execution steps:**
1. Define Docker Compose with Postgres 15.2 service and a WireMock container serving payment API responses
2. Add health checks: Postgres readiness probe; WireMock stub load confirmation
3. Implement teardown: `docker-compose down -v` (volumes purged — clean state guaranteed)
4. Integrate as CI pre-step; teardown as post-step (runs on failure)
5. Document: payment API mocked — real payment failure paths not exercised

**Result:** ✅ READY — isolated, reproducible, teardown guaranteed, parity gap documented

---

### Example 2: PII Detected — Halt and Remediate

**Scenario:** During environment audit, real customer email addresses found in the test database (imported from a production snapshot without anonymization).

**Execution steps:**
1. Halt all test execution in this environment immediately
2. Coordinate with `test-data-management` for anonymization of the snapshot
3. Drop and re-provision the database from the anonymized snapshot
4. Confirm no PII remains before resuming; log the incident

**Result:** ❌ NOT READY — CL-3 violation; halted; remediated before resuming

---

### Example 3: Slow Provisioning Blocking CI

**Scenario:** Integration test environment takes 8 minutes to provision due to a large database schema migration running on every CI job.

**Execution steps:**
1. Identify root cause: migration runs from scratch each time (no schema caching)
2. Solution: pre-build a base Docker image with schema applied; provisioning just starts the container
3. Provisioning time: 8 minutes → 45 seconds
4. If pipeline restructuring required, flag `ci-cd-pipeline-automation`

**Result:** ✅ READY — provisioning speed resolved without overengineering (DA-5 applied)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Manual environment setup steps**
"Just run these 3 scripts before the tests" is not reproducible and will drift.
✅ All setup must be code-defined and automated — no manual steps.

❌ **Anti-pattern 2: Teardown only on success**
Failed test runs leaving dirty environments pollute the next run's results.
✅ Teardown must be guaranteed — use CI post-steps or finally blocks.

❌ **Anti-pattern 3: Production data in test environments without anonymization**
A CL-3 violation — compliance risk regardless of intent or access controls.
✅ Anonymize all production data before import; verify before any test run.

❌ **Anti-pattern 4: Fixed-duration waits for service readiness**
`sleep 30` before starting tests causes both flakiness (service not ready) and slowness (unnecessary wait).
✅ Use health check probes with retry; test starts when services report ready.

❌ **Anti-pattern 5: Full production replica for every test tier**
E2E tests don't need a production-scale Kubernetes cluster. Over-provisioning is waste and slows CI.
✅ Match environment complexity to test tier needs (DA-5). Docker Compose for E2E; representative capacity for load tests.

❌ **Anti-pattern 6: Mocking decisions undocumented**
"We mocked the payment API" without documenting what failure modes are consequently untested creates invisible test gaps.
✅ Every mocking decision must be documented with its fidelity gap in the validation report.

❌ **Anti-pattern 7: Environment variables hardcoded in provisioning scripts**
Hardcoded secrets in scripts get committed to source control and cannot be rotated.
✅ Inject environment variables via CI secrets store or environment variable management; never hardcode.

❌ **Anti-pattern 8: "It works on my machine" accepted as valid**
Local developer environment is not a substitute for a reproducible CI environment.
✅ If it doesn't work in CI via code-defined provisioning, it doesn't work.

---

## Non-Goals

* ❌ **Provisioning production infrastructure** — handled by `infrastructure-as-code`
* ❌ **CI/CD pipeline design beyond environment provisioning** — handled by `ci-cd-pipeline-automation`
* ❌ **Generating or seeding test data** — handled by `test-data-management`
* ❌ **Diagnosing non-environment test failures** — handled by `test-interpretation-failure-diagnosis`

**Boundary clarifications:**

* This skill provisions and manages environments. It does not generate test data — coordinate with `test-data-management` for seeding.
* This skill flags pipeline issues to `ci-cd-pipeline-automation`; it does not redesign pipelines itself.
* This skill manages test environment isolation; production infrastructure is `infrastructure-as-code` territory.

---

## Notes for LLM Implementation

1. **Never accept "it works on my machine."** Reproducibility means code-defined, automated, and verified in CI — not locally convenient.
2. **PII detection is a hard stop.** If PII is present or suspected, halt immediately and coordinate remediation before any test execution resumes.
3. **Document every mocking decision.** Mocks are acceptable tradeoffs — but undocumented mocks create invisible test gaps that erode confidence in results.
4. **Guarantee teardown.** Post-step or finally-block teardown is non-negotiable. Dirty environments compound over time and produce increasingly unreliable results.
5. **Apply DA-5 aggressively.** The lightest approach that gives the required isolation is always preferred. Over-engineering test environments is a common and expensive mistake.

6. Present service inventory as a table; parity gaps as explicit checklist items; PII confirmation as a checkbox — not assumed.
7. Be specific about isolation — "isolated" means verified, not assumed; be decisive about PII — always a halt condition; document fidelity gaps honestly.

---
