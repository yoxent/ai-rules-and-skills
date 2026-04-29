```yaml
---
name: incident-response
description: Coordinates detection, triage, remediation, and communication for system incidents to minimise business impact and user disruption.
version: 1.1.0
category: DevOps
tags: [incident, response, triage, remediation, postmortem]
priority: High

depends_on: [monitoring-alerts]
flags_skills: [rollback-management, infrastructure-as-code]

inputs: [monitoring-alerts, incident-severity, logs-metrics-traces, runbooks, escalation-policies]
outputs: [resolved-incident, incident-timeline, post-incident-review]

rules_applied:
  - MF-4
  - PS-2
  - DD-2
  - DT-1

documents_needed: [runbooks, escalation-policy, incident-severity-matrix, deployment-logs]

execution_context: Triggered by monitoring-alerts on active incidents; coordinates across skills for remediation; produces post-incident review.

---
```

---

# Skill: Incident Response

---

## Purpose

**What this skill does:**
Coordinates the full incident lifecycle — detection, triage, remediation, stakeholder communication, and post-incident review. It classifies incident severity, coordinates the right remediation actions, communicates status at appropriate intervals, and ensures every significant incident produces a root cause analysis that prevents recurrence.

Minimises the business impact of system failures through structured, fast response. Prevents communication chaos during incidents by establishing clear ownership and update cadence. Builds organisational learning through post-incident reviews that drive systemic improvements.

Provides a structured framework for decisions made under time pressure — reducing cognitive load and preventing mistakes caused by stress. Ensures decisions made during incidents (rollback vs forward-fix, escalation thresholds) are documented for future reference. Feeds monitoring improvements through gap identification.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A monitoring alert has triggered and an active incident is declared
* A system failure is detected through means other than alerting (customer report, manual observation)
* An incident is active and remediation is in progress
* A post-incident review needs to be conducted
* Incident severity classification needs to be established or revised
* Escalation policies or runbooks need to be reviewed or updated

### Do NOT use this skill for:

* Designing monitoring and alert rules — handled by Monitoring & Alerts
* Executing deployment rollbacks — handled by Rollback Management
* Root cause analysis of code defects — handled by Bug Diagnosis
* Infrastructure provisioning changes needed for remediation — handled by Infrastructure as Code

**Execution Context Details:**
This skill is triggered by Monitoring & Alerts when an alert fires, or directly when an incident is reported. It orchestrates Rollback Management (for deployment-related recovery) and Infrastructure as Code (for provisioning-related failures) as part of remediation.

---

## Inputs

**Required inputs:**

* **Monitoring alerts and incident severity classification** — The triggering alert, severity level, and initial impact assessment.
* **Logs, metrics, and traces from the incident window** — The observability data needed to diagnose and remediate.
* **On-call runbooks and escalation policies** — The documented response procedures for this type of incident.

**Optional inputs:**

* **Recent deployment log** — To assess whether the incident is deployment-related (most common cause).
* **Prior incident history** — To identify whether this is a recurring failure pattern.

---

## Outputs

**Primary outputs:**

* **Resolved or stabilised incident** — System returned to normal operation or stabilised at acceptable degraded state.
* **Incident timeline and impact report** — Chronological record of detection, triage steps, decisions, actions, and resolution.
* **Post-incident review and lessons-learned documentation** — Root cause analysis, contributing factors, and action items to prevent recurrence.

---

## Preconditions

**Conditions that must be met before execution:**

* Incident is declared and severity is classified
* On-call owner is identified and engaged
* Monitoring data (logs, metrics, traces) is accessible for the incident window
* Runbook for this incident type is available (or acknowledged as absent)

**Validation checks:**

* [ ] Incident severity classified using defined severity matrix
* [ ] On-call owner engaged and incident bridge established
* [ ] Monitoring data accessible for diagnosis
* [ ] Stakeholder communication cadence established per severity level

---

## Step-by-Step Execution Procedure

### Step 1: Triage and Classify Severity

**Questions to answer:**
- What is the user-facing impact and blast radius?
- Is this a deployment-related failure?
- What is the correct severity level?

