```yaml
---
name: time_estimation
description: Produces accurate, risk-adjusted time estimates for features and sprints based on task complexity, team velocity, and known dependencies and risks.
version: 1.0.0
category: Product
tags: [estimation, planning, velocity, scheduling, risk-adjusted]
priority: Medium

depends_on: []
flags_skills: [risk-analysis, stakeholder-communication]

inputs: [feature-specs, complexity-assessment, velocity-data, dependencies, risk-factors]
outputs: [time-estimates, confidence-ranges, sprint-planning-recommendations]

rules_applied:
  - PS-2
  - DT-1
  - PS-4

documents_needed: [feature-specs, historical-velocity, dependency-map, risk-register]

execution_context: Triggered at sprint planning, release scheduling, or when a feature estimate is needed for stakeholder commitment. Runs after requirement-interpretation produces a task breakdown.
---
```

---

# Skill: Time Estimation

---

## Purpose

**What this skill does:**
Produces time estimates for feature development, sprint planning, and release scheduling. Estimates are risk-adjusted, assumption-explicit, and expressed as ranges rather than point estimates. Covers development, testing, integration, and deployment time — not development only.

Point estimates without confidence ranges create false precision that leads to missed commitments. Explicit assumptions and risk adjustments give stakeholders an accurate picture of delivery probability, enabling better business decisions about scope, timelines, and resource allocation.

Forces systematic consideration of non-development time (testing, code review, integration, deployment) that is routinely underestimated. Surfaces dependency risks before they become sprint blockers.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Sprint planning requires story point or hour estimates for backlog items
* A stakeholder requests a delivery date commitment for a feature
* A release schedule is being constructed and needs realistic milestone dates
* An existing estimate needs to be revised due to scope change or new information
* `scope-control` approves a new addition and requires a revised capacity assessment
* High-uncertainty features need probabilistic estimation (best/likely/worst case)

### Do NOT use this skill for:

* Roadmap-level strategic planning horizons (quarters, years) — too granular for that scope
* Resource hiring and team capacity planning — organizational concern, not sprint estimation
* Cost estimation in financial terms — convert from time estimates separately if needed

---

## Inputs

**Required inputs:**

* **Task breakdown** — Output from `requirement-interpretation`; individual tasks with acceptance criteria.
* **Team velocity** — Historical delivery rate in story points or hours per sprint.

**Optional inputs:**

* **Dependency map** — Inter-task and external dependencies that may block or delay work.
* **Risk register** — Known risks from `risk-analysis` that have time implications.
* **Historical estimates vs actuals** — Used to calibrate accuracy of future estimates.

---

## Outputs

**Primary outputs:**

* **Estimates with confidence ranges** — Best / likely / worst case per task and rolled up to feature level.
* **Assumption log** — All assumptions made during estimation, with sensitivity ("if this assumption is wrong, add N days").
* **Sprint planning recommendation** — Which tasks fit in the current sprint given velocity; which must defer.

---

## Preconditions

**Conditions that must be met before execution:**

* Task breakdown is available — cannot estimate undefined work
* Team velocity baseline exists (at least 2–3 sprints of historical data, or an initial calibration estimate)
* The scope being estimated is stable — estimates on shifting scope are unreliable and should be flagged

---

## Step-by-Step Execution Procedure

### Step 1: Scope Completeness Check

**Actions:**
- [ ] Confirm the task breakdown covers all work: development, testing, code review, integration, deployment, documentation if required
- [ ] Flag any missing coverage — a breakdown that omits testing is incomplete and will underestimate
- [ ] Confirm scope is stable before estimating — flag if requirements are still in flux

**Red flags:**
- Task breakdown covers only development tasks — testing and deployment commonly omitted
- Scope still being discussed while estimation is requested — estimates on shifting scope are waste

---

### Step 2: Estimate Each Task

**Actions:**
- [ ] Assign best / likely / worst case for each task
- [ ] Best case: everything goes right, no blockers
- [ ] Likely case: normal friction — one minor blocker, typical review cycle
- [ ] Worst case: dependency delayed, unexpected complexity, rework required
- [ ] Document the assumption driving each estimate

**Red flags:**
- Best and likely case are the same — indicates optimism bias; challenge the estimate
- Worst case is only slightly above likely — underestimating tail risk
- Estimate provided as a single point without a range — reject and require a range

