```yaml
---
name: priority_negotiation
description: Resolves competing feature priorities to optimize delivery value; structures stakeholder conflicts into explicit criteria-based decisions with documented outcomes.
version: 1.0.0
category: Product
tags: [priority, negotiation, backlog, stakeholders, conflict-resolution]
priority: Medium

depends_on: []
flags_skills: [stakeholder-communication, scope-control]

inputs: [product-roadmap, competing-requests, team-capacity, sprint-commitments]
outputs: [prioritized-backlog, alignment-record, deferral-documentation]

rules_applied:
  - PS-3
  - DT-3
  - PS-4
  - DT-2

documents_needed: [product-roadmap, backlog, stakeholder-priorities, capacity-data]

execution_context: Triggered when competing priorities create a delivery conflict, when scope-control or roadmap-awareness flag an irresolvable conflict, or at planning cadence for backlog ordering.
---
```

---

# Skill: Priority Negotiation

---

## Purpose

**What this skill does:**
Structures and resolves conflicts between competing feature priorities using explicit criteria (business value, strategic alignment, effort, risk). Produces a documented priority decision with rationale that all stakeholders can reference. Does not impose a priority — facilitates the decision with evidence and surfaces it for stakeholder confirmation.

Unresolved priority conflicts cause team paralysis, context switching, and stakeholder frustration. A structured negotiation process produces faster decisions, clearer rationale, and documented commitments that reduce re-litigation.

Protects engineering teams from being pulled in multiple directions simultaneously. A documented priority decision gives the team a single authoritative source of what to work on next.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Two or more stakeholders are requesting conflicting items for the same sprint or resource
* `scope-control` flags a conflict between a new request and a committed deliverable
* `roadmap-awareness` escalates an unaligned item requiring a planning decision
* A high-urgency tactical request is competing with strategic roadmap work
* A backlog ordering decision requires explicit criteria-based reasoning
* An executive escalation overrides a previously agreed priority without documentation

### Do NOT use this skill for:

* Making the priority decision unilaterally — this skill facilitates, does not decide
* Sprint capacity calculation — use `time-estimation`
* Scope gate enforcement — use `scope-control`
* Communicating the priority decision to the team — use `stakeholder-communication`

---

## Inputs

**Required inputs:**

* **Competing items** — The two or more work items or requests in conflict, with their business rationale.
* **Decision criteria** — The prioritization framework to apply (MoSCoW, WSJF, ICE, or explicit business-stated criteria).

**Optional inputs:**

* **Roadmap and strategic objectives** — Used to assess strategic alignment of competing items.
* **Capacity data** — Used to assess whether both items could be accommodated sequentially.
* **Historical priority decisions** — Used to check for consistency with prior decisions.

---

## Outputs

**Primary outputs:**

* **Prioritized decision** — Which item takes priority, with explicit criteria-based rationale.
* **Deferral documentation** — What is deferred, to when, and what conditions would change the priority.
* **Alignment record** — Which stakeholders agreed to the decision, documented per PS-4.

---

## Preconditions

**Conditions that must be met before execution:**

* At least two competing items with business rationale are defined
* A prioritization framework or explicit business criteria are available or can be established
* Decision-making stakeholders are identified and available

---

## Step-by-Step Execution Procedure

### Step 1: Define the Conflict Explicitly

**Actions:**
- [ ] State the conflict in one sentence: "Item A and Item B are competing for [resource/slot/sprint] and both cannot be accommodated."
- [ ] Document the business rationale for each item
- [ ] Identify who is advocating for each item and their authority level

**Red flags:**
- Conflict is framed as "A vs B" without business rationale for either — cannot prioritize without rationale
- One item has a stakeholder advocate and the other does not — asymmetric representation; surface this

---

### Step 2: Select and Apply Prioritization Criteria

**Actions:**
- [ ] If a framework is specified (MoSCoW, WSJF, ICE): apply it consistently to both items
- [ ] If no framework specified: use default criteria — business value, strategic alignment, effort, time-sensitivity
- [ ] Score or rank each item on each criterion
- [ ] Produce a priority recommendation based on the scoring

**Red flags:**
- Criteria applied asymmetrically (more lenient standard applied to one item)
- "Executive urgency" used as the sole criterion without business value assessment
- Criteria changed mid-evaluation to produce a preferred outcome

---

### Step 3: Surface and Confirm the Decision

**Actions:**
- [ ] Present the recommendation with scoring rationale — not just the conclusion
- [ ] Identify which stakeholders must confirm the decision per DT-2 if a committed item is affected
- [ ] Obtain explicit confirmation — verbal agreement is not sufficient for committed-item changes
- [ ] If stakeholders cannot agree: escalate to the next decision authority; do not absorb the conflict

