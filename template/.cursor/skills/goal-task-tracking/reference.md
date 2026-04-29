# Skill: Goal & Task Tracking
# File: goal-task-tracking-docs.md
# Location: agents/orchestrator/skills/orchestration-governance/
# NEVER loaded into runtime context — for human review and maintenance only

---

```yaml
---
name: goal_task_tracking
description: Manages goal state file lifecycle — surfaces next pending task on explicit user continuation, marks tasks done at Stage 10, detects goal completion. Never loads proactively.
version: 1.0.0
category: Orchestration Governance
tags: [goal-tracking, task-management, state-persistence, orchestration, session-continuity]
priority: High

depends_on: [goal-task-decomposition]
flags_skills: [goal-task-decomposition, engineering-decision-logging]

inputs: [explicit-continuation-signal, goal-state-file, completed-task-id]
outputs: [next-pending-task, updated-state-file, goal-completion-signal, dependency-conflict-report]

rules_applied:
  - GM-4   # Behavioral transparency — surface goal status, working task, remaining tasks
  - DT-1   # Explicit tradeoff logging — log task completion events and state anomalies
  - MF-1   # Feature consistency — status updates must not corrupt broader goal state
  - MF-5   # Reliability — state file writes must be atomic; no partial writes
  - PS-4   # Decision transparency — goal completion surfaced explicitly to user

documents_needed: [goals-directory-at-project-root]

execution_context: Two activation points — Stage 1 on explicit user continuation signal detected by intent-parsing; Stage 10 on orchestrator task completion trigger. Never activates proactively or via session-start scan.
---
```

---

# Skill: Goal & Task Tracking

---

## Purpose

**What this skill does:**
Goal & Task Tracking manages the ongoing lifecycle of the goal state file written by `goal-task-decomposition`. It activates at two explicit points: when the user signals intent to resume a goal ("continue with the notification system"), and when the orchestrator confirms a task is complete at Stage 10. Between these activations, on-hold goals sit inert on disk with zero token cost.

Enables multi-session, long-running work to survive context resets without requiring the user to manually track progress. A goal broken across many sessions is always resumable with a simple continuation request. Completed work is never lost.

Keeps goal state management cleanly separated from goal decomposition. A single skill owns all mutations to the state file after creation. State transitions are deterministic, atomic, and always confirmed by the orchestrator before being written.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Intent-parsing detects an explicit continuation signal at Stage 1: "continue with goal-001", "resume the auth migration", "what's next on the notification system", "please continue with the created goal"
* Stage 10 confirms a task is complete and a goal state file is active for the current session
* The user asks for the current status of an in-progress goal

### Do NOT use this skill for:

* Creating a new goal breakdown — that is `goal-task-decomposition`
* Automatically loading on every session start — this skill is never proactively triggered
* Modifying task objectives, names, or dependencies — only `status` and `last-updated` fields change after creation
* Planning the steps within a task — that is ORCH-1 Stage 4 (Task Planning)
* Sessions where the user has not signalled intent to work on a tracked goal

**Execution Context Details:**
This skill has two distinct execution paths. The Stage 1 path is read-heavy: load the file, validate it, surface the next task, hand off to Stage 2. The Stage 10 path is write-heavy: receive a completion signal, update the file, check for goal completion, emit signal if needed. Both paths are triggered externally — by intent-parsing (Stage 1) or by the orchestrator (Stage 10). This skill never self-triggers.

---

## Inputs

**Required inputs — Stage 1 activation:**

* **Explicit continuation signal** — Detected by intent-parsing from the user's message. Must be present; this skill does not activate without it.
* **Goal state file** (`goals/goal-[id].md`) — The on-disk record written by `goal-task-decomposition`. If the user names a specific goal, load that file. If ambiguous and multiple `in-progress` files exist, surface a disambiguation list.

**Required inputs — Stage 10 activation:**

* **Completed task ID** — Provided by the orchestrator after Stage 10 confirms completion (e.g., `T-1.2`).
* **Goal state file** — Same file as above; must be loaded to apply the update.

