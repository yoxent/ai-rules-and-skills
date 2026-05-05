```yaml
---
name: backward-compatibility
description: Validates that system updates preserve compatibility with existing consumers across APIs, services, and products, providing migration paths and deprecation timelines when breaking changes are unavoidable.
version: 1.2.0
category: Architecture
tags: [backward-compatibility, api-contracts, migration, consumers, breaking-changes]
priority: High
depends_on: [system-design]
flags_skills: [language-specific-implementation, api-design, stakeholder-communication, migration-strategy]
inputs: [existing-api-contracts, release-plans, change-descriptions, consumer-dependency-requirements]
outputs: [compatibility-matrices, migration-guides, deprecation-plans, contract-test-requirements]
rules_applied:
  - MF-3   # Backward Compatibility
  - MF-1   # Feature Consistency
  - PS-2   # Risk Communication
  - DT-2   # Confirmation Gate
  - DT-1   # Explicit Tradeoff Logging
  - GM-4   # Behavioral Transparency
documents_needed: [api-contracts, consumer-dependency-map, release-plan, change-descriptions]
execution_context: Runs when API, module, or product changes are proposed that may impact consumers, or when invoked by release-preparation in aggregate mode for full diff classification before a release tag is pushed.
---
```

---

# Skill: Backward Compatibility

---

## Purpose

**What this skill does:**
Backward Compatibility validates that proposed changes to APIs, modules, services, or products do not break existing consumers — including end users and integrations that depend on features, routes, exported formats, or workflows. When breaking changes are unavoidable, it designs the migration path, compatibility shim, or deprecation plan that allows consumers to migrate safely. It is the primary enforcement mechanism for MF-3.

**Business value:**
Breaking changes in production APIs are among the most visible engineering failures — consuming applications stop working, partners are disrupted, and customer trust is damaged. This skill makes incompatibility visible before deployment, designs the migration path, and ensures stakeholders are informed and have approved any unavoidable breaking change.

**Engineering value:**
Explicit compatibility validation prevents "it worked in testing" failures caused by assumptions about interface stability. Compatibility matrices make the impact surface explicit. Migration guides reduce consumer migration effort. Contract tests prevent regressions.

---

## When to Use This Skill

### Triggers:

* A release is being prepared and release-preparation invokes backward-compatibility in aggregate mode for full diff classification
* A dependency upgrade involves a library with breaking API changes affecting consumers
* An API field, endpoint, or behavior is being modified, removed, or renamed
* A database schema change affects downstream consumers reading from it
* A message format or event schema change affects downstream consumers
* A service contract change could affect an existing integration
* A product feature is removed or hidden with no transition path for existing users
* A URL route or navigation path changes without a redirect
* An exported data format changes (CSV columns, report fields, webhook payload structure)
* A UI workflow changes in a way that requires users to actively adapt (broken automation, relearned flows)

### Do NOT use this skill for:

* Classifying whether a change is breaking — that is Versioning's responsibility
* Designing the versioning strategy — that is Versioning's responsibility
* Executing consumer migrations — that is Migration Strategy or Refactoring
* Internal refactoring with no consumer-visible interface changes

**Execution Context:**
Typically invoked after Versioning classifies a change as BREAKING. May also be invoked directly when a change's consumer impact is suspected but not yet classified. Precedes Migration Strategy (when migration is complex) and Stakeholder Communication (when external consumers require notification).

---

## Inputs

**Required:**

* **Existing API and module contracts** — Interface definitions (OpenAPI specs, protobuf, module type signatures, event schemas) at risk of change
* **Release plan and change descriptions** — Proposed changes being evaluated for compatibility impact
* **Consumer dependency requirements** — What each consumer depends on in the current interface; used to determine which consumers are affected and how

---

## Outputs

**Primary:**

