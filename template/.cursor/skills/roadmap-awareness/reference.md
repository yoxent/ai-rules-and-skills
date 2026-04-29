```yaml
---
name: roadmap_awareness
description: Validates that features and development activities align with the product roadmap; flags deviations and conflicts before they cause missed milestones.
version: 1.0.0
category: Product
tags: [roadmap, alignment, milestones, planning, prioritization]
priority: Medium

depends_on: []
flags_skills: [priority-negotiation, stakeholder-communication]

inputs: [product-roadmap, sprint-plan, feature-requests, backlog]
outputs: [alignment-report, deviation-alerts, prioritization-recommendations]

rules_applied:
  - PS-1
  - PS-3
  - PS-4

documents_needed: [product-roadmap, release-schedule, sprint-backlog]

execution_context: Triggered during sprint planning, on new feature requests, or when a roadmap deviation is suspected. Runs before commitment to ensure all planned work maps to a roadmap initiative.
---
```

---

# Skill: Roadmap Awareness

---

## Purpose

**What this skill does:**
Maintains alignment between active development and the product roadmap. Validates that features being planned or built map to a current roadmap initiative, flags deviations before they cause missed milestones, and coordinates schedule changes with stakeholders.

Roadmap drift — features built that don't serve current strategic priorities — is one of the most common sources of wasted engineering capacity. Early detection prevents missed commitments and misallocated effort.

Gives engineering teams clear guardrails on what is in scope for a given cycle. Reduces re-planning overhead from scope surprises discovered mid-sprint.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Sprint planning begins and backlog items need to be validated against the roadmap
* A new feature request arrives and its roadmap alignment is unclear
* A committed milestone is at risk due to scope changes or delivery delays
* A feature is being built that doesn't clearly map to any current roadmap initiative
* A stakeholder requests a roadmap deviation without formal approval
* `requirement-interpretation` or `feature-validation` flags roadmap misalignment

### Do NOT use this skill for:

* Deciding roadmap priorities — use `priority-negotiation` for that
* Communicating roadmap changes to stakeholders — use `stakeholder-communication`
* Sprint capacity planning — use `time-estimation` and `scope-control`
* Technical feasibility of roadmap items — use `feature-validation`

---

## Inputs

**Required inputs:**

* **Product roadmap** — Current roadmap with initiatives, milestones, and release windows.
* **Sprint plan or backlog items** — The work being considered for validation.

**Optional inputs:**

* **Stakeholder priority updates** — Recent changes to business priorities that may not yet be reflected in the roadmap.
* **Delivery velocity data** — Used to assess whether committed milestones are still achievable.

---

## Outputs

**Primary outputs:**

* **Alignment report** — Per-item assessment of whether each backlog item maps to a roadmap initiative.
* **Deviation alerts** — Specific items that don't map, with the gap described and recommended action.
* **Prioritization recommendations** — Suggested ordering of aligned items within current capacity.

---

## Preconditions

**Conditions that must be met before execution:**

* Current product roadmap is accessible
* The backlog items or features to be assessed are defined
* Release windows or milestone dates are known

---

## Step-by-Step Execution Procedure

### Step 1: Load and Validate the Roadmap

**Actions:**
- [ ] Confirm the roadmap is current — check last updated date
- [ ] List active initiatives with their milestone dates and release windows
- [ ] Note any initiatives marked at-risk or recently deprioritized

**Red flags:**
- Roadmap hasn't been updated in more than one sprint cycle — treat as potentially stale
- Conflicting priority signals between roadmap and recent stakeholder communications

---

### Step 2: Map Each Backlog Item to a Roadmap Initiative

**Actions:**
- [ ] For each item, identify: does it map to a current roadmap initiative? (Yes / No / Partial)
- [ ] For partial matches: assess whether the item is an extension of the initiative or scope creep
- [ ] For no match: classify as unplanned work and flag per PS-3

