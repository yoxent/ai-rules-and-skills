```yaml
---
name: metrics_and_kpis
description: Defines, tracks, and reports KPIs to measure feature and product success; enables data-driven decisions and early detection of underperforming areas.
version: 1.0.0
category: Product
tags: [metrics, kpis, analytics, okrs, data-driven]
priority: Medium

depends_on: []
flags_skills: [feature-validation, stakeholder-communication]

inputs: [user-behavioral-data, feature-performance-metrics, business-kpis, okrs]
outputs: [kpi-definitions, performance-reports, anomaly-alerts, recommendations]

rules_applied:
  - PS-1
  - PS-4
  - DT-1

documents_needed: [product-okrs, feature-specs, historical-metrics, user-research]

execution_context: Triggered when a feature is being planned (define KPIs upfront), at regular reporting cadence (track and report), or when a metric anomaly is detected. KPI definition runs before sprint commitment; reporting runs post-launch.
---
```

---

# Skill: Metrics & KPIs

---

## Purpose

**What this skill does:**
Defines measurable success criteria for features before launch, monitors performance against targets post-launch, and identifies trends and anomalies that should drive product decisions. Covers the full lifecycle: definition → instrumentation → reporting → action.

Features without predefined success metrics cannot be objectively evaluated. KPI-driven decisions are faster, less political, and more defensible than intuition-based ones. Early anomaly detection prevents small underperformances from becoming business problems.

Upfront KPI definition drives instrumentation requirements into sprint planning, preventing the common failure of launching features without the data infrastructure to evaluate them.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new feature is being planned and success criteria haven't been defined
* A feature is about to launch without instrumentation in place
* Regular reporting cadence (sprint review, monthly business review) is due
* A metric anomaly is detected (unexpected spike, drop, or plateau)
* A product decision is being made and data is available to inform it
* KPI deferral for delivery speed is being considered and needs to be logged

### Do NOT use this skill for:

* Implementing the analytics instrumentation — that is an engineering task
* A/B test design — requires a separate statistical testing skill
* Financial reporting and accounting metrics — outside product KPI scope
* Real-time operational monitoring — use `observability` skill from Phase 2

---

## Inputs

**Required inputs:**

* **Feature specs or product area** — What is being measured.
* **Business goals or OKRs** — The strategic objectives the KPIs must connect to.

**Optional inputs:**

* **Historical metrics** — Baseline data for comparison and trend analysis.
* **User behavioral data** — Quantitative usage data for feature performance assessment.
* **Existing KPI framework** — Current metrics to ensure new KPIs don't conflict or duplicate.

---

## Outputs

**Primary outputs:**

* **KPI definitions** — Named metrics with: measurement method, target value, baseline, owner, and reporting cadence.
* **Performance reports** — Actuals vs targets with trend direction and anomaly highlights.
* **Recommendations** — Data-driven actions when KPIs indicate underperformance or opportunity.

---

## Preconditions

**Conditions that must be met before execution:**

* The feature or product area being measured is defined
* Business goals or OKRs are available to anchor KPI definitions
* For reporting mode: instrumentation is in place and data is accessible

---

## Step-by-Step Execution Procedure

### Step 1: Anchor KPIs to Business Goals

**Actions:**
- [ ] Identify the business goal or OKR this feature is meant to serve
- [ ] For each goal, define one primary KPI that directly measures progress toward it
- [ ] Define at most two secondary KPIs per goal — avoid metric proliferation

**Red flags:**
- KPI defined with no connection to a business goal (vanity metric risk)
- More than three KPIs per feature — focus degrades beyond that
- KPI measures activity (page views) instead of outcome (task completion rate)

---

### Step 2: Define Each KPI with Full Specification

**Actions:**
- [ ] Name: descriptive, unambiguous
- [ ] Measurement method: how it is calculated and from what data source
- [ ] Baseline: current state before the feature launches
- [ ] Target: specific, time-bound value (not "improve" — "increase by 15% within 30 days")
- [ ] Owner: who is responsible for monitoring this KPI
- [ ] Reporting cadence: daily / weekly / monthly based on signal volatility

**Red flags:**
- Target stated as directional only ("increase") without a specific value — not measurable
- No baseline defined — cannot assess improvement without one
- No owner assigned — unowned KPIs go unmonitored

---

### Step 3: Validate Instrumentation Coverage

