```yaml
---
name: scope_control
description: Prevents feature creep by enforcing committed sprint scope; evaluates scope change requests; requires explicit approval for additions that affect timeline or capacity.
version: 1.0.0
category: Product
tags: [scope, feature-creep, sprint, capacity, change-management]
priority: High

depends_on: []
flags_skills: [priority-negotiation, stakeholder-communication]

inputs: [committed-scope, change-requests, sprint-capacity, roadmap]
outputs: [scope-decision, change-log, reprioritization-recommendations]

rules_applied:
  - PS-3
  - DT-2
  - MF-2
  - PS-1

documents_needed: [sprint-plan, committed-scope, roadmap, capacity-data]

execution_context: Triggered when a scope addition or change request arrives mid-sprint or at planning time. Runs as a gate before any new work is added to an active sprint commitment.
---
```

---

# Skill: Scope Control

---

## Purpose

**What this skill does:**
Enforces the defined scope for the current delivery window. Evaluates incoming scope change requests against sprint capacity and roadmap alignment. Requires explicit stakeholder approval for any addition that affects committed milestones or capacity. Logs all decisions — approvals, rejections, and deferrals.

Feature creep is one of the leading causes of missed delivery commitments. Each unchecked scope addition shifts the probability of on-time delivery. Explicit scope governance creates delivery predictability and preserves stakeholder trust.

Protects the team from mid-sprint context switching and the hidden cost of scope additions that appear small but carry integration, testing, and deployment overhead.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new feature or task is proposed for addition to an active sprint
* A stakeholder requests a change to a committed deliverable mid-sprint
* A feature's scope has grown during implementation beyond the original ticket
* `feature-validation` detects unauthorized scope expansion in a task breakdown
* Sprint planning is being conducted and backlog items need scope boundary assessment
* A scope compression (cutting features to hit a deadline) is being considered

### Do NOT use this skill for:

* Roadmap prioritization decisions — use `priority-negotiation`
* Scheduling deferred scope into future sprints — use `time-estimation` and `roadmap-awareness`
* Technical debt decisions unrelated to scope — use `technical-debt-management`

---

## Inputs

**Required inputs:**

* **Committed scope** — The agreed sprint backlog at the start of the sprint.
* **Scope change request** — The proposed addition, modification, or removal with business rationale.
* **Sprint capacity** — Current remaining capacity after in-progress work is accounted for.

**Optional inputs:**

* **Roadmap** — Used to assess whether the proposed addition maps to an active initiative per PS-1.
* **Velocity data** — Historical delivery rate to calibrate capacity estimates.

---

## Outputs

**Primary outputs:**

* **Scope decision** — APPROVED / REJECTED / DEFERRED with explicit rationale.
* **Change log** — Record of every scope change request, decision, and approver per PS-3.
* **Reprioritization recommendations** — If approved, what existing work must be deferred to accommodate.

---

## Preconditions

**Conditions that must be met before execution:**

* Committed scope for the current sprint is documented
* The scope change request includes a business rationale
* Sprint capacity data is available or estimable

---

## Step-by-Step Execution Procedure

### Step 1: Characterize the Request

**Actions:**
- [ ] Classify the request: addition / modification / removal / compression
- [ ] Identify business rationale — reject requests with no stated rationale
- [ ] Estimate effort impact: story points or days; include testing and deployment overhead

**Red flags:**
- Request has no business rationale — scope addition without justification is not eligible for approval
- Effort estimate provided by the requester excludes testing or integration — reestimate

---

### Step 2: Assess Capacity Impact

**Actions:**
- [ ] Calculate remaining sprint capacity after in-progress work
- [ ] Determine if the request fits within remaining capacity
- [ ] If it doesn't fit: identify what existing committed work must be deferred to accommodate

**Red flags:**
- Request would push total committed work beyond team capacity
- "It'll only take a few hours" estimates that ignore testing, review, and deployment

---

### Step 3: Validate Roadmap Alignment

**Actions:**
- [ ] Verify the proposed addition maps to a current roadmap initiative per PS-1
- [ ] If misaligned: reject and recommend roadmap addition via `roadmap-awareness` before resubmission

---

### Step 4: Apply the Scope Gate

