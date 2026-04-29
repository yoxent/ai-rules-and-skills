# Skill Human Spec
# File: task-planning-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: task-planning
description: Decomposes structured intent into executable steps, milestones, and checkpoints while maintaining alignment with constraints and risk boundaries.
version: 1.0.0
category: Orchestration & Governance
tags: [planning, decomposition, milestones, checkpoints, rollback]
priority: High

depends_on: [intent-parsing, skill-orchestration]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]

inputs: [structured-intent-model, ordered-skill-chain, project-constraints]
outputs: [execution-roadmap, milestone-breakdown, risk-checkpoints]

rules_applied:
  - PS-3  # Scope Control — keep plan aligned with intent boundaries
  - DD-2  # Rollback Readiness — insert rollback points for reversible operations
  - DT-1  # Explicit Tradeoff Logging — log planning decisions and granularity tradeoffs

documents_needed: []

execution_context: Supports ORCH-1 Stage 4 (conditional) — activates when risk_level ∈ {MEDIUM, HIGH} OR multi_step = TRUE OR persistent_state_modified = TRUE.
---
```

---

# Skill: Task Planning

---

## Purpose

**What this skill does:**
Task Planning decomposes a structured intent and ordered skill chain into a concrete, step-by-step execution roadmap. It identifies subtask dependencies, inserts validation checkpoints, flags irreversible steps for the Confirmation Gate, and ensures rollback points exist for recoverable operations. It does not execute the plan — it produces the plan for the orchestrator to execute.

Unplanned execution of medium- and high-risk tasks leads to partial failures, data loss, and costly recovery. A structured plan with explicit checkpoints and rollback markers reduces execution risk and gives stakeholders visibility into what will happen before it happens.

Atomic step decomposition makes large tasks testable and recoverable at each stage. Explicit rollback points prevent irreversible damage from cascading failures. Checkpoint insertion enables validation between steps rather than only at the end.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Risk level is MEDIUM or HIGH (per ORCH-1 Stage 4 activation condition)
* Task involves multiple sequential steps that must be ordered
* Persistent state will be modified (database, configuration, deployed artefacts)
* A deployment or migration is being planned
* A rollback strategy is required
* The task has subtask dependencies that need explicit sequencing

### Do NOT use this skill for:

* Low-risk, single-step tasks — Task Planning is a conditional stage; do not activate it unnecessarily
* Executing the plan — that is the orchestrator's Stage 7 responsibility
* Evaluating rule compliance — handled by rule-enforcement-engine at Stage 5
* Selecting or sequencing skills — that is skill-orchestration's responsibility

**Execution Context Details:**
Task Planning supports ORCH-1 Stage 4. It runs after the ordered skill chain is produced by skill-orchestration and before rule evaluation at Stage 5. Its output — the execution roadmap — is the step-by-step contract that Stage 7 follows. It is conditional: it only activates when risk or complexity warrants it.

---

## Inputs

**Required inputs:**

* **Structured intent model** — From intent-parsing. Provides primary objective, scope boundary, risk level, and constraints. Defines what the plan must achieve and what it must not violate.
* **Ordered skill chain** — From skill-orchestration. Defines which skills execute and in what order. Task Planning decomposes each skill's contribution into concrete steps.
* **Project constraints** — Explicit and inferred constraints from the intent model: performance budgets, backward compatibility requirements, compliance boundaries, deployment windows.

**Optional inputs:**

* **Prior decision log** — If engineering-decision-logging has entries from earlier in the session, they may impose constraints on how steps are ordered or what rollback options are available.

---

## Outputs

**Primary outputs:**

* **Execution roadmap** — Ordered list of atomic steps, each with: action description, owning skill, validation checkpoint, and rollback marker if applicable.
* **Milestone breakdown** — Logical groupings of steps into phases (e.g., preparation, execution, validation, cleanup).
* **Risk checkpoints** — Steps identified as requiring validation before proceeding; irreversible steps flagged for Confirmation Gate.

**Output format:**

```markdown
## Execution Roadmap

**Task:** [Primary objective from intent model]
**Risk Level:** MEDIUM | HIGH
**Total Steps:** [N]

### Phase 1: [Phase Name]
- [ ] Step 1: [Action] — Skill: [skill-name] — Checkpoint: [validation criterion]
- [ ] Step 2: [Action] — Skill: [skill-name] — Rollback: [how to reverse if this fails]

### Phase 2: [Phase Name]
- [ ] Step 3: [Action] ⚠️ IRREVERSIBLE — requires Confirmation Gate
- [ ] Step 4: [Action] — Checkpoint: [validation criterion]

