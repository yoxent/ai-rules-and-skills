```yaml
---
name: release-preparation
description: Pre-release gate that classifies the full change set, enforces semver, verifies migration docs, and produces a changelog before the release tag is pushed.
version: 1.0.0
category: DevOps
tags: [release, versioning, semver, changelog, pre-release, backward-compatibility]
priority: High
depends_on: []
flags_skills: [backward-compatibility, versioning, ci-cd-pipeline-automation, stakeholder-communication, documentation-knowledge-transfer]
inputs: [git-diff-since-last-tag, last-release-tag, existing-migration-docs, consumer-dependency-map]
outputs: [compatibility-classification-report, version-bump-determination, changelog, release-readiness-assessment]
rules_applied:
  - DD-4
  - DD-2
  - MF-3
  - PS-4
  - DT-2
  - DT-1
  - GM-4
execution_context: Invoked manually before pushing a release tag; developer pushes tag only after this skill returns READY.
---
```

---

# Skill: Release Preparation

---

## Purpose

**What this skill does:**
Orchestrates the pre-release checklist before a release tag is pushed to main/master. Collects the full change set since the last release via git diff, invokes backward-compatibility in aggregate mode to classify all changes as BREAKING/COMPATIBLE/UNKNOWN, feeds that classification to versioning for the correct semver bump, verifies migration docs exist for all breaking changes, and produces a changelog. The developer pushes the tag only after this skill returns READY.

Prevents incorrect version numbers, undocumented breaking changes, and releases that lack migration paths from reaching consumers. Makes the release decision auditable — MAJOR bumps require stakeholder approval on record before the tag is immutable in git history.

Consolidates release classification into a single structured pass over the full change set, not a series of per-change assessments. Ensures versioning enforcement and consumer communication happen before the tag is pushed, not discovered after.

---

## When to Use This Skill

### Triggers:
* Developer is preparing to push a release tag to main/master
* A release cycle is closing and the version number must be determined
* A "prepare a release" or "cut a release" request is made

### Do NOT use this skill for:
* Per-change backward-compatibility checks during development — use `backward-compatibility` directly
* Designing the CI/CD deployment pipeline — use `ci-cd-pipeline-automation`
* Executing deployment after tag push — CI/CD pipeline handles that automatically

---

## Inputs

**Required:**
* **git diff since last tag** — `git diff <last-tag>..HEAD` combined with `git log <last-tag>..HEAD --oneline`; the full change set to classify
* **Last release tag** — baseline for the diff

**Optional:**
* **Existing migration docs** — verified against every BREAKING change found
* **Consumer dependency map** — passed to backward-compatibility to assess consumer impact
* **CI/CD pipeline config** — verified for tag-triggered deployment pipeline

---

## Outputs

**Primary:**
* **Compatibility classification report** — structured table from bc: each change → BREAKING/COMPATIBLE/UNKNOWN per consumer
* **Version bump determination** — MAJOR/MINOR/PATCH with rationale tied to bc classification
* **Changelog** — BREAKING / Added / Fixed sections
* **Release readiness assessment** — READY or BLOCKED with explicit blocking reasons

**Output format:**
* Compatibility classification as a table (not prose) — required for versioning to consume correctly
* Release readiness as structured markdown (see Final Step)

---

## Preconditions

* Last release tag exists and is reachable in git history
* All development work for the release is committed
* Consumer dependency map available

**Validation checks:**
* [ ] Last release tag identified
* [ ] git diff producible with no intended commits missing
* [ ] Migration docs location known

---

## Step-by-Step Execution Procedure

### Step 1: Collect Change Set

**Questions to answer:**
- What is the last release tag?
- Are all intended commits included in the diff?

**Actions:**
- [ ] Run `git diff <last-tag>..HEAD`
- [ ] Run `git log <last-tag>..HEAD --oneline` for commit context
- [ ] Confirm diff is complete — no intended commits excluded

**Watch-fors:** Partial diffs from branch divergence; pre-release commits from prior cycles accidentally included.

**Decisions:** If any intended commit is missing → stop and resolve before continuing.

---

### Step 2: Aggregate Backward-Compatibility Classification

**Questions to answer:**
- Are any changes BREAKING? For which consumers?
- Are any classifications UNKNOWN?

**Actions:**
- [ ] Invoke `backward-compatibility` with full diff in aggregate mode
- [ ] Require structured table output: change → BREAKING/COMPATIBLE/UNKNOWN per consumer

**Watch-fors:** Prose summaries instead of table (not consumable by versioning); UNKNOWN returned without investigation.

**Decisions:** If any UNKNOWN remains → block; do not proceed to versioning until each UNKNOWN is resolved to BREAKING or COMPATIBLE with evidence.

---

### Step 3: Versioning Enforcement

**Questions to answer:**
- What semver bump does the bc classification require?
- Is the proposed bump consistent with that classification?

**Actions:**
- [ ] Feed bc classification table to `versioning`
- [ ] Confirm semver rule: any BREAKING → MAJOR; only additions → MINOR; only fixes → PATCH

