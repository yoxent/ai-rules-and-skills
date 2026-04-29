```yaml
---
name: monitoring-alerts
description: Implements observability, monitoring, and alerting to detect failures and anomalies, provide actionable system health visibility, and enable rapid incident response.
version: 1.0.0
category: DevOps
tags: [monitoring, alerting, observability, slo, dashboards]
priority: High

depends_on: []
flags_skills: [incident-response, performance-optimization]

inputs: [application-metrics, infrastructure-metrics, logs, slo-sla-thresholds]
outputs: [alert-rules, health-dashboards, runbook-references]

rules_applied:
  - DD-1
  - CL-3
  - PS-2
  - DT-1

documents_needed: [slo-definitions, alert-threshold-policy, runbooks, data-classification-policy]

execution_context: Runs alongside deployment to instrument new services, and reactively when monitoring gaps or alert quality issues are identified.

---
```

---

# Skill: Monitoring & Alerts

---

## Purpose

**What this skill does:**
Designs, implements, and reviews monitoring instrumentation and alerting rules that provide actionable visibility into system health. It ensures alerts are calibrated to minimise false positives, routed to the right teams with relevant context, and linked to runbooks that enable rapid response.

Reduces mean time to detection (MTTD) and mean time to recovery (MTTR) for system failures. Surfaces degradation before it becomes a customer-impacting incident. Communicates monitoring gaps as business risk so stakeholders can make informed investment decisions.

Provides the observability foundation that all other operational skills depend on. Ensures monitoring is a first-class deployment concern, not retrofitted after incidents. Produces alert rules calibrated to real signal rather than noise that trains teams to ignore notifications.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new service or feature is being deployed and requires monitoring instrumentation
* Existing alert rules are producing too many false positives or missing real failures
* SLO definitions are being established or reviewed
* A post-incident review identifies monitoring gaps
* Monitoring is missing for a specific failure mode or metric
* Alert routing or on-call escalation policies are being reviewed
* Sensitive data handling in logs or metrics is being audited

### Do NOT use this skill for:

* Responding to active incidents — handled by Incident Response
* Performance profiling and optimisation — handled by Performance Optimization
* Application logging design within code — handled by the Logging skill
* Infrastructure provisioning for monitoring tools — handled by Infrastructure as Code

**Execution Context Details:**
This skill runs at deployment time (to instrument new services) and reactively after incidents or alert quality reviews. It feeds Incident Response with the detection capability and runbook links needed for effective response.

---

## Inputs

**Required inputs:**

* **Application and infrastructure metrics** — What metrics are available or need to be instrumented (request rate, error rate, latency, saturation, resource utilisation).
* **System and application logs** — Log sources and formats available for alerting and anomaly detection.
* **SLO/SLA threshold definitions** — The business-defined reliability targets that alert thresholds must be derived from.

**Optional inputs:**

* **Existing alert rules** — For review and calibration tasks.
* **On-call rotation and escalation policy** — To correctly route alerts to the right team.
* **Data classification policy** — To verify that monitoring does not capture sensitive personal data.

---

## Outputs

**Primary outputs:**

* **Alert rules and notification routing** — Calibrated alert rules with severity levels, routing to on-call teams, and suppression windows.
* **Health dashboards** — Dashboards providing clear system health visibility with SLO burn rate indicators.
* **Runbook references linked to alert conditions** — Each alert must link to a runbook that enables a responder to act without needing to investigate from scratch.

---

## Preconditions

**Conditions that must be met before execution:**

* SLO definitions exist or are being established in parallel
* Metrics and log sources are available or instrumentation is planned
* On-call rotation and escalation policy is defined
* Data classification policy is available to validate PII exclusion from monitoring

**Validation checks:**

* [ ] SLO thresholds are defined and agreed
* [ ] Alert routing targets are configured and reachable
* [ ] No sensitive personal data captured in metrics or logs
* [ ] Runbooks exist or are being created for each alert condition

---

## Step-by-Step Execution Procedure

### Step 1: Audit Monitoring Coverage

**Questions to answer:**
- What failure modes exist for this service and are they all monitored?
- Are SLO burn rate alerts configured for user-facing services?
- Are there known blind spots from previous incidents?

