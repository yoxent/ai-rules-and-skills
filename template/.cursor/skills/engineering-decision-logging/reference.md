# Skill Human Spec
# File: engineering-decision-logging-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: engineering_decision_logging
description: Records significant engineering decisions, tradeoffs, rule overrides, and architectural changes to maintain traceability and support audit and retrospective analysis.
version: 1.0.0
category: Orchestration & Governance
tags: [logging, decisions, traceability, audit, governance]
priority: High

depends_on: [decision-confirmation-gate]
flags_skills: [memory-management, skill-version-management]

inputs: [approved-decisions, tradeoff-documentation, rule-override-records, confirmation-outcomes]
outputs: [decision-log-entries, linked-rule-references, historical-decision-index]

rules_applied:
  - PS-4  # Decision Transparency — all major decisions must be explicitly recorded
  - DT-1  # Explicit Tradeoff Logging — tradeoffs must be logged with rationale
  - MF-2  # Technical Debt Tracking — shortcuts and deviations must be tracked

documents_needed: []

execution_context: Runs at ORCH-1 Stage 9 (conditional) when architectural_decision = TRUE, tradeoff_applied = TRUE, or rule_override_approved = TRUE; also invoked directly by decision-confirmation-gate after every approval and by other skills on their escalation paths.

---
```

---

# Skill: Engineering Decision Logging

---

## Purpose

**What this skill does:**
Engineering Decision Logging is the authoritative record-keeper for the AI Senior Engineer framework. It persists every significant engineering decision — whether an architectural choice, an approved rule override, an applied tradeoff, or a confirmed high-risk action — with full context: the decision itself, the rationale, the rules referenced, the skills involved, and the timestamp. It is the downstream consumer of decision-confirmation-gate approvals and the upstream source for memory-management's long-term retention.

Creates an auditable trail of consequential decisions that supports compliance reviews, retrospectives, onboarding, and incident post-mortems. Prevents the "why did we do this?" problem by ensuring the reasoning is captured at decision time, not reconstructed months later from code comments and memory.

Decouples decision recording from decision-making. Skills and the confirmation gate focus on making correct decisions; this skill ensures those decisions are durable, searchable, and linked to the rules and context that produced them. Enables confident refactoring and evolution of the system by making prior decisions visible and traceable.

---

## When to Use This Skill

### Triggers (Use this skill when):

* ORCH-1 Stage 9 activates: `architectural_decision = TRUE`
* ORCH-1 Stage 9 activates: `tradeoff_applied = TRUE`
* ORCH-1 Stage 9 activates: `rule_override_approved = TRUE`
* `decision-confirmation-gate` completes with an APPROVED outcome
* Any skill's ON_VIOLATION chain routes here to record a resolved exception
* A gap detection event is confirmed and resolved (either direction)
* A technical debt item is introduced and must be tracked (MF-2)
* Memory management flags a contradiction that has been resolved

### Do NOT use this skill for:

* Making or approving decisions — that is Decision Confirmation Gate
* Enforcing rules — that is Rule Enforcement Engine
* Storing active project state for real-time use — that is Memory Management
* Bumping skill versions or writing changelogs — that is Skill Version Management (though this skill flags it when a decision changes skill behavior)

**Execution Context Details:**
Engineering Decision Logging is invoked at Stage 9 by the orchestrator and directly by decision-confirmation-gate after every approval. It is the final substantive step before task completion validation. Its outputs feed memory-management (for cross-session persistence) and provide the audit trail for any future review. It never blocks execution — it records outcomes, not prerequisites.

---

## Inputs

**Required inputs:**

* **Approved decisions** — The outcome from decision-confirmation-gate: what was approved, who approved it, the timestamp, and the context
* **Tradeoff documentation** — The rationale for any applied tradeoff: what was traded, why, and what the time-box or remediation plan is
* **Rule override records** — Which rule was overridden, which constraint was waived, what justification was provided, and whether the override is time-boxed

**Optional inputs:**

* **Skill version impact** — Whether the decision changes the behavior of any registered skill (triggers flag to skill-version-management)
* **Technical debt notation** — A MF-2 flag from any skill indicating a shortcut that must be tracked
* **Gap detection outcome** — Result of a skill-gap-detection run: confirmed gap, resolved gap, or rejected extension

**Documents/Context needed:** none required — all necessary context is passed by the invoking skill or orchestrator

---

## Outputs

**Primary outputs:**

* **Decision log entries** — Structured records, one per decision, each containing: decision summary, rationale, rule references, impacted skills, decision-maker, timestamp, and time-box (if applicable)
* **Linked rule references** — Each log entry is explicitly linked to the rule IDs that were applied, overridden, or informed the decision
* **Historical decision index** — An incrementally updated searchable index of all logged decisions, grouped by: type (architectural / tradeoff / rule-override / technical-debt), rule ID, skill name, and date range

**Output format:**

* Individual log entries in a consistent structured format (see Final Step below)
* Index entry appended to the historical decision index after each log write
* Flag to memory-management for entries marked as long-term architectural decisions

**Skill flags (if applicable):**

* Flag **memory-management** when a logged decision is architectural in nature and must be preserved across sessions
* Flag **skill-version-management** when a logged decision changes the behavior, dependencies, or rules of a registered skill

---

## Preconditions

**Conditions that must be met before execution:**

* At least one of the Stage 9 activation conditions is met, or an invoking skill has passed decision context
* The decision to be logged is fully resolved — no pending confirmations or open contradictions
* Sufficient context is available to produce a complete log entry (decision, rationale, rule refs, timestamp)

**Validation checks:**

* [ ] Decision summary is specific — not "made a decision" but what the decision is
* [ ] At least one rule reference is present (even if the decision was rule-agnostic, note that explicitly)
* [ ] Rationale is present — not just what was decided, but why
* [ ] Timestamp is recorded at log-write time

---

## Step-by-Step Execution Procedure

### Step 1: Classify the Decision

**Questions to answer:**
- What type of decision is this: architectural / tradeoff / rule-override / technical-debt / gap-detection?
- What is the scope: single task, project-wide, system-wide?
- Does this decision change the behavior of any registered skill?
- Is this decision time-boxed (temporary override, planned remediation)?

**Actions:**
- [ ] Assign decision type from: ARCHITECTURAL, TRADEOFF, RULE_OVERRIDE, TECHNICAL_DEBT, GAP_DETECTION
- [ ] Determine scope: TASK, PROJECT, SYSTEM
- [ ] Identify all impacted skills by name (kebab-case, from skill_registry)
- [ ] Identify all relevant rule IDs referenced or overridden

**Red flags / Warning signs:**
- Decision type is unclear — may indicate the invoking context did not pass sufficient information
- No rule references can be identified — flag as WARNING; every decision in a governed system relates to at least one rule

---

### Step 2: Construct the Log Entry

**Questions to answer:**
- Is the decision summary specific enough to be meaningful without additional context?
- Is the rationale detailed enough for a future engineer who was not present?
- If a rule was overridden: is the justification for the override recorded, and is a time-box present?
- If a tradeoff was applied: what was traded and what is the remediation plan?

**Actions:**
- [ ] Write decision summary: one to three sentences, specific, no jargon without definition
- [ ] Write rationale: why this decision was made over alternatives; what constraints drove it
- [ ] List rule references: all rule IDs linked to this decision (applied, overridden, or consulted)
- [ ] List impacted skills: all skills whose behavior, dependencies, or outputs are affected
- [ ] Record decision-maker: user (explicit approval), orchestrator (rule-driven), or skill (autonomous within bounds)
- [ ] Record timestamp
- [ ] If time-boxed: record expiry condition and owner

**Red flags / Warning signs:**
- Rationale is absent or is "because it was requested" — insufficient; record what constraint or priority drove the choice
- No impacted skills listed despite the decision clearly affecting execution behavior
- A rule override with no time-box and no remediation plan — flag as WARNING; per DA-6, deviations must be time-boxed

---

### Step 3: Validate Entry Completeness

**Actions:**
- [ ] Confirm all required fields are populated: type, scope, summary, rationale, rule refs, skills, decision-maker, timestamp
- [ ] Confirm time-box field is populated for any rule override or tradeoff (or explicitly marked "permanent" with justification)
- [ ] If any required field is missing → do not write partial entry; request the missing context from the invoking skill

**Decision points:**
- If required context cannot be retrieved → log an INCOMPLETE entry with a flag to the invoking skill to supply missing fields
- Never write a log entry that cannot be traced to a specific decision with a specific rationale

---

### Step 4: Write Entry and Update Index

**Actions:**
- [ ] Write the structured log entry to the decision log
- [ ] Append an index entry to the historical decision index
- [ ] If decision type = ARCHITECTURAL → flag memory-management for cross-session persistence
- [ ] If decision changes a registered skill's behavior → flag skill-version-management

---

### Final Step: Generate Log Entry (Format)

```markdown
## Decision Log Entry