**Watch-fors:** Proposed bump understated relative to bc classification.

**Decisions:** If MAJOR → gate DT-2 stakeholder confirmation before continuing. If version understated → reclassify MAJOR, gate DT-2, log DT-1.

---

### Step 4: Verify Migration Docs

**Questions to answer:**
- Does every BREAKING change have a migration doc with before/after examples for each affected consumer?

**Actions:**
- [ ] For each BREAKING change: confirm migration doc exists
- [ ] Verify before/after examples cover all affected consumers

**Watch-fors:** Docs that describe the change but omit migration steps; docs that cover some consumers but not all.

**Decisions:** If any BREAKING change lacks migration docs → block release → flag `documentation-knowledge-transfer`.

---

### Step 5: Produce Release Artifacts and Final Check

**Questions to answer:**
- Does a rollback plan exist?
- Is a tag-triggered CI/CD pipeline configured?
- Have external consumers been notified (if MAJOR)?

**Actions:**
- [ ] Generate changelog: BREAKING / Added / Fixed sections
- [ ] Confirm rollback plan exists (DD-2)
- [ ] Verify tag-triggered CI/CD pipeline exists
- [ ] If MAJOR: flag `stakeholder-communication` for consumer notification with migration timeline

**Watch-fors:** No pipeline configured before tag push; rollback plan missing; changelog omits BREAKING section.

**Decisions:** If no pipeline → flag `ci-cd-pipeline-automation`, warn deployment will be manual. If no rollback plan → block.

---

### Final Step: Release Readiness Assessment

**Output structure:**

```markdown
## Release Preparation Report

**Last tag:** [tag]
**Status:** ✅ READY / ❌ BLOCKED

### Compatibility Classification
| Change | Classification | Affected Consumers |
|---|---|---|
| [change] | BREAKING/COMPATIBLE/UNKNOWN | [consumers] |

### Version Bump
**Determination:** MAJOR/MINOR/PATCH
**Rationale:** [tied to bc classification]

### Changelog
**BREAKING:**
- [description + migration doc link]

**Added:**
- [description]

**Fixed:**
- [description]

### Skills Flagged for Follow-up
- **[skill-name]**: [reason]

### Blocking Issues
- [ ] [issue — explicit reason preventing READY]

### Required Actions
- [ ] [action]
```

---

## Core Responsibilities

1. Collect the full change set via git diff since last release tag
2. Invoke backward-compatibility in aggregate mode — structured table required
3. Invoke versioning with bc's classification — enforce correct semver bump
4. Block release on unresolved UNKNOWN or missing migration docs
5. Gate MAJOR bumps through stakeholder confirmation (DT-2)
6. Produce changelog and release readiness assessment before tag push

**Quality criteria:** READY only when: bc classification complete with no UNKNOWN; semver bump confirmed; all BREAKING changes have migration docs; MAJOR bump has DT-2 approval on record; rollback plan confirmed; changelog produced.

---

## Constraints (Rules Applied)

* **DD-4: Release Coordination** — all dependencies, timing, and consumer notifications coordinated before tag push
* **DD-2: Rollback Readiness** — rollback plan must be confirmed before release proceeds
* **MF-3: Backward Compatibility** — every BREAKING change must have a migration path; no exceptions without DT-2 approval
* **PS-4: Decision Transparency** — version bump rationale documented; MAJOR requires stakeholder approval on record
* **DT-2: Confirmation Gate** — MAJOR bumps gate through explicit confirmation before tag push
* **DT-1: Explicit Tradeoff Logging** — any release gate exception logged with rationale and approval
* **GM-4: Behavioral Transparency** — all classifications traceable to git diff; no assumed-safe classifications

---

## Tradeoff Handling

### Speed vs Release Gate Completeness

**Scenario:** Team wants to release quickly; migration docs are incomplete for a BREAKING change.

**Default stance:** Block. Migration docs are a hard prerequisite, not a warning.

**Resolution:** If migration docs are genuinely impossible (e.g., deprecated consumer with no migration path) → escalate via DT-2, log exception via DT-1 with stakeholder approval on record. Never silently release with missing docs.

---

### MAJOR vs MINOR Classification Dispute

**Scenario:** Team disagrees whether a behavioral change is BREAKING.

**Default stance:** Default to MAJOR — understating a breaking change has consumer impact.

**Resolution:** If disputed → escalate via DT-2 to resolve classification. Log rationale via DT-1 regardless of outcome. Do not downgrade without DT-2 approval.

---

## Failure & Escalation Behavior

### UNKNOWN Classification Remains

**Trigger:** bc aggregate run returns UNKNOWN for one or more changes.

**Action:** Block release. Do not proceed to versioning. Resolve each UNKNOWN to BREAKING or COMPATIBLE with evidence before continuing.

---

### BREAKING Change Has No Migration Docs

**Trigger:** A BREAKING change has no migration documentation.