---

### Step 3: Apply Dependency and Risk Adjustments

**Actions:**
- [ ] For each external dependency: add a buffer to the worst case equal to the dependency's uncertainty window
- [ ] For each risk factor from the risk register: assess whether it has time implications; if so, add to worst case
- [ ] If a dependency has no known timeline: flag `risk-analysis` for assessment before committing

**Red flags:**
- External dependency with unknown timeline included in a committed estimate — this will slip
- Risk factors present in risk register but not reflected in estimates

---

### Step 4: Roll Up to Feature and Sprint Level

**Actions:**
- [ ] Sum task estimates to feature-level range
- [ ] Compare feature-level likely estimate to available sprint velocity
- [ ] Identify which tasks fit in current sprint and which must defer
- [ ] Express confidence: HIGH (well-understood work, stable scope), MEDIUM (some unknowns), LOW (high uncertainty, novel work)

---

### Step 5: Document Assumptions and Communicate Uncertainty

**Actions:**
- [ ] List all assumptions underlying the estimate per PS-4
- [ ] State uncertainty explicitly — never present a range as a commitment per PS-2
- [ ] If estimate has been compressed for business reasons: log the accepted risk per DT-1
- [ ] If significant uncertainty remains: flag `stakeholder-communication` to set expectations

---

### Final Step: Generate Estimation Report

```markdown
## Time Estimation Report

**Feature:** [Name]
**Date:** [YYYY-MM-DD]
**Confidence:** HIGH / MEDIUM / LOW

### Task Estimates
| Task | Best | Likely | Worst | Key Assumption |
|------|------|--------|-------|----------------|
| ...  | Nd   | Nd     | Nd    | ...            |

### Feature Total
- Best case: [N days/points]
- Likely case: [N days/points]
- Worst case: [N days/points]

### Sprint Fit
- Sprint capacity: [N points]
- Tasks in scope: [list]
- Tasks deferred: [list]

### Assumptions Log (PS-4)
- [Assumption]: [Sensitivity — "if wrong, add N days"]

### Compressed Estimate Log (DT-1)
- [If estimate was compressed]: [Original estimate, reason for compression, risk accepted]

### Skills Flagged
- [risk-analysis / stakeholder-communication if triggered]
```

---

## Core Responsibilities

1. Cover all work in estimates: development + testing + review + integration + deployment
2. Always produce ranges (best/likely/worst) — never point estimates
3. Make every assumption explicit with its sensitivity
4. Apply dependency and risk adjustments to worst case
5. Log compressed estimates and accepted risk per DT-1

---

## Constraints (Rules Applied)

* **PS-2:** Estimation uncertainty communicated as ranges and assumptions — point estimates presented as commitments are a violation.
* **DT-1:** When estimates are compressed for business reasons, the accepted risk is logged.
* **PS-4:** All estimation assumptions documented with sensitivity analysis.

---

## Tradeoff Handling

### Tradeoff 1: Accuracy vs Speed of Estimation

**Conflict:** Detailed estimation is more accurate but time-consuming.

**Resolution:** For small, low-risk features, a lightweight estimate is acceptable (likely + 20% buffer). For large or medium/high-risk features, a full best/likely/worst breakdown is required. Never skip assumption documentation regardless of estimation depth.

### Tradeoff 2: Conservative vs Optimistic Estimates

**Conflict:** Conservative estimates reduce risk but may lose business opportunities.

**Resolution:** Default to the likely case for planning; surface the worst case for risk communication. Never present best case as the planning estimate — optimism bias is the most common estimation failure. If the business requests an optimistic estimate, log it per DT-1 as accepted risk.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Unresolved External Dependency

**Trigger:** A task depends on an external team or system with no confirmed timeline.

**Action:**
- Flag `risk-analysis` for dependency risk assessment
- Do not commit to a timeline that includes this dependency until it is resolved
- Present estimate as CONDITIONAL on dependency resolution

### Escalation Scenario 2: Estimate Compressed Beyond Likely Case

**Trigger:** Business requests a delivery date that requires the best-case estimate to be treated as the plan.

**Action:**
- Log the compression per DT-1: original estimate, compressed target, risk accepted
- Flag `stakeholder-communication` to set expectations on probability of hitting the compressed date
- Do not silently accept the compressed estimate as the new baseline

