---

```yaml
---
name: contract_api_testing
description: Validates that API contracts between services and consumers are correctly implemented and remain stable, preventing integration failures without requiring full E2E runs.
version: 1.1.0
category: Testing & QA
tags: [contract-testing, api-testing, backward-compatibility, consumer-driven, integration]
priority: High

depends_on: []
flags_skills: [versioning, api-design, ci-cd-pipeline-automation]

inputs: [api-specifications, consumer-contracts, provider-implementation, breaking-change-history]
outputs: [contract-validation-reports, detected-violations, backward-compatibility-assessments, migration-recommendations]

rules_applied:
  - MF-3  # Backward Compatibility — contract tests are the primary enforcement mechanism at the API level
  - TQ-1  # Test Coverage Requirement — all public API surfaces must have contract test coverage
  - DD-1  # CI/CD Enforcement — contract tests must run as a mandatory gate before integration tests
  - DT-2  # Confirmation Gate — breaking contract changes require explicit approval and a migration plan

documents_needed: [api-specification, consumer-contracts, breaking-change-log, migration-plan-template]

execution_context: Invoked on API changes, before integration test runs, or when consumer compatibility must be validated; always runs as a CI gate before integration tests.

---
```

---

# Skill: Contract & API Testing

---

## Purpose

**What this skill does:**
Validates that API provider implementations match their published contracts, and that consumer expectations match what the provider delivers. It detects breaking changes before they reach integration testing or production, maintains a contract change log for audit and migration planning, and provides backward compatibility assessments with migration recommendations when breaking changes are required.

Integration failures caused by undetected API contract violations are expensive: they surface late in the delivery pipeline, affect multiple consumers simultaneously, and often require urgent coordination across teams. Contract testing catches these violations at the earliest possible point — when the API is being changed — before any consumer is affected.

Contract tests enable independent service deployment by making integration compatibility explicit and machine-verifiable. They are faster than full E2E tests for validating integration correctness, provide clear attribution when a contract violation is introduced (the specific change, in the specific commit), and serve as living documentation of what consumers actually depend on.

---

## When to Use This Skill

### Triggers (Use this skill when):

* An API endpoint is being added, modified, or removed
* A consumer service is adding a dependency on an existing API
* A breaking change is proposed and a migration plan is required
* Contract tests are absent from the CI pipeline as a gate before integration tests
* A contract drift is suspected — implementation has diverged from the published spec
* An API specification (OpenAPI, GraphQL schema, Protobuf, AsyncAPI) has been updated

### Do NOT use this skill for:

* Full user workflow validation — use `e2e-test-creation`
* Load or performance testing of APIs — use `load-test-creation`
* Internal implementation correctness (unit testing of API logic) — use `test-creation-strategy`
* Defining the API design or interface — use `api-design`

**Execution Context Details:**
This skill runs as a CI gate between build and integration tests — contract tests fail fast and cheaply before integration tests run. It flags `versioning` when a breaking change requires a formal migration strategy, and `api-design` when contract violations reveal an underlying API design problem that requires redesign rather than just a fix.

---

## Inputs

**Required inputs:**

* **API specifications** — OpenAPI, GraphQL schema, Protobuf, or AsyncAPI definitions. The source of truth for what the provider should deliver.
* **Consumer contracts** — Pact contracts or equivalent consumer-driven contract definitions describing what each consumer expects from the provider. Required for consumer-driven contract validation.
* **Provider implementation** — The actual API implementation being validated against its contract.

**Optional inputs:**

* **Breaking change history** — Log of prior breaking changes, used to assess cumulative impact and inform migration strategy.
* **Consumer registry** — List of registered consumers and their contract versions, used to assess blast radius of a proposed breaking change.

**Documents/Context needed:**

* **Migration plan template** — Used when a breaking change is approved and a migration plan must be produced.

---

## Outputs

**Primary outputs:**

* **Contract validation reports** — Per-consumer and per-provider validation results: which contracts pass, which fail, and which specific field or endpoint caused a violation.
* **Detected contract violations** — Specific breaking changes with change attribution: which commit introduced the violation, what the provider delivers vs what the contract requires.
* **Backward compatibility assessments** — For proposed changes: additive (safe), non-breaking modification (safe), or breaking (requires migration plan and DT-2 approval).
* **Versioning and migration recommendations** — When a breaking change is approved: recommended versioning strategy, migration path for existing consumers, and deprecation timeline.

**Output format:**

* Validation reports as structured CI artifacts (JUnit XML, Pact broker results, or equivalent).
* Backward compatibility assessment as a classification table: change, type, impacted consumers, risk.
* Migration recommendations as a structured plan: consumer notification, deprecation timeline, migration steps.

