# Skill Human Spec
# File: intent-parsing-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: intent-parsing
description: Interprets user requests to extract objectives, constraints, risk level, and candidate skills before execution begins.
version: 1.4.0
category: Orchestration & Governance
tags: [intent, parsing, risk-classification, orchestration, disambiguation, goal-detection]
priority: High

depends_on: []
flags_skills: [skill-gap-detection, decision-confirmation-gate, goal-task-decomposition, goal-task-tracking]

inputs: [raw-user-prompt, conversation-history, active-project-context]
outputs: [structured-intent-model, risk-classification, candidate-skill-list, goal-level-flag, continuation-signal]

rules_applied:
  - PS-1  # Requirement Validation — clarify before assuming scope
  - PS-2  # Risk Communication — surface risk early
  - DT-1  # Explicit Tradeoff Logging — log ambiguity resolution decisions

documents_needed: [skill_registry.md]

execution_context: Runs at ORCH-1 Stage 1 (always-active); first skill in every task lifecycle.
---
```

---

# Skill: Intent Parsing

---

## Purpose

**What this skill does:**
Intent Parsing interprets the raw user request to produce a structured intent model that the orchestrator uses to drive all subsequent stages. It extracts explicit and implicit objectives, identifies constraints and assumptions, classifies task type and risk level, and produces a candidate skill list for Stage 2. Where the request is ambiguous or underspecified, this skill triggers clarification rather than making silent assumptions.

It also detects two special input conditions that redirect the normal execution flow before Stage 2: goal-level input (which cannot be reduced to a single testable objective and requires decomposition via `goal-task-decomposition`) and explicit continuation signals (where the user is resuming an in-progress tracked goal via `goal-task-tracking`).

Incorrect intent interpretation is the root cause of most wasted engineering effort. By formalising intent extraction as a governed skill, the framework ensures that work begins on a verified, shared understanding — reducing rework, scope creep, and misaligned deliverables.

A structured intent model gives the orchestrator and all downstream skills a stable, queryable contract. Risk classification here determines which conditional stages activate, preventing unnecessary overhead on low-risk tasks and ensuring appropriate gates on high-risk ones. Goal-level detection prevents the orchestrator from attempting skill selection against a raw goal statement that no single skill set can fulfil in one pass.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Any new user request arrives that requires skill execution
* A request is ambiguous and requires decomposition before skill selection
* The task type is unclear (feature vs refactor vs migration vs architecture)
* Risk level cannot be determined from surface reading alone
* Implicit constraints are suspected but not stated
* A request spans multiple engineering domains
* The user states a broad goal that cannot be reduced to one testable objective
* The user explicitly signals intent to resume a tracked goal ("continue with X", "resume the auth migration", "what's next on goal-001", "please continue with the created goal")

### Do NOT use this skill for:

* Re-parsing intent mid-execution unless scope has materially changed
* Interpreting internal skill outputs (that is context management's concern)
* Answering simple factual questions that require no skill orchestration
* Substituting for domain-specific analysis (handled by phase 1–6 skills)
* Decomposing goals into sub-goals and tasks — that is `goal-task-decomposition`'s responsibility

**Execution Context Details:**
Intent Parsing is always-active at ORCH-1 Stage 1. It runs before any skill is selected or loaded. Its output — the structured intent model — is the contract on which Stage 2 (Skill Selection) operates. It precedes all other Phase 7 skills in every execution. Nothing else in the pipeline runs before it.

---

## Inputs

**Required inputs:**

* **Raw user prompt** — The verbatim request as typed by the user. This is the primary input. Parsed for explicit goals, named artefacts, verbs implying action type, implicit constraints, goal-level framing, and continuation signals.
* **Conversation history** — Prior exchanges in the session. Used to detect implicit assumptions carried forward, prior decisions that constrain scope, and context the user expects to be preserved.
* **Active project context** — Any project metadata in scope: language, framework, architecture style, known constraints, team conventions. May be empty for first interactions.

**Optional inputs:**

* **Prior decision log** — If engineering-decision-logging has already produced entries in this session, they inform constraint detection.
* **skill_registry.md** — Always in context per ORCH-1 design; used to validate that candidate skills exist.

**Documents/Context needed:**

* **skill_registry.md** — Required to validate that candidate skills named in the output actually exist in the registry. Intent Parsing must not name phantom skills.

---

## Outputs

**Primary outputs:**

* **Structured intent model** — A concise structured summary containing: primary objective, secondary objectives, explicit constraints, inferred constraints, assumptions made, task type classification, and scope boundary.
* **Risk classification** — One of: LOW, MEDIUM, HIGH. Set according to ORCH-1 risk model. Determines which conditional stages activate. Must not be understated.
* **Candidate skill list** — Ordered list of kebab-case skill names from skill_registry.md that are likely required to fulfill the intent. Passed to Stage 2.
* **Goal-level flag** — Set to TRUE when the input cannot be reduced to a single testable objective. Causes `goal-task-decomposition` to be flagged and Stage 2 to be blocked.
* **Continuation signal** — Set when the user explicitly signals intent to resume a tracked goal. Carries the referenced goal name or ID. Causes `goal-task-tracking` to be flagged before Stage 2.

**Output format:**

```markdown
## Intent Model

