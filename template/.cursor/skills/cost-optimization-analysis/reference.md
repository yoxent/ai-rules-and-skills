```yaml
---
name: cost-optimization-analysis
description: Analyses cloud and infrastructure resource usage to identify waste, right-size allocations, and reduce cost while maintaining performance and reliability requirements.
version: 1.0.0
category: DevOps
tags: [cost, optimization, cloud, rightsizing, finops]
priority: Medium

depends_on: [monitoring-alerts]
flags_skills: [infrastructure-as-code, monitoring-alerts]

inputs: [cloud-billing-data, resource-utilisation-metrics, performance-reliability-requirements]
outputs: [cost-optimization-recommendations, resource-usage-reports, rightsizing-recommendations]

rules_applied:
  - PC-4  # Performance Budget — cost reductions must not violate performance or reliability SLOs
  - DA-5  # Avoid Overengineering — cost optimisation changes must be justified against measured savings
  - DT-1  # Explicit Tradeoff Logging — document all cost vs performance tradeoffs
  - DT-2  # Confirmation Gate — changes reducing redundancy or capacity require explicit approval

documents_needed: [billing-reports, utilisation-metrics, slo-definitions, architecture-diagram]

execution_context: Runs periodically or when cost anomalies are detected; produces recommendations that are applied through infrastructure-as-code after approval.

---
```

---

# Skill: Cost Optimization & Analysis

---

## Purpose

**What this skill does:**
Analyses cloud billing data and resource utilisation metrics to identify idle, underutilised, or over-provisioned resources. It produces prioritised recommendations for rightsizing, scheduling, or architectural changes — always validated against performance and reliability SLOs before being proposed.

Reduces infrastructure spend without compromising reliability. Surfaces cost anomalies from runaway services or misconfigured auto-scaling before they generate unexpected bills. Enables informed investment decisions by making the cost impact of architectural choices visible.

Makes resource efficiency a measured, data-driven concern rather than an intuition-driven one. Prevents the accumulation of orphaned or forgotten resources that add cost without value. Ensures optimisation decisions are validated against real SLO data, not just cost figures.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Cloud bill has increased unexpectedly or anomalously
* Infrastructure costs are being reviewed for a service or environment
* Resource utilisation metrics show consistently low utilisation
* Auto-scaling configuration is being reviewed
* A new service is being architected and cost efficiency is a design concern
* Post-incident review identifies resource misconfiguration contributing to cost

### Do NOT use this skill for:

* Applying infrastructure changes — approved recommendations are applied via Infrastructure as Code
* Monitoring and alerting setup — handled by Monitoring & Alerts
* Performance profiling and root cause analysis — handled by Performance Optimization
* Procurement or contract negotiation — outside engineering scope

---

## Inputs

**Required inputs:**

* **Cloud billing data and usage reports** — Cost breakdowns by service, resource type, and time period. Used to identify cost anomalies and spending patterns.
* **Resource utilisation metrics** — CPU, memory, network, and storage utilisation per resource, ideally at p50/p95/p99 over a representative time window (minimum 2 weeks).
* **Performance and reliability requirements** — SLO definitions and performance budgets that constrain how aggressively resources can be reduced.

**Optional inputs:**

* **Architecture diagram** — To understand resource relationships and identify optimisation opportunities at the architectural level.
* **Auto-scaling configuration** — To assess whether scaling policies are efficient and correctly calibrated.

---

## Outputs

**Primary outputs:**

* **Cost optimisation recommendations with impact estimates** — Prioritised list of changes with estimated monthly savings, implementation effort, and risk classification.
* **Resource usage reports and anomaly alerts** — Current utilisation state with anomalies highlighted for immediate attention.
* **Rightsizing and termination recommendations** — Specific resource changes (resize from m5.xlarge to m5.large, terminate idle dev instances) with SLO impact assessment.

---

## Preconditions

**Conditions that must be met before execution:**

* Billing data is available for at least 2 weeks (ideally 4 weeks) to establish utilisation baselines
* SLO definitions are available to validate recommendations against
* Monitoring & Alerts skill has been applied — utilisation metrics depend on monitoring instrumentation

**Validation checks:**

* [ ] Billing data covers representative time window (includes weekday and weekend patterns)
* [ ] Utilisation metrics available at sufficient granularity (per-resource, not just aggregate)
* [ ] SLO definitions available for all services being optimised
* [ ] DT-2 confirmation obtained before any capacity-reducing changes are applied

