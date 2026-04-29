```yaml
---
name: configuration
description: Manages system configuration by enforcing separation from code, validating per environment, routing secrets through dedicated management, and supporting dynamic changes without redeployment.
version: 1.0.0
category: Architecture
tags: [configuration, environment-management, secrets, feature-flags, validation]
priority: Medium
depends_on: [system-design]
flags_skills: [security, dependency-management, observability, technical-debt-management]
inputs: [application-requirements, environment-variables, deployment-targets, feature-flag-requirements, secrets-inventory]
outputs: [configuration-schema, validation-rules, environment-overrides, dynamic-configuration-setup]
rules_applied:
  - DA-4   # Change Boundary Rule
  - DD-3   # Infrastructure Validation
  - MF-1   # Feature Consistency
  - CL-3   # Data Privacy
  - DT-1   # Explicit Tradeoff Logging
  - GM-4   # Behavioral Transparency
documents_needed: [system-architecture, deployment-targets, compliance-requirements]
execution_context: Runs when new services are designed, when environment-specific behavior is needed, or when hard-coded values or secrets-in-config are detected.
---
```

---

# Skill: Configuration

---

## Purpose

**What this skill does:**
Configuration enforces the strict separation of configuration from code, validates configuration consistency across environments, routes all secrets through dedicated secrets management systems, and designs dynamic configuration where runtime changes without redeployment are required. It prevents hard-coded values, environment-specific code branches, and secrets in configuration files from entering the codebase.

Configuration problems are a leading cause of production incidents — environment drift, hard-coded staging values deployed to production, and secrets in source control create costly failures. This skill prevents the class of incidents caused by configuration errors by making configuration explicit, validated, and environment-appropriate.

Clean configuration separation makes services portable across environments (dev/staging/prod) without code changes. Validated configuration schemas catch misconfiguration at startup rather than at runtime under load. Dynamic configuration enables operational control of system behavior without deployment risk.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new service is being designed and its configuration surface needs definition
* Hard-coded values are detected in code review that should be configuration
* Environment-specific code branches (`if (env === "production")`) are introduced
* A secret (API key, DB password, certificate) is being stored in a configuration file or committed to source control
* Multiple environments (dev, staging, prod) need to run the same service with different behavior
* Feature flags are being introduced as a configuration-driven mechanism
* A configuration change caused a production incident (misconfiguration post-mortem)

### Do NOT use this skill for:

* Provisioning and managing secrets storage infrastructure (use Secrets Management, Phase 4)
* Deploying configuration changes to live environments (DevOps Phase 4)
* Infrastructure-as-Code configuration (Terraform, Pulumi — use Infrastructure as Code, Phase 4)
* Business rule changes encoded as configuration — if it's business logic, it belongs in code, not config

---

## Inputs

**Required inputs:**

* **Application requirements** — What the service needs to behave differently across environments: database endpoints, service URLs, feature states, timeouts, pool sizes, log levels.
* **Environment variables** — The set of deployment targets (local, dev, staging, production) and their environmental distinctions.
* **Secrets inventory** — Which configuration values are secrets (credentials, API keys, certificates) vs. non-secret configuration (URLs, timeouts, feature flags).

**Optional inputs:**

* **Feature flag requirements** — Whether dynamic feature flags are needed, and whether they need per-tenant, per-user, or system-wide scope.
* **Dynamic configuration requirements** — Whether any configuration must change at runtime without redeployment (rate limits, kill switches, rollout percentages).

---

## Outputs

**Primary outputs:**

* **Configuration schema** — A machine-validated schema for all configuration values, with types, required/optional designation, allowed value ranges, and default values.
* **Validation rules** — What is checked at service startup: required fields present, values within allowed ranges, environment-specific constraints satisfied.
* **Environment-specific override structure** — How the same service is configured differently per environment without code changes: base config + per-environment overlay pattern.
* **Dynamic configuration setup** — Where applicable: feature flag service or dynamic config store design (LaunchDarkly, AWS AppConfig, custom Redis-backed), with change propagation and audit trail.

