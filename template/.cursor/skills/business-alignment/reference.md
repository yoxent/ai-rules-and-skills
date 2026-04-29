```yaml
---
name: business_alignment
description: Validates that features, technical decisions, and deliverables align with strategic objectives and KPIs; flags misalignments before they consume resources.
version: 1.1.0
category: Product
tags: [alignment, strategy, okrs, business-goals, governance]
priority: Medium

depends_on: []
flags_skills: [roadmap-awareness, stakeholder-communication, priority-negotiation]

inputs: [product-roadmap, okrs, strategic-objectives, in-progress-features, technical-decisions]
outputs: [alignment-report, gap-identification, corrective-recommendations]

rules_applied:
  - PS-1
  - PS-4
  - DT-3
  - CL-4

execution_context: Triggered at planning cadence (quarterly OKR review, sprint planning) or when a feature or technical decision's strategic relevance is unclear. Runs before significant resource commitment is made.
---
```

---

# Skill: Business Alignment

---

## Purpose

**What this skill does:**
Validates that the work being planned and executed connects to the organisation's stated strategic objectives and KPIs. Identifies features and technical decisions that don't serve current business goals, flags misalignments before significant investment is made, and coordinates alignment reviews with Product Management and Leadership.

Technically correct work that doesn't serve business goals is waste. Strategic misalignment discovered after significant delivery investment is expensive to reverse. Early alignment checks prevent the most costly class of misdirected effort — work that is done well but shouldn't have been done at all.

Gives engineering teams clear context for why they are building what they are building. Teams with strategic context make better local design decisions and are less likely to over-engineer in directions the business isn't heading.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Quarterly OKR review — validating the backlog maps to current OKRs
* Sprint planning — checking that sprint items connect to a strategic initiative
* A feature's business justification is unclear or stated as "we've always done it this way"
* A technical decision (refactor, architectural change) needs strategic justification
* A feature is technically sound but its connection to business goals is tenuous
* An ethical concern about a feature's alignment with organisational values is raised
* `roadmap-awareness` detects items with no initiative mapping that require strategic assessment

### Do NOT use this skill for:

* Sprint-level scope enforcement — use `scope-control`
* Roadmap milestone tracking — use `roadmap-awareness`
* Individual feature feasibility — use `feature-validation`
* Stakeholder priority conflicts — use `priority-negotiation`

---

## Inputs

**Required inputs:**

* **Strategic objectives / OKRs** — The current cycle's stated business goals. Required to assess alignment.
* **Features or decisions being assessed** — The work items to be evaluated for strategic relevance.

**Optional inputs:**

* **Product roadmap** — Provides the intermediate layer between OKRs and sprint items.
* **Feature backlog** — Used for full backlog alignment review at planning cadence.
* **Historical alignment decisions** — Used to check consistency with prior alignment rulings.

---

## Outputs

**Primary outputs:**

* **Alignment report** — Per-item assessment of strategic relevance: ALIGNED / PARTIAL / MISALIGNED.
* **Gap identification** — Specific misalignments with the strategic objective or OKR not served.
* **Corrective recommendations** — Defer, descope, reframe, or escalate for strategic reassessment.

---

## Preconditions

**Conditions that must be met before execution:**

* Current strategic objectives or OKRs are accessible and up to date
* The features or decisions to be assessed are defined
* The planning horizon is known (sprint, quarter, release)

---

## Step-by-Step Execution Procedure

### Step 1: Load and Validate Strategic Objectives

**Actions:**
- [ ] Confirm OKRs or strategic objectives are current — check cycle date
- [ ] List active objectives with their key results or success metrics
- [ ] Note any objectives recently deprioritised or superseded
- [ ] If OKRs are stale or unavailable: flag the assessment as provisional; request refresh before acting on findings

**Red flags:**
- OKRs not updated at the start of the current cycle — stale OKRs produce false alignment signals
- Objectives stated without measurable key results — cannot assess alignment without a measurable target

---

### Step 2: Map Each Item to a Strategic Objective

**Actions:**
- [ ] For each feature or decision: identify which OKR or strategic objective it serves
- [ ] Classify alignment: ALIGNED (clear direct contribution), PARTIAL (indirect or weak contribution), MISALIGNED (no contribution to any active objective)
- [ ] For PARTIAL: assess whether the contribution is strong enough to justify the resource cost
- [ ] For MISALIGNED: document why the item doesn't serve any current objective

**Red flags:**
- Item justified as "it's good engineering" with no business goal connection — MISALIGNED
- Item maps to a deprioritised or previous-cycle objective — treat as MISALIGNED unless objective reinstated
- Multiple items competing for the same OKR with no prioritisation — flag `priority-negotiation`

---

### Step 3: Ethical and Values Alignment Check (CL-4)

**Actions:**
- [ ] For each item: check whether it conflicts with organisational values, stated ethical commitments, or applicable ethical guidelines
- [ ] Flag immediately if conflict detected — CL-4 is unconditional regardless of business justification
- [ ] Document the specific value or commitment in conflict

---

### Step 4: Generate Recommendations

