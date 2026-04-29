# Skill Human Spec
# File: skill-gap-detection-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: skill_gap_detection
description: Identifies missing capabilities when user intent cannot be satisfied by existing skills, triggering controlled registry extension rather than ad hoc improvisation.
version: 1.0.0
category: Orchestration & Governance
tags: [gap-detection, governance, registry, capability, escalation]
priority: High

depends_on: [intent-parsing]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]  # not yet created

inputs: [structured-intent-model, skill-registry, execution-attempt-logs]
outputs: [gap-analysis-report, new-skill-outline, escalation-recommendation]

rules_applied:
  - PS-1  # Requirement Validation — differentiate real gap from misuse before escalating
  - PS-3  # Scope Control — prevent ad hoc expansion; proposed skills must fit a valid phase
  - DT-2  # Confirmation Gate — new skill creation requires explicit approval

documents_needed: [skill_registry, skill_overview, skill_ai_spec_template]

execution_context: Triggered by ORCH-1 ON FAILURE path when missing_capability is detected; also invoked by skill-orchestration when no skill in the registry matches parsed intent.

---
```

---

# Skill: Skill Gap Detection

---

## Purpose

**What this skill does:**
Skill Gap Detection activates when the orchestrator cannot map user intent to any registered skill — or when a registered skill is clearly insufficient for the task at hand. It distinguishes between a genuine capability gap (no skill exists for this domain) and a misuse (the skill exists but was selected incorrectly). When a real gap is confirmed, it produces a structured outline for a new skill and escalates to the Decision Confirmation Gate before any registry change is made.

Prevents two failure modes: silent improvisation (the AI acts outside its defined boundaries without governance) and complete paralysis (the AI refuses to help without surfacing a path forward). Keeps the skill registry honest — gaps become explicit, tracked, and resolved through governed extension rather than drift.

Enforces the "no undefined behavior" principle at the orchestration layer. Every capability is either covered by a registered skill or formally recognized as a gap. Prevents silent architectural expansion of the framework without oversight.

---

## When to Use This Skill

### Triggers (Use this skill when):

* ORCH-1 ON FAILURE path fires `missing_capability` — no registered skill addresses the parsed intent
* `skill-orchestration` cannot find a skill match after consulting `skill_registry.md`
* A registered skill is invoked but explicitly states in its SCOPE that the current task is out of scope
* An existing skill's output indicates the task requires a capability the skill does not provide
* A user explicitly requests a capability that has no obvious skill mapping

### Do NOT use this skill for:

* Selecting between multiple valid registered skills — that is Skill Orchestration
* Validating the structure of a proposed skill — that is Skill Validation
* Evaluating whether a skill's existing content is technically adequate — that is engineering review
* Creating or writing the new skill itself — that is the skill authoring workflow

**Execution Context Details:**
Skill Gap Detection sits on the ORCH-1 failure path. It runs after the orchestrator has failed to find a matching skill, not speculatively. The output is a gap analysis report and a new skill outline — not an improvised execution. The gap must be confirmed and a new skill approved before any registry change occurs.

---

## Inputs

**Required inputs:**

* **Structured intent model** — Output from intent-parsing; the parsed description of what the user needs
* **Skill registry** — `skill_registry.md`; used to confirm no matching skill exists
* **Execution attempt logs** — Records of which skills were considered and why they were rejected

**Optional inputs:**

* **Partial skill match** — If a skill partially covers the gap, used to scope the delta
* **Phase assignment hint** — User or orchestrator suggestion for which phase the new skill belongs to

**Documents/Context needed:**

* **`skill_registry.md`** — To confirm absence of an existing skill covering the gap
* **`skill_overview.md`** — To identify the correct phase and category for the proposed new skill
* **`skill_ai_spec_template.md`** — To structure the new skill outline in the correct format

---

## Outputs

**Primary outputs:**

* **Gap analysis report** — Confirms the gap is real (not a misuse), describes the missing capability, and references the rejected skills and why they were insufficient
* **Recommended new skill definition outline** — A pre-filled draft of the new skill's YAML frontmatter and SCOPE/TRIGGER in the AI spec format, ready for authoring review
* **Escalation recommendation** — Explicit recommendation to invoke decision-confirmation-gate before proceeding

**Output format:**

* Gap analysis in structured markdown with evidence section
* New skill outline in the AI spec YAML format (partial — enough for human authoring to complete)
* Escalation block addressed to the user or framework maintainer

**Skill flags (if applicable):**

* Flag **decision-confirmation-gate** — always, before any new skill outline is formally registered
* Flag **engineering-decision-logging** — to record the gap identification and the approved extension decision

---

## Preconditions

**Conditions that must be met before execution:**

* Intent-parsing has already run and produced a structured intent model
* The orchestrator has confirmed that no registered skill matches the intent
* Execution attempt logs exist showing which skills were considered and rejected

**Validation checks:**

* [ ] Structured intent model is available and non-empty
* [ ] `skill_registry.md` has been consulted and no matching skill found
* [ ] At least one skill rejection reason is documented

---

## Step-by-Step Execution Procedure

### Step 1: Confirm the Gap Is Real

**Questions to answer:**
- Was the intent parsed correctly? Could a different intent interpretation match an existing skill?
- Was the skill registry searched completely, including all phases?
- Is this a misuse of an existing skill, or a genuine missing capability?

**Actions:**
- [ ] Re-read the structured intent model for any ambiguity
- [ ] Search `skill_registry.md` across all phases for any partial match
- [ ] If a partial match exists, assess whether extending it is preferable to creating a new skill
- [ ] Confirm: no existing skill covers this capability, even partially

**Red flags / Warning signs:**
- The gap appears very similar to an existing skill with a slightly different name
- The intent was parsed very broadly and a narrower interpretation would match existing skills
- The request is a one-off edge case, not a reusable capability pattern

**Decision points:**
- If a partial match exists and extension is feasible → recommend extension, not new skill creation
- If the intent is ambiguous → escalate to intent-parsing for re-clarification before continuing
- If gap is confirmed → proceed to Step 2

---

### Step 2: Classify the Gap

**Questions to answer:**
- Which phase does this capability belong to (1–7)?
- Is this a net-new domain, or a missing skill within an existing phase?
- What is the risk level of operating without this skill (LOW / MEDIUM / HIGH)?

**Actions:**
- [ ] Map the missing capability to the correct phase using `skill_overview.md`
- [ ] Determine whether this is a new phase addition or a gap within an existing phase
- [ ] Assess risk: what happens if execution proceeds without this skill?

**Red flags / Warning signs:**
- Gap spans multiple phases — may indicate a design problem rather than a missing skill
- Proposed skill duplicates responsibility of an existing skill

**Decision points:**
- If risk = HIGH → immediately escalate to decision-confirmation-gate; do not attempt to proceed without the skill
- If risk = MEDIUM → note in gap report; flag for controlled extension
- If risk = LOW → document gap, propose extension, allow limited fallback if explicitly approved

---

### Step 3: Produce the New Skill Outline

**Questions to answer:**
- What is the canonical kebab-case name for the proposed skill?
- What rules from `rules_overview.md` are likely to apply?
- What are the likely `depends_on` and `flags_skills` relationships?

**Actions:**
- [ ] Draft a kebab-case skill name (verify uniqueness in `skill_registry.md`)
- [ ] Write a SCOPE line (single line, ≤150 chars)
- [ ] Write a TRIGGER condition
- [ ] Draft 3–5 likely ENFORCE points based on the identified capability
- [ ] Identify candidate rule IDs from `rules_overview.md`
- [ ] Identify likely phase and category

**Red flags / Warning signs:**
- Proposed name conflicts with an existing skill name
- Proposed SCOPE overlaps significantly with an existing skill
- No applicable rules can be identified — may indicate the capability is outside the framework's scope

**Decision points:**
- If name conflicts → generate an alternative and note both in the outline
- If SCOPE overlaps > 50% with an existing skill → recommend skill extension instead

---

### Step 4: Escalate Before Any Registry Change

**Questions to answer:**
- Has the gap been clearly communicated to the user or framework maintainer?
- Is the proposed skill outline sufficient for an informed approval decision?

**Actions:**
- [ ] Flag decision-confirmation-gate with the gap report and skill outline
- [ ] Flag engineering-decision-logging to record the gap identification
- [ ] Block any registry update until confirmation is received
- [ ] Communicate clearly: execution is blocked and why, and what the path forward is

**Decision points:**
- Confirmation approved → pass skill outline to skill authoring workflow; flag skill-validation after authoring
- Confirmation rejected → document the rejection, do not create the skill, surface alternative approaches

---

### Final Step: Generate Gap Analysis Report

**Report/Output structure:**

```markdown
## Skill Gap Detection Report