* **Compatibility matrix** — Each proposed change, affected consumers, and COMPATIBLE / MIGRATION REQUIRED / UNKNOWN classification
* **Migration guides** — Step-by-step consumer instructions with before/after examples for each breaking change
* **Deprecation plans** — Timeline and communication plan for sunsetting old interface versions
* **Contract test requirements** — Specification of tests to add to CI/CD to prevent regression of the compatibility guarantee

---

## Preconditions

* Current interface contracts are available (API specs, type definitions, event schemas)
* The set of proposed changes is clearly defined
* Consumer dependency map is available

**Validation checks:**

* [ ] Interface contracts collected and baselined
* [ ] Consumer dependency map populated

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:** At execution start, determine whether backward-compatibility analysis involves code-level implementation.
- If yes → flag **language-specific-implementation** and co-invoke before planning begins
- If no (pure compatibility analysis/migration design) → continue to Step 1

---

### Step 1: Contract Inventory and Baseline

**Actions:**
- [ ] Collect all interface contracts at risk: REST API specs (OpenAPI), gRPC/protobuf definitions, message schemas (Avro, JSON Schema), module type signatures, database views used by external consumers
- [ ] For each contract: document the guaranteed interface — what consumers depend on, not just what exists
- [ ] Identify contract consumers from the dependency map: internal services, external partners, public API users

---

### Step 2: Compatibility Impact Analysis

**Actions:**
- [ ] For each proposed change, evaluate against each consumer's known dependencies
- [ ] Classify each change per consumer: COMPATIBLE (no consumer action), MIGRATION REQUIRED (consumer must update), or UNKNOWN (cannot determine — block until resolved)

**Backward-compatible patterns:** Adding optional fields/parameters with sensible defaults; adding new endpoints without removing existing ones; expanding enums only when consumers handle unknown values gracefully.

**Breaking patterns (always require migration path):** Removing any field, endpoint, or parameter; renaming without aliasing; changing field types or semantics; making optional fields required; tightening validation rules.

**Product-facing breaking patterns:** Removing or hiding a feature users depend on; changing a route or URL without a redirect; altering exported data structure (columns, fields, payload shape); changing a workflow in a way that breaks user automation or requires active relearning. For products, "consumer" = end users and integrations — not just developer dependents.

---

### Step 3: Migration Path Design

For every breaking change, design one of:

**Option A — Additive Migration (preferred):** Keep old interface intact; add new interface alongside; mark old deprecated; sunset after consumers migrate.

**Option B — Versioned Migration:** Package breaking change in a new version; run v1 and v2 simultaneously during migration window; sunset v1 after all consumers migrate.

**Option C — Compatibility Shim:** Translate old-format requests/responses to the new implementation; remove shim after consumer migration.

**Actions:**
- [ ] Evaluate Options A, B, C for each breaking change
- [ ] Select approach minimizing consumer disruption at acceptable implementation cost
- [ ] Produce migration guide with concrete before/after examples per consumer action required
- [ ] Apply DT-2: any unavoidable breaking change requires explicit stakeholder approval before proceeding

---

### Step 4: Contract Test Specification

**Actions:**
- [ ] Define contract tests verifying the current guaranteed interface is still satisfied post-change
- [ ] For consumer-driven contract testing (Pact or equivalent): specify consumer interactions to capture and verify
- [ ] Require contract tests added to CI/CD before the breaking change merges — prevents future regressions
- [ ] Flag any missing contract tests as required actions

---

### Final Step: Generate Backward Compatibility Report

```markdown
## Backward Compatibility Report

**API / Module:** [Name]  **Date:** [YYYY-MM-DD]
**Status:** ✅ COMPATIBLE / ⚠️ MIGRATION REQUIRED / ❌ BLOCKED

### Compatibility Matrix
| Change | Affects Consumers | Compatible? | Migration Required |
|--------|------------------|------------|------------------|
| [Change] | [List] | [Y/N] | [Option A/B/C / None] |

### Migration Guides
For each breaking change: [Before/After examples and migration steps]

### Deprecation Plan
| Interface Element | Deprecation Date | Sunset Date | Consumers Notified |
|------------------|-----------------|------------|-------------------|
| [Element] | [Date] | [Date] | [Y/N] |

### Contract Test Requirements
| Test | Consumer | Interface | Status |
|------|---------|----------|--------|
| [Test name] | [Consumer] | [Endpoint/field] | [Required/Exists] |

### Skills Flagged
- **[Skill]**: [Reason]

### Required Actions
- [ ] Stakeholder approval (DT-2) for breaking changes
- [ ] [Additional actions]
```