**Actions:**
- [ ] Assess user-facing impact: how many users affected, what functionality is impaired
- [ ] Check recent deployment history — is this correlated with a recent deployment?
- [ ] Classify severity per defined matrix (SEV1: complete outage, SEV2: major degradation, SEV3: minor degradation, SEV4: no user impact)
- [ ] Engage correct on-call rotation based on severity
- [ ] Establish stakeholder communication cadence: SEV1 every 15min, SEV2 every 30min, SEV3 every 60min

**Red flags / Warning signs:**
- Incident correlated with a recent deployment — rollback should be first recovery option
- Blast radius larger than initially assessed — escalate severity
- No runbook for this incident type — document gap post-incident

**Decision points:**
- If deployment-related, flag rollback-management immediately as first recovery option.
- If severity is ambiguous, escalate — risk escalates, never decreases.

---

### Step 2: Communicate Status to Stakeholders

**Questions to answer:**
- Who needs to be informed and at what cadence?
- What is the current status and estimated time to resolution?
- Are there any customer-facing communications needed?

**Actions:**
- [ ] Send initial incident notification with: what is impacted, severity, who owns it, next update time
- [ ] Establish update cadence per severity level
- [ ] Identify if customer-facing status page update is needed
- [ ] Assign a dedicated communicator role for SEV1/SEV2 so the incident commander can focus on remediation

**Red flags / Warning signs:**
- No stakeholder updates for >30 minutes during active SEV1/SEV2 incident
- Technical jargon in stakeholder communications — communicate in business impact language
- Incident commander handling both communication and remediation — creates bottleneck

**Decision points:**
- If no communication has gone out within 15 minutes of SEV1 declaration, escalate communication immediately.

---

### Step 3: Diagnose and Remediate

**Questions to answer:**
- What is the likely root cause based on available signals?
- Is rollback the fastest path to stability?
- What is the remediation priority: stabilise first, investigate second?

**Actions:**
- [ ] Review monitoring data (error rate, latency, logs, traces) for the incident window
- [ ] Correlate with recent changes (deployments, config changes, infrastructure changes)
- [ ] For deployment-related incidents: flag rollback-management as first recovery option
- [ ] For infrastructure-related incidents: flag infrastructure-as-code for provisioning fixes
- [ ] Document all remediation decisions and actions taken via DT-1
- [ ] Prioritise stabilisation over investigation — restore service first, root cause second

**Red flags / Warning signs:**
- Team attempting deep root cause analysis before stabilising the service
- Multiple remediation attempts running in parallel without coordination — risk of conflicting changes
- No documentation of decisions made during response — loses institutional knowledge

**Decision points:**
- If rollback is chosen over forward-fix, flag rollback-management with incident context.
- If remediation attempts are not producing improvement after reasonable time, escalate severity.

---

### Step 4: Confirm Resolution and Stand Down

**Questions to answer:**
- Are all health checks passing and error rates back to baseline?
- Have all stakeholders been notified of resolution?
- Has the incident timeline been captured?

**Actions:**
- [ ] Confirm health checks passing and metrics back to pre-incident baseline
- [ ] Send resolution notification to all stakeholders with: what was resolved, duration, next steps
- [ ] Confirm monitoring-alerts is active and functioning post-resolution
- [ ] Capture complete incident timeline before standing down
- [ ] Schedule post-incident review within 48-72 hours

**Red flags / Warning signs:**
- Declaring resolution before metrics return to baseline
- Standing down without scheduling post-incident review
- Incident timeline not captured while details are fresh

---

### Step 5: Conduct Post-Incident Review

**Questions to answer:**
- What was the root cause?
- What contributing factors allowed the incident to occur or persist?
- What action items will prevent recurrence?

**Actions:**
- [ ] Conduct blameless post-incident review with all involved parties
- [ ] Document: timeline, root cause, contributing factors, what went well, what to improve
- [ ] Produce concrete action items with owners and due dates
- [ ] Identify monitoring gaps that delayed detection — flag monitoring-alerts
- [ ] Update runbooks based on learnings
- [ ] Track action items to completion

