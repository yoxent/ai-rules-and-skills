# Skill Human Spec
# File: skill-orchestration-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: skill-orchestration
description: Coordinates and sequences skills required to fulfill a parsed intent, managing execution order, dependencies, and escalation pathways.
version: 1.0.0
category: Orchestration & Governance
tags: [orchestration, skill-selection, execution-chain, sequencing, coordination]
priority: High

depends_on: [intent-parsing]
flags_skills: [skill-dependency-resolution, rule-enforcement-engine]

inputs: [structured-intent-model, skill-registry, dependency-metadata]
outputs: [execution-plan, ordered-skill-chain, escalation-triggers]

rules_applied:
  - DT-1  # Explicit Tradeoff Logging — log sequencing decisions and conflicts
  - PS-3  # Scope Control — prevent skill chain from expanding beyond intent scope
  - MF-3  # Backward Compatibility — ensure skill chain respects interface contracts

documents_needed: [skill_registry.md]

execution_context: Supports ORCH-1 Stages 2 and 3 — skill selection and execution chain construction after intent model is available.
---
```

---

# Skill: Skill Orchestration

---

## Purpose

**What this skill does:**
Skill Orchestration selects the minimal set of skills required to fulfill a parsed intent, resolves their execution order based on dependency declarations, and produces an ordered execution chain ready for rule evaluation and execution. It also detects and escalates circular dependencies and skill conflicts before execution begins.

Uncoordinated skill invocation leads to duplicate work, missed prerequisites, and inconsistent outputs. By formalising orchestration as a governed skill, the framework guarantees that every task is fulfilled by the right skills in the right order — reducing error rates and improving output consistency.

Correct execution ordering prevents invalid intermediate states. Dependency-aware sequencing ensures that skills consuming outputs from other skills always receive complete, valid inputs. Escalation of conflicts before execution prevents runtime failures.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A valid structured intent model has been produced by intent-parsing
* Two or more candidate skills must be sequenced for a task
* A skill declares `depends_on` in its YAML metadata
* The execution chain requires ordering across phases
* A conflict between candidate skills needs resolution before execution
* A skill substitution is required due to a capability overlap or conflict

### Do NOT use this skill for:

* Parsing or interpreting user intent — that is intent-parsing's responsibility
* Evaluating rule compliance — that is rule-enforcement-engine's responsibility at Stage 5
* Resolving circular dependency graphs — escalate to skill-dependency-resolution
* Executing the skill chain — that is the orchestrator's Stage 7 responsibility

**Execution Context Details:**
Skill Orchestration supports Stages 2 and 3 of ORCH-1. At Stage 2 it performs skill selection and path resolution from the registry. At Stage 3 (conditional: `skill_count > 1` OR any skill declares `depends_on`) it resolves execution order. Its output — the ordered execution chain — is consumed by Stage 5 (Pre-Execution Rule Check) and ultimately Stage 7 (Execution).

---

## Inputs

**Required inputs:**

* **Structured intent model** — Produced by intent-parsing. Contains task type, risk level, scope boundary, and candidate skill list. The candidate list is the starting point for skill selection.
* **skill_registry.md** — Always in context. Provides the authoritative kebab-case skill names, phase paths, and rule IDs. Used to resolve full file paths for each selected skill.
* **Dependency metadata** — Read from each loaded skill file's YAML `depends_on` field after the skill file is loaded via `view`. Not sourced from the registry.

**Optional inputs:**

* **Prior execution state** — If a previous skill in the chain has already completed (e.g., in a multi-step session), its output status informs whether its dependents can proceed.

**Documents/Context needed:**

* **skill_registry.md** — Required to resolve skill file paths and validate skill names. Phase header + skill name + `.md` = full path.

---

## Outputs

**Primary outputs:**

* **Ordered skill chain** — List of skill names in execution order, with dependency relationships annotated. Each entry includes the resolved file path and the rule IDs to be evaluated at Stage 5.
* **Execution plan** — Metadata about the chain: single-skill vs multi-skill, whether Stage 3 was activated, identified dependency constraints, and any substitutions made.
* **Escalation triggers** — Signals to the orchestrator: dependency conflict detected (→ skill-dependency-resolution), rule pre-check required (→ rule-enforcement-engine).

**Output format:**

```markdown
## Execution Plan