**Red flags:**
- Multiple items with no roadmap mapping — suggests systemic scope drift
- Items that map to a deprioritized initiative being treated as active

---

### Step 3: Assess Milestone Risk

**Actions:**
- [ ] For each active milestone: assess whether committed items are on track
- [ ] Flag any milestone at risk due to scope additions, delivery delays, or dependency changes
- [ ] Quantify the risk: which items are blocking the milestone and why

---

### Step 4: Generate Recommendations

**Actions:**
- [ ] For unaligned items: recommend defer to next planning cycle, or escalate for roadmap addition via `priority-negotiation`
- [ ] For at-risk milestones: recommend scope reduction, timeline adjustment, or stakeholder communication
- [ ] Document all recommendations with roadmap rationale per PS-4

---

### Final Step: Generate Alignment Report

```markdown
## Roadmap Awareness Report

**Sprint/Cycle:** [Identifier]
**Date:** [YYYY-MM-DD]
**Roadmap Version:** [Date or version of roadmap used]
**Status:** ✅ ALIGNED / ⚠️ DEVIATIONS DETECTED / ❌ MILESTONE AT RISK

### Alignment Summary
| Backlog Item | Roadmap Initiative | Alignment | Action |
|---|---|---|---|
| ... | ... | ✅ / ⚠️ / ❌ | Proceed / Defer / Escalate |

### Deviation Alerts
- [Item]: Not mapped to any current initiative → Recommend: [defer/escalate]

### Milestone Risk
- [Milestone]: At risk due to [reason] → Recommended action: [scope reduction/timeline adjustment]

### Skills Flagged
- ⚡ **priority-negotiation**: [Items requiring prioritization decision]
- 📢 **stakeholder-communication**: [Deviations or risks requiring stakeholder notification]

### Recommendations
[Ordered list of recommended actions with roadmap rationale]
```

---

## Core Responsibilities

1. Validate every planned item maps to a current, active roadmap initiative
2. Flag deviations before sprint commitment — not after
3. Assess milestone risk when scope or timeline changes are detected
4. Escalate priority conflicts to `priority-negotiation`; escalate stakeholder notifications to `stakeholder-communication`
5. Document all deviation decisions with rationale per PS-4

---

## Constraints (Rules Applied)

* **PS-1:** Every feature validated against roadmap before sprint commitment.
* **PS-3:** Roadmap deviations flagged and approved explicitly — silent acceptance not permitted.
* **PS-4:** Roadmap changes and deviation decisions documented with rationale and communicated to stakeholders.

---

## Tradeoff Handling

### Tradeoff 1: Long-Term Roadmap Discipline vs Short-Term Urgency

**Conflict:** Urgent stakeholder request conflicts with a committed roadmap initiative.

**Resolution:** Do not accept the request silently — flag per PS-3. Escalate to `priority-negotiation` with both priorities documented. If the stakeholder overrides the roadmap, document the override per PS-4. Log impact on at-risk milestones.

### Tradeoff 2: Flexibility vs Delivery Predictability

**Conflict:** Frequent roadmap changes reduce delivery predictability.

**Resolution:** Document each change with the business reason. After the third change in a cycle, flag `stakeholder-communication` to brief leadership on the predictability risk. Recommend a roadmap freeze policy if the pattern is recurring.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Persistent Roadmap Misalignment

**Trigger:** Multiple items in the current sprint have no roadmap mapping.

**Action:**
- Flag `priority-negotiation` for a full backlog alignment session
- Do not proceed with sprint planning until alignment is resolved or deviations are explicitly approved

### Escalation Scenario 2: Committed Milestone at Risk

**Trigger:** Scope additions or delays put a committed milestone at risk.

**Action:**
- Flag `stakeholder-communication` immediately
- Document the risk: which items are blocking, estimated impact on milestone date
- Recommend: scope reduction OR timeline renegotiation OR explicit stakeholder acceptance of risk

