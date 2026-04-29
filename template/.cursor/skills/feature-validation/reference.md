```yaml
---
name: feature_validation
description: Validates that proposed features are feasible, consistent with existing behavior, aligned with roadmap, and within sprint capacity before development commits.
version: 1.0.0
category: Product
tags: [feature, validation, feasibility, scope, regression-prevention]
priority: High

depends_on: [requirement-interpretation]
flags_skills: [risk-analysis, scope-control, roadmap-awareness]

inputs: [task-breakdowns, existing-system-constraints, business-goals-and-kpis]
outputs: [validation-report, risk-assessment, go-no-go-recommendation]

rules_applied:
  - PS-1   # Requirement Validation — validate feature against project goals before commitment
  - MF-1   # Feature Consistency — new feature must not break existing functionality
  - PS-3   # Scope Control — features that expand scope without approval must be flagged
  - DT-2   # Confirmation Gate — high-risk features require explicit stakeholder approval

documents_needed: [system-architecture, feature-backlog, roadmap, sprint-capacity-data]

execution_context: After requirement-interpretation; before engineering design or sprint commitment. Provides go/no-go recommendation to orchestrator.
---
```

---

# Skill: Feature Validation

---

## Purpose

**What this skill does:**
Evaluates a proposed feature against three gates: (1) consistency with existing system behavior, (2) alignment with roadmap and sprint capacity, and (3) architectural feasibility. Produces a go/no-go recommendation with specific risk flags before any engineering commitment is made.

Catches misalignments, regressions, and scope creep before they consume sprint capacity. A failed feature validation before development starts saves orders of magnitude more effort than discovery during QA or post-release.

Prevents silent regressions from features that interact with existing behavior. Surfaces architectural constraints early, when design changes are cheap.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A task breakdown from `requirement-interpretation` is ready and sprint commitment is being considered
* A proposed feature touches an existing high-traffic or high-risk code path
* A feature request arrives with implied changes to existing user flows or APIs
* A feature is flagged by `requirement-interpretation` for feasibility review
* A stakeholder proposes a feature addition mid-sprint
* A feature appears to extend scope beyond the current roadmap initiative
* A redesign or replacement of an existing feature is proposed

### Do NOT use this skill for:

* Post-development QA validation that the feature meets acceptance criteria — use testing skills
* Formal security auditing — use `security` skill
* Architecture design decisions — use `system-design`
* Prioritization between competing features — use `priority-negotiation`

**Execution Context Details:**
This skill runs after `requirement-interpretation` and before any implementation begins. It feeds its go/no-go recommendation to sprint planning. If HIGH-risk is detected, `DT-2` confirmation gate is activated and stakeholder approval is required before proceeding.

---

## Inputs

**Required inputs:**

* **Task breakdowns with acceptance criteria** — Output from `requirement-interpretation`. Used to evaluate feasibility and consistency for each planned task.
* **Existing system features and constraints** — Documentation of current behavior, API contracts, and known constraints that the new feature must be consistent with.
* **Business goals and KPIs** — Required to validate alignment per PS-1.

**Optional inputs:**

* **Sprint capacity data** — Used to assess whether the feature fits current capacity without scope creep.
* **Historical incident reports** — Inform risk classification for high-traffic or high-risk code paths.

**Documents/Context needed:**

* **System architecture overview** — Needed to evaluate architectural feasibility and detect integration risks.
* **Feature backlog / Roadmap** — Required for PS-1 validation and PS-3 scope gate.

---

## Outputs

**Primary outputs:**

* **Validation report** — Structured assessment of consistency, alignment, and feasibility findings.
* **Risk assessment** — Per-task risk classification (LOW/MEDIUM/HIGH) with specific identified risks.
* **Go/no-go recommendation** — Explicit recommendation with conditions if conditional go (e.g., "go if auth dependency resolved first").

**Output format:**

* Structured report per Final Step template
* Risk table per task
* Conditions for approval if CONDITIONAL GO

---

## Preconditions

**Conditions that must be met before execution:**

* Task breakdown from `requirement-interpretation` is available
* Roadmap is accessible for PS-1 check
* Existing system behavior documentation is available or current behavior can be inferred from context

**Validation checks:**

* [ ] Task breakdown received from `requirement-interpretation`?
* [ ] Each task has at least one acceptance criterion?
* [ ] Roadmap accessible for alignment check?

---

## Step-by-Step Execution Procedure

### Step 1: Validate Against Business Goals and Roadmap

**Questions to answer:**
- Does each task map to a stated business goal or KPI?
- Does the feature belong to a current roadmap initiative?
- Would committing to this feature require deprioritizing a committed item?