**Red flags / Warning signs:**
- Post-incident review focused on blame rather than systemic improvement
- Action items produced but never tracked to completion
- Recurring incident with same root cause — prior PIR action items not completed

**Decision points:**
- If recurring failure pattern detected, escalate action items to engineering leadership.

---

### Final Step: Generate Incident Report

```markdown
## Incident Response Report

**Service:** [Service Name]
**Severity:** [SEV1 / SEV2 / SEV3 / SEV4]
**Duration:** [HH:MM — detection to resolution]
**Date:** [YYYY-MM-DD]
**Status:** ✅ RESOLVED / ⚠️ STABILISED / ❌ ONGOING

### Timeline
| Time | Event |
|------|-------|
| HH:MM | Alert triggered |
| HH:MM | On-call engaged |
| HH:MM | Rollback initiated |
| HH:MM | Service restored |

### Root Cause
[Root cause statement — factual, blameless]

### Contributing Factors
- [Factor 1]
- [Factor 2]

### Action Items
| Action | Owner | Due Date |
|--------|-------|----------|
| [Action] | [Owner] | [Date] |

### Skills Flagged
- **monitoring-alerts**: [Gap identified]
- **rollback-management**: [If rollback was part of remediation]
```

---

## Core Responsibilities

1. Classify incident severity accurately and engage correct on-call owner immediately.
2. Communicate incident status to stakeholders at the cadence defined for the severity level.
3. Prioritise service stabilisation over root cause investigation during active incidents.
4. Document all decisions and actions taken during response via DT-1.
5. Conduct blameless post-incident review and produce tracked action items after every significant incident.

---

## Constraints (Rules Applied)

* **MF-4: Root Cause Analysis** — Every significant incident (SEV1, SEV2) requires a blameless post-incident review with documented root cause and action items; incidents without PIR allow the same failure to recur.
* **PS-2: Risk Communication** — Incident status and impact must be communicated to stakeholders in business language at the cadence defined for the severity level; silent incidents are a violation.
* **DD-2: Rollback Readiness** — For deployment-related incidents, rollback is the first recovery option to consider; forward-fix under time pressure often extends downtime.
* **DT-1: Explicit Tradeoff Logging** — Decisions made under incident time pressure (rollback vs forward-fix, severity escalation, remediation approach) must be documented; time pressure does not exempt this requirement.

---

## Tradeoff Handling

### Tradeoff 1: Response Speed vs Investigation Thoroughness

**Conflict:** Production incidents require fast stabilisation, but thorough investigation takes time.

**Resolution:** Phase 1: stabilise — restore service to acceptable state as fast as possible; Phase 2: investigate — root cause analysis after service is stable; document all decisions during both phases via DT-1.

### Tradeoff 2: Automation vs Human Intervention

**Conflict:** Automated remediation (auto-rollback on health check failure) is fast but may roll back for transient issues.

**Resolution:** Automated rollback is appropriate for clear health check failure persisting >N minutes; human review is required for ambiguous failures, novel failure modes, or multi-service impact; log all automated actions taken during incident via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Remediation Not Producing Improvement

**Trigger:** Remediation attempts are running but metrics are not improving after a reasonable window.

**Action:**
- Escalate severity level
- Bring in additional responders or domain experts
- Document attempted remediation steps and outcomes via DT-1

---

### Escalation Scenario 2: Rollback Not Available or Failing

**Trigger:** Deployment-related incident but rollback is not available or rollback-management reports failure.

**Action:**
- Switch to forward-fix path
- Escalate severity if estimated forward-fix time exceeds SLA
- Document rollback failure and reasons via DT-1

---

### Escalation Scenario 3: Post-Incident Review Not Scheduled

**Trigger:** Incident resolved but no PIR scheduled within 48 hours.

**Action:**
- Block incident closure
- Require PIR scheduling before marking incident as fully resolved
- Escalate to engineering lead if PIR is repeatedly deferred

---

### When to halt execution:

* Multiple conflicting remediation attempts running simultaneously — halt, coordinate, then proceed
* Rollback failing and forward-fix not available — escalate to engineering leadership immediately
* Data loss or corruption detected — halt all changes, escalate to data team

