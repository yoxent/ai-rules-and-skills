```yaml
---
name: stakeholder_communication
description: Communicates project status, risks, and decisions to stakeholders at the right level of detail to enable alignment and informed decision-making.
version: 1.0.0
category: Product
tags: [stakeholder, communication, status, escalation, alignment]
priority: Medium

depends_on: []
flags_skills: [risk-analysis, priority-negotiation]

inputs: [progress-reports, risk-assessments, incident-summaries, feature-updates]
outputs: [stakeholder-briefings, escalation-communications, decision-documentation]

rules_applied:
  - PS-4
  - PS-2
  - DT-3

documents_needed: [sprint-outcomes, risk-register, roadmap, decision-log]

execution_context: Triggered when a status update, risk finding, or decision requires stakeholder notification. Runs after risk-analysis or roadmap-awareness produce findings that require communication, or on a regular sprint cadence.
---
```

---

# Skill: Stakeholder Communication

---

## Purpose

**What this skill does:**
Structures and delivers communications to stakeholders about project status, risks, decisions, and incidents. Calibrates detail level to audience technical depth. Ensures critical findings from other skills reach the right people at the right time in a form they can act on.

Misaligned stakeholders make poor decisions or no decisions. Surprises — risks or delays communicated too late — erode trust and create reactive rather than proactive responses. Consistent, well-calibrated communication keeps stakeholders aligned and decisions flowing.

Translates engineering findings into stakeholder-consumable formats, reducing the communication burden on engineers and ensuring technical risks are accurately represented without distortion.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A sprint review or status update is due
* A risk finding from `risk-analysis` or `roadmap-awareness` requires stakeholder notification
* A production incident requires executive briefing
* A major architectural or product decision needs to be communicated with rationale
* A milestone is at risk and stakeholders need to be informed before the miss occurs
* Conflicting stakeholder priorities need to be surfaced and resolved

### Do NOT use this skill for:

* Making decisions — this skill communicates decisions, it does not make them
* Risk assessment — use `risk-analysis` for that
* Priority adjudication — use `priority-negotiation`
* Internal team status updates with no stakeholder impact

---

## Inputs

**Required inputs:**

* **Content to communicate** — Risk findings, decision outcomes, status updates, or incident summaries from upstream skills or direct input.
* **Stakeholder identity and technical depth** — Who is receiving the communication and what level of detail they can act on.

**Optional inputs:**

* **Sprint outcomes and velocity data** — For regular status cadence communications.
* **Decision log** — For communications that reference prior decisions.

---

## Outputs

**Primary outputs:**

* **Stakeholder briefing** — Structured communication calibrated to audience technical depth.
* **Escalation communication** — Urgent notification with impact framing and recommended action for critical issues.
* **Decision documentation** — Record of what was communicated, to whom, when, and what response was received — per PS-4.

---

## Preconditions

**Conditions that must be met before execution:**

* The content to communicate is defined (finding, decision, status, or incident)
* The target stakeholder(s) and their role/technical depth are known
* The required action or outcome from the communication is clear (inform / decide / approve)

---

## Step-by-Step Execution Procedure

### Step 1: Identify Communication Type and Audience

**Actions:**
- [ ] Classify communication type: status update / risk notification / decision briefing / incident report / escalation
- [ ] Identify audience technical depth: executive (business outcomes only) / product (feature-level) / engineering (technical detail permitted)
- [ ] Determine required outcome: inform only / request decision / request approval

**Red flags:**
- No clear required outcome defined — every communication needs a purpose
- Audience technical depth unknown — default to least-technical framing until confirmed

---

### Step 2: Frame Content at Correct Detail Level

**Actions:**
- [ ] Translate all technical content to business-language equivalents per PS-2
- [ ] For executive audience: lead with business impact, then recommendation, then supporting detail
- [ ] For product audience: lead with feature impact and timeline, then technical constraints
- [ ] For engineering audience: technical detail permitted but business context still required
- [ ] Omit technical implementation details unless explicitly requested

**Red flags:**
- Technical jargon present in executive or product-facing communication
- Business impact buried after technical detail — leads must be business-first