**Skill flags (if applicable):**

* Flag **versioning** when a breaking change requires a formal versioning strategy and migration plan beyond what this skill produces.
* Flag **api-design** when contract violations reveal that the underlying API design needs revision — not just a fix to the implementation.

---

## Preconditions

**Conditions that must be met before execution:**

* API specification must be available and current — contract tests validate against the spec, not against assumed behavior.
* Consumer contracts must be registered — without consumer contracts, only provider-side validation is possible.
* CI pipeline must have a contract test stage before integration tests — this is a structural requirement, not a preference.

**Validation checks:**

* [ ] API specification exists and is current (not a stale doc)
* [ ] Consumer contracts are registered and version-tracked
* [ ] Contract test stage is configured before integration tests in CI pipeline
* [ ] Breaking change classification methodology is defined (what constitutes breaking vs non-breaking)

---

## Step-by-Step Execution Procedure

### Step 1: Classify the Change

**Questions to answer:**
- Is this change additive (new endpoint, optional field), non-breaking modification, or breaking (field removal, type change, required field addition)?
- Which consumers are registered against this API?
- What is the blast radius of this change if breaking?

**Actions:**
- [ ] Classify the proposed or detected change: additive / non-breaking / breaking
- [ ] Identify all registered consumers of the affected API surface
- [ ] For breaking changes: assess blast radius — how many consumers, which workflows affected
- [ ] For breaking changes: trigger DT-2 confirmation gate before proceeding

**Red flags / Warning signs:**
- Change removes or renames an existing field — breaking by default
- Change makes an optional field required — breaking for consumers that omit it
- No consumer registry exists — blast radius is unknown; treat as maximum risk

**Decision points:**
- If the change is breaking, block merge and trigger DT-2 — explicit approval and migration plan required before proceeding
- If consumer registry is incomplete, escalate — cannot approve a breaking change without knowing who is affected

---

### Step 2: Validate Provider Against Specification

**Questions to answer:**
- Does the provider implementation match its published API specification for all declared endpoints and schemas?
- Are there any contract drift points — where the implementation has diverged from the spec without a corresponding spec update?

**Actions:**
- [ ] Run spec-against-implementation validation (schemathesis, Dredd, or equivalent)
- [ ] Identify any response fields present in implementation but absent from spec (undocumented behavior)
- [ ] Identify any spec-declared fields absent from implementation (contract drift)
- [ ] Flag contract drift points — undocumented behavior that consumers may be relying on is a hidden contract

**Red flags / Warning signs:**
- Implementation returns fields not in the spec — consumers may depend on undocumented behavior
- Implementation omits spec-declared required fields — downstream consumers will fail
- Spec and implementation last updated on different dates — drift likely

**Decision points:**
- Contract drift discovered: flag `api-design` — the spec must be updated to match reality or the implementation must be corrected; drift is never acceptable to leave undocumented

---

### Step 3: Validate Consumers Against Provider

**Questions to answer:**
- Do consumer contracts express what consumers actually need from the provider?
- Does the provider satisfy every registered consumer contract?
- Are any consumer contracts out of date — testing against a version of the provider that no longer exists?

**Actions:**
- [ ] Run consumer contract validation against the current provider implementation (Pact, Spring Cloud Contract, or equivalent)
- [ ] Identify consumers whose contracts fail against the current provider
- [ ] Identify consumer contracts that pass but may be testing stale provider versions
- [ ] Flag consumers that have not updated their contracts after a provider change — stale consumer contracts create false safety

**Red flags / Warning signs:**
- Consumer contract passes but tests a deprecated endpoint — false safety
- Consumer contract tests only the happy path — missing error responses and edge cases
- No consumer contracts registered — only provider-side validation is possible; integration failures will surface later

**Decision points:**
- If consumer contracts are absent, surface the gap and recommend implementation — contract testing is provider-side only without consumer contracts, which is significantly weaker
- If a consumer contract fails, the provider change is breaking for that consumer — block until resolved or migration plan approved via DT-2

---

### Step 4: Manage the Contract Change Log

**Questions to answer:**
- Is this change recorded in the contract change log with attribution, consumer impact, and classification?
- Is the change log current enough to support migration planning and audit?

**Actions:**
- [ ] Record the change: endpoint/field affected, change type, consumers impacted, commit reference, date
- [ ] For breaking changes: record migration plan reference and DT-2 approval record
- [ ] For deprecations: record deprecation date and planned removal date

**Red flags / Warning signs:**
- Change log not updated — audit trail is incomplete
- Breaking change recorded without a migration plan reference — incomplete record

