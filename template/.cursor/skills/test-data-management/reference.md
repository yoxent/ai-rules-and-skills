---

```yaml
---
name: test_data_management
description: Designs, generates, provisions, and manages test data ensuring tests are deterministic, representative, privacy-compliant, and capable of covering edge cases.
version: 1.0.0
category: Testing & QA
tags: [test-data, synthetic-data, anonymization, fixtures, determinism]
priority: High

depends_on: []
flags_skills: [test-environment-management, security]

inputs: [test-scenarios, data-schemas, privacy-constraints, production-data-samples]
outputs: [synthetic-datasets, seeding-scripts, anonymized-subsets, teardown-procedures]

rules_applied:
  - CL-3  # Data Privacy — no PII in test environments without anonymization; non-negotiable
  - CL-1  # Regulatory Compliance — test data processes must comply with applicable regulations
  - TQ-4  # Test Quality Rule — unrepresentative data yields false confidence
  - MF-1  # Feature Consistency — seeding must not create state that masks behavioral regressions

documents_needed: [data-schema, domain-model, privacy-compliance-requirements, test-scenario-definitions]

execution_context: Invoked before test suites requiring data setup; also triggered when non-deterministic results, stale fixtures, or PII compliance concerns are detected.

---
```

---

# Skill: Test Data Management

---

## Purpose

**What this skill does:**
Designs and provisions the test data that test suites depend on — synthetic datasets that accurately represent real domain entities and edge cases, idempotent seeding scripts that reset to a known state before each run, and anonymized subsets when production data characteristics are required. It ensures test data is deterministic, representative, referentially intact, and compliant with privacy regulations.

Tests backed by unrepresentative data create false confidence. A checkout test that always uses a single, pre-loaded, perfectly-formed order misses every real-world data edge case. Conversely, using real production data in tests exposes the business to privacy and compliance risk. Proper test data management bridges this gap — representative coverage without PII exposure.

Deterministic seeding eliminates a primary source of test non-determinism. Idempotent scripts that reset state before each run remove inter-test data dependencies. Well-designed synthetic data covers edge cases (boundary values, null fields, multi-byte characters, referential integrity edge cases) that production data may not reliably provide for tests.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A test suite requires data setup before execution and no seeding mechanism exists
* Test results are non-deterministic and data state variation between runs is suspected
* Fixtures are stale — schema changes have made existing test data invalid or misleading
* Production data is proposed for use in a test environment (must be anonymized first)
* New edge cases are required that synthetic data does not yet cover
* Privacy audit flags PII in a test environment

### Do NOT use this skill for:

* Provisioning the test environment itself — use `test-environment-management`
* Diagnosing test failures that are not data-related — use `test-interpretation-failure-diagnosis`
* Generating load test traffic (virtual user simulation) — use `load-test-creation`
* Defining data schema or domain model — use `abstraction-domain-modeling`

**Execution Context Details:**
This skill runs before test suites that require data setup. It is closely coordinated with `test-environment-management` — the environment must exist before data can be seeded into it. It flags `test-environment-management` if seeding failures are caused by environment issues, and `security` if data handling in test pipelines risks compliance violations.

---

## Inputs

**Required inputs:**

* **Test scenarios and data coverage requirements** — What data states each test needs: happy path records, boundary values, null fields, multi-tenant records, high-cardinality relationships.
* **Data schemas and domain models** — The structure of entities being generated, including foreign key relationships, constraints, and field validation rules. Required for referential integrity.
* **Privacy and compliance constraints** — GDPR, HIPAA, PCI, or other applicable regulations governing what data can appear in test environments. These are non-negotiable input constraints, not optional guidance.

**Optional inputs:**

* **Production data samples** — Used only for anonymization workflows. Never used directly in test environments; provided only to understand realistic data distributions for synthetic generation.
* **Existing fixture inventory** — Helps identify what test data already exists, what is stale, and what gaps need filling.

---

## Outputs

**Primary outputs:**

