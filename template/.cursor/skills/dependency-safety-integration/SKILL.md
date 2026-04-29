---
name: dependency-safety-integration
description: "Use when task requires Manages external dependencies to prevent breaking changes, security vulnerabilities, and compatibility issues"
---

# Dependency Safety Integration

name:dependency-safety-integration|pri:M|deps:[correctness-validation]|flags:[security,backward-compatibility,error-handling-resilience,dependency-license-compliance]|rules:[CL-2,CL-3,MF-3,DT-2,GM-2]
SCOPE: Manages external dependencies to prevent breaking changes, security vulnerabilities, and compatibility issues
ENFORCE: Prevent breaking changes from dependency updates; Check license compatibility before adopting any new dependency per CL-2; Assess data handling risks from new dependencies per CL-3; Verify dependency upgrades don't break existing contracts per MF-3; Request confirmation for major dependency upgrades per DT-2; Assess risk of upgrades against benefit of features/security patches; Check transitive dependencies for vulnerabilities; Test after dependency upgrades; Plan rollback strategy for dependency changes
PROHIBIT: Introducing dependency with incompatible license per CL-2; Upgrading dependencies without testing; Ignoring security vulnerabilities; Not checking transitive dependencies; Upgrading all dependencies simultaneously; Ignoring deprecation warnings; No rollback plan for upgrades
ON_VIOLATION: major_upgrade → request_confirmation per DT-2 → assess_risk. license_conflict → flag dependency-license-compliance. sec_vuln_found → flag security → assess_urgency. breaking_change → flag backward-compatibility → test_compatibility. privacy_risk → flag security per CL-3. upgrade_breaks → revert → investigate per MF-3. unsafe_failure_introduced → flag error-handling-resilience

## Reference
- See [reference.md](reference.md) for distilled source details.
