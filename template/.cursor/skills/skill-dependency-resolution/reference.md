# Skill Human Spec
# File: skill-dependency-resolution-docs.md
# Purpose: Human-readable comprehensive documentation — never loaded into agent context

---

```yaml
---
name: skill-dependency-resolution
description: Detects, analyzes, and resolves inter-skill dependency conflicts, circular dependencies, and prerequisite violations during orchestration.
version: 1.0.0
category: Orchestration & Governance
tags: [dependencies, orchestration, conflict-resolution, execution-order, governance]
priority: High

depends_on: [skill-orchestration]
flags_skills: [skill-orchestration, decision-confirmation-gate]  # not yet created

inputs: [ordered-skill-chain, skill-registry-metadata, execution-state]
outputs: [dependency-graph, conflict-resolution-plan, revised-execution-order]

rules_applied:
  - DA-4  # Change Boundary Rule — skills must not exceed their declared scope when resolving deps
  - MF-3  # Backward Compatibility — resolution must not break existing skill interfaces
  - DT-1  # Explicit Tradeoff Logging — resolution decisions affecting scope must be logged

documents_needed: []

execution_context: Activated by ORCH-1 Stage 3 when skill_count > 1 or any selected skill declares depends_on; produces revised execution order before Stage 4 (Task Planning).
---
```

---

# Skill: Skill Dependency Resolution

---

## Purpose

**What this skill does:**
Skill Dependency Resolution analyzes the set of skills selected for a task, reads their `depends_on` declarations from their YAML metadata, builds a dependency graph, detects ordering violations and circular dependencies, and produces a revised execution order that satisfies all dependency constraints. If conflicts cannot be resolved automatically, it escalates to the Confirmation Gate.

Prevents incorrect skill execution order from producing invalid outputs, which would require expensive rework. Ensures that prerequisite skills always complete before dependent skills run, maintaining output integrity across the entire task pipeline.

Enforces the directed acyclic graph (DAG) property of skill execution chains. Provides deterministic conflict detection and resolution rather than relying on implicit ordering assumptions. Makes dependency relationships explicit and auditable.

---

## When to Use This Skill

### Triggers (Use this skill when):

* More than one skill is selected for a task (`skill_count > 1`)
* Any selected skill declares `depends_on` in its YAML metadata
* A skill in the execution chain requires output from another skill that has not yet run
* A potential circular dependency is suspected or detected
* Execution order produced by `skill-orchestration` needs validation before task planning begins

### Do NOT use this skill for:

* Selecting which skills to use for a task — that is `skill-orchestration`'s responsibility
* Loading skill files from the registry — that is done by the orchestrator in Stage 2
* Evaluating rule violations — that is `rule-enforcement-engine`'s responsibility
* Planning the detailed step breakdown of a task — that is `task-planning`'s responsibility

**Execution Context Details:**
This skill runs at ORCH-1 Stage 3 (Dependency Resolution), activated conditionally. It receives the ordered skill chain from `skill-orchestration` and returns a revised, dependency-validated execution order. Its output feeds directly into Stage 4 (Task Planning) and Stage 5 (Pre-Execution Rule Check). It is a prerequisite for all subsequent stages when multiple skills are involved.

---

## Inputs

**Required inputs:**

* **Ordered skill chain** — The initial skill execution sequence produced by `skill-orchestration`. May be incomplete or incorrectly ordered with respect to dependencies.
* **Skill registry metadata** — The loaded skill files (already in context from Stage 2), each containing `depends_on` and `flags_skills` YAML fields. Note: these fields are read from loaded skill files, not from `skill_registry.md` which omits them for leanness.
* **Execution state** — Current task state including which skills (if any) have already completed, used when dependency resolution runs mid-task after a re-evaluation.

**Optional inputs:**

* **Explicit override instructions** — Operator-provided instructions to bypass a specific dependency constraint (requires Confirmation Gate approval before applying).

**Documents/Context needed:**