* **Synthetic test datasets** — Generated data covering required scenarios: happy path, boundary values, null fields, high-cardinality relationships, multi-tenant records, referential integrity edge cases.
* **Seeding scripts** — Idempotent scripts that provision datasets into the test environment before each run. Re-runnable without accumulating duplicate records or violating constraints.
* **Anonymized data subsets** — Production data with all PII replaced by synthetic equivalents, preserving statistical distributions while removing identifying information.
* **Teardown and reset procedures** — Scripts that remove test data after suite execution, or reset to a known baseline state for the next run.

**Output format:**

* Seeding scripts as idempotent SQL, migration fixtures, or framework-native seed mechanisms (e.g., Rails seeds, Django fixtures, Factory Bot factories).
* Anonymized subsets delivered with a confirmation that PII fields are replaced — not just redacted or masked with reversible transforms.
* Teardown as database truncation, rollback, or namespace deletion — matching the isolation strategy of the environment.

**Skill flags (if applicable):**

* Flag **test-environment-management** when seeding failures are caused by environment configuration issues (wrong schema version, missing service, permission error) rather than data definition issues.
* Flag **security** when data handling practices in the test pipeline risk compliance violations beyond what this skill can remediate independently.

---

## Preconditions

**Conditions that must be met before execution:**

* Test environment must exist and be accessible — seeding cannot run into a non-existent environment.
* Data schema must be current — seeding against a stale schema produces constraint violations or silently inserts invalid data.
* Privacy compliance constraints must be known — cannot design anonymization without knowing what constitutes PII in this context.

**Validation checks:**

* [ ] Test environment is provisioned and schema is at the expected version
* [ ] Privacy requirements are defined — what fields are PII, what regulations apply
* [ ] No production data will be used without explicit anonymization plan
* [ ] Seeding scripts are idempotent — re-runnable without accumulating state
* [ ] Teardown procedure defined before seeding runs in any persistent environment

---

## Step-by-Step Execution Procedure

### Step 1: Assess Data Coverage Requirements

**Questions to answer:**
- What data states does each test scenario require?
- What edge cases (boundary values, nulls, multi-byte, high-cardinality) must be represented?
- Is existing test data (fixtures, factories) still current and representative?

**Actions:**
- [ ] List all data states required by the test suite, one per scenario
- [ ] Identify edge cases not covered by existing fixtures
- [ ] Audit existing fixtures for schema currency — flag stale fixtures for update or removal
- [ ] Determine required data volume (E2E tests need a few records; load tests may need thousands)

**Red flags / Warning signs:**
- Tests all use the same single record — edge cases are not covered
- Fixtures have not been updated since the last schema migration — likely stale
- No mapping between test scenarios and data states — coverage is assumed, not verified

**Decision points:**
- If existing fixtures are stale, update or replace before relying on them — stale data creates false test confidence
- If data volume requirements for load tests exceed what this skill manages, coordinate with `load-test-creation` on data generation strategy

---

### Step 2: Design Synthetic Data Strategy

**Questions to answer:**
- Can required data be generated synthetically, or are production data characteristics essential?
- How will referential integrity be maintained across related entities?
- What anonymization approach is required if production samples are used?

**Actions:**
- [ ] Design synthetic generation strategy per entity: value distributions, cardinality, nullable fields, relationships
- [ ] Ensure foreign key relationships are seeded in dependency order (parent before child)
- [ ] If production data characteristics are required, design anonymization pipeline: identify PII fields, choose replacement strategy (random synthetic, format-preserving encryption, pseudonymization)
- [ ] Validate anonymization completeness: confirm all PII fields are covered, not just the obvious ones (email, name) — also indirect identifiers (postcode + DOB combination, unique job title)

**Red flags / Warning signs:**
- Only "obvious" PII fields anonymized — indirect identifiers overlooked is a common compliance gap
- No referential integrity plan — seeding will fail with constraint violations or insert orphaned records
- Production data used directly "just for one test" — this is always a compliance violation