**Red flags:**
- Decision accepted by one stakeholder without consultation of the other affected party
- Confirmation obtained verbally on a decision that changes a committed milestone

---

### Step 4: Document Deferral Conditions

**Actions:**
- [ ] For the deferred item: state when it will be reconsidered (next sprint, next quarter, specific trigger)
- [ ] State what conditions would reprioritize it (e.g., "if metric X drops below Y, this is re-elevated")
- [ ] Log the deferral per PS-4

---

### Step 5: Communicate and Handoff

**Actions:**
- [ ] Flag `stakeholder-communication` to notify all affected parties of the decision
- [ ] Flag `scope-control` if the decision changes an active sprint commitment
- [ ] Log the complete decision record per PS-4: items considered, criteria used, scores, decision, approvers, deferral conditions

---

### Final Step: Generate Priority Decision Record

```markdown
## Priority Negotiation Record

**Conflict:** [One sentence description]
**Date:** [YYYY-MM-DD]
**Decision authority:** [Name / Role]

### Competing Items
| Item | Business Rationale | Advocate |
|------|--------------------|----------|
| A    | ...                | ...      |
| B    | ...                | ...      |

### Prioritization Criteria and Scores
| Criterion | Item A | Item B |
|-----------|--------|--------|
| Business value | H/M/L | H/M/L |
| Strategic alignment | H/M/L | H/M/L |
| Effort | H/M/L | H/M/L |
| Time-sensitivity | H/M/L | H/M/L |

### Decision
**Priority: [Item A / Item B]**
Rationale: [Criteria-based reasoning]

### Deferral
- Deferred: [Item]
- Next review: [Sprint / Date / Trigger condition]

### Approval Record (PS-4 / DT-2)
- Agreed by: [Stakeholder names and roles]
- Date confirmed: [YYYY-MM-DD]
- Method: [Written / Documented meeting / Async approval]

### Skills Flagged
- [stakeholder-communication / scope-control if triggered]
```

---

## Core Responsibilities

1. State the conflict explicitly before attempting resolution — ambiguous conflicts cannot be resolved
2. Apply prioritization criteria consistently and symmetrically to all competing items
3. Obtain explicit stakeholder confirmation — verbal agreement is not sufficient for committed-item changes per DT-2
4. Document deferral conditions — not just what was deferred, but when and how it gets reconsidered
5. Never absorb an unresolvable conflict — escalate to the next decision authority

---

## Constraints (Rules Applied)

* **PS-3:** Priority decisions must not silently expand scope. If the winning item adds scope, route to `scope-control`.
* **DT-3:** Priority conflicts escalated with explicit criteria — not absorbed or resolved by seniority alone.
* **PS-4:** All priority decisions documented with rationale, criteria scores, and approver identity.
* **DT-2:** Changes to committed items require explicit stakeholder confirmation before proceeding.

---

## Tradeoff Handling

### Tradeoff 1: Business Urgency vs Technical Feasibility

**Conflict:** Urgent business request conflicts with technical readiness or dependency.

**Resolution:** Surface the technical constraint as a criterion in the scoring — not a veto. Offer options: (A) proceed with urgency with technical risk accepted, or (B) defer until feasible. Require stakeholder selection — do not resolve this tradeoff unilaterally. Log per DT-1 if high technical risk is accepted under business pressure.

### Tradeoff 2: Short-Term Value vs Long-Term Strategy

**Conflict:** High-urgency tactical item displaces strategic roadmap work.

**Resolution:** Score both on strategic alignment criterion — tactical items typically score LOW. Surface the strategic cost explicitly: "Choosing A delays B by N sprints." Require explicit acknowledgment of the strategic cost from the decision authority. Log per DT-1 if strategic work is repeatedly displaced by tactical requests.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Stakeholders Cannot Reach Agreement

**Trigger:** Structured negotiation produces a recommendation but stakeholders cannot agree on it.

**Action:**
- Document both positions and the recommendation in the decision record
- Escalate to the next decision authority (typically VP or C-suite)
- Do not continue work on either item until the conflict is resolved
- Do not proceed based on the last-speaking stakeholder's preference

### Escalation Scenario 2: Executive Override Without Criteria

**Trigger:** A senior stakeholder overrides a priority decision without engaging with the criteria.