**ID:** DL-[YYYY-MM-DD]-[sequence]
**Date:** [YYYY-MM-DD HH:MM]
**Type:** [ARCHITECTURAL | TRADEOFF | RULE_OVERRIDE | TECHNICAL_DEBT | GAP_DETECTION]
**Scope:** [TASK | PROJECT | SYSTEM]
**Decision-maker:** [User (confirmed via decision-confirmation-gate) | Orchestrator | Skill: skill-name]

### Decision
[One to three sentences describing exactly what was decided]

### Rationale
[Why this decision was made — constraints, priorities, alternatives rejected]

### Rules Referenced
| Rule ID | Role |
|---------|------|
| [ID]    | Applied / Overridden / Consulted |

### Impacted Skills
| Skill | Impact |
|-------|--------|
| [skill-name] | [What changes in this skill's behavior or outputs] |

### Time-Box / Remediation
- **Time-box:** [Expiry condition or date — or "Permanent" with justification]
- **Remediation plan:** [What must happen to address the deviation, if any]
- **Owner:** [Who is responsible for the time-box action]

### Index Tags
[type:ARCHITECTURAL] [rule:DA-1] [skill:api-design] [scope:PROJECT]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Classify each decision by type, scope, and impact
2. Construct a complete, specific, rationale-rich log entry
3. Validate completeness before writing — no partial entries
4. Write to log and update historical index
5. Flag memory-management for architectural decisions and skill-version-management for skill-impacting decisions

**Quality criteria:**

* Every entry is self-contained — a future engineer can understand the decision without additional context
* Every rule override has a time-box or a justified "permanent" classification
* No entry is written without a specific rationale — "because it was requested" is insufficient
* The historical index is searchable by type, rule ID, skill name, and date

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-4: Decision Transparency**
  The log entry must be explicit and traceable. Vague summaries ("made an optimization decision") are non-compliant. Every entry must identify what was decided, why, and what rules were involved.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  Every tradeoff — including performance vs. correctness, speed vs. maintainability, and any SOLID deviation — must be logged with its rationale and a time-box. Undocumented tradeoffs are a governance violation.

### Maintenance & Feature Consistency Rules

* **MF-2: Technical Debt Tracking**
  Technical debt introduced as part of any decision must be recorded with: what the debt is, why it was accepted, and when or under what condition it will be addressed. Untracked debt is a MF-2 violation.

---

## Tradeoff Handling

### Tradeoff 1: Comprehensive Logging vs. Documentation Overhead

**Scenario:** A task involves many small decisions; logging each one fully creates disproportionate overhead.

```
IF decision_count_in_task > threshold AND decisions_are_minor
→ Batch minor related decisions into a single log entry with combined rationale
→ Log only one entry per distinct decision type per task
→ Never batch decisions of different types (e.g., a tradeoff and a rule override)
→ Flag via DT-1 that batching was applied
```

### Tradeoff 2: Granularity vs. Clarity

**Scenario:** A highly granular log entry covers every sub-step but becomes unreadable.

```
IF entry_length > readable_threshold
→ Summarize at decision level, not step level
→ Reference the task execution record for step-level detail
→ Ensure the decision and rationale remain prominent
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Required Context Missing

**Trigger:** The invoking skill or orchestrator did not pass sufficient context to construct a complete log entry.

**Action:**
- Do not write a partial entry
- Request missing fields from the invoking skill
- Write an INCOMPLETE placeholder with a flag to the invoking skill

**Escalation format:**
```
⚠️ LOG ENTRY INCOMPLETE

Missing fields: [rationale | rule references | decision-maker | ...]
Decision summary (partial): [What is known]

Required action: [Invoking skill] must supply [missing fields] before entry is finalized.
```

---

### Escalation Scenario 2: Rule Override with No Time-Box

**Trigger:** A rule override is logged but no time-box or remediation plan is provided.

**Action:**
- Write the entry with a WARNING flag on the time-box field
- Flag skill-version-management if the override affects a skill
- Surface the warning to the user: per DA-6, deviations must be time-boxed

---

### When to halt execution:

* Engineering Decision Logging never halts task execution — it records outcomes, not prerequisites. The only case where it blocks is if it cannot write the log entry at all (e.g., log is inaccessible), in which case it surfaces the failure and requires resolution before task completion.

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Engineering Decision Logging sits at Stage 9 — the final governance step before completion validation. It is also a direct downstream consumer of decision-confirmation-gate (invoked after every APPROVED confirmation). Its outputs feed memory-management (for architectural decisions) and skill-version-management (for skill-impacting decisions).

### How This Skill Integrates

**Integration workflow:**
1. **Orchestrator** invokes at Stage 9 OR **decision-confirmation-gate** flags directly after APPROVE
2. Engineering-decision-logging classifies the decision, constructs and validates the entry
3. Writes entry to log, updates historical index
4. Flags memory-management for architectural entries
5. Flags skill-version-management for skill-impacting entries
6. Returns completion status to orchestrator — task proceeds to Stage 10

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Decision is architectural (ARCHITECTURAL type) | memory-management | Must be persisted across sessions |
| Decision changes a registered skill's behavior | skill-version-management | Skill requires a version bump |

---

## Related Skills

**Skills this skill depends on:**

* **decision-confirmation-gate** — Primary upstream source; every APPROVED confirmation triggers a log entry here. Confirmation outcome is a required input.

**Skills this skill cooperates with:**

* **memory-management** — Receives architectural log entries for cross-session persistence
* **rule-enforcement-engine** — Sources rule override records that this skill logs after approval
* **skill-gap-detection** — Sources gap detection outcomes for logging

**Skills this skill may invoke/flag:**

* **memory-management** — Flagged when a logged decision is architectural and must be preserved cross-session
* **skill-version-management** — Flagged when a logged decision affects a registered skill's behavior or rules

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never write a partial log entry — all required fields must be present
* [ ] Every rule override entry must include a time-box or an explicit "permanent" classification with justification
* [ ] Every technical debt entry must include a remediation plan
* [ ] Flag memory-management for all ARCHITECTURAL entries
* [ ] Flag skill-version-management when a decision changes skill behavior
* [ ] The historical decision index must be updated on every log write

**Audit trail requirements:**

* Log entries are immutable once written — corrections are addenda, not overwrites
* Every entry records who made the decision (user / orchestrator / skill) and when
* The index must support search by: type, rule ID, skill name, date range, and decision-maker

---

## Example Use Cases

### Example 1: Logging a Rule Override for a Performance Tradeoff

**Scenario:** User approved overriding DA-1 (SOLID) for a performance-critical path via decision-confirmation-gate.

**Log entry produced:**
- Type: RULE_OVERRIDE
- Decision: SOLID principles relaxed in `OrderProcessor.process()` for the hot path; SRP violated intentionally
- Rationale: 40% latency reduction required to meet SLA; no SOLID-compliant alternative achieved the same result within budget
- Rules: DA-1 (overridden), PC-2 (applied — tradeoff confirmed)
- Impacted skills: clean-code-solid, performance-optimization
- Time-box: Q2 2025 — refactor after SLA constraint is lifted
- Owner: backend team

**Flags:** memory-management (architectural), skill-version-management (clean-code-solid behavior affected)

---

### Example 2: Logging Technical Debt

**Scenario:** A synchronous API call was introduced as a shortcut; async design is the correct long-term approach.

**Log entry produced:**
- Type: TECHNICAL_DEBT
- Decision: Synchronous HTTP call to payment service in `CheckoutController` — should be async
- Rationale: Async refactor is out of scope for current sprint; synchronous call acceptable for current load levels
- Rules: MF-2 (tracked), DA-5 (deviation noted)
- Time-box: Sprint 8 — async refactor planned
- Remediation: Extract to async message queue when payment service supports it

---

### Example 3: Logging a Gap Detection Resolution

**Scenario:** skill-gap-detection confirmed a gap; user approved creation of a new cost-optimization skill.

**Log entry produced:**
- Type: GAP_DETECTION
- Decision: New skill `cost-optimization-analysis` approved for Phase 4 registry addition
- Rationale: No existing skill covered cloud cost analysis; gap confirmed after full registry search
- Rules: PS-1 (gap validated), DT-2 (confirmation obtained)
- Impacted skills: skill_registry (updated), skill-gap-detection (gap resolved)
- Time-box: N/A — permanent registry addition

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Writing a log entry with no rationale ("decision made per user request")
✅ **Correct approach:** Rationale must explain what constraint or priority drove the decision, not just who requested it.

❌ **Anti-pattern 2:** Logging a rule override with no time-box
✅ **Correct approach:** Every override must have a time-box or a justified "permanent" classification. Indefinite overrides without justification are a DA-6 violation.

❌ **Anti-pattern 3:** Writing partial entries when context is missing
✅ **Correct approach:** Write an INCOMPLETE placeholder and flag the invoking skill to supply missing fields. Do not write guessed or inferred fields.

❌ **Anti-pattern 4:** Not flagging memory-management for architectural decisions
✅ **Correct approach:** Every ARCHITECTURAL entry must be flagged to memory-management for cross-session persistence.

❌ **Anti-pattern 5:** Treating logging as optional for "minor" tradeoffs
✅ **Correct approach:** DT-1 requires every tradeoff to be logged. There is no threshold below which tradeoff logging is optional.

❌ **Anti-pattern 6:** Overwriting a log entry to correct it
✅ **Correct approach:** Log entries are immutable. Corrections are written as addenda linked to the original entry.

❌ **Anti-pattern 7:** Not updating the historical index after writing an entry
✅ **Correct approach:** Index update is mandatory on every log write; a log without an index is not searchable.

❌ **Anti-pattern 8:** Failing to flag skill-version-management when a decision changes skill behavior
✅ **Correct approach:** If the logged decision affects how a registered skill behaves, its dependencies, or its rules, skill-version-management must be flagged for a version bump.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Approving decisions — that is Decision Confirmation Gate
* ❌ Enforcing rules — that is Rule Enforcement Engine
* ❌ Cross-session memory management — that is Memory Management (this skill flags it, does not do it)
* ❌ Bumping skill versions — that is Skill Version Management (this skill flags it, does not do it)

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Always classify before writing** — decision type drives the required fields and downstream flags
2. **Never accept a rationale of "per user request"** — require the constraint or priority that drove the decision
3. **Treat immutability as absolute** — no overwriting; corrections are addenda
4. **Flag downstream skills proactively** — do not wait for the orchestrator to route; flag memory-management and skill-version-management when conditions are met
5. **Validate completeness before writing** — an incomplete entry is worse than a delayed one

**Output format preferences:**

* Structured log entry with explicit field labels
* Index entry with searchable tags appended to each write
* INCOMPLETE placeholder format when context is missing

**Tone and approach:**

* Precise and archival — log entries will be read by future engineers without the current context
* Conservative — when in doubt about completeness, flag for missing context rather than guessing
* Forward-looking — rationale and time-boxes should be written for the engineer who will revisit this decision in six months

---

## Metadata Summary

```yaml
name: engineering_decision_logging
category: Orchestration & Governance
priority: High
depends_on: [decision-confirmation-gate]
flags_skills: [memory-management, skill-version-management]
rules_applied: [PS-4, DT-1, MF-2]
documents_needed: []
tags: [logging, decisions, traceability, audit, governance]
```

**Key relationships:**
- Depends on: decision-confirmation-gate (primary upstream; every APPROVED confirmation triggers a log entry)
- Flags: memory-management (architectural decisions), skill-version-management (skill-impacting decisions)
- Governed by: PS-4 (all decisions must be explicitly recorded), DT-1 (all tradeoffs must be logged with rationale), MF-2 (technical debt must be tracked with remediation plan)

---

*End of Engineering Decision Logging Human Spec*