---

## Step-by-Step Execution Procedure

### Step 1: Identify Cost Anomalies and Top Spenders

**Questions to answer:**
- Are there unexpected cost spikes in the billing data?
- Which resources or services account for the largest share of cost?
- Are there orphaned or idle resources with no utilisation?

**Actions:**
- [ ] Review billing data for anomalous cost increases (>20% week-over-week without deployment correlation)
- [ ] Identify top 20% of resources by cost (Pareto — these typically represent 80% of spend)
- [ ] Identify resources with zero or near-zero utilisation over the measurement window
- [ ] Flag cost anomalies for immediate investigation — may indicate misconfigured auto-scaling or runaway processes

**Red flags / Warning signs:**
- Cost spike correlated with a recent deployment — potential misconfiguration
- Resources with zero utilisation for >7 days — orphaned resources
- Auto-scaling groups with minimum instance count set higher than peak utilisation requires

**Decision points:**
- If anomalous spike detected, investigate root cause before generating optimisation recommendations — the spike may indicate a bug, not a scaling opportunity.

---

### Step 2: Analyse Utilisation Against Provisioned Capacity

**Questions to answer:**
- What is the p95 utilisation for each resource over the measurement window?
- Is the provisioned capacity appropriate for the observed utilisation pattern?
- Are there resources consistently below 20% utilisation that are candidates for rightsizing?

**Actions:**
- [ ] Calculate p50 and p95 utilisation per resource for CPU, memory, and relevant metrics
- [ ] Compare p95 utilisation against provisioned capacity — identify over-provisioned resources
- [ ] Identify resources where p95 utilisation is below 20% of provisioned capacity
- [ ] Account for traffic patterns — resources may appear idle at p50 but necessary for p99 spike handling

**Red flags / Warning signs:**
- Rightsizing based on p50 only — p99 spikes may require the current capacity
- Production resources with p95 CPU < 5% — strong rightsizing candidate
- Memory utilisation near 100% despite low CPU — resource constraint mismatch

**Decision points:**
- Never recommend rightsizing based on p50 alone — always validate against p95 and traffic spike patterns.
- If rightsizing would bring p95 utilisation above 70%, classify as MEDIUM risk — requires DT-2.

---

### Step 3: Generate Recommendations with SLO Validation

**Questions to answer:**
- Does each recommendation maintain SLO compliance after the change?
- What is the risk classification for each recommendation?
- Are recommendations prioritised by savings impact vs implementation risk?

**Actions:**
- [ ] For each candidate resource, simulate post-optimisation utilisation against SLO thresholds
- [ ] Classify each recommendation: LOW risk (idle/orphaned resources), MEDIUM risk (rightsizing with buffer), HIGH risk (capacity reduction near SLO boundary)
- [ ] Prioritise recommendations by: (savings × confidence) / risk
- [ ] Reject any recommendation that would violate a defined SLO — log via DT-1 if forced

**Red flags / Warning signs:**
- Recommendations that bring utilisation above SLO-defined performance budgets
- High-risk recommendations presented without explicit SLO impact assessment
- Cost savings estimated without accounting for performance degradation cost

**Decision points:**
- Any recommendation classified HIGH risk requires DT-2 confirmation before being actioned.
- If no low-risk recommendations exist, communicate cost vs reliability tradeoff explicitly via DT-1.

---

### Step 4: Identify Architectural Optimisation Opportunities

**Questions to answer:**
- Are there architectural patterns driving unnecessary cost (e.g. always-on resources for bursty workloads)?
- Are reserved instance or savings plan commitments appropriate for the utilisation pattern?
- Are there consolidation opportunities (multiple small instances vs one appropriately sized instance)?

**Actions:**
- [ ] Identify workloads suitable for spot/preemptible instances (stateless, fault-tolerant)
- [ ] Assess reserved instance or savings plan coverage vs on-demand spend ratio
- [ ] Identify consolidation opportunities — multiple under-utilised instances that could be merged
- [ ] Flag scheduling opportunities — dev/staging environments that could be shut down outside business hours

**Red flags / Warning signs:**
- Production stateful workloads running on spot instances — reliability risk
- 100% on-demand spend for stable, predictable workloads — significant reserved instance savings available
- Identical dev and production environment sizing when dev runs only during business hours

**Decision points:**
- Spot instance recommendations for production stateful workloads require DT-2 with explicit reliability risk acknowledgement.

