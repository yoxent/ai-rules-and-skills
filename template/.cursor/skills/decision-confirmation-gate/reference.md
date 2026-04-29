# Skill Human Spec
# File: decision-confirmation-gate-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: decision_confirmation_gate
description: Requires explicit user confirmation for high-risk, irreversible, or compliance-sensitive decisions before execution proceeds; records all outcomes for audit.
version: 1.0.0
category: Orchestration & Governance
tags: [confirmation, risk, governance, safety, audit]
priority: High

depends_on: [intent-parsing, rule-enforcement-engine]
flags_skills: [engineering-decision-logging]  # not yet created

inputs: [risk-classification, proposed-action, impact-assessment, violation-context]
outputs: [confirmation-request, approval-or-rejection-record, execution-authorization-status]

rules_applied:
  - DT-2  # Confirmation Gate — this skill IS the implementation of DT-2
  - PS-2  # Risk Communication — risk must be presented clearly before requesting confirmation
  - CL-4  # Ethical Risk Flagging — ethically sensitive decisions require explicit approval

documents_needed: []

execution_context: Runs at ORCH-1 Stage 6 (conditional) when risk_level = HIGH, rule_requires_confirmation = TRUE, or irreversible_operation = TRUE; also invoked by rule-enforcement-engine on soft violations and by other skills via escalation.

