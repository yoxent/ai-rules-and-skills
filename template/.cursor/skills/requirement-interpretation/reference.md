```yaml
---
name: requirement_interpretation
description: Analyzes and translates product requirements into actionable engineering tasks with clear acceptance criteria and dependency visibility.
version: 1.1.0
category: Product
tags: [requirements, interpretation, acceptance-criteria, decomposition, stakeholder]
priority: High

depends_on: []
flags_skills: [feature-validation, risk-analysis, roadmap-awareness]

inputs: [requirement-documents, user-stories, feature-requests]
outputs: [task-breakdowns, acceptance-criteria, dependency-map, risk-flags]

rules_applied:
  - PS-1   # Requirement Validation — check alignment with project goals before development starts
  - DA-2   # Abstraction by Business Meaning — tasks framed in domain language
  - DT-1   # Explicit Tradeoff Logging — assumptions made during interpretation must be documented
  - GM-2   # Explain Before Acting — risky interpretations surfaced before acting

documents_needed: [requirement-documents, roadmap, architecture-overview]

execution_context: Stage 1 / On new feature request or requirement intake. Runs before any engineering planning or design work begins.
---
```

---

# Skill: Requirement Interpretation

---

## Purpose

**What this skill does:**
Analyzes incoming product requirements, user stories, and feature requests to extract actionable engineering tasks. It resolves ambiguities by surfacing assumptions, maps dependencies, and produces clear acceptance criteria that engineering can act on without further clarification cycles.

Prevents the most expensive class of defect — building the wrong thing. Misinterpreted requirements discovered late in a sprint waste engineering capacity and erode stakeholder trust. Early disambiguation reduces rework and accelerates time-to-value.

Converts vague or incomplete product intent into deterministic tasks with measurable acceptance criteria, reducing in-sprint ambiguity and re-planning overhead.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new product requirement document, PRD, or feature brief is received
* User stories are submitted without acceptance criteria
* A stakeholder describes a feature verbally or through a ticket without engineering detail
* Conflicting requirements are identified between two business stakeholders
* Requirements reference existing system behavior without specifying whether to extend or replace it
* A feature request arrives with implicit assumptions about architecture not yet validated
* Pre-sprint planning requires decomposition of epics into implementable stories

### Do NOT use this skill for:

* Technical implementation decisions — this skill produces tasks, not code
* Architectural evaluation of whether the requirement is feasible — use `system-design` for that
* Prioritization of requirements against roadmap capacity — use `roadmap-awareness` or `priority-negotiation`
* Validating that a feature meets its acceptance criteria post-development — use `feature-validation`

**Execution Context Details:**
This skill runs at the start of any feature intake cycle, before sprint planning, engineering design, or implementation begins. It is typically the first skill invoked when a new requirement arrives. `feature-validation` may be flagged after task breakdown if feasibility or scope concerns emerge.

---

## Inputs

**Required inputs:**

* **Requirement documents / PRDs** — Product requirement documents, feature briefs, or business case documents. May be formal or informal. Used to extract the primary objective and functional scope.
* **User stories** — Structured or unstructured stories describing user goals. Used to derive acceptance criteria and edge cases.
* **Feature requests with business context** — Stakeholder-provided descriptions including the business motivation. The "why" context is essential for correct abstraction.

**Optional inputs:**

* **Stakeholder clarification notes** — Notes from interviews or Slack threads clarifying intent. Used to resolve ambiguities before assuming.
* **Existing system documentation** — Architecture diagrams or API contracts that inform whether the requirement extends or replaces current behavior.
* **Sprint capacity / velocity data** — Used to calibrate decomposition granularity to sprint-deliverable chunks.

**Documents/Context needed:**

* **Product roadmap** — Required to validate that the requirement aligns with current strategic priorities before decomposing it.
* **Architecture overview** — Required to identify technical dependencies or constraints that affect how tasks are structured.

---

## Outputs

**Primary outputs:**

* **Task breakdowns with acceptance criteria** — Each user story or requirement decomposed into independently deliverable engineering tasks, each with one or more testable acceptance criteria.
* **Dependency and risk identification** — A map of inter-task dependencies and any risks arising from ambiguous requirements, integration points, or unclear business rules.
* **Prioritization recommendations** — A suggested ordering for tasks based on dependencies, risk, and business value, for use in sprint planning.
* **Assumption log** — All assumptions made during interpretation documented for stakeholder validation, per DT-1.

