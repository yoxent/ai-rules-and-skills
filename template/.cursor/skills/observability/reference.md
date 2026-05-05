```yaml
---
name: observability
description: Designs monitoring, distributed tracing, and alerting strategies to provide actionable visibility into system behavior and enable rapid fault detection and root-cause analysis.
version: 1.1.0
category: Architecture
tags: [observability, monitoring, tracing, alerting, slo]
priority: High

depends_on: [system-design]
flags_skills: [language-specific-implementation, logging, security, performance-optimization, incident-response, scalability]

inputs: [system-architecture, slo-definitions, critical-metrics, event-sources, compliance-requirements]
outputs: [monitoring-dashboards, alerting-rules, tracing-configuration, logging-strategy, slo-burn-rate-model]

rules_applied:
  - DD-1   # CI/CD Enforcement
  - CL-3   # Data Privacy
  - DT-1   # Explicit Tradeoff Logging
  - PS-2   # Risk Communication
  - MF-5   # Reliability Rule
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency

documents_needed: [system-architecture, slo-definitions, compliance-requirements, traffic-projections]

execution_context: Runs after System Design when instrumentation must be designed, or when Scalability or Security flag monitoring requirements, or when existing gaps leave the system unobservable in production.

---
```

---

# Skill: Observability

---

## Purpose

**What this skill does:**
Observability designs the three pillars of system visibility — metrics, logs, and distributed traces — into the architecture before deployment. It defines what to measure, how to alert on it, and how to trace requests across component boundaries so that production failures can be detected, diagnosed, and resolved within SLA windows.

An unobservable system is an unmanageable system. When production incidents occur, the difference between a 5-minute and a 5-hour resolution is almost always the quality of observability — engineers debugging blindly with no metrics or traces face the worst possible outcome.

Good observability transforms production debugging from guesswork to evidence-based investigation. Distributed traces eliminate the need to mentally reconstruct multi-service call chains. SLO-based alerting eliminates alert fatigue by signalling user-facing impact rather than infrastructure thresholds.

---

## When to Use This Skill

### Triggers:

* System Design has completed and instrumentation strategy has not been defined
* Scalability skill defines scaling triggers that require metric-based monitoring
* Security skill requires audit log instrumentation for compliance
* A new service or component is being deployed to production for the first time
* A post-mortem reveals observability gaps that prevented timely detection or diagnosis
* SLOs are being defined or revised for an existing system
* A distributed tracing gap is identified — cross-service requests cannot be correlated

### Do NOT use this skill for:

* Implementing logging within application code — use Logging for format standardization
* Active incident response and diagnosis — use Incident Response (Phase 4)
* Business intelligence or analytics dashboards — BI is a product concern
* Performance profiling at the code level — use Performance Optimization

**Execution Context:**
Observability runs after System Design, often co-triggered with Security and Scalability (both generate observability requirements). Its outputs feed the CI/CD pipeline (DD-1: instrumentation must be part of deployment, not added post-hoc) and the Logging skill (log format standardization). It is a prerequisite for reliable incident response.

---

## Inputs

**Required:**

* **System architecture** — Component map and data flow models. Required to determine instrumentation points and distributed trace propagation paths.
* **SLO definitions** — Service Level Objectives defining user-facing reliability targets. Without SLOs, alert thresholds are arbitrary infrastructure metrics rather than user-impact signals.
* **Critical metrics** — Business and technical metrics that matter most for this system; informed by the product team, SRE targets, and failure mode analysis.

**Optional:**

* **Compliance requirements** — When GDPR, HIPAA, or PCI apply, observability must avoid capturing sensitive data in metrics, traces, or logs (CL-3).
* **Traffic projections** — Helps determine volume and cardinality constraints (high-cardinality label explosion in Prometheus, log storage sizing).
* **Existing observability tooling** — Design should extend existing tooling where possible rather than introducing competing systems.

---

## Outputs

**Primary:**

* **Monitoring dashboard design** — What metrics to display, at what aggregation, for what audience; key metrics per component with alert thresholds.
* **Alerting rules and thresholds** — SLO-based burn rate alerts with severity levels, routing, and escalation paths.
* **Distributed tracing configuration** — Sampling strategy (head-based vs. tail-based), trace propagation headers, context propagation between services.
* **Logging strategy** — What events are logged at what verbosity level and how logs feed the broader observability stack. (Logging owns format standardization; Observability owns the strategy.)
* **SLO burn rate model** — Per SLO: error budget, burn rate alert thresholds (fast burn + slow burn), escalation response.

