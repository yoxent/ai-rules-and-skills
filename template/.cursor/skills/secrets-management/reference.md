```yaml
---
name: secrets-management
description: Securely manages credentials, API keys, and certificates to prevent unauthorised access, ensure auditability, and automate rotation without service disruption.
version: 1.1.0
category: DevOps
tags: [secrets, credentials, vault, rotation, security]
priority: High

depends_on: []
flags_skills: [incident-response, infrastructure-as-code]

inputs: [secrets-inventory, access-policies, service-identity-definitions, application-integration-points]
outputs: [encrypted-secrets-with-access-control, access-audit-log, rotation-schedules]

rules_applied:
  - CL-3
  - CL-1
  - DD-3
  - DT-2

documents_needed: [secrets-inventory, access-policy, rotation-policy, compliance-requirements]

execution_context: Runs when secrets are provisioned, rotated, or when secret leaks are detected; prerequisite for any service requiring credential injection.

---
```

---

# Skill: Secrets Management

---

## Purpose

**What this skill does:**
Manages the full lifecycle of sensitive credentials — provisioning, access control, injection, rotation, and revocation — ensuring secrets never appear in code, logs, configuration files, or container images. It enforces least-privilege access, automates rotation to minimise exposure windows, and maintains an auditable record of all secret access and changes.

Prevents credential-based breaches that are among the most common and costly security incidents. Meets regulatory audit requirements for credential management (SOC2, PCI-DSS, HIPAA). Reduces operational risk from stale, unrotated credentials that accumulate over time.

Centralises credential management, eliminating the scatter of credentials across config files, environment variables, and hardcoded values. Enables automated rotation without service disruption. Provides a clear audit trail for compliance and incident investigation.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new service needs credentials provisioned and injected at runtime
* A secret leak or suspected unauthorised access is detected
* Credentials need to be rotated — scheduled or emergency
* Secret access policies are being reviewed or modified
* A service is being migrated away from hardcoded or file-based credentials
* Compliance audit requires credential management documentation
* A pipeline or infrastructure change requires secret injection pattern review

### Do NOT use this skill for:

* Designing network security policies — handled by Networking & Security Configuration
* Application-level encryption of user data — handled by the Security skill (Phase 2)
* Certificate authority setup — this skill consumes certificates; CA setup is Infrastructure as Code
* Incident response coordination — handled by Incident Response (this skill flags it)

---

## Inputs

**Required inputs:**

* **Secrets and credentials inventory** — What secrets exist, their type (API key, DB password, TLS cert, OAuth token), owning service, and rotation schedule.
* **Access policies and service identity definitions** — Which services are permitted to access which secrets, using what identity mechanism (IAM role, Kubernetes service account, Vault AppRole).
* **Application integration points** — Where and how secrets are consumed by applications (environment injection, mounted files, dynamic credentials).

**Optional inputs:**

* **Existing secret storage configuration** — For review or migration tasks.
* **Compliance requirements** — Specific regulatory requirements for credential management (rotation frequency, audit log retention, encryption standards).

---

## Outputs

**Primary outputs:**

* **Encrypted secrets with access-controlled retrieval** — Secrets stored in approved vault with least-privilege access policies enforced.
* **Access audit log** — Immutable record of which service accessed which secret, when, and from where.
* **Automated rotation schedules and runbooks** — Rotation configured for all secrets with service disruption prevention validated.

---

## Preconditions

**Conditions that must be met before execution:**

* Approved secrets vault is available (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault)
* Service identity mechanism is established (IAM role, service account, AppRole)
* Rotation procedure has been tested to confirm it does not cause service disruption
* Compliance requirements are documented

**Validation checks:**

* [ ] No existing secrets hardcoded in code, config files, or container images
* [ ] Least-privilege access policies defined per service
* [ ] Rotation schedule defined for all secrets
* [ ] Audit logging enabled on secret vault

---

## Step-by-Step Execution Procedure

### Step 1: Audit Current Secret Storage and Access Patterns