**Intent:** [Parsed intent summary]
**Date:** [YYYY-MM-DD]
**Status:** 🔴 GAP CONFIRMED — Execution blocked pending skill creation

### Gap Analysis
**Missing capability:** [Description of what no existing skill covers]
**Skills considered and rejected:**
| Skill | Reason Rejected |
|-------|-----------------|
| [skill-name] | [Specific reason] |

**Gap classification:**
- Phase: [Phase N — Name]
- Risk level without skill: [LOW / MEDIUM / HIGH]
- Recommended approach: [New skill / Extend existing skill]

### Proposed Skill Outline
```yaml
name: [proposed-kebab-case-name]
category: [Category]
priority: [High / Medium / Low]
depends_on: [candidate dependencies]
rules_applied: [candidate rule IDs]
SCOPE: [Single-line scope description]
TRIGGER: [When this skill activates]
```

### Skills Flagged for Follow-up
- **decision-confirmation-gate**: Approval required before creating new skill or updating registry
- **engineering-decision-logging**: Gap identification and resolution must be recorded

### Required Actions
- [ ] Review proposed skill outline
- [ ] Confirm or reject new skill creation via decision-confirmation-gate
- [ ] If approved: author skill using skill_ai_spec_template and skill_human_spec_template
- [ ] Run skill-validation before adding to skill_registry.md
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Confirm the gap is genuine — rule out misuse or incorrect intent parsing first
2. Classify the gap by phase, risk level, and relationship to existing skills
3. Produce a structured new skill outline ready for authoring
4. Escalate to Decision Confirmation Gate before any registry change
5. Prevent improvised or ad hoc behavior outside the registered skill boundary