**Decision points:**
- If production data is proposed without anonymization, block immediately — escalate to prompt engineer for approval of anonymization approach before any data transfer
- If indirect identifier risk is identified, flag `security` for compliance assessment

---

### Step 3: Implement Seeding Scripts

**Questions to answer:**
- Are scripts idempotent — can they run repeatedly without accumulating duplicate records?
- Do scripts seed in the correct dependency order to preserve referential integrity?
- Are scripts parameterized for different data volumes (unit test vs load test)?

**Actions:**
- [ ] Implement seeding using upsert semantics or pre-truncate strategy — not blind insert
- [ ] Seed entities in foreign key dependency order
- [ ] Parameterize data volume so the same scripts serve multiple test tiers
- [ ] Include schema version assertion at script start — fail fast if schema does not match expected version
- [ ] Test script idempotency: run twice; verify no duplicates and no constraint violations

**Red flags / Warning signs:**
- INSERT without upsert or truncate — second run will fail with duplicate key violations
- Hardcoded IDs — brittle across environments with different auto-increment sequences
- No schema version check — script silently fails against wrong schema version

**Decision points:**
- If the environment uses auto-generated IDs, use application-layer factories rather than raw SQL inserts with hardcoded IDs
- If schema version assertion fails, halt seeding and coordinate with `test-environment-management`

---

### Step 4: Implement Teardown and Reset Procedures

**Questions to answer:**
- Does teardown restore the environment to a known baseline, or does it fully remove all test data?
- Is teardown guaranteed to run even on test failure?
- Does teardown handle cascading deletes correctly without orphaning records?

**Actions:**
- [ ] Implement teardown in reverse dependency order (children before parents)
- [ ] Use truncate cascade or equivalent — do not rely on manual delete-by-filter which misses records
- [ ] Integrate teardown as a guaranteed post-step in the CI job (runs on failure as well as success)
- [ ] For persistent environments: implement reset-to-baseline rather than full teardown

**Red flags / Warning signs:**
- Teardown only runs on success — failed test runs leave dirty data for the next run
- Teardown uses filtered deletes ("delete where created_by = 'test'") — fragile and incomplete
- No cascade handling — parent records deleted, child records orphaned

---

### Step 5: Validate and Document

**Questions to answer:**
- Does the seeded data actually cover all required scenarios and edge cases?
- Is the anonymization complete and verifiable?
- Is the data coverage documented so test consumers can understand what states are and are not represented?

**Actions:**
- [ ] Run coverage validation: map each test scenario to the data state it requires; confirm seeded data satisfies it
- [ ] Run anonymization validation: sample the anonymized dataset and verify no PII fields remain
- [ ] Document: what data states are seeded, what edge cases are covered, what is intentionally not covered
- [ ] Document: for anonymized subsets, what fields were replaced and with what strategy

---

### Final Step: Generate Test Data Report

**Report/Output structure:**

