# Skill Human Spec: Dependency Safety & Integration

```yaml
---
name: dependency-safety-integration
description: Manages external dependencies to prevent breaking changes, security vulnerabilities, and compatibility issues
version: 1.0.0
category: Engineering
tags: [dependencies, security, compatibility, vulnerability-management, library-integration]
priority: Medium
depends_on: [correctness-validation]
flags_skills: [security, backward-compatibility, error-handling-resilience, dependency-license-compliance]
inputs: [dependency_list, current_versions, vulnerability_reports, proposed_libraries, version_upgrades]
outputs: [safe_integration_plan, compatibility_assessment, risk_ranked_recommendations, security_report]
rules_applied:
  - CL-2  # License Validation
  - CL-3  # Data Privacy
  - MF-3  # Backward Compatibility
  - DT-2  # Confirmation Gate
  - GM-2  # Explain Before Acting
documents_needed: [dependency-inventory, vulnerability-reports]
execution_context: Runs when adding new dependencies, updating versions, or security vulnerabilities discovered
---
```

# Skill: Dependency Safety & Integration

## Purpose

**What this skill does:**
Manages and validates external dependencies to prevent breaking changes, security vulnerabilities, and compatibility issues from entering the codebase through library updates or new integrations.

Prevents production incidents from dependency issues, maintains security posture, reduces integration risk, avoids legal issues from license incompatibility.

Ensures stable dependency versions across environments, validates compatibility before deployment, prevents supply chain vulnerabilities, maintains predictable builds.

## When to Use This Skill

### Triggers:

* New third-party library being considered for adoption
* Existing dependency version upgrade proposed (major, minor, or patch)
* Security vulnerability discovered in current dependencies
* Dependency license change detected
* Transitive dependency conflict identified
* Build reproducibility issues related to dependencies
* Dependency deprecation notices received

### Do NOT use for:

* Internal libraries owned by the team
* Already-vendored dependencies that were validated
* Development-only dependencies with no prod impact
* Trivial patch updates with no breaking changes

## Core Responsibilities

1. Prevent breaking changes from dependency updates per MF-3
2. Assess risk of upgrades against benefit of new features/security patches
3. Maintain version stability across environments (dev, staging, prod)
4. Coordinate with DevOps for dependency governance in CI/CD
5. Validate license compatibility per CL-2 before adopting dependencies

## Constraints (Rules Applied)

* **CL-2**: Check license compatibility before adopting any new dependency. Some licenses (GPL, AGPL) have viral clauses incompatible with commercial software.
* **CL-3**: Assess whether new dependencies introduce data handling risks. Dependencies that phone home or collect telemetry need scrutiny.
* **MF-3**: Dependency upgrades must not break existing integration contracts. Semantic versioning should be respected.
* **DT-2**: Major dependency upgrades require explicit approval before proceeding due to high risk.
* **GM-2**: Explain risks before major dependency upgrades, including breaking changes and migration effort.

## Example Use Cases

### Example 1: npm Package Audit Before Upgrade

**Scenario:** Team wants to upgrade React from 17.0.2 to 18.2.0 for new features.

**Execution:**
1. Check CHANGELOG for breaking changes
   - createRoot replaces ReactDOM.render
   - Automatic batching changes behavior
   - IE11 support dropped
2. Assess impact on codebase
   - Search for ReactDOM.render usage: 15 files
   - Check browser support requirements: IE11 not supported by product
3. Review security advisories
   - No critical vulnerabilities in React 17.0.2
   - React 18 has improved security posture
4. Test in isolated environment
   - Create feature branch
   - Run full test suite: 3 tests fail due to batching behavior
   - Fix tests, verify application works
5. Plan rollout
   - Incremental: update one module at a time
   - Or: Big bang with rollback plan

**Result:** ✅ Approved with migration plan and rollback strategy

### Example 2: Security Vulnerability Response

**Scenario:** npm audit reports critical vulnerability in lodash 4.17.15.

**Execution:**
1. Assess vulnerability
   - CVE-2020-8203: Prototype pollution
   - Severity: High (7.4 CVSS)
   - Exploitability: Requires attacker-controlled input to specific functions
2. Check if vulnerable code paths used
   - Search codebase for lodash.set, lodash.merge, lodash.defaultsDeep
   - Found: Only using lodash.map and lodash.filter (not vulnerable)
3. Assess upgrade path
   - Latest: 4.17.21 (patches vulnerability)
   - Breaking changes: None (patch version)
4. Decision
   - Upgrade immediately due to security fix
   - Low risk: Patch version, no breaking changes
   - Test suite passes after upgrade

**Result:** ✅ Immediate upgrade approved and deployed

### Example 3: License Compatibility Check

**Scenario:** Developer wants to add GPL-licensed library for PDF generation.

**Execution:**
1. Check license
   - Library: wkhtmltopdf (LGPL v3)
   - Our product: Commercial SaaS
   - Compatibility: LGPL allows dynamic linking without viral effect
2. Verify usage pattern
   - Planned: Call wkhtmltopdf as external process
   - Not: Link as library (would trigger GPL viral clause)
3. Legal review
   - Consult with legal team on LGPL compliance
   - Requirement: Preserve LGPL license and copyright notices
4. Alternative assessment
   - Consider: Puppeteer (Apache 2.0) - more permissive
   - Trade-off: Puppeteer requires Chrome/Node runtime
5. Decision
   - Approve LGPL dependency with compliance requirements documented

**Result:** ✅ Approved with compliance checklist

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Upgrading all dependencies at once without testing
✅ **Correct approach:** Incremental upgrades with testing between each

❌ **Anti-pattern 2:** Ignoring security vulnerabilities because "we don't use that feature"
✅ **Correct approach:** Upgrade anyway - attack surface may expand in future

❌ **Anti-pattern 3:** Not checking transitive dependencies
✅ **Correct approach:** Audit full dependency tree, including indirect dependencies

❌ **Anti-pattern 4:** Using latest/^version in production
✅ **Correct approach:** Pin exact versions for reproducible builds

❌ **Anti-pattern 5:** No rollback plan for dependency upgrades
✅ **Correct approach:** Document rollback procedure before upgrading

❌ **Anti-pattern 6:** Ignoring deprecation warnings
✅ **Correct approach:** Plan migration before deprecated version reaches EOL

❌ **Anti-pattern 7:** Adding dependencies for trivial functionality
✅ **Correct approach:** Evaluate: Is this worth the dependency cost?

❌ **Anti-pattern 8:** Not testing after dependency upgrades
✅ **Correct approach:** Run full test suite, including integration tests

## Skills Flagged

* **security** - when vulnerability found in dependency
* **backward-compatibility** - when upgrade introduces breaking changes
* **error-handling-resilience** - when dependency introduces unsafe failure behavior
* **dependency-license-compliance** - when license conflict detected

## Failure & Escalation

* Security vulnerability found → flag `security` → assess urgency and patch priority
* Breaking change detected in upgrade → flag `backward-compatibility` → test compatibility
* License conflict found → flag `dependency-license-compliance`
* Unsafe failure behavior introduced by dependency → flag `error-handling-resilience`