**Actions:**
- [ ] ALIGNED items: confirm and proceed
- [ ] PARTIAL items: recommend reframing the item's goal to strengthen OKR connection, or deferral if contribution is too weak
- [ ] MISALIGNED items: recommend deferral to next planning cycle with a clear resubmission path, or archival if no foreseeable strategic fit
- [ ] For all recommendations: state which OKR would need to exist or be elevated for the item to become strategically relevant

---

### Step 5: Escalate and Document

**Actions:**
- [ ] Flag `roadmap-awareness` for MISALIGNED items requiring planning-cycle routing
- [ ] Flag `stakeholder-communication` when findings require leadership awareness
- [ ] Log all alignment decisions with rationale and reviewer per PS-4
- [ ] Note items where alignment is disputed — do not resolve disputes unilaterally; escalate per DT-3

---

### Final Step: Generate Alignment Report

```markdown
## Business Alignment Report

**Scope:** [Backlog / Sprint / Specific feature or decision]
**Date:** [YYYY-MM-DD]
**OKR Cycle:** [Q and Year]
**Status:** ✅ ALIGNED / ⚠️ PARTIAL ALIGNMENT / ❌ MISALIGNMENT DETECTED

### Alignment Summary
| Item | OKR / Objective | Alignment | Recommendation |
|------|----------------|-----------|----------------|
| ...  | ...            | ✅/⚠️/❌  | Proceed / Reframe / Defer / Archive |

### Misalignment Details
- [Item]: Not connected to any active OKR. Nearest candidate: [OKR X] — requires [gap description] to qualify. Recommendation: defer to next planning cycle.

### Ethical / Values Findings (CL-4)
- [Item if applicable]: Conflicts with [value/commitment]. → flag:risk-analysis. Block pending review.

### Disputed Alignment
- [Item]: Alignment disputed between [stakeholder A] and [stakeholder B]. → Escalate to priority-negotiation.

### Skills Flagged
- 📋 **roadmap-awareness**: [Items requiring planning-cycle routing]
- 📢 **stakeholder-communication**: [Misalignments requiring leadership notification]
- 🤝 **priority-negotiation**: [Disputes requiring structured resolution]

### Overall Assessment
[Summary of alignment health: % aligned, key gaps, recommended actions before next commitment]
```

---

## Core Responsibilities

1. Validate OKR currency before use — stale OKRs produce false alignment signals
2. Classify every item as ALIGNED / PARTIAL / MISALIGNED against active objectives
3. Flag CL-4 ethical and values conflicts immediately and unconditionally
4. Provide specific corrective recommendations — not just misalignment labels
5. Escalate alignment disputes via DT-3; do not resolve unilaterally

---

## Constraints (Rules Applied)

* **PS-1:** Features validated against business goals, not just technical soundness. Technical correctness alone does not constitute alignment.
* **PS-4:** All alignment decisions and their rationale documented with reviewer identity.
* **DT-3:** Business alignment vs tactical execution conflicts escalated explicitly — not absorbed or decided by seniority.
* **CL-4:** Ethical conflicts with organisational values flagged unconditionally regardless of business justification.

---

## Tradeoff Handling

### Tradeoff 1: Strategic Alignment vs Tactical Agility

**Conflict:** Strict alignment with long-term goals may prevent responding to short-term opportunities.

**Resolution:** Short-term opportunities are not exempt from alignment assessment — they go through the process. If the opportunity is genuine and time-sensitive, fast-track the assessment; still requires OKR mapping or an explicit exception. Log exceptions per DT-1 with business rationale and a time-bound review date. Recurring exceptions signal the OKRs need updating — flag to leadership.

### Tradeoff 2: Alignment Review Overhead vs Delivery Speed

**Conflict:** Alignment checks add governance overhead; teams want to move fast.

**Resolution:** If the item is clearly aligned and low risk, a lightweight check is acceptable (one-line OKR mapping). If the item is uncertain or high-investment, a full alignment review is required. Never skip the alignment check entirely — even a brief mapping is required for governance.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Persistent Misalignment Pattern

**Trigger:** A significant portion of the backlog (>30%) maps to no active OKR.

**Action:**
- Flag `stakeholder-communication` to brief leadership immediately
- Do not attempt to realign the backlog unilaterally — this is a strategic signal
- Recommend an OKR review or backlog grooming session with leadership
- Document the finding with specifics: which items, which OKRs are absent

### Escalation Scenario 2: OKRs Unavailable or Stale

**Trigger:** OKRs have not been updated for the current cycle or are inaccessible.

**Action:**
- Mark all alignment assessments as PROVISIONAL
- Do not block delivery on provisional assessments — flag the risk and proceed with caution
- Request OKR refresh from leadership before the next planning commitment
- Log the provisional status per PS-4

### Escalation Scenario 3: Ethical / Values Conflict (CL-4)

**Trigger:** A feature conflicts with organisational values or stated ethical commitments.

**Action:**
- Flag immediately — before completing the rest of the alignment report
- Block the feature pending ethics/leadership review
- Document the specific conflict with the value or commitment cited
- Cannot be overridden by business justification

### Escalation Scenario 4: Alignment Dispute Between Stakeholders

