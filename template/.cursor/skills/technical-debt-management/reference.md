```yaml
---
name: technical-debt-management
description: Identifies, quantifies, and manages technical debt to ensure it is visible, prioritized, and addressed systematically before it causes delivery paralysis or systemic failures.
version: 1.3.0
category: Architecture
tags: [technical-debt, refactoring, maintainability, quality, prioritization]
priority: High
depends_on: []
flags_skills: [refactoring, system-design, performance-optimization, modularity]
inputs: [codebase-analysis, complexity-metrics, developer-pain-points, feature-roadmap, delivery-timelines]
outputs: [debt-register, prioritized-refactoring-plan, risk-mitigation-recommendations, effort-estimates, debt-register-file (persistent mode only)]
rules_applied:
  - MF-2   # Technical Debt Tracking
  - DA-1   # SOLID & Clean Code First
  - PC-3   # Business Priority Override
  - PS-3   # Scope Control
  - DT-1   # Explicit Tradeoff Logging
  - GM-4   # Behavioral Transparency
documents_needed: [codebase-analysis, feature-roadmap, incident-history]
execution_context: Runs when shortcuts are introduced, when debt accumulation is flagged by other skills, or proactively before a major feature cycle to assess structural risks. Also invoked explicitly via "check debt-register" to review whether active or waived items have been resolved in recent commits.
---
```

---

# Skill: Technical Debt Management

---

## Purpose

**What this skill does:**
Technical Debt Management identifies, quantifies, and governs technical debt accumulation and repayment. It maintains a debt register where every deliberate shortcut is logged, prioritizes debt by business impact, and produces scoped remediation plans that prevent debt from accumulating invisibly until it causes delivery paralysis.

Invisible technical debt is one of the most common causes of engineering velocity collapse. Teams take shortcuts under time pressure and never return to them — making debt visible, framing it in business terms, and managing it as a first-class concern prevents this failure mode.

A maintained debt register enables informed architectural decisions. Engineers can make deliberate tradeoffs when time pressure is real — knowing the cost and having a plan — rather than accumulating implicit technical risk.

---

## When to Use This Skill

### Triggers:

* A shortcut or temporary solution is introduced under time pressure
* Other skills (Modularity, Code Maintenance) flag debt accumulation
* A sprint retrospective or incident post-mortem reveals structural debt causing delivery problems
* Proactively before a major feature cycle to assess structural risks
* A module's defect rate or change failure rate is disproportionately high
* The team is debating unscoped "refactor everything" work during a feature sprint
* User prompts "check debt-register" to review whether active or waived items were resolved in recent commits

### Do NOT use this skill for:

* Executing refactoring work — Refactoring handles execution
* Deciding individual code quality standards — Clean Code & SOLID
* Making performance improvements — Performance Optimization

**Execution Context:**
Runs after shortcuts are introduced or when other skills surface debt signals. Typically precedes Refactoring and System Design when CRITICAL debt must be addressed. Feeds prioritized debt items into sprint planning.

---

## Inputs

**Required:**

* **Codebase analysis and complexity metrics** — Cyclomatic complexity, module coupling, test coverage gaps, code churn. Quantifies where debt lives and how severe it is.
* **Developer-reported pain points** — Where engineers find the codebase hardest to work with. Often the most accurate signal of high-impact debt.
* **Feature roadmap and delivery timelines** — Which modules upcoming features will touch. Debt in those modules is highest priority.

**Optional:**

* **Incident history** — Modules involved in the most production incidents often correlate with highest debt.
* **Code churn rate by module** — High complexity + high churn = highest-risk debt items.

---

## Outputs

**Primary:**

* **Debt register** — Structured log of all debt items: description, location, severity, business impact, remediation effort, logged-by/date.
* **Prioritized refactoring plan** — Debt ranked by (business_impact × incident_probability) / remediation_effort.
* **Risk mitigation recommendations** — For deferred items: containment strategies (additional tests, isolation patterns, monitoring).
* **Effort estimates** — T-shirt sizing (S/M/L/XL) per item for sprint planning.

**Output format:**