---
```

---

# Skill: Decision Confirmation Gate

---

## Purpose

**What this skill does:**
The Decision Confirmation Gate is the human-in-the-loop checkpoint for the AI Senior Engineer framework. It activates for any action that is high-risk, irreversible, or explicitly flagged by a rule as requiring confirmation. It presents a clear, complete impact summary to the user, requires an explicit approval or rejection decision, and records the outcome. No high-risk or irreversible action proceeds without passing through this gate.

Prevents catastrophic, irreversible, or non-compliant actions from executing without explicit human awareness and consent. Creates an auditable record of risk decisions that links intent, proposed action, risk classification, and human approval. Builds trust in the AI system by ensuring humans remain in control of consequential decisions.

Provides a single, consistent escalation target for all high-risk decisions across the framework. Removes ad hoc confirmation logic from individual skills — they escalate here instead of implementing their own gates. Ensures the confirmation record is uniform and auditable regardless of which skill triggered the escalation.

---

## When to Use This Skill

### Triggers (Use this skill when):

* ORCH-1 Stage 6 activates: `risk_level = HIGH`
* ORCH-1 Stage 6 activates: `rule_requires_confirmation = TRUE` (any rule declares confirmation required)
* ORCH-1 Stage 6 activates: `irreversible_operation = TRUE`
* `rule-enforcement-engine` escalates a soft violation requiring override
* Any skill's ON_VIOLATION chain escalates to `decision-confirmation-gate`
* A dependency conflict resolution changes task scope and requires user awareness
* Memory management detects a stale constraint requiring re-confirmation

### Do NOT use this skill for:

* Logging the confirmed decision — that is Engineering Decision Logging
* Evaluating whether rules are violated — that is Rule Enforcement Engine
* Determining the risk level of a task — that is Intent Parsing
* Blocking hard constraint violations that permit no override — that is Rule Enforcement Engine (BLOCK, not ESCALATE)

**Execution Context Details:**
Decision Confirmation Gate is invoked by the orchestrator at Stage 6, or by other skills via their ON_VIOLATION / escalation paths. It never self-triggers — it is always called by the orchestrator or another skill. After it completes (approval or rejection), it flags Engineering Decision Logging and returns an execution authorization status to the caller.

---

## Inputs

**Required inputs:**

* **Risk classification** — The risk level assigned at Stage 1 (LOW / MEDIUM / HIGH) and any escalations since
* **Proposed action** — A precise description of what will happen if execution proceeds
* **Impact assessment** — What is affected, what is irreversible, what can be rolled back, and by whom

**Optional inputs:**

* **Violation context** — If invoked by rule-enforcement-engine: the specific rule ID, violated constraint, and override rationale
* **Dependency conflict context** — If invoked due to a conflict resolution changing task scope
* **Alternatives considered** — Other approaches that were evaluated and why they were rejected

**Documents/Context needed:** none required — all necessary context is passed by the invoking skill or orchestrator

---

## Outputs

**Primary outputs:**

* **Confirmation request** — A clear, structured presentation of the proposed action and its risks, formatted for human decision-making
* **Approval or rejection record** — The user's explicit decision with timestamp and context
* **Execution authorization status** — APPROVED (execution may proceed) / REJECTED (execution is aborted or revised)

**Output format:**

* Structured confirmation block with all decision-relevant information
* Binary outcome: APPROVED / REJECTED
* Rejection includes reason captured from user response

**Skill flags (if applicable):**

* Flag **engineering-decision-logging** on every APPROVED confirmation — all approvals must be logged
* Flag **engineering-decision-logging** on REJECTED confirmations only when the rejection reveals an architectural decision or significant risk finding that should be preserved

---

## Preconditions

**Conditions that must be met before execution:**

* The invoking context (orchestrator or skill) has provided a risk classification, proposed action, and impact assessment
* The proposed action is precisely defined — no confirmation can be requested for a vague or undefined action
* The user is present and able to respond (this is a synchronous gate)

**Validation checks:**

* [ ] Proposed action description is specific and unambiguous
* [ ] Impact assessment covers: what changes, what is irreversible, and rollback availability
* [ ] Risk classification is present and matches at least one activation condition

---

## Step-by-Step Execution Procedure

### Step 1: Validate the Confirmation Request

**Questions to answer:**
- Is the proposed action precisely defined? Vague confirmations are not acceptable.
- Is the impact assessment complete — does it cover irreversibility and rollback?
- Is the risk level consistent with the activation condition?

**Actions:**
- [ ] Verify proposed action is specific (not "modify the system" — must state exactly what changes)
- [ ] Verify impact assessment states what is irreversible and what can be recovered
- [ ] Verify at least one activation condition is met (HIGH risk / rule_requires_confirmation / irreversible)

**Red flags / Warning signs:**
- Proposed action is described vaguely — cannot confirm what the user is approving
- Impact assessment omits rollback information — user cannot make an informed decision
- Activation condition is not clearly met — may be a false escalation

**Decision points:**
- If proposed action is vague → request clarification from the invoking skill before presenting to user; do not present an ambiguous confirmation
- If activation condition is not met → log and return PROCEED without gate; do not present unnecessary confirmations

---

### Step 2: Construct the Confirmation Presentation

**Questions to answer:**
- Is the risk communicated in terms the user can act on?
- Are alternatives presented if any exist?
- Is the irreversibility of the action stated explicitly?

**Actions:**
- [ ] Write a plain-language summary of what will happen
- [ ] State explicitly what is irreversible and what can be recovered
- [ ] If a rule violation is the trigger, explain which rule and what constraint would be overridden
- [ ] If alternatives exist, present them clearly
- [ ] State the specific question requiring the user's decision

**Red flags / Warning signs:**
- Technical jargon that obscures the actual risk from a non-technical user
- Missing the "point of no return" — user must know what cannot be undone before confirming

---

### Step 3: Present to User and Await Response

**Actions:**
- [ ] Present the structured confirmation block (see output format below)
- [ ] Await explicit APPROVE or REJECT — do not infer from ambiguous responses
- [ ] If response is ambiguous → ask for clarification; do not default to APPROVE

**Red flags / Warning signs:**
- User response does not clearly indicate approval or rejection
- User approves without acknowledging the irreversibility statement — may require re-presentation

**Decision points:**
- Explicit APPROVE → proceed to Step 4
- Explicit REJECT → proceed to Step 5
- Ambiguous response → re-present with a direct binary question

---

### Step 4: Record Approval and Authorize Execution

**Actions:**
- [ ] Record: decision = APPROVED, timestamp, proposed action, risk level, rule override context (if any)
- [ ] Flag engineering-decision-logging with full approval context
- [ ] Return APPROVED authorization status to caller

---

### Step 5: Record Rejection and Halt Execution

**Actions:**
- [ ] Record: decision = REJECTED, timestamp, reason (if provided by user), proposed action
- [ ] Flag engineering-decision-logging if rejection reveals an architectural finding worth preserving
- [ ] Return REJECTED authorization status to caller
- [ ] If caller is the orchestrator → orchestrator aborts or presents revised plan

---

### Confirmation Presentation Format

```markdown
## ⚠️ Confirmation Required