---

## Skill Integration & Orchestration

This skill is triggered by Monitoring & Alerts and orchestrates Rollback Management and Infrastructure as Code during remediation. It hands off to post-incident processes and flags monitoring gaps back to Monitoring & Alerts.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Deployment-related incident | rollback-management | Rollback is first recovery option |
| Infrastructure provisioning failure | infrastructure-as-code | Provisioning fix needed |

---

## Related Skills

**Skills this skill depends on:**
* **monitoring-alerts** — Provides detection capability and runbooks that trigger and guide incident response.

**Skills this skill cooperates with:**
* **rollback-management** — Executes deployment reversals during incident remediation.
* **infrastructure-as-code** — Applies infrastructure fixes for provisioning-related incidents.
* **monitoring-alerts** — Receives monitoring gap findings post-incident for instrumentation improvement.

---

## Governance Hooks

* [ ] Document all remediation decisions via DT-1 during the incident
* [ ] Communicate incident status to stakeholders at defined cadence
* [ ] Conduct blameless post-incident review after every SEV1/SEV2 incident
* [ ] Track PIR action items to completion
* [ ] Flag monitoring gaps identified during incident back to monitoring-alerts

---

## Example Use Cases

### Example 1: Deployment-Related SEV2 Incident

**Scenario:** A payment service deployment causes a 15% error rate increase. Alert fires. On-call engaged.

**Execution steps:**
1. Triage — correlate with deployment 20 minutes prior. Classify SEV2.
2. Communicate to stakeholders: "Payment service degradation, 15% errors, investigating, next update in 30 min."
3. Flag rollback-management — deployment-related, rollback is first option.
4. Rollback executes — error rate returns to baseline within 5 minutes.
5. Confirm resolution. Communicate to stakeholders.
6. Schedule PIR within 48 hours. Document missing env var as root cause.

**Result:** RESOLVED — 25 minutes total duration.

---

### Example 2: No Runbook for Novel Failure Mode

**Scenario:** Database connection pool exhaustion causes widespread API timeouts. No runbook exists for this failure mode.

**Execution steps:**
1. Triage — novel failure mode, no runbook. Classify SEV1.
2. Communicate immediately — user-facing impact.
3. Diagnose from metrics — connection pool at 100%, query latency spiking.
4. Remediate — increase pool size, restart affected services.
5. Resolve. Document: root cause (query not releasing connections), action items (fix leak, add pool saturation alert).
6. Flag monitoring-alerts — add connection pool saturation alert to prevent recurrence.

**Result:** RESOLVED. New runbook created. Monitoring gap flagged.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Investigating root cause before stabilising the service**
✅ **Correct approach:** Stabilise first, investigate second. A thorough root cause analysis is worthless if users are still impacted while it's being conducted.

❌ **Anti-pattern 2: No stakeholder communication during active incident**
✅ **Correct approach:** Send initial notification within 15 minutes of SEV1/SEV2 declaration. Silence is worse than uncertainty — stakeholders assume the worst.

❌ **Anti-pattern 3: Multiple remediation attempts running in parallel without coordination**
✅ **Correct approach:** One remediation action at a time. Parallel changes create conflicting state that is harder to diagnose and roll back.

❌ **Anti-pattern 4: Post-incident review focused on blame**
✅ **Correct approach:** Blameless PIRs. Systems and processes fail; individuals operate within the constraints the system provides. Focus on systemic improvement.

❌ **Anti-pattern 5: PIR action items produced but never tracked**
✅ **Correct approach:** Every action item needs an owner and a due date. Untracked action items ensure the same incident recurs.

❌ **Anti-pattern 6: Declaring resolution before metrics return to baseline**
✅ **Correct approach:** Resolution is confirmed by metrics, not by the cessation of remediation activity.

---

## Non-Goals

* ❌ Designing monitoring and alerting rules — handled by Monitoring & Alerts
* ❌ Executing rollbacks — handled by Rollback Management
* ❌ Root cause analysis of code defects — handled by Bug Diagnosis
* ❌ Infrastructure provisioning changes — handled by Infrastructure as Code

---