**Output format:**

* Task list with structured acceptance criteria (Given/When/Then or equivalent)
* Dependency table or simple ordered list
* Assumption log entries for DT-1 compliance

---

## Preconditions

**Conditions that must be met before execution:**

* A requirement or feature description has been received in at least one form (written or verbal summary)
* The primary business objective is identifiable (may require one clarification question if not explicit)
* The product roadmap is accessible to validate alignment

**Validation checks:**

* [ ] Is there at least one identifiable primary objective?
* [ ] Does the requirement reference a domain concept that can be mapped to system behavior?
* [ ] Is the roadmap available to validate scope alignment per PS-1?

---

## Step-by-Step Execution Procedure

### Step 1: Extract Primary Objective

**Questions to answer:**
- What is the single testable outcome this requirement is asking for?
- Is the objective stated in business terms or technical terms?
- Does the objective have a measurable success definition?

**Actions:**
- [ ] Read the requirement and write a one-sentence primary objective statement
- [ ] If the objective cannot be stated in one sentence, flag the requirement as ambiguous and request clarification per GM-2
- [ ] Label the objective in domain language (not implementation terms) per DA-2

**Red flags / Warning signs:**
- Objective contains multiple distinct goals — decompose before proceeding
- Objective is stated as a technical action rather than a business outcome (e.g., "add an API endpoint" vs. "allow users to retrieve their order history")
- Objective contains conditional language that implies multiple interpretations

**Decision points:**
- If objective is ambiguous, ask at most one clarifying question before proceeding with documented assumptions (DT-1)
- If requirement references an undefined domain concept, escalate to stakeholder rather than assuming meaning

---

### Step 2: Validate Against Roadmap and Project Goals

**Questions to answer:**
- Does this requirement belong to a current roadmap initiative?
- Does it conflict with any committed milestones?

**Actions:**
- [ ] Cross-reference the requirement against the product roadmap per PS-1
- [ ] If misalignment is found, document the gap and flag for stakeholder review before proceeding

**Red flags / Warning signs:**
- Requirement references a product area not in the current roadmap
- Requirement would require deferring a committed milestone

**Decision points:**
- If misalignment is confirmed, block decomposition and escalate to `roadmap-awareness` or `priority-negotiation`

---

### Step 3: Decompose into Engineering Tasks

**Questions to answer:**
- What is the smallest independently deliverable unit of work?
- Are there tasks that can be parallelized vs. serialized?
- Does each task have a clear definition of done?

**Actions:**
- [ ] Break the requirement into tasks, each deliverable within a single sprint by one developer
- [ ] Assign a preliminary acceptance criterion (Given/When/Then) to each task
- [ ] Identify any tasks that depend on upstream work not yet started

**Red flags / Warning signs:**
- Task has no observable output (cannot be verified by a test or review)
- Task cannot be completed without a dependency that isn't tracked
- Acceptance criterion is subjective ("should feel fast") — quantify or escalate

**Decision points:**
- If a task's acceptance criterion cannot be made testable, flag as ambiguous and log assumption
- If decomposition reveals architectural complexity, flag `feature-validation`

---

### Step 4: Identify Dependencies and Risks

**Questions to answer:**
- Which tasks must complete before others can start?
- Are there integration points with other systems or teams?
- Are there assumptions embedded in the requirement that carry risk?

**Actions:**
- [ ] Map inter-task dependencies
- [ ] Identify external dependencies (APIs, third-party services, other teams)
- [ ] List assumptions made during interpretation and log them per DT-1

**Red flags / Warning signs:**
- Dependency on an external team or system with unknown timeline
- Requirement assumes a capability that hasn't been built yet
- Compliance or data privacy implications that require legal review

**Decision points:**
- If compliance risk detected, flag `risk-analysis`
- If architectural dependency is unresolved, escalate via GM-2 before committing to tasks

---

### Final Step: Generate Interpretation Report

**Report/Output structure:**