**Documents/Context needed:**

* **`goals/` directory at project root** — Must exist and be accessible. If missing or empty when referenced, halt and report.

---

## Outputs

**Primary outputs:**

* **Next pending task** — The first `pending` task whose full dependency chain is `done`, surfaced in declaration order. Returned to the orchestrator as the session's working task. Includes: task ID, name, objective, risk-hint.
* **Updated state file** — `goals/goal-[id].md` with the completed task marked `done` and `last-updated` refreshed. Written atomically.
* **Goal completion signal** — Explicit conversational notification emitted when all tasks reach `done`: "All tasks for goal-[id] ([goal name]) are complete."
* **Dependency conflict report** — Surfaced during load if a state anomaly is detected (e.g., a `pending` task whose dependency is unexpectedly not `done`).

**Output format:**

* State file mutations touch only `Status` and `Last-Updated` fields — structure is immutable after creation
* Goal completion signal is always conversational and explicit — never only a file change

**Skill flags:**

* Flag **goal-task-decomposition** when a goal is complete and user signals intent to start a new related goal, or when state file is missing and re-planning is needed
* Flag **engineering-decision-logging** when a state corruption event must be recorded for audit

---

## Preconditions

**Conditions that must be met before execution:**

* An explicit continuation signal is present (Stage 1) OR a Stage 10 completion signal is received from the orchestrator
* A `goals/goal-[id].md` file exists at the referenced path
* The target state file is parseable and has status `in-progress`

**Validation checks:**

* [ ] Continuation signal is explicit (not inferred from vague input)
* [ ] `goals/` directory exists and is accessible
* [ ] Target state file exists and conforms to expected schema
* [ ] Goal status is `in-progress` (not `complete`)
* [ ] For Stage 10: completed task ID is provided and Stage 10 criteria are confirmed met

---

## Step-by-Step Execution Procedure

### Stage 1 Activation Path

#### Step 1: Identify Target Goal File

**Actions:**
- [ ] Parse the continuation signal from intent-parsing to identify which goal is being resumed
- [ ] If the signal names a specific goal → load `goals/goal-[id].md` directly
- [ ] If ambiguous and multiple `in-progress` files exist → surface disambiguation list; require explicit selection before proceeding
- [ ] If no `in-progress` files exist → report that no active goals are found; suggest running `goal-task-decomposition`

**Decision points:**
- If file not found → halt; report missing file; offer re-decomposition
- If file is corrupt → halt; report parse failure; flag `engineering-decision-logging`
- If goal status is `complete` → notify user goal is already complete; do not surface a next task

---

#### Step 2: Determine Next Pending Task

**Actions:**
- [ ] Scan tasks for the first `pending` task whose declared dependencies are all `done`, in declaration order
- [ ] If no unblocked `pending` task exists but tasks remain `pending` → surface the dependency blockage to the user
- [ ] If all tasks are `done` → emit goal-completion signal; set goal status to `complete`; write update; do not surface a next task

**Red flags / Warning signs:**
- All remaining `pending` tasks are blocked by other `pending` tasks (dependency deadlock)
- Task order in file doesn't match dependency declarations (state anomaly)

**Decision points:**
- If dependency deadlock → surface blocked tasks; request user resolution; block Stage 2
- If all tasks done → emit completion signal; update file; session ends or user redirected

---

#### Step 3: Hand Off to Orchestrator

**Actions:**
- [ ] Return next pending task (ID, name, objective, risk-hint) to the orchestrator as session intent input
- [ ] Log the task activation via DT-1 on first activation for this task

---

### Stage 10 Activation Path

#### Step 1: Validate Completion Signal

**Actions:**
- [ ] Receive completed task ID from the orchestrator
- [ ] Verify all Stage 10 completion criteria were met: no active rule violations, no pending confirmations, all planned steps executed
- [ ] If criteria not fully met → do not update file; report to orchestrator; task remains `in-progress`

---

#### Step 2: Update State File