**Questions to answer:**
- Are any secrets stored outside the approved vault (hardcoded, in config files, in environment variables in plain text)?
- Are access policies following least-privilege?
- Are all secrets on a defined rotation schedule?

**Actions:**
- [ ] Scan codebase, config files, Dockerfiles, and pipeline definitions for hardcoded secrets
- [ ] Review environment variable injection patterns — confirm secrets not passed as plain text
- [ ] Audit vault access policies — verify least-privilege per service
- [ ] Identify secrets with no rotation schedule

**Red flags / Warning signs:**
- Secrets in version control — immediate CL-3 violation
- Broad access policies granting multiple services access to the same secret
- Secrets with no expiry or rotation schedule — stale credentials accumulate risk
- Secrets in CI/CD pipeline logs

**Decision points:**
- If secrets found in version control, treat as leaked — initiate emergency rotation immediately.
- If overly broad access policies found, require remediation to least-privilege before proceeding.

---

### Step 2: Provision or Migrate Secrets to Approved Vault

**Questions to answer:**
- Is the secret stored in the approved vault with the correct access policy?
- Is the secret encrypted at rest and in transit?
- Is the secret accessible only via the defined service identity?

**Actions:**
- [ ] Store secret in approved vault with encryption at rest confirmed
- [ ] Define access policy scoped to the requesting service identity only
- [ ] Verify secret is retrievable via service identity (not via shared credentials)
- [ ] Confirm secret is NOT stored anywhere outside the vault

**Red flags / Warning signs:**
- Secret stored in vault but also left in legacy location — dual storage creates confusion
- Access policy using wildcard or overly broad resource patterns
- Secret retrievable without service identity verification

**Decision points:**
- If DT-2 confirmation required for access policy changes, block until received.

---

### Step 3: Configure Runtime Injection

**Questions to answer:**
- How is the secret injected into the application at runtime?
- Does the injection mechanism avoid plain text exposure in process environment or logs?
- Is the injection validated in the deployment pipeline?

**Actions:**
- [ ] Configure runtime injection using approved pattern (Vault Agent sidecar, external-secrets-operator, AWS SDK dynamic retrieval, mounted tmpfs volume)
- [ ] Verify secret does not appear in process environment variables in plain text where avoidable
- [ ] Confirm secret is not logged at application startup or in debug output
- [ ] Validate injection in deployment pipeline before production (DD-3)

**Red flags / Warning signs:**
- Secret injected as plain text environment variable visible in `docker inspect` or `kubectl describe pod`
- Application logs printing secret value at startup
- Injection validated only manually, not in pipeline

**Decision points:**
- If plain text environment injection is unavoidable, document as accepted risk via DT-1 with compensating controls.

---

### Step 4: Configure and Validate Rotation

**Questions to answer:**
- Is automated rotation configured for this secret?
- Has rotation been tested to confirm it does not disrupt the consuming service?
- Is the rotation window appropriate for the secret's risk profile?

**Actions:**
- [ ] Configure automated rotation with frequency appropriate to secret type and risk
- [ ] Test rotation procedure in staging — confirm service continues without restart or disruption
- [ ] Verify rotation failure alerting is configured — failed rotation must not silently leave a stale credential
- [ ] Document rotation runbook for manual rotation in emergency scenarios

**Red flags / Warning signs:**
- Rotation procedure requires service restart — zero-disruption rotation is the target
- Rotation never tested — risk of service outage on first rotation event
- No alert on rotation failure — stale credentials accumulate undetected

**Decision points:**
- If rotation causes service disruption in staging, block production rotation and require redesign.
- If zero-disruption rotation is not achievable, document via DT-1 with planned maintenance window.

---

### Step 5: Verify Audit Logging and Compliance

**Questions to answer:**
- Is audit logging enabled and capturing all secret access events?
- Does the audit log retention period meet compliance requirements?
- Are audit logs protected from tampering?