```markdown
## Requirement Interpretation Report

**Requirement:** [Name or ID]
**Date:** [YYYY-MM-DD]
**Status:** ✅ READY / ⚠️ NEEDS CLARIFICATION / ❌ BLOCKED

### Primary Objective
[One-sentence statement in business/domain language]

### Task Breakdown
| # | Task | Acceptance Criteria | Dependencies | Risk |
|---|------|---------------------|--------------|------|
| 1 | ... | Given/When/Then | ... | Low/Med/High |

### Assumptions Logged (DT-1)
- [Assumption 1: what was assumed, what would change if assumption is wrong]

### Dependencies Map
- [Task N] → requires → [Task M / External system / Other team]

### Skills Flagged for Follow-up
- ⚡ **feature-validation**: [Reason with specific context]
- 🛡️ **risk-analysis**: [Reason with specific context]
- 🗺️ **roadmap-awareness**: [Reason with specific context]

### Overall Assessment
**Decision:**
- ✅ READY: All tasks have testable acceptance criteria, no unresolved blockers
- ⚠️ NEEDS CLARIFICATION: [Specific ambiguities outstanding]
- ❌ BLOCKED: [Dependency or alignment issue preventing decomposition]

### Required Actions
- [ ] [Action 1 if status is not READY]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Extract the primary objective in one testable sentence aligned with domain language
2. Validate the requirement against the product roadmap per PS-1
3. Decompose into independently deliverable tasks with testable acceptance criteria
4. Map all inter-task and external dependencies
5. Log all assumptions and escalate risks before acting on them

**Quality criteria:**

* Every task has at least one verifiable acceptance criterion
* No assumption is acted upon without being logged
* Decomposition granularity fits a single sprint
* All escalations use GM-2 format with maximum one clarifying question per turn

---

## Constraints (Rules Applied)

* **PS-1: Requirement Validation** — Every requirement must be checked against the roadmap before decomposition begins; misaligned requirements are blocked, not decomposed.
* **DA-2: Abstraction by Business Meaning** — Tasks and acceptance criteria use domain/business language, not technical terms (e.g., "User can view order history" not "Add GET /orders endpoint").
* **DT-1: Explicit Tradeoff Logging** — Every assumption made to resolve ambiguity is logged; never silently resolve ambiguity.
* **GM-2: Explain Before Acting** — Risky interpretations must be surfaced to the stakeholder before acting; one clarifying question max per turn.

---

## Tradeoff Handling

**How this skill behaves when conflicts arise:**

### Tradeoff 1: Depth of Analysis vs Delivery Speed

**Resolution:** Default to accuracy for HIGH-risk requirements; speed for LOW-risk. If speed: proceed with documented assumptions (DT-1), flag outstanding ambiguities in output for async resolution. If accuracy: request clarification before decomposition and pause execution. Log decision via DT-1.

### Tradeoff 2: Assumption vs Escalation

**Resolution:** If assumption affects acceptance criteria → escalate via GM-2 with one specific question, block decomposition until resolved. If assumption affects implementation only → log per DT-1 and proceed.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Irresolvable Ambiguity

**Trigger:** Primary objective cannot be stated in one sentence even after one clarification attempt.

**Action:**
- Surface the two or more candidate interpretations to the stakeholder
- Request explicit selection between interpretations
- Block decomposition until resolved

**Escalation format:**
```
⚠️ CLARIFICATION NEEDED

Issue: Requirement has two valid interpretations that lead to different deliverables.
Context: [Requirement name/ID], received [date]
Options:
  A. [Interpretation A with implied acceptance criteria]
  B. [Interpretation B with implied acceptance criteria]

Recommendation: [Interpretation most consistent with roadmap, with reasoning]