**Primary Objective:** [Single sentence — or "GOAL-LEVEL: see goal flag" if goal-level detected]
**Task Type:** [feature | refactor | migration | architecture | debugging | analysis | devops | hybrid | goal]
**Risk Level:** LOW | MEDIUM | HIGH
**Scope Boundary:** [What is in scope and what is explicitly out of scope]
**Goal-Level Flag:** TRUE | FALSE
**Continuation Signal:** [goal name/ID if detected — omit if not applicable]

### Explicit Constraints
- [Constraint 1]
- [Constraint 2]

### Inferred Constraints
- [Inferred constraint with reasoning]

### Assumptions Made
- [Assumption 1 — state what was assumed and why]

### Candidate Skills
- [skill-name-1]
- [skill-name-2]
(omit if Goal-Level Flag = TRUE or Continuation Signal present — skills selected after goal resolution)

### Clarification Required
- [Question 1 if ambiguity detected — otherwise omit section]

### Skills Flagged for Follow-up
- **skill-gap-detection**: [If no registry skill covers required capability]
- **decision-confirmation-gate**: [If risk = HIGH or irreversible operation detected]
- **goal-task-decomposition**: [If Goal-Level Flag = TRUE]
- **goal-task-tracking**: [If Continuation Signal detected]
```

**Skill flags (if applicable):**

* Flag **skill-gap-detection** when no candidate skill in the registry satisfies the parsed intent
* Flag **decision-confirmation-gate** when risk is HIGH or when irreversibility is detected in the intent
* Flag **goal-task-decomposition** when Goal-Level Flag = TRUE; block Stage 2 until decomposition returns an approved task
* Flag **goal-task-tracking** when a Continuation Signal is detected; load before Stage 2 to surface next pending task

---

## Preconditions

**Conditions that must be met before execution:**

* A user prompt exists in the current turn
* skill_registry.md is in context (per ORCH-1 static import requirement)
* No prior intent model exists for this task (or a scope change has been explicitly declared)

**Validation checks:**

* [ ] skill_registry.md is accessible and has content
* [ ] The user prompt is non-empty
* [ ] No existing valid intent model from the same request is being re-parsed unnecessarily

---

## Step-by-Step Execution Procedure

### Step 1: Extract Primary Objective

**Questions to answer:**
- What is the user explicitly asking to achieve?
- Is there a single primary goal or multiple co-equal goals?
- Are there named artefacts (files, services, APIs) that constrain scope?
- Can a single testable objective be formulated, or is this goal-level input?

**Actions:**
- [ ] Identify the main action verb(s) in the request (build, refactor, debug, design, migrate, continue, resume, etc.)
- [ ] Extract the primary artefact or system component being acted on
- [ ] Attempt to formulate a single-sentence primary objective
- [ ] If no single testable objective is possible → set Goal-Level Flag = TRUE; do not force an objective

**Red flags / Warning signs:**
- Multiple conflicting verbs suggesting scope confusion (e.g., "refactor and add features and optimise")
- No clear target artefact
- Goal stated in outcome terms only ("make it faster") without specifying what to change
- Request spans multiple deliverables or sessions ("build the whole notification system")

**Decision points:**
- If single testable objective is formulated → proceed to Step 2
- If goal-level input detected → set Goal-Level Flag = TRUE; skip to Step 6 (Goal & Continuation Detection)
- If multiple conflicting goals detected → request clarification before proceeding

---

### Step 2: Detect and Extract Constraints

**Questions to answer:**
- What must NOT change during this task?
- Are there performance, compatibility, compliance, or architectural constraints stated or implied?
- Does conversation history contain prior constraints that carry forward?

**Actions:**
- [ ] Scan for explicit constraint language ("must not break", "without changing the API", "GDPR compliant", etc.)
- [ ] Scan conversation history for constraints established in prior turns
- [ ] Identify implicit constraints from project context (e.g., microservice architecture implies backward compatibility concern)

**Red flags / Warning signs:**
- Performance or compliance requirements mentioned without specifics
- Constraints that contradict each other
- User history contains overriding decisions that conflict with current request

**Decision points:**
- If constraint is ambiguous, note as inferred and flag for clarification
- If constraint contradicts prior decision log, escalate to decision-confirmation-gate

---

### Step 3: Classify Task Type

**Questions to answer:**
- Is this a net-new feature, a change to existing code, an infrastructure task, or a design task?
- Does it span multiple domains (e.g., feature + DevOps)?
- Is this exploratory/advisory or implementation-directed?

**Actions:**
- [ ] Map primary verb + artefact to task type taxonomy: feature, refactor, migration, architecture, debugging, analysis, DevOps, hybrid, or goal
- [ ] Determine if single-skill or multi-skill chain is required
- [ ] Note any cross-phase skill requirements

**Red flags / Warning signs:**
- Hybrid task types that are actually scope creep disguised as one request
- Migration tasks underestimated as simple refactors

**Decision points:**
- If task is hybrid, split into ordered sub-intents where possible
- If task type is indeterminate, default to MEDIUM risk and request clarification
- If task type is `goal`, Goal-Level Flag must be TRUE

---

### Step 4: Classify Risk Level

**Questions to answer:**
- Is this operation reversible if it goes wrong?
- Does it touch production, compliance-sensitive data, public APIs, or shared infrastructure?
- Could it cause data loss, downtime, or regulatory violation?

**Actions:**
- [ ] Apply ORCH-1 risk model: LOW = reversible/informational; MEDIUM = state-modifying and recoverable; HIGH = irreversible, destructive, compliance-sensitive, or production-impacting
- [ ] Check for any language implying permanence ("delete", "drop", "migrate permanently", "release to production")
- [ ] Set risk level conservatively — if uncertain between LOW and MEDIUM, choose MEDIUM

**Red flags / Warning signs:**
- Any mention of production systems without explicit rollback discussion
- Data deletion or schema migration
- Compliance-adjacent features (authentication, payments, PII)
- Ambiguous scope with potentially irreversible side effects

**Decision points:**
- If HIGH risk detected, ensure decision-confirmation-gate is flagged
- Risk level set here may be escalated by later stages but MUST NOT decrease

---

### Step 5: Build Candidate Skill List

**Questions to answer:**
- Which skills in skill_registry.md map to the parsed task type and domain?
- Are there dependency relationships between candidate skills that constrain ordering?
- Is any required capability absent from the registry?

**Actions:**
- [ ] Match task type and domain keywords against skill names and categories in skill_registry.md
- [ ] Produce ordered list of candidate skills in kebab-case
- [ ] Check if all required capabilities are covered by registry entries
- [ ] If coverage gap detected, flag skill-gap-detection
- [ ] If Goal-Level Flag = TRUE or Continuation Signal present → omit candidate skill list; skills are determined after goal resolution

**Red flags / Warning signs:**
- Intent requires a capability with no matching skill in registry
- More than 8 candidate skills (may indicate scope that needs decomposition)

**Decision points:**
- If no skill covers required capability → flag skill-gap-detection
- If candidate list is empty → abort with explanation
- If Goal-Level Flag = TRUE → skip this step; flag goal-task-decomposition instead

---

### Step 6: Goal & Continuation Detection (new in v1.1.0)

This step runs in parallel with Steps 1–5. It is not sequential — detection can occur at any point during parsing and immediately influences output.

**Goal-level detection — questions to answer:**
- Can the request be reduced to a single testable objective after Steps 1–3?
- Does the request span multiple sessions, deliverables, or skill sets?
- Does the user frame it with goal-language: "I want to build", "we need to", "let's create", "I want to"?

**Actions:**
- [ ] Apply the primary criterion: flag goal-level when the task has a meaningful probability of error or context loss if executed in a single pass — i.e., when it is NOT reducible to one atomic, certain action → set Goal-Level Flag = TRUE
- [ ] Evaluate using these signals (any one is sufficient to flag goal-level):
  - Multiple steps where step N depends on step N-1 succeeding correctly
  - Decisions that can't be made until earlier results are known
  - Scope large enough that context drift is likely mid-execution
  - Ambiguity about what "done" looks like
  - Changes span multiple files, systems, or components where an error propagates silently
- [ ] Flag `goal-task-decomposition`
- [ ] Block Stage 2 — do not emit a candidate skill list
- [ ] Log the goal-level detection as an assumption via DT-1

**Continuation signal detection — questions to answer:**
- Does the user explicitly signal resumption of tracked work?
- Is a specific goal, goal ID, or goal name referenced?

**Actions:**
- [ ] Scan for explicit continuation language: "continue with", "resume", "what's next on", "please continue with the created goal", "next task for", "pick up where we left off on"
- [ ] If detected → set Continuation Signal with referenced goal name or ID
- [ ] Flag `goal-task-tracking`
- [ ] Do not emit a candidate skill list — `goal-task-tracking` surfaces the next task, which becomes the input for Stage 2
- [ ] If signal is ambiguous (no specific goal named and multiple goals may exist) → ask one clarifying question: which goal to resume

**Red flags / Warning signs:**
- User says "continue" without naming a goal and no prior context identifies which goal
- User signals continuation but `goals/` directory has no matching in-progress file (surface to user; offer to re-decompose)

**Decision points:**
- Goal-Level Flag = TRUE → flag goal-task-decomposition → block Stage 2
- Continuation Signal detected → flag goal-task-tracking → proceed to Stage 2 after tracking surfaces next task
- Both detected simultaneously (unlikely but possible) → Goal-Level Flag takes precedence; surface conflict to user

---

### Final Step: Produce Structured Intent Model

**Report/Output structure:**

```markdown
## Intent Model

