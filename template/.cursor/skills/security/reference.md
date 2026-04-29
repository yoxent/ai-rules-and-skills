```yaml
---
name: security
description: Identifies and mitigates security vulnerabilities at the architectural level, enforcing authentication, authorization, encryption, and regulatory compliance across all system components.
version: 1.0.0
category: Architecture
tags: [security, authentication, authorization, encryption, compliance]
priority: High
depends_on: [system-design]
flags_skills: [system-design, observability, dependency-management, logging, incident-response]
inputs: [architecture-diagrams, compliance-requirements, threat-models, data-classification]
outputs: [security-controls, threat-mitigation-plan, access-control-strategy, encryption-standards]
rules_applied:
  - CL-1   # Regulatory Compliance
  - CL-3   # Data Privacy
  - CL-4   # Ethical Risk Flagging
  - DT-2   # Confirmation Gate
  - DT-1   # Explicit Tradeoff Logging
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency
documents_needed: [architecture-diagrams, compliance-requirements, threat-models, data-classification-policy]
execution_context: Runs during system design for new components handling sensitive data, or when security risks are flagged by other skills, dependency audits, or incident analysis.
---
```

---

# Skill: Security

---

## Purpose

**What this skill does:**
Security identifies and mitigates security vulnerabilities at the architectural level before implementation. It enforces authentication and authorization patterns, defines encryption standards for data at rest and in transit, ensures regulatory compliance (GDPR, HIPAA, PCI DSS), and produces threat mitigation strategies for the specific system design under review.

Security breaches carry severe financial, reputational, and legal costs. Proactive security architecture at design time is far cheaper than breach response and prevents the ineffective pattern of bolting security on after implementation.

Security concerns addressed at design time produce cleaner, more maintainable systems than security retrofitted onto existing code. Authentication boundaries, encryption layers, and access controls designed as first-class architecture concerns integrate naturally rather than wrapping existing logic with awkward patches.

---

## When to Use This Skill

### Triggers (Use this skill when):

* System Design identifies components that handle sensitive, personal, or regulated data
* A new authentication or authorization mechanism is being introduced
* Compliance requirements (GDPR, HIPAA, PCI DSS, SOC 2) apply to the system or a component
* A dependency audit (Dependency Management) flags known CVEs
* A new external integration introduces data flows that cross trust boundaries
* Incident analysis reveals a security vulnerability in the existing architecture
* A feature introduces new data collection, retention, or processing of personal data
* An API surface is being exposed to external consumers

### Do NOT use this skill for:

* Active security incident response (use Incident Response, Phase 4)
* Code-level security review of specific implementations (use Correctness Validation with security focus)
* Secrets rotation and operational key management (use Secrets Management, Phase 4)
* Dependency CVE remediation execution (use Dependency Management for identification; Refactoring for remediation)

**Execution Context Details:**
Security is a design-time skill that runs in parallel with or immediately after System Design when security-sensitive components are identified. It is frequently triggered by other skills (Dependency Management flags CVEs; Correctness Validation flags unsafe patterns; System Design flags data-handling components).

---

## Inputs

**Required inputs:**

* **Architecture diagrams** — Component map and data flow models from System Design. Essential for understanding what components exist, how they interact, and where data flows.
* **Compliance and regulatory requirements** — Applicable regulations (GDPR, HIPAA, PCI DSS, CCPA, SOC 2) and their specific requirements for the system. Without these, compliance controls cannot be designed correctly.
* **Data classification** — What categories of data the system handles: PII, PHI, payment card data, credentials, public data. Classification drives encryption and access control design.

**Optional inputs:**

* **Threat models** — Existing threat model documents (STRIDE, DREAD, PASTA) if available. Accelerates threat analysis rather than starting from scratch.
* **Existing security controls** — Current authentication, authorization, and encryption implementations. Required for gap analysis in existing systems.
* **External audit findings** — Penetration test results, security audit reports, or bug bounty findings. Provide validated threat intelligence for the specific system.

---

## Outputs

**Primary outputs:**

* **Security controls specification** — Specific controls for authentication (protocols, token types, session management), authorization (RBAC/ABAC, permission models, privilege levels), and data protection (encryption algorithms, key management approach, masking policies).
* **Threat mitigation plan** — For each identified threat: its likelihood and impact, the mitigating control, and the residual risk after the control is applied.
* **Access control strategy** — Who can access what, under what conditions, with what audit trail. Defines principal types, permission scopes, and escalation paths for privileged operations.
* **Encryption standards** — Algorithms, key lengths, key rotation policies, and key management approach for data at rest and in transit. References specific standards (AES-256, TLS 1.3, etc.).