* Structured markdown report with debt register table, quick wins list, strategic refactors list, and deferred debt with containment.
* All debt items include a business impact statement — technical metrics alone are insufficient for prioritization.
* In persistent mode, the register is written to `.ai/<project-name>/debt-register.md` in the format below. Active items occupy the top section; waived items occupy a concise table at the bottom.

**Register file format:**

```markdown
## Active
| ID | Location | Violation | Date | Priority |
|---|---|---|---|---|
| TD-001 | [Module] | [Description] | [YYYY-MM-DD] | [CRITICAL/HIGH/MED/LOW] |

## Waived
| ID | Location | Violation | Date | Reason |
|---|---|---|---|---|
| TD-002 | [Module] | [Description] | [YYYY-MM-DD] | [Why waived] |
```

---

## Preconditions

* Codebase metrics or developer knowledge input is available
* Feature roadmap is available to prioritize debt by upcoming feature work
* Agreement that debt tracking is a first-class activity

**Validation checks:**

* [ ] Complexity metrics or equivalent developer input is accessible
* [ ] Feature roadmap scope for next cycle is known
* [ ] Stakeholder is available for debt-vs-delivery escalations (PC-3)
* [ ] Persistent or session-only mode confirmed
* [ ] If persistent: project name confirmed; path `.ai/<project-name>/debt-register.md` agreed

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:**
- [ ] Determine whether this invocation involves active remediation planning (not a check-debt-register review).
- [ ] If planning remediation of code-level debt items → flag **refactoring** → co-invoke before planning begins.

*check-debt-register mode is a read-only register review — co-invocation does not apply.*

---

### Step 1: Debt Discovery and Inventory

**Actions:**
- [ ] If persistent mode: read `.ai/<project-name>/debt-register.md` — load Active and Waived sections
- [ ] Collect complexity metrics per module (cyclomatic complexity, coupling, coverage)
- [ ] Survey developers: "Which 3 modules would you most like to refactor and why?"
- [ ] Review incident history for modules contributing most to production failures
- [ ] Review recent sprint retrospectives for references to technical pain
- [ ] Cross-reference with code churn: high complexity + high churn = highest debt priority
- [ ] Filter discovered violations: skip items already in Active (duplicate); skip items in Waived (already reviewed and accepted)

**Watch-fors:** A module appearing in multiple incident post-mortems AND being the most-changed module — systemic debt creating systemic risk. Developers routing feature work around a module ("we can't touch X") — debt so severe the module is effectively frozen.

---

### Step 2: Debt Classification and Severity Scoring

| Level | Definition |
|-------|-----------|
| CRITICAL | Actively causing incidents or blocking delivery; requires immediate remediation |
| HIGH | Slowing feature velocity significantly; causing repeated minor incidents |
| MEDIUM | Reducing maintainability; not yet causing delivery problems |
| LOW | Cosmetic or minor structural issues; address during routine maintenance |

**Actions:**
- [ ] Score each item on: business impact, probability of causing a problem, remediation effort
- [ ] Apply DA-1: SOLID violations at module level are minimum MEDIUM severity
- [ ] Populate all debt register fields — a debt item without a business impact statement has no priority basis

---

### Step 3: Business Impact Framing

Debt framed as "the code is messy" gets deprioritized. Framed as "this module caused 40% of our incidents and takes 3x longer to change" it gets addressed.

**Actions:**
- [ ] Translate each item to business language: "X has no test coverage" → "every change to X carries regression risk; last 3 incidents originated here"
- [ ] Quantify where possible: coverage %, incident count, relative feature delivery time vs. comparable modules
- [ ] Apply PC-3: when debt repayment competes with feature delivery, present the quantified tradeoff and request stakeholder prioritization — do not resolve unilaterally

---

### Step 4: Prioritization and Remediation Planning

**Actions:**
- [ ] Rank items: priority = (business_impact × incident_probability) / remediation_effort
- [ ] Identify quick wins — LOW effort, MEDIUM+ impact, addressable in one sprint
- [ ] Identify strategic refactors — HIGH effort, CRITICAL impact, requiring dedicated sprint allocation
- [ ] Apply PS-3: scope all remediation explicitly — define scope and exit criteria per item; open-ended "refactor everything" sprints are not acceptable
- [ ] Elevate debt in modules receiving heavy upcoming feature work — fix debt before adding complexity on top
- [ ] Flag **refactoring** for each item prioritized for the current cycle

