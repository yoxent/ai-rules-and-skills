# Skill: Goal & Task Decomposition
# File: goal-task-decomposition-docs.md
# Location: agents/orchestrator/skills/orchestration-governance/
# NEVER loaded into runtime context — for human review and maintenance only

---

```yaml
---
name: goal_task_decomposition
description: Decomposes goal-level input into an approved two-level hierarchy (goal → sub-goals → tasks) and writes the result to a persistent state file at goals/goal-[id].md.
version: 2.3.0
category: Orchestration Governance
tags: [goal-decomposition, task-planning, orchestration, state-management, iterative-refinement]
priority: High

depends_on: [intent-parsing]
flags_skills: [skill-gap-detection, decision-confirmation-gate]

inputs: [goal-statement, intent-model-flagged-as-goal-level, user-constraints]
outputs: [goal-state-file, human-readable-breakdown, conflict-log]

rules_applied:
  - GM-2   # Explain before acting — present breakdown before writing any file
  - GM-4   # Behavioral transparency — state what is known, assumed, and unknown
  - DT-1   # Explicit tradeoff logging — log decomposition conflicts and resolution decisions
  - DT-2   # Confirmation gate — user must approve before orchestrator proceeds to Stage 2
  - PS-1   # Requirement validation — verify sub-goals are traceable to the stated goal
  - PS-2   # Risk communication — surface undeclared costs or delivery risks found during decomposition
  - PS-3   # Scope control — flag sub-goals or tasks that exceed stated scope
  - CL-4   # Ethical risk flagging — annotate tasks with legal or ethical risk before presenting

documents_needed: [intent-model-from-stage-1, goals-directory-at-project-root]

execution_context: Activates after Stage 1 when intent-parsing flags goal-level input. Blocks Stage 2 until state file is written and user approval is confirmed.
---
```

---

# Skill: Goal & Task Decomposition

---

## Purpose

**What this skill does:**
Goal & Task Decomposition bridges the gap between a high-level user goal and the orchestrator's need for a single, well-scoped, testable task per session. When intent-parsing determines that a user's input cannot be reduced to one testable objective, this skill takes over. It works with the user through an iterative loop to decompose the goal into sub-goals, then into atomic tasks, and writes the approved result to a persistent state file on disk.

Prevents the orchestrator from executing against a misunderstood or under-specified goal. Ensures that complex, multi-session work is planned and approved before any implementation begins. The persistent state file means progress survives context resets — work done in one session is not lost or forgotten.

Produces a deterministic, dependency-aware task graph that the orchestrator can consume one task at a time. Isolates goal-reasoning (which is iterative and conversational) from skill-execution (which is deterministic), keeping each concern in its correct layer.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Intent-parsing flags the input as goal-level (cannot produce a single testable objective)
* The user's request spans multiple sessions or deliverables ("build X", "migrate Y", "improve Z across the codebase")
* No single skill set from the registry can cover the full request in one orchestrator pass
* The user explicitly frames input as a goal: "I want to...", "We need to...", "Let's build..."
* A new `goals/goal-[id].md` file does not yet exist for the stated goal

### Do NOT use this skill for:

* Well-scoped, single-task requests already handled by intent-parsing
* Resuming or updating an existing goal — that is `goal-task-tracking`'s responsibility
* Planning the steps within a single task — that is Stage 4 (Task Planning) in ORCH-1
* Any request where intent-parsing successfully produces one testable objective

**Execution Context Details:**
This skill sits between Stage 1 (Intent Parsing) and Stage 2 (Skill Selection). It is not a stage in the orchestrator — it is a governance skill flagged by intent-parsing and loaded on demand. Stage 2 is blocked until this skill completes and produces an approved state file. The first pending task from that state file then becomes the input for Stage 2 of the current session.

---

## Inputs

**Required inputs:**

* **Goal statement** — The raw user goal as extracted by intent-parsing. A natural-language description of what the user wants to achieve. May be vague — elicitation is part of this skill's responsibility.
* **Intent model (goal-level flag)** — The structured output from Stage 1 indicating that intent-parsing could not produce a single testable objective. Serves as the activation signal for this skill.

**Optional inputs:**

