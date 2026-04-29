```yaml
---
name: infrastructure-as-code
description: Defines and provisions infrastructure using version-controlled code to ensure reproducible, idempotent, and drift-free environment management.
version: 1.1.0
category: DevOps
tags: [infrastructure, terraform, ansible, iac, provisioning]
priority: High

depends_on: []
flags_skills: [ci-cd-pipeline-automation, containerization, secrets-management]

inputs: [infrastructure-requirements, cloud-resource-specifications, security-compliance-rules]
outputs: [infrastructure-definitions, provisioning-scripts, environment-configuration-documentation]

rules_applied:
  - DD-3  # Infrastructure Validation — IaC scripts must be validated for idempotence and correctness
  - DD-1  # CI/CD Enforcement — infrastructure changes must go through pipeline review
  - CL-3  # Data Privacy — infrastructure definitions must not contain hardcoded secrets
  - DT-2  # Confirmation Gate — destructive infrastructure operations require explicit approval

documents_needed: [infrastructure-requirements, cloud-architecture-diagram, security-compliance-requirements, existing-iac-definitions]

execution_context: Runs when infrastructure is provisioned, modified, or diagnosed; prerequisite for environment-dependent deployments.

---
```

---

# Skill: Infrastructure as Code

---

## Purpose

**What this skill does:**
Defines, provisions, and manages infrastructure components — compute, networking, storage, managed services — using version-controlled code (Terraform, Ansible, CloudFormation, Pulumi, etc.). It ensures all environments are reproducible, idempotent, and free from manual configuration drift.

Eliminates manual provisioning errors that cause environment inconsistency and outages. Enables rapid, consistent environment creation (new regions, disaster recovery, ephemeral test environments). Provides an auditable history of all infrastructure changes through version control.

Makes infrastructure changes reviewable, testable, and reversible. Prevents configuration drift — the gap between what is defined in code and what is actually running. Enables infrastructure to be treated as a first-class engineering artifact with the same quality standards as application code.

---

## When to Use This Skill

### Triggers (Use this skill when):

* New infrastructure is being provisioned for a service or environment
* Existing infrastructure definitions are being reviewed or modified
* Manual infrastructure changes have been made outside IaC and drift remediation is needed
* Infrastructure security or compliance posture is being reviewed
* A new cloud region or environment is being established
* Infrastructure provisioning failures are being diagnosed
* Infrastructure changes are needed to support a pipeline or deployment change

### Do NOT use this skill for:

* Application deployment to provisioned infrastructure — handled by Deployment Management
* CI/CD pipeline configuration — handled by CI/CD Pipeline Automation
* Container image construction — handled by Containerization
* Secrets storage and rotation — handled by Secrets Management

**Execution Context Details:**
This skill runs before deployment and pipeline skills that depend on infrastructure existing. It is also triggered reactively when drift is detected or infrastructure changes are needed to unblock other skills.

---

## Inputs

**Required inputs:**

* **Infrastructure requirements** — What compute, network, storage, and managed services are needed, with capacity and performance requirements.
* **Cloud or on-prem resource specifications** — Cloud provider, region, resource types, sizing, and tagging requirements.
* **Security and compliance rules** — Network segmentation requirements, encryption requirements, IAM policies, and regulatory constraints.

**Optional inputs:**

* **Existing IaC definitions** — For review or modification tasks.
* **Architecture diagram** — To validate that IaC definitions match the intended architecture.

---

## Outputs

**Primary outputs:**

* **Infrastructure definitions** — Version-controlled IaC files (`.tf`, `.yml`, `.json`, etc.) defining all infrastructure components.
* **Provisioning and validation scripts** — Plan outputs, dry-run results, and idempotency validation results.
* **Environment configuration documentation** — What was provisioned, where, and with what configuration — for operational reference.

**Output format:**

* IaC definition files in the appropriate tool format
* Terraform plan output or equivalent dry-run result
* Provisioning report documenting resources created, modified, or destroyed

---

## Preconditions

**Conditions that must be met before execution:**

* Infrastructure requirements are documented and approved
* Cloud provider credentials are available via approved secrets mechanism (not hardcoded)
* Existing IaC state is available and up-to-date (no out-of-band manual changes in progress)
* Destructive operations have received explicit DT-2 confirmation before execution

**Validation checks:**