---

### Step 5: Integrate Into CI Pipeline

**Questions to answer:**
- Do contract tests run before integration tests as a mandatory blocking gate?
- Are results surfaced in the CI dashboard with clear violation details?
- Is the Pact broker (or equivalent) configured for contract versioning and consumer registration?

**Actions:**
- [ ] Verify contract test stage is positioned before integration tests in the pipeline
- [ ] Confirm pipeline fails on contract violation — not informational only
- [ ] Confirm result artifacts are published with violation details (not just pass/fail)
- [ ] If pipeline is missing a contract stage, surface as a required action and block completion

---

### Final Step: Generate Contract Validation Report

```markdown
## Contract & API Testing Report

**API:** [Endpoint / service / schema]
**Date:** [YYYY-MM-DD]
**Change Type:** Additive / Non-breaking / Breaking
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Provider Validation
| Endpoint | Spec Match | Contract Drift | Status |
|---|---|---|---|
| GET /orders | ✅ | None | ✅ |
| POST /payments | ❌ | Missing `currency` field | ❌ |

### Consumer Contract Validation
| Consumer | Contract Version | Result | Failing Assertion |
|---|---|---|---|
| [frontend-bff] | v1.2 | ✅ | — |
| [mobile-app] | v1.1 | ❌ | `status` field removed |

### Breaking Change Assessment
| Change | Type | Consumers Affected | DT-2 Obtained | Migration Plan |
|---|---|---|---|---|
| Remove `status` field | Breaking | mobile-app | ❌ | None |

### Contract Change Log Entry
[Recorded change with attribution, classification, and consumer impact]

### Skills Flagged
- **[Skill]**: [Reason]

### Overall Assessment
- ✅ PASS: No violations; all consumers satisfied; spec matches implementation
- ❌ FAIL: Contract violation, breaking change without DT-2, or consumer contract failure
- ⚠️ NEEDS REVIEW: Additive change requires consumer registration update

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Classify every change as additive, non-breaking, or breaking — trigger DT-2 gate for breaking changes
2. Validate provider implementation against published specification — surface contract drift immediately
3. Validate consumer contracts against provider — identify consumers broken by current implementation
4. Maintain contract change log with attribution, consumer impact, and migration plan references
5. Enforce contract test CI gate before integration tests — surface missing gate as a required action

**Quality criteria:**

* Every public API surface has contract test coverage — no undocumented behavior left as implicit contract
* Breaking changes never merge without DT-2 approval and a migration plan
* Contract drift (spec vs implementation divergence) is surfaced and resolved — never left undocumented
* Contract test CI gate is mandatory and blocks on violation — not informational

---

## Constraints (Rules Applied)

* **MF-3: Backward Compatibility** — Contract tests are the primary enforcement mechanism for API backward compatibility. A breaking change that passes contract tests has either been approved via DT-2 with a migration plan, or the tests are missing.
* **TQ-1: Test Coverage Requirement** — All public API surfaces must have contract test coverage: both provider-side spec validation and consumer-driven contract validation.
* **DD-1: CI/CD Enforcement** — Contract tests must run as a mandatory gate before integration tests; running them after defeats their purpose.
* **DT-2: Confirmation Gate** — Any breaking contract change requires explicit approval and a migration plan before merging. This is a hard gate — a breaking change merged without DT-2 is a policy violation.

---

## Tradeoff Handling

### Tradeoff 1: Consumer-Driven vs Provider-Driven Contracts

Consumer-driven contracts are stronger but require team coordination overhead.

**Resolution:** Surface the gap when no consumer contracts exist; proceed with provider-side validation as interim and document via DT-1; if a breaking change is proposed with no consumer contracts, block — blast radius is unknown.

### Tradeoff 2: Contract Breadth vs Maintenance Cost

Exhaustive contracts covering every field are brittle for rapidly evolving APIs.

**Resolution:** Calibrate contracts to actual usage — lock only fields the consumer uses; consumer-driven contracts naturally scope to actual usage; log scope decision via DT-1.

### Tradeoff 3: Breaking Change Required vs Consumer Migration Cost

Sometimes a breaking change is technically necessary despite consumer impact.

**Resolution:** Obtain DT-2 approval with explicit consumer impact acknowledgment; produce migration plan (versioned API, deprecation timeline, consumer notification); flag `versioning`; log via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Breaking Change Without DT-2 Approval

**Trigger:** A breaking change is detected (field removal, type change, required field addition) with no DT-2 approval record.

**Action:**
- Block the change from merging immediately
- Escalate to prompt engineer for DT-2 approval decision
- Require a migration plan before approval is given

**Escalation format:**
```
⚠️ CONFIRMATION REQUIRED — Breaking API Contract Change