* **User constraints** — Any scope boundaries, priority signals, or exclusions the user stated ("not the UI layer", "this sprint only", "backend only"). These constrain which sub-goals and tasks are in scope.
* **Existing skill registry** — Available in context. Used to validate that every proposed task maps to at least one registered skill.

**Documents/Context needed:**

* **`goals/` directory at project root** — Must exist and be writable. If it does not exist, create it before writing the state file.
* **`skill_registry.md`** — Already in context via static import. Used to validate task addressability.

---

## Outputs

**Primary outputs:**

* **Goal state file (`goals/goal-[id].md`)** — Persistent on-disk record of the approved breakdown. Written once, on user approval. Updated only by `goal-task-tracking`. Schema defined below.
* **Human-readable breakdown** — Presented to the user during the iterative loop. Shows goal, sub-goals, and tasks in a readable hierarchy. Not a file — part of the conversational output.
* **Conflict/dependency log** — Surfaced during iterative review. Lists any detected dependency conflicts, scope overlaps, or unaddressable tasks. Included in the conversational output and referenced in the state file metadata if unresolved at approval.

**State file schema (`goals/goal-[id].md`):**

```markdown
# Goal: [goal-statement]
ID: goal-[zero-padded-id]
Created: [YYYY-MM-DD]
Last-Updated: [YYYY-MM-DD]
Status: in-progress | complete

## Decisions
### D-[n]: [Decision Name]
Type: scope-change | tooling-change | tradeoff
Description: [what was decided]
Rationale: [why]
Date: [YYYY-MM-DD]

## Sub-goals

### SG-1: [Sub-goal Name]
Objective: [one sentence]

#### Task T-1.1: [Task Name]
Objective: [one testable sentence]
Depends-on: []
Status: pending | in-progress | done
Risk-hint: LOW | MEDIUM | HIGH

#### Task T-1.2: [Task Name]
Objective: [one testable sentence]
Depends-on: [T-1.1]
Status: pending
Risk-hint: LOW

### SG-2: [Sub-goal Name]
...
```

**Skill flags (if applicable):**

* Flag **skill-gap-detection** when a proposed task cannot be addressed by any skill in the registry
* Flag **decision-confirmation-gate** when the user cannot reach approval after 2 iteration cycles

---

## Preconditions

**Conditions that must be met before execution:**

* intent-parsing has completed Stage 1 and flagged the input as goal-level
* No existing `goals/goal-[id].md` file covers the same goal (avoid duplicate decomposition)
* `skill_registry.md` is in context (always true via static import)

**Validation checks:**

* [ ] Intent model is present and carries a goal-level flag
* [ ] `goals/` directory is accessible (create if missing)
* [ ] No active goal state file already covers this goal

---

## Step-by-Step Execution Procedure

### Step 1: Confirm Goal-Level Detection

**Questions to answer:**
- Did intent-parsing explicitly flag this as goal-level, or is this a boundary case?
- Is the goal genuinely multi-session, or could it be handled in one orchestrator pass?

**Actions:**
- [ ] Verify the goal-level flag from intent-parsing
- [ ] If borderline, attempt to produce one testable objective. If you can, do not activate this skill — return to intent-parsing

**Decision points:**
- If one testable objective is possible → do not activate this skill; return to Stage 2
- If goal-level confirmed → proceed to Step 2

---

### Step 2: Elicit and Clarify Goal

**Questions to answer:**
- Is the goal statement specific enough to decompose, or does it need scoping?
- Are there explicit constraints or exclusions?

**Actions:**
- [ ] If goal is too vague to decompose, OR if sub-goals cannot be decomposed without resolving unknowns, batch critical unknowns into a single turn; max 5 per turn; prioritize unknowns that block the most sub-goals first
- [ ] Record any stated constraints as scope boundaries
- [ ] Do not proceed to decomposition until a scoped goal statement is confirmed
- [ ] Do not begin Step 3 until all elicited unknowns have been answered — elicitation is a hard stop, not a concurrent step

**Red flags / Warning signs:**
- Goal is defined only by technology ("use microservices") with no stated outcome
- No success criteria are even implicitly present

