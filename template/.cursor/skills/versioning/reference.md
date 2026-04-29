```yaml
---
name: versioning
description: Maintains semantic versioning for APIs, modules, and services to support backward compatibility, safe evolution, and coordinated releases across consumers.
version: 1.0.0
category: Architecture
tags: [versioning, semver, api-versioning, deprecation, releases]
priority: Medium

depends_on: [system-design]
flags_skills: [backward-compatibility, stakeholder-communication, technical-debt-management]

inputs: [api-definitions, module-definitions, release-plans, consumer-dependency-maps, change-classifications]
outputs: [versioning-strategy, deprecation-policies, release-notes, migration-documentation]

rules_applied:
  - MF-3
  - PS-4
  - DD-4
  - DT-2
  - DT-1
  - GM-4

execution_context: Runs when APIs or module interfaces are modified, when breaking changes are planned, or when a release requires coordinated versioning across dependent services.

---
```

---

# Skill: Versioning

---

## Purpose

**What this skill does:**
Versioning defines and enforces semantic versioning discipline for APIs, modules, and services. It classifies changes as breaking vs. non-breaking, enforces version increments that communicate change impact accurately, coordinates deprecation timelines with consumers, and ensures releases do not surprise downstream teams.

Surprise breaking changes in APIs and services are one of the most disruptive events in a distributed system. They cause unplanned emergency work for consuming teams, production incidents, and erosion of trust between teams. This skill makes change impact explicit, communicated in advance, and managed with a migration path.

Accurate semver enables automated dependency management tools to safely upgrade consumers. Clear deprecation policies prevent the accumulation of legacy API versions that must be maintained indefinitely. Consistent versioning across the system makes release coordination tractable.

---

## When to Use This Skill

### Triggers (Use this skill when):

* An API endpoint, module interface, or service contract is being modified
* A change must be classified as breaking vs. non-breaking before release
* A new major version is being planned that breaks existing consumers
* A deprecation timeline is being established for an existing API version
* Release notes need to accurately communicate change impact to consumers
* Multiple services with inter-dependencies are being released in coordination
* A consumer has not migrated off a deprecated version by the agreed deadline

### Do NOT use this skill for:

* Designing the API interface itself (use API Design)
* Executing the migration of consumers off deprecated versions (use Migration Strategy or Refactoring)
* Infrastructure versioning (container image versions, Terraform module versions — DevOps Phase 4)
* Data schema versioning within a database (use Migration Strategy)

---

## Inputs

**Required inputs:**

* **API and module definitions** — Current and proposed interface definitions. Required to classify changes as breaking or non-breaking.
* **Release plan** — The planned change set for the upcoming release. Used to determine the correct version increment.
* **Consumer dependency map** — Which consumers depend on which versions of the API or module. Required for deprecation timeline planning and breaking change impact assessment.

**Optional inputs:**

* **Breaking vs. non-breaking change classification** — Pre-classified change list if available. If not provided, this skill performs the classification.
* **Deprecation history** — Existing deprecated versions and their announced end-of-life dates.

---

## Outputs

**Primary outputs:**

* **Versioning strategy** — Which versioning scheme applies (semantic versioning for libraries/modules, URI versioning or header versioning for APIs), version increment rules, and branching strategy for maintaining multiple versions.
* **Deprecation policies and timelines** — Minimum deprecation notice period per consumer tier (internal: 1 sprint minimum; external: 3-6 months minimum), sunset date communication, and escalation path for consumers that do not migrate.
* **Release notes** — Structured change log entries with accurate breaking/non-breaking classification, migration guidance for breaking changes, and example code where applicable.
* **Migration documentation** — For breaking changes: step-by-step migration guide from old version to new, including any tooling support.

**Skill flags (if applicable):**

* Flag **backward-compatibility** when a breaking change is unavoidable and a migration path must be designed
* Flag **stakeholder-communication** when a major version with breaking changes affects external consumers requiring formal announcement
* Flag **technical-debt-management** when multiple deprecated versions are still maintained because consumers have not migrated — this is accumulating maintenance debt

---

## Preconditions

* Current interface definitions are available
* The set of changes planned for the release is known
* The consumer dependency map is available (who depends on what version)

---

## Step-by-Step Execution Procedure

### Step 1: Change Classification

**Questions to answer:**
- Is each planned change breaking or non-breaking?
- Does the change remove, rename, or alter the behavior of any existing interface element?
- Does the change require consumers to modify their code to continue working?