**Primary Objective:** [Single sentence — clear, testable — or "GOAL-LEVEL INPUT" if flag set]
**Task Type:** [feature | refactor | migration | architecture | debugging | analysis | devops | hybrid | goal]
**Risk Level:** LOW | MEDIUM | HIGH
**Scope Boundary:** [In scope: X. Out of scope: Y.]
**Goal-Level Flag:** TRUE | FALSE
**Continuation Signal:** [goal name/ID — omit if not applicable]

### Explicit Constraints
- [Constraint extracted verbatim or paraphrased from request]

### Inferred Constraints
- [Constraint with reasoning: "Inferred because X implies Y"]

### Assumptions Made
- [Assumption — state what was assumed and why it is reasonable]

### Candidate Skills
- [skill-name-1]
- [skill-name-2]
- [skill-name-n]
(omit section if Goal-Level Flag = TRUE or Continuation Signal present)

### Clarification Required
- [Question if ambiguity remains — omit section if none]

### Skills Flagged for Follow-up
- **skill-gap-detection**: [If no registry skill covers required capability]
- **decision-confirmation-gate**: [If risk = HIGH or irreversible operation detected]
- **goal-task-decomposition**: [If Goal-Level Flag = TRUE]
- **goal-task-tracking**: [If Continuation Signal detected]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Extract the primary objective from the user request accurately and without distortion
2. Identify all explicit and inferred constraints that govern execution
3. Classify task type accurately to enable correct skill selection
4. Classify risk level conservatively and in accordance with the ORCH-1 risk model
5. Produce a valid candidate skill list referencing only registry-verified skills
6. Trigger clarification when ambiguity would cause silent assumption
7. Detect goal-level input and flag `goal-task-decomposition` before Stage 2 proceeds
8. Detect explicit continuation signals and flag `goal-task-tracking` before Stage 2 proceeds