* No external documents required. All inputs derive from the orchestration pipeline.

---

## Outputs

**Primary outputs:**

* **Dependency graph** — A directed graph of all selected skills and their `depends_on` relationships. Visualized as an ordered list with dependency annotations in the output report.
* **Conflict resolution plan** — For each conflict detected (cycle, missing prerequisite, ordering violation), a description of what was detected and how it was resolved or why it could not be resolved.
* **Revised execution order** — The corrected, topologically sorted skill execution sequence that satisfies all dependency constraints. This is the authoritative order handed back to the orchestrator for Stage 4.

**Output format:**

* Structured markdown report with dependency graph, conflicts, and resolved order
* Revised skill execution order as an ordered list (ready for orchestrator consumption)
* Conflict entries formatted as: `[skill-a] → [skill-b]: [conflict type] → [resolution or escalation]`

**Skill flags (if applicable):**

* Flag **skill-orchestration** when the revised execution order differs significantly from the initial plan (e.g., more than 2 skills reordered, or a skill removed from the chain)
* Flag **decision-confirmation-gate** when a conflict cannot be resolved automatically and requires user confirmation before proceeding

---

## Preconditions

**Conditions that must be met before execution:**

* At least one selected skill has `depends_on` declared, OR `skill_count > 1` (ORCH-1 Stage 3 activation condition)
* All selected skill files have been loaded into context (Stage 2 complete)
* The initial skill chain from `skill-orchestration` is available

**Validation checks:**

* [ ] All skills referenced in `depends_on` fields are present in `skill_registry.md`
* [ ] All selected skill files are accessible and their YAML metadata is parseable
* [ ] No skill references itself in its own `depends_on` list

---

## Step-by-Step Execution Procedure

### Step 1: Build the Dependency Graph

**Questions to answer:**
- What does each selected skill declare in its `depends_on` field?
- Are all declared dependencies included in the current skill selection?
- Are there transitive dependencies (A depends on B, B depends on C)?

**Actions:**
- [ ] Read `depends_on` from the YAML metadata of every loaded skill file
- [ ] Build a directed graph: node per skill, directed edge from dependent → prerequisite
- [ ] Identify transitive dependencies — if A depends on B and B depends on C, then A transitively depends on C
- [ ] Check whether all declared prerequisites are present in the active skill selection

**Red flags / Warning signs:**
- A skill's `depends_on` references a skill not in the current selection — missing prerequisite
- A skill's `depends_on` references a skill not registered in `skill_registry.md` — invalid reference
- Deep transitive dependency chains (>4 levels) — may indicate over-coupling between skills

**Decision points:**
- If a prerequisite is missing from the selection, check whether the orchestrator can add it; if not, surface as a gap
- If a `depends_on` reference is invalid (not in registry), treat as a skill validation error and flag `skill-validation` (not yet created) if available

---

### Step 2: Detect Conflicts

**Questions to answer:**
- Are there cycles in the dependency graph?
- Are there ordering violations in the initial skill chain (dependent skill scheduled before its prerequisite)?
- Are there mutual dependencies that cannot be broken?

**Actions:**
- [ ] Run cycle detection on the dependency graph (depth-first search for back edges)
- [ ] Compare initial execution order against topological sort requirements
- [ ] Identify any ordering violations: cases where skill B appears before skill A but B depends on A

**Red flags / Warning signs:**
- Any cycle detected — this is a hard conflict and cannot be resolved automatically
- Multiple ordering violations — may indicate the initial plan was built without dependency awareness
- A dependency chain longer than the total skill count — indicates a cycle (by pigeonhole)

**Decision points:**
- If cycle detected → classify as UNRESOLVABLE → escalate to `decision-confirmation-gate`
- If ordering violation only → classify as REORDERABLE → proceed to Step 3

---

### Step 3: Resolve Reorderable Conflicts