**Actions:**
- [ ] Cross-reference feature against roadmap per PS-1
- [ ] Confirm each task maps to a business goal or KPI
- [ ] If misalignment found, flag `roadmap-awareness` and classify as BLOCKED

**Red flags / Warning signs:**
- Feature doesn't map to any roadmap initiative
- Feature would require deferring a committed milestone
- No business metric is improved by the feature (possible misalignment)

**Decision points:**
- If roadmap misalignment: flag `roadmap-awareness`; recommend BLOCKED unless override approved

---

### Step 2: Check Consistency with Existing Functionality

**Questions to answer:**
- Does the feature modify, replace, or interact with any existing user-facing behavior?
- Are there regression risks in shared components or APIs?
- Does the feature require changes to existing interfaces that other features depend on?

**Actions:**
- [ ] Identify all existing behaviors the feature will touch per MF-1
- [ ] Assess regression risk for each touch point
- [ ] Check if interface changes are backward-compatible per MF-3

**Red flags / Warning signs:**
- Feature modifies a shared component used by other features
- Feature deprecates an existing behavior without a migration path
- Feature changes API contracts that consumers depend on

**Decision points:**
- If regression risk detected: add regression testing requirement to task
- If interface breaking change detected: flag `backward-compatibility` (if applicable) and require migration plan

---

### Step 3: Assess Architectural Feasibility

**Questions to answer:**
- Can the feature be built within the current architecture without significant structural changes?
- Are there performance or scalability implications?
- Are there security or data sensitivity implications?

**Actions:**
- [ ] Evaluate architectural fit of each task
- [ ] Classify architectural risk: NONE / MINOR (can proceed) / MAJOR (requires design phase)
- [ ] Identify security or compliance exposure per CL-4

**Red flags / Warning signs:**
- Feature requires introducing a new architectural pattern inconsistent with existing conventions (DA-7)
- Feature adds a high-fan-out integration that could cascade failures
- Feature processes sensitive user data without explicit security review

**Decision points:**
- If MAJOR architectural change required: recommend `system-design` phase before sprint commitment
- If compliance exposure: flag `risk-analysis`

---

### Step 4: Scope Gate

**Questions to answer:**
- Does the feature fit within the committed sprint scope?
- Does it introduce new scope not in the original requirement?
- Is the stakeholder aware of scope expansion, if any?

**Actions:**
- [ ] Compare feature scope against original requirement and sprint plan per PS-3
- [ ] Flag any scope additions beyond the original requirement
- [ ] If scope expansion without approval: flag `scope-control` and require confirmation per DT-2

**Red flags / Warning signs:**
- Feature has grown during decomposition beyond original requirement
- Additional "while we're in there" tasks have been added informally
- Feature scope implies work in subsequent sprints without roadmap support

**Decision points:**
- If scope expansion detected without approval: flag `scope-control`; require DT-2 confirmation gate

---

### Step 5: Risk Classification and Go/No-Go Recommendation

**Actions:**
- [ ] Aggregate findings from Steps 1–4
- [ ] Classify overall feature risk: LOW / MEDIUM / HIGH
- [ ] Produce go/no-go recommendation with conditions
- [ ] Activate DT-2 confirmation gate if HIGH risk

---

### Final Step: Generate Validation Report

**Report/Output structure:**

