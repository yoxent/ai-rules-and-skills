# Skill Human Spec
# File: rule-enforcement-engine-docs.md
# Purpose: Human-readable comprehensive documentation — NEVER loaded into agent context

---

```yaml
---
name: rule_enforcement_engine
description: Evaluates active skill outputs and execution plans against the rule registry, blocking or escalating on violations before and after execution.
version: 1.0.0
category: Orchestration & Governance
tags: [rules, enforcement, compliance, governance, validation]
priority: High

depends_on: [intent-parsing, skill-orchestration]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]  # not yet created

inputs: [loaded-skill-yaml-metadata, execution-plan, rule-files]
outputs: [rule-compliance-report, violation-alerts, execution-approval-or-block]

rules_applied:
  - DT-2  # Confirmation Gate — violations requiring override must go through confirmation
  - CL-1  # Regulatory Compliance — compliance-sensitive rules are hard constraints
  - MF-3  # Backward Compatibility — interface and contract violations must be caught

documents_needed: [rules_overview]

execution_context: Runs at ORCH-1 Stage 5 (Pre-Execution Rule Check, always) and Stage 8 (Post-Execution Rule Check, conditional). Rules are loaded on demand from rules_applied in each skill's YAML metadata.

---
```

---

# Skill: Rule Enforcement Engine

---

## Purpose

**What this skill does:**
The Rule Enforcement Engine is the governance checkpoint between skill selection and skill execution. It reads the `rules_applied` list from each loaded skill's YAML metadata, loads the corresponding rule files, evaluates every applicable rule against the proposed execution plan, and blocks or escalates on any violation. It runs twice: before execution (Stage 5, always) and after execution (Stage 8, when persistent state was modified). Rules override skills unconditionally — this skill cannot be bypassed.

Prevents non-compliant, unsafe, or architecturally inconsistent outputs from reaching users. Ensures every execution is governed by the same rule framework regardless of which skill runs. Provides a clear, auditable record of rule evaluations and any approved overrides.

Decouples rule enforcement from skill implementation — skills declare which rules apply; this skill enforces them. This separation means rules can change without modifying skills, and new skills automatically inherit enforcement when they declare rule IDs. Prevents rule evaluation drift where some skills enforce rules and others silently skip them.

---

## When to Use This Skill

### Triggers (Use this skill when):

* ORCH-1 Stage 5 — always, before any skill execution begins
* ORCH-1 Stage 8 — when `persistent_state_modified = TRUE` or `deployment_or_migration = TRUE`
* A rule violation is detected mid-execution and the execution plan must be re-evaluated
* A skill's ON_VIOLATION chain escalates to rule-enforcement-engine

### Do NOT use this skill for:

* Loading or executing skills — that is Skill Orchestration
* Confirming high-risk decisions with the user — that is Decision Confirmation Gate
* Logging approved overrides — that is Engineering Decision Logging
* Validating skill specification structure — that is Skill Validation

**Execution Context Details:**
Rule Enforcement Engine is invoked by the orchestrator at Stage 5 and Stage 8 — never by other skills directly. It reads rule file paths from the `rules_applied` field in each loaded skill's YAML, loads those rule files via `view`, and evaluates them in sequence. Its output (block / proceed / escalate) determines whether the orchestrator continues, pauses for confirmation, or aborts.

---

## Inputs

**Required inputs:**

* **Loaded skill YAML metadata** — The `rules_applied` list from each selected skill; this drives which rule files are loaded
* **Execution plan** — The proposed steps produced by task-planning or skill-orchestration; the subject of rule evaluation
* **Rule files** — Individual rule files loaded on demand via `view rules/<CATEGORY>/<RULE-ID>.md`

**Optional inputs:**

* **Post-execution state** — Actual resulting state after execution, used at Stage 8 to validate compliance of outcomes

**Documents/Context needed:**

* **`rules_overview.md`** — Reference for understanding rule semantics when evaluating ambiguous cases; not loaded per rule but available as context

---

## Outputs

**Primary outputs:**

* **Rule compliance report** — Per-rule evaluation results: PASS, VIOLATION, or WARNING, with evidence for each
* **Violation alerts** — Specific violation descriptions including: rule ID, violated constraint, location in execution plan, and severity
* **Execution approval or block decision** — Binary outcome: PROCEED / BLOCK / ESCALATE TO CONFIRMATION

**Output format:**

