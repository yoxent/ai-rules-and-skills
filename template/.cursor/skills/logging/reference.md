```yaml
---
name: logging
description: Implements structured, consistent logging across all system components to support debugging, auditing, compliance, and observability requirements without capturing sensitive data.
version: 1.0.0
category: Architecture
tags: [logging, structured-logs, audit-trail, compliance, debugging]
priority: Medium
depends_on: [system-design]
flags_skills: [observability, security, configuration, technical-debt-management]
inputs: [application-components, event-types, severity-levels, compliance-requirements, observability-strategy]
outputs: [logging-standards, retention-policies, structured-log-formats, centralized-logging-setup]
rules_applied:
  - CL-3   # Data Privacy
  - CL-1   # Regulatory Compliance
  - DA-1   # SOLID & Clean Code First
  - MF-5   # Reliability Rule
  - DT-1   # Explicit Tradeoff Logging
  - GM-4   # Behavioral Transparency
documents_needed: [system-architecture, compliance-requirements, observability-strategy]
execution_context: Runs after System Design and Observability strategy is defined, or when log inconsistency, missing audit trails, or compliance gaps are identified.
---
```

---

# Skill: Logging

---

## Purpose

**What this skill does:**
Logging defines and enforces a consistent, structured logging strategy across all system components. It specifies what events must be logged, at what severity level, in what format, with what retention policy, and with explicit rules preventing sensitive data from entering log streams.

Unstructured, inconsistent logs make incident diagnosis slow and expensive. Missing audit logs create compliance violations. Logs containing PII create regulatory liability. This skill prevents all three by making logging a first-class architectural concern rather than an afterthought added per-developer preference.

Structured logs are machine-parseable, queryable, and feed directly into observability pipelines. Consistent severity levels make alert routing reliable. Cross-service correlation IDs make distributed debugging tractable. Centralized log aggregation with defined retention eliminates the operational burden of per-service log management.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Observability strategy has been defined and requires log standardization
* System Design identifies components with compliance-mandated audit trail requirements
* Inconsistent log formats are identified across services during code review or incident response
* A security or compliance audit finds missing or insufficient audit logs
* A production incident cannot be diagnosed because logs are absent, unstructured, or too verbose
* A new service is being added to the system and needs logging standards defined before implementation

### Do NOT use this skill for:

* Designing the overall observability strategy (use Observability)
* Implementing log aggregation infrastructure provisioning (DevOps Phase 4)
* Active incident diagnosis using existing logs (use Bug Diagnosis or Incident Response)
* Application Performance Monitoring (APM) — that is part of Observability

---

## Inputs

**Required inputs:**

* **Application and service components** — The system's services and components needing logging standards applied.
* **Event types and severity levels** — The categories of events (request, error, audit, business event) and the severity taxonomy (DEBUG/INFO/WARN/ERROR/FATAL or equivalent).
* **Compliance and audit requirements** — Which regulations apply, and what their specific audit logging requirements are (e.g., GDPR data access logs, PCI transaction logs, SOC 2 authentication events).

**Optional inputs:**

* **Observability strategy** — From Observability skill. Logging must align with the broader observability stack (which log aggregator, which query language, what retention tiers).
* **Existing log samples** — Samples of current logs from the system. Used for gap analysis and format standardization.

---

## Outputs

**Primary outputs:**

* **Logging standards document** — The organization-wide log format specification: required fields, severity level definitions, correlation ID conventions, and field naming standards.
* **Centralized logging setup** — Architecture of the log aggregation pipeline: collection agents, aggregator (ELK, Loki, Datadog), transport (Fluentd, Vector), and query interface.
* **Log retention policies** — Per-log-category retention periods aligned with compliance requirements and cost constraints.
* **Structured log format examples** — Concrete JSON schema examples for each log category (request log, error log, audit event, business event).

---

## Preconditions

* System architecture is defined
* Compliance requirements are known
* Observability strategy exists (at minimum, which log aggregation platform will be used)

---

## Step-by-Step Execution Procedure

### Step 1: Define the Log Taxonomy

**Questions to answer:**
- What categories of events must be logged (request/response, errors, audit events, business events, system events)?
- What severity level maps to each category?
- What is the minimum required field set for each log category?

**Actions:**
- [ ] Define severity level semantics: DEBUG (development-only, never in production by default), INFO (normal operation), WARN (unexpected but recoverable), ERROR (failure requiring attention), FATAL (unrecoverable — service must restart)
- [ ] Define event categories and their required severity level
- [ ] Map compliance requirements to mandatory log categories (e.g., GDPR: data access/modification events; PCI: all CHD access; SOC 2: authentication events, privilege escalation)
- [ ] Specify which log categories are mandatory vs. optional per environment