**Quality criteria:**

* The intent model is sufficient for Stage 2 to select skills without re-reading the raw prompt
* Risk classification does not understate risk
* Candidate skills are all present in skill_registry.md
* Ambiguity is surfaced explicitly, not silently resolved
* Goal-Level Flag is set correctly — never forced to FALSE when a single testable objective cannot be formulated
* Continuation signals are never inferred from vague input — only from explicit resumption language

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-1: Requirement Validation**
  - How this rule applies: Before proceeding, intent-parsing must validate that the user's request aligns with a coherent, achievable objective. It must not proceed on requests that are contradictory, out of scope, or insufficiently specified without clarification.
  - In practice: If the request contains conflicting goals or missing preconditions, ask a targeted clarifying question before emitting the intent model. If the request is goal-level, flag decomposition rather than forcing a false objective.

* **PS-2: Risk Communication**
  - How this rule applies: Any detected risk at MEDIUM or HIGH must be surfaced explicitly in the intent model, not buried or omitted.
  - In practice: Risk classification is a required field in the output. It cannot be omitted or left as "unknown."

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How this rule applies: When intent-parsing resolves an ambiguity by making an assumption, that assumption must be stated explicitly in the "Assumptions Made" section of the intent model.
  - In practice: Do not silently pick an interpretation. Log the chosen interpretation and why it was chosen. Goal-level detection and continuation signal detection must also be logged as assumptions when inferred.