---

## Preconditions

* System architecture defines the services requiring configuration
* Deployment targets (environments) are known
* Secrets inventory has been identified (so secrets can be routed separately from non-secret config)

---

## Step-by-Step Execution Procedure

### Step 1: Configuration Inventory and Classification

**Questions to answer:**
- What values does the service need to run that are not business logic?
- Which of those values differ across environments?
- Which of those values are secrets?
- Which of those values need to change without redeployment?

**Actions:**
- [ ] Enumerate all configuration values the service consumes: endpoints, credentials, timeouts, feature states, pool sizes, log levels, third-party API keys
- [ ] Classify each value: (a) non-secret config (can be in version control), (b) secret (must be in secrets manager), (c) dynamic (needs runtime change capability)
- [ ] Identify values that are currently hard-coded in source — mark as configuration debt

**Red flags / Warning signs:**
- Any secret (password, API key, certificate) classified as non-secret config — a source control commit will expose it
- Business logic encoded as configuration values (pricing rules, discount thresholds) — configuration is not a substitute for a proper business rule engine
- More than 20% of config values require dynamic changes — complex dynamic config is an operational burden that must be justified

---

### Step 2: Configuration Schema and Validation Design

**Questions to answer:**
- What type and range constraints apply to each configuration value?
- Which values are required vs. optional with defaults?
- What should happen when configuration is invalid at startup — fail-fast or use defaults?

**Actions:**
- [ ] Define schema for each configuration key: type (string, int, bool, duration, URL), required/optional, default value if optional, allowed values or ranges
- [ ] Apply DA-4: configuration schema changes should only be required when the service's business behavior changes, not when deployment infrastructure changes
- [ ] Design fail-fast validation at startup: the service must not start with invalid configuration. Invalid config that causes failures at runtime is significantly harder to debug than a startup failure with a clear error message
- [ ] Define environment-specific validation rules: production may require stricter validation (e.g., TLS required, debug mode prohibited)

**Red flags / Warning signs:**
- No schema validation — a misconfigured value is discovered at runtime under load, not at startup
- Optional fields with no defaults — creates silent undefined behavior when not provided
- Configuration that is validated in application code rather than at a startup boundary — validation happens too late

---

### Step 3: Secrets Separation

**Questions to answer:**
- Are all secrets routed through a dedicated secrets management system (Vault, AWS Secrets Manager, GCP Secret Manager)?
- Are any secrets currently in configuration files, environment variable files, or source control?
- What is the secret rotation strategy?

**Actions:**
- [ ] Verify every secret in the configuration inventory has a corresponding secrets manager reference (not a value)
- [ ] Configuration files must contain only references to secrets (`SECRET_REF: vault:secret/my-service/db-password`) not the secret values themselves
- [ ] Apply CL-3: secrets in configuration files or source control must be treated as compromised and rotated immediately
- [ ] Define rotation strategy: how often are secrets rotated, and does the service support hot rotation (without restart)?

**Red flags / Warning signs:**
- Secrets in `.env` files committed to source control — even in private repositories, this is a security violation
- Secrets passed as environment variables in deployment configuration that is stored in plaintext — the deployment config is as sensitive as the secrets themselves
- No rotation strategy for long-lived credentials — credentials that never rotate create permanent exposure if compromised

**Decision points:**
- Any secret found outside a secrets manager → flag security → treat as potentially compromised → require immediate rotation

---

### Step 4: Environment Parity and Override Design

**Questions to answer:**
- How does the service's configuration differ across dev, staging, and production?
- How are environment-specific overrides structured without duplicating the entire config?
- Are there production-only requirements (TLS, high connection pool, stricter timeouts) that must be enforced?