---

### Step 5: Risk Mitigation for Deferred Debt

**Actions:**
- [ ] Define containment: add test coverage around debt area, add monitoring for failure modes it creates, isolate behind a clean interface
- [ ] Set deferral limits: CRITICAL ≤ 1 sprint, HIGH ≤ 2 sprints
- [ ] Schedule deferred items for review at every sprint planning — they must not silently accumulate on the backlog

---

### "check debt-register" Mode

Invoked explicitly by the user. Does not run the full discovery and classification pipeline — only reviews the existing register against recent git history.

**Actions:**
- [ ] Read `.ai/<project-name>/debt-register.md` — load Active and Waived sections
- [ ] Run `git log --stat` since last register check (or a specified date/tag)
- [ ] For each Active item: determine whether any commit touched the item's module/location in a way that addresses the violation; if violation is no longer detectable, propose deletion
- [ ] For each Waived item: determine whether the violation was removed by a commit; if no longer detectable, propose deletion
- [ ] Present proposed deletions to user for confirmation — do not write until confirmed
- [ ] On confirmation: remove resolved items from file; git has the history

**Watch-fors:** Items where the relevant code was moved rather than deleted — the violation may persist in a new location. Confirm the violation is genuinely gone, not relocated.

---

### Final Step: Generate Debt Register Entry and Prioritization Report

```markdown
## Technical Debt Report

**Date:** [YYYY-MM-DD]  **Scope:** [System / Component / Module]

### Debt Register
| ID | Location | Description | Severity | Business Impact | Effort | Priority Score |
|----|----------|-------------|---------|----------------|--------|---------------|
| TD-001 | [Module] | [Description] | [CRITICAL/HIGH/MED/LOW] | [Business impact] | [S/M/L/XL] | [Score] |

### Quick Wins (Low Effort, Medium+ Impact)
| ID | Action | Estimated Sprint | Owner |
|----|--------|-----------------|-------|

### Strategic Refactors (High Effort, Critical Impact)
| ID | Scope | Sprint Allocation | Prerequisites |
|----|-------|------------------|--------------|

### Deferred Debt with Containment
| ID | Deferral Reason | Containment Strategy | Review Date |
|----|----------------|---------------------|------------|

### Skills Flagged
- **refactoring**: [Items prioritized for this cycle]
- **system-design**: [Architectural debt items]
- **performance-optimization**: [Debt causing perf degradation]
- **modularity**: [Boundary violation debt items — unregistered only]

### Required Actions
- [ ] Schedule quick wins in current sprint
- [ ] Allocate sprint capacity for strategic refactors
```

**If persistent mode:** write/update `.ai/<project-name>/debt-register.md` — append new Active items; append new Waived items to the Waived section. Do not remove items here; removal happens only via "check debt-register" mode with user confirmation.

---

## Core Responsibilities

1. Discover and inventory all technical debt with business impact framing
2. Classify debt by severity and score by impact × probability / effort
3. Produce a scoped, prioritized remediation plan with clear sprint allocations
4. Define containment strategies for deferred debt items
5. Prevent invisible accumulation by logging every new shortcut at introduction time
6. Bridge between engineering debt language and business priority language

**Quality criteria:** Every debt item has a business impact statement and defined remediation scope. No debt item is deferred indefinitely — each has a scheduled review date and deferral limit per severity.

---

## Constraints (Rules Applied)

* **MF-2: Technical Debt Tracking** — All shortcuts must be logged at the time they are taken. Untracked debt is unmanaged debt.
* **DA-1: SOLID & Clean Code First** — Debt entries reference the specific design principle violated, making the remediation approach clearer.
* **PC-3: Business Priority Override** — Debt prioritization competing with feature delivery is a business decision. Present tradeoffs; do not resolve unilaterally.
* **PS-3: Scope Control** — Debt remediation sprints must be scoped with defined exit criteria. Open-ended refactoring allocations are not acceptable.
* **DT-1: Explicit Tradeoff Logging** — Every accepted shortcut must be logged at acceptance, not retroactively.
* **GM-4: Behavioral Transparency** — Severity assessments must be evidence-based (metrics, incident data), not subjective impressions.