---

## Tradeoff Handling

### Tradeoff 1: Speed vs Completeness

**Conflict:** Rapid parsing may miss subtle constraints or implicit requirements, but extensive clarification slows the workflow.

**Resolution:**
```
IF constraint is explicit → include without asking
IF constraint is clearly inferable from project context → include as "inferred" with reasoning
IF constraint is ambiguous and material to execution → ask one targeted question
IF constraint is ambiguous but low-stakes → note as assumption and proceed
→ Log all assumptions via DT-1 in the intent model
→ Fallback: If uncertainty is high and risk is MEDIUM+, ask rather than assume
```

### Tradeoff 2: Strict Clarification vs Conversational Fluidity

**Conflict:** Asking too many clarifying questions creates friction. Asking too few leads to misaligned execution.

**Resolution:**
```
IF more than one clarifying question is needed → prioritise the single highest-impact question
Highest-impact = the unknown that most affects intent model correctness for Stage 2
IF the answer to one question resolves others → ask only that one
IF risk is LOW and intent is mostly clear → proceed with documented assumptions
→ Never ask multiple questions in one turn. Applies before goal-level flag is set; once flag:goal-task-decomposition fires, questioning authority transfers to it.
→ Log the chosen approach via DT-1
```

### Tradeoff 3: Goal-Level vs Task-Level Detection (new in v1.1.0)

**Conflict:** Borderline requests may appear task-level but actually require decomposition. Forcing a testable objective on a goal-level request causes downstream failures.

**Resolution:**
```
The certainty criterion defined in Step 6 is the arbiter — apply it first.

IF uncertain after applying the signals:
  → If even one signal applies → goal-level
  → If no signal clearly applies but doubt remains → prefer goal-level over task-level
  → A task with a statable objective can still be goal-level — never use
    "I can state an objective" as justification for task-level classification

→ Log the uncertainty resolution via DT-1
→ Default: when genuinely uncertain after applying all signals, prefer goal-level
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Completely Ambiguous Intent

**Trigger:** Primary objective cannot be determined from the prompt and conversation history.

**Action:**
- Do NOT emit an incomplete intent model
- Ask one targeted question to disambiguate the primary objective
- Do not proceed to Stage 2 until intent model is valid

**Escalation format:**
```
⚠️ CLARIFICATION NEEDED