**Decision points:**
- If elicitation questions were asked but not yet answered → halt; do not proceed to Step 3
- If goal remains vague after one elicitation → halt; request scope narrowing; do not write file
- If goal is sufficiently scoped → proceed to Step 3

---

### Step 3: Propose Initial Decomposition

**Actions:**
- [ ] Decompose goal into sub-goals. Each sub-goal must be a coherent, independently reviewable unit of work. Warn the user if sub-goals exceed 7 — surface warning but do not block
- [ ] For each sub-goal, propose tasks. Warn if tasks per sub-goal exceed 6 — surface warning but do not block. Each task must have: a name, a single testable objective, declared dependencies (task IDs or empty), and a risk hint
- [ ] Apply the leaf-task certainty test to each task: a task passes when it is NOT reducible further — i.e., executing it in a single pass has a meaningful probability of error or context loss. Evaluate using these signals (any one means the task still needs decomposition):
  - Multiple steps where step N depends on step N-1 succeeding correctly
  - Decisions that can't be made until earlier results are known
  - Scope large enough that context drift is likely mid-execution
  - Ambiguity about what "done" looks like
  - Changes span multiple files, systems, or components where an error propagates silently
- [ ] If a leaf task fails the certainty test, recurse one level deeper. Hard cap: if decomposition depth reaches 10, escalate to `decision-confirmation-gate` — do not silently proceed
- [ ] Validate each task against `skill_registry.md` — every task must map to at least one registered skill
- [ ] Flag any task that maps to no registered skill via `skill-gap-detection` before presenting to user
- [ ] If a task may involve legal or ethical risk, annotate that task with a CL-4 warning before presenting
- [ ] Flag any undeclared costs or delivery risks discovered during decomposition per PS-2 before presenting

**Red flags / Warning signs:**
- Any task's objective contains "and" — likely needs splitting
- A task depends on a task in a later sub-goal (potential cycle)
- More than 7 sub-goals suggests the goal itself may need narrowing — surface as a warning
- Depth exceeding 5 levels is unusual — verify the certainty test is being applied correctly before going deeper

**Decision points:**
- If circular dependency detected → flag immediately; do not present breakdown until resolved
- If skill gap detected → flag `skill-gap-detection`; surface gap in the breakdown presentation

---

### Step 4: Iterative Review with User

**Actions:**
- [ ] Present the full breakdown to the user in human-readable form
- [ ] Ask for explicit feedback: What should be removed? What is missing? What is out of scope?
- [ ] Re-decompose based on feedback
- [ ] Repeat until user explicitly approves or iteration limit reached

**Red flags / Warning signs:**
- User keeps adding scope (feature creep in the decomposition itself) — apply PS-3
- User approval is ambiguous ("looks fine", "sure") — confirm explicitly before writing file

**Decision points:**
- If user approves → proceed to Step 5
- If 2 iteration cycles pass without approval → flag `decision-confirmation-gate` with current best breakdown
- If scope creep detected → flag it explicitly; apply PS-3 before accepting additions
- All accepted scope or tooling changes → record in goal state file `## Decisions` section AND log via DT-1 with rationale

---

### Step 5: Write State File

**Actions:**
- [ ] Generate a unique goal ID (increment from highest existing ID in `goals/`, or start at `001`)
- [ ] Write `goals/goal-[id].md` using the schema defined in Outputs
- [ ] Set all task statuses to `pending`
- [ ] Set goal status to `in-progress`
- [ ] Confirm file write succeeded before signalling Stage 2 to proceed

**Decision points:**
- If file write fails → halt; report error; do not proceed to Stage 2
- If write succeeds → surface the first pending task (respecting dependencies) to the orchestrator as the session's working task

---

### Final Step: Hand Off to Orchestrator

**Actions:**
- [ ] Return the first `pending` task (with no unresolved dependencies) as the input for Stage 2
- [ ] Log the decomposition decision via DT-1

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Detect and confirm goal-level input before activating
2. Elicit sufficient scope clarity before decomposing
3. Produce a valid, dependency-consistent two-level breakdown
4. Iterate with the user until explicit approval
5. Write the approved breakdown to a persistent state file
6. Hand off the first pending task to the orchestrator

