```yaml
---
name: tradeoff_communication
description: Translates technical tradeoffs, risks, and constraints into business-language options with explicit consequences, enabling informed stakeholder decisions.
version: 1.2.0
category: Product
tags: [tradeoffs, communication, stakeholders, decision-making, business-language]
priority: Medium

depends_on: []
flags_skills: [risk-analysis, priority-negotiation]

inputs: [design-proposals, performance-metrics, resource-estimates, conflict-detected]
outputs: [tradeoff-document, decision-options, stakeholder-briefing]

rules_applied:
  - PS-2
  - PS-4
  - DT-1
  - DT-3

documents_needed: [design-proposals, architecture-constraints, business-goals]

execution_context: Triggered when a technical tradeoff, conflict, or design decision requires stakeholder input. Runs before a decision is locked in; produces options, not unilateral choices.
---
```

---

# Skill: Tradeoff Communication

---

## Purpose

**What this skill does:**
Translates technical tradeoffs into business-language options with explicit consequences. It structures decisions so stakeholders can choose between alternatives without needing to understand the underlying technical implementation. It does not make the decision — it frames it.

Poor tradeoff communication leads to misaligned expectations, surprise technical debt, and stakeholder loss of trust. Structured options with explicit consequences enable faster, better-informed decisions and create an audit trail when the chosen path has future costs.

Forces engineers to articulate the real cost of each option before a decision is made. Prevents unilateral technical choices that have business consequences from going undocumented.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A design decision has two or more valid approaches with meaningfully different business consequences
* A performance optimization would violate a design principle (PC-2)
* Engineering and business priorities are in conflict (DT-3)
* A technical constraint needs to be explained to a non-technical stakeholder before they approve or reject a feature
* A risk-analysis output requires stakeholder-facing communication
* A tradeoff was accepted informally and needs to be documented retroactively

### Do NOT use this skill for:

* Making the decision — this skill frames options; the stakeholder or confirmation gate decides
* Pure technical decisions with no business impact — handle within engineering without escalation
* Generating risk registers — use `risk-analysis` for that
* Sprint prioritization — use `priority-negotiation`

**Execution Context Details:**
Often co-activated with `risk-analysis` (risk findings need communication) or `feature-validation` (HIGH-risk findings need stakeholder framing). Runs before the DT-2 confirmation gate is resolved.

---

## Inputs

**Required inputs:**

* **Design proposals or conflict description** — The technical decision or conflict that needs to be communicated. May come from any upstream skill's output.
* **Options with technical consequences** — At least two alternatives with their known tradeoffs (performance, cost, complexity, risk).

**Optional inputs:**

* **Performance or reliability metrics** — Quantitative data that can be translated into business impact terms.
* **Resource and timeline estimates** — Used to express cost in delivery terms, not engineering effort.
* **Business goals / KPIs** — Used to frame which option best serves stated objectives.

---

## Outputs

**Primary outputs:**

* **Tradeoff document** — Structured options in business language with explicit consequences per option.
* **Decision recommendation** — The option most consistent with stated business priorities, with reasoning. Clearly labeled as a recommendation, not a decision.
* **Decision log entry** — DT-1 compliant record of what was communicated, what was chosen, and who approved.

---

## Preconditions

**Conditions that must be met before execution:**

* At least two distinct options exist — if there is only one viable path, communicate it as a constraint, not a tradeoff
* The business consequence of each option can be articulated (even roughly)
* A stakeholder or decision-maker is identified

---

## Step-by-Step Execution Procedure

### Step 1: Identify the Decision and Options

**Actions:**
- [ ] State the decision to be made in one sentence of business language
- [ ] List each option — minimum two, maximum four (beyond four, reduce or group)
- [ ] For each option, identify: primary benefit, primary cost, reversibility

**Red flags:**
- More than four options — group or prune before communicating; too many options paralyze decisions
- Options that are actually the same decision with different implementation details — consolidate

---

### Step 2: Translate Technical Consequences to Business Impact

**Actions:**
- [ ] Convert technical costs (latency, complexity, coupling) to business terms (user experience, delivery speed, maintenance cost, outage risk)
- [ ] Quantify where possible — "20% slower page load" not "increased latency"
- [ ] Identify which business KPI each option affects and how