Issue: The request does not specify a clear primary objective.
Context: [What was parsed and why it is insufficient]
Question: [Single most important clarifying question]
```

---

### Escalation Scenario 2: No Registry Coverage

**Trigger:** Candidate skill list is empty because no skill in skill_registry.md addresses the parsed intent.

**Action:**
- Emit the intent model with an empty candidate list
- Flag skill-gap-detection immediately
- Do not proceed to Stage 2

---

### Escalation Scenario 3: HIGH Risk Detected

**Trigger:** Risk classification = HIGH.

**Action:**
- Emit the intent model with risk level = HIGH
- Flag decision-confirmation-gate
- Ensure Stage 6 (Confirmation Gate) will activate via ORCH-1 conditional logic

---

### Escalation Scenario 4: Goal-Level Input Detected (new in v1.1.0)

**Trigger:** Input cannot be reduced to a single testable objective.

**Action:**
- Set Goal-Level Flag = TRUE in the intent model
- Flag `goal-task-decomposition`
- Do not emit a candidate skill list
- Block Stage 2 — do not proceed until `goal-task-decomposition` returns an approved task
- Log detection via DT-1

---

### Escalation Scenario 5: Continuation Signal Detected (new in v1.1.0)

**Trigger:** User explicitly signals intent to resume a tracked goal.

**Action:**
- Set Continuation Signal in the intent model with the referenced goal name or ID
- Flag `goal-task-tracking`
- Do not emit a candidate skill list — `goal-task-tracking` surfaces the next task
- If signal is ambiguous (no goal named) → ask one clarifying question before flagging

---

### When to halt execution:

* Primary objective cannot be determined after one clarification attempt
* Request is internally contradictory and cannot be decomposed
* skill_registry.md is not in context (cannot validate candidate skills)
* Goal-Level Flag = TRUE and `goal-task-decomposition` is not available in the registry

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Intent Parsing is always the first skill invoked. It produces the foundation on which all other stages depend. No other skill runs before it in any task.

### How This Skill Integrates

1. **Orchestrator** invokes intent-parsing at Stage 1 for every task
2. Intent-parsing analyses the user request and produces a structured intent model
3. Intent-parsing detects goal-level input or continuation signals and flags appropriate skills
4. Intent-parsing flags downstream skills (skill-gap-detection, decision-confirmation-gate, goal-task-decomposition, goal-task-tracking) if conditions warrant
5. **Orchestrator** passes the intent model to Stage 2 (Skill Selection) — or blocks Stage 2 if goal-level flag is set

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No registry skill covers required capability | skill-gap-detection | Framework cannot proceed without a skill to handle the gap; controlled extension required |
| Risk = HIGH or irreversible operation detected | decision-confirmation-gate | High-risk actions require explicit confirmation before Stage 7 executes |
| Input cannot be reduced to single testable objective | goal-task-decomposition | Goal must be decomposed before skill selection; Stage 2 blocked until approved task returned |
| Explicit continuation signal detected | goal-task-tracking | In-progress goal state must be loaded and next task surfaced before Stage 2 proceeds |

---

## Related Skills

**Skills this skill depends on:**
* None — intent-parsing is foundational; it has no prerequisites.

**Skills this skill cooperates with:**
* **skill-orchestration** — Receives the intent model and candidate skill list; uses them to build the execution chain
* **context-management** — Shares conversation history and project context as inputs; context-management preserves prior decisions that constrain intent parsing

**Skills this skill may invoke/flag:**
* **skill-gap-detection** — Flagged when candidate skill list is empty
* **decision-confirmation-gate** — Flagged when risk = HIGH or irreversible operation is detected
* **goal-task-decomposition** — Flagged when Goal-Level Flag = TRUE; Stage 2 blocked until decomposition complete
* **goal-task-tracking** — Flagged when explicit continuation signal detected; next pending task surfaced before Stage 2

---

## Governance Hooks

* [ ] Log all ambiguity-resolution assumptions via DT-1 in the intent model output
* [ ] Surface risk level explicitly; never omit or leave as "unknown"
* [ ] Do not proceed to Stage 2 if the intent model is incomplete
* [ ] Do not name candidate skills that do not exist in skill_registry.md
* [ ] Trigger clarification rather than silent assumption when constraint is ambiguous and material
* [ ] Log goal-level detection and continuation signal detection via DT-1
* [ ] Never force a testable objective on goal-level input
* [ ] Never infer a continuation signal from vague input — explicit language only

**Audit trail requirements:**

* All assumptions made during parsing must be documented in the "Assumptions Made" section
* Risk classification must be stated with the triggering condition (what in the request caused that level)
* Any clarification request must be logged as a decision point
* Goal-Level Flag = TRUE must be logged with the reason no single testable objective was possible
* Continuation Signal must be logged with the exact phrase that triggered detection

---

## Example Use Cases

### Example 1: Clear Low-Risk Request

**Scenario:** User asks: "Add a helper method to format currency values in the existing Utils class."

**Inputs provided:**
- Prompt: as above
- Context: Java Spring Boot project, existing Utils class

**Execution steps:**
1. Objective extracted: Add currency formatting helper to Utils class — single testable objective confirmed
2. Goal-Level Flag = FALSE; no continuation signal
3. Constraints: Must not break existing Utils methods; should follow existing style
4. Task type: feature; Risk: LOW
5. Candidate skills: clean-code-solid, test-creation-strategy

**Result:** PASS — clean intent model emitted, no flags

---

### Example 2: Goal-Level Input (new in v1.1.0)

**Scenario:** User asks: "I want to build a real-time notification system."

**Execution steps:**
1. Attempt single testable objective: cannot formulate — spans data model, delivery, observability, API
2. Goal-Level Flag = TRUE; task type = goal
3. Log detection via DT-1: "Cannot reduce to single testable objective — spans multiple deliverables and skill sets"
4. Flag `goal-task-decomposition`; block Stage 2
5. Omit candidate skill list

**Result:** PASS — goal-task-decomposition flagged; Stage 2 blocked pending decomposition

**Output produced:**
```
## Intent Model
**Primary Objective:** GOAL-LEVEL INPUT
**Task Type:** goal
**Risk Level:** MEDIUM
**Scope Boundary:** To be defined during goal decomposition.
**Goal-Level Flag:** TRUE
**Continuation Signal:** N/A