**Red flags / Warning signs:**
- DEBUG logs enabled in production — severe performance overhead and PII risk
- No distinction between expected errors (user input validation) and unexpected errors (null pointer exceptions) — makes alerting on real errors impossible
- Missing audit log category for compliance-required events

---

### Step 2: Define the Structured Log Format

**Questions to answer:**
- What fields are required in every log entry (timestamp, service name, trace ID, severity, message)?
- What fields are category-specific (request logs: HTTP method, path, status code, latency; error logs: exception class, stack trace reference)?
- What format is used (JSON strongly preferred for machine parseability)?

**Actions:**
- [ ] Define the universal required field set for all log entries:
  - `timestamp` (ISO 8601, UTC)
  - `service` (canonical service name)
  - `severity` (standardized level)
  - `message` (human-readable summary)
  - `trace_id` (distributed trace correlation ID)
  - `span_id` (for trace correlation within a service)
  - `environment` (dev/staging/prod)
- [ ] Define per-category additional fields
- [ ] Prohibit free-form log messages that cannot be parsed programmatically
- [ ] Apply CL-3: define a field exclusion list — what must never appear in any log field

**Red flags / Warning signs:**
- No trace/correlation ID — distributed incidents cannot be correlated across services
- Log messages that embed structured data as string concatenation (unqueryable)
- No standard field for service name — logs cannot be filtered to a specific service

**Decision points:**
- If existing logs are entirely unstructured, the migration effort is significant — flag technical-debt-management for remediation planning

---

### Step 3: PII and Sensitive Data Audit

**Questions to answer:**
- Which proposed log fields could contain PII, credentials, or regulated data?
- Are there existing logs that already contain sensitive data?
- What masking or exclusion strategy applies to each sensitive field type?

**Actions:**
- [ ] Audit every proposed log field against data classification: could this ever contain PII, credentials, payment data, health data?
- [ ] Apply CL-3: define the explicit exclusion list (never log): passwords, tokens, full credit card numbers, SSNs, health identifiers, full email addresses in most contexts
- [ ] Define masking rules for partially sensitive fields: last 4 digits of card number acceptable; IP addresses may require anonymization under GDPR
- [ ] Scan existing log samples for known sensitive patterns (regex for credit card formats, email patterns, JWT tokens)

**Red flags / Warning signs:**
- Request body logged wholesale — request bodies frequently contain PII, credentials, or payment data
- Authorization header logged — contains bearer tokens that can be replayed for unauthorized access
- Stack traces containing object serializations that include field values with PII

**Decision points:**
- If sensitive data found in existing logs, flag security and assess breach notification obligation under applicable regulation

---

### Step 4: Retention Policy Design

**Questions to answer:**
- What retention period is required for each log category by applicable regulations?
- What retention period is operationally useful for debugging (beyond which logs have no diagnostic value)?
- What is the storage cost at projected log volume, and is tiered storage appropriate?

**Actions:**
- [ ] Map each log category to its compliance-mandated minimum retention (GDPR access logs: typically no specific mandate but subject to data minimization; PCI: 1 year minimum, 3 months immediately available; SOC 2: typically 1 year; HIPAA: 6 years)
- [ ] Define operational retention beyond compliance minimum where justified: application error logs typically useful for 30-90 days; DEBUG logs have zero retention (development only)
- [ ] Design tiered storage: hot (0-30 days, fast query), warm (30-90 days, slower query), cold (90 days+, archive — compliance only)
- [ ] Estimate log volume at projected request rate and validate storage cost is within budget

**Red flags / Warning signs:**
- Retention set to "indefinite" — GDPR data minimization requires justification for indefinite retention of logs containing personal data
- Compliance-required logs with retention shorter than the regulatory minimum — a compliance violation
- No tiered storage for high-volume services — hot storage for 1 year of debug logs is prohibitively expensive

---

### Step 5: Centralized Aggregation Architecture

**Questions to answer:**
- How do logs from all services flow to a central aggregation system?
- What collection agents are used (Fluentd, Vector, Filebeat)?
- What is the aggregation platform (ELK stack, Grafana Loki, Datadog, Splunk)?
- Are there multi-region or air-gapped environments requiring separate log routing?

**Actions:**
- [ ] Define the log collection pipeline: agent on each service → transport → aggregator → query interface
- [ ] Specify collection agent requirements (sidecar vs. daemonset for Kubernetes; file-based vs. stdout collection)
- [ ] Define access controls on the log aggregation system (not everyone should have access to all logs, especially audit logs with PII context)
- [ ] Verify aggregation platform is consistent with the observability tooling stack — avoid competing log systems

