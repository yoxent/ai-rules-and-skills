```yaml
---
name: networking-security-configuration
description: Manages network topology, firewall rules, and security policies to enforce least-privilege access, environment isolation, and compliance with applicable network security standards.
version: 1.1.0
category: DevOps
tags: [networking, security, firewall, vpc, least-privilege]
priority: High

depends_on: [infrastructure-as-code]
flags_skills: [incident-response, secrets-management, infrastructure-as-code]

inputs: [network-architecture, security-requirements, compliance-constraints, service-communication-requirements]
outputs: [network-security-configurations, audit-reports, access-control-matrices]

rules_applied:
  - CL-1
  - CL-3
  - DD-3
  - DT-2

execution_context: Runs when network infrastructure is provisioned or modified; prerequisite for environment isolation and service communication security.

---
```

---

# Skill: Networking & Security Configuration

---

## Purpose

**What this skill does:**
Designs and manages network topology, firewall rules, VPN configuration, and security group policies to enforce least-privilege network access between services and environments. It ensures environment tiers (dev, staging, production) are isolated, service-to-service communication is explicitly declared and enforced, and network configurations meet applicable compliance requirements.

Prevents lateral movement in the event of a service compromise by enforcing network segmentation. Meets regulatory compliance requirements for network isolation (PCI-DSS, HIPAA, SOC2). Reduces the blast radius of security incidents through strict inter-service access controls.

Makes network access policies explicit, reviewable, and version-controlled. Prevents the accumulation of permissive rules that erode security posture over time. Enables service-to-service communication to be audited and validated against declared requirements.

---

## When to Use This Skill

### Triggers (Use this skill when):

* New infrastructure is being provisioned and network security groups or policies need defining
* Existing network rules are being reviewed for compliance or security posture
* A new service needs its ingress and egress communication paths declared
* Environment isolation between dev, staging, and production is being reviewed
* A security incident involves potential unauthorised network access
* Network configuration changes are being proposed for production
* Compliance audit requires network access control documentation

### Do NOT use this skill for:

* Provisioning the underlying network infrastructure (VPCs, subnets) — handled by Infrastructure as Code
* Application-level authentication and authorisation — handled by Security skill (Phase 2)
* Secrets and credential management for service communication — handled by Secrets Management
* Incident response coordination — handled by Incident Response

---

## Inputs

**Required inputs:**

* **Network architecture diagram** — The intended network topology, environment tiers, and service placement.
* **Security requirements and compliance constraints** — Applicable regulatory requirements (PCI-DSS zone isolation, HIPAA network controls) and organisational security policies.
* **Service communication requirements** — What services need to communicate with what, on what ports, and in what direction (ingress/egress).

**Optional inputs:**

* **Existing network security configurations** — For review or modification tasks.
* **Penetration test or security assessment findings** — To prioritise remediation of specific network vulnerabilities.

---

## Outputs

**Primary outputs:**

* **Network and security configuration definitions** — Firewall rules, security groups, NetworkPolicies, VPN configurations as version-controlled IaC.
* **Audit reports and compliance documentation** — Evidence of least-privilege enforcement and environment isolation for compliance purposes.
* **Access control matrices** — Explicit documentation of which service can communicate with which, on what port, in what direction.

---

## Preconditions

**Conditions that must be met before execution:**

* Network architecture is documented and approved
* Service communication requirements are declared (not assumed)
* Infrastructure as Code skill has provisioned or will provision the underlying network resources
* DT-2 confirmation received for production network security rule changes

**Validation checks:**

* [ ] Service communication matrix is documented
* [ ] Environment isolation boundaries are defined
* [ ] Compliance requirements are available for validation
* [ ] Network configurations are version-controlled

---

## Step-by-Step Execution Procedure

### Step 1: Audit Existing Network Security Posture

**Questions to answer:**
- Are environment tiers (dev, staging, production) properly isolated?
- Are any overly permissive rules (0.0.0.0/0, port ranges, all-traffic rules) present?
- Does the current configuration match the documented service communication matrix?

**Actions:**
- [ ] Review all ingress and egress rules for each environment tier
- [ ] Identify overly permissive rules — any rule allowing broader access than necessary
- [ ] Compare actual rules against declared service communication requirements
- [ ] Identify any undeclared service-to-service communication paths

**Red flags / Warning signs:**
- Rules allowing 0.0.0.0/0 ingress beyond load balancers or bastion hosts
- Production environment accessible from development environment
- Undeclared service communication paths — services communicating without documented requirement
- Identical security policies across all environments — no environment isolation

**Decision points:**
- Any overly permissive rule in production requires DT-2 confirmation to retain.
- Undeclared communication paths must be either declared and justified or blocked.

---

### Step 2: Define or Validate Least-Privilege Network Policies

**Questions to answer:**
- Is each rule scoped to the minimum required source, destination, and port?
- Are all permitted communication paths explicitly declared in the service communication matrix?
- Are denied paths explicitly blocked rather than relying on implicit default-deny?