### Escalation Scenario 3: Stale Roadmap

**Trigger:** Roadmap hasn't been updated within the last sprint cycle.

**Action:**
- Flag as potentially stale in the report
- Request roadmap refresh from product management before proceeding with alignment validation
- Do not treat a stale roadmap as authoritative

---

### When to halt execution:

* Roadmap is unavailable or inaccessible — cannot validate alignment without it
* No backlog items or sprint plan provided — nothing to assess

---

## Skill Integration & Orchestration

Runs during sprint planning and on feature intake. Called by `requirement-interpretation` and `feature-validation` when roadmap alignment is uncertain. Feeds `priority-negotiation` (conflict resolution) and `stakeholder-communication` (deviation notifications).

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Priority conflict or unaligned item needing decision | priority-negotiation | Stakeholder prioritization required |
| Deviation or milestone risk needing stakeholder notification | stakeholder-communication | Transparency required per PS-4 |

---

## Related Skills

* **Called by:** `requirement-interpretation`, `feature-validation`
* **Feeds:** `priority-negotiation`, `stakeholder-communication`
* **No hard dependencies**

---

## Governance Hooks

* [ ] No roadmap deviation accepted silently — PS-3 always enforced
* [ ] All deviation decisions documented with rationale per PS-4
* [ ] Stale roadmap flagged before use — do not validate against outdated data

---

## Example Use Cases

### Example 1: Sprint Planning Validation

**Scenario:** 8 backlog items queued for sprint planning. Roadmap has 3 active initiatives.

**Execution:** 6 items map clearly to initiatives. 1 item maps to a deprioritized initiative. 1 item has no mapping.

**Result:** ⚠️ DEVIATIONS DETECTED — deprioritized item deferred; unaligned item escalated to `priority-negotiation`.

### Example 2: Mid-Sprint Feature Request

**Scenario:** Stakeholder requests a dark mode feature mid-sprint. Current roadmap: backend reliability focus.

**Execution:** No roadmap initiative for UI theming. Milestone risk: adding it would delay a backend reliability task.

**Result:** ❌ Flag `priority-negotiation`. Recommend defer to next planning cycle. Document milestone risk per PS-4.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Treating "the stakeholder asked for it" as implicit roadmap alignment
✅ Stakeholder requests must map to an explicit roadmap initiative or be escalated for formal addition.

❌ **Anti-pattern 2:** Validating against a stale roadmap without flagging it
✅ Always check roadmap freshness first. A stale roadmap produces false alignment signals.

❌ **Anti-pattern 3:** Deferring roadmap deviation notification until after sprint commitment
✅ Deviations must be surfaced before commitment — post-commitment discovery is a governance failure.

❌ **Anti-pattern 4:** Accepting a roadmap override verbally without documentation
✅ Every override must be logged per PS-4 with the approver identity and business rationale.

❌ **Anti-pattern 5:** Treating a partial roadmap match as full alignment
✅ Partial matches must be explicitly assessed as extension vs scope creep before proceeding.

---

## Non-Goals

* ❌ Roadmap prioritization decisions — use `priority-negotiation`
* ❌ Stakeholder briefings — use `stakeholder-communication`
* ❌ Sprint capacity planning — use `time-estimation` and `scope-control`
* ❌ Technical feasibility of roadmap items — use `feature-validation`

---

## Notes for LLM Implementation

1. **Roadmap freshness first:** Always check and report the roadmap's last-updated date before using it. A stale roadmap invalidates the entire assessment.
2. **Partial matches are not passes:** A partial match requires explicit assessment. Do not treat it as aligned without reasoning.
3. **Document overrides immediately:** When a stakeholder overrides a roadmap alignment flag, capture it in the report before moving on. Do not defer logging.
4. **Milestone risk is forward-looking:** Don't just assess current state — project whether the milestone remains achievable given the current trajectory.

---