**Actions:**
- [ ] For each change in the planned release, classify as: BREAKING (requires consumer code change), NON-BREAKING ADDITION (new optional capability, consumers unaffected), or PATCH (bug fix, no interface change)
- [ ] Apply the semantic versioning rules: breaking → MAJOR bump; non-breaking addition → MINOR bump; bug fix → PATCH bump
- [ ] Flag any MAJOR bump for DT-2 Confirmation Gate — breaking changes require explicit stakeholder approval before release

**Breaking change examples (always MAJOR):**
- Removing an endpoint, field, or parameter
- Renaming an endpoint, field, or parameter without aliasing
- Changing the type of an existing field (string → integer)
- Changing the semantics of an existing field (status codes, enum values)
- Removing previously optional fields from responses
- Changing authentication requirements

**Non-breaking addition examples (MINOR):**
- Adding a new optional endpoint
- Adding a new optional field to a response
- Adding a new optional parameter with a default value

**Red flags / Warning signs:**
- A change classified as PATCH that removes a field — field removal is always MAJOR regardless of how "minor" the field seems
- "We'll just call it a minor bump" without checking all consumers — semantic versioning is a contract, not a negotiation

---

### Step 2: Determine Version Increment

**Questions to answer:**
- What is the correct new version given the change classification?
- Are there multiple changes in this release requiring different bump levels?
- Does the version increment accurately communicate the impact to consumers?

**Actions:**
- [ ] Apply the highest-priority bump from all changes in the release (if one breaking + three non-breaking additions: MAJOR bump, not MINOR)
- [ ] Verify the version increment matches the change classification strictly — do not understate breaking changes
- [ ] For APIs: determine versioning strategy — URL path versioning (`/v1/`, `/v2/`), header versioning (`Accept: application/vnd.api+json;version=2`), or query parameter versioning (least preferred)
- [ ] For MAJOR bumps: apply DT-2 and require explicit stakeholder approval before the version is released

---

### Step 3: Consumer Impact Analysis

**Questions to answer:**
- Which consumers will be affected by this version change?
- What changes does each consumer need to make?
- What is the realistic migration timeline for each consumer tier?

**Actions:**
- [ ] From the consumer dependency map, identify all consumers on the version being changed
- [ ] For breaking changes: assess the effort required for each consumer to migrate (small config change vs. significant code refactor)
- [ ] Define consumer tiers: internal teams (shorter notice, can be coordinated), external partners (longer notice, formal communication), public API consumers (longest notice, public announcement)
- [ ] Set deprecation timeline: old version remains supported until all consumers have migrated or the sunset date passes
- [ ] Flag **stakeholder-communication** for major version announcements to external consumers

---

### Step 4: Deprecation Policy and Communication

**Questions to answer:**
- When will the old version be sunset?
- How will consumers be notified?
- What happens to consumers that have not migrated by the sunset date?

**Actions:**
- [ ] Define the minimum deprecation notice period by consumer tier
- [ ] Add deprecation warnings to the old API version responses (`Deprecation` HTTP header, changelog notice, API documentation update)
- [ ] Apply PS-4: document and communicate the deprecation decision with rationale and timeline
- [ ] Define the enforcement plan for non-migrated consumers at sunset: hard cutoff, grace period extension, or negotiated migration

**Red flags / Warning signs:**
- Sunsetting a version with consumers still on it without a formal notification — guaranteed production incidents for consuming teams
- Deprecation timeline set without validating that the timeline is realistic for the largest consumer migration effort
- No deprecation header or warning in the old API version responses — consumers who don't read changelogs will be surprised

---

### Step 5: Release Notes and Migration Documentation

**Actions:**
- [ ] Write structured release notes with explicit BREAKING/ADDED/FIXED/DEPRECATED sections
- [ ] For every breaking change: include a migration guide with before/after code examples
- [ ] Version the migration guide itself — maintain one per major version transition (v1→v2, v2→v3)
- [ ] Include links to migration documentation in deprecation warning headers and API documentation

---

### Final Step: Generate Versioning Report