```markdown
## Feature Validation Report

**Feature:** [Name or ID]
**Date:** [YYYY-MM-DD]
**Status:** ✅ GO / ⚠️ CONDITIONAL GO / ❌ NO-GO

### Roadmap & Business Alignment
- Status: [ALIGNED / MISALIGNED]
- [Finding details]

### Consistency Check (MF-1)
- Status: [PASS / REGRESSION RISK DETECTED]
- [Touch points and risk assessment per task]

### Architectural Feasibility
- Status: [FIT / MINOR CHANGE / MAJOR CHANGE REQUIRED]
- [Specific findings]

### Scope Gate (PS-3)
- Status: [IN-SCOPE / SCOPE EXPANSION DETECTED]
- [Scope delta if detected]

### Risk Assessment
| Task | Risk Level | Risk Factor |
|------|-----------|-------------|
| ...  | LOW/MED/HIGH | ... |

### Skills Flagged for Follow-up
- ⚡ **risk-analysis**: [Reason]
- 🔒 **scope-control**: [Reason]

### Overall Recommendation
**Decision:**
- ✅ GO: All gates passed; proceed to sprint planning
- ⚠️ CONDITIONAL GO: [Specific conditions that must be resolved first]
- ❌ NO-GO: [Blocking findings — what must change before resubmission]

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Validate feature alignment with roadmap and business goals per PS-1
2. Identify regression risks from interaction with existing features per MF-1
3. Assess architectural feasibility and surface structural blockers
4. Enforce scope gate — flag unauthorized scope expansion per PS-3
5. Produce a go/no-go recommendation with explicit conditions; activate DT-2 confirmation gate for HIGH risk

**Quality criteria:**

* Every task in the breakdown is evaluated — no task is assumed safe without inspection
* Risk classification is justified with a specific finding, not a general statement
* Conditional go conditions are specific and actionable, not vague

---

## Constraints (Rules Applied)

* **PS-1: Requirement Validation** — Feature must map to a current roadmap goal before sprint commitment is made.
* **PS-3: Scope Control** — Any scope expansion beyond the original requirement must be flagged; silent acceptance is not permitted.
* **MF-1: Feature Consistency** — Every touch point on existing functionality must be assessed for regression risk.
* **DT-2: Confirmation Gate** — HIGH-risk features require explicit stakeholder approval before proceeding; this skill activates the gate, the orchestrator enforces it.

---

## Tradeoff Handling

### Tradeoff 1: Validation Thoroughness vs Delivery Speed

**Resolution:** LOW-risk + roadmap-aligned → expedited review (Steps 1 and 4 only, document basis); MEDIUM-risk or architecture change → full review; HIGH-risk → full review + DT-2, no exceptions. Log via DT-1.

### Tradeoff 2: Business Priority vs Technical Constraint

**Resolution:** If business-critical feature requires MAJOR architectural change, surface the tradeoff to stakeholder via PS-2: (A) full arch work + delayed delivery; (B) scoped MVP within current arch. Request stakeholder selection; document via DT-1. Default: recommend option B; escalate for override if not acceptable.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: HIGH-Risk Feature Requires Stakeholder Approval

**Trigger:** Feature classified HIGH-risk (irreversible change, compliance exposure, production impact).

**Action:**
- Activate DT-2 confirmation gate
- Surface risk in business terms per PS-2
- Block sprint commitment until explicit approval received

**Escalation format:**
```
⚠️ HIGH-RISK FEATURE — APPROVAL REQUIRED

Feature: [Name]
Risk Factor: [Specific risk — e.g., "Modifies authentication flow for all users"]
Impact: [Business-language description of what happens if this goes wrong]
Options:
  A. [Proceed with mitigations — list specific mitigations]
  B. [Reduce scope to lower-risk MVP]
  C. [Defer to next release with additional design phase]