### Rollback Plan
- If Step 3 fails: [specific recovery action]
- If Step 5 fails: [specific recovery action]

### Skills Flagged for Follow-up
- **decision-confirmation-gate**: Step [N] is irreversible — confirmation required before execution
- **engineering-decision-logging**: [If architectural decision embedded in plan]
```

**Skill flags (if applicable):**

* Flag **decision-confirmation-gate** when any step is identified as irreversible or HIGH risk
* Flag **engineering-decision-logging** when the plan embeds an architectural or governance decision

---

## Preconditions

**Conditions that must be met before execution:**

* Valid structured intent model exists from intent-parsing
* Ordered skill chain exists from skill-orchestration
* Stage 4 activation condition is met: risk ∈ {MEDIUM, HIGH} OR multi_step = TRUE OR persistent_state_modified = TRUE

**Validation checks:**

* [ ] Intent model is complete with risk level set
* [ ] Ordered skill chain is non-empty
* [ ] Activation condition is confirmed before running (do not plan low-risk single-step tasks)

---

## Step-by-Step Execution Procedure

### Step 1: Confirm Activation Condition

**Questions to answer:**
- Is risk MEDIUM or HIGH?
- Does the task have multiple sequential steps?
- Will persistent state be modified?

**Actions:**
- [ ] Check risk level from intent model
- [ ] Determine if task is multi-step based on ordered skill chain
- [ ] Determine if any skill in the chain modifies persistent state

**Decision points:**
- If none of the activation conditions are met → skip Task Planning, proceed directly to Stage 5
- If any condition is met → proceed to Step 2

---

### Step 2: Decompose into Atomic Steps

**Questions to answer:**
- What is the smallest independent unit of work for each skill in the chain?
- What must be true before each step begins (preconditions)?
- What must be true after each step completes (postconditions)?

**Actions:**
- [ ] For each skill in the ordered chain, enumerate its atomic actions
- [ ] Define precondition and postcondition for each step
- [ ] Identify which steps produce outputs consumed by later steps

**Red flags / Warning signs:**
- Steps that are too coarse (multiple concerns in one step) — split them
- Steps that depend on the outcome of a step not yet defined — reorder

**Decision points:**
- If a step is ambiguous → decompose further until it is atomic and testable

---

### Step 3: Insert Validation Checkpoints

**Questions to answer:**
- After which steps must the state be validated before proceeding?
- What is the validation criterion for each checkpoint?
- Which checkpoints are mandatory vs advisory?

**Actions:**
- [ ] Identify steps after which partial failure would be undetectable without validation
- [ ] Define a concrete, testable validation criterion for each checkpoint
- [ ] Mark checkpoints as mandatory (block on failure) or advisory (warn on failure)

**Red flags / Warning signs:**
- Long sequences with no checkpoints — risk of propagating errors silently
- Checkpoints defined too vaguely to be testable ("check it works")

---

### Step 4: Identify and Mark Irreversible Steps

**Questions to answer:**
- Which steps cannot be undone if they fail or produce wrong output?
- Does the intent model or ORCH-1 risk model classify any operation as irreversible?
- Are any irreversible steps avoidable by reordering?

**Actions:**
- [ ] Mark each irreversible step with ⚠️ IRREVERSIBLE
- [ ] Flag decision-confirmation-gate for every irreversible step
- [ ] Verify that irreversible steps are preceded by a validation checkpoint wherever possible

**Decision points:**
- If irreversible step can be made reversible by reordering (e.g., backup before delete) → reorder
- If irreversibility is inherent → flag confirmation gate and document clearly

---

### Step 5: Define Rollback Plan

**Questions to answer:**
- For each reversible step that modifies state, what is the rollback action?
- Are rollback actions themselves safe and tested?
- Is there a point of no return after which rollback is impossible?

**Actions:**
- [ ] For each state-modifying step, define a rollback action (DD-2)
- [ ] Mark the point of no return clearly in the roadmap
- [ ] Verify rollback actions are concrete and executable (not vague)

**Red flags / Warning signs:**
- "Rollback: restore from backup" without specifying which backup or how
- Rollback actions that themselves modify state without checkpoints

---

### Final Step: Emit Execution Roadmap

```markdown
## Execution Roadmap

**Task:** [Primary objective]
**Risk Level:** MEDIUM | HIGH
**Activation Reason:** [risk_level | multi_step | persistent_state_modified]
**Total Steps:** [N]
**Point of No Return:** Step [N] (if applicable)

### Phase 1: [Preparation / Setup / Analysis]
- [ ] Step 1: [Action] — Skill: [name] — Checkpoint: [criterion]
- [ ] Step 2: [Action] — Skill: [name] — Rollback: [action]