**Actions:**
- [ ] Confirm audit logging is enabled on vault for all secret access events (read, write, delete, policy change)
- [ ] Verify audit log retention period meets compliance requirements (e.g. 12 months for SOC2)
- [ ] Confirm audit logs are stored in tamper-evident, access-controlled storage
- [ ] Verify access policy changes require DT-2 confirmation and are captured in audit log

**Red flags / Warning signs:**
- Audit logging disabled or not capturing read events
- Audit logs stored in the same system as the secrets — not independently protected
- Retention period below compliance requirement

---

### Final Step: Generate Secrets Management Report

```markdown
## Secrets Management Report

**Service:** [Service Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Secret Inventory
| Secret | Vault | Access Policy | Rotation | Audit Log |
|--------|-------|--------------|----------|-----------|
| db-password | ✅ | Least-privilege ✅ | 30d ✅ | ✅ |
| api-key-ext | ✅ | Least-privilege ✅ | 90d ✅ | ✅ |

### Security Checks
| Check | Status | Notes |
|-------|--------|-------|
| No hardcoded secrets | ✅ | |
| Least-privilege access | ✅ | |
| Rotation tested | ✅ | |
| Audit logging enabled | ✅ | |

### Skills Flagged
- **incident-response**: [If leak detected]
- **infrastructure-as-code**: [If vault provisioning needed]

### Required Actions
- [ ] [Action if any]
```

---

## Core Responsibilities

1. Detect and block any secret stored outside the approved vault — code, config, images, logs.
2. Enforce least-privilege access policies scoped to specific service identities.
3. Configure and validate automated rotation without service disruption.
4. Require DT-2 confirmation for all secret access policy changes.
5. Maintain tamper-evident audit logs meeting compliance retention requirements.

---

## Constraints (Rules Applied)

* **CL-3: Data Privacy** — Secrets must never appear in code, logs, environment variables in plain text, or container images; any detected violation is an immediate block.
* **CL-1: Regulatory Compliance** — Secrets management must meet applicable regulatory audit requirements (rotation frequency, audit log retention, encryption standards, access control documentation).
* **DD-3: Infrastructure Validation** — Secret injection patterns must be validated in deployment pipelines before production; manual injection validation is insufficient.
* **DT-2: Confirmation Gate** — Changes to secret access policies (who can access what) are security-sensitive and require explicit human approval.

---

## Tradeoff Handling

### Tradeoff 1: Security vs Accessibility

**Conflict:** Strict least-privilege access controls improve security but can block legitimate service access if policies are too narrow.

**Resolution:** Start with minimal access and expand only when confirmed necessary; document policy expansions via DT-1 with business justification; review access policies quarterly and remove permissions no longer needed.

### Tradeoff 2: Automation Complexity vs Rotation Safety

**Conflict:** Automated rotation is more secure but requires careful coordination to avoid service outages during rotation events.

**Resolution:** Test rotation in staging first — zero-disruption is the target; gate production rotation on staging test passing; monitor rotation events and alert on failure immediately.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Secret Found in Version Control

**Trigger:** A secret, credential, or API key is found committed to version control.

**Action:**
- Treat as leaked immediately — assume compromised
- Initiate emergency rotation before any other action
- Flag incident-response for security incident handling
- Report file and commit reference without reproducing the secret value
- Require git history remediation (rewrite history or notify all cloners)

---

### Escalation Scenario 2: Unauthorised Secret Access Detected in Audit Log

**Trigger:** Audit log shows secret access from an unexpected service identity, IP, or at an unexpected time.

**Action:**
- Rotate affected secret immediately
- Flag incident-response for security incident investigation
- Revoke access for the suspected compromised identity
- Document via DT-1

---

### Escalation Scenario 3: Rotation Causing Service Disruption

**Trigger:** Secret rotation in staging causes service errors or restart.

**Action:**
- Block production rotation
- Document disruption via DT-1
- Require rotation procedure redesign before production use
- If zero-disruption rotation is not achievable, plan a maintenance window

---

### When to halt execution:

* Secret found in version control — treat as leaked, rotate immediately before anything else
* Unauthorised access detected — rotate and flag incident-response immediately
* Rotation causing service disruption and no maintenance window planned