---

## Tradeoff Handling

### Immediate Delivery vs. Long-Term Maintainability

**Scenario:** Time pressure requires a shortcut; logging it creates overhead and slows the team.

**Default stance:** Accept debt deliberately and log it immediately. A logged shortcut with a remediation plan is a managed risk; an unlogged shortcut is an unknown risk. MF-2 is non-negotiable.

**Resolution:** Take the shortcut → log it immediately with severity and remediation timeline → schedule remediation within the agreed deferral window per severity level.

---

### Refactoring Investment vs. Feature Velocity

**Scenario:** Debt repayment competes with committed feature delivery.

**Default stance:** This is a business decision, not an engineering decision. Present the quantified tradeoff and let the stakeholder prioritize.

**Resolution:** Quantify delivery slowdown from the debt and effort to remediate → present options to stakeholder → never secretly refactor during feature sprints (creates scope creep and breaks delivery commitments).

---

## Failure & Escalation Behavior

### Debt Reaches Delivery-Blocking Severity

**Trigger:** A module's accumulated debt reaches CRITICAL — features cannot be safely delivered without addressing it first.

**Action:** Stop new feature work in the affected module. Escalate to stakeholder with business impact quantification. Flag **refactoring** and **system-design** for remediation planning. Do not add new features on top of CRITICAL debt.

---

### Debt Accumulating Without Being Logged

**Trigger:** Code review or incident analysis reveals shortcuts taken without being logged.

**Action:** Log retroactively. Investigate why they weren't logged at the time — process gap or cultural resistance. Address the root cause; if engineers avoid logging out of fear of judgment, the process must be made psychologically safe.

---

### Debt Causing Performance Degradation

**Trigger:** A debt item is identified as the root cause of measurable performance degradation.

**Action:** Flag **performance-optimization** to quantify and address the degradation alongside the debt remediation plan.

---

### Debt Manifesting as Module Boundary Violations

**Trigger:** Debt manifests as module boundary violations requiring structural decomposition; violations are not yet registered in the debt register.

**Action:** Log violations in the debt register first, then flag **modularity** for decomposition analysis. Only flag modularity for unregistered violations — violations already in the register do not trigger re-escalation.

---

### When to halt execution:

* Debt severity is CRITICAL and stakeholder is unavailable — halt feature work in the affected module until escalation is resolved
* Debt-vs-delivery conflict cannot be quantified — halt prioritization and request metrics before proceeding

---

## Skill Integration & Orchestration

**Role in pipeline:** Runs after shortcuts are introduced or when other skills surface debt signals. Feeds prioritized debt items into Refactoring and System Design. Receives boundary violation signals from Modularity and performance signals from Performance Optimization.

### How This Skill Integrates

**Does NOT directly call other skills.** Instead, this skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes this skill based on triggers (shortcut logged, debt signal, pre-cycle assessment)
2. This skill inventories, classifies, and prioritizes all debt items
3. This skill **outputs flags** for other skills in the report
4. **Orchestrator** decides which skills to invoke next based on flags

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Debt item prioritized for immediate remediation | refactoring | Refactoring executes the fix; TDM identifies and scopes it |
| Architectural debt affecting system boundaries | system-design | Structural debt requires system-level redesign |
| Debt causing measurable performance degradation | performance-optimization | Performance analysis needed alongside remediation |
| Module boundary violations not yet in debt register | modularity | Decomposition analysis required; log violations first |

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides architectural context for classifying structural debt severity.

**Skills this skill cooperates with:**

* **refactoring** — TDM scopes and prioritizes; Refactoring executes. Close collaboration on CRITICAL items.
* **modularity** — Bidirectional: TDM flags modularity for unregistered boundary violations; modularity flags TDM when violations are too numerous to fix immediately.
* **performance-optimization** — TDM flags when debt causes degradation; performance-optimization provides quantification and fix.

---

## Governance Hooks

* [ ] Log all tradeoff decisions via DT-1 — every accepted shortcut must be recorded at the time it is taken
* [ ] Explain risks before recommending deferral (GM-2) — present business impact honestly and completely
* [ ] Respect confirmation gates for debt-vs-delivery conflicts — do not resolve unilaterally (PC-3)
* [ ] Do not accept CRITICAL debt deferral without explicit stakeholder approval
* [ ] Document all exceptions and deviations with rationale and review date