### Phase 2: [Execution]
- [ ] Step 3: [Action] — Skill: [name] ⚠️ IRREVERSIBLE — Confirmation Gate required
- [ ] Step 4: [Action] — Skill: [name] — Checkpoint: [criterion]

### Phase 3: [Validation / Cleanup]
- [ ] Step 5: [Action] — Skill: [name]

### Rollback Plan
| Step | Rollback Action | Feasible Until |
|---|---|---|
| Step 2 | [action] | Before Step 3 |

### Skills Flagged for Follow-up
- **decision-confirmation-gate**: Step 3 is irreversible — requires explicit approval
- **engineering-decision-logging**: [If applicable]
```

---

## Core Responsibilities

1. Confirm Stage 4 activation conditions before producing a plan
2. Decompose each skill in the ordered chain into atomic, testable steps
3. Insert mandatory validation checkpoints at state-change boundaries
4. Identify and mark all irreversible steps; flag Confirmation Gate
5. Define concrete rollback actions for all reversible state-modifying steps
6. Keep the plan aligned with the intent model's scope boundary (PS-3)

**Quality criteria:**

* Every step is atomic — one action, one outcome
* Every irreversible step is preceded by a checkpoint
* Every state-modifying step has a defined rollback action or is marked irreversible
* Plan scope does not exceed the intent model's scope boundary

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-3: Scope Control**
  - The plan must not introduce steps that fall outside the intent model's scope boundary. If a step is needed but out of scope, surface it as a separate task rather than embedding it silently.

### DevOps & Deployment Rules

* **DD-2: Rollback Readiness**
  - Every state-modifying step must have a defined rollback action, or must be explicitly marked as irreversible with a Confirmation Gate flag. No step may silently lack a recovery path.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - Planning decisions — granularity level, checkpoint placement, rollback strategy choices — must be logged when they involve a non-obvious tradeoff.

---

## Tradeoff Handling

### Tradeoff 1: Granularity vs Efficiency

**Conflict:** Highly granular plans reduce risk but increase overhead and complexity.

**Resolution:**
```
IF step is irreversible OR high-risk → decompose to atomic level regardless of overhead
IF step is reversible AND low-risk within a MEDIUM task → group into logical units
IF overplanning is delaying execution → reduce granularity for recoverable steps, log via DT-1
→ Fallback: When uncertain, prefer finer granularity for state-modifying steps
```

### Tradeoff 2: Upfront Planning vs Adaptive Iteration

**Conflict:** Detailed upfront plans become stale as execution uncovers new information.

**Resolution:**
```
IF task is well-understood → produce full roadmap upfront
IF task has high uncertainty → plan to the next checkpoint only; note that plan will be extended
IF mid-execution scope change occurs → re-trigger Task Planning for the remaining steps
→ Log adaptive decisions via DT-1
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Irreversible Step Identified

**Trigger:** A step in the plan is irreversible (data deletion, production deployment, schema drop, etc.).

**Action:**
- Mark step ⚠️ IRREVERSIBLE in the roadmap
- Flag decision-confirmation-gate with step details and impact summary
- Do not proceed past this step in Stage 7 without confirmation

---

### Escalation Scenario 2: Rollback Impossible for a State-Modifying Step

**Trigger:** A step modifies persistent state but no rollback action can be defined.

**Action:**
- Classify the step as irreversible
- Flag decision-confirmation-gate
- Surface clearly to user before execution

---

### Escalation Scenario 3: Scope Violation in Plan

**Trigger:** Decomposition produces steps that fall outside the intent model's scope boundary.

**Action:**
- Remove out-of-scope steps
- Log removal via DT-1
- Surface out-of-scope work as a recommended follow-up task

---

### When to halt execution:

* No activation condition is met — do not produce a plan; skip to Stage 5
* Plan cannot be produced without information that is missing from the intent model
* Irreversible steps cannot be confirmed and user rejects the Confirmation Gate

---

## Skill Integration & Orchestration

Task Planning sits between skill-orchestration (Stage 3) and rule-enforcement-engine (Stage 5). It consumes the ordered skill chain and produces the execution roadmap that Stage 7 follows. It is conditional — it does not run for every task.

### Skills That May Be Flagged

| Scenario | Flag This Skill | Reason |
|---|---|---|
| Irreversible step in plan | decision-confirmation-gate | Explicit approval required before Stage 7 executes that step |
| Architectural decision embedded in plan | engineering-decision-logging | Decision must be persisted for audit and retrospective |

---

## Related Skills