**Actions:**
- [ ] Confirm that the data required to measure each KPI will be captured by launch
- [ ] If instrumentation gap exists, flag as a sprint dependency — instrumentation is a launch blocker
- [ ] Log any KPI deferred due to instrumentation constraints per DT-1

**Red flags:**
- Feature launching without instrumentation for its primary KPI
- Instrumentation planned as a follow-up ticket — high risk of never completing

---

### Step 4: Monitor and Report (Post-Launch Mode)

**Actions:**
- [ ] Compare actuals to targets at each reporting cadence
- [ ] Classify each KPI: ON-TRACK / AT-RISK / UNDERPERFORMING / ANOMALY
- [ ] For ANOMALY: investigate before reporting — distinguish data artifact from real signal
- [ ] For UNDERPERFORMING: generate a specific hypothesis and recommended action

---

### Step 5: Flag Decisions and Anomalies

**Actions:**
- [ ] For significant underperformance: flag `feature-validation` for feature reconsideration
- [ ] For stakeholder-relevant trends or anomalies: flag `stakeholder-communication`
- [ ] Log all KPI-based decisions with the data that drove them per PS-4

---

### Final Step: Generate KPI Report

```markdown
## Metrics & KPIs Report

**Feature/Area:** [Name]
**Date:** [YYYY-MM-DD]
**Mode:** Definition / Reporting

### KPI Definitions (Definition Mode)
| KPI | Method | Baseline | Target | Owner | Cadence |
|-----|--------|----------|--------|-------|---------|
| ... | ...    | ...      | ...    | ...   | ...     |

### Performance Summary (Reporting Mode)
| KPI | Target | Actual | Status | Trend |
|-----|--------|--------|--------|-------|
| ... | ...    | ...    | ✅/⚠️/❌ | ↑/↓/→ |

### Anomalies and Actions
- [KPI]: [Anomaly description] → Recommended action: [specific action]

### KPI Deferrals (DT-1)
- [KPI]: Deferred due to [reason]. Scheduled for: [date or sprint]

### Skills Flagged
- ⚡ **feature-validation**: [KPI evidence suggesting feature reconsideration]
- 📢 **stakeholder-communication**: [Trend or anomaly requiring stakeholder notification]
```

---

## Core Responsibilities

1. Define KPIs anchored to business goals before sprint commitment — not post-launch
2. Every KPI has: measurement method, baseline, specific target, owner, cadence
3. Instrumentation gaps treated as launch blockers — flag as sprint dependencies
4. Log KPI deferrals per DT-1 with reason and recovery plan
5. Flag significant underperformance to `feature-validation`; anomalies to `stakeholder-communication`

---

## Constraints (Rules Applied)

* **PS-1:** KPIs must be defined as part of feature requirements, not added post-launch. Missing KPI definition at sprint planning = requirement gap.
* **PS-4:** Every KPI-based decision documented with the specific data that drove it.
* **DT-1:** Any KPI deferred for delivery speed logged with reason, risk accepted, and recovery plan.

---

## Tradeoff Handling

### Tradeoff 1: Metric Granularity vs Signal Clarity

**Conflict:** More metrics provide richer insight but create noise and monitoring overhead.

**Resolution:** Always define a primary KPI per goal. Secondary KPIs: max two per feature; prune if they don't inform distinct decisions. If uncertain whether a metric is signal or noise, define it with a 30-day review and drop it if no action is ever taken on it.

### Tradeoff 2: KPI Definition vs Delivery Speed

**Conflict:** KPI definition adds sprint overhead; teams want to ship fast.

**Resolution:** If a KPI is deferred for speed, log per DT-1 with: which KPI, why deferred, target sprint for completion; flag instrumentation as a follow-up ticket — not optional. Never launch a primary KPI uninstrumented — this is a hard block. Deferring a secondary KPI is acceptable with a DT-1 log.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Feature Launching Without Primary KPI Instrumentation

**Trigger:** Sprint is about to end and primary KPI instrumentation is not in place.

**Action:**
- Block launch or negotiate explicit acceptance that the feature launches blind
- If launch proceeds uninstrumented: log per DT-1 as accepted risk; require instrumentation in next sprint
- Flag `stakeholder-communication` to inform stakeholders of the measurement gap

### Escalation Scenario 2: Persistent KPI Underperformance