Recommendation: [Suggested option with reasoning]
Question: Which option is approved to proceed with?
```

---

### Escalation Scenario 2: Regression Risk in Shared Component

**Trigger:** Feature modifies a component shared by other active features or user flows.

**Action:**
- Identify all features that use the shared component
- Require regression test coverage for all affected paths before sprint go-ahead
- Log the dependency per MF-1

---

### Escalation Scenario 3: Scope Expansion Without Approval

**Trigger:** Feature scope has grown beyond the original requirement during decomposition.

**Action:**
- Flag `scope-control`
- Document the scope delta (original vs. current)
- Require DT-2 confirmation for the expanded scope before proceeding

---

### When to halt execution:

* HIGH-risk findings with no available stakeholder to approve the DT-2 gate
* Feature requires replacing core architecture with no time budget for a design phase
* Compliance exposure identified with no `risk-analysis` completion available

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Runs after `requirement-interpretation`, before sprint commitment or engineering design. Its go/no-go recommendation is a prerequisite for sprint planning on any non-trivial feature. HIGH-risk findings activate the DT-2 confirmation gate.

### How This Skill Integrates

1. **Orchestrator** invokes this skill after `requirement-interpretation` produces a task breakdown
2. Skill validates across four gates (alignment, consistency, feasibility, scope)
3. Skill **outputs flags** for `risk-analysis`, `scope-control`, `roadmap-awareness` as applicable
4. **Orchestrator** enforces DT-2 if HIGH-risk returned
5. Sprint planning proceeds only on GO or approved CONDITIONAL GO

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Compliance, irreversibility, or production impact detected | risk-analysis | Formal risk register needed before HIGH-risk feature can be approved |
| Scope expansion beyond original requirement or sprint plan | scope-control | Scope gate enforcement and stakeholder coordination required |
| Feature doesn't map to any roadmap initiative | roadmap-awareness | Alignment check and planning-cycle decision required |

---

## Related Skills

**Skills this skill depends on:**

* **requirement-interpretation** — provides the task breakdown and acceptance criteria that this skill validates

**Skills this skill cooperates with:**

* **roadmap-awareness** — consulted for roadmap alignment in Step 1
* **system-design** — invoked if MAJOR architectural change is required

---

## Governance Hooks

* [ ] Activate DT-2 confirmation gate for every HIGH-risk recommendation
* [ ] Log all tradeoff resolutions via DT-1
* [ ] Never approve a HIGH-risk feature without explicit stakeholder confirmation
* [ ] Document regression risk findings with specific touch points, not generic warnings
* [ ] Surface all risks in business language per PS-2 when escalating

---

## Example Use Cases

### Example 1: Standard Feature — GO

**Scenario:** New user preference setting (email notification toggle) validated before sprint commitment.

**Execution:** Roadmap aligned (Q3 User Settings initiative). No shared component modifications. No compliance risk. Scope matches original story. Single task, LOW risk.

**Result:** ✅ GO — all gates passed.

---

### Example 2: Regression Risk Detected — Conditional GO

**Scenario:** New feature adds a shared utility function to format currency, replacing inline formatting in 12 places across the app.

**Execution:** MF-1 check detects 12 touch points. Regression risk MEDIUM. Condition: regression test suite covering all 12 call sites must be added before sprint merge.

**Result:** ⚠️ CONDITIONAL GO — regression tests required as sprint entry criterion.

---

### Example 3: Scope Expansion — DT-2 Gate Activated

**Scenario:** Payment feature task breakdown grew from 3 tasks to 9 during decomposition, including a new admin reporting module not in the original requirement.

**Execution:** Scope delta detected (6 unplanned tasks). `scope-control` flagged. DT-2 gate activated. Stakeholder informed of scope expansion; explicit approval required.

**Result:** ⚠️ CONDITIONAL GO — pending stakeholder scope approval via DT-2.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Assuming a feature is consistent with existing behavior without checking shared components
✅ **Correct approach:** Explicitly identify all existing behaviors the feature touches in Step 2; no "it should be fine" assumptions.

❌ **Anti-pattern 2:** Classifying HIGH risk as MEDIUM to avoid the DT-2 gate
✅ **Correct approach:** Risk classification must be based on the highest applicable criterion (irreversibility, compliance, production impact). Downgrading to avoid governance is a policy violation.

❌ **Anti-pattern 3:** Producing a vague CONDITIONAL GO without specific conditions
✅ **Correct approach:** Each condition must be specific, measurable, and owned: "Regression test suite for checkout flow must be added and pass CI before sprint merge."

❌ **Anti-pattern 4:** Validating only the happy path without considering edge cases or rollback
✅ **Correct approach:** Validation includes failure modes — what happens if the feature partially fails? Is rollback possible?

❌ **Anti-pattern 5:** Silent scope creep acceptance ("it's just one more task")
✅ **Correct approach:** Any task not in the original requirement must trigger the PS-3 scope gate, regardless of apparent size.

❌ **Anti-pattern 6:** Treating validation as a checkbox exercise rather than a genuine risk assessment
✅ **Correct approach:** Each gate must be evaluated with evidence. A gate passes only when a specific finding supports the pass, not by default.

❌ **Anti-pattern 7:** Proceeding with HIGH-risk features because the stakeholder is "probably okay with it"
✅ **Correct approach:** DT-2 requires explicit, recorded approval. "Probably" is not approval.

❌ **Anti-pattern 8:** Failing to log scope expansion formally, treating it as a technical detail
✅ **Correct approach:** Scope expansion has business implications (timeline, capacity, commitments) and must be escalated to stakeholders via `scope-control`.

---

## Non-Goals

* ❌ **Post-development acceptance testing** — handled by QA and testing skills
* ❌ **Security audit** — handled by `security` skill
* ❌ **Architecture design** — handled by `system-design`; this skill identifies when `system-design` is needed, not what the design should be
* ❌ **Priority ranking among competing features** — handled by `priority-negotiation`

---

## Notes for LLM Implementation

1. **Gate discipline**: Treat each of the four gates (alignment, consistency, feasibility, scope) as independent checks. A failure in any one gate affects the overall recommendation but does not cancel other gates — complete all gates and surface all findings.
2. **Risk justification**: Every risk classification must cite a specific finding. Never write "HIGH risk" without stating what makes it high.
3. **Business language in escalations**: When activating DT-2, frame the risk in terms of business impact, not technical implementation. "All users' checkout flows could be disrupted" not "the shared Cart module has a race condition."
4. **Conditions must be actionable**: A CONDITIONAL GO condition must be completable by the team without further design phases. If it requires a design phase, the recommendation is NO-GO with a resubmission path.