**Red flags / Warning signs:**
- Logs written to local disk only with no centralized collection — log loss on service restart
- No access controls on the log aggregation system — anyone with dashboard access can query all logs including sensitive audit events
- Multiple competing log aggregation systems introduced by different teams — fragmented observability

---

### Final Step: Generate Logging Standards Report

```markdown
## Logging Standards Report

**System:** [Name]  **Date:** [YYYY-MM-DD]  **Status:** ✅ / ⚠️ / ❌

### Log Taxonomy
| Category | Severity | Mandatory? | Compliance Requirement |
|----------|---------|------------|----------------------|
| [Category] | [Level] | [Yes/No] | [Regulation/None] |

### Universal Log Format (JSON Schema)
```json
{
  "timestamp": "ISO 8601 UTC",
  "service": "canonical-service-name",
  "severity": "INFO|WARN|ERROR|FATAL",
  "message": "human-readable summary",
  "trace_id": "hex string",
  "span_id": "hex string",
  "environment": "prod|staging|dev",
  "[category_fields]": "..."
}
```

### PII Exclusion List
| Field Type | Action | Replacement |
|-----------|--------|------------|
| [e.g., password] | Exclude | Never logged |
| [e.g., card number] | Mask | Last 4 digits only |

### Retention Policy
| Log Category | Compliance Min | Operational Target | Storage Tier |
|-------------|--------------|-------------------|-------------|
| [Category] | [Period] | [Period] | [Hot/Warm/Cold] |

### Aggregation Architecture
- Collection: [Agent]
- Transport: [Method]
- Aggregator: [Platform]
- Access controls: [Policy]

### Skills Flagged
- **[Skill]**: [Reason]

### Required Actions
- [ ] [Action with owner]
```

---

## Core Responsibilities

1. Define structured log format with universal required fields and per-category extensions
2. Establish severity level semantics and enforce category-to-severity mapping
3. Audit all log fields for PII and define the sensitive data exclusion list
4. Define retention policies per log category aligned with compliance requirements
5. Design centralized log aggregation pipeline with appropriate access controls
6. Identify observability gaps and compliance risks in existing log output

---

## Constraints (Rules Applied)

* **CL-3: Data Privacy** — Logs must never contain PII, credentials, or regulated data without explicit justification and masking. The exclusion list is non-negotiable.
* **CL-1: Regulatory Compliance** — Retention periods must meet compliance minimums. Missing audit log categories are compliance violations.
* **DA-1: SOLID & Clean Code First** — Logging is cross-cutting infrastructure; it must not be scattered ad hoc throughout business logic. A logging abstraction layer is required.
* **MF-5: Reliability Rule** — Log pipeline failures must not cause application failures. Logging must be non-blocking and degrade gracefully if the aggregation endpoint is unreachable.
* **DT-1: Explicit Tradeoff Logging** — Verbosity vs. performance and retention vs. cost tradeoffs must be documented.

---

## Tradeoff Handling

### Tradeoff 1: Verbosity vs. Performance

**Default stance:** INFO level in production. DEBUG never in production by default. ERROR and FATAL always.

If verbose logging is required for a specific debugging scenario, enable it for a bounded time window via configuration (flag **configuration**) and disable automatically — do not leave DEBUG permanently on in production.

### Tradeoff 2: Retention vs. Storage Cost

**Default stance:** Meet compliance minimums. Extend only where operational diagnostic value is demonstrated. Use tiered storage for cost efficiency rather than reducing retention below operational usefulness.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Sensitive Data in Existing Logs

**Trigger:** Scan of existing logs reveals PII, credentials, or regulated data in log fields.

**Action:** Flag **security** immediately. Assess whether regulatory breach notification is required. Rotate any leaked credentials. Block new deployments with the same logging pattern until fixed.

### Escalation Scenario 2: Missing Compliance-Required Audit Log

**Trigger:** A regulation requires logging of specific events (e.g., all PCI CHD access) but those events have no corresponding log.

**Action:** Document as a blocking compliance gap. Block production deployment approval until the audit log is implemented.

### Escalation Scenario 3: Log Pipeline Failure Causing Application Impact

**Trigger:** The logging pipeline (agent, transport, aggregator) failure is causing application threads to block or crash.

**Action:** Per MF-5, log writes must be non-blocking. Redesign logging to fire-and-forget with bounded queue. Flag **observability** to add logging pipeline health monitoring.

---

## Skill Integration & Orchestration

Logging runs after System Design and in concert with Observability. It produces the log format standards that all engineering skills must follow during implementation. It is upstream of incident diagnosis — without standardized logs, Bug Diagnosis and Incident Response are severely hampered.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|----------|------|--------|
| Log strategy reveals observability coverage gaps | observability | Monitoring strategy may need revision |
| PII found in log fields | security | Data privacy review and potential breach assessment |
| Log verbosity/retention settings need environment config | configuration | Environment-specific log config required |
| Existing logs too inconsistent to migrate incrementally | technical-debt-management | Systematic remediation plan needed |