**Skills this skill depends on:**
* **intent-parsing** — Provides risk level, scope boundary, and constraints that govern plan construction
* **skill-orchestration** — Provides the ordered skill chain that task-planning decomposes into steps

**Skills this skill cooperates with:**
* **rule-enforcement-engine** — Consumes the execution roadmap at Stage 5 to validate rule compliance before execution
* **decision-confirmation-gate** — Receives irreversible step flags and manages user approval workflow

**Skills this skill may invoke/flag:**
* **decision-confirmation-gate** — For every irreversible step
* **engineering-decision-logging** — When the plan embeds an architectural or governance decision

---

## Governance Hooks

* [ ] Confirm Stage 4 activation condition before producing any plan
* [ ] Mark every irreversible step explicitly; never omit ⚠️ marker
* [ ] Define rollback for every reversible state-modifying step (DD-2)
* [ ] Log granularity and rollback strategy decisions via DT-1
* [ ] Do not include out-of-scope steps in the plan

---

## Example Use Cases

### Example 1: Database Migration (HIGH Risk)

**Scenario:** Migrate users table to new schema with column renames and type changes.

**Plan highlights:**
- Phase 1: Backup current schema and data (Rollback: restore backup)
- Phase 2: Apply migration script in staging (Checkpoint: validate row count and data integrity)
- Phase 3: ⚠️ IRREVERSIBLE — apply to production (Confirmation Gate required)
- Phase 4: Validate production state; run regression tests
- Rollback plan: restore from backup (feasible until Phase 3 step)

---

### Example 2: New Feature with Tests (MEDIUM Risk)

**Scenario:** Add a new REST endpoint with validation logic.

**Plan highlights:**
- Phase 1: Define API contract (Checkpoint: contract reviewed)
- Phase 2: Implement handler + validation (Rollback: revert commit)
- Phase 3: Write and run unit tests (Checkpoint: all tests pass)
- Phase 4: Integration test in staging
- No irreversible steps — no Confirmation Gate needed

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Producing a plan for a LOW-risk single-step task.
✅ **Correct approach:** Check activation conditions first. Task Planning is conditional — skip if not warranted.

❌ **Anti-pattern 2:** Steps defined too coarsely ("migrate the database" as one step).
✅ **Correct approach:** Decompose until each step is atomic with a single, testable outcome.

❌ **Anti-pattern 3:** Omitting rollback actions for state-modifying steps.
✅ **Correct approach:** Every state-modifying step must have a rollback action or be explicitly marked irreversible (DD-2).

❌ **Anti-pattern 4:** Marking a step irreversible without flagging decision-confirmation-gate.
✅ **Correct approach:** Irreversibility and Confirmation Gate flagging are inseparable. One implies the other.

❌ **Anti-pattern 5:** Including steps outside the intent model's scope boundary.
✅ **Correct approach:** Out-of-scope work is surfaced as a recommended follow-up, never silently embedded.

❌ **Anti-pattern 6:** Vague checkpoints ("check it works").
✅ **Correct approach:** Every checkpoint must be a concrete, testable criterion ("row count in new table = row count in old table").

---

## Non-Goals

* ❌ **Executing the plan** — Handled by ORCH-1 Stage 7.
* ❌ **Selecting or sequencing skills** — Handled by skill-orchestration.
* ❌ **Evaluating rule compliance** — Handled by rule-enforcement-engine at Stage 5.
* ❌ **Managing user confirmation** — Handled by decision-confirmation-gate.

---

## Notes for LLM Implementation

1. **Always check activation conditions first** — do not produce a plan for low-risk single-step tasks.
2. **Atomic steps** — each step should have exactly one action, one precondition, one postcondition.
3. **Concrete rollback actions** — "restore from backup" is only acceptable if the backup strategy is specified.
4. **Irreversibility is binary** — a step is either reversible with a defined rollback, or irreversible with a Confirmation Gate. No middle ground.
5. **Scope discipline** — if decomposition surfaces out-of-scope work, surface it separately rather than absorbing it.

---

## Metadata Summary

```yaml
name: task-planning
category: Orchestration & Governance
priority: High
depends_on: [intent-parsing, skill-orchestration]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]
rules_applied: [PS-3, DD-2, DT-1]
documents_needed: []
tags: [planning, decomposition, milestones, checkpoints, rollback]
```

**Key relationships:**
- Depends on: intent-parsing (risk level + scope), skill-orchestration (ordered chain to decompose)
- Flags: decision-confirmation-gate (irreversible steps), engineering-decision-logging (architectural decisions in plan)
- Governed by: PS-3 (scope), DD-2 (rollback), DT-1 (log planning decisions)

---

*End of task-planning-docs.md*