**Actions:**
- [ ] Set completed task status to `done`
- [ ] Update `last-updated` in file metadata
- [ ] Write atomically (write-then-rename or equivalent)
- [ ] Confirm write succeeded before reporting completion to orchestrator

**Decision points:**
- If write fails → halt; report error; task remains in previous state; do not declare complete

---

#### Step 3: Check Goal Completion

**Actions:**
- [ ] After confirmed write, check if all tasks in the goal are `done`
- [ ] If yes → set goal status to `complete`; write update; emit explicit goal-completion signal to user
- [ ] If no → surface next pending task (dependency-aware) for user's awareness; session may continue or close

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Activate only on explicit user signal or Stage 10 orchestrator trigger — never proactively
2. Load and validate the goal state file before any read or write operation
3. Surface the correct next pending task (dependency-aware, declaration-ordered) to the orchestrator
4. Mark tasks `done` only after Stage 10 explicit confirmation
5. Write state updates atomically; halt on failure
6. Detect and signal goal completion explicitly when all tasks are `done`

**Quality criteria:**

* State file is never left in a partial or inconsistent state
* Task completion is only recorded after Stage 10 confirms all criteria met
* Goal completion is always surfaced explicitly in conversation
* Zero token cost for sessions that do not reference a tracked goal

---

## Constraints (Rules Applied)

### Global Meta-Rules

* **GM-4: Behavioral Transparency**
  At every activation, surface the current goal name, status, working task, remaining task count, and what was just completed. Never assume the user knows the current state — make it visible.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  Log task completion events via `engineering-decision-logging`. Log state anomalies detected on load.

### Maintenance & Feature Rules

* **MF-1: Feature Consistency**
  Status updates to one task must not affect the status or integrity of other tasks or the goal's overall state.

* **MF-5: Reliability**
  All writes are atomic. A failed write must leave the previous state intact and the failure diagnosable. No partial writes. No silent failures.

### Product & Stakeholder Rules

* **PS-4: Decision Transparency**
  Goal completion is a significant milestone. It must be surfaced explicitly to the user in conversation — not only reflected in the file.

---

## Tradeoff Handling

### Tradeoff 1: Explicit Trigger vs. Automatic Resumption

**Conflict:** Proactive scanning would automatically resume an in-progress goal without the user needing to say anything. More convenient in some cases.

**Resolution:**
- Explicit trigger wins. Token cost for unrelated sessions is zero. On-hold goals do not interfere with other work.
- The tradeoff is that the user must remember to say "continue with X." This is acceptable — the user chose to put the goal on hold and controls when to resume.
- Log this design decision under DT-1 as a framework-level tradeoff.

### Tradeoff 2: Orchestrator Authority vs. Self-Completion

**Conflict:** The skill could theoretically detect task completion from execution context and self-trigger a status update.

**Resolution:**
- Stage 10 is the only valid source of a completion signal. This preserves the orchestrator's authority over the task lifecycle and prevents premature or incorrect status updates.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: State File Missing

**Trigger:** `goals/goal-[id].md` referenced but not found on disk.

**Action:**
- Halt immediately
- Report: "Goal state file not found at goals/goal-[id].md. The file may have been moved or deleted."
- Offer: "Would you like to re-run goal decomposition for this goal?"
- Flag `goal-task-decomposition` if user wants to re-plan

---

### Escalation Scenario 2: State File Corrupt

**Trigger:** File exists but cannot be parsed against expected schema.

**Action:**
- Halt immediately; report specific parse failure
- Do not attempt auto-repair
- Flag `engineering-decision-logging` to record the corruption event

---

### Escalation Scenario 3: Dependency Deadlock

**Trigger:** All remaining `pending` tasks have at least one dependency that is itself `pending`.

**Action:**
- Surface the complete deadlock: list each blocked task and what is blocking it
- Request user resolution: which dependency should be resolved first?
- Block Stage 2 until resolved

---

### Escalation Scenario 4: Ambiguous Continuation Signal

**Trigger:** User says "continue with my goal" but multiple `in-progress` goal files exist.

**Action:**
- Surface a numbered list of all `in-progress` goals with their names and next pending tasks
- Require explicit selection before loading any file
- Do not auto-select based on recency or any other heuristic