**Output format:** Each alerting rule includes metric/condition, threshold, for-duration, severity, routing, and runbook reference. Tracing configuration includes sampling rate, context propagation headers, and instrumented services. All outputs reference the specific SLO targets they protect.

---

## Preconditions

* System architecture is defined at the component level
* SLOs are defined (at minimum in draft form — can be refined, but must exist)
* Existing observability tooling inventory is known

**Validation checks:**

* [ ] Component map is available with inter-service communication paths
* [ ] At least draft SLOs exist for user-facing components
* [ ] Compliance requirements are known (to prevent sensitive data capture)

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:** At execution start, determine whether observability design involves code-level implementation.
- If yes → flag **language-specific-implementation** and co-invoke before planning begins
- If no (pure observability architecture/strategy design) → continue to Step 1

---

### Step 1: Define the Golden Signals per Component

**Actions:**
- [ ] For each component: define the four golden signals (latency, traffic, errors, saturation) with metric names and collection methods
- [ ] Identify which components are on the SLO critical path
- [ ] Map known failure modes to the metrics that would detect them
- [ ] Flag any failure mode with no corresponding detectable metric as an observability gap

**Watch-fors:** Critical-path component with no error rate or latency metric; infrastructure-only metrics (disk, CPU) with no user-facing impact metric; no metric for the most common failure mode of a component.

**Decisions:** If a failure mode cannot be detected by any defined metric, document as a gap and require a new metric or synthetic check before production deployment.

---

### Step 2: SLO and Error Budget Design

**Actions:**
- [ ] For each SLO: define the target (e.g., 99.9% availability = 43.8 min downtime budget/month)
- [ ] Design burn rate alerts: fast burn (5% of monthly error budget in 1 hour → page) and slow burn (10% in 6 hours → ticket)
- [ ] Verify SLO targets are realistic given the system architecture and known failure rates
- [ ] Define the SLO measurement methodology: what counts as a "good" request?

**Watch-fors:** SLO defined as 100% — unachievable, drives hiding failures. Alert thresholds at exact SLO boundary — SLO already breached when alert fires. No slow-burn alert — gradual degradation goes undetected.

**Decisions:** If SLO targets are unrealistically high (99.99%+ without active redundancy), document the gap and escalate to stakeholder for realistic target-setting.

---

### Step 3: Distributed Tracing Design

**Actions:**
- [ ] Define the trace propagation standard (W3C Trace Context, B3, OpenTelemetry)
- [ ] Identify all service-to-service communication paths requiring trace context propagation
- [ ] Design sampling strategy: 100% for critical paths (checkout, payment); probabilistic for high-volume routine paths; tail-based (all errors and slow requests) for cost efficiency
- [ ] Define required span attributes: service name, operation name, status code, error message, key business context — anonymized where required
- [ ] Apply CL-3: verify trace attributes do not capture PII (names, email, payment data)

**Watch-fors:** No trace context propagation between services — cross-service correlation impossible. 100% sampling on high-volume services — prohibitive cost; tail-based achieves similar diagnostic value. PII in trace attributes — privacy violation.

**Decisions:** If PII risk in traces exists, flag security before instrumentation. If trace volume would strain infrastructure, flag scalability for storage sizing.

---

### Step 4: Alert Design and Noise Reduction

**Actions:**
- [ ] Classify each alert by required response: page (immediate), ticket (business hours), informational (logged only)
- [ ] Use burn rate alerts over fixed threshold alerts where SLOs are defined
- [ ] Set `for:` duration on all alerts (e.g., `for: 5m`) to prevent transient-spike false positives
- [ ] Define alert routing: who receives what alert, through what channel
- [ ] Define alert suppression rules for known maintenance windows

**Watch-fors:** Alert fires and is silenced without investigation >10% of the time — poorly tuned. Every alert fires a page — alert fatigue. Alerts without runbook references — on-call has no guidance.

**Decisions:** Routinely silenced alerts should be re-evaluated: widen threshold, change from page to ticket, or remove if not actionable.

---

### Step 5: Observability Data Privacy Compliance

**Actions:**
- [ ] Audit proposed metric labels, trace attributes, and log fields for PII
- [ ] Apply CL-3: remove or anonymize any PII from observability data collection
- [ ] Define retention periods: metrics (13 months), traces (30–90 days), logs (per compliance requirement)
- [ ] Verify access controls on observability systems — dashboards and trace viewers can reveal user behavior

**Watch-fors:** User IDs or email in metric label values — high-cardinality PII violates privacy and breaks metric storage. Session tokens or payment data in trace attributes. No defined retention policy — indefinite retention of user behavioral data may violate GDPR.

---