---

## Related Skills

* **depends on: system-design** — component list and data flows are required to identify all logging points
* **cooperates with: observability** — Observability owns the monitoring strategy; Logging owns format and retention within that strategy
* **cooperates with: security** — Security defines audit log requirements; Logging implements capture and retention

---

## Governance Hooks

* [ ] Never log sensitive data without explicit masking or exclusion — CL-3 non-negotiable
* [ ] Verify compliance-required audit log categories are present before production approval
* [ ] Log pipeline must be non-blocking — logging failures must not impact application availability (MF-5)
* [ ] Document verbosity-vs-performance tradeoffs per DT-1
* [ ] Access controls on log aggregation system required — audit logs are sensitive by definition

---

## Example Use Cases

### Example 1: Standardizing Logs Across a Microservices Fleet

**Scenario:** 6 microservices each log differently — some use plain text, some use JSON with different field names, one logs authorization headers.

**Steps:**
1. Audit existing formats — identify the authorization header leak → flag security immediately
2. Define universal JSON schema with required fields
3. PII audit: request paths may contain user IDs — acceptable as opaque identifiers; query params may contain email addresses — exclude
4. Retention: application errors 90 days (hot 30 / warm 60), audit events 1 year, DEBUG not retained
5. Aggregate to Grafana Loki; collection via Vector sidecar

**Result:** ⚠️ NEEDS ATTENTION — Standards defined; auth header leak flagged to security; migration of existing services is technical debt

### Example 2: HIPAA Audit Trail Design

**Scenario:** A healthcare API must log all PHI access for HIPAA compliance (6-year retention).

**Steps:**
1. Mandatory audit events: every read/write/delete of PHI records with: who, what, when, from where
2. PHI fields never appear in log values — only record IDs (opaque)
3. Retention: 6 years minimum (HIPAA § 164.530(j)); cold archive after 90 days
4. Separate audit log stream with stricter access controls than application logs
5. Integrity protection: append-only log storage to prevent tampering

**Result:** ✅ COMPLETE — HIPAA audit trail defined with required retention and access controls

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Logging Sensitive Data**
Logging request bodies, auth headers, or user input wholesale. Almost always introduces PII or credential exposure.
✅ **Correct approach:** Whitelist what is logged, not blacklist. Define exactly which fields are captured; exclude everything else.

❌ **Anti-pattern 2: DEBUG in Production**
Leaving DEBUG logging enabled in production environments. Causes performance degradation, excessive storage cost, and PII risk.
✅ **Correct approach:** INFO is the production default. DEBUG is enabled only via configuration for bounded time-boxed diagnostic windows.

❌ **Anti-pattern 3: Unstructured String Logs**
Log messages constructed with string concatenation (`"User " + userId + " did " + action`). Not machine-parseable; query requires regex.
✅ **Correct approach:** Structured JSON with separate fields for each data point. The log message is a human summary; structured fields carry the queryable data.

❌ **Anti-pattern 4: No Correlation ID**
No trace or correlation ID in log entries. Incidents spanning multiple services require manually reconstructing call sequences from timestamps.
✅ **Correct approach:** Every log entry must include a correlation/trace ID. The ID is propagated across all service calls in the same request chain.

❌ **Anti-pattern 5: Logging as a Blocking Operation**
Log writes that can block the application thread if the log pipeline is slow or unavailable.
✅ **Correct approach:** Logging must be async and non-blocking with a bounded in-memory queue. A full queue drops the oldest log entries rather than blocking the application.

❌ **Anti-pattern 6: Indefinite Log Retention**
Retaining all logs forever "just in case." GDPR data minimization requires justification for retention beyond what is operationally or legally necessary.
✅ **Correct approach:** Define retention per category with compliance and operational justification. Implement automated deletion at retention boundary.

---

## Non-Goals

* ❌ **Overall observability strategy** — that is Observability's scope
* ❌ **Log aggregation infrastructure provisioning** — DevOps Phase 4
* ❌ **Active incident diagnosis using logs** — Bug Diagnosis or Incident Response

---

## Notes for LLM Implementation

1. **Audit first**: Before designing new logging standards, scan any existing logs for sensitive data. Remediation takes priority over standardization.
2. **Whitelist, don't blacklist**: When defining what to log, list what IS captured, not what IS NOT. Blacklists have gaps; whitelists have explicit scope.
3. **Compliance requirements are minimum floors**: Retention below the compliance minimum is a violation; above is a business decision.
4. **Non-blocking is non-negotiable**: Any logging design that could block application threads on log pipeline failure violates MF-5.