**Red flags:**
- Consequence stated as a technical metric with no business translation (violates PS-2)
- Consequence framed as certain when it is an estimate — qualify uncertainty explicitly

---

### Step 3: Identify Priority Conflict (if present)

**Actions:**
- [ ] Determine if the options represent a business vs engineering priority conflict (DT-3)
- [ ] If conflict exists, surface it explicitly — do not embed it in option descriptions
- [ ] Ask which business priority applies: speed, correctness, maintainability, cost

**Decision points:**
- If conflict cannot be resolved by available information, escalate to `priority-negotiation`

---

### Step 4: Formulate Recommendation

**Actions:**
- [ ] Identify which option best aligns with stated business goals
- [ ] State the recommendation with reasoning in business terms
- [ ] Label it explicitly as a recommendation, not a decision
- [ ] If no option is clearly better, present options without a recommendation and explain why

---

### Step 5: Log and Confirm

**Actions:**
- [ ] Log the tradeoff per DT-1: options presented, recommendation made, decision received, approver identity
- [ ] If HIGH-risk option is selected, require written confirmation before proceeding per DT-3
- [ ] If decision deferred, log the deferral with a target resolution date

---

### Final Step: Generate Tradeoff Communication Document

```markdown
## Tradeoff Communication

**Decision:** [One sentence in business language]
**Date:** [YYYY-MM-DD]
**Stakeholder:** [Name / role]
**Status:** PENDING / DECIDED / DEFERRED

### Options

**Option A: [Name]**
- Benefit: [Business-language benefit]
- Cost: [Business-language cost]
- Reversible: Yes / No / Partially

**Option B: [Name]**
- Benefit: [Business-language benefit]
- Cost: [Business-language cost]
- Reversible: Yes / No / Partially

### Recommendation
[Option X] — [Reasoning in business terms, referencing business goals or KPIs]
*This is a recommendation. The decision requires stakeholder approval.*

### Decision Log (DT-1)
- Decision made: [Option selected or DEFERRED]
- Approved by: [Name / role]
- Date: [YYYY-MM-DD]
- Conditions: [Any conditions attached to the decision]

### Skills Flagged
- [priority-negotiation if priority conflict detected]
- HIGH-risk option selected → written confirmation required per DT-3 (rule enforcement — no skill flag)
```

---

## Core Responsibilities

1. Translate every technical consequence into a business-language impact before presenting
2. Present options neutrally — do not embed a preference in option framing
3. Provide exactly one recommendation, labeled as such, or explicitly state why none is given
4. Log every decision per DT-1 regardless of outcome
5. Never make the decision unilaterally — frame and recommend only

---

## Constraints (Rules Applied)

* **PS-2:** All consequences must be expressed in business terms. No technical jargon in stakeholder-facing output.
* **PS-4:** Every decision must be documented with rationale and the identity of the approver.
* **DT-1:** All accepted tradeoffs logged — including informal ones retroactively.
* **DT-3:** Business vs engineering priority conflicts surfaced explicitly; not embedded in option framing.

---

## Tradeoff Handling

### Tradeoff 1: Technical Accuracy vs Stakeholder Comprehension

**Conflict:** Full technical detail loses non-technical stakeholders; over-simplification misrepresents.

**Resolution:** For technical stakeholders, include quantitative metrics with business translation. For non-technical stakeholders, use business impact only and offer a technical appendix if requested. Never misrepresent a tradeoff to make it simpler — flag uncertainty explicitly. Log simplification decisions per DT-1.

### Tradeoff 2: Speed of Communication vs Completeness

**Conflict:** Rushed briefings miss context; full analysis delays decisions.

**Resolution:** If the decision is reversible and low risk, an abbreviated format is acceptable. If the decision is irreversible or high risk, the full format is required — no shortcuts. Log any decision to abbreviate per DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Stakeholder Cannot Decide

**Trigger:** Stakeholder defers or requests more information after options are presented.

**Action:**
- Identify the specific missing information blocking the decision
- Retrieve or estimate it; re-present with the gap filled
- If gap cannot be filled, log deferral with blocking reason and target resolution date

### Escalation Scenario 2: Priority Conflict Between Stakeholders

**Trigger:** Two stakeholders favor different options for conflicting reasons.

**Action:**
- Do not adjudicate — escalate to `priority-negotiation`
- Document both positions in the decision log