**Chain Type:** single-skill | multi-skill
**Stage 3 Activated:** yes | no
**Skills Selected:** [count]

### Ordered Skill Chain
1. [skill-name] — path: [resolved-path] — rules: [R1,R2]
2. [skill-name] — path: [resolved-path] — rules: [R1,R2]
   ↳ depends on: [skill-name above]

### Dependency Constraints
- [skill-A] must complete before [skill-B]: [reason]

### Substitutions Made
- [Original skill] → [Substitute skill]: [reason logged via DT-1]

### Skills Flagged for Follow-up
- **skill-dependency-resolution**: [If circular or unresolvable dependency detected]
- **rule-enforcement-engine**: [Always — chain ready for pre-execution rule check]
```

**Skill flags (if applicable):**

* Flag **skill-dependency-resolution** when a circular dependency or unresolvable conflict is detected
* Flag **rule-enforcement-engine** when the ordered chain is ready for Stage 5 pre-execution rule check

---

## Preconditions

**Conditions that must be met before execution:**

* A valid, complete structured intent model exists from intent-parsing
* skill_registry.md is in context
* All candidate skills named in the intent model exist in the registry

**Validation checks:**

* [ ] Intent model is complete (objective, risk level, candidate list all present)
* [ ] All candidate skill names resolve to entries in skill_registry.md
* [ ] skill_registry.md phase headers are intact and parseable

---

## Step-by-Step Execution Procedure

### Step 1: Validate Candidate Skill List

**Questions to answer:**
- Do all candidate skills from the intent model exist in skill_registry.md?
- Are there any names that were flagged but don't resolve?

**Actions:**
- [ ] For each candidate skill name in the intent model, look it up in skill_registry.md
- [ ] Confirm phase header + skill name + `.md` resolves to a valid path
- [ ] Remove any skills that do not resolve; if removal empties the list, flag skill-gap-detection

**Red flags / Warning signs:**
- Candidate skill names that don't appear in any phase section of the registry
- Phase header path missing a trailing `/`

**Decision points:**
- If all candidates resolve → proceed to Step 2
- If any candidate missing and list still non-empty → log substitution via DT-1, proceed
- If list is empty after removal → abort, flag skill-gap-detection

---

### Step 2: Load Skill Files

**Questions to answer:**
- What are the `depends_on` and `rules_applied` declarations of each selected skill?
- Do any skills declare dependencies not in the current candidate list?

**Actions:**
- [ ] For each validated skill, resolve full path: phase base path (from phase header) + skill name + `.md`
- [ ] Load each skill file via `view`
- [ ] Read `depends_on` and `rules_applied` from each loaded skill's YAML frontmatter

**Red flags / Warning signs:**
- A skill's `depends_on` references a skill not in the candidate list
- A skill declares a dependency on a Phase 7 sibling not yet generated

**Decision points:**
- If `depends_on` references a skill not in candidate list → add it to the list and load it
- If `depends_on` reference cannot be resolved → escalate to skill-dependency-resolution

---

### Step 3: Resolve Execution Order

**Questions to answer:**
- Does any skill depend on another skill in the selected set?
- Is there a valid topological ordering of the skill chain?
- Are there circular dependencies?

**Actions:**
- [ ] Build a dependency graph from `depends_on` declarations across all loaded skills
- [ ] Topologically sort the graph to produce execution order
- [ ] Detect any cycles in the graph

**Red flags / Warning signs:**
- Skill A depends on Skill B and Skill B depends on Skill A (circular)
- Two skills both claim to produce the same output with no ordering relationship

**Decision points:**
- If topological sort succeeds → produce ordered chain, activate Stage 3
- If circular dependency detected → flag skill-dependency-resolution → block execution
- If single skill only → Stage 3 not activated; chain is trivially ordered

---

### Step 4: Detect and Resolve Skill Conflicts

**Questions to answer:**
- Do any two selected skills produce conflicting outputs or operate on the same artefact without coordination?
- Does scope creep risk exist (skills selected beyond what intent requires)?

**Actions:**
- [ ] Check for overlapping output domains between selected skills
- [ ] Verify that each selected skill is justified by the intent model (PS-3 scope control)
- [ ] Log any substitution or de-selection decisions via DT-1

**Red flags / Warning signs:**
- Two skills both modify the same interface or schema without ordering
- Skills selected that address concerns not mentioned in the intent model

**Decision points:**
- If conflict is resolvable by ordering → adjust order and log via DT-1
- If conflict requires substitution → substitute and log via DT-1
- If conflict is unresolvable → flag skill-dependency-resolution

---

### Final Step: Emit Execution Plan

**Report/Output structure:**

```markdown
## Execution Plan