**Trigger:** Two stakeholders disagree on whether an item is aligned.

**Action:**
- Do not adjudicate — escalate per DT-3
- Document both positions in the report
- Flag `priority-negotiation` for structured resolution

---

### When to halt execution:

* OKRs are unavailable and no proxy strategic objective can be identified — cannot assess alignment without a reference
* CL-4 ethical conflict identified with no review process available

---

## Skill Integration & Orchestration

Runs at planning cadence (quarterly, sprint) or on-demand when strategic relevance is questioned. Feeds `roadmap-awareness` (misaligned items need planning routing) and `stakeholder-communication` (leadership notification). Receives escalations from `roadmap-awareness` on items with no initiative mapping.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Misaligned item needing planning-cycle routing | roadmap-awareness | Formal roadmap process required |
| Misalignment finding requiring leadership notification | stakeholder-communication | Strategic signal needs escalation |
| Alignment disputed between stakeholders | priority-negotiation | Structured priority resolution needed |

---

## Related Skills

* **Receives escalations from:** `roadmap-awareness`
* **Flags:** `roadmap-awareness`, `stakeholder-communication`
* **Cooperates with:** `priority-negotiation` on disputed alignment
* **No hard dependencies**

---

## Governance Hooks

* [ ] OKR currency validated before use — stale OKRs flagged
* [ ] All alignment decisions logged with reviewer per PS-4
* [ ] CL-4 ethical flags are unconditional
* [ ] Alignment disputes escalated per DT-3 — not resolved unilaterally
* [ ] Recurring tactical exceptions flagged to leadership as OKR update signal

---

## Example Use Cases

### Example 1: Quarterly Backlog Alignment Review

**Scenario:** 15-item backlog reviewed against Q3 OKRs: "Improve checkout conversion by 15%" and "Reduce support ticket volume by 20%."

**Findings:** 9 items ALIGNED (checkout and support features), 3 items PARTIAL (infrastructure work with indirect reliability benefit), 3 items MISALIGNED (dark mode, social sharing, admin reporting — no OKR connection).

**Result:** ⚠️ PARTIAL — 3 misaligned items recommended for deferral. `roadmap-awareness` flagged for planning routing.

### Example 2: Single Feature Alignment Check

**Scenario:** Team wants to refactor the notification service for code quality reasons.

**Assessment:** OKR mapping: "Reduce support ticket volume" — indirect at best; refactor has no direct user-facing outcome. Classified PARTIAL with weak contribution. Recommendation: reframe as reliability work under the support-reduction OKR with a specific ticket-volume hypothesis, or defer to a technical health initiative if one exists.

### Example 3: Values Conflict

**Scenario:** Marketing proposes a feature that uses user engagement data to send emotionally manipulative push notifications to re-engage churned users.

**Finding:** CL-4 — conflicts with stated organisational value of user respect and transparent communication. Block immediately. Flag to leadership and ethics review regardless of conversion projection.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Accepting "it's good engineering" as strategic justification
✅ Technical soundness is not business alignment. Every item must connect to a measurable business objective.

❌ **Anti-pattern 2:** Treating a deprioritised previous-cycle OKR as an active objective
✅ Only current-cycle active OKRs count. Items mapping to old objectives are MISALIGNED until the objective is reinstated.

❌ **Anti-pattern 3:** Resolving an alignment dispute by deferring to the senior stakeholder
✅ Disputes escalate to `priority-negotiation` for structured resolution. Seniority is a legitimate input, not a substitute for process.

❌ **Anti-pattern 4:** Using stale OKRs without flagging them as provisional
✅ Stale OKRs must be flagged before use. Alignment assessments built on stale data are unreliable and must be marked PROVISIONAL.

❌ **Anti-pattern 5:** Completing the full report before flagging a CL-4 ethical conflict
✅ CL-4 is flagged immediately on detection — not noted at the end of the report.

❌ **Anti-pattern 6:** Treating recurring tactical exceptions as normal without escalating the pattern
✅ Recurring exceptions are a strategic signal. Flag to leadership after two consecutive occurrences — the OKRs may need updating.

---

## Non-Goals

* ❌ Sprint-level scope gate — use `scope-control`
* ❌ Roadmap milestone tracking — use `roadmap-awareness`
* ❌ Feature feasibility assessment — use `feature-validation`
* ❌ Priority conflict resolution — use `priority-negotiation`
* ❌ Writing or updating OKRs — leadership responsibility, not this skill's scope

---

## Notes for LLM Implementation

1. **OKRs first:** Before assessing a single item, confirm the OKRs are current. A stale reference makes the entire assessment unreliable.
2. **CL-4 before everything else:** If a values or ethical conflict is detected at any point, flag it immediately. Do not finish the report and mention it at the end.
3. **Specific gap articulation:** A misalignment finding must state exactly what OKR would need to exist for the item to become aligned — not just "no OKR." This gives the team a resubmission path.
4. **Don't adjudicate disputes:** When stakeholders disagree on alignment, document both positions and escalate. The business alignment skill determines the facts; `priority-negotiation` resolves the disagreement.

---