---

## Core Responsibilities

1. At execution start, detect whether backward-compatibility analysis involves code-level implementation; if so → flag **language-specific-implementation** and co-invoke before planning begins.
2. Inventory all interface contracts and their consumers before evaluating any proposed change
3. Classify every proposed change as COMPATIBLE, MIGRATION REQUIRED, or UNKNOWN per consumer
4. Design a concrete migration path (additive, versioned, or shim) for every breaking change
5. Gate every unavoidable breaking change through DT-2 stakeholder approval
6. Produce consumer-actionable migration guides with concrete before/after examples
7. Specify contract tests that prevent future regression of the compatibility guarantee

---

## Constraints (Rules Applied)

* **MF-3: Backward Compatibility** — Primary enforcement mechanism. Breaking changes released without a migration path are always a violation.
* **MF-1: Feature Consistency** — Silent behavioral changes (same API, changed semantics) are breaking changes — not just structural changes.
* **PS-2: Risk Communication** — Compatibility risks must be communicated in business terms: which partners are affected and what migration effort is required.
* **DT-2: Confirmation Gate** — Any unavoidable breaking change requires explicit stakeholder approval before proceeding.
* **DT-1: Explicit Tradeoff Logging** — All decisions to accept compatibility tradeoffs must be logged with business context.

---

## Tradeoff Handling

### Innovation Velocity vs. Consumer Stability

**Default stance:** Prefer additive changes that don't break consumers. When breaking changes are necessary, provide generous migration timelines and tooling support.

**Resolution:** If the rate of breaking changes is high (multiple major versions per quarter), flag api-design for interface stability review.

---

### Legacy Contract Maintenance vs. Complexity Reduction

**Default stance:** Maintain legacy contracts until consumers have migrated. Do not remove support to "clean up" the codebase at the cost of breaking production integrations.

**Resolution:** If a legacy contract creates a security risk, escalate to stakeholder with the security risk communicated per PS-2 to evaluate accelerated deprecation.

---

## Failure & Escalation Behavior

### Breaking Change Without Migration Path

**Trigger:** A breaking change is proposed but no migration path has been designed.

**Action:** Block the change. Design a migration path before the change proceeds. If no backward-compatible migration is possible, escalate to DT-2 for stakeholder approval.

---

### Consumer Refuses or Cannot Migrate

**Trigger:** A consumer has not migrated off a deprecated interface by the agreed timeline.

**Action:** Flag stakeholder-communication. Do not silently extend the deprecation period. Escalate to stakeholder for a decision: extend with a firm date, negotiate migration support, or enforce the cutoff.

---

### Breaking Change Caused by API Design Defect

**Trigger:** Analysis reveals the proposed breaking change is caused by an underlying API design problem that could be resolved with an additive redesign instead.

**Action:** Flag api-design. Block the breaking change pending design review. Evaluate whether an additive interface redesign can avoid the break before accepting the breaking path.

---

### Migration Requires Multi-Service or Data Coordination

**Trigger:** The migration path involves coordinating multiple services, migrating data schemas, or managing state transitions that exceed a simple consumer-side update.

**Action:** Flag migration-strategy. Require a formal migration plan before proceeding with the breaking change. Migration Strategy produces the sequenced execution plan.

### Code-Level Implementation in Scope

**Trigger:** Backward-compatibility analysis identifies code-level implementation requirements (e.g., compatibility shims, migration scripts, or adapter layers).