**Actions:**
- [ ] Define rules with specific source/destination CIDRs or security group references — no wildcards
- [ ] Scope port ranges to minimum required — specific ports, not ranges, where possible
- [ ] Enforce default-deny posture — only explicitly permitted traffic is allowed
- [ ] Update service communication matrix to reflect all defined rules

**Red flags / Warning signs:**
- Rules referencing broad CIDR ranges instead of specific security group references
- Port ranges used where specific ports would suffice
- Absence of explicit deny rules at tier boundaries

**Decision points:**
- If existing rules cannot be tightened without breaking declared service communication, document via DT-1.

---

### Step 3: Validate Environment Isolation

**Questions to answer:**
- Is production network traffic fully isolated from staging and development?
- Are there any shared network paths between environment tiers that could allow lateral movement?
- Are management access paths (bastion, VPN) isolated from application traffic paths?

**Actions:**
- [ ] Verify production VPC/namespace has no direct peering or routing to dev/staging without explicit justification
- [ ] Confirm management access (SSH, kubectl) is restricted to bastion or VPN paths only
- [ ] Verify shared services (databases, message queues) used across environments are environment-specific instances, not shared
- [ ] Confirm no cross-environment DNS resolution that could enable service discovery across tiers

**Red flags / Warning signs:**
- Direct VPC peering between production and development without justification
- Shared database instances used across environment tiers
- Management ports (22, 3389, 6443) accessible from application subnets

**Decision points:**
- Any cross-environment routing requires DT-2 confirmation with documented justification.

---

### Step 4: Validate Version Control and Change Process

**Questions to answer:**
- Are all network security configurations defined as IaC and version-controlled?
- Are manual network changes tracked and remediated back into IaC?
- Do production network security rule changes go through the approval process?

**Actions:**
- [ ] Verify network configurations are defined in IaC alongside application code (DD-3)
- [ ] Check for manual changes made outside IaC — identify drift
- [ ] Confirm production network rule changes require DT-2 confirmation
- [ ] Verify peer review process applies to network configuration changes

**Red flags / Warning signs:**
- Network rules modified manually in cloud console without IaC update
- Network configurations not version-controlled
- Production rule changes applied without review

**Decision points:**
- If manual changes found, remediate by importing into IaC and flagging as drift.

---

### Step 5: Document and Communicate Compliance Evidence

**Questions to answer:**
- Does the current configuration meet applicable compliance requirements?
- Is the access control matrix documented and current?
- Are any compliance gaps communicated to stakeholders?

**Actions:**
- [ ] Validate configuration against applicable compliance requirements (PCI-DSS zones, HIPAA network controls)
- [ ] Update access control matrix documentation
- [ ] Communicate any compliance gaps as business risk via PS-2 equivalent
- [ ] Generate compliance evidence artefacts if audit is in scope

---

### Final Step: Generate Networking & Security Configuration Report

```markdown
## Networking & Security Configuration Report

**Environment:** [Target environment]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Security Posture
| Check | Status | Notes |
|-------|--------|-------|
| No overly permissive rules | ✅ | |
| Environment isolation enforced | ✅ | |
| Default-deny posture | ✅ | |
| Version-controlled configurations | ✅ | |
| Production rules DT-2 confirmed | ✅ | |

### Access Control Matrix
| Source | Destination | Port | Direction | Status |
|--------|-------------|------|-----------|--------|
| api-service | db-service | 5432 | Egress | ✅ |
| internet | load-balancer | 443 | Ingress | ✅ |

### Skills Flagged
- **incident-response**: [If security incident suspected]
- **secrets-management**: [If credential injection patterns need review]

### Required Actions
- [ ] [Action if any]
```

---

## Core Responsibilities

1. Enforce least-privilege network access — every rule scoped to minimum required source, destination, and port.
2. Enforce environment isolation — production must be isolated from staging and development.
3. Ensure all network security configurations are version-controlled and reviewed before application.
4. Require DT-2 confirmation for all production network security rule changes.
5. Maintain and update the service communication matrix as the authoritative access control record.

---

## Constraints (Rules Applied)

* **CL-1: Regulatory Compliance** — Network configuration must meet applicable compliance requirements (PCI-DSS zone isolation, HIPAA network controls, SOC2 access controls); non-compliant configurations block production deployment.
* **CL-3: Data Privacy** — Network segmentation must prevent unauthorised data access between services; overly permissive rules allowing cross-service access beyond declared requirements are violations.
* **DD-3: Infrastructure Validation** — Network configurations must be defined in IaC, version-controlled, and validated before application; manual console changes that bypass IaC are a violation.
* **DT-2: Confirmation Gate** — Production network security rule changes (adding, modifying, or removing firewall rules, security groups, or network policies) require explicit human approval before application.

---

## Tradeoff Handling

### Tradeoff 1: Security vs Developer Productivity

**Conflict:** Strict network policies improve security but can slow developer iteration if development environments are too locked down.

**Resolution:** Production gets strict least-privilege and full isolation; development can be more permissive but still isolated from production; document intentional differences via DT-1 — deviations must be conscious, not accidental.

### Tradeoff 2: Strict Rules vs Service Communication Flexibility