**Output format:**

* Threat mitigation plan uses a risk matrix format (likelihood × impact)
* All controls are specific and implementable — not "use encryption" but "encrypt with AES-256-GCM, keys managed by [KMS], rotated every 90 days"
* Compliance mapping table shows which controls address which regulatory requirements

**Skill flags (if applicable):**

* Flag **system-design** when security requirements reveal that the system architecture must change (e.g., a component handling PCI data must be isolated into a separate trust boundary)
* Flag **observability** when security controls require audit logging and anomaly detection instrumentation
* Flag **dependency-management** when a dependency introduces a security vulnerability that was not previously known
* Flag **logging** when security events (authentication failures, authorization denials, data access) must be logged for audit trail or compliance
* Flag **incident-response** when an active or recently discovered vulnerability requires immediate operational response

---

## Preconditions

**Conditions that must be met before execution:**

* System architecture (component map and data flows) is available
* Applicable compliance requirements are known
* Data classification is defined — at minimum, which components handle sensitive data

**Validation checks:**

* [ ] Architecture diagrams identify all data flows, including external integrations
* [ ] Applicable compliance frameworks are identified
* [ ] Data categories handled by the system are classified

---

## Step-by-Step Execution Procedure

### Step 1: Data Classification and Trust Boundary Mapping

**Questions to answer:**
- What categories of sensitive data does the system process, store, or transmit?
- Where does each category of data flow across component boundaries?
- Which components cross trust boundaries (public internet, third parties, internal vs. external networks)?
- What regulatory regimes apply to each data category?

**Actions:**
- [ ] Enumerate all data categories in the system with their sensitivity classification (PII, PHI, PCI, credentials, public)
- [ ] Map each data category to the components that handle it
- [ ] Identify trust boundaries: public internet edge, internal service mesh, database tier, external integrations
- [ ] Annotate the architecture diagram with trust boundary lines and data classification labels

**Red flags / Warning signs:**
- Sensitive data flows crossing trust boundaries without explicit encryption
- PII or PHI data stored in components without access controls
- External integrations receiving data without explicit data classification of what is shared

**Decision points:**
- If a component handling PCI data shares a trust boundary with non-PCI components, escalate to system-design for isolation — PCI DSS requires scope reduction

---

### Step 2: Authentication Architecture

**Questions to answer:**
- How do users (human and machine) authenticate to the system?
- What authentication protocol is appropriate for each access pattern (browser, API, service-to-service)?
- How are credentials stored, validated, and rotated?
- What is the session management strategy (token expiry, refresh, revocation)?

**Actions:**
- [ ] Define the authentication protocol for each access pattern (OAuth 2.0 + OIDC for user-facing, mTLS or signed JWTs for service-to-service)
- [ ] Specify credential storage requirements (bcrypt/Argon2 for passwords, never plaintext, never MD5/SHA1)
- [ ] Define token lifetimes and refresh strategies (short-lived access tokens, longer-lived refresh tokens with revocation)
- [ ] Verify no authentication bypass paths exist in the component design

**Red flags / Warning signs:**
- Custom authentication implementation instead of established protocols — almost always introduces vulnerabilities
- Long-lived tokens without revocation capability — a compromised token remains valid indefinitely
- Password storage using reversible encryption or weak hashing (MD5, SHA1)
- Service-to-service authentication using shared static secrets without rotation

**Decision points:**
- Custom auth protocol proposed → block → require OAuth 2.0/OIDC or equivalent established standard
- Static shared secrets for service auth → flag for mTLS or signed JWT replacement

---

### Step 3: Authorization Design

**Questions to answer:**
- What permission model is appropriate: RBAC (role-based), ABAC (attribute-based), or policy-based?
- What is the principle of least privilege applied to each principal type?
- How are permissions granted, modified, and revoked?
- Are there privileged operations that require elevated authorization (multi-factor, time-bounded, audited)?

**Actions:**
- [ ] Define principal types and their permission scopes (users, service accounts, admin roles, read-only roles)
- [ ] Apply least privilege: start with no permissions, grant only what is demonstrably required
- [ ] Identify privileged operations and define their authorization requirements (re-authentication, approval workflow, time-bounded elevation)
- [ ] Define the authorization enforcement point — where in the request path is authorization checked?