**Chain Type:** single-skill | multi-skill
**Stage 3 Activated:** yes | no
**Skills Selected:** [N]
**Risk Level (from intent model):** LOW | MEDIUM | HIGH

### Ordered Skill Chain
1. [skill-name] — path: skills/[phase]/[skill-name].md — rules: [R1,R2,R3]
2. [skill-name] — path: skills/[phase]/[skill-name].md — rules: [R1,R2]
   ↳ depends on: Step 1

### Dependency Constraints
- [skill-A] must complete before [skill-B]: [stated reason]

### Substitutions / Adjustments
- [What changed from the original candidate list and why — logged via DT-1]

### Overall Status
✅ READY — chain is valid, ordered, and ready for Stage 5 rule check
❌ BLOCKED — [reason; flag raised]

### Skills Flagged for Follow-up
- **rule-enforcement-engine**: Chain ready for pre-execution rule check
- **skill-dependency-resolution**: [If conflict or cycle detected]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Validate all candidate skills against skill_registry.md
2. Load each skill file and read dependency and rule metadata
3. Resolve execution order via topological sort of the dependency graph
4. Detect and escalate circular dependencies before execution
5. Control scope — reject skills that are not justified by the intent model
6. Emit a valid, ordered execution chain ready for rule evaluation

**Quality criteria:**

* All skills in the output chain exist in skill_registry.md
* Execution order satisfies all declared `depends_on` constraints
* No circular dependencies pass through to Stage 5
* Every deviation from the original candidate list is logged via DT-1

---

## Constraints (Rules Applied)

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How this rule applies: Any time skill-orchestration makes a non-obvious decision — substituting a skill, changing order, removing a candidate, adding an unlisted dependency — that decision and its rationale must be logged.
  - In practice: Substitutions, de-selections, and order changes appear in the "Substitutions / Adjustments" section of the execution plan.

### Product & Stakeholder Rules

* **PS-3: Scope Control**
  - How this rule applies: The skill chain must not expand beyond what the intent model justifies. Adding skills "just in case" is a scope violation.
  - In practice: Every skill in the final chain must be traceable to a specific element of the intent model (objective, constraint, or risk).

### Maintenance & Feature Rules

* **MF-3: Backward Compatibility**
  - How this rule applies: When sequencing skills that modify shared interfaces or schemas, the ordering must preserve compatibility for any skill consuming those outputs.
  - In practice: Skills that consume another skill's output must always be placed after the producing skill in the chain.

---

## Tradeoff Handling

### Tradeoff 1: Strict Dependency Enforcement vs Execution Flexibility

**Conflict:** Rigid dependency ordering may prevent valid alternative sequences that would also produce correct results.

**Resolution:**
```
IF dependency is declared via depends_on → enforce strictly
IF dependency is inferred (not declared) → log as assumption, apply ordering, flag for review
IF alternative ordering would produce equivalent result → prefer declared ordering
→ Log any flexibility applied via DT-1
→ Fallback: If uncertain, enforce strictly and document
```

### Tradeoff 2: Minimal Skill Set vs Completeness

**Conflict:** Adding more skills increases coverage but risks scope creep and token cost.

**Resolution:**
```
IF skill is directly required by intent model → include
IF skill is useful but not required → exclude; note as optional follow-up
IF skill is triggered by another skill's flags → include only if flag is active
→ Log any inclusion beyond the original candidate list via DT-1
→ Apply PS-3 as the deciding constraint
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Circular Dependency

**Trigger:** Topological sort of the dependency graph fails due to a cycle.

**Action:**
- Block execution
- Surface the cycle explicitly (Skill A → Skill B → Skill A)
- Flag skill-dependency-resolution with the cycle graph

**Escalation format:**
```
⚠️ DEPENDENCY CONFLICT