**Actions:**
- [ ] Map critical failure modes to monitoring coverage — identify gaps
- [ ] Verify SLO error budget burn rate alerts are configured for user-facing services
- [ ] Review post-incident reports for monitoring gaps that allowed delayed detection
- [ ] Confirm infrastructure metrics (CPU, memory, disk, network) are covered alongside application metrics

**Red flags / Warning signs:**
- No SLO burn rate alerting — slow degradation can go undetected for hours
- Monitoring only on infrastructure metrics, not application-level signals (error rate, latency)
- Known failure modes from prior incidents with no corresponding alert

**Decision points:**
- If critical failure mode has no alert, classify as monitoring gap and communicate as business risk via PS-2.
- If SLO burn rate alerting is absent for a user-facing service, flag as HIGH priority gap.

---

### Step 2: Calibrate Alert Thresholds

**Questions to answer:**
- Are alert thresholds derived from SLO targets or arbitrarily set?
- Are current thresholds producing false positives (alert fatigue) or missing real failures?
- Are burn rate multipliers appropriate for the SLO window?

**Actions:**
- [ ] Derive alert thresholds from SLO targets — not arbitrary fixed values
- [ ] Review recent alert history for false positive rate
- [ ] Apply multi-window burn rate alerting for SLOs (fast burn + slow burn)
- [ ] Document threshold choices and sensitivity rationale via DT-1

**Red flags / Warning signs:**
- Thresholds set to fixed values not derived from SLOs (e.g. "alert if error rate > 5%" with no SLO reference)
- Alert history showing >20% false positive rate — teams will develop alert fatigue
- Single-window burn rate alerting only — misses slow degradation

**Decision points:**
- If threshold calibration changes are proposed, log rationale via DT-1.
- If alert fatigue is severe, escalate as business risk via PS-2 before reducing sensitivity.

---

### Step 3: Verify Data Privacy Compliance

**Questions to answer:**
- Do any metrics, logs, or traces capture personally identifiable information?
- Are log retention policies compliant with applicable regulations?
- Are monitoring dashboards access-controlled to prevent unauthorised PII exposure?

**Actions:**
- [ ] Review metric labels and log fields for PII (user IDs, email addresses, IP addresses where restricted, health data)
- [ ] Confirm log retention periods comply with data classification policy
- [ ] Verify monitoring dashboards have appropriate access controls
- [ ] Confirm trace data does not include request bodies containing sensitive data

**Red flags / Warning signs:**
- User identifiers in metric labels enabling individual tracking
- Request bodies or query parameters logged without sanitisation
- No log retention policy — data accumulated indefinitely

**Decision points:**
- If PII found in monitoring data, block and require remediation — CL-3 violation.
- If retention policy is absent, flag as compliance risk.

---

### Step 4: Verify Alert Routing and Runbook Coverage

**Questions to answer:**
- Is each alert routed to the correct on-call team?
- Does each alert link to a runbook that enables a responder to act?
- Are alert severity levels correctly classified?

**Actions:**
- [ ] Verify alert routing rules map to correct on-call rotation or escalation policy
- [ ] Confirm each alert has a linked runbook with diagnosis and remediation steps
- [ ] Review alert severity classification — CRITICAL for user-impacting, WARNING for degradation, INFO for awareness
- [ ] Verify suppression windows are appropriate — not silencing genuine incidents

**Red flags / Warning signs:**
- Alerts with no linked runbook — responder has no guidance on what to do
- All alerts classified as CRITICAL — severity inflation causes responders to treat all alerts as equal
- Suppression windows covering business-critical hours

**Decision points:**
- If alert has no runbook, classify as incomplete and require runbook creation before deployment.

---

### Step 5: Validate Instrumentation Deployment Alongside Application

**Questions to answer:**
- Is monitoring instrumentation included in the deployment pipeline alongside application changes?
- Will the new service have monitoring active from its first production deployment?

**Actions:**
- [ ] Verify monitoring instrumentation is in the deployment pipeline — not a post-deployment manual step
- [ ] Confirm alert rules and dashboards are version-controlled
- [ ] Validate that removing monitoring instrumentation requires the same review process as removing application code