**Risk Level:** [HIGH / Rule Override / Irreversible Operation]
**Triggered by:** [Stage 6 condition / Rule ID / Skill name]

### Proposed Action
[Plain-language description of exactly what will happen]

### Impact
**What changes:** [Specific changes to state, data, infrastructure, etc.]
**What is irreversible:** [What cannot be undone after execution]
**What can be recovered:** [What rollback options exist, if any]
**Affected systems/data:** [Scope of impact]

### Rule Override (if applicable)
**Rule:** [Rule ID] — [Rule Name]
**Constraint being overridden:** [Exact constraint text]
**Justification provided:** [Rationale from invoking skill or user]

### Alternatives Considered
- [Alternative A] — [Why not chosen]
- [Alternative B] — [Why not chosen]
*(If no alternatives exist, state: "No compliant alternative identified.")*

### Decision Required
Do you approve this action?

- **APPROVE** — Execution proceeds. This action [is/is not] reversible.
- **REJECT** — Execution is halted. The plan will be revised or aborted.
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Validate that the confirmation request is specific and the activation condition is met
2. Construct a clear, complete impact summary in plain language
3. Present to user and await an explicit binary decision
4. Record the outcome (approval or rejection) with full context
5. Flag engineering-decision-logging for every approval

**Quality criteria:**

* User has enough information to make an informed decision — no vague or incomplete confirmations
* Every approval is recorded and linked to the specific action, risk level, and rule override (if any)
* No high-risk or irreversible action executes without a recorded approval

---

## Constraints (Rules Applied)

### Decision & Tradeoff Rules

* **DT-2: Confirmation Gate**
  This skill IS the implementation of DT-2. Every activation of DT-2 in any rule routes here. The confirmation gate is non-optional when its activation conditions are met.

### Product & Stakeholder Rules

* **PS-2: Risk Communication**
  Risk must be communicated in business terms before requesting confirmation. A technically accurate but incomprehensible risk summary does not satisfy this rule. The user must be able to understand what they are approving.

### Compliance & Legal Rules

* **CL-4: Ethical Risk Flagging**
  Features or actions with potential ethical harm must be flagged and require approval. Ethical risk is treated equivalently to technical risk for confirmation purposes.

---

## Tradeoff Handling

### Tradeoff 1: Safety vs. Workflow Speed

**Scenario:** User is in a fast iteration loop and finds confirmations disruptive.

```
IF user_requests_reduced_confirmations
→ Do NOT suppress confirmations for HIGH risk or irreversible operations
→ May reduce confirmation frequency for MEDIUM risk soft violations IF explicitly approved via DT-2 once
→ Log the reduced-confirmation decision via engineering-decision-logging
→ Fallback: Restore full confirmation behavior on any new HIGH risk trigger
```

### Tradeoff 2: Frequent Confirmations vs. User Fatigue

**Scenario:** Multiple soft violations in a single task chain each trigger escalation, creating confirmation fatigue.