---

### Step 5: Present Recommendations and Obtain Approval

**Questions to answer:**
- Are recommendations presented with sufficient context for informed decision-making?
- Are all capacity-reducing changes confirmed via DT-2 before being actioned?
- Are approved recommendations handed off to Infrastructure as Code for implementation?

**Actions:**
- [ ] Present prioritised recommendations with: current cost, projected savings, risk classification, SLO impact
- [ ] Request DT-2 confirmation for all capacity-reducing or redundancy-reducing changes
- [ ] Flag infrastructure-as-code for implementation of approved recommendations
- [ ] Flag monitoring-alerts to track post-optimisation performance impact

**Decision points:**
- Do not action any recommendation without explicit DT-2 confirmation.
- If user accepts HIGH risk recommendation, document via DT-1 with explicit risk acknowledgement.

---

### Final Step: Generate Cost Optimisation Report

```markdown
## Cost Optimisation & Analysis Report

**Scope:** [Service / Environment / Account]
**Period:** [Date range]
**Date:** [YYYY-MM-DD]
**Status:** ✅ RECOMMENDATIONS READY / ⚠️ ANOMALIES DETECTED / ❌ SLO RISK

### Cost Summary
- **Current monthly spend:** $X,XXX
- **Identified savings opportunity:** $XXX/month (XX%)

### Recommendations
| Resource | Change | Savings/mo | Risk | SLO Impact | DT-2 Required |
|----------|--------|-----------|------|-----------|---------------|
| prod-api-server | m5.xlarge → m5.large | $180 | LOW | None | No |
| staging-db | Always-on → scheduled off-hours | $95 | LOW | None (staging only) | No |
| prod-cache | 3 nodes → 2 nodes | $140 | MEDIUM | p95 latency +12ms | Yes |

### Anomalies Detected
- [Anomaly description if any]

### Skills Flagged
- **infrastructure-as-code**: Implement approved changes
- **monitoring-alerts**: Track post-optimisation performance

### Required Actions
- [ ] DT-2 confirmation for MEDIUM/HIGH risk recommendations
- [ ] Infrastructure as Code implementation for approved changes
```

---

## Core Responsibilities

1. Identify idle, orphaned, and over-provisioned resources from billing and utilisation data.
2. Validate all recommendations against SLO thresholds before proposing — never recommend changes that violate SLOs without explicit DT-1 and DT-2.
3. Classify every recommendation by risk and require DT-2 for capacity-reducing changes.
4. Flag cost anomalies for investigation before generating recommendations.
5. Hand off approved recommendations to Infrastructure as Code for implementation.

---

## Constraints (Rules Applied)

* **PC-4: Performance Budget** — Cost reductions must not violate defined performance or reliability SLOs; every recommendation must include a post-optimisation SLO impact assessment.
* **DA-5: Avoid Overengineering** — Cost optimisation changes must be justified against measured savings; micro-optimisations with negligible savings and high complexity are not worth pursuing.
* **DT-1: Explicit Tradeoff Logging** — Every cost vs performance tradeoff must be documented explicitly.
* **DT-2: Confirmation Gate** — Changes that reduce redundancy or capacity require explicit human confirmation; cost savings do not override this requirement.

---

## Tradeoff Handling

### Tradeoff 1: Cost Savings vs System Performance

**Resolution:** Measure p95 utilisation over a representative window; validate that post-optimisation p95 stays below SLO threshold; require DT-2 for any recommendation where p95 utilisation would exceed 70% post-change.

### Tradeoff 2: Automation vs Manual Tuning

**Resolution:** Generate recommendations from data, not intuition; have a human review for application-specific knowledge (seasonal patterns, upcoming launches); DT-2 confirms all capacity-reducing changes before execution.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Cost Anomaly Detected

**Trigger:** Billing data shows unexpected cost spike not explained by known deployments or traffic growth.

**Action:**
- Do not generate optimisation recommendations until anomaly is investigated
- Flag monitoring-alerts — anomaly may indicate runaway process or misconfigured auto-scaling
- Document anomaly via DT-1

---

### Escalation Scenario 2: No Low-Risk Recommendations Available

**Trigger:** All identified optimisation opportunities carry MEDIUM or HIGH risk due to SLO proximity.

**Action:**
- Present cost vs reliability tradeoff explicitly to stakeholders
- Document via DT-1 — cost savings achievable only at reliability risk
- Request DT-2 for stakeholder to make informed choice
- Do not action without confirmation