**Action:** Block release. Flag `documentation-knowledge-transfer`. Release cannot proceed until migration docs with before/after examples exist for every affected consumer.

---

### MAJOR Version Bump Required

**Trigger:** bc classification contains at least one BREAKING change.

**Action:** Gate through DT-2 stakeholder confirmation. Flag `stakeholder-communication` for consumer notification with deprecation timeline and migration docs. Do not push tag until confirmation received.

---

### No Tag-Triggered Deployment Pipeline

**Trigger:** No CI/CD pipeline configured to trigger on the release tag.

**Action:** Flag `ci-cd-pipeline-automation`. Warn: pushing tag without a configured pipeline means manual deployment with no automated quality gates.

---

### Version Understated

**Trigger:** Proposed bump is MINOR or PATCH but bc classification contains BREAKING changes.

**Action:** Reclassify as MAJOR. Gate through DT-2. Log via DT-1.

---

### When to halt execution:
* Any UNKNOWN classification unresolved
* BREAKING change has no migration docs and no DT-2 exception approved
* MAJOR bump has not received DT-2 stakeholder confirmation
* No rollback plan confirmed

---

## Skill Integration & Orchestration

**Role in pipeline:** Manual pre-release gate, invoked once per release cycle after all commits are in. Runs before the tag is pushed. The tag push is the handoff to ci-cd-pipeline-automation.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Always — classify full diff | backward-compatibility | Aggregate classification: BREAKING/COMPATIBLE/UNKNOWN per consumer |
| Always — after bc classification | versioning | Enforce semver bump from bc's classification |
| BREAKING changes affect external consumers | stakeholder-communication | Formal notification and deprecation timeline required |
| BREAKING change missing migration docs | documentation-knowledge-transfer | Migration docs required before release can proceed |
| No tag-triggered deployment pipeline | ci-cd-pipeline-automation | Automated deployment pipeline must be configured |

---

## Governance Hooks

* [ ] bc aggregate classification completed — no UNKNOWN remaining
* [ ] Versioning semver bump confirmed and rationale documented
* [ ] Migration docs verified for every BREAKING change
* [ ] MAJOR bump: DT-2 stakeholder confirmation on record
* [ ] Rollback plan confirmed (DD-2)
* [ ] Changelog produced with BREAKING / Added / Fixed sections
* [ ] Tag-triggered CI/CD pipeline verified or flagged

---

## Anti-Patterns to Catch

❌ **Skipping the bc aggregate classification:** "We checked compatibility as we went" — dev-time incremental checks don't cover the combined effect of all changes. An individually innocuous set of changes can combine into a BREAKING change. ✅ Always run bc on the full diff since last tag.

❌ **Proceeding with UNKNOWN classifications:** "It's probably fine" — UNKNOWN means consumer dependency is unconfirmed, not that no consumer exists. ✅ Block until every UNKNOWN is resolved to BREAKING or COMPATIBLE with evidence.

❌ **Releasing a MAJOR bump without DT-2 confirmation:** Consumers are broken without prior notification or consent. ✅ Gate every MAJOR bump through explicit DT-2 confirmation. No tag push without approval on record.

❌ **Understating the version bump:** "It's a small behavioral change — MINOR is fine." If bc classifies it BREAKING, the bump is MAJOR. ✅ Trust the classification. When disputed, escalate via DT-2 — do not downgrade.

❌ **Treating the changelog as optional:** The changelog is the consumer's first signal of what changed and what action they must take. ✅ Always produce a structured changelog before pushing the tag.

❌ **Pushing the tag before the deployment pipeline exists:** A tag without a pipeline means manual deployment with no quality gates. ✅ Verify the pipeline exists before pushing. Flag ci-cd-pipeline-automation if not configured.

---

## Non-Goals

* ❌ Per-change backward-compatibility checks during development — use `backward-compatibility` directly
* ❌ Designing the CI/CD deployment pipeline — use `ci-cd-pipeline-automation`
* ❌ Executing deployment after tag push — CI/CD pipeline handles that automatically
* ❌ Post-release monitoring and rollback — use `monitoring-alerts` and `rollback-management`

**Boundary clarifications:**
* release-preparation ends at the tag push; bc invoked here is aggregate mode on the full diff — it does not replace dev-time incremental bc checks.

---

## Notes for LLM Implementation

1. **bc output must be a structured table, not prose.** When invoking backward-compatibility in aggregate mode, explicitly require the compatibility matrix as a table. Prose summaries are not reliably consumable by versioning for semver classification.
2. **bc and versioning are always invoked in sequence — never skipped.** Every release-preparation run invokes bc first, then versioning with bc's output. No release type bypasses this sequence.
3. **Block on UNKNOWN — never assume safe.** An unresolved UNKNOWN is a hard release blocker. Do not proceed optimistically or treat it as a warning.
4. **MAJOR gate is non-negotiable.** DT-2 confirmation for MAJOR bumps must be on record before the tag is pushed. Do not push optimistically and notify after — the tag is immutable once pushed.

---