---

## Skill Integration & Orchestration

This skill is foundational for any service requiring credential injection. It is triggered by containerization and infrastructure-as-code when they detect hardcoded secrets, and by deployment pipelines requiring secret injection validation.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Secret found in version control or image | incident-response | Security incident — potential breach |
| Unauthorised access in audit log | incident-response | Active security incident |
| Vault provisioning needed | infrastructure-as-code | Infrastructure setup required |

---

## Related Skills

**Skills this skill depends on:** None — foundational security skill.

**Skills this skill cooperates with:**
* **containerization** — Flags secrets-management when secrets are found in image layers.
* **infrastructure-as-code** — Flags secrets-management when hardcoded credentials are found in IaC definitions.
* **ci-cd-pipeline-automation** — Secret injection validation is a pipeline stage concern.
* **incident-response** — Receives escalations when secret leaks or unauthorised access is detected.

---

## Governance Hooks

* [ ] Block immediately on any secret found outside approved vault
* [ ] Require DT-2 for all access policy changes
* [ ] Validate rotation in staging before production
* [ ] Maintain audit logs meeting compliance retention requirements
* [ ] Treat version-control secret exposure as a security incident — rotate before all else

---

## Example Use Cases

### Example 1: Migrating Hardcoded Database Password to Vault

**Scenario:** A service has its database password hardcoded in `application.properties` committed to git.

**Execution steps:**
1. Detect hardcoded secret in version control — treat as leaked.
2. Rotate database password immediately.
3. Store new password in HashiCorp Vault with access policy scoped to service's Kubernetes service account.
4. Configure Vault Agent sidecar to inject secret as mounted file at runtime.
5. Remove hardcoded value from config file and git history.
6. Validate injection in staging pipeline.
7. Flag incident-response to document the exposure.

**Result:** PASS after remediation. Secret exposure flagged as incident.

---

### Example 2: Access Policy Change Requiring DT-2

**Scenario:** A team requests that service B be granted read access to a secret currently only accessible by service A.

**Execution steps:**
1. Classify as access policy change — DT-2 required.
2. Request confirmation: why does service B need this secret, is a separate secret preferable?
3. Receive DT-2 confirmation with business justification.
4. Update access policy in vault.
5. Capture change in audit log.
6. Document via DT-1.

**Result:** PASS — access policy updated with confirmed approval.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Secrets in version control**
✅ **Correct approach:** Treat as a security incident immediately. Rotate, remediate git history, and flag incident-response.

❌ **Anti-pattern 2: Sharing secrets between services**
✅ **Correct approach:** Each service should have its own credentials. Shared secrets mean a breach of one service compromises all services sharing that credential.

❌ **Anti-pattern 3: Secrets as plain text environment variables**
✅ **Correct approach:** Use vault agent sidecars, external-secrets-operator, or SDK-based dynamic retrieval. Plain text env vars are visible in process listings and `kubectl describe`.

❌ **Anti-pattern 4: Never rotating credentials**
✅ **Correct approach:** All secrets must have a rotation schedule. Long-lived, never-rotated credentials are a significant breach risk.

❌ **Anti-pattern 5: Testing rotation for the first time during an incident**
✅ **Correct approach:** Rotation must be tested in staging before production. An untested rotation procedure is a service outage risk.

❌ **Anti-pattern 6: Audit logging disabled to reduce storage cost**
✅ **Correct approach:** Audit logs are non-negotiable for compliance and incident investigation. Storage cost is not a valid justification for disabling them.

❌ **Anti-pattern 7: Broad vault access policies using wildcards**
✅ **Correct approach:** Access policies must be scoped to specific secrets and specific service identities. Wildcard policies defeat the purpose of a secrets vault.

---

## Non-Goals

* ❌ Application-level data encryption — handled by Security skill (Phase 2)
* ❌ Certificate authority setup — handled by Infrastructure as Code
* ❌ Network security policy design — handled by Networking & Security Configuration
* ❌ Incident response coordination — handled by Incident Response

---