* Structured report with per-rule status
* Block or proceed decision surfaced prominently at the top of the report
* Escalation target explicitly named when escalation is required

**Skill flags (if applicable):**

* Flag **decision-confirmation-gate** when a rule violation is detected but the rule permits override via confirmation
* Flag **engineering-decision-logging** when an override is approved and must be recorded for audit

---

## Preconditions

**Conditions that must be met before execution:**

* All skills for the current task have been loaded and their YAML metadata is available
* The execution plan has been produced (by task-planning or skill-orchestration)
* Rule files are accessible via `view rules/<CATEGORY>/<RULE-ID>.md`

**Validation checks:**

* [ ] `rules_applied` field is present and non-empty in at least one loaded skill
* [ ] All rule IDs in `rules_applied` are resolvable to rule files on disk
* [ ] Execution plan is defined (even if minimal for simple tasks)

---

## Step-by-Step Execution Procedure

### Step 1: Collect All Applicable Rule IDs

**Questions to answer:**
- What is the union of all `rules_applied` IDs across every loaded skill?
- Are there any duplicate IDs (evaluate once, not per skill)?
- Are there any rule IDs that cannot be resolved to a file path?

**Actions:**
- [ ] Extract `rules_applied` from every loaded skill's YAML
- [ ] Deduplicate — each rule ID is evaluated once regardless of how many skills reference it
- [ ] Resolve each rule ID to its file path: `rules/<CATEGORY>/<RULE-ID>.md`
- [ ] Flag any unresolvable rule ID as a WARNING — do not silently skip

**Red flags / Warning signs:**
- A rule ID that does not resolve to a file — may indicate a stale skill or missing rule file
- An empty `rules_applied` — rule enforcement cannot run; flag for review

**Decision points:**
- If a rule file is missing → mark WARNING, log, and continue with remaining rules; do not abort enforcement
- If `rules_applied` is empty for all skills → surface WARNING; Stage 5 still completes but with no rules evaluated

---

### Step 2: Load Rule Files

**Actions:**
- [ ] Load each resolved rule file via `view rules/<CATEGORY>/<RULE-ID>.md`
- [ ] Confirm each file is readable and contains the expected rule definition
- [ ] Never load rules speculatively or in bulk — only those in `rules_applied`

**Red flags / Warning signs:**
- Rule file exists but appears empty or malformed
- Rule ID resolves to an unexpected category folder

---

### Step 3: Evaluate Each Rule Against the Execution Plan

**Questions to answer:**
- Does the proposed execution plan comply with this rule's constraints?
- Is any hard constraint (non-overridable) violated?
- Is any soft constraint (overridable via confirmation) violated?
- Does the rule define specific execution conditions that must be met?

**Actions:**
- [ ] For each loaded rule, read its constraint definition
- [ ] Evaluate the execution plan step by step against the constraint
- [ ] Classify each outcome: PASS, VIOLATION (hard), or WARNING (soft/overridable)
- [ ] Record specific evidence for every non-PASS outcome

**Red flags / Warning signs:**
- A step in the execution plan that modifies production state without a rollback point — likely violates DD-2
- A data-handling step with no encryption or access control validation — likely violates CL-3
- An interface modification with no compatibility check — likely violates MF-3

**Decision points:**
- Hard constraint violation → immediately record BLOCK; do not continue evaluating dependent steps
- Soft constraint violation → record ESCALATE; continue evaluating remaining rules
- All rules PASS → record PROCEED

---

### Step 4: Produce Block / Proceed / Escalate Decision

**Questions to answer:**
- Are there any hard violations? (→ BLOCK)
- Are there any soft violations that permit override? (→ ESCALATE)
- Do all rules pass? (→ PROCEED)

**Actions:**
- [ ] If any hard violation exists → produce BLOCK decision, surface violation details
- [ ] If only soft violations exist → produce ESCALATE decision, flag decision-confirmation-gate
- [ ] If no violations → produce PROCEED decision
- [ ] Produce compliance report regardless of outcome

**Decision points:**
- BLOCK: Halt execution, surface rule ID and violated constraint, require user action before proceeding
- ESCALATE: Flag decision-confirmation-gate with full violation context; do not proceed without approval
- PROCEED: Pass execution authorization to the orchestrator

---

### Step 5 (Stage 8 only): Post-Execution State Validation