**Actions:**
- [ ] Design base config (applies to all environments) + per-environment overlay (overrides only what differs)
- [ ] Apply MF-1: configuration changes must not alter behavior unexpectedly across environments. A config key that behaves differently in prod than staging due to a missing override is a consistency violation
- [ ] Define production-specific mandatory overrides: TLS enabled, debug logging disabled, minimum connection pool size, max request timeouts
- [ ] Verify no environment-specific code branches in the application code — all environment differences must be in configuration

**Red flags / Warning signs:**
- `if (process.env.NODE_ENV === 'production')` in application code — environment logic belongs in configuration, not in business logic
- Configuration that is only tested in staging but has different production values — the prod behavior is untested
- Production configuration not managed in version control (even with secrets excluded) — untracked production config creates drift that is invisible until failure

---

### Step 5: Dynamic Configuration Design (Where Required)

**Questions to answer:**
- Which configuration values need to change at runtime without redeployment?
- What is the propagation latency requirement (how quickly must a change take effect)?
- What is the rollback mechanism if a dynamic config change causes problems?
- What is the audit trail for configuration changes?

**Actions:**
- [ ] Identify the minimum set of values that genuinely require dynamic changes (kill switches, rollout percentages, rate limits)
- [ ] Apply DA-5: do not build dynamic configuration capability for values that can safely require a deployment to change — dynamic config adds operational complexity
- [ ] Design the dynamic config store with change propagation (polling interval vs. push-based), version history, and rollback capability
- [ ] Require an audit log for all dynamic config changes: who changed what, from what value, to what value, when
- [ ] Flag **observability** to instrument config change events and expose current config state via a metrics or health endpoint

**Red flags / Warning signs:**
- Dynamic configuration without rollback capability — a bad config push with no rollback is as dangerous as a bad code deploy
- Feature flags controlling security-critical behavior changed dynamically without an approval gate
- Dynamic config changes not logged — a configuration change that caused an incident cannot be investigated without a change history

---

### Final Step: Generate Configuration Design Report

```markdown
## Configuration Design Report

**Service:** [Name]  **Date:** [YYYY-MM-DD]  **Status:** ✅ / ⚠️ / ❌

### Configuration Inventory
| Key | Type | Required | Default | Secret? | Dynamic? |
|-----|------|----------|---------|---------|---------|
| [key] | [type] | [Y/N] | [value/none] | [Y/N] | [Y/N] |

### Secrets Routing
| Secret | Current Location | Required Location | Status |
|--------|----------------|------------------|--------|
| [name] | [location] | [secrets manager] | ✅/❌ |

### Environment Override Structure
- Base config: [location]
- Per-env overrides: [location and pattern]
- Production mandatory overrides: [list]

### Validation Rules
- Startup validation: [fail-fast / warn / silent]
- Environment-specific constraints: [list]

### Dynamic Configuration
| Key | Store | Propagation | Rollback | Audit |
|-----|-------|------------|---------|-------|
| [key] | [store] | [interval/push] | [mechanism] | [yes/no] |

### Configuration Debt
| Hard-coded Value | Location | Priority |
|-----------------|----------|---------|
| [value] | [file:line] | [High/Med/Low] |

### Skills Flagged
- **[Skill]**: [Reason]

### Required Actions
- [ ] [Action with owner]
```

---

## Core Responsibilities

1. Classify all configuration values as non-secret, secret, or dynamic
2. Design configuration schema with type validation and startup fail-fast enforcement
3. Route all secrets to dedicated secrets management — zero tolerance for secrets in config files
4. Design base + per-environment override structure with production mandatory constraints
5. Design dynamic configuration only where runtime changes are genuinely required (DA-5)
6. Produce configuration debt inventory for hard-coded values requiring remediation

---

## Constraints (Rules Applied)

* **DA-4: Change Boundary Rule** — Configuration changes should never require code changes and vice versa. A service that requires a code deployment to change its database endpoint has failed to separate concerns.
* **DD-3: Infrastructure Validation** — Configuration must be validated for correctness before deployment. Startup validation is the minimum; pre-deployment schema validation in CI/CD is preferred.
* **MF-1: Feature Consistency** — A configuration change must not cause unexpected behavioral differences across environments. Config changes must be tested in staging with the same values as production.
* **CL-3: Data Privacy** — Secrets must never appear in configuration files, even encrypted configuration files. The config file format is not an acceptable secrets store.
* **DT-1: Explicit Tradeoff Logging** — Decisions to use dynamic configuration (vs. requiring a deployment for changes) must be documented with the operational cost accepted.