**Red flags / Warning signs:**
- Monitoring instrumentation added manually post-deployment — creates a window of unmonitored production traffic
- Alert rules stored outside version control — not reviewable or auditable

---

### Final Step: Generate Monitoring & Alerts Report

```markdown
## Monitoring & Alerts Report

**Service:** [Service Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Coverage Assessment
| Failure Mode | Monitored | Alert | Runbook |
|---|---|---|---|
| High error rate | ✅ | ✅ | ✅ |
| Latency degradation | ✅ | ✅ | ✅ |
| SLO burn rate | ✅ | ✅ | ✅ |
| Disk saturation | ✅ | ⚠️ | ❌ Missing |

### Data Privacy
| Check | Status |
|---|---|
| No PII in metrics | ✅ |
| No PII in logs | ✅ |
| Retention policy set | ✅ |

### Skills Flagged
- **incident-response**: [Reason if flagged]
- **performance-optimization**: [Reason if flagged]

### Required Actions
- [ ] [Action if any]
```

---

## Core Responsibilities

1. Map all critical failure modes to monitoring coverage and identify gaps.
2. Derive alert thresholds from SLO targets; document rationale via DT-1.
3. Verify no PII is captured in metrics, logs, or traces.
4. Ensure every alert has a linked runbook and correct severity classification.
5. Ensure monitoring instrumentation is deployed alongside application changes, not added retroactively.

---

## Constraints (Rules Applied)

* **DD-1: CI/CD Enforcement** — Monitoring instrumentation must be included in the deployment pipeline alongside application changes; retroactive manual instrumentation is a compliance gap.
* **CL-3: Data Privacy** — Monitoring must not capture PII in metrics, logs, or traces; user identifiers in metric labels, request bodies in logs, and health data in traces are violations.
* **PS-2: Risk Communication** — Monitoring gaps must be communicated to stakeholders as business risk with concrete impact description, not just flagged internally.
* **DT-1: Explicit Tradeoff Logging** — Alert threshold choices represent a deliberate sensitivity decision; every threshold must be documented with its rationale (SLO derivation, false positive tolerance, business context).

---

## Tradeoff Handling

### Tradeoff 1: Alert Sensitivity vs Noise

**Conflict:** Low thresholds catch more issues but generate alert fatigue; high thresholds reduce noise but miss real degradation.

**Resolution:** Derive thresholds from SLO error budget burn rates, not arbitrary values; use multi-window burn rate (fast burn 1h + slow burn 6h) to catch both sudden and gradual failures; document threshold rationale via DT-1.

### Tradeoff 2: Monitoring Granularity vs Performance Overhead

**Conflict:** Fine-grained metrics provide better visibility but add collection and storage cost.

**Resolution:** Assess what granularity is actually needed for diagnosis vs nice-to-have; high-cardinality metrics require explicit business justification; log non-standard granularity decisions via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: PII Found in Monitoring Data

**Trigger:** PII detected in metric labels, log fields, or trace data.

**Action:**
- Block deployment of monitoring configuration immediately — CL-3 violation
- Report specific field or label containing PII without reproducing values
- Require sanitisation before monitoring can be deployed

---

### Escalation Scenario 2: Critical Monitoring Gap Identified

**Trigger:** A critical failure mode has no alert coverage and no plan to add it.

**Action:**
- Document gap via DT-1
- Communicate as business risk via PS-2 to stakeholders
- Flag incident-response to note the gap in active runbooks

---

### Escalation Scenario 3: Alert Fatigue — High False Positive Rate

**Trigger:** Alert history shows >20% false positive rate or on-call team reports ignoring alert class.

**Action:**
- Do not reduce alert sensitivity without documented justification via DT-1
- Propose threshold recalibration derived from SLO
- Escalate to stakeholders via PS-2 if alert fatigue is systemic

---

### When to halt execution:

* PII found in monitoring data — block until remediated
* Alert rules proposed without any runbook coverage — require runbooks before deploying
* Monitoring instrumentation proposed as post-deployment manual step — require pipeline inclusion

---