Question: Which interpretation should be used as the primary objective?
```

---

### Escalation Scenario 2: Roadmap Misalignment

**Trigger:** Requirement does not align with any current roadmap initiative.

**Action:**
- Document the misalignment specifically (which roadmap item is missing or conflicted)
- Flag for `roadmap-awareness` or `priority-negotiation` as appropriate
- Do not decompose until roadmap alignment is confirmed

---

### Escalation Scenario 3: Compliance or Privacy Risk Detected

**Trigger:** Requirement touches data handling, user consent, authentication, or regulated domains.

**Action:**
- Flag `risk-analysis` immediately
- Document the compliance dimension identified
- Proceed with decomposition of non-compliance-sensitive tasks only; hold compliance-related tasks pending risk review

---

### When to halt execution:

* Primary objective is completely undefined and stakeholder is unavailable for clarification
* Requirement explicitly contradicts a committed milestone with no indication of priority override
* Compliance implications are identified but `risk-analysis` has not completed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

This skill is the entry point for all feature work. It runs before `feature-validation`, `system-design`, or any implementation skill. It produces the structured task breakdown that feeds sprint planning.

### How This Skill Integrates

1. **Orchestrator** invokes this skill on receipt of a new requirement
2. Skill extracts objective, validates against roadmap, decomposes into tasks
3. Skill **outputs flags** for `feature-validation` and/or `risk-analysis` if risks are detected
4. **Orchestrator** decides which downstream skills to invoke based on flags
5. Sprint planning or `roadmap-awareness` consumes the task breakdown output

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Requirement conflicts with existing behavior or architecture | feature-validation | Needs feasibility and consistency check before committing to tasks |
| Compliance, data privacy, or irreversible change detected | risk-analysis | Formal risk register and mitigation strategy required before decomposition finalizes |
| Scope appears to exceed current roadmap | roadmap-awareness | Roadmap alignment check needed before committing sprint capacity |

---

## Related Skills

**Skills this skill depends on:** None — this is an entry-point skill.

**Skills this skill cooperates with:**

* **roadmap-awareness** — provides the roadmap context required for PS-1 validation in Step 2
* **feature-validation** — consumes the task breakdown produced by this skill to validate feasibility

**Skills this skill may invoke/flag:**

* **feature-validation** — flagged when feasibility or consistency concerns are detected in decomposition
* **risk-analysis** — flagged when compliance or data sensitivity is detected in the requirement

---

## Governance Hooks

* [ ] Log all assumptions via DT-1 in every interpretation report
* [ ] Explain risks before acting on ambiguous requirements (GM-2)
* [ ] Respect confirmation gates — do not decompose roadmap-misaligned requirements without approval
* [ ] Do not proceed past Step 2 without roadmap validation (PS-1)
* [ ] Document all escalation decisions with reason

**Audit trail requirements:**

* All assumptions logged with: what was assumed, what changes if wrong, risk level
* Roadmap validation outcome documented in report
* All escalations to stakeholder recorded with question asked and response received

---

## Example Use Cases

### Example 1: Clear Requirement with Implicit Dependencies

**Scenario:** Product manager submits "As a user, I want to see my order history so I can track past purchases."

**Inputs provided:**
- User story as written above
- Roadmap: "Q3 — Customer Account Enhancements"

**Execution steps:**
1. Primary objective: "Users can view a paginated list of their past orders in their account." Roadmap aligned: Q3 Account Enhancements ✅
2. Decompose: (a) Backend: Order history API endpoint; (b) Frontend: Order history page component; (c) Authentication: Ensure orders are scoped to authenticated user only
3. Acceptance criteria for (c): "Given a user is authenticated, when they navigate to /account/orders, then they see only their own orders, not other users' orders."
4. Dependencies: (a) must complete before (b); auth system must be confirmed to provide user context

**Result:** ✅ READY — 3 tasks with acceptance criteria, 1 dependency chain, no compliance risk

**Skills flagged:** None

---

### Example 2: Ambiguous Requirement with Compliance Risk

**Scenario:** "We need to add Facebook login to improve onboarding conversion."

**Inputs provided:**
- Single-sentence stakeholder request
- GDPR is in scope for the product

**Execution steps:**
1. Primary objective: Two interpretations — "Users can authenticate using Facebook OAuth" vs. "Users can import Facebook profile data to pre-fill onboarding." Log both; ask stakeholder to select.
2. Compliance detected: Facebook login involves third-party data sharing → flag `risk-analysis` immediately
3. Decomposition held on compliance-dependent tasks pending risk review

**Result:** ⚠️ NEEDS CLARIFICATION — interpretation ambiguity + compliance flag

**Skills flagged:** risk-analysis (third-party data sharing / GDPR), feature-validation (integration scope undefined)

---

### Example 3: Roadmap-Misaligned Requirement

**Scenario:** "Can we add a dark mode toggle? Users are asking for it."

**Inputs provided:**
- Verbal stakeholder request
- Current roadmap: Q3 focused on backend reliability; no UI initiatives

**Execution steps:**
1. Objective is clear: "Users can toggle dark/light display mode."
2. Roadmap validation: No current initiative covers UI theming. Misalignment detected.
3. Block decomposition; escalate to `roadmap-awareness` with the gap documented.

**Result:** ❌ BLOCKED — roadmap misalignment; flagged for planning cycle

**Skills flagged:** roadmap-awareness

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Decomposing a requirement before validating roadmap alignment
✅ **Correct approach:** Always run Step 2 (roadmap validation) before Step 3 (decomposition). A technically correct breakdown of a misaligned feature wastes sprint capacity.

❌ **Anti-pattern 2:** Writing acceptance criteria in technical terms ("API returns 200 status code")
✅ **Correct approach:** Write acceptance criteria in observable business behavior ("User sees their order history without error"). Technical assertions belong in test code, not in requirements.

❌ **Anti-pattern 3:** Silently resolving an ambiguous requirement without logging the assumption
✅ **Correct approach:** Every assumption must appear in the Assumption Log per DT-1, with a risk rating. Silent resolution breaks traceability.

❌ **Anti-pattern 4:** Asking multiple clarifying questions at once
✅ **Correct approach:** One question per turn (GM-2). Prioritize the question whose answer unblocks the most work. Batch other questions only if the stakeholder explicitly invites it.

❌ **Anti-pattern 5:** Decomposing tasks that are too large to verify in one sprint
✅ **Correct approach:** Each task must be completable and verifiable within a single sprint by one developer. If a task can't be, decompose further.

❌ **Anti-pattern 6:** Accepting a requirement that conflicts with a committed milestone without flagging it
✅ **Correct approach:** Any requirement that would require deferring a committed deliverable must be escalated to `priority-negotiation` before sprint planning proceeds.

❌ **Anti-pattern 7:** Treating a non-functional requirement (performance, security) as implicit
✅ **Correct approach:** Non-functional requirements must be made explicit and given measurable acceptance criteria (e.g., "page load under 2 seconds on 3G") or flagged for `risk-analysis`.

❌ **Anti-pattern 8:** Starting implementation guidance within this skill
✅ **Correct approach:** This skill produces tasks and acceptance criteria, not implementation instructions. Any implementation guidance belongs in a downstream engineering skill.

---

## Non-Goals

* ❌ **Technical feasibility assessment** — handled by `feature-validation` and `system-design`
* ❌ **Sprint capacity planning** — handled by `time-estimation` and `scope-control`
* ❌ **Prioritization decisions** — handled by `priority-negotiation` and `roadmap-awareness`
* ❌ **Post-development validation that acceptance criteria are met** — handled by `feature-validation` and QA skills
* ❌ **Writing implementation code or design** — never in scope for this skill

**Boundary clarifications:**
* This skill ends when the task breakdown with acceptance criteria is produced. It does not decide whether to build the feature.
* Escalation to `risk-analysis` is a flag, not a decision — the orchestrator decides whether to block on it.

---

## Notes for LLM Implementation

1. **One objective sentence first**: Always start by writing the primary objective before any decomposition. If you can't write it, stop and escalate.
2. **Domain language only**: Never use class names, database terms, or HTTP verbs in acceptance criteria. Write what a user or business observer would see.
3. **Assume the minimum**: When making assumptions to resolve ambiguity, choose the interpretation that requires the least irreversible work. Log it.
4. **One question max per turn**: If clarification is needed, ask the single most blocking question. Do not front-load multiple questions.
5. **Compliance is a hard stop**: Any requirement touching user data, third-party services, or authentication must flag `risk-analysis` before tasks in those areas are finalized.
6. Use the structured report template from the Final Step; tables for task breakdowns, checkboxes for actions, ⚠️/❌ for flags; keep acceptance criteria in Given/When/Then format.
7. Be methodical and domain-fluent — speak in business terms; be explicit about uncertainty; one specific escalation question, not a list.