```
IF multiple_soft_violations_in_same_task AND violations_are_related
→ Batch related violations into a single confirmation request
→ Present all violations together with a single APPROVE/REJECT decision
→ Do not batch unrelated violations — each must be individually understood
→ Log batch confirmation via engineering-decision-logging with all violation IDs
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: User Rejects — No Alternative Exists

**Trigger:** User rejects the proposed action and no compliant alternative has been identified.

**Action:**
- Return REJECTED status to caller
- Surface explanation: "No compliant alternative identified — task cannot be completed as specified"
- Recommend: revise the requirement or accept the constraint
- Log the rejection via engineering-decision-logging

---

### Escalation Scenario 2: Ambiguous User Response

**Trigger:** User response does not clearly indicate approval or rejection.

**Action:**
- Do not interpret ambiguity as approval
- Re-present with a direct binary question: "Please respond with APPROVE or REJECT"
- After two ambiguous responses, default to REJECTED and surface the reason

---

### When to halt execution:

* User explicitly rejects — halt immediately, return REJECTED, do not retry
* User cannot be reached or does not respond — do not default to APPROVE; treat as REJECTED
* The proposed action cannot be precisely defined — do not present an undefined confirmation

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Decision Confirmation Gate is the only skill in the framework with direct user interaction as its primary function. It sits at Stage 6 in the ORCH-1 lifecycle and on all escalation paths from rule-enforcement-engine and other skills. Its output gates whether Stage 7 (execution) proceeds.

### How This Skill Integrates

**Integration workflow:**
1. **Orchestrator** invokes decision-confirmation-gate at Stage 6 OR rule-enforcement-engine escalates here
2. Gate validates the confirmation request, constructs the presentation, and presents to user
3. User responds APPROVE or REJECT
4. Gate records the outcome and flags engineering-decision-logging
5. Gate returns authorization status to the orchestrator or invoking skill
6. Orchestrator proceeds (APPROVED) or aborts/revises (REJECTED)

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| User approves high-risk action | engineering-decision-logging | All approvals must be logged for audit trail |
| User rejects and finding is architecturally significant | engineering-decision-logging | Significant rejections should be recorded |

---

## Related Skills

**Skills this skill depends on:**

* **intent-parsing** — Provides risk classification; HIGH risk is a primary activation trigger
* **rule-enforcement-engine** — Primary source of escalations; routes soft violations here for override approval

**Skills this skill cooperates with:**

* **task-planning** — Task-planning flags irreversible steps; decision-confirmation-gate handles the confirmation for those steps
* **memory-management** — Memory-management may escalate stale constraint conflicts here when re-confirmation is needed

**Skills this skill may invoke/flag:**

* **engineering-decision-logging** *(# not yet created)* — Flagged on every APPROVED decision and on architecturally significant rejections

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never present a vague or undefined confirmation — validate the proposed action is specific first
* [ ] Never default ambiguous responses to APPROVE — require explicit decision
* [ ] Always flag engineering-decision-logging after every approved confirmation
* [ ] Never suppress confirmations for HIGH risk or irreversible operations regardless of user preference
* [ ] Record every outcome (approval or rejection) with timestamp and full context

**Audit trail requirements:**

* Every confirmation request must be logged: proposed action, risk level, activation trigger, timestamp
* Every approval must be logged: who approved (user), what was approved, rule overrides granted, timestamp
* Every rejection must be logged: what was rejected, reason if provided, timestamp

---

## Example Use Cases

### Example 1: Production Data Deletion

**Scenario:** A migration cleanup task would delete production records. `risk_level = HIGH`, `irreversible_operation = TRUE`.

**Confirmation presented:**
- Action: Delete 12,400 user records from the production `orders` table as part of migration cleanup
- Irreversible: Yes — deletion cannot be undone without a restore from backup
- Rollback: Database backup from 2 hours prior; restore takes ~45 minutes
- Rule override: none — this is a HIGH risk trigger, not a rule override

**Result:** User reviews, confirms backup is recent, responds APPROVE. Execution proceeds. Engineering Decision Logging flagged.

---

### Example 2: Rule Override for Performance Optimization

**Scenario:** Performance optimization violates SOLID principles. `rule-enforcement-engine` escalates PC-2 soft violation.

**Confirmation presented:**
- Action: Introduce a performance-critical path that breaks the Single Responsibility Principle in `OrderProcessor`
- Rule overridden: PC-2 — Performance Tradeoff Confirmation; DA-1 SOLID principles
- Justification: 40% latency reduction required to meet SLA; no compliant alternative achieves the same result
- Reversible: Yes — refactor can restore SOLID compliance after SLA constraint is lifted

**Result:** User approves with note "time-box this for Q2 refactor." Engineering Decision Logging flagged with time-box note.

---

### Example 3: Rejection — No Compliant Alternative

**Scenario:** A proposed architectural change would break backward compatibility with no migration path. Rule MF-3 is a hard block, but the invoking skill escalated anyway via a misrouting.

**Action:**
- Gate receives the escalation, validates activation condition — MF-3 is a hard constraint, no override path
- Returns REJECTED immediately, surfaces: "MF-3 does not permit override — plan revision required"
- Engineering Decision Logging flagged with the rejection finding

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Presenting a vague confirmation ("Are you sure you want to proceed?")
✅ **Correct approach:** Every confirmation states precisely what will happen, what is irreversible, and what can be recovered.

❌ **Anti-pattern 2:** Defaulting to APPROVE on ambiguous user responses
✅ **Correct approach:** Require explicit APPROVE or REJECT; re-present if ambiguous; default to REJECT after two unclear responses.

❌ **Anti-pattern 3:** Suppressing confirmations for HIGH risk operations to reduce friction
✅ **Correct approach:** HIGH risk and irreversible operations always require confirmation; this is non-negotiable.

❌ **Anti-pattern 4:** Failing to flag engineering-decision-logging after an approval
✅ **Correct approach:** Every APPROVED confirmation must be immediately followed by a flag to engineering-decision-logging.

❌ **Anti-pattern 5:** Accepting a hard-block rule violation for confirmation (CL-1, CL-3)
✅ **Correct approach:** Hard constraints have no override path — they should never reach the confirmation gate. If they do, return REJECTED immediately.

❌ **Anti-pattern 6:** Batching unrelated violations into a single confirmation
✅ **Correct approach:** Only batch related violations from the same task chain. Unrelated violations each require their own confirmation.

❌ **Anti-pattern 7:** Presenting the confirmation in technical jargon without a plain-language summary
✅ **Correct approach:** Per PS-2, risk must be communicated in terms the user can act on — plain language summary is mandatory.

❌ **Anti-pattern 8:** Not recording rejected confirmations
✅ **Correct approach:** Rejections must also be recorded — they are governance-relevant findings even when no action is taken.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Determining risk level — that is Intent Parsing
* ❌ Evaluating rules — that is Rule Enforcement Engine
* ❌ Logging approved decisions durably — that is Engineering Decision Logging
* ❌ Resolving dependency conflicts — that is Skill Dependency Resolution

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Be precise about the proposed action** — never present a confirmation for an action that is not exactly defined
2. **Lead with irreversibility** — users must know what cannot be undone before anything else
3. **Never interpret silence or ambiguity as approval** — require explicit response
4. **Keep it human-readable** — the confirmation is for a human, not the AI; avoid internal jargon
5. **Flag engineering-decision-logging immediately after every APPROVE** — do not defer this step

**Output format preferences:**

* Structured confirmation block with clear sections
* Binary APPROVE / REJECT framing — no hedged options
* Bold the irreversibility statement so it cannot be overlooked

**Tone and approach:**

* Neutral and factual — the gate informs, not persuades
* Clear about consequences — the user must understand what they are deciding
* Respectful of user time — be complete but not verbose

---

## Metadata Summary

```yaml
name: decision_confirmation_gate
category: Orchestration & Governance
priority: High
depends_on: [intent-parsing, rule-enforcement-engine]
flags_skills: [engineering-decision-logging]
rules_applied: [DT-2, PS-2, CL-4]
documents_needed: []
tags: [confirmation, risk, governance, safety, audit]
```

**Key relationships:**
- Depends on: intent-parsing (risk classification), rule-enforcement-engine (primary escalation source)
- Flags: engineering-decision-logging (every approved decision must be logged)
- Governed by: DT-2 (this skill implements DT-2), PS-2 (risk must be communicated clearly), CL-4 (ethical risks require confirmation)

---

*End of Decision Confirmation Gate Human Spec*