---

### Step 3: Structure the Communication

**Actions:**
- [ ] Lead: what happened or what is the status (one sentence)
- [ ] Impact: what does this mean for the business, timeline, or users
- [ ] Options or recommendation (if decision required): structured options per `tradeoff-communication` format
- [ ] Required action: what do you need from the stakeholder (decision / acknowledgment / approval)
- [ ] Deadline: by when is a response needed, and why

**Red flags:**
- No explicit required action — recipients don't know what to do with the communication
- No deadline on decision requests — creates indefinite deferral risk

---

### Step 4: Surface Priority Conflicts (if present)

**Actions:**
- [ ] If communication reveals conflicting priorities between stakeholders, flag explicitly per DT-3
- [ ] Do not embed the conflict in the communication — surface it separately
- [ ] Escalate to `priority-negotiation` if conflict requires structured resolution

---

### Step 5: Document and Confirm

**Actions:**
- [ ] Log: what was communicated, to whom, when, what response was received per PS-4
- [ ] If approval or decision was requested, confirm it was received before proceeding
- [ ] If no response received by deadline, escalate via re-communication with urgency framing

---

### Final Step: Generate Communication

```markdown
## Stakeholder Communication

**Type:** Status Update / Risk Notification / Decision Briefing / Incident Report / Escalation
**Audience:** [Name / Role / Technical depth]
**Date:** [YYYY-MM-DD]
**Required Action:** Inform only / Decide by [date] / Approve by [date]

---

**Summary:** [One sentence — what happened or what is the status]

**Impact:** [Business-language impact on timeline, users, or revenue]

**Options / Recommendation:** [If decision required — structured options or single recommendation]

**Required Action:** [Explicit ask — what the stakeholder needs to do and by when]

---

### Communication Log (PS-4)
- Sent to: [Name / Role]
- Date/time: [YYYY-MM-DD HH:MM]
- Response received: [Yes / No / Pending]
- Response summary: [What was decided or acknowledged]

### Skills Flagged
- [risk-analysis / priority-negotiation if triggered]
```

---

## Core Responsibilities

1. Calibrate every communication to the audience's technical depth — no jargon in executive communications
2. Lead with business impact, not technical detail
3. Every communication has an explicit required action and deadline
4. Log all communications and responses per PS-4
5. Surface priority conflicts to `priority-negotiation` — do not attempt to resolve them in the communication itself

---

## Constraints (Rules Applied)

* **PS-4:** Every major communication logged with recipient, date, content summary, and response received.
* **PS-2:** All risk and technical content expressed in business terms for non-engineering audiences.
* **DT-3:** Stakeholder priority conflicts surfaced explicitly and escalated — not embedded or resolved unilaterally.

---

## Tradeoff Handling

### Tradeoff 1: Transparency vs Information Overload

**Conflict:** Full detail maintains accuracy but overwhelms non-technical stakeholders.

**Resolution:** For executive audiences, provide business impact and recommendation only — offer detail on request. For product audiences, cover feature and timeline impact with technical constraints summarized. For engineering audiences, full technical detail is permitted with business context included. When in doubt, default to less detail with an explicit offer of more.

### Tradeoff 2: Communication Frequency vs Stakeholder Time

**Conflict:** High-frequency updates build alignment but consume stakeholder attention budget.

**Resolution:** For critical risks or milestones at risk, communicate immediately regardless of cadence. For routine status, batch into the regular cadence (sprint review, weekly update). Never delay a critical risk notification to fit a communication cadence.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: No Response to Decision Request

**Trigger:** A decision or approval was requested and no response received by deadline.

**Action:**
- Re-communicate with explicit urgency framing: what is blocked and what is the cost of continued delay
- Escalate to the stakeholder's manager if second attempt also goes unanswered
- Log the escalation per PS-4

### Escalation Scenario 2: Conflicting Stakeholder Responses

**Trigger:** Two stakeholders provide conflicting direction in response to the same communication.

**Action:**
- Do not proceed based on either response
- Flag `priority-negotiation` to resolve the conflict formally
- Document both responses in the communication log