* [ ] IaC definitions contain no hardcoded secrets or credentials
* [ ] Dry-run/plan step has been executed and reviewed before apply
* [ ] Destructive operations identified and confirmed
* [ ] IaC definitions are version-controlled and reviewed

---

## Step-by-Step Execution Procedure

### Step 1: Validate IaC Definitions for Correctness and Security

**Questions to answer:**
- Are any secrets or credentials hardcoded in IaC definitions?
- Are all resource definitions syntactically valid?
- Do resource definitions match the stated requirements?

**Actions:**
- [ ] Scan IaC definitions for hardcoded secrets, API keys, or passwords
- [ ] Run syntax validation (e.g. `terraform validate`, `ansible-lint`)
- [ ] Review resource definitions against stated requirements
- [ ] Verify all variable inputs are sourced from approved secrets mechanisms, not hardcoded

**Red flags / Warning signs:**
- Hardcoded credentials in any IaC file
- Resources defined without required tags (cost allocation, environment, owner)
- Resource sizing significantly over or under requirements without justification

**Decision points:**
- If hardcoded secrets found, block immediately — CL-3 violation.
- If resource sizing is unexplained, request justification before proceeding.

---

### Step 2: Validate Idempotency

**Questions to answer:**
- Will running this IaC definition twice produce the same result?
- Are there any non-idempotent operations (e.g. shell scripts with side effects)?
- Does the dry-run output match expectations?

**Actions:**
- [ ] Execute dry-run/plan step and review output
- [ ] Identify any resources that will be destroyed and recreated (vs modified in-place)
- [ ] Check for non-idempotent shell scripts or provisioners
- [ ] Confirm plan output matches intended changes — no unexpected resource modifications

**Red flags / Warning signs:**
- Plan output shows resources being destroyed unexpectedly
- Shell scripts in provisioners with non-idempotent side effects
- Plan shows more changes than expected — possible state drift

**Decision points:**
- If plan shows unexpected destruction, block and escalate — require explicit confirmation.
- If non-idempotent scripts are found, require remediation before proceeding.

---

### Step 3: Identify and Gate Destructive Operations

**Questions to answer:**
- Does this change destroy or replace any existing resources?
- What is the blast radius if this change fails mid-execution?
- Is rollback possible if the change needs to be reversed?

**Actions:**
- [ ] Identify all destroy and replace operations in the plan
- [ ] Classify risk: LOW (new resources only), MEDIUM (modifications), HIGH (destructions or replacements)
- [ ] For HIGH risk: require DT-2 confirmation before proceeding
- [ ] Verify rollback path exists for HIGH risk operations

**Red flags / Warning signs:**
- Database or stateful resource destruction without explicit data backup confirmation
- Network resource changes that could cause connectivity loss
- IAM policy changes that could lock out operators

**Decision points:**
- Any resource destruction requires DT-2 confirmation — no exceptions.
- If rollback is impossible (e.g. destructive migration), escalate and document via DT-1.

---

### Step 4: Review for Architectural Consistency

**Questions to answer:**
- Do the new infrastructure definitions follow established patterns in the codebase?
- Are naming conventions, tagging standards, and module structure consistent?
- Is the level of modularity appropriate — not over-engineered, not a single monolithic file?

**Actions:**
- [ ] Verify naming conventions match existing infrastructure definitions
- [ ] Check tagging standards are applied consistently
- [ ] Assess module structure — flag if a single large file should be decomposed, or if over-abstracted modules add complexity without benefit
- [ ] Verify new patterns are justified if they deviate from established conventions

**Red flags / Warning signs:**
- New IaC patterns that deviate from established conventions without justification
- Single monolithic infrastructure file that is hard to maintain and review
- Excessive module abstraction hiding important configuration details (DA-5 violation)

**Decision points:**
- Unjustified deviation from established IaC patterns requires DT-1 log.

---

### Step 5: Apply and Verify

**Questions to answer:**
- Did the apply complete successfully?
- Does the provisioned infrastructure match the plan output?
- Are there any post-provisioning validation steps required?

**Actions:**
- [ ] Apply IaC definitions (after all gates passed and confirmations received)
- [ ] Verify provisioned resources match plan output
- [ ] Run post-provisioning smoke tests (connectivity checks, service availability)
- [ ] Confirm no manual changes are needed post-provisioning — flag if so

**Red flags / Warning signs:**
- Apply output differs from plan output (unexpected changes during apply)
- Provisioned resources not reachable or not in expected state post-apply
- Manual post-apply steps required — these should be automated