**Conflict:** Overly strict rules can block legitimate new service communication paths as architecture evolves.

**Resolution:** Declare the new path in the service communication matrix; review and confirm it as a legitimate requirement; apply as a specific, scoped rule — not a permissive workaround.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Overly Permissive Rule in Production

**Trigger:** Audit finds a rule allowing broader access than required (0.0.0.0/0, broad port ranges, cross-environment access).

**Action:**
- Block any new deployments that depend on the permissive rule
- Require DT-2 confirmation to retain the rule or plan for tightening
- Document via DT-1

---

### Escalation Scenario 2: Suspected Unauthorised Network Access

**Trigger:** Network logs or IDS alerts suggest traffic outside declared communication paths.

**Action:**
- Flag incident-response immediately
- Preserve network logs for forensic investigation
- Do not modify network rules until incident-response guidance received

---

### Escalation Scenario 3: Manual Network Change Outside IaC

**Trigger:** Network configuration found modified in cloud console without corresponding IaC update.

**Action:**
- Flag infrastructure-as-code to bring the change under version control
- Flag as configuration drift requiring immediate IaC import
- Require DT-2 if change is in production
- Document how the manual change occurred to prevent recurrence

---

### When to halt execution:

* Suspected active security incident — flag incident-response before making any changes
* Production rule changes without DT-2 confirmation
* Configuration that would eliminate environment isolation between production and other tiers

---

## Skill Integration & Orchestration

This skill depends on Infrastructure as Code (which provisions the underlying network resources) and produces configurations that protect all services running in the provisioned infrastructure.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Suspected unauthorised network access | incident-response | Active security incident |
| Credential injection pattern review needed | secrets-management | Service communication credentials |
| Manual network change found outside IaC | infrastructure-as-code | Bring configuration under version control |

---

## Related Skills

**Skills this skill depends on:**
* **infrastructure-as-code** — Provisions the VPCs, subnets, and network infrastructure that this skill configures security policies for.

**Skills this skill cooperates with:**
* **secrets-management** — Service-to-service communication often requires credential injection alongside network policy.
* **incident-response** — Escalation target for detected security incidents involving network access.

---

## Governance Hooks

* [ ] Require DT-2 for all production network security rule changes
* [ ] Enforce version control for all network configurations
* [ ] Block any configuration eliminating production environment isolation
* [ ] Document all intentional deviations from least-privilege via DT-1
* [ ] Flag incident-response immediately on suspected unauthorised network access

---

## Example Use Cases

### Example 1: Kubernetes NetworkPolicy for Microservice

**Scenario:** A new payment microservice needs network policies that restrict pod-to-pod communication to declared dependencies only.

**Execution steps:**
1. Review service communication requirements — payment-service needs egress to db-service:5432 and auth-service:8080 only.
2. Define NetworkPolicy: default-deny-all ingress/egress; explicit allow for declared paths.
3. Verify no other pods can reach payment-service except api-gateway.
4. Version-control NetworkPolicy in Helm chart.
5. Validate in staging — confirm declared paths work, undeclared paths blocked.

**Result:** PASS — least-privilege NetworkPolicy deployed.

---

### Example 2: Overly Permissive Security Group Found in Audit

**Scenario:** Production security group audit reveals an inbound rule allowing port 22 (SSH) from 0.0.0.0/0.

**Execution steps:**
1. Classify as overly permissive rule — immediate compliance concern.
2. Block dependent deployments.
3. Request DT-2 confirmation to retain or remediate.
4. Remediate: restrict port 22 to bastion host CIDR only.
5. Document via DT-1.

**Result:** Remediated after DT-2. Audit log updated.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: 0.0.0.0/0 ingress beyond load balancers**
✅ **Correct approach:** Only load balancers and bastion hosts should have broad ingress. All other services should have ingress restricted to specific security groups or CIDRs.

❌ **Anti-pattern 2: Identical security policies across all environment tiers**
✅ **Correct approach:** Production requires stricter isolation than development. Identical policies suggest environment isolation is not enforced.

❌ **Anti-pattern 3: Manual network changes in cloud console**
✅ **Correct approach:** All network configuration changes must go through IaC and version control. Console changes create untracked drift.

❌ **Anti-pattern 4: Broad port range rules instead of specific ports**
✅ **Correct approach:** Specify exact ports required. Port ranges are a sign of permissive policy that will accumulate risk over time.

❌ **Anti-pattern 5: Shared network resources across environment tiers**
✅ **Correct approach:** Databases, message queues, and other stateful services must be environment-specific. Shared resources eliminate environment isolation.

❌ **Anti-pattern 6: No default-deny posture**
✅ **Correct approach:** Default-deny everything, then explicitly permit only required paths. Implicit deny is insufficient — make it explicit.

---

## Non-Goals

* ❌ Provisioning VPCs and subnets — handled by Infrastructure as Code
* ❌ Application-level authentication — handled by Security skill (Phase 2)
* ❌ Secrets and credential management — handled by Secrets Management
* ❌ Incident response coordination — handled by Incident Response

---