### Assumptions Made
- Cannot reduce to single testable objective — spans multiple deliverables and skill sets (logged via DT-1)

### Skills Flagged for Follow-up
- **goal-task-decomposition**: Goal-Level Flag = TRUE; Stage 2 blocked until approved task returned
```

---

### Example 3: Continuation Signal (new in v1.1.0)

**Scenario:** User says: "Please continue with the notification system goal."

**Execution steps:**
1. Detect explicit continuation language: "please continue with"
2. Referenced goal: "notification system goal"
3. Set Continuation Signal = "notification system"
4. Flag `goal-task-tracking`; omit candidate skill list
5. Log via DT-1

**Result:** PASS — goal-task-tracking flagged; next pending task surfaced before Stage 2

---

### Example 4: Ambiguous Continuation (new in v1.1.0)

**Scenario:** User says: "Continue with my goal." No specific goal named. Multiple in-progress goals exist.

**Execution steps:**
1. Detect continuation language: "continue with my goal"
2. No specific goal named — ambiguous
3. Ask one clarifying question before flagging

**Result:** CLARIFICATION NEEDED — "Which goal would you like to continue? Please name the goal or provide its ID."

---

### Example 5: Ambiguous High-Risk Request (unchanged)

**Scenario:** User asks: "Clean up the database."

**Execution steps:**
1. "Clean up" is ambiguous — could mean schema migration, data deletion, index optimisation, or archiving
2. "Database" without qualification in a production system = HIGH risk potential
3. Cannot emit a valid intent model without clarification

**Result:** CLARIFICATION NEEDED

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Silently choosing one interpretation of an ambiguous request without logging the assumption.
✅ State the assumption explicitly in the "Assumptions Made" section of the intent model.

❌ **Anti-pattern 2:** Understating risk to avoid triggering the Confirmation Gate.
✅ Apply the ORCH-1 risk model conservatively. When uncertain, choose the higher level.

❌ **Anti-pattern 3:** Including candidate skills that do not exist in skill_registry.md.
✅ Validate all candidate skill names against the registry before emitting the intent model.

❌ **Anti-pattern 4:** Asking multiple clarifying questions in a single turn.
✅ Identify the single highest-impact question and ask only that.

❌ **Anti-pattern 5:** Re-parsing intent mid-execution without a scope change event.
✅ Intent Parsing runs once per task. Only re-run if the user explicitly declares a scope change.

❌ **Anti-pattern 6:** Treating all requests as HIGH risk to "be safe."
✅ Apply the ORCH-1 risk model as defined. Overstating risk causes unnecessary gate friction and user fatigue.

❌ **Anti-pattern 7:** Omitting inferred constraints because they aren't stated explicitly.
✅ Inferred constraints must be included, clearly labelled as inferred, with reasoning provided.

❌ **Anti-pattern 8:** Proceeding to Stage 2 with an incomplete or empty candidate skill list.
✅ If the list is empty, flag skill-gap-detection and halt Stage 2 until the gap is resolved.

❌ **Anti-pattern 9:** Treating a task as task-level because a testable objective can be stated, while ignoring that executing it in a single pass has a meaningful probability of error or context loss. (updated in v1.2.0)
✅ Apply the certainty criterion first. A task with a statable objective can still be goal-level if any of the 5 decomposition signals are present. Never force task-level classification to avoid decomposition.

❌ **Anti-pattern 10:** Inferring a continuation signal from vague input like "continue" with no goal reference. (new in v1.1.0)
✅ Continuation signals require explicit resumption language referencing a specific goal. When ambiguous, ask.

❌ **Anti-pattern 11:** Emitting a candidate skill list when Goal-Level Flag = TRUE or a Continuation Signal is present. (new in v1.1.0)
✅ Omit the candidate skill list in both cases. Skills are determined after goal resolution or task surfacing.

---

## Non-Goals

* ❌ **Executing any skill** — Intent Parsing only produces the input for skill selection; it does not invoke skills.
* ❌ **Resolving skill dependencies** — That is skill-dependency-resolution's responsibility (Stage 3).
* ❌ **Enforcing rules** — Rules are evaluated at Stage 5 (Pre-Execution Rule Check), not here.
* ❌ **Domain-specific analysis** — Intent Parsing classifies the task type; it does not perform the engineering analysis itself.
* ❌ **Maintaining session memory** — Context continuity is memory-management's responsibility.
* ❌ **Decomposing goals into tasks** — That is goal-task-decomposition's responsibility.
* ❌ **Loading or reading goal state files** — That is goal-task-tracking's responsibility.

---

## Notes for LLM Implementation

1. **Parse the full prompt plus conversation history** — do not rely on the current turn alone. Critical constraints are often established in earlier turns.
2. **Apply the ORCH-1 risk model literally** — use the three-tier model (LOW/MEDIUM/HIGH) with the defined criteria. Do not invent intermediate levels.
3. **Validate candidate skills against skill_registry.md** — never name a skill that does not exist in the registry.
4. **One clarifying question maximum per turn** — identify the single highest-impact question if clarification is needed. Highest-impact = the unknown that most affects intent model correctness for Stage 2. Applies before goal-level flag is set. Once flag:goal-task-decomposition fires, questioning authority transfers to it.
5. **Log every assumption** — any ambiguity that was resolved by choosing an interpretation must appear in "Assumptions Made."
6. **Goal-level detection is binary** — either a single testable objective can be formulated or it cannot. Do not hedge. If in doubt, prefer goal-level. (new in v1.1.0)
7. **Continuation signals require explicit language** — do not infer from vague input. "Continue" alone is not enough; a goal reference must be present or clarification must be requested. (new in v1.1.0)

**Output format preferences:**
* Use the structured intent model format defined in this spec
* Use consistent terminology: "Explicit Constraints", "Inferred Constraints", "Assumptions Made"
* Risk level must be in capitals: LOW, MEDIUM, HIGH
* Goal-Level Flag must always appear in the intent model output, even when FALSE

**Tone and approach:**
* Be systematic and precise — intent parsing is a contract, not a guess
* Be conservative on risk classification
* Be concise in clarifying questions — one targeted question, clearly worded

---

## Metadata Summary

```yaml
name: intent-parsing
category: Orchestration & Governance
priority: High
depends_on: []
flags_skills: [skill-gap-detection, decision-confirmation-gate, goal-task-decomposition, goal-task-tracking]
rules_applied: [PS-1, PS-2, DT-1]
documents_needed: [skill_registry.md]
tags: [intent, parsing, risk-classification, orchestration, disambiguation, goal-detection]
```

**Key relationships:**
- Depends on: nothing — foundational first-stage skill
- Flags: skill-gap-detection (no registry coverage); decision-confirmation-gate (risk = HIGH); goal-task-decomposition (goal-level input); goal-task-tracking (continuation signal)
- Governed by: PS-1 (validate before proceeding), PS-2 (surface risk), DT-1 (log assumptions)

---

*End of intent-parsing-docs.md*