```markdown
## Versioning Report

**API / Module:** [Name]  **Date:** [YYYY-MM-DD]
**Current Version:** [X.Y.Z]  **New Version:** [X.Y.Z]
**Status:** ✅ / ⚠️ BREAKING / ❌ BLOCKED

### Change Classification
| Change | Type | BREAKING? | Bump Required |
|--------|------|----------|--------------|
| [Change] | [Add/Remove/Modify] | [Y/N] | [MAJOR/MINOR/PATCH] |

### Consumer Impact
| Consumer | Tier | Migration Effort | Current Version | Migration Deadline |
|----------|------|-----------------|----------------|-------------------|
| [Consumer] | [Internal/Partner/Public] | [H/M/L] | [version] | [date] |

### Deprecation Timeline
- Old version supported until: [date]
- Deprecation warning added: [Y/N]
- Sunset enforcement: [Hard cutoff / Grace period / Negotiated]

### Skills Flagged
- **[Skill]**: [Reason]

### Required Actions
- [ ] [Action with owner]
```

---

## Core Responsibilities

1. Classify every planned change as breaking, non-breaking addition, or patch
2. Apply the correct semver increment — never understate breaking changes
3. Perform consumer impact analysis against the dependency map
4. Define deprecation timelines appropriate to each consumer tier
5. Produce structured release notes with migration guidance for all breaking changes
6. Gate all major version releases through DT-2 stakeholder approval

---

## Constraints (Rules Applied)

* **MF-3: Backward Compatibility** — Breaking changes must never be released without a versioning strategy and migration path. Silent breaking changes are always a violation.
* **PS-4: Decision Transparency** — Version changes must be documented with rationale and consumer impact. "We bumped to v2" is not sufficient.
* **DD-4: Release Coordination** — Version releases must be coordinated across all dependent services. No breaking release without consumer notification.
* **DT-2: Confirmation Gate** — Major version bumps with breaking changes require explicit stakeholder approval.
* **DT-1: Explicit Tradeoff Logging** — Rapid evolution vs. consumer stability tradeoffs must be logged.

---

## Tradeoff Handling

### Rapid Evolution vs. Consumer Stability

**Default stance:** Prefer additive, non-breaking changes. Design interfaces to evolve without breaking changes where possible. When breaking changes are necessary, communicate early with generous deprecation timelines.

**Resolution:** If feature velocity requires frequent breaking changes (many MAJOR bumps per quarter), escalate to stakeholder — this is a product strategy question, not just an engineering question. Frequent major versions burden consumers disproportionately.

---

## Failure & Escalation Behavior

### Breaking Change Without Consumer Notification

**Trigger:** A breaking change is about to be deployed without consumers being notified or given time to migrate.

**Action:** Block the release. Apply DD-4. Require consumer notification and minimum deprecation period before the breaking version is deployed.

### Consumer Has Not Migrated by Sunset Date

**Trigger:** A deprecated version is scheduled for sunset but one or more consumers have not migrated.

**Action:** Flag stakeholder-communication. Escalate to stakeholder for decision: extend the sunset date, negotiate an urgent migration, or proceed with the cutoff (accepting the consumer will break). Do not silently extend — every extension must be a deliberate decision per DT-1.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Calling a Breaking Change a Minor Bump**
Removing or renaming a field but calling it a minor version bump because "it's a small change."
✅ **Correct approach:** Semver classifications are based on consumer impact, not change size. Any change that requires consumer code modification is MAJOR.

❌ **Anti-pattern 2: No Deprecation Period**
Releasing a new major version and immediately removing support for the old version, without giving consumers time to migrate.
✅ **Correct approach:** Old versions must remain supported for the deprecation period. The deprecation period starts when consumers are notified, not when the new version ships.

❌ **Anti-pattern 3: Versioning Around API Design Problems**
Bumping to v2 to "fix" a poorly designed v1 API that could have been fixed non-breakingly with a deprecation+addition approach.
✅ **Correct approach:** Before bumping a major version, evaluate whether the change can be made additive (add new field, keep old field, deprecate old field on a timeline). Flag api-design for interface redesign where appropriate.

❌ **Anti-pattern 4: Undocumented Deprecations**
Stopping support for a version without ever formally announcing its deprecation or adding deprecation warnings to the responses.
✅ **Correct approach:** Deprecation must be communicated via: (1) deprecation header in API responses, (2) updated documentation, (3) direct notification to known consumers, (4) changelog entry.

---

## Non-Goals

* ❌ **API interface design** — API Design handles the interface; Versioning handles the change lifecycle
* ❌ **Consumer migration execution** — Migration Strategy handles the actual migration
* ❌ **Database schema versioning** — Migration Strategy handles schema evolution

---