---

### Escalation Scenario 5: File Write Failure

**Trigger:** Atomic write of updated state file fails at Stage 10.

**Action:**
- Halt immediately; report the write failure with path attempted
- Task remains in its previous state in the file
- Do not report the task as complete to the orchestrator until write succeeds

---

### When to halt execution:

* State file not found or corrupt
* Dependency deadlock with no user-provided resolution
* File write failure on status update
* Continuation signal present but no `in-progress` goal files exist

---

## Skill Integration & Orchestration

This skill is invoked by the orchestrator at two explicit points. It never self-triggers and never scans `goals/` proactively.

**Integration workflow — Stage 1:**
1. Intent-parsing detects explicit continuation signal
2. Orchestrator flags and loads `goal-task-tracking`
3. Skill identifies target goal file; validates it
4. Skill surfaces next pending task
5. Orchestrator proceeds to Stage 2 with that task as intent input

**Integration workflow — Stage 10:**
1. Stage 10 confirms task completion (all criteria met)
2. Orchestrator triggers `goal-task-tracking` with completed task ID
3. Skill updates state file atomically
4. If all tasks done: emits goal-completion signal; orchestrator session may close
5. If tasks remain: surfaces next pending task for user awareness

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| State file missing; user wants to re-plan | goal-task-decomposition | Re-decomposition needed for same or revised goal |
| State file corrupt | engineering-decision-logging | Corruption event must be recorded for audit |

---

## Related Skills

**Skills this skill depends on:**
* **goal-task-decomposition** — Produces the state file this skill manages. Must have run successfully before this skill can activate.

**Skills this skill cooperates with:**
* **intent-parsing** — Detects the explicit continuation signal that triggers Stage 1 activation. Without intent-parsing's signal, this skill does not load.
* **task-planning** (ORCH-1 Stage 4) — Receives the next pending task surfaced by this skill and decomposes it into atomic execution steps.

**Skills this skill may flag:**
* **goal-task-decomposition** — When state is missing and re-planning is requested by the user
* **engineering-decision-logging** — When state corruption must be recorded

---

## Governance Hooks

* [ ] Activate only on explicit signal — never proactively (token efficiency)
* [ ] Surface current goal status at every Stage 1 activation (GM-4)
* [ ] Log task completion events and state anomalies via DT-1
* [ ] Mark tasks `done` only after Stage 10 explicit confirmation
* [ ] Write state updates atomically — no partial writes (MF-5)
* [ ] Surface goal completion explicitly to the user (PS-4)
* [ ] Never auto-repair corrupt state files

---

## Example Use Cases

### Example 1: Resuming an On-Hold Goal

**Scenario:** User has been working on a notification system goal. Last session completed T-1.1. Now in a new session.

**Input:** "Please continue with the notification system goal."

**Execution:**
1. Intent-parsing detects continuation signal
2. `goal-task-tracking` loads `goals/goal-001.md` — valid, status `in-progress`
3. T-1.1 is `done`. T-1.2 is `pending`, dependency T-1.1 satisfied.
4. Surfaces T-1.2 to orchestrator. Stage 2 proceeds.
5. At Stage 10, T-1.2 completes. File updated. T-2.1 now unblocked.

**Result:** PASS — session continues correctly from where it left off.

---

### Example 2: Goal Completion

**Scenario:** T-3.2 just completed. It is the last `pending` task.

**Execution:**
1. Stage 10 triggers `goal-task-tracking` with T-3.2
2. All Stage 10 criteria confirmed met. File updated: T-3.2 → `done`
3. All tasks now `done`. Goal status set to `complete`. File written.
4. Emits: "All tasks for goal-001 (Real-time Notification System) are complete."

**Result:** PASS — goal closed explicitly; user notified.

---

### Example 3: Unrelated Session — Zero Token Cost

**Scenario:** User says "Refactor the payment service." No continuation signal.