---

### Escalation Scenario 3: Recommendation Would Violate SLO

**Trigger:** A cost optimisation recommendation would bring a resource above SLO-defined performance thresholds.

**Action:**
- Reject the recommendation
- Document via DT-1 — what saving was forgone and why
- Present alternative: accept cost or revise SLO

---

### When to halt execution:

* Cost anomaly detected — investigate before generating recommendations
* All recommendations violate SLOs — escalate cost vs reliability tradeoff to stakeholders
* DT-2 confirmation not received for capacity-reducing changes

---

## Skill Integration & Orchestration

This skill depends on Monitoring & Alerts for utilisation metrics. Approved recommendations are handed to Infrastructure as Code for implementation. Monitoring & Alerts is flagged post-implementation to track performance impact.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Approved recommendations ready for implementation | infrastructure-as-code | IaC applies the changes |
| Post-optimisation performance monitoring needed | monitoring-alerts | Track SLO impact after changes |

---

## Related Skills

**Skills this skill depends on:**
* **monitoring-alerts** — Provides the utilisation metrics that cost analysis depends on.

**Skills this skill cooperates with:**
* **infrastructure-as-code** — Implements approved resource changes.
* **monitoring-alerts** — Monitors post-optimisation performance impact.

---

## Governance Hooks

* [ ] Never recommend changes that violate SLOs without DT-1 and DT-2
* [ ] Require DT-2 for all capacity-reducing or redundancy-reducing changes
* [ ] Investigate anomalies before generating recommendations
* [ ] Document all cost vs performance tradeoffs via DT-1
* [ ] Hand off approved changes to infrastructure-as-code — do not apply directly

---

## Example Use Cases

### Example 1: Idle Dev Instances Identified

**Scenario:** Cost analysis finds 8 development EC2 instances running 24/7 with <2% average CPU utilisation, consuming $640/month.

**Execution steps:**
1. Confirm zero utilisation outside business hours (nights and weekends).
2. Classify as LOW risk — development environment, no SLO impact.
3. Recommend scheduling: shut down outside 07:00–20:00 weekdays.
4. Projected savings: $420/month (65%).
5. No DT-2 required (LOW risk, no production impact).
6. Flag infrastructure-as-code to implement scheduling.

**Result:** Recommendation presented. $420/month savings identified.

---

### Example 2: Production Rightsizing Near SLO Boundary

**Scenario:** Production API servers running at p95 CPU of 18% on m5.xlarge. Rightsizing to m5.large would bring p95 to estimated 65%.

**Execution steps:**
1. Calculate p95 utilisation post-rightsizing: 65% — within SLO budget (threshold: 70%).
2. Classify as MEDIUM risk — close to SLO boundary under spike conditions.
3. Require DT-2 confirmation.
4. Log cost vs performance tradeoff via DT-1.
5. Present to stakeholder: $180/month savings, 12ms p99 latency increase estimated.

**Result:** MEDIUM risk recommendation presented. Awaiting DT-2.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Rightsizing based on average (p50) utilisation**
✅ **Correct approach:** Always use p95 as the primary rightsizing metric. Average utilisation ignores traffic spikes that require the current capacity.

❌ **Anti-pattern 2: Actioning recommendations without DT-2 confirmation**
✅ **Correct approach:** Cost savings do not override the confirmation gate. Capacity reductions always require explicit approval.

❌ **Anti-pattern 3: Investigating cost anomalies as optimisation opportunities**
✅ **Correct approach:** A cost spike is not an optimisation opportunity — it may be a bug or misconfiguration. Investigate root cause before recommending changes.

❌ **Anti-pattern 4: Recommending spot instances for stateful production workloads**
✅ **Correct approach:** Spot instances are appropriate for stateless, fault-tolerant workloads. Stateful production workloads require on-demand or reserved instances.

❌ **Anti-pattern 5: Optimising without measuring post-change performance**
✅ **Correct approach:** Flag monitoring-alerts after every change to track SLO compliance. Cost optimisation without performance tracking is incomplete.

---

## Non-Goals

* ❌ Applying infrastructure changes directly — recommendations are implemented via Infrastructure as Code
* ❌ Monitoring and alerting setup — handled by Monitoring & Alerts
* ❌ Performance profiling — handled by Performance Optimization
* ❌ Procurement and contract negotiation — outside engineering scope