**Action:** Flag **language-specific-implementation** and co-invoke before compatibility design proceeds. Do not finalize shim or migration path design for implementation-dependent components until language-specific guidance is available.

---

### When to halt execution:

* A proposed change is classified as UNKNOWN for any consumer — do not approve the change until the consumer's actual dependency is confirmed
* A breaking change has no feasible migration path and no stakeholder authorization — block the change entirely

---

## Skill Integration & Orchestration

**Role in pipeline:** Runs after Versioning classifies a change as BREAKING, or directly when a consumer-impacting change is detected. Precedes Migration Strategy (complex migrations) and Stakeholder Communication (external consumer notifications). Typically mid-pipeline, between change classification and migration execution.

### How This Skill Integrates

**Does NOT directly call other skills.** Instead, this skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes this skill when a consumer-impacting change is detected, or release-preparation invokes it in aggregate mode for pre-release classification
2. This skill inventories contracts, classifies compatibility impact, and designs migration paths
3. This skill **outputs flags** for api-design, stakeholder-communication, and migration-strategy as applicable
4. **Orchestrator** decides which flagged skills to invoke next

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Code-level implementation in scope (proactive — at execution start) | language-specific-implementation | Code-level implementation requires language-correct patterns |
| Breaking change caused by fixable API design defect | api-design | Additive redesign may eliminate the break |
| Breaking change affects external consumers | stakeholder-communication | Formal notification required; deprecation timeline to communicate |
| Migration involves multi-service or data coordination | migration-strategy | Formal sequenced migration plan required |

---

### Flag Format in Report

```markdown
### Skills Flagged for Follow-up
- ⚡ **api-design**: [Specific reason — design defect that may be avoidable with additive redesign]
- 📢 **stakeholder-communication**: [Specific reason — external consumer affected, formal notification required]
- 🔄 **migration-strategy**: [Specific reason — multi-service coordination required]
```

**Note:** Orchestrator uses these flags to build the execution pipeline. Flags should be actionable and specific.

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides architectural context for interface ownership and consumer dependency mapping

**Skills this skill cooperates with:**

* **migration-strategy** — Backward-compatibility designs the migration approach; migration-strategy executes the formal plan for complex cases
* **stakeholder-communication** — Backward-compatibility identifies affected consumers; stakeholder-communication manages formal notification and negotiation

---

## Governance Hooks

* [ ] Log all compatibility tradeoff decisions via DT-1
* [ ] Communicate breaking change risks to stakeholders in business terms before proceeding (PS-2, GM-4)
* [ ] Gate every unavoidable breaking change through DT-2 stakeholder confirmation
* [ ] Do not silently extend deprecation deadlines — document stakeholder approval
* [ ] Require contract tests in CI/CD before merging breaking changes
* [ ] Document all decisions to classify UNKNOWN changes as COMPATIBLE without consumer validation

---

## Example Use Cases

### General: REST API Field Removal

A product team proposes removing a deprecated `user.legacy_id` field from the user profile API. Backward-compatibility inventories three consuming services and finds two have migrated but one internal analytics service still reads `legacy_id`. The skill classifies the change as MIGRATION REQUIRED for the analytics service and designs an Option A additive migration: keep `legacy_id` in responses for 60 days while the analytics team migrates to `user.id`. It flags stakeholder-communication to notify the analytics team with the migration timeline and produces a contract test requiring `legacy_id` to remain present until the sunset date.

### Edge Case: Silent Semantic Change

A backend change to the order service alters what `order.status = "pending"` means — it now includes orders awaiting payment, not just orders awaiting fulfillment. The API interface is structurally unchanged. Backward-compatibility identifies this as a silent behavioral breaking change under MF-1: consuming services that branch on `"pending"` will behave incorrectly. The skill treats this as a full breaking change requiring a new explicit status value and DT-2 stakeholder approval before release.

### Edge Case: Security-Driven Accelerated Deprecation