**Actions:**
- [ ] If fits in capacity AND roadmap aligned AND LOW risk: APPROVE with log entry
- [ ] If fits in capacity AND roadmap aligned AND MEDIUM/HIGH risk: require DT-2 stakeholder confirmation
- [ ] If doesn't fit in capacity: REJECT or offer DEFERRED with displacement analysis
- [ ] If roadmap misaligned: REJECT; redirect to planning cycle
- [ ] If scope compression requested: assess which commitments are being cut; log as technical debt if shortcuts introduced per MF-2

**Decision points:**
- Any scope change affecting a committed milestone requires DT-2 regardless of size
- Silent acceptance of scope additions is never permitted per PS-3

---

### Step 5: Log and Communicate

**Actions:**
- [ ] Log every decision: request, decision, rationale, approver, date per PS-3
- [ ] If REJECTED or DEFERRED: flag `stakeholder-communication` to notify requester
- [ ] If priority conflict created: flag `priority-negotiation`
- [ ] If approved with displacement: update sprint backlog to reflect deferral of displaced work

---

### Final Step: Generate Scope Decision Record

```markdown
## Scope Control Decision

**Request:** [Description of proposed scope change]
**Requested by:** [Name / Role]
**Date:** [YYYY-MM-DD]
**Sprint:** [Sprint identifier]

### Assessment
- Request type: Addition / Modification / Removal / Compression
- Business rationale: [Stated / Missing]
- Effort estimate: [N story points / days, including test + deploy]
- Remaining capacity: [N story points / days]
- Roadmap alignment: [Aligned / Misaligned / Unknown]
- Risk level: LOW / MEDIUM / HIGH

### Decision
**APPROVED / REJECTED / DEFERRED**

Rationale: [Specific reason]

Displacement (if approved): [What existing work is deferred to accommodate]
Conditions (if conditional): [What must be true for this to be approved]

### Change Log (PS-3)
- Decision: [APPROVED/REJECTED/DEFERRED]
- Approver: [Name / Role]
- Date: [YYYY-MM-DD]

### Skills Flagged
- [priority-negotiation / stakeholder-communication if triggered]
```

---

## Core Responsibilities

1. Apply the scope gate to every addition request — no silent acceptance per PS-3
2. Require DT-2 confirmation for any change affecting a committed milestone
3. Reject requests with no business rationale
4. Log all scope compression decisions as technical debt per MF-2 when shortcuts are introduced
5. Flag `priority-negotiation` when approval creates a delivery conflict

---

## Constraints (Rules Applied)

* **PS-3:** Every scope addition requires explicit approval — silent acceptance is a violation.
* **DT-2:** Any change affecting committed milestones activates the confirmation gate.
* **MF-2:** Scope compressions that introduce shortcuts or defer quality work logged as technical debt.
* **PS-1:** New scope validated against roadmap before acceptance.

---

## Tradeoff Handling

### Tradeoff 1: Strict Scope vs Flexibility for High-Value Opportunities

**Conflict:** A legitimate urgent request may justify scope adjustment.

**Resolution:** Urgent requests are not exempt from the scope gate — they go through the process faster. If high value and low effort, fast-track DT-2 with an explicit displacement decision. If high value and high effort, displacement analysis is required before approval. Log all fast-tracked decisions per PS-3 with urgency rationale.

### Tradeoff 2: Feature Richness vs Delivery Predictability

**Conflict:** Scope additions improve the product but reduce delivery reliability.

**Resolution:** Surface this tradeoff explicitly to the requester — not a unilateral rejection. Offer: approve with displacement (what gets deferred), or defer to next sprint. Document the tradeoff decision per DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Scope Addition Conflicts With Committed Milestone

**Trigger:** Accepting the request would cause a committed milestone to be missed.

**Action:**
- Flag `priority-negotiation` — stakeholder must choose: new request or committed milestone
- Do not proceed without explicit stakeholder decision
- Document the conflict and the decision per PS-3

### Escalation Scenario 2: Scope Addition Approved Without Displacement Plan

**Trigger:** A scope addition is being accepted but no work has been identified for deferral.

**Action:**
- Block approval
- Require displacement analysis before approval is granted
- Capacity is finite — additions require subtractions

### Escalation Scenario 3: Repeated Scope Additions Pattern

**Trigger:** Three or more scope additions in the same sprint.

**Action:**
- Flag `stakeholder-communication` to brief leadership on scope volatility and its delivery impact
- Recommend a scope freeze for the remainder of the sprint
- Document the pattern per PS-4