### Final Step: Generate Observability Design Report

```markdown
## Observability Design Report

**System / Component:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ COMPLETE / ⚠️ GAPS IDENTIFIED / ❌ BLOCKED

### Golden Signals Coverage
| Component | Latency | Traffic | Errors | Saturation | SLO Critical Path? |
|-----------|---------|---------|--------|-----------|-------------------|
| [Name] | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | Yes/No |

### SLO Definitions
| SLO | Target | Error Budget (30d) | Fast-Burn Alert | Slow-Burn Alert |
|-----|--------|-------------------|----------------|----------------|
| [Name] | [99.9%] | [43.8 min] | [5% in 1h → page] | [10% in 6h → ticket] |

### Tracing Strategy
| Service | Sampling Strategy | Sampling Rate | Context Propagation |
|---------|-----------------|--------------|-------------------|
| [Name] | [Head/Tail/100%] | [Rate] | [W3C/B3/OTel] |

### Alert Inventory
| Alert | Condition | Severity | Response | Runbook |
|-------|-----------|----------|---------|---------|
| [Name] | [Condition] | [Page/Ticket/Info] | [Owner] | [Link] |

### Observability Gaps
| Gap | Component | Risk | Remediation |
|-----|-----------|------|-------------|
| [Description] | [Component] | [High/Med/Low] | [Action] |

### Privacy Compliance
| Data Type | PII Risk | Action Taken |
|-----------|---------|-------------|
| [Metric/Trace/Log] | [Yes/No] | [Removed/Anonymized/Accepted] |

### Skills Flagged for Follow-up
- **[Skill]**: [Specific reason]

### Overall Assessment
- ✅ COMPLETE: All critical paths instrumented, SLOs defined, no blocking gaps
- ⚠️ GAPS IDENTIFIED: Non-critical gaps logged for remediation
- ❌ BLOCKED: Critical failure modes undetectable — cannot deploy to production

### Required Actions
- [ ] [Action with owner and priority]
```

---

## Core Responsibilities

1. Define the four golden signals for every critical-path component
2. Design SLO-based alerting with fast-burn and slow-burn alert pairs
3. Design distributed tracing with appropriate sampling and context propagation
4. Audit observability data for PII and compliance violations (CL-3)
5. Identify observability gaps — failure modes with no corresponding detectable metric
6. Flag follow-on skills for logging standardization, security review, performance, and incident response

**Quality criteria:** Every critical-path component has all four golden signals; every SLO has fast-burn and slow-burn alert pairs; no known failure mode is undetectable; no PII in metric labels, trace attributes, or log fields; all alerts have runbook references.

---

## Constraints (Rules Applied)

* **DD-1: CI/CD Enforcement** — Observability instrumentation must be part of the deployment pipeline. A service deployed without instrumentation is unobservable until a subsequent deployment adds it.
* **CL-3: Data Privacy** — Metric labels, trace attributes, and log fields must not capture PII, PHI, PCI data, or credentials. Observability systems often have weaker access controls and longer retention than primary data stores.
* **DT-1: Explicit Tradeoff Logging** — Tradeoffs between observability granularity and performance/cost must be documented with rationale (e.g., "10% sampling because 100% would cost $X/month and tail-based captures all errors").
* **PS-2: Risk Communication** — Observability gaps must be surfaced as business risk. An undetected outage is customer-facing. Gaps leaving failure modes undetectable must be escalated.
* **MF-5: Reliability Rule** — Observability is a prerequisite for reliability. Systems that cannot be monitored cannot be reliably operated.

---

## Tradeoff Handling

### Granularity vs. Performance Overhead

**Scenario:** Fine-grained distributed tracing (100% sampling, detailed span attributes) provides maximum diagnostic value but adds latency and storage cost at high traffic volumes.

**Default stance:** Use tail-based sampling for high-volume services — capture 100% of errors and slow requests; sample routine successful requests probabilistically (1–10%).

**Resolution:** Estimate cost and latency impact of full sampling at projected volume. If tail-based sampling still has prohibitive cost, reduce attribute cardinality rather than sampling rate. Log the tradeoff per DT-1.

---

### Alert Sensitivity vs. Alert Fatigue

**Scenario:** Low thresholds detect more real issues but generate false positives; high thresholds reduce noise but let real issues go undetected longer.

**Default stance:** Use SLO burn rate alerts — empirically lower false positive rates while maintaining high sensitivity to user-facing failures.

**Resolution:** Define the SLO first, then derive burn rate thresholds (fast burn = 14.4× for 5% of budget in 1 hour). If burn rate alerting is not feasible, use fixed thresholds with `for:` duration guards (minimum 5 minutes). Review firing history after 30 days; tune any alert firing >20% of the time without a real incident.