### Escalation Scenario 3: Scope Still in Flux During Estimation

**Trigger:** Requirements are still being defined while estimates are requested.

**Action:**
- Produce a rough order-of-magnitude estimate only (not a commitment)
- Flag that the estimate will need revision once scope is stable
- Do not use flux-scope estimates for sprint commitments

---

### When to halt execution:

* No task breakdown available — cannot estimate undefined work
* Scope is actively changing and no stable baseline exists for estimation
* Team velocity data is unavailable and no calibration baseline can be established

---

## Skill Integration & Orchestration

Runs after `requirement-interpretation` produces a task breakdown. Feeds sprint planning and `scope-control` (capacity assessment for new additions). Flags `risk-analysis` on unresolved dependencies and `stakeholder-communication` on compressed or high-uncertainty estimates.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| External dependency with unknown timeline | risk-analysis | Dependency risk needs formal assessment before commit |
| Compressed or high-uncertainty estimate | stakeholder-communication | Stakeholder expectations need to be calibrated |

---

## Related Skills

* **Depends on output of:** `requirement-interpretation` (task breakdown)
* **Feeds:** `scope-control` (capacity data), sprint planning
* **Flags:** `risk-analysis`, `stakeholder-communication`

---

## Governance Hooks

* [ ] All estimates expressed as ranges — no point estimates presented as commitments
* [ ] All assumptions documented per PS-4
* [ ] All compressed estimates logged per DT-1
* [ ] Estimates cover full delivery scope: dev + test + review + deploy

---

## Example Use Cases

### Example 1: Feature Estimation for Sprint Planning

**Scenario:** Estimating a user profile edit feature: 3 tasks (frontend form, API endpoint, validation logic).

**Estimates:** Frontend form: 2/3/5d. API endpoint: 1/2/3d. Validation: 1/1.5/3d. Feature total: 4/6.5/11d. Sprint capacity: 8d. Likely case fits; worst case doesn't. Recommendation: commit to likely case; flag worst-case risk to PM.

**Confidence:** MEDIUM — new design pattern for forms; no external dependencies.

### Example 2: Compressed Estimate Request

**Scenario:** Stakeholder requests feature delivery in 5 days; likely estimate is 8 days, best case is 6.

**Action:** Log compression per DT-1. Flag `stakeholder-communication` — stakeholder must understand 5-day delivery requires best-case conditions and carries HIGH miss risk. Do not silently accept 5 days as the plan.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Estimating development time only, excluding testing and deployment
✅ Full delivery scope always: development + testing + code review + integration + deployment.

❌ **Anti-pattern 2:** Providing a point estimate under stakeholder pressure
✅ Always a range. If pressed for a single number, give the likely case and state it explicitly as likely, not guaranteed.

❌ **Anti-pattern 3:** Treating best case as the plan
✅ Best case is the floor, not the target. Likely case is the plan. Worst case informs the risk buffer.

❌ **Anti-pattern 4:** Committing to a timeline that includes an unresolved external dependency
✅ Unresolved dependencies make the estimate CONDITIONAL. Flag the dependency and present accordingly.

❌ **Anti-pattern 5:** Silently accepting a compressed estimate without logging the risk
✅ Every compression is logged per DT-1. The accepted risk must be visible and attributed.

❌ **Anti-pattern 6:** Estimating while scope is still in flux
✅ Flux-scope estimates are rough order-of-magnitude only. Sprint commitments require stable scope.

---

## Non-Goals

* ❌ Strategic planning horizons (quarters, years) — too granular
* ❌ Financial cost estimation — convert from time estimates separately
* ❌ Resource planning and hiring — organizational scope

---

## Notes for LLM Implementation

1. **Range first:** The first output of every estimation task is a range, not a number. If you find yourself producing a single number, stop and produce best/likely/worst.
2. **Assumption sensitivity:** Every assumption gets a sensitivity: "If this assumption is wrong, add N days." This is what makes the assumption log actionable.
3. **Full scope check:** Before estimating, audit the task breakdown for testing, review, and deployment tasks. If missing, flag before estimating.
4. **Compression logging is mandatory:** When a business deadline compresses an estimate, the DT-1 log is not optional. It is the paper trail that protects the team when the compressed date is missed.

---