Issue: Circular dependency detected in skill chain.
Cycle: [skill-A] → [skill-B] → [skill-A]
Context: [What each skill needs from the other]
Options considered:
  A. Remove one skill from the chain
  B. Restructure task to break the cycle
  C. Escalate to skill-dependency-resolution for resolution

Recommendation: Escalate to skill-dependency-resolution.
```

---

### Escalation Scenario 2: Unresolvable Skill Conflict

**Trigger:** Two skills in the chain produce conflicting outputs with no valid ordering.

**Action:**
- Attempt reordering
- If reordering fails, flag skill-dependency-resolution
- If skill-dependency-resolution cannot resolve, abort with explanation

---

### Escalation Scenario 3: Scope Creep in Chain

**Trigger:** A skill is being added to the chain that is not traceable to the intent model.

**Action:**
- Remove the skill
- Log the removal via DT-1
- If the skill's absence would leave the task incomplete, raise clarification with the user

---

### When to halt execution:

* Circular dependency cannot be resolved by skill-dependency-resolution
* Candidate skill list is empty after validation
* Execution chain produces no coverage of the primary objective

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Skill Orchestration bridges intent-parsing (Stage 1) and rule-enforcement-engine (Stage 5). It is the mechanism through which abstract intent becomes a concrete, ordered, executable skill chain.

### How This Skill Integrates

1. **Orchestrator** receives the intent model from intent-parsing
2. Skill Orchestration validates candidate skills and loads skill files via `view`
3. Execution order is resolved from `depends_on` declarations
4. Ordered chain is emitted as input to Stage 5
5. rule-enforcement-engine evaluates the chain against applicable rules before execution

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Circular dependency in chain | skill-dependency-resolution | Cannot resolve cycle without dedicated conflict analysis |
| Unresolvable skill conflict | skill-dependency-resolution | Conflict analysis and substitution logic lives there |
| Chain is valid and ordered | rule-enforcement-engine | Always — chain proceeds to pre-execution rule check |

---

## Related Skills

**Skills this skill depends on:**
* **intent-parsing** — Produces the structured intent model and candidate skill list that skill-orchestration consumes. Without a valid intent model, skill-orchestration cannot begin.

**Skills this skill cooperates with:**
* **skill-dependency-resolution** — Handles conflict escalation when skill-orchestration cannot resolve ordering independently
* **rule-enforcement-engine** — Consumes the ordered chain at Stage 5 to evaluate rule compliance before execution

**Skills this skill may invoke/flag:**
* **skill-dependency-resolution** — When circular or unresolvable dependency detected
* **rule-enforcement-engine** — Always, when a valid ordered chain is produced

---

## Governance Hooks

* [ ] Log all substitutions and order adjustments via DT-1
* [ ] Never add skills to the chain that are not traceable to the intent model (PS-3)
* [ ] Validate all skill names against skill_registry.md before including in chain
* [ ] Surface circular dependencies explicitly before escalating
* [ ] Do not proceed to Stage 5 if the chain has an unresolved conflict

**Audit trail requirements:**

* Every deviation from the original candidate skill list must be logged with reason
* Dependency constraints must be documented in the execution plan
* Conflict escalations must reference the specific skill names and the nature of the conflict

---

## Example Use Cases

### Example 1: Simple Single-Skill Chain

**Scenario:** User asks to add a utility method. Intent model has one candidate: `clean-code-solid`.

**Execution steps:**
1. Validate: `clean-code-solid` exists in registry ✅
2. Load skill file; `depends_on: []`
3. Single skill — Stage 3 not activated
4. Chain: [clean-code-solid]

**Result:** READY — trivial chain, no dependencies to resolve.

---

### Example 2: Multi-Skill Chain with Dependencies

**Scenario:** New microservice task. Intent model candidates: `system-design`, `dependency-management`, `ci-cd-pipeline-automation`.

**Execution steps:**
1. Validate all three against registry ✅
2. Load each; `ci-cd-pipeline-automation` declares `depends_on: [system-design]`
3. Topological sort: system-design → dependency-management → ci-cd-pipeline-automation
4. Stage 3 activated; chain ordered

**Result:** READY — ordered chain emitted.

---

### Example 3: Circular Dependency Detected

**Scenario:** Two custom skills each declare `depends_on` referencing the other.

**Execution steps:**
1. Load both skills; detect cycle in dependency graph
2. Topological sort fails
3. Flag skill-dependency-resolution with cycle details
4. Block execution until resolved

**Result:** BLOCKED — skill-dependency-resolution flagged.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Adding skills to the chain "to be safe" without justification in the intent model.
✅ **Correct approach:** Every skill must be traceable to a specific element of the intent model. Apply PS-3.

❌ **Anti-pattern 2:** Silently reordering skills without logging the change.
✅ **Correct approach:** All order changes must be logged via DT-1 in the substitutions section.

❌ **Anti-pattern 3:** Proceeding with a chain that contains a known circular dependency.
✅ **Correct approach:** Block and flag skill-dependency-resolution immediately.

❌ **Anti-pattern 4:** Reading `depends_on` from skill_registry.md instead of the loaded skill file.
✅ **Correct approach:** The registry omits `depends_on` intentionally. Always read from the loaded skill YAML.

❌ **Anti-pattern 5:** Loading all skills from the registry speculatively for every task.
✅ **Correct approach:** Load only the skills selected for this task. Context cost is proportional to skills loaded.

❌ **Anti-pattern 6:** Treating a skill referenced in `flags_skills` as a dependency.
✅ **Correct approach:** Flagged skills are invoked by the orchestrator based on conditions, not sequenced as dependencies.

❌ **Anti-pattern 7:** Skipping Stage 3 when `skill_count > 1` even if no `depends_on` is declared.
✅ **Correct approach:** Stage 3 activates on `skill_count > 1` OR `depends_on` declared — either condition is sufficient.

❌ **Anti-pattern 8:** Allowing scope creep by including adjacent skills the user did not request.
✅ **Correct approach:** Flag optional follow-up skills in the report; do not include them in the active chain.

---

## Non-Goals

* ❌ **Parsing user intent** — Handled by intent-parsing.
* ❌ **Evaluating rule compliance** — Handled by rule-enforcement-engine at Stage 5.
* ❌ **Resolving complex circular dependencies** — Escalated to skill-dependency-resolution.
* ❌ **Executing the skill chain** — Handled by the orchestrator at Stage 7.
* ❌ **Managing context state across turns** — Handled by context-management.

---

## Notes for LLM Implementation

1. **Always read `depends_on` from the loaded skill file** — not from skill_registry.md, which omits it intentionally.
2. **Apply topological sort mentally** — for chains of 2–4 skills, this is straightforward; for larger chains, be explicit about ordering constraints.
3. **One flag per condition** — do not redundantly flag rule-enforcement-engine multiple times; it is implied by every valid chain.
4. **Scope discipline** — resist the instinct to add "helpful" adjacent skills. PS-3 is the governing constraint.
5. **Log every non-obvious decision** — DT-1 is mandatory for substitutions, de-selections, and inferred ordering decisions.

**Output format preferences:**
* Use the structured execution plan format defined in this spec
* Label each skill in the chain with its resolved path and rule IDs
* Annotate dependency arrows clearly (↳ depends on: Step N)

**Tone and approach:**
* Be systematic — chain construction is deterministic, not judgement-based
* Be minimal — smallest valid chain that fulfils the intent
* Be explicit — every decision in the chain must be traceable

---

## Metadata Summary

```yaml
name: skill-orchestration
category: Orchestration & Governance
priority: High
depends_on: [intent-parsing]
flags_skills: [skill-dependency-resolution, rule-enforcement-engine]
rules_applied: [DT-1, PS-3, MF-3]
documents_needed: [skill_registry.md]
tags: [orchestration, skill-selection, execution-chain, sequencing, coordination]
```

**Key relationships:**
- Depends on: intent-parsing (requires structured intent model as input)
- Flags: skill-dependency-resolution (on conflict/cycle); rule-enforcement-engine (on valid chain)
- Governed by: DT-1 (log all chain decisions), PS-3 (scope control), MF-3 (compatibility ordering)

---

*End of skill-orchestration-docs.md*