**Trigger:** Primary KPI has been UNDERPERFORMING for two or more consecutive reporting periods.

**Action:**
- Flag `feature-validation` for feature reconsideration
- Provide the specific KPI data and trend as evidence
- Do not simply report underperformance — generate a hypothesis and recommended action

### Escalation Scenario 3: Vanity Metric Substitution

**Trigger:** A proposed KPI measures activity rather than outcome (e.g., page views instead of conversion rate).

**Action:**
- Reject the vanity metric
- Propose an outcome-based alternative
- Log the substitution decision per PS-4

---

### When to halt execution:

* No business goal or OKR is available to anchor KPI definitions — cannot define meaningful KPIs without strategic context
* In reporting mode: instrumentation data is unavailable or unreliable — do not report on bad data

---

## Skill Integration & Orchestration

KPI definition runs during `requirement-interpretation` or `feature-validation` as a sprint planning dependency. Reporting runs on regular cadence post-launch. Anomaly detection may trigger at any time.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Persistent KPI underperformance | feature-validation | Feature value delivery in question |
| Anomaly or significant trend | stakeholder-communication | Stakeholder notification required |

---

## Related Skills

* **Co-runs with:** `requirement-interpretation` (KPI definition phase)
* **Flags:** `feature-validation`, `stakeholder-communication`
* **No hard dependencies**

---

## Governance Hooks

* [ ] No feature commits without primary KPI defined (PS-1)
* [ ] All KPI deferrals logged per DT-1
* [ ] All KPI-based decisions documented with supporting data per PS-4
* [ ] Vanity metrics rejected at definition stage

---

## Example Use Cases

### Example 1: New Onboarding Flow KPI Definition

**Scenario:** Planning a redesigned onboarding flow to improve activation.

**KPIs defined:** Primary — 7-day activation rate (target: 65%, baseline: 48%, owner: PM, cadence: weekly). Secondary — time-to-first-key-action (target: <5 min, baseline: 8.2 min).

**Instrumentation:** Both metrics require event tracking on step completion — confirmed as sprint dependency before commitment.

### Example 2: KPI Anomaly During Reporting

**Scenario:** Checkout conversion rate drops 18% week-over-week with no scheduled changes.

**Action:** Classify as ANOMALY. Investigate: correlates with a third-party payment provider degradation event. Flag `stakeholder-communication`. Hypothesis: not a product issue — provider issue. Recommended action: confirm with provider SLA data before attributing to product.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Defining KPIs after launch ("we'll figure out metrics later")
✅ KPI definition is a sprint planning requirement, not a post-launch activity.

❌ **Anti-pattern 2:** Using activity metrics as primary KPIs (page views, clicks)
✅ Primary KPIs must measure outcomes (conversion, retention, task completion, revenue).

❌ **Anti-pattern 3:** Setting directional targets without specific values ("increase retention")
✅ Targets must be specific and time-bound: "increase 30-day retention by 10 percentage points within 60 days of launch."

❌ **Anti-pattern 4:** Reporting underperformance without a hypothesis or recommended action
✅ Every underperforming KPI gets a hypothesis ("likely caused by X") and a recommended action ("investigate Y, consider Z").

❌ **Anti-pattern 5:** Treating instrumentation as optional follow-up work
✅ Instrumentation for the primary KPI is a launch blocker. No instrumentation = launching blind.

❌ **Anti-pattern 6:** Defining more than three KPIs per feature
✅ Metric proliferation dilutes focus. Primary + two secondaries maximum. Prune aggressively.

---

## Non-Goals

* ❌ Implementing analytics instrumentation — engineering task
* ❌ A/B test design and statistical analysis — separate skill
* ❌ Financial accounting metrics — outside product KPI scope
* ❌ Real-time operational monitoring — use `observability` from Phase 2

---

## Notes for LLM Implementation

1. **Anchor first:** Before defining any KPI, identify the business goal it serves. A KPI with no goal anchor is a vanity metric by default.
2. **Specificity gate:** If a target cannot be stated with a number and a timeframe, it is not a valid target. Push back until it is specific.
3. **Instrumentation is a blocker:** Never let a primary KPI launch without confirmed instrumentation. Treat it the same as a functional dependency.
4. **Underperformance requires a hypothesis:** Reporting a red metric without a hypothesis is not actionable. Always pair the finding with a "likely because X" and a "recommend doing Y."

---