---

### Observability Data Retention vs. Storage Cost

**Scenario:** Longer retention enables better trend analysis and debugging of intermittent issues but increases storage cost significantly.

**Default stance:** Default retention (metrics: 13 months; traces: 30–90 days; logs: per compliance requirement) covers most debugging and trend analysis at reasonable cost.

**Resolution:** Identify any specific retention requirement beyond defaults. For non-compliance-driven extended retention, quantify business value before accepting the cost. Consider tiered storage (hot/warm/cold). Log the retention decision per DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Critical Failure Mode Has No Observable Signal

**Trigger:** A known failure mode (e.g., downstream service timeout causing silent failures) would not be detected by any defined metric or alert.

**Action:** Document the gap with the specific failure scenario. For high-risk gaps: block production deployment until instrumented. For lower-risk gaps: log as known risk with a defined SLA for remediation. Flag **incident-response** — the gap represents unmanaged production risk.

---

### Escalation Scenario 2: PII Detected in Observability Data

**Trigger:** A proposed metric label, trace attribute, or log field contains PII or regulated data.

**Action:** Block the data collection implementation. Flag **security** for review. Require redesign (anonymize, pseudonymize, or remove the field). Do not permit deployment of instrumentation capturing PII without explicit compliance review.

---

### Escalation Scenario 3: SLOs Are Undefined or Unrealistic

**Trigger:** Alerting design cannot proceed — no SLOs exist, or stated SLOs are 100% availability or expressed as non-measurable requirements.

**Action:** Block alert design pending SLO definition. Provide a template for realistic SLO definition to the stakeholder. In the interim, instrument golden signals and flag PS-2 risk: system is unobservable until SLOs are defined.

---

### Escalation Scenario 4: Instrumentation Not in CI/CD Pipeline

**Trigger:** Observability instrumentation is planned to be added manually post-deployment rather than included in the deployment pipeline.

**Action:** Block this approach per DD-1. Require instrumentation to be added to the deployment definition before the service goes to production.

---

### When to halt execution:

* Critical-path failure modes have no observable signal and the gap cannot be closed before production
* PII is being collected in observability data and redesign has not been agreed
* No SLOs exist and no stakeholder commitment to define them before deployment

---

## Skill Integration & Orchestration

**Role in pipeline:** Runs after System Design, typically co-triggered with Scalability (scaling triggers need metrics) and Security (compliance audit logging). It is a prerequisite for production deployment of any critical-path component and informs the CI/CD pipeline (DD-1).

**Integration workflow:**
1. **Orchestrator** invokes Observability after System Design completes or when triggered by Scalability/Security flags
2. Skill designs golden signals, SLO alerting, distributed tracing, and log strategy
3. Skill **outputs flags** for logging, security, performance-optimization, incident-response, scalability
4. **Orchestrator** invokes flagged skills based on findings

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Log format standardization needed | logging | Structured log format and retention must align with observability strategy |
| PII risk in metrics or traces | security | Data privacy review required before instrumentation is deployed |
| Metrics reveal performance bottleneck | performance-optimization | Code-level investigation required for the identified bottleneck |
| Critical failure mode undetectable | incident-response | Gap must be escalated as known undetected production risk |
| Metric cardinality or log volume too high | scalability | Observability infrastructure scaling must be addressed |

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides the component architecture and data flows that observability must instrument. Without the system design, observability cannot determine what components exist or how they communicate.

**Skills this skill cooperates with:**

* **logging** — Observability defines the logging strategy (what to log, at what verbosity). Logging standardizes the format and retention. They are closely coupled and typically run together.
* **scalability** — Scalability defines autoscaling triggers; Observability designs the metric instrumentation those triggers rely on. They share the same metric definitions.
* **security** — Security defines audit logging requirements; Observability designs the broader monitoring strategy within which those audit logs exist.

**Skills this skill may flag:**

* **logging**, **security**, **performance-optimization**, **incident-response**, **scalability** — see Skills That May Be Flagged table.

---

## Governance Hooks

* [ ] Require instrumentation to be included in deployment pipelines per DD-1 — never post-deployment
* [ ] Audit all proposed observability data for PII compliance per CL-3 before approving
* [ ] Define SLO-based alerts, not just infrastructure threshold alerts
* [ ] Document all observability gaps as business risk per PS-2
* [ ] Log all granularity-vs-cost tradeoffs with sampling rationale per DT-1
* [ ] Block production deployment when critical-path failure modes are undetectable