---

## Tradeoff Handling

### Tradeoff 1: Flexibility vs. Complexity

**Default stance:** Simple static configuration (environment variables + config files) is the default. Dynamic configuration is only introduced when the operational requirement for runtime changes is explicit and justified (specific feature flag use case, rate limit tuning, kill switch requirement).

### Tradeoff 2: Centralized vs. Distributed Config

**Default stance:** Centralized configuration management (all services read from a common config store) is preferred for consistency. Per-service config files in the service's own repository are the fallback when a centralized config store is not available.

**Tradeoff:** Centralized config is consistent but is a dependency and potential single point of failure. Services must handle config store unavailability gracefully — use last-known-good values, not crash.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Secret Found in Configuration File or Source Control

**Trigger:** A secret (API key, password, certificate, token) is found in a configuration file, `.env` file, or committed to source control.

**Action:** Flag **security** immediately. Treat the secret as compromised — it must be rotated. Remove from source control (including history scrub if in a commit). The deployment must not proceed until the secret is rotated and stored in a secrets manager.

### Escalation Scenario 2: Environment-Specific Code Branches Detected

**Trigger:** Application code contains explicit environment checks (`if env == "production"`).

**Action:** Document as a configuration boundary violation. Require refactoring: the behavior difference must be expressed as configuration, not as code. Flag **technical-debt-management** if the violation is widespread.

### Escalation Scenario 3: Configuration Validation Failure in CI/CD

**Trigger:** Pre-deployment configuration schema validation fails — a required key is missing or a value is out of range.

**Action:** Block deployment. Surface the specific validation error. Do not proceed with deployment until configuration is corrected and validation passes.

---

## Skill Integration & Orchestration

Configuration runs after System Design. It is closely related to Secrets Management (Phase 4) for secret storage, and to Observability for config change instrumentation. It is upstream of all DevOps deployment skills — deployment cannot be correctly executed without a validated configuration design.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|----------|------|--------|
| Secret outside secrets manager | security | Credentials at risk; immediate rotation required |
| Dynamic config introduces external service dependency | dependency-management | New coupling must be validated |
| Config change events need instrumentation | observability | Config changes should be observable and auditable |
| Widespread hard-coded values | technical-debt-management | Systematic remediation plan needed |

---

## Related Skills

* **depends on: system-design** — services and their runtime requirements must be known before configuration can be designed
* **cooperates with: security** — secrets inventory from Security informs what must be routed to secrets manager
* **cooperates with: observability** — configuration change events should be instrumented and observable

---

## Governance Hooks

* [ ] Secrets must never be in configuration files — CL-3 absolute requirement
* [ ] All configuration values must have schema validation applied at service startup
* [ ] Document all dynamic configuration decisions with operational justification per DT-1
* [ ] Production configuration must be version-controlled (excluding secret values)
* [ ] Configuration changes to production must have an audit trail

---

## Example Use Cases

### Example 1: New Service Configuration Design

**Scenario:** A new payments service is being designed. It needs: a database URL (secret), Stripe API key (secret), feature flags for 3DS enforcement, request timeout settings, and log level.

**Steps:**
1. Inventory: DB URL → secret, Stripe key → secret, 3DS flag → dynamic (feature flag), timeouts → static config, log level → static config with env override
2. Schema: timeouts are integer (ms), required, no default — must be explicit per environment; log level is enum [DEBUG, INFO, WARN, ERROR], default INFO
3. Secrets: DB URL and Stripe key routed to AWS Secrets Manager with references in config
4. Dynamic: 3DS flag → LaunchDarkly feature flag with rollback capability and audit trail
5. Environment overrides: prod requires TLS=true, log_level=INFO enforced (DEBUG prohibited)