**Red flags / Warning signs:**
- Authorization checked only at the API gateway, not at the service level — a compromised internal service can bypass gateway-level controls
- Permissions granted to roles, not verified per-request — stale permissions from a role change remain effective
- Admin functionality accessible from the same surface as user functionality without isolation
- No audit trail for permission changes

**Decision points:**
- Authorization enforcement only at gateway level → require defense-in-depth with service-level checks
- Admin access not isolated → escalate to system-design for admin interface separation

---

### Step 4: Encryption Design

**Questions to answer:**
- What data must be encrypted at rest? At what granularity (field, row, table, volume)?
- What protocols and cipher suites are required for data in transit?
- What is the key management strategy (envelope encryption, KMS, HSM)?
- What is the key rotation policy and how are rotations executed without downtime?

**Actions:**
- [ ] Define encryption requirements per data classification tier (PCI: AES-256 minimum; GDPR PII: encryption + pseudonymization)
- [ ] Specify TLS version requirements (TLS 1.3 preferred; TLS 1.2 minimum; TLS 1.0/1.1 prohibited)
- [ ] Define key management approach: keys must never be stored alongside the data they protect
- [ ] Specify key rotation frequency and automated rotation strategy
- [ ] Identify data that requires field-level encryption vs. volume-level (e.g., SSNs require field-level; log files may only require volume-level)

**Red flags / Warning signs:**
- Encryption keys stored in the same database as the encrypted data
- TLS 1.0 or 1.1 still supported — known vulnerabilities, prohibited by PCI DSS v4.0
- No key rotation policy — keys that never rotate create permanent exposure if compromised
- Sensitive data in logs, even in encrypted storage — log aggregation systems may not apply the same encryption

**Decision points:**
- Encryption keys co-located with data → require key management separation (KMS, Vault, HSM)
- TLS 1.0/1.1 in scope → block deployment until deprecated

---

### Step 5: Regulatory Compliance Mapping

**Questions to answer:**
- Which specific controls are required by each applicable regulation?
- Which controls are already addressed by the architecture? Which are gaps?
- Are there data residency requirements that constrain architectural choices?
- Are there data retention and deletion requirements that must be designed for?

**Actions:**
- [ ] Map each applicable regulation to its specific technical requirements (GDPR Article 32: encryption, pseudonymization, access controls, breach notification within 72 hours; PCI DSS: CHD isolation, encryption, vulnerability scanning)
- [ ] Produce a compliance gap analysis: which requirements are covered, which are gaps
- [ ] Apply CL-1: ensure all data-touching components comply with applicable regulations
- [ ] Apply CL-4: flag any architectural decision that introduces unacceptable regulatory risk for stakeholder approval

**Red flags / Warning signs:**
- GDPR applies but no data subject rights mechanism exists (right to access, right to deletion) — these require architectural support, not just policy
- PCI scope includes components that do not need to handle CHD — scope creep increases audit burden without business reason
- Data residency requirement (EU data in EU infrastructure) with no enforcement mechanism in the architecture

**Decision points:**
- Compliance gap identified → document as blocking requirement → escalate for resolution before production
- PCI scope too broad → flag system-design for CHD isolation and scope reduction

---

### Final Step: Generate Security Report