**Execution:**
1. Intent-parsing processes the request normally — no continuation signal detected
2. `goal-task-tracking` is not flagged. Not loaded.
3. `goals/goal-001.md` sits on disk untouched.

**Result:** PASS — zero impact on unrelated work; goal preserved for future resumption.

---

### Example 4: Ambiguous Signal — Multiple Goals

**Scenario:** User says "continue with my goal." Two `in-progress` files exist: `goal-001.md` (notification system) and `goal-002.md` (auth migration).

**Execution:**
1. `goal-task-tracking` detects ambiguity
2. Surfaces: "You have 2 active goals. Which would you like to continue? 1. Notification System (next: T-2.1 — delivery layer schema) 2. Auth Migration (next: T-1.1 — define token model)"
3. Waits for explicit selection

**Result:** HOLD — no auto-selection; user retains control.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Activating at session start without an explicit continuation signal.
✅ This skill only loads when intent-parsing detects a continuation signal or Stage 10 fires. Never proactively.

❌ **Anti-pattern 2:** Marking a task `done` without Stage 10 orchestrator confirmation.
✅ Stage 10 is the only valid source of a completion signal. No exceptions.

❌ **Anti-pattern 3:** Auto-selecting a goal when the continuation signal is ambiguous.
✅ Surface a disambiguation list and require explicit selection.

❌ **Anti-pattern 4:** Silently closing a completed goal without notifying the user.
✅ Goal completion must be surfaced explicitly in conversation.

❌ **Anti-pattern 5:** Attempting to auto-repair a corrupt state file.
✅ Halt and report. Flag `engineering-decision-logging`. Let the user decide.

❌ **Anti-pattern 6:** Surfacing a task whose dependency chain is not fully `done`.
✅ Always verify the full dependency chain before surfacing a task as next.

❌ **Anti-pattern 7:** Non-atomic state file writes.
✅ Write-then-rename or equivalent. If the write fails, the previous state must remain intact.

❌ **Anti-pattern 8:** Modifying task objectives, names, or dependencies in the state file.
✅ Only `Status` and `Last-Updated` fields change after the file is created.

---

## Non-Goals

* ❌ Proactive goal state scanning at session start — never done; zero token cost for unrelated sessions
* ❌ Creating new goal breakdowns — that is `goal-task-decomposition`
* ❌ Planning steps within a task — that is ORCH-1 Stage 4
* ❌ Executing tasks — this skill only manages state
* ❌ Modifying task structure after creation — structure is immutable; only status changes
* ❌ Managing multiple concurrent active goals in a single session without user disambiguation

---

## Notes for LLM Implementation

1. **Two paths, one skill:** Stage 1 path is read-only (load + surface). Stage 10 path is write-only (update + check completion). Keep them cleanly separated in execution — do not blend responsibilities.
2. **Explicit is everything:** This skill's entire design philosophy is explicit over automatic. Never infer that a user wants to continue a goal. Wait for the signal.
3. **Atomic writes only:** Treat all state file writes as atomic. If the runtime doesn't support rename-swap natively, write to a temp file and replace on success. A half-written state file is worse than no update.
4. **Dependency order matters:** When surfacing the next task, traverse in declaration order. Do not pick tasks out of order even if they are technically unblocked.
5. **Goal completion is a moment:** Emit the completion signal in the same response as the final task completion. Do not defer it.

---

## Metadata Summary

```yaml
name: goal_task_tracking
category: Orchestration Governance
priority: High
depends_on: [goal-task-decomposition]
flags_skills: [goal-task-decomposition, engineering-decision-logging]
rules_applied: [GM-4, DT-1, MF-1, MF-5, PS-4]
documents_needed: [goals-directory-at-project-root]
tags: [goal-tracking, task-management, state-persistence, orchestration, session-continuity]
```

**Key relationships:**
- Depends on: goal-task-decomposition (produces the state file this skill manages)
- Flags: goal-task-decomposition (re-planning), engineering-decision-logging (corruption events)
- Governed by: GM-4 (transparency), DT-1 (log completions), MF-1 (consistency), MF-5 (atomic writes), PS-4 (explicit completion signal)