**Questions to answer:**
- Does the actual resulting state comply with all applicable rules?
- Were any rules satisfied by the execution plan but violated by the outcome?

**Actions:**
- [ ] Load the post-execution state
- [ ] Re-evaluate all rules against the actual outcome (not the plan)
- [ ] Compare plan-time compliance with outcome compliance
- [ ] If a new violation is detected in the outcome → produce BLOCK COMPLETION decision

**Decision points:**
- New violation in outcome → block task completion, escalate to decision-confirmation-gate

---

### Final Step: Generate Rule Compliance Report

**Report/Output structure:**

```markdown
## Rule Enforcement Report

**Stage:** [Pre-Execution (Stage 5) / Post-Execution (Stage 8)]
**Task:** [Task description]
**Date:** [YYYY-MM-DD]
**Decision:** ✅ PROCEED / 🔴 BLOCK / ⚠️ ESCALATE TO CONFIRMATION

### Rule Evaluation Results
| Rule ID | Rule Name | Status | Evidence |
|---------|-----------|--------|----------|
| [ID]    | [Name]    | ✅ PASS / ❌ VIOLATION / ⚠️ WARNING | [Specific finding] |

### Violations Requiring Action
#### ❌ [Rule ID] — [Rule Name]
**Violated constraint:** [Exact constraint from rule definition]
**Location in plan:** [Step number or skill name where violation occurs]
**Severity:** HARD (blocks execution) / SOFT (requires confirmation)
**Override permitted:** Yes / No

### Skills Flagged for Follow-up
- **decision-confirmation-gate**: [Rule ID and violation detail — override required]
- **engineering-decision-logging**: [If override is approved — must be logged]

### Overall Decision
[PROCEED / BLOCK / ESCALATE] — [Summary explanation]

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Collect the union of all `rules_applied` IDs across loaded skills
2. Load each rule file on demand — never speculatively
3. Evaluate each rule against the execution plan with specific evidence
4. Produce a binary block/proceed/escalate decision
5. At Stage 8: re-evaluate against actual outcome, not just plan

**Quality criteria:**

* Every rule evaluation produces a specific, evidence-based finding — no vague "may violate" outputs
* BLOCK decisions always cite the specific rule ID and constraint violated
* No rule in `rules_applied` is silently skipped — unresolvable rules are flagged as warnings

---

## Constraints (Rules Applied)

### Decision & Tradeoff Rules

* **DT-2: Confirmation Gate**
  Violations of rules that permit override must be routed to the Decision Confirmation Gate. The Rule Enforcement Engine does not approve its own overrides — it only identifies violations and escalates. Override authority belongs to the user via the confirmation gate.

### Compliance & Legal Rules

* **CL-1: Regulatory Compliance**
  Compliance-sensitive rules (GDPR, HIPAA, PCI, etc.) are treated as hard constraints. No override is permitted for compliance rule violations without explicit escalation and documented justification. The Rule Enforcement Engine must never silently pass a compliance violation.

### Maintenance & Feature Consistency Rules

* **MF-3: Backward Compatibility**
  Interface and contract changes that violate backward compatibility must be caught and blocked. This rule is a hard constraint for API and schema changes.

---

## Tradeoff Handling

### Tradeoff 1: Strict Enforcement vs. Execution Velocity

**Scenario:** A rule violation is minor and the user wants to proceed quickly.

```
IF violation_is_soft AND user_requests_override
→ Flag decision-confirmation-gate — do not self-approve
→ Require explicit user confirmation before continuing
→ Log override via engineering-decision-logging after approval
→ Fallback: If confirmation not received, maintain BLOCK status
```

### Tradeoff 2: Hard Block vs. Partial Execution

**Scenario:** A hard violation affects only one step of a multi-step plan; other steps are clean.

```
IF hard_violation_affects_single_step AND other_steps_are_compliant
→ Block the violating step specifically — surface clearly which step
→ Do not block compliant steps unless they depend on the blocked step
→ Present options: fix the step, remove it, or abort entirely
→ Log via DT-2 if any partial execution is approved
```

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Hard Rule Violation — No Override Permitted

**Trigger:** A compliance rule (e.g., CL-1) or hard architectural constraint is violated and the rule does not permit override.

**Action:**
- Produce BLOCK decision immediately
- Surface the specific rule ID, violated constraint, and affected plan step
- Do not route to confirmation gate — no override path exists
- Require plan revision before re-evaluation

**Escalation format:**
```
🔴 EXECUTION BLOCKED — Hard Rule Violation