```markdown
## Test Data Management Report

**Target Test Suite:** [Suite name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ READY / ❌ NOT READY / ⚠️ READY WITH GAPS

### Data Coverage Summary

| Scenario | Required Data State | Seeded | Edge Cases | Notes |
|---|---|---|---|---|
| [Happy path checkout] | [Order with 3 items, valid payment] | ✅ | ✅ | |
| [Expired coupon] | [Order with expired coupon code] | ✅ | ✅ | |

### Anonymization Report (if production data used)
| Field | PII Type | Replacement Strategy | Verified |
|---|---|---|---|
| email | Direct identifier | Random synthetic | ✅ |

### Stale Fixtures Identified
[List of fixtures flagged as stale, with recommended action]

### Privacy Compliance Confirmation
- [ ] No PII present in test environment
- [ ] All production data anonymized before use
- [ ] Indirect identifiers assessed

### Skills Flagged
- **[Skill]**: [Reason]

### Overall Assessment
- ✅ READY: All scenarios covered, data deterministic, no PII, seeding idempotent
- ❌ NOT READY: PII present, seeding non-idempotent, or critical scenario uncovered
- ⚠️ READY WITH GAPS: Known coverage gaps documented; acceptable risk confirmed

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Map test scenarios to required data states — coverage must be explicit, not assumed
2. Generate synthetic data that is semantically valid, referentially intact, and edge-case-representative
3. Implement idempotent seeding scripts that produce deterministic state on every run
4. Anonymize any production data before use — never allow PII into test environments
5. Implement guaranteed teardown or reset procedures that leave no dirty data for subsequent runs

**Quality criteria:**

* Every test scenario has an explicitly seeded data state — no scenario relies on assumed ambient data
* Seeding scripts are idempotent: run N times, result is identical to run once
* No PII present in any test environment — verified, not assumed
* Stale fixtures are identified, updated, or removed — not silently relied upon

---

## Constraints (Rules Applied)

* **CL-3: Data Privacy** — No PII in test environments without irreversible anonymization (not masking, not reversible encryption). Indirect identifiers must be assessed alongside direct ones. Non-negotiable.
* **CL-1: Regulatory Compliance** — Test data processes must comply with GDPR, HIPAA, PCI and similar; includes data retention limits, consent requirements, and cross-border transfer restrictions.
* **TQ-4: Test Quality Rule** — Unrepresentative data produces false confidence. Synthetic data must cover real domain distributions and edge cases — not just a minimal happy-path fiction.
* **MF-1: Feature Consistency** — Seeding must not create states so minimal they mask behavioral regressions; test data must exercise real-world data patterns.

---

## Tradeoff Handling

### Tradeoff 1: Data Realism vs Privacy Compliance

Realistic data improves coverage but risks PII exposure if sourced from production.

**Resolution:** Anonymize all PII before any transfer; use production data only for distribution analysis and generate synthetic data with matching distributions; never transfer raw records. If anonymization cannot be verified, use purely synthetic data with documented distribution assumptions; log approach via DT-1.

### Tradeoff 2: Static Fixtures vs Dynamic Generation

Static fixtures are fast but become stale as schemas evolve. Dynamic generation stays current but is slower and more complex.

**Resolution:** Update stale fixtures before relying on them; for rapidly evolving schemas, prefer factory-based dynamic generation; log staleness incidents via DT-1.

### Tradeoff 3: Data Volume vs Seeding Speed

Load tests may require large data volumes that take significant time to seed.

**Resolution:** Pre-generate and snapshot large datasets; restore from snapshot rather than regenerating each run; regenerate when schema changes; log snapshot strategy and currency risk via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: PII Detected in Test Environment

**Trigger:** Real PII found in a test environment — in the database, logs, or files.

**Action:**
- Halt all test execution immediately
- Assess scope: what PII, how much, how long present
- Coordinate remediation: purge PII data, anonymize if production snapshot is required
- Flag `security` if the scope or duration suggests a compliance incident requiring formal assessment
- Do not resume test execution until environment is confirmed clean and anonymization is verified

---

### Escalation Scenario 2: Seeding Fails Due to Environment Issues

**Trigger:** Seeding script fails because of environment-level issues — wrong schema version, missing service, permission error — not data definition errors.

**Action:**
- Distinguish: data issue (fix seeding script) vs environment issue (escalate)
- Flag `test-environment-management` with specific error context
- Block test suite execution until environment issue is resolved

---

### Escalation Scenario 3: Non-Deterministic Results Traced to Data State

**Trigger:** Test results vary between runs and data state variation is identified as the cause (e.g., auto-increment IDs creating different sort orders, timestamps causing race conditions).

**Action:**
- Identify and fix the non-determinism source in seeding scripts
- For timestamp non-determinism: inject controlled timestamps via seeding rather than relying on `NOW()`
- For ID non-determinism: use stable synthetic IDs rather than auto-increment sequences
- Retest for determinism before marking resolved

---

### When to halt execution:

* PII detected — halt immediately, no exceptions
* Schema version mismatch — seeding will produce invalid data; halt until schema is aligned
* Anonymization completeness cannot be verified — do not use the dataset

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs after `test-environment-management` has provisioned the environment and before test suite execution. Closely coordinates with `test-environment-management` on schema version and environment readiness. Flags `security` for compliance-level data handling issues that exceed the scope of anonymization.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Seeding fails due to env issue | test-environment-management | Schema version mismatch or missing service is an env problem |
| PII scope suggests compliance incident | security | Formal compliance assessment may be required |

---

## Related Skills

**Skills this skill depends on:**

* **test-environment-management** — Environment must exist and schema must be at expected version before seeding can run.

**Skills this skill cooperates with:**

* **e2e-test-creation, load-test-creation, stress-test-creation** — All depend on this skill for deterministic data states before test execution.

**Skills this skill may invoke/flag:**

* **test-environment-management** — When seeding failures are environment-level.
* **security** — When PII scope or data handling risk requires compliance-level assessment.

---

## Governance Hooks

* [ ] Never allow PII into test environments without verified anonymization — CL-3 is non-negotiable
* [ ] Confirm compliance constraints before designing any anonymization approach
* [ ] Log all anonymization decisions, coverage gaps, and tradeoffs via DT-1
* [ ] Verify seeding idempotency before declaring scripts production-ready
* [ ] Assess indirect identifiers in anonymization — not just obvious PII fields
* [ ] Halt and escalate immediately on PII detection — do not attempt self-remediation without flagging

**Audit trail requirements:**

* Anonymization field inventory: what was replaced, with what strategy, verified by whom
* Data coverage map: test scenarios → seeded data states
* Stale fixture inventory: what was updated, what was removed
* PII incident log (if applicable): scope, duration, remediation steps

---

## Example Use Cases

### Example 1: E2E Checkout Test Data Setup

**Scenario:** E2E checkout tests need: a registered user, a product catalogue with 10 items, an active coupon, and an expired coupon.

**Inputs provided:**
- Test scenarios: happy path, expired coupon, out-of-stock item, multi-item order
- Schema: users, products, orders, coupons (with FK relationships)

**Execution steps:**
1. Map scenarios to data states; identify gap: out-of-stock state not in existing fixtures
2. Design upsert-based seed script: users → products → coupons (dependency order)
3. Add out-of-stock product record to cover missing edge case
4. Implement teardown: truncate coupons → orders → products → users (reverse order)
5. Run twice; confirm idempotent (no duplicates, no constraint violations)

**Result:** ✅ READY — all scenarios covered, idempotent, teardown guaranteed

---

### Example 2: Production Data Anonymization for Load Test

**Scenario:** Load test needs realistic order data distributions. Team proposes using a production database snapshot.

**Execution steps:**
1. Block direct production data use — CL-3 violation
2. Assess PII fields: email, name, address, phone, payment_last4 (direct); postcode + DOB (indirect combo)
3. Design anonymization: email → random@synthetic.test; name → Faker; address → random valid; postcode + DOB → randomize postcode to break indirect identifier
4. Run anonymization pipeline; sample 100 records and verify no original PII values remain
5. Deliver anonymized dataset with field inventory report

**Result:** ✅ READY — anonymized with indirect identifiers addressed; field inventory documented

---

### Example 3: Stale Fixtures After Schema Migration

**Scenario:** A schema migration added a NOT NULL column `order_type` to the orders table. Existing fixtures pre-date the migration and insert into orders without `order_type`.

**Execution steps:**
1. Schema version assertion in seeding script fires — reports version mismatch
2. Audit fixtures: orders table fixtures are missing `order_type` — all are stale
3. Update fixtures with default `order_type = 'standard'` for existing scenarios; add `order_type = 'subscription'` for new scenario
4. Verify: seed script runs cleanly; no constraint violations

**Result:** ✅ READY — fixtures updated; stale fixture incident logged

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Production data in test environments without anonymization**
Always a CL-3 violation. "It's just for one test" is not an acceptable justification.
✅ Anonymize all production data before any use in test environments. Verify completeness.

❌ **Anti-pattern 2: Tests sharing a single global dataset**
One shared order record used by all checkout tests means tests are not independent — one test's modification breaks another's assertion.
✅ Each test should own its data state or seed a fresh, dedicated record.

❌ **Anti-pattern 3: Non-idempotent seeding (blind INSERT)**
The second CI run fails with duplicate key violations; the third run has accumulated three times the expected records.
✅ Use upsert semantics or truncate-then-insert. Test idempotency explicitly.

❌ **Anti-pattern 4: Hardcoded IDs in seeding scripts**
IDs 1, 2, 3 work in a fresh database but collide in a environment with existing records.
✅ Use application-layer factories with sequence-safe ID generation, or use UUIDs.

❌ **Anti-pattern 5: Only obvious PII fields anonymized**
Email and name are replaced, but postcode + date of birth combination still identifies individuals.
✅ Assess indirect identifiers systematically — not just the obvious fields.

❌ **Anti-pattern 6: Stale fixtures silently relied upon**
Fixtures haven't been updated since the last schema change; they insert invalid or incomplete data that tests pass on by accident.
✅ Add schema version assertions to seeding scripts. Audit fixtures after every schema migration.

❌ **Anti-pattern 7: Teardown only on success**
A failed test leaves dirty data; the next run's seeding accumulates on top, producing non-deterministic results.
✅ Teardown must be guaranteed — run in CI post-step or finally block.

❌ **Anti-pattern 8: Timestamp-dependent data causing non-determinism**
A test that relies on `created_at = NOW()` produces different results based on when it runs.
✅ Inject fixed, controlled timestamps via seeding; never rely on database-generated timestamps for test assertions.

❌ **Anti-pattern 9: Minimal happy-path-only data**
A test suite that only ever sees one perfect record per entity type is not testing real-world data patterns.
✅ Cover: boundary values, nulls, multi-byte characters, high-cardinality relationships, invalid-but-realistic inputs.

❌ **Anti-pattern 10: No data coverage map**
"We have fixtures" without knowing which test scenarios they cover means gaps are invisible.
✅ Maintain an explicit scenario-to-data-state map; update it with every fixture change.

---

## Non-Goals

* ❌ **Provisioning the test environment** — handled by `test-environment-management`
* ❌ **Generating load test traffic** — handled by `load-test-creation`
* ❌ **Defining data schema or domain model** — handled by `abstraction-domain-modeling`
* ❌ **Diagnosing non-data-related test failures** — handled by `test-interpretation-failure-diagnosis`
* ❌ **Formal compliance incident response** — escalated to `security`

**Boundary clarifications:**

* This skill manages test data — not environment provisioning. Environment must exist before seeding runs.
* Anonymization is within scope; formal compliance incident assessment is not — escalate to `security`.
* Data volume generation for load tests is within scope; traffic simulation is `load-test-creation`.

---

## Notes for LLM Implementation

1. **PII is always a halt condition.** On detection, stop everything and coordinate remediation — do not attempt to work around it or continue testing with a note in the report.
2. **Idempotency is the primary quality gate for seeding scripts.** A seeding script that only works once is not production-ready. Run it twice; verify the output is identical.
3. **Assess indirect identifiers.** The combination of postcode + date of birth + job title can identify individuals as surely as an email address. Anonymization that covers only obvious fields is incomplete.
4. **Stale fixtures are a reliability risk.** After every schema migration, audit all fixtures against the new schema. A schema version assertion in seeding scripts catches this automatically.
5. **Coverage must be explicit.** Maintain a scenario-to-data-state map. "We have some fixtures" is not coverage.

6. Present coverage as a scenario-to-data-state table; anonymization report as a field inventory table (not prose); PII confirmation as explicit checkboxes.
7. Be strict about PII — never soften the halt condition; be thorough about edge cases; be explicit about gaps — undocumented gaps are invisible risks.

---