A legacy API version uses a deprecated authentication scheme with a known CVE. The standard 90-day deprecation window would leave consumers exposed. Backward-compatibility escalates to stakeholder via PS-2, communicating the security risk and proposing a 30-day accelerated deprecation. Flags stakeholder-communication for formal partner notification and flags migration-strategy to produce an expedited migration plan.

---

## Anti-Patterns to Catch

❌ **Silent Behavioral Breaking Changes:** The API structure is unchanged but field semantics change (e.g., `status: "pending"` gains a new meaning). Consumers receive no breaking change signal.
✅ Semantic changes are breaking changes — treat them the same as structural removals.

❌ **Removing Fields "No One Uses":** Usage analytics show low adoption so the field is removed without deprecation.
✅ Usage analytics inform migration prioritization, not breaking-vs-compatible classification. Any removal requires a deprecation period.

❌ **Assuming Consumers Handle Unknown Fields:** A new required field is added and assumed safe because the spec says clients should tolerate unknown fields.
✅ Required fields are always breaking additions. Only optional fields with sensible defaults are backward-compatible additions.

❌ **Expanding Enums Without Consumer Validation:** A new enum value is added and assumed backward-compatible.
✅ Enum expansions are backward-compatible only when consumer code handles unknown values gracefully (e.g., default switch case). Verify before classifying as non-breaking.

❌ **Silently Extending Deprecation Deadlines:** A consumer misses the migration deadline and the sunset date is quietly moved.
✅ Deprecation deadline changes require documented stakeholder approval. Flag stakeholder-communication.

❌ **UNKNOWN Treated as COMPATIBLE:** A change's impact on a consumer cannot be confirmed, but the change proceeds anyway.
✅ Block UNKNOWN classifications until the consumer's actual dependency is verified.

---

## Non-Goals

* ❌ **Change classification** — Versioning classifies change type; backward-compatibility responds to classification and designs migration
* ❌ **Executing consumer migrations** — Migration Strategy and Refactoring handle execution
* ❌ **Internal refactoring** — No consumer-visible interface change means backward-compatibility analysis is not required

**Boundary clarifications:**

* Backward-compatibility ends when the migration path is designed and documented; Migration Strategy begins when execution of a complex migration must be planned and sequenced
* Backward-compatibility identifies affected consumers; Stakeholder Communication manages the formal notification and negotiation process

---

## Version History

**v1.2.0 (2026-05-05)** — Added proactive ENFORCE clause: detect code-level implementation at execution start and co-invoke language-specific-implementation. Added Pre-Execution step, Core Responsibility 1 (renumbered 1–6 → 2–7), Skills That May Be Flagged proactive row, and escalation scenario for code-level implementation in scope.

**v1.1.0** — Prior version (no changelog recorded).

---

## Notes for LLM Implementation

1. **UNKNOWN is a hard block** — Do not classify a change as COMPATIBLE when the consumer's dependency on the affected interface element is not confirmed. UNKNOWN must be resolved before approval.
2. **Silent semantic changes are breaking** — A field that changes meaning without changing name or type is a breaking change under MF-1. Structural interface unchanged does not make it safe.
3. **Enum expansion requires consumer code verification** — Before classifying enum expansion as backward-compatible, verify (or require the team to verify) that consumer code uses a default/fallback case for unknown enum values.
4. **Migration path design precedes DT-2** — Stakeholder approval is for unavoidable breaking changes that already have a designed migration path. Gate on the migration plan, not on a blank break.
5. **Contract test gate is non-negotiable** — Contract tests must be added to CI/CD before the breaking change merges, not after consumers migrate. This prevents future regression of the compatibility guarantee.
6. **Aggregate mode output must be a structured table** — When invoked by release-preparation in aggregate mode (full diff classification), output one row per change with BREAKING/COMPATIBLE/UNKNOWN per consumer. Do not produce prose summaries; versioning consumes the table directly to determine the semver bump.