---

## Example Use Cases

### General: Pre-Feature-Cycle Debt Assessment

Before adding a major payments feature, TDM is invoked to assess structural risk in the PaymentService module. Complexity metrics show high cyclomatic complexity, developer surveys flag it as "scary to change," and incident history shows it contributed to 4 of the last 6 production incidents. TDM classifies this as CRITICAL debt, halts feature work, escalates to the stakeholder with a "3x delivery slowdown + 67% of payment incidents" framing, and flags **refactoring** for a scoped remediation sprint before feature work begins.

### Edge Case: Boundary Violations Too Numerous for Immediate Fix

During a debt audit, TDM identifies that the UserService has accumulated 12 boundary violations across 3 domain concerns. Fixing all of them immediately would require 2+ sprints and conflicts with an upcoming release. TDM logs all violations in the debt register with severity classifications, then flags **modularity** for decomposition analysis of the BLOCKING violations. The output-state guard ensures TDM does not re-escalate to modularity for violations already registered — only newly discovered unregistered violations trigger re-escalation.

---

## Anti-Patterns to Catch

❌ **Invisible Debt:** Taking shortcuts without logging them, intending to remember later. They are never fixed because they are never visible. ✅ Log every shortcut at the time it is taken. MF-2 is non-negotiable.

❌ **Debt as Engineering's Private Problem:** Treating debt repayment as something to solve privately without stakeholder involvement. Debt repayment competes with feature delivery — stakeholders must be informed. ✅ Present debt with business impact framing and request prioritization. PC-3 applies.

❌ **Open-Ended Refactoring Sprints:** Allocating a "refactoring sprint" without defined scope or exit criteria. These typically produce work-in-progress that is never completed. ✅ Every debt remediation item has defined scope, exit criteria, and a definition of done. PS-3 applies.

❌ **Addressing Symptoms, Not Root Causes:** Fixing a bug in a high-debt module without addressing the underlying debt that made the bug possible. ✅ When fixing bugs in high-debt modules, log the contributing debt. If CRITICAL, the bug fix alone is insufficient.

❌ **Debt Measured in Code Quality Alone:** Tracking debt as code smells or cyclomatic complexity without connecting to business impact. "We have high cyclomatic complexity" is not actionable. ✅ Every debt item must have a business impact statement. Technical metrics are evidence; business impact is the justification for prioritization.

---

## Non-Goals

* ❌ **Executing refactoring** — Refactoring handles execution
* ❌ **Per-PR code quality standards** — Clean Code & SOLID
* ❌ **Performance optimization** — Performance Optimization handles performance-specific improvements

**Boundary clarifications:**

* TDM identifies and scopes debt items; Refactoring executes the fix. TDM does not touch code.
* TDM flags boundary violations needing decomposition; Modularity performs the decomposition. TDM does not redesign module boundaries.
* TDM flags performance-degrading debt; Performance Optimization quantifies and fixes the degradation. TDM does not run profiling.

---

## Notes for LLM Implementation

1. Never defer CRITICAL debt without explicit stakeholder confirmation — escalate even if the stakeholder is unavailable; do not make the deferral decision unilaterally.
2. Business impact framing is mandatory for every debt item — "the code is messy" is not an acceptable impact statement; quantify in delivery time, incident rate, or feature risk.
3. When flagging modularity, apply the output-state guard: only flag for violations not already in the debt register (Active or Waived). In persistent mode, read the file; in session-only mode, check session context. Re-escalating already-registered violations creates a loop.
4. The priority formula (business_impact × incident_probability / effort) is a ranking tool, not an absolute score — use it to order items, not to exclude low-scoring items from the register.
5. Quick wins (low effort, medium+ impact) must be surfaced explicitly — they often get buried under strategic refactors and never actioned.
6. Two distinct modes: normal run (read register for dedup/skip, run full discovery, append new items, write if persistent) vs. "check debt-register" (read register + git log, propose deletions, confirm before writing). Never run the full discovery pipeline in "check debt-register" mode — it is a lightweight review only.