**Quality criteria:**

* Gap is only declared confirmed after full registry search and intent re-validation
* New skill outline is formatted to the AI spec template and passes basic structural review
* No registry change occurs without an explicit approved confirmation

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-1: Requirement Validation**
  Before declaring a gap, validate that the intent is correctly parsed and that no existing skill covers the request. A false gap declaration wastes governance resources and fragments the registry unnecessarily.

* **PS-3: Scope Control**
  Proposed new skills must fit within an existing phase or a clearly justified new category. Ad hoc skill proliferation without phase governance is prohibited.

### Decision & Tradeoff Rules

* **DT-2: Confirmation Gate**
  Every confirmed gap that would result in new skill creation must pass through the Decision Confirmation Gate. No registry extension is self-approved by this skill.

---

## Tradeoff Handling

### Tradeoff 1: Expanding Capability vs. Registry Discipline

**Scenario:** A genuine gap exists, but creating a new skill would add a very narrow, one-off capability.

```
IF gap_is_confirmed AND capability_is_narrow AND reuse_likelihood = LOW
→ Flag decision-confirmation-gate with recommendation to extend existing skill instead
→ Surface the tradeoff explicitly: fragmentation risk vs. unmet need
→ Log via DT-1
→ Fallback: Allow user to decide; do not create skill without approval
```

### Tradeoff 2: Immediate Improvisation vs. Structured Extension

**Scenario:** The user needs an answer now, but no registered skill covers the topic.