Change: [Field/endpoint removed or modified]
Consumers affected: [List of registered consumers]
Blast radius: [Number of consumers, workflows affected]
Migration plan: [None — required before approval]

Options:
  A. Approve breaking change with migration plan and deprecation timeline.
  B. Introduce versioned endpoint (v2) and deprecate v1 with defined sunset date.
  C. Reject the change — redesign to maintain backward compatibility.

Question: Which approach is approved, and what is the migration commitment?
```

---

### Escalation Scenario 2: Contract Drift Detected

**Trigger:** Provider implementation returns fields or behavior not declared in the spec, or omits spec-declared fields.

**Action:**
- Flag `api-design` — drift must be resolved by either updating the spec or correcting the implementation
- Do not allow the drift to persist — undocumented behavior is an implicit contract that will break consumers when corrected

---

### Escalation Scenario 3: Consumer Contract Fails Against Provider

**Trigger:** A registered consumer's contract fails against the current provider state.

**Action:**
- Classify: is this a provider regression (the provider broke a previously passing contract) or a consumer contract that is newly failing after an approved change?
- For provider regression: block and treat as a breaking change requiring DT-2
- For approved change: ensure the consumer has a migration plan and timeline in the change log

---

### Escalation Scenario 4: No CI Gate for Contract Tests

**Trigger:** Contract tests are not configured as a mandatory gate in the CI pipeline before integration tests.

**Action:**
- Surface the missing gate as a required action
- Flag ci-cd-pipeline-automation to add contract test gate before integration tests
- Block completion until the gate is confirmed present in pipeline configuration

---

### When to halt execution:

* Breaking change detected without DT-2 approval — do not proceed
* Consumer blast radius unknown (no consumer registry) and breaking change proposed — do not approve
* Contract drift found and unresolved — do not allow spec and implementation to diverge

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs as a CI gate before integration tests on every API change. It is independent of E2E tests — contract tests validate interface compatibility, not user workflow correctness. It flags `versioning` for migration strategy and `api-design` for design-level issues surfaced by violations.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Breaking change needs migration strategy | versioning | Formal versioning and deprecation plan required |
| Contract violation reveals design issue | api-design | The API interface needs redesign, not just a fix |
| Contract tests missing from CI gate | ci-cd-pipeline-automation | Add mandatory gate before integration tests |

---

## Related Skills

**Skills this skill depends on:**

* None — operates independently as a CI gate.

**Skills this skill cooperates with:**

* **e2e-test-creation** — Contract tests validate compatibility; E2E tests validate end-to-end workflows. Both are required; contract tests are faster and run earlier in the pipeline.
* **regression-test-suite-management** — Consumer contracts are part of the regression suite; their health is tracked in suite management.

**Skills this skill may invoke/flag:**

* **versioning** — When a breaking change requires a formal versioning and migration strategy.
* **api-design** — When contract violations reveal an underlying API design problem.

---

## Governance Hooks

* [ ] Block breaking changes without DT-2 approval — non-negotiable
* [ ] Record every contract change (breaking or additive) in the change log
* [ ] Require migration plan for every approved breaking change
* [ ] Ensure contract test CI gate is mandatory — block if configured as informational
* [ ] Flag contract drift immediately — never leave spec and implementation diverged
* [ ] Log all tradeoff decisions (consumer-driven vs provider-driven scope, version strategy) via DT-1

**Audit trail requirements:**

* Per-change: classification, consumers impacted, DT-2 approval record (if breaking)
* Per-breaking change: migration plan reference, consumer notification record, deprecation timeline
* Contract change log maintained and current

---

## Example Use Cases

### Example 1: Field Removal Detected as Breaking Change

**Scenario:** A developer removes the `status` field from the `GET /orders` response. The mobile app consumer contract requires `status`.

**Execution steps:**
1. Change classified: field removal = breaking
2. Consumer contract validation: mobile-app contract fails (`status` field absent)
3. Block merge; trigger DT-2 confirmation gate
4. Escalate to prompt engineer: breaking change, mobile-app affected, no migration plan
5. After DT-2 approval: flag `versioning` for v2 endpoint strategy; record migration plan in change log

**Result:** ❌ FAIL — breaking change blocked; DT-2 escalated
**Skills flagged:** `versioning`

---

### Example 2: Additive Change — Safe to Merge

**Scenario:** A developer adds an optional `estimated_delivery` field to the `GET /orders` response. No consumer contracts reference this field.

**Execution steps:**
1. Change classified: additive (new optional field) — non-breaking
2. Provider validation: spec updated to include new field; implementation matches ✅
3. Consumer contract validation: all registered consumers pass (they don't reference the new field) ✅
4. Contract change log updated: additive change, no consumers affected
5. CI gate: passes; integration tests proceed

**Result:** ✅ PASS — additive change; all contracts satisfied

---

### Example 3: Contract Drift Discovered

**Scenario:** schemathesis validation reveals the provider is returning a `internal_id` field not declared in the OpenAPI spec. Two consumers are silently depending on it.

**Execution steps:**
1. Contract drift detected: `internal_id` undocumented but present in responses
2. Flag `api-design` — two options: add to spec (formalising the implicit contract) or remove from responses (breaking for consumers depending on it)
3. Block — drift must be resolved before further changes proceed
4. Record in change log as contract drift requiring resolution

**Result:** ⚠️ NEEDS REVIEW — contract drift flagged; `api-design` escalated for resolution

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Breaking changes merged without DT-2 approval**
"It's a small change" is not a valid justification for bypassing the confirmation gate.
✅ Every breaking change — regardless of perceived size — requires DT-2 approval and a migration plan.

❌ **Anti-pattern 2: Contract tests configured as informational in CI**
Optional contract tests are routinely ignored under delivery pressure, providing no protection.
✅ Contract tests must be a mandatory blocking gate before integration tests — not informational.

❌ **Anti-pattern 3: Only provider-side validation, no consumer contracts**
Provider-side spec validation catches spec drift but not consumer compatibility. A provider can be spec-compliant while still breaking consumers.
✅ Implement consumer-driven contracts (Pact or equivalent) for all registered consumers.

❌ **Anti-pattern 4: Contract drift left undocumented**
Undocumented behavior is an implicit contract. Consumers will depend on it; removing it will break them without warning.
✅ Contract drift must be resolved immediately — either formalise in the spec or remove from the implementation.

❌ **Anti-pattern 5: Consumer contracts testing only happy paths**
A consumer contract that only tests successful responses will not catch breaking changes in error responses or edge cases.
✅ Consumer contracts should cover the error responses and edge cases the consumer actually handles.

❌ **Anti-pattern 6: Breaking change approved without a consumer migration plan**
DT-2 approval is meaningless if there is no plan for how consumers will migrate before the breaking change takes effect.
✅ Every approved breaking change must have: versioning strategy, consumer notification, migration timeline, deprecation date.

❌ **Anti-pattern 7: Stale consumer contracts not updated after approved changes**
A consumer contract that tests against a deprecated endpoint gives false safety — it passes against the old provider but fails against the new one.
✅ Consumer contracts must be updated as part of the consumer-side migration; stale contracts are flagged.

❌ **Anti-pattern 8: No contract change log**
Without a change log, there is no audit trail, no migration plan history, and no way to attribute a consumer failure to its root cause.
✅ Every change — breaking or additive — is recorded in the contract change log.

---

## Non-Goals

* ❌ **Full user workflow validation** — handled by `e2e-test-creation`
* ❌ **Load or performance testing of APIs** — handled by `load-test-creation`
* ❌ **Defining the API interface or design** — handled by `api-design`
* ❌ **Formal API versioning strategy** — escalated to `versioning`

**Boundary clarifications:**

* This skill validates contracts; it does not design APIs. When violations reveal design issues, escalate to `api-design`.
* This skill identifies that a breaking change requires a versioning strategy; it does not produce the full migration plan — that is `versioning`.
* Contract testing is not a substitute for E2E testing — they test different concerns at different levels.

---

## Notes for LLM Implementation

1. **Classify the change first, always.** The entire escalation path (DT-2 gate, migration plan, versioning flag) depends on whether the change is breaking. Get this right before anything else.
2. **Contract drift is never acceptable to leave undocumented.** Undocumented behavior is a hidden contract. If it is intentional, put it in the spec. If it is unintentional, remove it.
3. **Consumer contracts are the real protection.** Provider-side validation alone catches spec drift but not consumer compatibility. Push for consumer-driven contracts for all registered consumers.
4. **The DT-2 gate is a hard stop.** Never soften it to a recommendation. Breaking changes without approval and a migration plan are policy violations.
5. **The CI gate must be mandatory.** An informational contract test stage that can be bypassed provides zero protection.

6. Provider validation as a table (endpoint, spec match, drift, status); consumer contract results as a table (consumer, contract version, result, failing assertion); breaking change assessment as a classification table.
7. Be precise about breaking vs non-breaking classification; be firm about the DT-2 gate — it is not negotiable; be constructive about violations — present the migration path.

---