---

## Example Use Cases

### General: Microservices Platform Observability Design

A platform of 8 microservices is being prepared for production with no observability beyond basic CPU/memory. Skill defines four golden signals for all services including Kafka consumer lag as a saturation signal. SLO 99.9% on checkout flow (spans 3 services) yields 43.8 min error budget; fast-burn and slow-burn alerts designed. OpenTelemetry adopted with 100% sampling for checkout, 5% probabilistic for product search, tail-based for remaining services. Email address proposed for search traces is rejected; security flagged. **Result:** ⚠️ GAPS IDENTIFIED — design complete, email-in-traces flagged to security. Skills flagged: logging (format standardization across 8 services), security (email in trace attributes).

### Edge Case: Redesigning Infrastructure Alerts to SLO Burn Rates

An existing system generates 15 pages/week with a 60% false positive rate from CPU and memory threshold alerts. SLO is 99.5% availability, p95 < 200ms (error budget: 219 minutes/month). Skill calculates fast-burn (page when 5% budget consumed in 1 hour) and slow-burn (ticket when 10% consumed in 6 hours), reclassifies existing infrastructure alerts as informational (no paging), and redesigns routing. Expected outcome: reduction from 15 pages/week to 2–3 actionable pages/week. Skills flagged: none.

---

## Anti-Patterns to Catch

❌ **Infrastructure Metrics Only:** Monitoring CPU, memory, and disk without measuring user-facing latency or error rates. Infrastructure can be healthy while users experience errors. ✅ Start with the four golden signals; infrastructure metrics are secondary context.

❌ **100% Trace Sampling on High-Volume Services:** Prohibitive storage cost and measurable latency overhead. ✅ Tail-based sampling captures all errors and slow requests at 5–10% of the cost of full sampling.

❌ **Fixed Threshold Alerting Without SLO Context:** Setting thresholds (error rate > 1%) without knowing what error rate is acceptable. ✅ Define the SLO first; derive alert thresholds from error budget burn rates.

❌ **Alert Without Runbook:** On-call engineer doesn't know what to do when the alert fires. ✅ Every alert definition must reference a runbook with: what this alert means, how to confirm it's real, and standard first-response actions.

❌ **PII in Metric Labels:** User IDs or email in label values causes cardinality explosion and violates data privacy. ✅ Metric labels must be low-cardinality aggregations. User-identifying information belongs in traces (with sampling and retention) and logs (with access controls).

❌ **Observability Added Post-Deployment:** "We'll add monitoring later" means production failures occur before later arrives. ✅ Per DD-1, observability instrumentation is part of the deployment definition — not ready for production without it.

❌ **Alert Fatigue from Over-Alerting:** Alerting on every anomaly trains engineers to ignore alerts. ✅ Every alert must be actionable — if the right response is "check tomorrow," it's a ticket, not a page. Review and demote alerts that generate no investigation.

❌ **Siloed Observability per Service:** Each service uses different metric formats, label conventions, and trace standards — cross-service correlation becomes impossible. ✅ Define organization-wide standards: metric naming, required label set, trace propagation format, log format. Flag logging for implementation.

---

## Non-Goals

* ❌ **Application log format implementation** — Logging skill owns log format standardization within application code.
* ❌ **Business intelligence and analytics dashboards** — BI dashboards serve product teams; Observability serves operational teams.
* ❌ **Active incident response** — Incident Response (Phase 4) uses observability outputs. Observability designs instrumentation; Incident Response operates it.
* ❌ **Performance profiling at code level** — Performance Optimization handles code-level profiling. Observability surfaces the signal; Performance Optimization investigates the cause.

---

## Notes for LLM Implementation

1. **Start with SLOs, not metrics:** Don't design alerts until SLOs are defined. If absent, request them before proceeding; instrument golden signals as an interim measure only.
2. **Design burn rate alerts by default:** For any component with a defined SLO, use SLO burn rate alerts. Only fall back to fixed thresholds when SLOs are genuinely undefined and cannot be defined.
3. **Enumerate failure modes explicitly:** For each component, ask "what are the ways this can fail?" and verify each has a detectable metric. An undetected failure mode is a production risk — document it as a blocking gap.
4. **Enforce CL-3 proactively:** Before approving any metric label, trace attribute, or log field, ask explicitly: "does this field ever contain user-identifying information?" Do not assume the answer is no.
5. **Be specific about sampling rates:** "We'll sample some traces" is not a strategy. Specify: tail-based at 100% for errors and slow requests (p99 > 2× baseline), X% probabilistic for routine requests, with cost rationale logged per DT-1.