```
IF gap_confirmed AND user_needs_immediate_response
→ Surface gap clearly and explain why improvisation is prohibited
→ Offer to provide a best-effort response explicitly labeled as outside registered skills
→ Flag decision-confirmation-gate for any action that modifies state
→ Do not silently improvise
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Gap Confirmed but User Rejects New Skill Creation

**Trigger:** Decision Confirmation Gate returns a rejection — user does not want to create a new skill.

**Action:**
- Document the rejection in engineering-decision-logging
- Communicate clearly what tasks cannot be fulfilled without the skill
- Offer available partial alternatives using existing skills

---

### Escalation Scenario 2: Proposed Skill SCOPE Overlaps with Existing Skill

**Trigger:** During outline drafting, the proposed SCOPE significantly overlaps with a registered skill.

**Action:**
- Do not propose a new skill — recommend extension of the existing one
- Flag skill-version-management if an existing skill requires significant extension

---

### When to halt execution:

* Gap is confirmed with HIGH risk and no registered skill can even partially cover the task — halt and require explicit user decision before proceeding
* The same gap has been identified and rejected multiple times — document and surface for framework governance review

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Skill Gap Detection sits on the ORCH-1 ON FAILURE path. It activates only when the orchestrator's skill selection fails. Its output feeds the skill authoring workflow (via the new skill outline) and the Decision Confirmation Gate (via the escalation flag).

### How This Skill Integrates

**Integration workflow:**
1. **Orchestrator** fails to map intent to a registered skill → triggers skill-gap-detection
2. Skill-gap-detection confirms gap, classifies it, produces outline
3. Flags decision-confirmation-gate for registry extension approval
4. If approved: skill authoring proceeds → skill-validation gates → registry updated
5. Flags engineering-decision-logging to record the gap and the resolution decision

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Gap confirmed, new skill outline ready | decision-confirmation-gate | Registry extension requires explicit approval |
| Gap identified and resolved (either direction) | engineering-decision-logging | All registry changes and gap decisions must be recorded |
| Existing skill needs significant extension | skill-version-management | Extension is a version bump, not a new skill |

---

## Related Skills

**Skills this skill depends on:**

* **intent-parsing** — Provides the structured intent model that is the primary input. Must run before gap detection can begin.

**Skills this skill cooperates with:**

* **skill-orchestration** — Triggers skill-gap-detection when no skill match is found during Stage 2
* **skill-validation** — Receives the new skill outline after authoring to gate registry admission

**Skills this skill may invoke/flag:**

* **decision-confirmation-gate** *(# not yet created)* — Always flagged when a new skill is proposed
* **engineering-decision-logging** *(# not yet created)* — Flagged to record the gap and resolution
* **skill-version-management** *(# not yet created)* — Flagged when extension of an existing skill is recommended

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never improvise outside registered skills without explicit user-approved escalation
* [ ] Always confirm the gap is genuine before escalating — prevent false positives
* [ ] Always flag decision-confirmation-gate before any registry change
* [ ] Always flag engineering-decision-logging to record gap identification
* [ ] Produce a structured gap report and skill outline — no informal gap declarations

**Audit trail requirements:**

* Every gap detection run must produce a persisted gap report
* Registry extension decisions (approved or rejected) must be logged via engineering-decision-logging
* Rejected gaps must be documented to prevent repeated false escalations

---

## Example Use Cases

### Example 1: Missing DevOps Skill for Cost Optimization

**Scenario:** User asks to analyze cloud infrastructure costs and recommend optimizations. No Phase 4 skill covers cost analysis.

**Inputs provided:**
- Intent: "Analyze AWS cost allocation and recommend optimizations"
- `skill_registry.md`: Phase 4 skills checked — no cost-optimization skill

**Execution steps:**
1. Confirm gap — full registry search finds no match; intent re-validated as unambiguous
2. Classify — Phase 4 DevOps, MEDIUM risk (informational output, not destructive)
3. Produce outline: `cost-optimization-analysis`, rules: `PC-4`, `PS-2`, `DT-1`
4. Flag decision-confirmation-gate and engineering-decision-logging

**Result:** 🔴 GAP CONFIRMED — skill outline produced, escalated for approval.

---

### Example 2: Near-Miss — Existing Skill Covers the Gap

**Scenario:** User asks to check library licenses. `dependency-safety-integration` is in Phase 1.

**Execution steps:**
1. Re-read intent — "check library license compatibility"
2. Search registry — `dependency-safety-integration` references `CL-2: License Validation`
3. Assess match — skill SCOPE covers dependency safety including license; gap is NOT confirmed

**Result:** Gap NOT confirmed — redirect to `dependency-safety-integration`.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Declaring a gap without first re-searching the registry and re-validating intent
✅ **Correct approach:** Gap confirmation requires full registry search and intent re-validation as Step 1.

❌ **Anti-pattern 2:** Improvising a response when no skill matches, without surfacing the gap
✅ **Correct approach:** Always surface the gap explicitly. Silent improvisation is prohibited.

❌ **Anti-pattern 3:** Creating a new skill outline that duplicates an existing skill's SCOPE
✅ **Correct approach:** Check for SCOPE overlap in Step 3; recommend extension if >50% overlap.

❌ **Anti-pattern 4:** Proposing a new skill without flagging decision-confirmation-gate
✅ **Correct approach:** Every proposed registry change requires explicit confirmation — always flag.

❌ **Anti-pattern 5:** Over-fragmenting the registry by creating very narrow single-use skills
✅ **Correct approach:** Per PS-3, proposed skills must represent reusable capabilities, not one-off edge cases.

❌ **Anti-pattern 6:** Proceeding with execution using improvised behavior after gap is confirmed
✅ **Correct approach:** Block execution and surface gap clearly. Do not silently fill gaps with undefined behavior.

❌ **Anti-pattern 7:** Treating a skill's partial match as a confirmed gap
✅ **Correct approach:** If a skill partially covers the intent, recommend extension — not new skill creation.

❌ **Anti-pattern 8:** Failing to log the gap identification and resolution in engineering-decision-logging
✅ **Correct approach:** All gap events (confirmed, rejected, resolved) must be logged for audit trail.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Selecting between multiple valid registered skills — that is Skill Orchestration
* ❌ Validating the structure of the new skill after authoring — that is Skill Validation
* ❌ Writing or authoring the new skill — that is the skill generation workflow
* ❌ Approving its own proposed registry changes — that is Decision Confirmation Gate

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Always validate the gap before escalating** — a false gap declaration wastes governance overhead
2. **Be conservative about proposing new skills** — extension is preferred over fragmentation
3. **Never improvise silently** — if execution cannot proceed, say so explicitly with a clear path forward
4. **Produce a complete outline, not just a name** — the gap report must include enough for a human to make an informed approval decision
5. **Always flag both confirmation-gate and decision-logging** — both are required for every confirmed gap

**Output format preferences:**

* Structured gap report with evidence section
* Proposed skill outline in YAML format
* Clear escalation flags with reasons

**Tone and approach:**

* Be definitive — either the gap is confirmed or it isn't; avoid hedging
* Be constructive — a gap report should enable resolution, not just report failure
* Be governed — every output must be framed within the "confirmation before action" model

---

## Metadata Summary

```yaml
name: skill_gap_detection
category: Orchestration & Governance
priority: High
depends_on: [intent-parsing]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]
rules_applied: [PS-1, PS-3, DT-2]
documents_needed: [skill_registry, skill_overview, skill_ai_spec_template]
tags: [gap-detection, governance, registry, capability, escalation]
```

**Key relationships:**
- Depends on: intent-parsing (structured intent model required to assess gap)
- Flags: decision-confirmation-gate (always, before registry change), engineering-decision-logging (always, to record gap), skill-version-management (when extension preferred)
- Governed by: PS-1 (validate gap before escalating), PS-3 (no ad hoc registry expansion), DT-2 (confirmation required for all registry changes)

---

*End of Skill Gap Detection Human Spec*