### Escalation Scenario 3: Risk Identified During Communication Preparation

**Trigger:** Preparing the communication reveals a risk that hasn't been formally assessed.

**Action:**
- Flag `risk-analysis` before sending the communication
- Do not communicate an unassessed risk as if it has been analyzed

---

### When to halt execution:

* Target stakeholder cannot be identified
* Required outcome (inform / decide / approve) is undefined
* Communication content contains an unassessed risk — assess via `risk-analysis` first

---

## Skill Integration & Orchestration

Downstream of `risk-analysis`, `roadmap-awareness`, and `feature-validation`. Triggered when those skills produce findings requiring stakeholder notification. Also runs on regular sprint cadence for status updates.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Unassessed risk identified during communication prep | risk-analysis | Formal analysis required before communicating |
| Conflicting stakeholder priorities revealed | priority-negotiation | Structured resolution needed before proceeding |

---

## Related Skills

* **Triggered by:** `risk-analysis`, `roadmap-awareness`, `feature-validation`
* **Flags:** `risk-analysis`, `priority-negotiation`
* **No hard dependencies**

---

## Governance Hooks

* [ ] All communications logged per PS-4 with recipient, date, and response
* [ ] No technical jargon in executive or product-facing communications
* [ ] Every communication has an explicit required action — no "FYI only" for critical findings
* [ ] Priority conflicts escalated to `priority-negotiation`, not resolved in communication

---

## Example Use Cases

### Example 1: Milestone Risk Notification

**Scenario:** A backend dependency slippage puts the Q3 checkout feature release at risk.

**Audience:** Product VP (executive depth).

**Communication:** "The Q3 checkout release is at risk of a 2-week delay due to a payment API dependency not yet delivered by our third-party vendor. Options: (A) delay release by 2 weeks, (B) release without the new payment method and add it in Q4. We need your decision by Friday to begin replanning."

**Result:** Decision received Friday — Option B selected. Logged per PS-4.

### Example 2: Production Incident Briefing

**Scenario:** 45-minute checkout outage affecting 12% of users during peak hours.

**Audience:** CTO + Head of Product (executive depth).

**Communication:** "Today 3–3:45 PM, 12% of users were unable to complete checkout due to a database connection pool exhaustion. No data loss occurred. Estimated revenue impact: $40k. Root cause identified; fix deployed at 3:50 PM. Post-mortem scheduled for Thursday."

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Leading with technical root cause before business impact
✅ Business impact always leads. Root cause in supporting detail or appendix.

❌ **Anti-pattern 2:** Communicating a risk without a recommended action
✅ Every risk communication includes at least one recommended response option.

❌ **Anti-pattern 3:** Logging the communication but not the response received
✅ PS-4 requires both — a communication log without a response is incomplete.

❌ **Anti-pattern 4:** Delaying a critical risk notification to fit a weekly cadence
✅ Critical risks communicate immediately. Cadence is for routine updates only.

❌ **Anti-pattern 5:** Attempting to resolve a stakeholder priority conflict within the communication
✅ Conflicts escalate to `priority-negotiation`. The communication surfaces the conflict; it does not adjudicate it.

❌ **Anti-pattern 6:** Sending a decision request without a deadline
✅ Every decision request includes a deadline and states what is blocked until the decision is made.

---

## Non-Goals

* ❌ Making decisions — this skill communicates and facilitates, does not decide
* ❌ Risk assessment — use `risk-analysis`
* ❌ Priority adjudication — use `priority-negotiation`
* ❌ Internal engineering team communications with no stakeholder impact

---

## Notes for LLM Implementation

1. **Audience-first:** Before writing a word of content, determine the audience's technical depth. Everything else follows from that.
2. **Lead with impact:** The first sentence of any communication is the business impact. Not the cause. Not the background. The impact.
3. **Explicit ask every time:** Never send a communication without a clear required action and deadline. "Keeping you informed" is not sufficient for risk or milestone communications.
4. **Log the response:** A communication without a logged response is incomplete. If the response is "pending," that is the logged state — but it must be noted.

---