**Decision points:**
- If apply output differs from plan, halt and investigate before proceeding.
- If manual post-apply steps are needed, log as technical debt via MF-2 equivalent.

---

### Final Step: Generate IaC Report

```markdown
## Infrastructure as Code Report

**Target:** [Environment/Service Name]
**Tool:** [Terraform / Ansible / CloudFormation / etc.]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Plan Summary
| Operation | Resource | Risk |
|-----------|----------|------|
| CREATE | aws_vpc.main | LOW |
| MODIFY | aws_security_group.app | MEDIUM |
| DESTROY | aws_rds_instance.old | HIGH — DT-2 confirmed ✅ |

### Security Checks
| Check | Status | Notes |
|-------|--------|-------|
| No hardcoded secrets | ✅ | |
| Resources tagged | ✅ | |
| Destructive ops confirmed | ✅ | DT-2 received |
| Idempotency validated | ✅ | Plan matches apply |

### Skills Flagged
- **ci-cd-pipeline-automation**: [Reason if flagged]

### Required Actions
- [ ] [Action 1 if any]
```

---

## Core Responsibilities

1. Ensure all infrastructure definitions are idempotent — identical results on repeated runs.
2. Block any IaC definition containing hardcoded secrets or credentials.
3. Require DT-2 confirmation before executing any destructive infrastructure operation.
4. Validate IaC definitions through dry-run before apply.
5. Ensure all infrastructure changes are version-controlled and reviewed before application.

---

## Constraints (Rules Applied)

* **DD-3: Infrastructure Validation** — All IaC scripts must be validated for idempotence and correctness before application; dry-run/plan is mandatory; non-idempotent scripts are a blocking defect.
* **DD-1: CI/CD Enforcement** — Infrastructure changes must go through the same pipeline review process as application code: version control, peer review, automated validation.
* **CL-3: Data Privacy** — IaC definitions must not contain hardcoded secrets, credentials, or API keys; all sensitive values must be sourced from approved secrets mechanisms.
* **DT-2: Confirmation Gate** — Destructive infrastructure operations (resource destruction, replacement, IAM policy, network changes) require explicit human confirmation before execution.

---

## Tradeoff Handling

### Tradeoff 1: Automation Complexity vs Maintainability

**Resolution:** If module abstraction is hiding important config or a monolithic file is hard to review, apply DA-5: reject unnecessary complexity; justify abstractions with real reuse requirements. Right-sized modularity — decompose where there is real reuse; keep simple where there isn't.

### Tradeoff 2: Abstraction Level vs Control

**Resolution:** If a module abstraction prevents required configuration, log via DT-1 (what control is lost and why), then request DT-2 if deviation from the standard module is justified.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Hardcoded Secret in IaC Definition

**Trigger:** Any secret, credential, or API key found hardcoded in an IaC file.

**Action:**
- Block immediately — CL-3 violation
- Report file and line number without reproducing the value
- Flag secrets-management; require migration to proper secrets management before proceeding

---

### Escalation Scenario 2: Destructive Operation Without Confirmation

**Trigger:** Plan output shows resource destruction or replacement without prior DT-2 confirmation.

**Action:**
- Block apply immediately
- Present destruction list with blast radius assessment
- Request DT-2 confirmation before proceeding

**Escalation format:**
```
⚠️ DESTRUCTIVE OPERATION CONFIRMATION REQUIRED

Resources to be destroyed:
  - [resource_type.name] — [description of impact]

Blast radius: [What services/data are affected]
Rollback possible: [Yes/No — details]

Question: Confirm destruction of listed resources? (DT-2 required)
```

---

### Escalation Scenario 3: Plan Output Differs from Apply Output

**Trigger:** Resources changed during apply that were not in the plan output.

**Action:**
- Halt immediately
- Document discrepancy
- Investigate state drift before retrying

---

### When to halt execution:

* Hardcoded secret found in any IaC file
* Destructive operation without DT-2 confirmation
* Plan output shows unexpected resource changes
* Apply output differs from plan output

---

## Skill Integration & Orchestration

This skill is foundational — it provisions the infrastructure that all other deployment and operational skills depend on. It is triggered before deployment skills when new environments are needed, and reactively when drift remediation is required.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Infrastructure changes need pipeline integration | ci-cd-pipeline-automation | Pipeline changes needed to apply IaC |
| Container registry or runtime provisioning needed | containerization | Container environment setup |