**Action:**
- Accept the override (authority is legitimate)
- Document the override explicitly: who overrode, what was overridden, what criteria were bypassed
- Log per PS-4 and DT-1 — the override is visible in the audit trail
- Flag `stakeholder-communication` to inform affected parties of the change

### Escalation Scenario 3: Repeated Tactical Displacement of Strategic Work

**Trigger:** Strategic roadmap items are displaced by tactical requests for three or more consecutive planning cycles.

**Action:**
- Flag `stakeholder-communication` to brief leadership on the strategic delivery risk
- Recommend a prioritization policy review
- Document the pattern per PS-4

---

### When to halt execution:

* No business rationale provided for any competing item — cannot prioritize without evidence
* Decision authority is unavailable and the conflict is blocking active work
* Committed items are affected and DT-2 confirmation cannot be obtained

---

## Skill Integration & Orchestration

Typically invoked by `scope-control` or `roadmap-awareness` on conflict escalation, or directly on stakeholder requests. Outputs feed `stakeholder-communication` (decision notification) and `scope-control` (if sprint changes result).

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Decision needs communication to affected parties | stakeholder-communication | Notification and alignment required |
| Decision changes active sprint commitment | scope-control | Scope gate enforcement needed |

---

## Related Skills

* **Invoked by:** `scope-control`, `roadmap-awareness`
* **Flags:** `stakeholder-communication`, `scope-control`
* **No hard dependencies**

---

## Governance Hooks

* [ ] Every priority decision documented with criteria scores and approver per PS-4
* [ ] DT-2 activated for all decisions affecting committed items
* [ ] Executive overrides logged explicitly — not silently applied
* [ ] Deferral conditions documented — not just what was deferred

---

## Example Use Cases

### Example 1: Competing Sprint Items

**Scenario:** PM A wants a reporting dashboard; PM B wants an export feature. Sprint has capacity for one.

**Criteria applied:** Business value (Dashboard: HIGH, Export: MEDIUM), Strategic alignment (both MEDIUM), Effort (Dashboard: HIGH, Export: LOW), Time-sensitivity (Export: HIGH — customer contractual obligation).

**Decision:** Export wins on time-sensitivity criterion. Dashboard deferred to next sprint. Documented and confirmed by both PMs.

### Example 2: Executive Override

**Scenario:** Engineering lead and PM agree on priority order. CTO overrides to prioritize a partner integration.

**Action:** Override accepted. Documented: CTO override, items affected, business rationale given. Prior priority decision logged as superseded. `stakeholder-communication` flagged to notify PM and engineering lead.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Resolving the conflict by seniority alone ("the VP asked for it")
✅ Seniority is a legitimate decision factor but must be applied transparently alongside business rationale. Log the basis for the decision.

❌ **Anti-pattern 2:** Changing the prioritization criteria mid-evaluation to favor a preferred outcome
✅ Criteria are set before scoring. Post-hoc criterion changes are a governance violation — log if they occur.

❌ **Anti-pattern 3:** Proceeding on a verbal agreement to change a committed item
✅ DT-2 requires explicit confirmation for committed-item changes. Verbal is not sufficient.

❌ **Anti-pattern 4:** Deferring an item with no conditions for reconsideration
✅ Every deferral includes a specific next-review point or trigger condition. "We'll look at it later" is not a deferral plan.

❌ **Anti-pattern 5:** Absorbing an unresolvable conflict and letting the team decide
✅ Unresolvable conflicts escalate to the next decision authority. The team is not the decision authority for business priority conflicts.

❌ **Anti-pattern 6:** Silently accepting a recurring pattern of strategic displacement
✅ Three or more consecutive displacements trigger `stakeholder-communication` to leadership. The pattern must be made visible.

---

## Non-Goals

* ❌ Making the priority decision unilaterally — facilitates and documents, does not decide
* ❌ Sprint capacity calculation — use `time-estimation`
* ❌ Scope gate enforcement — use `scope-control`
* ❌ Team-level task assignment — engineering team concern

---

## Notes for LLM Implementation

1. **State the conflict first:** Before any scoring or recommendation, write one sentence that clearly states what is competing for what. If you cannot write that sentence, the conflict is not yet well-defined enough to resolve.
2. **Symmetric criteria application:** Apply the same criteria with the same rigor to every competing item. If you find yourself applying a stricter standard to one item, flag it and recalibrate.
3. **Deferral conditions are required:** Every deferred item must have a specific when (next sprint, next quarter, trigger condition). "Later" is not a deferral plan.
4. **Override logging:** When an executive or authority figure overrides a recommendation, log it explicitly. The override is legitimate; what is not acceptable is allowing it to be invisible in the record.

---