**Quality criteria:**

* Every task has exactly one testable objective
* Every task maps to at least one registered skill
* No circular dependencies exist in the task graph
* User has explicitly approved the breakdown before the file is written
* State file is complete and parseable on first write

---

## Constraints (Rules Applied)

### Global Meta-Rules

* **GM-2: Explain Before Acting**
  The full breakdown must be presented to the user and approved before the state file is written. Never write first and present after.

* **GM-4: Behavioral Transparency**
  During decomposition, state explicitly what is known (user's stated goal), what is assumed (implied sub-goals), and what is unknown (unstated constraints). Never present assumptions as confirmed scope.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  Log any decomposition decisions where scope was excluded, tasks were merged, or dependency ordering was non-obvious.

* **DT-2: Confirmation Gate**
  User approval is mandatory before the state file is written. Ambiguous approval ("looks fine") is not sufficient — confirm explicitly.

### Product & Stakeholder Rules

* **PS-1: Requirement Validation**
  Every sub-goal must be traceable to the stated goal. Sub-goals that serve a different objective are out of scope. **Greenfield exception:** When no prior project goals file exists, the goal being decomposed constitutes the project's goals definition. PS-1 validation is satisfied upon user approval of the breakdown.

* **PS-2: Risk Communication**
  Any undeclared costs, third-party dependencies with non-obvious pricing, or delivery risks discovered during decomposition must be surfaced before the breakdown is presented.

* **PS-3: Scope Control**
  Flag scope additions during iteration. Apply PS-3 before accepting any expansion beyond the user's original stated boundaries. All accepted scope and tooling changes must be recorded in both: (1) the goal state file under a `## Decisions` section, and (2) the DT-1 traceability log with rationale.

---

## Tradeoff Handling

### Tradeoff 1: Completeness vs. Reviewability

**Conflict:** A thorough decomposition might produce many sub-goals and tasks, which is difficult for a user to review meaningfully. But stopping too early leaves leaf tasks that fail the certainty test, causing execution errors.

**Resolution:**
- Stopping condition is the leaf-task certainty test, not a numeric cap.
- Warn at 7+ sub-goals or 6+ tasks per sub-goal — surface to user but do not block.
- Hard escalation at depth 10 via `decision-confirmation-gate`.
- In practice, most goals reach certainty by depth 3–5. If depth is growing beyond that, verify the certainty test is being applied correctly before going deeper.
- Log depth and stopping decisions via DT-1.

### Tradeoff 2: Speed vs. Accuracy

**Conflict:** The iterative loop adds latency. Users may want to skip review and proceed.

**Resolution:**
- DT-2 is non-negotiable. The confirmation gate cannot be bypassed.
- If the user is resistant to iteration, present the breakdown once and ask for a single approval/rejection decision rather than multi-cycle refinement.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Goal Too Vague

**Trigger:** Goal cannot be decomposed into sub-goals even after one elicitation pass.

**Action:**
- Halt decomposition
- Surface the specific vagueness: "The goal does not define a success condition. What would 'done' look like?"
- Do not write a file. Do not proceed to Stage 2.

---

### Escalation Scenario 2: Skill Gap Detected

**Trigger:** A proposed task maps to no registered skill in `skill_registry.md`.

**Action:**
- Flag `skill-gap-detection` with the task description and the gap identified
- Surface the gap to the user during the breakdown presentation
- Allow the user to either remove the task from scope or accept the gap (pending skill creation)

---

### Escalation Scenario 3: Iteration Limit Reached

**Trigger:** User has not approved the breakdown after 2 iteration cycles.

**Action:**
- Flag `decision-confirmation-gate` with the current best breakdown
- Present the breakdown as a final proposal requiring explicit yes/no approval
- Do not auto-approve. Do not write the file without explicit confirmation.

---

### Escalation Scenario 5: Elicitation Unanswered

**Trigger:** Decomposition is attempted while elicited unknowns from Step 2 have not yet been answered by the user.

**Action:**
- Halt decomposition immediately
- Do not produce any sub-goals or tasks
- Await user response before resuming Step 3

---

### Escalation Scenario 4: File Write Failure

**Trigger:** `goals/goal-[id].md` cannot be written (permissions error, disk issue, etc.).

**Action:**
- Halt immediately
- Report the write failure with the path attempted
- Do not proceed to Stage 2 under any circumstances
- Do not retain the breakdown in memory as a substitute for the file

---

### When to halt execution:

* Goal remains unscopeable after one elicitation pass
* Circular dependency cannot be resolved
* File write fails
* User explicitly rejects the breakdown and provides no alternative direction

---

## Skill Integration & Orchestration

This skill sits between Stage 1 and Stage 2 of the ORCH-1 lifecycle. It is not a lifecycle stage — it is a governance skill dynamically loaded when intent-parsing flags goal-level input.

**Integration workflow:**
1. Stage 1 (Intent Parsing) flags goal-level input
2. Orchestrator loads `goal-task-decomposition` via `view`
3. This skill runs Steps 1–5 (iterative, conversational)
4. On approval, state file is written to `goals/`
5. This skill returns the first pending task as the session's working task
6. Stage 2 proceeds with that task as its intent input
7. On Stage 10 task completion, `goal-task-tracking` is triggered to update the state file

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Task maps to no registered skill | skill-gap-detection | A capability gap must be surfaced before the breakdown is approved |
| User cannot reach approval after 2 cycles | decision-confirmation-gate | Unresolvable ambiguity requires explicit confirmation gate |

---

## Related Skills

**Skills this skill depends on:**
* **intent-parsing** — Provides the goal-level flag and the raw goal statement. This skill does not activate without intent-parsing's signal.

**Skills this skill cooperates with:**
* **goal-task-tracking** — Consumes the state file written by this skill. The two skills share ownership of `goals/goal-[id].md` — this skill writes it once; `goal-task-tracking` reads and updates it thereafter.
* **task-planning** (ORCH-1 Stage 4) — Receives individual tasks from the state file as its input. Task Planning decomposes a single task into atomic steps — this skill's output feeds into that.

**Skills this skill may flag:**
* **skill-gap-detection** — When a proposed task cannot be addressed by any registered skill
* **decision-confirmation-gate** — When iteration limit is reached without user approval

---

## Governance Hooks

* [ ] Log decomposition decisions and scope exclusions via DT-1 (engineering-decision-logging)
* [ ] Present breakdown before writing any file (GM-2)
* [ ] State assumptions explicitly during decomposition (GM-4)
* [ ] Require explicit user approval before state file write (DT-2)
* [ ] Apply scope control on additions during iteration (PS-3)
* [ ] Validate all tasks against skill registry before presenting breakdown
* [ ] Surface undeclared costs or delivery risks discovered during decomposition (PS-2)
* [ ] Log all accepted scope and tooling changes to both the goal state file Decisions section and DT-1

---

## Example Use Cases

### Example 1: Notification System

**Scenario:** User says "I want to build a real-time notification system." Intent-parsing cannot produce one testable objective.

**Inputs provided:**
- Goal: "Build a real-time notification system"
- Constraints: "Backend only, no UI work this sprint"

**Execution steps:**
1. Confirm goal-level: yes, multi-session, no single testable objective possible
2. Propose sub-goals: data model, delivery layer, observability, API surface
3. User removes API surface (out of scope per constraint)
4. Re-decompose 3 sub-goals into 9 tasks total
5. User approves. `goals/goal-001.md` written.
6. First pending task (T-1.1: Define notification schema) returned to orchestrator.

**Result:** PASS — state file written, Stage 2 proceeds with T-1.1.

---

### Example 2: Goal Too Vague

**Scenario:** User says "Improve the system."

**Execution steps:**
1. Confirm goal-level: yes (no testable objective possible)
2. Elicitation: "What aspect of the system? What would 'improved' look like?"
3. User responds: "Just make it better." Still no scoped objective.
4. Halt. Surface: "The goal needs a defined outcome before I can decompose it."

**Result:** HALT — no file written, Stage 2 blocked.

---

### Example 3: Skill Gap Detected

**Scenario:** User wants to build a mobile push notification layer. The registry has no mobile skill.

**Execution steps:**
1. Decompose: sub-goals include "iOS/Android push integration"
2. Task T-3.1 "Implement iOS APNS integration" maps to no registered skill
3. Flag `skill-gap-detection` with gap description
4. Surface gap to user: "Task T-3.1 has no registered skill. Options: remove from scope, or accept as pending skill creation."
5. User removes it from current goal. Decomposition continues.

**Result:** PASS with scope adjustment — gap flagged and resolved before approval.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Writing the state file before user approval.
✅ Present, iterate, confirm — then write.

❌ **Anti-pattern 2:** Stopping decomposition at a fixed depth before the leaf-task certainty test passes.
✅ Decompose until every leaf task can be executed in a single pass with near-certainty of correctness — none of the 5 signals present. Do not stop at an arbitrary level if leaf tasks still fail the certainty test. Hard cap is depth 10; escalate via `decision-confirmation-gate` at that point rather than proceeding silently.

❌ **Anti-pattern 3:** Treating "looks fine" as explicit approval.
✅ Require an unambiguous confirmation ("yes", "approved", "proceed") before writing the file.

❌ **Anti-pattern 4:** Silently resolving dependency conflicts during decomposition.
✅ Surface all dependency conflicts during the iterative review. Let the user decide ordering.

❌ **Anti-pattern 5:** Proceeding to Stage 2 when the file write failed.
✅ File write failure is a hard halt. No exceptions.

❌ **Anti-pattern 6:** Running decomposition when a state file for the same goal already exists.
✅ Check `goals/` before activating. If a relevant state file exists, surface it and trigger `goal-task-tracking` instead.

❌ **Anti-pattern 7:** Accepting scope additions during iteration without flagging them.
✅ Apply PS-3. Every addition beyond the original stated boundaries must be explicitly called out.

❌ **Anti-pattern 8:** Using vague task objectives like "improve performance" or "fix issues."
✅ Every task must have one testable, specific objective. Reject vague tasks during decomposition.

❌ **Anti-pattern 9:** Asking elicitation questions and continuing decomposition in the same pass.
✅ Elicitation is a hard stop. Do not begin Step 3 until the user's answers are received and recorded.

---

## Non-Goals

* ❌ Resuming or updating an existing goal's task statuses — that is `goal-task-tracking`
* ❌ Planning the steps within a single task — that is ORCH-1 Stage 4 (Task Planning)
* ❌ Executing any task — this skill only decomposes and writes the plan
* ❌ Selecting skills for a task — that is ORCH-1 Stage 2 (Skill Selection)

---

## Notes for LLM Implementation

1. **Batch critical unknowns:** If multiple unknowns block decomposition, batch them into a single turn rather than spreading across turns — fewer turns reduces context drift. Max 5 per turn; prioritize unknowns that block the most sub-goals first.
2. **Dependency awareness:** When building the task graph, explicitly check for cycles before presenting. A task that depends on a later task in the same sub-goal is a red flag.
3. **Testable objectives:** Every task objective should pass this test: "Could I write a test that verifies this is done?" If not, the objective needs tightening.
4. **File write is final:** Once the state file is written, this skill's job is done. Do not re-run decomposition on an existing goal — direct to `goal-task-tracking`.
5. **Iteration discipline:** Two cycles maximum. After the second rejection, escalate to `decision-confirmation-gate`. Do not keep iterating indefinitely.

---

## Metadata Summary

```yaml
name: goal_task_decomposition
category: Orchestration Governance
priority: High
depends_on: [intent-parsing]
flags_skills: [skill-gap-detection, decision-confirmation-gate]
rules_applied: [GM-2, GM-4, DT-1, DT-2, PS-1, PS-2, PS-3, CL-4]
documents_needed: [intent-model-from-stage-1, goals-directory-at-project-root]
tags: [goal-decomposition, task-planning, orchestration, state-management, iterative-refinement]
```

**Key relationships:**
- Depends on: intent-parsing (activation signal and raw goal statement)
- Flags: skill-gap-detection (unaddressable task), decision-confirmation-gate (iteration limit)
- Governed by: GM-2 (present before acting), GM-4 (transparency), DT-1 (log decisions), DT-2 (confirmation gate), PS-1 (requirement traceability), PS-3 (scope control)