```markdown
## Security Report

**System / Component:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ APPROVED / ⚠️ CONDITIONAL / ❌ BLOCKED

### Data Classification Summary
| Data Category | Components | Regulatory Regime | Encryption Required |
|---------------|-----------|------------------|-------------------|
| [Category] | [Components] | [GDPR/HIPAA/PCI] | [Yes/No + standard] |

### Trust Boundary Map
[Component diagram with trust boundary annotations]

### Authentication Controls
| Access Pattern | Protocol | Token Lifetime | Revocation |
|---------------|---------|---------------|-----------|
| [Pattern] | [Protocol] | [Duration] | [Strategy] |

### Authorization Model
| Principal Type | Permission Scope | Enforcement Point | Audit Trail |
|---------------|-----------------|------------------|-------------|
| [Principal] | [Scope] | [Where] | [Yes/No] |

### Encryption Standards
| Data | At Rest | In Transit | Key Management | Rotation |
|------|---------|-----------|---------------|---------|
| [Category] | [Standard] | [TLS version] | [KMS/Vault] | [Frequency] |

### Threat Mitigation Plan
| Threat | Likelihood | Impact | Control | Residual Risk |
|--------|-----------|--------|---------|--------------|
| [Threat] | [H/M/L] | [H/M/L] | [Control] | [Acceptable?] |

### Compliance Gap Analysis
| Regulation | Requirement | Status | Action Required |
|-----------|------------|--------|----------------|
| [Reg] | [Requirement] | ✅/❌ | [Action] |

### Skills Flagged for Follow-up
- **[Skill]**: [Specific reason]

### Overall Assessment
- ✅ APPROVED: All controls defined, no blocking gaps
- ⚠️ CONDITIONAL: Controls defined with documented open items requiring resolution
- ❌ BLOCKED: Security gaps that prevent production deployment

### Required Actions
- [ ] [Action with owner and regulatory reference]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Map sensitive data flows and classify data against regulatory requirements
2. Define authentication architecture for all access patterns
3. Design authorization model with least-privilege enforcement
4. Specify encryption standards for data at rest and in transit with key management
5. Produce compliance gap analysis against applicable regulations
6. Generate threat mitigation plan with residual risk assessment

**Quality criteria:**

* Every control is specific and implementable — not "use strong encryption" but a named algorithm, key length, and key management approach
* Every compliance requirement is either addressed by a specific control or documented as a gap requiring remediation
* No sensitive data flow is unencrypted in transit across a trust boundary
* Every threat has a stated control and residual risk assessment

---

## Constraints (Rules Applied)

### Compliance & Legal Rules

* **CL-1: Regulatory Compliance**
  - All data-touching components must comply with applicable regulations — non-compliance is a blocking violation, not a tradeoff. Produce an explicit control-to-requirement mapping; claims of compliance without it are unacceptable.

* **CL-3: Data Privacy**
  - Enforce encryption and access controls on all sensitive data. PII must be encrypted at rest and in transit. Access must be logged. Retention limits must be enforced.

* **CL-4: Ethical Risk Flagging**
  - Flag architectural decisions that introduce unacceptable security risk, even if they are technically possible and not explicitly prohibited by regulations. Risk must be surfaced for stakeholder awareness and approval.

### Decision & Tradeoff Rules

* **DT-2: Confirmation Gate**
  - Any security tradeoff (accepting a weaker control for performance reasons, deferring a compliance requirement) requires explicit stakeholder approval before acceptance. Security tradeoffs are never silently resolved.

* **DT-1: Explicit Tradeoff Logging**
  - All security decisions — including decisions to accept residual risk — must be logged with the risk assessment, the alternatives considered, and the approval authority.

### Global Meta-Rules

* **GM-2: Explain Before Acting**
  - For any architectural recommendation that has security implications (isolation, access control changes, encryption additions), explain the threat being mitigated and the cost of not mitigating it.

* **GM-4: Behavioral Transparency**
  - Security assessments must be based on the actual architecture, not assumptions. If a data flow is unknown, state that — do not assume it is safe.

---

## Tradeoff Handling

### Tradeoff 1: Security vs. Usability

**Scenario:** Strict security controls (MFA required for every action, short session expiry, re-authentication for sensitive operations) degrade user experience.

**Default stance:** Apply the minimum necessary friction to achieve the security requirement. Security that drives users to workarounds (writing down MFA codes, sharing passwords) is counter-productive.

**Resolution process:**
1. Identify the specific threat the friction addresses
2. Evaluate risk-based alternatives (MFA only on new devices, re-auth only for high-risk operations)
3. Escalate to stakeholder per DT-2 if the tradeoff involves a compliance requirement
4. Log the decision per DT-1

---

### Tradeoff 2: Security vs. Performance

**Scenario:** Encryption overhead, token validation latency, and TLS handshake cost add measurable latency to request processing.

**Default stance:** Security requirements take priority over performance unless the performance impact breaches a specific SLA. Optimize within the security constraint; do not weaken the security constraint for performance.

**Resolution process:**
1. Measure the performance impact of the security control (not assumed — measured)
2. If the impact breaches an SLA: evaluate implementation optimizations (session caching, connection pooling, hardware encryption acceleration) before weakening the control
3. If optimizations are insufficient and the SLA is breached: escalate to DT-2 — this is a business priority decision
4. Log per DT-1

---

### Tradeoff 3: Compliance Scope Minimization vs. Feature Richness

**Scenario:** A feature could be built using regulated data (PCI, PHI) for richer functionality, but including regulated data expands compliance scope significantly.

**Default stance:** Minimize compliance scope by design. If the feature can be delivered without regulated data, deliver it that way. Compliance scope expansion is a significant and ongoing cost.

**Resolution process:**
1. Evaluate whether regulated data is genuinely required for the feature
2. If it can be delivered with pseudonymized or anonymized data, prefer that approach
3. If regulated data is required, scope the compliance expansion explicitly and estimate its cost
4. Escalate to stakeholder per DT-2 for scope expansion decisions

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Component Requires Architectural Isolation for Compliance

**Trigger:** A component handling regulated data (PCI CHD, HIPAA PHI) shares a trust boundary with non-regulated components, creating unacceptable compliance scope expansion.

**Action:**
- Flag system-design for component isolation
- Block production deployment until isolation is designed and implemented
- Document the specific regulatory requirement requiring the isolation

---

### Escalation Scenario 2: Custom Authentication Protocol Proposed

**Trigger:** A design proposes implementing custom authentication or cryptographic protocols rather than using established, audited standards.

**Action:**
- Block the proposal immediately
- Explain the risk: custom crypto/auth implementations almost universally contain vulnerabilities that established protocols (OAuth 2.0, TLS) have had years to discover and fix
- Require replacement with a vetted standard
- Escalate to DT-2 if the team insists on proceeding — this requires explicit business risk acceptance

---

### Escalation Scenario 3: Compliance Gap Cannot Be Addressed Architecturally

**Trigger:** A regulatory requirement cannot be satisfied by architectural controls alone — it requires process, policy, or organizational change (e.g., GDPR data subject rights process).

**Action:**
- Document the gap explicitly
- Identify whether it is a blocking or non-blocking gap for production deployment
- Escalate to stakeholder for non-technical remediation planning
- Do not mark as resolved without evidence of remediation

---

### Escalation Scenario 4: Active Vulnerability Discovered

**Trigger:** Security analysis reveals a vulnerability that may be currently exploitable (not just a design risk).

**Action:**
- Escalate to incident-response immediately
- Do not continue design work until the active vulnerability is contained
- Log the discovery per DT-1

---

### When to halt execution:

* An active, exploitable vulnerability is discovered — halt and escalate to incident-response
* A compliance-blocking gap exists that cannot be resolved architecturally — halt production approval
* A custom cryptographic or authentication protocol is proposed — halt until replaced with a standard

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Security runs as a gate for any component that handles sensitive data or crosses trust boundaries. It is invoked by System Design, Dependency Management, and Correctness Validation when security concerns are identified. Its outputs inform implementation decisions across all engineering skills and observability design.

### How This Skill Integrates

**Does NOT directly call other skills.** This skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes Security when triggered by system design, dependency CVEs, or explicit security review requests
2. Skill performs data classification, threat analysis, authentication/authorization design, encryption specification, and compliance mapping
3. Skill **outputs flags** for system-design (isolation), observability (audit logging), logging (security events), etc.
4. **Orchestrator** invokes flagged skills based on findings
5. Flagged skills implement the security controls in their respective domains

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|-------------------|-----------------|---------|
| Architecture must change for compliance isolation | system-design | Trust boundary redesign required |
| Security events need audit log instrumentation | observability | Monitoring for auth failures, anomalies, intrusion detection |
| CVE found in dependency | dependency-management | Vulnerability must be patched or mitigated |
| Security events (auth failures, access denials) must be logged | logging | Compliance-grade audit trail required |
| Active or recently discovered vulnerability | incident-response | Immediate operational response required |

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides the architecture that Security analyzes. Without the component map and data flow model, security controls cannot be designed correctly.

**Skills this skill cooperates with:**

* **observability** — Security controls require monitoring: authentication anomaly detection, authorization failure rates, and data access patterns all require observability instrumentation. Security defines what to monitor; Observability designs the instrumentation.
* **logging** — Security event logging (authentication, authorization, data access) is a compliance requirement in most regulatory frameworks. Security defines the events; Logging implements the capture and retention.

**Skills this skill may invoke/flag:**

* **system-design** — When compliance requires architectural isolation
* **observability** — When security controls require monitoring and anomaly detection
* **dependency-management** — When CVEs are discovered during security review
* **logging** — When audit trail requirements need implementation
* **incident-response** — When active vulnerabilities are discovered

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Apply CL-1: verify every data-touching component against applicable regulations — no exceptions
* [ ] Apply CL-4: flag all architectural decisions that introduce unacceptable security risk before proceeding
* [ ] Apply DT-2: every security tradeoff requires explicit stakeholder approval — never resolved silently
* [ ] Never accept custom authentication or cryptographic protocol implementations
* [ ] Produce a compliance gap analysis for every regulated system — not a narrative claim of compliance
* [ ] Log all residual risk acceptance decisions per DT-1 with approval authority documented

**Audit trail requirements:**

* All identified threats and their mitigations must be documented (even accepted risks)
* All compliance gaps must be logged whether resolved or outstanding
* All security control decisions must be traceable to specific regulatory requirements or threat scenarios
* All deferred or accepted security risks require documented stakeholder approval

---

## Example Use Cases

### Example 1: GDPR-Compliant SaaS Platform Architecture

**Scenario:** A B2B SaaS platform collects and processes EU customer data including names, email addresses, and usage analytics. GDPR applies. New features are expanding data collection.

**Inputs provided:**
- Architecture: API gateway, user service, analytics service, PostgreSQL, S3 for exports
- Data: user PII (name, email, IP), behavioral analytics, exported reports
- Compliance: GDPR applies (EU users); SOC 2 Type II target

**Execution steps:**
1. Data classification: PII (name, email, IP) in user service and analytics — GDPR Article 32 applies; analytics data must be pseudonymized where possible
2. Authentication: OAuth 2.0 + OIDC via Auth0, JWTs with 1-hour expiry, refresh tokens revocable
3. Authorization: RBAC — tenant isolation enforced at service level, not just API gateway; admin role isolated to separate service endpoint
4. Encryption: PII at rest encrypted with AES-256 (field-level for email, SSO tokens); TLS 1.3 in transit
5. GDPR gap: no data subject rights implementation (right to access, right to erasure) — blocking gap requiring architectural support (deletion cascade across user service and analytics)
6. Data residency: EU users' data must remain in EU — requires region-specific deployment or data routing enforcement

**Result:** ⚠️ CONDITIONAL — Core controls defined; data subject rights implementation and residency enforcement are blocking gaps

**Skills flagged:** system-design (data residency requires deployment architecture change), logging (GDPR audit trail for data access required), observability (authentication anomaly detection needed)

---

### Example 2: PCI DSS Scope Reduction

**Scenario:** An e-commerce platform currently processes credit card data directly, placing the entire application in PCI scope. Team is evaluating moving to a hosted payment page to reduce scope.

**Inputs provided:**
- Architecture: monolith including payment processing
- Compliance: PCI DSS v4.0 applies (currently full SAQ D scope)
- Proposed change: redirect to hosted payment page, store only tokenized card references

**Execution steps:**
1. Current state: entire application in PCI scope — encryption, vulnerability scanning, access controls required across all components. High compliance burden.
2. Proposed state analysis: hosted payment page means cardholder data never touches application servers. PCI scope reduces to SAQ A (redirect model) — dramatically lower burden.
3. Security controls for tokenized references: tokens are non-sensitive but must be protected against abuse (order manipulation, token theft)
4. New attack surface: redirect flow can be hijacked (open redirect vulnerability, CSRF). Controls required: CSRF tokens, redirect URL allowlist, HTTPS enforcement.
5. Residual PCI obligation: even with SAQ A, merchant must ensure the payment provider is PCI compliant (contractual requirement).

**Result:** ✅ APPROVED (with conditions) — Scope reduction approved; open redirect and CSRF controls must be implemented; payment provider PCI compliance must be contractually confirmed

**Skills flagged:** system-design (payment flow architecture change), logging (payment events must be logged for dispute resolution)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Security as an Afterthought**
Designing a system to full implementation before conducting a security review. By this point, security gaps require expensive refactoring rather than architectural adjustment.
✅ **Correct approach:** Security review runs in parallel with or immediately after System Design — before implementation begins. Cost of fixing security in design: hours. Cost of fixing in production: weeks.

❌ **Anti-pattern 2: Custom Authentication Implementation**
Building a bespoke authentication system because the team believes they know better than OAuth 2.0, OIDC, or SAML. Custom auth implementations almost universally introduce vulnerabilities.
✅ **Correct approach:** Use established, audited authentication protocols without modification. OAuth 2.0 + OIDC is the current industry standard. Deviations from standard protocols require explicit justification and security review.

❌ **Anti-pattern 3: Authorization Only at the Gateway**
Enforcing authorization only at the API gateway or load balancer, not at individual services. A compromised internal service or misconfigured network rule can bypass gateway-level controls.
✅ **Correct approach:** Defense in depth: enforce authorization at every trust boundary, including at the service level. An internal service call must still validate that the caller has permission for the requested operation.

❌ **Anti-pattern 4: Encryption Keys Stored with Encrypted Data**
Storing encryption keys in the same database, file system, or environment as the data they protect. This renders encryption ineffective against a database breach.
✅ **Correct approach:** Keys must be managed by a dedicated key management service (AWS KMS, HashiCorp Vault, Azure Key Vault). Keys and data are never co-located.

❌ **Anti-pattern 5: Treating Compliance as a Checkbox**
Producing a compliance document that claims requirements are met without mapping each requirement to a specific, verifiable control. "We're GDPR compliant" is not an architectural statement.
✅ **Correct approach:** Produce an explicit compliance matrix mapping each requirement to a specific technical control. Controls are verifiable, not claimed.

❌ **Anti-pattern 6: Sensitive Data in Logs**
Logging request bodies, response payloads, or error messages that contain PII, payment data, or credentials. Log aggregation systems often have weaker access controls than the primary data store.
✅ **Correct approach:** Logging must explicitly exclude sensitive fields. Implement structured logging with field-level exclusion for classified data categories. Logging skill must be flagged when sensitive data flows near log output.

❌ **Anti-pattern 7: Overly Broad PCI Scope**
Including components that do not handle cardholder data within PCI scope because it is easier than isolating them. Each component in scope increases audit burden without business reason.
✅ **Correct approach:** Minimize PCI scope by design. Use tokenization, hosted payment pages, and CHD isolation to keep scope as small as possible. Each component added to scope must be justified.

❌ **Anti-pattern 8: Stale Permission Models**
Permission models that do not account for role changes, employee departures, or service account lifecycle. Permissions granted are rarely revoked promptly.
✅ **Correct approach:** Design the permission lifecycle explicitly: how are permissions granted, reviewed (periodic access review), and revoked? Permissions should expire by default and require active renewal for continued access.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ **Active security incident response** — Incident Response (Phase 4) handles live security events.
* ❌ **Code-level security vulnerability scanning** — Specific implementation vulnerabilities (SQL injection, XSS) are Correctness Validation concerns within engineering review, not architectural security design.
* ❌ **Secrets rotation and operational key management** — Secrets Management (Phase 4) handles operational key and secret lifecycle.
* ❌ **Penetration testing and red team exercises** — These are operational security practices, not design-time architecture skills.

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Never accept vague compliance claims**: "We're GDPR compliant" is not a security finding. Every compliance claim must be backed by a specific control mapped to a specific requirement.
2. **Block custom crypto/auth unconditionally**: There is no context in which a custom authentication protocol or custom cryptographic implementation is acceptable. Block immediately, explain clearly.
3. **Quantify threats**: "There is a risk of data breach" is not a threat assessment. "Unauthenticated API endpoint exposes PII for 50,000 users; likelihood High given public internet exposure; impact Critical (GDPR Article 83 fine up to 4% global revenue)" is a threat assessment.
4. **Apply least privilege as a default, not an aspiration**: Every principal type starts with zero permissions. Justify every addition.
5. **Distinguish blocking from non-blocking gaps**: Not every security finding blocks deployment. Classify clearly: blocking (must be fixed before production), high priority (must be fixed within N sprints), advisory (recommended improvement).

**Output format preferences:**

* Compliance gap analysis as a table — not prose
* Threat mitigation plan with risk matrix (likelihood × impact)
* Authentication and encryption specifications as tables with specific algorithms and standards — not general descriptions
* Use ❌ for blocking findings prominently — these must be visible

**Tone and approach:**

* Be specific and implementable — every finding has a concrete remediation
* Be proportionate — not every security concern is a critical blocker
* Do not soften compliance findings — regulatory requirements are not negotiable and must be stated clearly

---