### Escalation Scenario 3: HIGH-Risk Option Selected

**Trigger:** Stakeholder selects an option classified as HIGH risk.

**Action:**
- Require written confirmation before proceeding per DT-3
- Ensure explicit written confirmation is obtained before proceeding
- Log per DT-1 with approver identity

---

### When to halt execution:

* No stakeholder or decision-maker is identified — do not present options into a vacuum
* Fewer than two distinct options exist — communicate as a constraint instead
* A compliance dimension is identified that hasn't been assessed by `risk-analysis`

---

## Skill Integration & Orchestration

Typically co-activated with `risk-analysis` or `feature-validation`. Outputs feed the DT-2 confirmation gate or `priority-negotiation`. Does not depend on any skill but may consume their outputs as inputs.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Compliance or irreversibility risk not yet assessed | risk-analysis | Formal risk register needed before decision |
| Priority conflict between stakeholders | priority-negotiation | Structured resolution needed |
| HIGH-risk option selected by stakeholder | (no skill flag) | Written confirmation required per DT-3 — handled via rule enforcement |

---

## Related Skills

* **Cooperates with:** `risk-analysis` (consumes risk findings as input), `feature-validation` (consumes HIGH-risk findings)
* **Flags:** `risk-analysis`, `priority-negotiation`
* **No hard dependencies** — entry point for communication tasks

---

## Governance Hooks

* [ ] Every tradeoff document logged per DT-1 before session ends
* [ ] No decision made unilaterally — recommendation only
* [ ] HIGH-risk selections always require written confirmation per DT-3 before proceeding
* [ ] All simplifications of technical content noted in the log

---

## Example Use Cases

### Example 1: Caching Layer Tradeoff

**Scenario:** Engineering proposes adding Redis caching to reduce DB load. Two options: full cache (fast, complex, stale data risk) vs. partial cache (moderate gain, simpler, fresher data).

**Output:** Option A — full cache: "Users get faster responses but may see data up to 60 seconds out of date; adds ~2 weeks delivery." Option B — partial cache: "Moderate speed improvement, data always current, ~1 week delivery." Recommendation: Option B — aligns with stated data-freshness KPI.

### Example 2: Sync vs Async Authorization

**Scenario:** Security team proposes async authorization checks to improve throughput. Risk: failed auth may not block the request in time.

**Output:** Option A (sync): "All unauthorized requests blocked immediately; 15% slower API responses." Option B (async): "Higher throughput; 0.1% risk of briefly serving unauthorized data during race window." Classification: HIGH risk on Option B → require written confirmation per DT-3 if selected.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Presenting a recommendation as the only option
✅ Always present alternatives; the stakeholder must see what they're choosing between.

❌ **Anti-pattern 2:** Using technical metrics without business translation ("p99 latency increases 40ms")
✅ "The slowest 1% of user requests will feel noticeably slower — roughly an extra half-second."

❌ **Anti-pattern 3:** Logging the decision after the fact without recording the approver
✅ DT-1 requires approver identity. Anonymous decisions are not compliant.

❌ **Anti-pattern 4:** Presenting more than four options
✅ Group or prune. Decision fatigue degrades choice quality above four options.

❌ **Anti-pattern 5:** Framing options asymmetrically to steer the decision
✅ Each option gets equal structural treatment: one benefit, one cost, one reversibility assessment.

❌ **Anti-pattern 6:** Proceeding after a verbal "yes" on a HIGH-risk decision without written confirmation
✅ HIGH-risk decisions require written confirmation per DT-3 — verbal approval is not sufficient.

---

## Non-Goals

* ❌ Making the decision — this skill recommends and documents only
* ❌ Generating the risk register — use `risk-analysis`
* ❌ Sprint prioritization — use `priority-negotiation`
* ❌ Technical design of the chosen option — use downstream engineering skills

---

## Notes for LLM Implementation

1. **Business language is non-negotiable:** If you find yourself writing a technical metric, stop and translate it first.
2. **Neutral option framing:** Write option descriptions so neither reads as obviously better before the recommendation section.
3. **One recommendation or none:** Never give two recommendations or a "it depends" recommendation — if it truly depends, ask which business priority applies (DT-3) and use the answer.
4. **Approver identity in every log:** A DT-1 entry without an approver name is incomplete.

---
