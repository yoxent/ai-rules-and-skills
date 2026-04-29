---
name: configuration
description: "Use when task requires Enforces config/code separation, per-env validation, secrets routing, and dynamic config design"
---

# Configuration

name:configuration|pri:M|deps:[system-design]|flags:[security,dependency-management,observability,technical-debt-management]|rules:[DA-4,DD-3,MF-1,CL-3,DT-1,GM-4]
SCOPE: Enforces config/code separation, per-env validation, secrets routing, and dynamic config design
ENFORCE: Classify all configuration values as non-secret, secret, or dynamic before designing any schema; Route every secret to a dedicated secrets manager — config files store references only, never values (CL-3); Define schema validation for all config keys with types, required/optional, and allowed ranges; Require fail-fast startup validation — service must not start with invalid configuration (DD-3); Design base + per-environment override structure; environment behavior differences belong in config, not code (DA-4); Apply dynamic configuration only where runtime changes are explicitly justified — deployment is the default (DA-5 via DT-1); Require audit trail for all dynamic configuration changes
PROHIBIT: Secrets in configuration files, .env files, or source control under any circumstances; Environment-specific code branches (if env == "production") in application code; Configuration without startup schema validation; Dynamic configuration without rollback capability
ON_VIOLATION: secret_in_config → flag security → treat_as_compromised → rotate_immediately → block_deployment. env_branch_in_code → document_as_boundary_violation → require_refactoring → flag technical-debt-management. config_invalid → block_deployment → surface_specific_validation_error → require_fix. dynamic_no_rollback → block_approval → require_rollback_mechanism_design. dynamic_config_external_coupling → flag:dependency-management → validate_new_coupling. config_changes_need_instrumentation → flag:observability → instrument_config_change_events

## Reference
- See [reference.md](reference.md) for distilled source details.