**Result:** ✅ COMPLETE — Configuration design ready for implementation

### Example 2: Secrets Found in Source Control

**Scenario:** Code review discovers a `.env.production` file committed to the repository containing database passwords and API keys.

**Steps:**
1. Immediate action: flag **security** — secrets are compromised
2. Rotate all exposed secrets immediately
3. Remove `.env.production` from git history (BFG Repo Cleaner or git filter-branch)
4. Add `.env*` to `.gitignore`
5. Migrate all secrets to AWS Secrets Manager
6. Update CI/CD to inject secrets from Secrets Manager at deploy time

**Result:** ❌ BLOCKED (resolved) — Secrets rotated, configuration redesigned. Technical debt item added for any remaining non-secret config in `.env` files.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Secrets in Config Files**
Storing passwords, API keys, or certificates in configuration files, even encrypted ones. Config files in source control expose secrets to anyone with repo access.
✅ **Correct approach:** Config files store references to secrets (`secret_ref: vault:path/to/secret`). The secret value is injected at runtime by the secrets manager.

❌ **Anti-pattern 2: Environment Checks in Application Code**
`if (NODE_ENV === 'production') { ... }` anywhere in application code. Environment is a runtime concern; application code should be environment-agnostic.
✅ **Correct approach:** All environment differences are expressed as configuration values. The code reads the configuration value and behaves accordingly without knowing which environment it's in.

❌ **Anti-pattern 3: No Configuration Validation**
Configuration is read and used without validation. A missing required value causes a null pointer exception 30 minutes into a production deployment when the affected code path is first hit.
✅ **Correct approach:** Validate all required configuration at startup. If validation fails, the service does not start. Fail fast with a clear error message.

❌ **Anti-pattern 4: Dynamic Config Without Rollback**
A dynamic configuration system that allows runtime changes but has no mechanism to revert a bad change. A misconfigured feature flag or rate limit can bring down a service.
✅ **Correct approach:** Every dynamic configuration system must support instant rollback to the previous value. The rollback should be faster than the propagation of the bad change.

❌ **Anti-pattern 5: Configuration Drift Between Environments**
Production configuration has diverged from staging over time — manual changes applied to prod that were never applied to staging. Staging is no longer a reliable test of production behavior.
✅ **Correct approach:** All configuration (excluding secret values) is version-controlled. Configuration changes flow through the same deployment pipeline as code changes, never applied manually to production.

❌ **Anti-pattern 6: Business Logic in Configuration**
Using configuration to encode business rules (pricing tiers, discount rates, eligibility rules). Configuration is for runtime behavior, not business logic.
✅ **Correct approach:** Business rules belong in the business domain model or a dedicated rules engine. Configuration that encodes business rules becomes a hidden, unversioned, untested code path.

---

## Non-Goals

* ❌ **Secrets storage infrastructure provisioning** — Secrets Management (Phase 4)
* ❌ **Infrastructure-as-Code** — Terraform, Pulumi, CloudFormation are DevOps Phase 4 concerns
* ❌ **Business rule engines** — Business logic encoded as configuration is out of scope
* ❌ **Deploying configuration changes** — DevOps Phase 4 handles deployment execution

---

## Notes for LLM Implementation

1. **Classify secrets first**: Before designing any configuration, identify every secret in the inventory. Routing secrets is non-negotiable and must be addressed before any other configuration design proceeds.
2. **Fail-fast by default**: Always recommend startup validation that fails the service if configuration is invalid. The cost of a clean startup failure is far lower than a runtime failure under load.
3. **Apply DA-5 to dynamic config**: Every feature flag and dynamic config entry adds operational complexity. Question whether each one genuinely needs runtime change capability, or whether a deployment is acceptable.
4. **Version control for non-secret config**: Configuration that is not version-controlled cannot be diffed, reviewed, or rolled back. Even environment overrides should be in version control (with secret values excluded).