---

### When to halt execution:

* Committed scope is not documented — cannot assess additions without a baseline
* Sprint capacity cannot be estimated — cannot assess fit without capacity data

---

## Skill Integration & Orchestration

Acts as a gate during sprint execution. Triggered by `feature-validation` on scope expansion detection, or directly on stakeholder requests. Feeds `priority-negotiation` (conflicts) and `stakeholder-communication` (rejections/deferrals).

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Scope addition conflicts with committed deliverable | priority-negotiation | Stakeholder prioritization decision required |
| Rejection or deferral needs communication | stakeholder-communication | Requester must be notified with rationale |

---

## Related Skills

* **Triggered by:** `feature-validation` (scope expansion detection), direct stakeholder requests
* **Flags:** `priority-negotiation`, `stakeholder-communication`
* **No hard dependencies**

---

## Governance Hooks

* [ ] Every scope addition logged per PS-3 regardless of decision outcome
* [ ] No silent scope acceptance — ever
* [ ] DT-2 activated for all milestone-affecting changes
* [ ] Scope compressions with shortcuts logged as technical debt per MF-2

---

## Example Use Cases

### Example 1: Mid-Sprint Addition — DEFERRED

**Scenario:** PM requests adding a share button to the product detail page mid-sprint. Sprint has 4 points remaining; share button estimated at 5 points including testing.

**Assessment:** Capacity: insufficient. Roadmap: aligned (Q3 Social Features). Risk: LOW.

**Decision:** DEFERRED — insufficient capacity. Scheduled for next sprint. No displacement required.

### Example 2: Urgent Addition — APPROVED WITH DISPLACEMENT

**Scenario:** Legal requires a GDPR consent banner added before end of sprint due to upcoming audit.

**Assessment:** Capacity: fits. Roadmap: compliance initiative. Risk: MEDIUM (legal). Displacement: defers the onboarding tooltip polish task.

**Decision:** APPROVED — legal urgency justifies. DT-2 confirmation obtained. Tooltip task deferred to next sprint and logged.

### Example 3: Scope Compression — TECHNICAL DEBT LOGGED

**Scenario:** To hit the release date, end-to-end tests for the payment flow are proposed to be skipped.

**Assessment:** Scope compression. Shortcuts introduced to testing coverage.

**Decision:** APPROVED (stakeholder accepted risk) with technical debt logged per MF-2. Regression test task created for next sprint.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** "It's just a small change" — accepting scope without assessment
✅ Every addition goes through the gate. Size is not a valid exemption.

❌ **Anti-pattern 2:** Approving an addition without identifying what gets displaced
✅ Capacity is finite. Approval without displacement analysis means something will slip untracked.

❌ **Anti-pattern 3:** Rejecting a scope addition without communicating the decision to the requester
✅ Every rejection triggers `stakeholder-communication`. Silence is not a decision.

❌ **Anti-pattern 4:** Allowing scope additions because the stakeholder is senior
✅ Seniority does not exempt a request from the scope gate. DT-2 applies regardless of requester role.

❌ **Anti-pattern 5:** Skipping the technical debt log on scope compressions
✅ Every shortcut introduced by a scope compression is logged per MF-2 with a recovery plan.

❌ **Anti-pattern 6:** Treating "urgent" as automatic approval
✅ Urgent requests are fast-tracked, not exempt. They still require capacity assessment and displacement analysis.

---

## Non-Goals

* ❌ Roadmap prioritization — use `priority-negotiation`
* ❌ Scheduling deferred work into future sprints — use `time-estimation` and `roadmap-awareness`
* ❌ Technical debt decisions unrelated to scope changes — use `technical-debt-management`

---

## Notes for LLM Implementation

1. **Gate first, discuss second:** Before engaging with the merits of a scope request, apply the gate criteria (capacity, roadmap alignment, milestone impact). The gate determines the process; the merits inform the recommendation within that process.
2. **Displacement is mandatory on approval:** Never approve a scope addition without identifying what gets displaced. Make this explicit and visible in the decision record.
3. **Log everything:** The change log is the audit trail. A scope decision without a log entry didn't happen as far as governance is concerned.
4. **Urgency is not exemption:** When a request is framed as urgent, acknowledge the urgency, then still apply the gate. Urgency determines speed of processing, not whether the gate applies.

---