---

## Related Skills

**Skills this skill depends on:** None — foundational skill.

**Skills this skill cooperates with:**
* **ci-cd-pipeline-automation** — Infrastructure changes should go through CI/CD pipelines.
* **secrets-management** — Credentials used in IaC must come from secrets management, not be hardcoded.
* **deployment-management** — Deployment depends on infrastructure being correctly provisioned.

---

## Governance Hooks

* [ ] Block immediately on hardcoded secrets in IaC files
* [ ] Require dry-run/plan before every apply
* [ ] Require DT-2 confirmation for all destructive operations
* [ ] Ensure all IaC changes are version-controlled before application
* [ ] Log all deviations from established IaC patterns via DT-1

---

## Example Use Cases

### Example 1: Terraform AWS VPC Provisioning

**Scenario:** A new microservice requires a dedicated VPC with public/private subnets, security groups, and an RDS instance.

**Execution steps:**
1. Review Terraform definitions — no hardcoded secrets, all variables sourced from Vault.
2. Run `terraform validate` — passes.
3. Run `terraform plan` — 12 resources to create, 0 to destroy.
4. Classify as LOW risk (new resources only, no destruction).
5. Apply — all 12 resources created successfully.
6. Post-provisioning: verify VPC connectivity and RDS reachability.

**Result:** PASS.

---

### Example 2: Terraform Plan Shows Unexpected RDS Destruction

**Scenario:** A Terraform module update to change RDS instance class produces a plan that destroys and recreates the RDS instance (not an in-place modification).

**Execution steps:**
1. Review plan — RDS instance destruction detected.
2. Classify as HIGH risk — stateful resource, potential data loss.
3. Block apply immediately.
4. Present destruction impact to stakeholder — request DT-2 confirmation.
5. Confirm data backup exists before proceeding.
6. Receive DT-2 confirmation — proceed with apply.

**Result:** NEEDS REVIEW → PASS after DT-2 confirmation and backup validation.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Hardcoded credentials in IaC files**
✅ **Correct approach:** All sensitive values must be sourced from secrets management. Use provider-specific mechanisms (AWS Secrets Manager, Vault provider, environment variables injected at runtime).

❌ **Anti-pattern 2: Applying without running plan first**
✅ **Correct approach:** Plan is mandatory before every apply. The plan output is the contract — apply executes exactly what plan described.

❌ **Anti-pattern 3: Making manual changes outside IaC**
✅ **Correct approach:** All infrastructure changes must go through IaC. Manual changes create drift, break idempotency, and create untracked state. If a manual change was made, remediate by importing the resource into IaC state.

❌ **Anti-pattern 4: Single monolithic IaC file for all infrastructure**
✅ **Correct approach:** Decompose into logical modules (networking, compute, database). This enables independent review, testing, and modification of each concern.

❌ **Anti-pattern 5: Destroying stateful resources without data backup confirmation**
✅ **Correct approach:** Any destruction of databases, file storage, or other stateful resources requires explicit backup confirmation before DT-2 approval is sought.

❌ **Anti-pattern 6: IaC not version-controlled**
✅ **Correct approach:** IaC definitions are production code. They must live in version control, be peer reviewed, and go through the same pipeline as application code.

❌ **Anti-pattern 7: Over-abstracted modules hiding critical configuration**
✅ **Correct approach:** Apply DA-5. Modules should encapsulate real reuse. If a module hides important security or networking configuration, it is too abstract.

---

## Non-Goals

* ❌ Deploying applications to provisioned infrastructure — handled by Deployment Management
* ❌ Container image construction — handled by Containerization
* ❌ Secrets storage and rotation — handled by Secrets Management
* ❌ CI/CD pipeline configuration — handled by CI/CD Pipeline Automation
* ❌ Post-deployment monitoring — handled by Monitoring & Alerts

---

## Notes for LLM Implementation

1. **Always run plan before apply:** Never suggest applying IaC without reviewing plan output first.
2. **Never reproduce secret values:** Report file and line number of hardcoded secrets only.
3. **Be explicit about destruction risk:** Don't understate the impact of resource destruction — always present blast radius and rollback availability.
4. **Distinguish drift from intentional change:** A plan showing unexpected changes may indicate state drift, not a code error — investigate before blocking.