Rule: [Rule ID] — [Rule Name]
Violated constraint: [Exact text from rule definition]
Location: [Step or skill where violation occurs]
Override permitted: NO

Required action: Revise the execution plan to comply with [Rule ID] before proceeding.
```

---

### Escalation Scenario 2: Soft Violation — Override Requested

**Trigger:** A rule violation is detected but the rule explicitly permits override via confirmation.

**Action:**
- Produce ESCALATE decision
- Flag decision-confirmation-gate with full violation context
- Do not proceed until confirmation is received
- After approval: flag engineering-decision-logging

---

### Escalation Scenario 3: Post-Execution Violation (Stage 8)

**Trigger:** The actual outcome violates a rule that the execution plan appeared to satisfy.

**Action:**
- Block task completion immediately
- Surface the discrepancy between planned and actual compliance
- Escalate to decision-confirmation-gate for remediation decision

---

### When to halt execution:

* Any hard constraint violation — no exceptions, no self-approval
* A compliance rule (CL-1, CL-3) is violated — halt and require explicit remediation
* Post-execution state reveals a new violation not present in the plan evaluation

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Rule Enforcement Engine is a mandatory checkpoint invoked by the orchestrator — it is not optional and cannot be skipped by any skill. It sits between skill selection (Stage 2) and skill execution (Stage 7) at Stage 5, and between execution and completion (Stage 10) at Stage 8.

### How This Skill Integrates

**Integration workflow:**
1. **Orchestrator** invokes rule-enforcement-engine at Stage 5 with loaded skill metadata and execution plan
2. Rule-enforcement-engine collects rule IDs, loads rule files, evaluates each rule
3. Produces PROCEED / BLOCK / ESCALATE decision
4. If ESCALATE → flags decision-confirmation-gate
5. If override approved → flags engineering-decision-logging
6. **Orchestrator** resumes or halts based on the decision
7. At Stage 8: orchestrator re-invokes rule-enforcement-engine with post-execution state

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Soft violation requiring override | decision-confirmation-gate | Override must be user-confirmed, not self-approved |
| Override approved after confirmation | engineering-decision-logging | All rule overrides must be logged for audit |

---

## Related Skills

**Skills this skill depends on:**

* **intent-parsing** — Risk classification from Stage 1 informs which rules are most critical to evaluate
* **skill-orchestration** — Provides the execution plan and loaded skill metadata that rule-enforcement-engine evaluates

**Skills this skill cooperates with:**

* **task-planning** — Task-planning inserts rollback checkpoints; rule-enforcement-engine validates that they satisfy rule requirements
* **skill-validation** — Validates rule ID references at authoring time; rule-enforcement-engine enforces at execution time

**Skills this skill may invoke/flag:**

* **decision-confirmation-gate** *(# not yet created)* — Flagged on every soft violation requiring override
* **engineering-decision-logging** *(# not yet created)* — Flagged after every approved override

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never self-approve a rule override — all overrides require decision-confirmation-gate
* [ ] Never silently skip a rule in `rules_applied` — all must be evaluated or flagged as missing
* [ ] Compliance rules (CL-1, CL-3) are always hard constraints — no override path
* [ ] Log all approved overrides via engineering-decision-logging
* [ ] Produce a compliance report on every invocation — no informal pass/fail

**Audit trail requirements:**

* Every rule evaluation run must produce a persisted compliance report
* All BLOCK decisions must record: rule ID, constraint, plan location, and date
* All approved overrides must be logged via engineering-decision-logging with justification

---

## Example Use Cases

### Example 1: Clean Execution — All Rules Pass

**Scenario:** A refactoring task loads `clean-code-solid` and `test-creation-strategy`. Rules: DA-1, DA-5, TQ-1, TQ-4.

**Execution steps:**
1. Collect rule IDs: DA-1, DA-5, TQ-1, TQ-4
2. Load each rule file via view
3. Evaluate plan — no interface changes, no state modifications, tests planned ✅
4. All rules PASS → PROCEED

**Result:** ✅ PROCEED

---

### Example 2: Backward Compatibility Violation — Blocked

**Scenario:** An API change removes a field from a public endpoint. `api-design` skill loaded, `rules_applied: [MF-3, DA-2, ...]`.

**Execution steps:**
1. Load MF-3: Backward Compatibility rule
2. Evaluate plan — field removal detected on public API endpoint
3. MF-3: hard violation — field removal breaks existing consumers ❌
4. BLOCK decision produced; plan revision required

**Result:** 🔴 BLOCK — MF-3 violated; field removal prohibited without migration plan.

---

### Example 3: Performance Tradeoff Requires Confirmation

**Scenario:** Performance optimization violates SOLID principles. `performance-optimization` skill loaded, `rules_applied: [PC-2, DA-5, ...]`.

**Execution steps:**
1. Load PC-2: Tradeoff Confirmation rule
2. Evaluate plan — optimization introduces a SOLID violation; PC-2 requires confirmation
3. Soft violation detected → ESCALATE
4. Flag decision-confirmation-gate with violation context

**Result:** ⚠️ ESCALATE — PC-2 requires user confirmation before proceeding.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Skipping rule evaluation for "simple" tasks
✅ **Correct approach:** Stage 5 always runs. No task classification bypasses rule enforcement.

❌ **Anti-pattern 2:** Self-approving a soft violation to avoid confirmation overhead
✅ **Correct approach:** All overrides route to decision-confirmation-gate. Self-approval is prohibited.

❌ **Anti-pattern 3:** Silently skipping a rule whose file cannot be found
✅ **Correct approach:** Unresolvable rule files are flagged as WARNING in the compliance report; never silently skipped.

❌ **Anti-pattern 4:** Evaluating rules speculatively (loading rules not in `rules_applied`)
✅ **Correct approach:** Load only rules explicitly declared in `rules_applied` from loaded skill YAML.

❌ **Anti-pattern 5:** Producing a vague "may violate" finding without citing specific evidence
✅ **Correct approach:** Every non-PASS finding cites the specific rule constraint and execution plan location.

❌ **Anti-pattern 6:** Blocking all steps when only one step in a multi-step plan violates a rule
✅ **Correct approach:** Block the specific violating step; evaluate dependent steps; surface options.

❌ **Anti-pattern 7:** Treating compliance rules (CL-1, CL-3) as soft constraints
✅ **Correct approach:** Compliance rules are always hard constraints — no override path exists.

❌ **Anti-pattern 8:** Only running at Stage 5 and skipping Stage 8 for state-modifying tasks
✅ **Correct approach:** Stage 8 runs whenever `persistent_state_modified = TRUE` or `deployment_or_migration = TRUE` — both stages are mandatory when triggered.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Approving rule overrides — that is Decision Confirmation Gate
* ❌ Logging approved overrides — that is Engineering Decision Logging
* ❌ Validating skill specification structure — that is Skill Validation
* ❌ Selecting which skills to execute — that is Skill Orchestration

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Load rules from `rules_applied` only** — never speculatively or from memory
2. **Evaluate each rule with specific evidence** — cite the execution plan step, not just the rule name
3. **Never self-approve** — every violation routes to confirmation gate or blocks
4. **Treat compliance rules as absolute** — CL-1 and CL-3 violations are hard stops
5. **Run Stage 8 when triggered** — do not treat post-execution validation as optional

**Output format preferences:**

* Table format for per-rule evaluation results
* Prominent PROCEED / BLOCK / ESCALATE banner at top of report
* Specific violation blocks with required action clearly stated

**Tone and approach:**

* Authoritative — rule enforcement is not advisory; it is deterministic
* Evidence-based — every finding is grounded in specific rule text and plan content
* Constructive on blocks — always explain what must change, not just what is wrong

---

## Metadata Summary

```yaml
name: rule_enforcement_engine
category: Orchestration & Governance
priority: High
depends_on: [intent-parsing, skill-orchestration]
flags_skills: [decision-confirmation-gate, engineering-decision-logging]
rules_applied: [DT-2, CL-1, MF-3]
documents_needed: [rules_overview]
tags: [rules, enforcement, compliance, governance, validation]
```

**Key relationships:**
- Depends on: intent-parsing (risk context), skill-orchestration (execution plan and loaded skill metadata)
- Flags: decision-confirmation-gate (soft violations), engineering-decision-logging (approved overrides)
- Governed by: DT-2 (overrides require confirmation), CL-1 (compliance is a hard constraint), MF-3 (backward compatibility is a hard constraint)

---

*End of Rule Enforcement Engine Human Spec*