**Questions to answer:**
- What is the valid topological order for the dependency graph?
- Does reordering change the scope of any skill's output significantly?
- Does the reordering require any skill to run that was not in the original plan?

**Actions:**
- [ ] Compute the topological sort of the dependency graph (Kahn's algorithm or equivalent)
- [ ] Produce the revised execution order from the topological sort
- [ ] Verify the revised order does not introduce new conflicts or scope changes
- [ ] Log the reordering decision via DT-1 if the reordering affects more than 2 skills

**Red flags / Warning signs:**
- Topological sort produces multiple valid orderings — pick the one closest to the original intent (prefer minimal disruption)
- Reordering causes a skill to run earlier than originally planned, potentially before its inputs are available from prior task steps

**Decision points:**
- If reordering changes task scope → flag `skill-orchestration` for plan review
- If reordering is minimal (1-2 swaps) → apply silently and note in report

---

### Step 4: Handle Unresolvable Conflicts

**Questions to answer:**
- Is the conflict a true cycle or a false positive?
- Can the conflict be resolved by removing one skill from the chain?
- Does the conflict require human decision?

**Actions:**
- [ ] Re-examine detected cycle for false positives (confirm direction of edges)
- [ ] If confirmed cycle: document which skills form the cycle and what the circular dependency is
- [ ] Assess whether any skill in the cycle can be deferred or substituted
- [ ] Flag `decision-confirmation-gate` with full conflict details

**Red flags / Warning signs:**
- Cycle involves a Phase 7 governance skill (e.g., rule-enforcement-engine depending on itself through a chain) — likely an architectural error in skill definitions
- User proposes removing a Phase 7 skill from the chain to break a cycle — this may violate governance requirements

**Decision points:**
- If override is proposed that would skip a rule-enforcing skill → block and escalate; do not permit bypassing governance skills
- If cycle is in non-governance skills → surface for user decision with option to defer one skill

---

### Final Step: Generate Dependency Resolution Report

**Report structure:**

```markdown
## Skill Dependency Resolution Report

**Task:** [task identifier]
**Date:** [YYYY-MM-DD]
**Status:** ✅ RESOLVED / ⚠️ REORDERED / ❌ UNRESOLVABLE

### Dependency Graph
| Skill | Depends On | Transitive Dependencies |
|-------|-----------|------------------------|
| [skill-a] | [skill-b] | [skill-c via skill-b] |
| [skill-b] | [skill-c] | — |

### Conflicts Detected
| Conflict | Type | Resolution |
|----------|------|-----------|
| [skill-a before skill-b] | Ordering Violation | Reordered |
| [skill-x ↔ skill-y] | Circular Dependency | Escalated |

### Revised Execution Order
1. [skill-c]
2. [skill-b]
3. [skill-a]
4. ...

### Skills Flagged for Follow-up
- **skill-orchestration**: [Reason — significant reordering detected]
- **decision-confirmation-gate**: [Reason — unresolvable cycle detected]

### Overall Assessment
- ✅ RESOLVED: Execution order corrected; no manual intervention required
- ⚠️ REORDERED: Order changed; skill-orchestration notified
- ❌ UNRESOLVABLE: Circular dependency cannot be auto-resolved; user confirmation required

### Required Actions
- [ ] [Specific action if unresolvable]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Read `depends_on` from all loaded skill files and build the dependency graph
2. Detect cycles, ordering violations, and missing prerequisites
3. Resolve ordering violations via topological sort
4. Escalate unresolvable cycles to `decision-confirmation-gate`
5. Produce revised execution order and conflict resolution report

**Quality criteria:**

* All dependency relationships are read from skill YAML metadata — never assumed or inferred
* Every conflict is classified (REORDERABLE or UNRESOLVABLE) — none pass silently
* Revised execution order is topologically valid — no skill runs before its prerequisites
* Every reordering affecting more than 2 skills is logged via DT-1

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-4: Change Boundary Rule**
  - Dependency resolution must not alter a skill's declared scope or responsibilities. It reorders execution; it does not modify what any skill does. Substituting one skill for another is only permissible with explicit user approval via the Confirmation Gate.

### Maintenance & Feature Consistency Rules

* **MF-3: Backward Compatibility**
  - Reordering skills must not break the interface contract between them. If skill A produces output consumed by skill B, reordering must ensure A still runs before B. Compatibility must be preserved across the revised execution order.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - When automatic reordering is applied, the decision must be logged if it affects more than 2 skills or changes the task scope. The log must document what was detected, what the original order was, and what the revised order is.

---

## Tradeoff Handling

### Tradeoff 1: Strict Dependency Enforcement vs. Execution Flexibility

**Conflict:** Strict enforcement of declared `depends_on` constraints may prevent a skill from running in contexts where its dependency's output is not strictly necessary.

**Resolution path:**
```
Detect: depends_on constraint blocks a skill that appears executable without its prerequisite
Evaluate: Is the prerequisite's output actually consumed by the dependent skill?
Options:
  A. Enforce strictly — require prerequisite regardless → safe but may block valid execution
  B. Allow override with confirmation → flexible but risks output integrity
  C. Flag for user decision → most transparent
Decision: Default to Option A (strict enforcement); allow Option B only via Confirmation Gate
Log decision via: DT-1
Fallback: Escalate to decision-confirmation-gate if enforcement blocks critical path
```

---

### Tradeoff 2: Automated Conflict Resolution vs. Manual Confirmation

**Conflict:** Automatically resolving all reorderable conflicts without user visibility may hide structural problems in the skill plan.

**Resolution path:**
```
Detect: Reordering affects >2 skills or changes task scope materially
Evaluate: Is this a trivial reorder or a significant plan change?
Options:
  A. Apply silently — fast but opaque
  B. Log and notify — transparent but adds overhead
  C. Require confirmation — safest but slowest
Decision: Option B for minor reorders; Option C for reorders affecting >2 skills or scope
Log decision via: DT-1
Fallback: When in doubt, prefer Option C
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Circular Dependency Detected

**Trigger:** Cycle detection finds a back edge in the dependency graph — skill A depends on B, B depends on C, C depends on A.

**Action:**
- Classify conflict as UNRESOLVABLE
- Document the full cycle path
- Flag `decision-confirmation-gate` with cycle details and options
- Block task execution pending confirmation

**Escalation format:**
```
⚠️ CIRCULAR DEPENDENCY DETECTED

Issue: A circular dependency exists in the selected skill chain.
Cycle: [skill-a] → depends on [skill-b] → depends on [skill-c] → depends on [skill-a]

This cycle cannot be resolved automatically.

Options considered:
  A. Remove [skill-c] from execution chain — breaks the cycle, but [skill-c] responsibilities unexecuted
  B. Remove [skill-a] from execution chain — breaks the cycle, but [skill-a] responsibilities unexecuted
  C. Redesign skill dependencies — requires changes to skill definitions (out of scope for this task)

Recommendation: Option A if [skill-c] is lower priority; otherwise escalate to framework maintainer.

Question: Which skill can be deferred or removed from this execution chain to break the cycle?
```

---

### Escalation Scenario 2: Missing Prerequisite Not in Registry

**Trigger:** A skill declares `depends_on: [skill-xyz]` but `skill-xyz` does not exist in `skill_registry.md`.

**Action:**
- Classify as an invalid skill reference
- Surface the specific skill name and the skill that declared it
- Flag `skill-gap-detection` if the missing skill represents a real capability need
- Block execution of the dependent skill pending resolution

---

### When to halt execution:

* Unresolvable circular dependency — task cannot proceed with contradictory execution order requirements
* Missing prerequisite that cannot be substituted — dependent skill's output integrity cannot be guaranteed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Skill Dependency Resolution runs at ORCH-1 Stage 3, between Skill Selection (Stage 2) and Task Planning (Stage 4). It is a gate — nothing proceeds to planning or rule checking until a valid, dependency-satisfied execution order exists.

### How This Skill Integrates

1. **Orchestrator** activates this skill when `skill_count > 1` or `depends_on` is declared in any loaded skill
2. **skill-dependency-resolution** reads all loaded skill metadata, builds the graph, detects conflicts
3. Returns revised execution order to orchestrator
4. If significant reordering → flags `skill-orchestration` for awareness
5. If unresolvable → flags `decision-confirmation-gate`
6. **Orchestrator** proceeds to Stage 4 (Task Planning) with validated execution order

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Significant reordering (>2 skills) | skill-orchestration | Original orchestration plan may need to be revised given the new order |
| Unresolvable circular dependency | decision-confirmation-gate | User confirmation required before proceeding |
| Missing prerequisite skill | skill-gap-detection | A declared dependency does not exist in the registry — may be a capability gap |

---

## Related Skills

**Skills this skill depends on:**

* **skill-orchestration** — Produces the initial skill chain that this skill validates and potentially reorders. Must complete before skill-dependency-resolution runs.

**Skills this skill cooperates with:**

* **task-planning** — Consumes the revised execution order produced by this skill to build the step-by-step plan.
* **rule-enforcement-engine** — Operates after dependency resolution. The validated execution order is what rule-enforcement-engine checks at Stage 5.

**Skills this skill may invoke/flag:**

* **skill-orchestration** — When significant reordering is applied, the orchestration plan needs awareness.
* **decision-confirmation-gate** — When circular dependencies cannot be auto-resolved.
* **skill-gap-detection** — When a declared `depends_on` references a skill not in the registry.

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Read `depends_on` only from loaded skill YAML metadata — never infer or assume dependencies
* [ ] Log all reorderings affecting >2 skills via DT-1
* [ ] Never bypass governance skills (rule-enforcement-engine, decision-confirmation-gate) even to break a cycle
* [ ] Surface all detected conflicts — none pass silently
* [ ] Block execution on unresolvable conflicts — do not proceed with an invalid order

**Audit trail requirements:**

* All detected conflicts must appear in the resolution report with conflict type and resolution action
* All reorderings must be logged with before/after execution order
* Escalations to `decision-confirmation-gate` must include the full cycle or conflict description

---

## Example Use Cases

### Example 1: Standard Reordering

**Scenario:** The orchestrator selects three skills: `api-design`, `correctness-validation`, and `test-creation-strategy`. The initial order is [api-design, test-creation-strategy, correctness-validation]. `test-creation-strategy` declares `depends_on: [correctness-validation]`.

**Execution steps:**
1. Read `depends_on` from all three skills — only `test-creation-strategy` has a dependency
2. Build graph: `test-creation-strategy` → `correctness-validation`
3. Detect ordering violation: `test-creation-strategy` is scheduled before `correctness-validation`
4. Topological sort: `api-design` (no deps), `correctness-validation` (no deps), `test-creation-strategy` (after correctness-validation)
5. Revised order: [api-design, correctness-validation, test-creation-strategy]

**Result:** ✅ RESOLVED — Minor reorder applied (1 swap). No logging required (≤2 skills affected).

---

### Example 2: Circular Dependency Escalation

**Scenario:** Skills A, B, and C are selected. A depends on B, B depends on C, C depends on A.

**Execution steps:**
1. Build graph with all three edges
2. Cycle detection finds: A → B → C → A
3. Classify as UNRESOLVABLE
4. Flag `decision-confirmation-gate` with cycle details and options

**Result:** ❌ UNRESOLVABLE — Execution blocked. Confirmation Gate activated.

---

### Example 3: Missing Prerequisite

**Scenario:** `performance-optimization` declares `depends_on: [profiling-skill]`. `profiling-skill` does not exist in `skill_registry.md`.

**Execution steps:**
1. Read `depends_on` — finds `profiling-skill`
2. Check `skill_registry.md` — skill not found
3. Classify as invalid reference
4. Flag `skill-gap-detection`

**Result:** ⚠️ ESCALATED — Dependency on non-existent skill surfaces as a capability gap.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Assuming skill execution order is always safe without checking `depends_on`
✅ **Correct approach:** Always read `depends_on` from loaded skill metadata before proceeding. Never assume order from skill name or category alone.

❌ **Anti-pattern 2:** Inferring dependencies that are not declared
✅ **Correct approach:** Only act on explicitly declared `depends_on` relationships. Inferred or assumed dependencies are not valid inputs to the graph.

❌ **Anti-pattern 3:** Silently reordering without logging when >2 skills are affected
✅ **Correct approach:** Log all significant reorderings via DT-1. Transparency in execution order changes is mandatory.

❌ **Anti-pattern 4:** Attempting to resolve a circular dependency by skipping a governance skill
✅ **Correct approach:** Never remove `rule-enforcement-engine`, `decision-confirmation-gate`, or other governance skills from an execution chain, even to break a cycle. Escalate instead.

❌ **Anti-pattern 5:** Treating `skill_registry.md` as the source for `depends_on` data
✅ **Correct approach:** `skill_registry.md` intentionally omits `depends_on` for leanness. Read it from the loaded skill file's YAML metadata.

❌ **Anti-pattern 6:** Allowing execution to proceed with an unresolved ordering violation
✅ **Correct approach:** Block execution until the dependency graph is resolved. An invalid execution order produces invalid outputs.

❌ **Anti-pattern 7:** Substituting one skill for another to break a dependency conflict without user approval
✅ **Correct approach:** Skill substitution requires explicit Confirmation Gate approval. This skill resolves order, not composition.

---

## Non-Goals

* ❌ **Selecting which skills to run** — That is `skill-orchestration`'s responsibility.
* ❌ **Loading skill files** — That is done by the orchestrator in Stage 2.
* ❌ **Evaluating rule compliance** — That is `rule-enforcement-engine`'s responsibility.
* ❌ **Modifying skill definitions** — This skill resolves execution order, not skill content.
* ❌ **Replacing missing skills** — This skill detects missing prerequisites and flags `skill-gap-detection`; it does not improvise.

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Read metadata explicitly** — Extract `depends_on` by reading the YAML frontmatter of each loaded skill file. Do not rely on memory or prior knowledge of skill relationships.
2. **Build the graph before checking** — Construct the full dependency graph first, then run conflict detection. Do not check conflicts incrementally.
3. **Use topological sort** — For reorderable conflicts, apply a proper topological sort. Do not guess at a valid order.
4. **Never skip governance skills** — Even if removing a Phase 7 skill would resolve a cycle, this is never permitted without explicit user confirmation.
5. **Always produce a report** — Even if no conflicts are detected, produce the dependency report confirming the original order is valid.

**Output format preferences:**

* Dependency graph as a table (skill, depends_on, transitive deps)
* Conflicts as a table (conflict, type, resolution or escalation)
* Revised execution order as a numbered list
* Use ✅ ⚠️ ❌ status indicators

---

## Metadata Summary

```yaml
name: skill-dependency-resolution
category: Orchestration & Governance
priority: High
depends_on: [skill-orchestration]
flags_skills: [skill-orchestration, decision-confirmation-gate, skill-gap-detection]
rules_applied: [DA-4, MF-3, DT-1]
documents_needed: []
tags: [dependencies, orchestration, conflict-resolution, execution-order, governance]
```

**Key relationships:**
- Depends on: skill-orchestration (provides the initial skill chain to validate)
- Flags: skill-orchestration (significant reordering), decision-confirmation-gate (unresolvable cycles), skill-gap-detection (missing declared prerequisites)
- Governed by: DA-4 (resolution must not alter skill scope), MF-3 (backward compatibility of interface contracts preserved), DT-1 (significant reorders logged)

---

*End of Skill Human Spec — skill-dependency-resolution*
