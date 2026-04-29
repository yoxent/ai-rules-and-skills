# Skill Human Spec: Code Maintenance

```yaml
---
name: code-maintenance
description: Ensures long-term codebase health by identifying and addressing dead code, outdated patterns, and structural drift
version: 1.0.0
category: Maintenance
tags: [maintenance, technical-debt, code-health, dead-code, legacy-cleanup]
priority: Medium
depends_on: [correctness-validation]
flags_skills: [refactoring, technical-debt-management, regression-prevention, architecture-consistency, correctness-validation, test-creation-strategy]
inputs: [existing_codebase, change_history, static_analysis_reports, technical_debt_register, feature_roadmap]
outputs: [maintenance_action_plan, decay_areas, cleaned_code, updated_documentation_references]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - MF-2  # Technical Debt Tracking
  - MF-1  # Feature Consistency
  - TQ-3  # Regression Prevention
  - GM-2  # Explain Before Acting
documents_needed: [technical-debt-register, architectural-standards]
execution_context: Runs proactively to prevent debt accumulation; after major refactors; when structural drift detected
---
```

# Skill: Code Maintenance

## Purpose

Ensures long-term health of the codebase by proactively identifying and addressing dead code, outdated patterns, structural drift, and obsolete references before they compound into critical technical debt.

## When to Use This Skill

**Triggers:**
* After major refactoring or feature removal
* Following library upgrades or API deprecations
* Periodic codebase health reviews
* Static analysis reports show dead code or unused dependencies
* Architectural standards have evolved
* Feature roadmap shows legacy features being sunset
* Code review reveals outdated patterns

**Do NOT use for:**
* Active feature development (that's not maintenance)
* Major structural refactoring (use refactoring skill instead)
* Performance optimization (different concern)
* Code that's still in active use regardless of age

**Execution Context:** Runs proactively to prevent debt accumulation. Often scheduled periodically or triggered after major changes.

## Inputs & Outputs

**Required inputs:**
* Existing codebase
* Change history and commit logs
* Static analysis reports
* Technical debt register
* Feature roadmap

**Primary outputs:**
* Maintenance action plan
* Identified areas of decay or risk
* Cleaned and updated code or recommendations
* Updated documentation references

## Step-by-Step Execution

1. **Identify Dead Code** - Find unused imports, methods, classes; check static analysis reports
2. **Detect Outdated Patterns** - Compare current code to evolved architectural standards
3. **Find Obsolete References** - Locate deprecated API usages, orphaned configs
4. **Assess Removal Safety** - Check test coverage, usage analysis, impact scope
5. **Plan Maintenance Actions** - Prioritize by risk/benefit, coordinate with refactoring if needed
6. **Execute Cleanup** - Remove dead code, update patterns, verify no regressions per TQ-3

## Core Responsibilities

1. Identify dead code, obsolete patterns, and legacy constructs
2. Ensure code remains aligned with evolving architectural standards
3. Coordinate with Refactoring Skill when structural changes required
4. Track and surface incremental degradation before it becomes critical debt
5. Keep internal APIs and module contracts consistent with active usage

## Constraints (Rules Applied)

* **DA-1**: Maintenance must not reintroduce SOLID/Clean Code violations
* **MF-2**: All deferred maintenance must be logged as technical debt
* **MF-1**: Maintenance changes must not break existing behavior
* **TQ-3**: Regression checks required after maintenance passes
* **GM-2**: Explain risks before removing or deprecating code

## Tradeoff Handling

**Maintenance Depth vs Delivery Velocity:** Deep cleanup may conflict with sprint commitments; scope and confirm
**Proactive Cleanup vs Regression Risk:** Scope conservatively unless regression coverage high

## Failure & Escalation

* Structural changes exceed surface cleanup → flag refactoring skill
* Decay requires architectural planning → flag technical-debt-management
* Removal uncertain without test coverage → request guidance before proceeding
* Large scope identified → break into incremental maintenance plan
* Code modified during maintenance → flag `correctness-validation`, `regression-prevention`, `test-creation-strategy`

## Skills Flagged

* **refactoring** - when structural changes exceed surface-level cleanup
* **technical-debt-management** - when decay requires architectural planning
* **regression-prevention** - when removal risk requires extra validation
* **architecture-consistency** - when outdated patterns need standardization
* **correctness-validation** - when maintenance changes may affect existing correctness
* **test-creation-strategy** - when modified or removed code paths lack test coverage

## Anti-Patterns to Catch

1. Dead code accumulation increasing cognitive load and maintenance surface
2. Outdated patterns diverging from current architectural standards
3. Orphaned configuration or references causing confusion or latent bugs
4. Removing code without verifying it's truly unused
5. Updating patterns without regression testing
6. Deferring maintenance indefinitely until it becomes crisis
7. Breaking behavior while "cleaning up"
8. Removing code that lacks tests without investigation