## Skill Integration & Orchestration

This skill runs at deployment time and reactively after incidents. It feeds Incident Response with detection capability and runbook links. It flags Performance Optimization when metrics reveal persistent performance degradation.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Active incident triggered by alert | incident-response | Response coordination needed |
| Persistent performance degradation in metrics | performance-optimization | Optimisation investigation needed |

---

## Related Skills

**Skills this skill depends on:** None — foundational operational skill.

**Skills this skill cooperates with:**
* **incident-response** — Provides the detection and runbook foundation that incident response depends on.
* **deployment-management** — Monitoring is deployed alongside application changes managed by this skill.
* **observability** (Phase 2) — Broader observability architecture feeds the instrumentation this skill deploys.

---

## Governance Hooks

* [ ] Block monitoring configurations that capture PII
* [ ] Document all alert threshold decisions via DT-1
* [ ] Communicate monitoring gaps as business risk via PS-2
* [ ] Require runbooks for all alert conditions before deployment
* [ ] Ensure monitoring is in the deployment pipeline, not a manual post-deployment step

---

## Example Use Cases

### Example 1: SLO-Based Alerting for a Payment API

**Scenario:** A payment API has a 99.9% availability SLO (43.8 minutes error budget per month). No SLO burn rate alerting exists — only a fixed "error rate > 5%" alert.

**Execution steps:**
1. Identify gap: fixed threshold alert does not protect the SLO error budget.
2. Design multi-window burn rate alerts: 1h window at 14x burn rate (CRITICAL), 6h window at 5x burn rate (WARNING).
3. Link both alerts to payment API runbook.
4. Document threshold derivation via DT-1.
5. Deploy alert rules as part of pipeline.

**Result:** PASS — SLO-derived alerting deployed.

---

### Example 2: PII Found in Request Logs

**Scenario:** A review of application logs reveals that a REST API is logging full request bodies, including user email addresses and partial payment card data.

**Execution steps:**
1. Detect PII in log fields — CL-3 violation.
2. Block logging configuration deployment immediately.
3. Report specific log fields containing PII without reproducing values.
4. Require log sanitisation (field masking or exclusion) before re-deployment.

**Result:** FAIL — CL-3 violation; blocked until remediated.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Alert thresholds set to arbitrary fixed values**
✅ **Correct approach:** Derive thresholds from SLO error budget burn rates. Fixed thresholds are disconnected from business reliability targets.

❌ **Anti-pattern 2: All alerts classified as CRITICAL**
✅ **Correct approach:** Use severity levels meaningfully — CRITICAL for immediate user impact, WARNING for degradation requiring attention, INFO for awareness. Severity inflation causes alert fatigue.

❌ **Anti-pattern 3: Alerts with no linked runbook**
✅ **Correct approach:** Every alert must link to a runbook. An alert without a runbook puts the responder in diagnosis mode at 3am — maximising MTTR.

❌ **Anti-pattern 4: Monitoring added manually after deployment**
✅ **Correct approach:** Monitoring instrumentation belongs in the deployment pipeline. A service deployed without monitoring has an unmonitored window in production.

❌ **Anti-pattern 5: Single-window burn rate alerting only**
✅ **Correct approach:** Use both fast-burn (short window, high multiplier) and slow-burn (long window, lower multiplier) alerts. Single-window alerting misses gradual degradation.

❌ **Anti-pattern 6: PII in metric labels or log fields**
✅ **Correct approach:** Metrics and logs must never contain personally identifiable information. Use anonymised identifiers, aggregate counts, or hashed values instead.

❌ **Anti-pattern 7: Alert routing to a generic inbox with no on-call ownership**
✅ **Correct approach:** Every alert must route to a specific on-call owner. Generic inboxes result in nobody taking ownership.

---

## Non-Goals

* ❌ Responding to active incidents — handled by Incident Response
* ❌ Application logging design within code — handled by Logging skill
* ❌ Performance profiling and root cause analysis — handled by Performance Optimization
* ❌ Observability architecture design — handled by Observability skill (Phase 2)
* ❌ Infrastructure provisioning for monitoring tools — handled by Infrastructure as Code

---
