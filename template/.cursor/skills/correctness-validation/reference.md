# Skill Human Spec: Correctness & Validation

```yaml
---
name: correctness-validation
description: Ensures functional correctness of all code and design changes by verifying logic against business intent
version: 1.0.0
category: Engineering
tags: [correctness, validation, quality-assurance, regression, testing]
priority: High
depends_on: []
flags_skills: [performance-optimization, clean-code-solid, security, design-pattern-selection, error-handling-resilience, backward-compatibility, bug-diagnosis, test-creation-strategy]
inputs: [business_requirements, acceptance_criteria, existing_codebase, test_results, feature_specifications]
outputs: [validation_report, defect_list, approval_status, pass_fail_status, reproduction_steps]
rules_applied:
  - PC-5  # Correctness Priority
  - TQ-1  # Test Coverage Requirement
  - MF-1  # Feature Consistency
  - GM-2  # Explain Before Acting
  - GM-4  # Behavioral Transparency
documents_needed: [business-requirements, acceptance-criteria, test-specifications]
execution_context: Runs after feature implementation, refactoring, or bug fixes before deployment approval
---
```

# Skill: Correctness & Validation

## Purpose

Ensures functional correctness of all code and design changes by verifying logic against business intent, preventing regressions, and validating edge cases before delivery.

## When to Use This Skill

**Triggers:**
* New feature implementation complete
* Refactoring performed
* Bug fix implemented
* Changes touch business/calculation logic
* API contracts or external interfaces modified
* Database schema/data transformation changed
* Integration points with external systems modified
* Performance optimizations applied

**Do NOT use for:**
* Code not yet written
* Purely stylistic/formatting changes
* Documentation-only changes
* Simple variable renames

**Execution Context:** Runs after implementation complete but before merge/deploy. Critical checkpoint between "code written" and "code approved."

## Inputs & Outputs

**Required inputs:**
* Business requirements and acceptance criteria
* Existing codebase and test results
* Feature specifications or change descriptions

**Primary outputs:**
* Validation report with pass/fail status
* Defect list with reproduction steps
* Approval/rejection recommendation with rationale

## Step-by-Step Execution

1. **Verify Logic Against Business Intent** - Map requirements to implementation, check acceptance criteria met
2. **Validate Edge Cases & Boundaries** - Test boundary values, null/empty inputs, array bounds, date/time edge cases
3. **Check for Regressions** - Run existing test suite, review failures, test critical workflows
4. **Verify Performance Tradeoffs** - Identify any correctness compromises, check documentation, assess if acceptable
5. **Assess Test Coverage** - Review coverage metrics, examine assertions, verify error paths tested

## Core Responsibilities

1. Verify logic against business intent, not just technical specification
2. Ensure no regression of existing features
3. Cross-check edge cases and boundary conditions
4. Validate performance tradeoffs are explicit, documented, approved
5. Confirm test coverage exists for critical paths including error handling

## Constraints (Rules Applied)

* **PC-5**: Correctness is non-negotiable baseline - any deviation must be explicitly confirmed and logged
* **TQ-1**: Validation must be backed by tests, not manual inspection alone
* **MF-1**: New features must not break existing functionality
* **GM-2**: Risky changes require explanation before execution
* **GM-4**: All outputs based on evidence, not assumptions

## Tradeoff Handling

**Correctness vs Delivery Speed:** Reject unless deviation explicitly approved and logged via DT-1
**Correctness vs Performance:** Flag as violation unless tradeoff documented with error bounds

## Failure & Escalation

* Ambiguous requirements → halt → request clarification
* Root cause unclear → escalate to bug-diagnosis
* Regression with unknown impact → flag bug-diagnosis

## Skills Flagged

* **performance-optimization** - when correctness validated but performance degrades
* **clean-code-solid** - when logic correct but structure poor
* **security** - when correctness validated but vulnerabilities suspected
* **design-pattern-selection** - when complexity suggests pattern improvement
* **error-handling-resilience** - when happy path works but error handling missing
* **backward-compatibility** - when correctness validated but breaking changes detected
* **bug-diagnosis** - when regression detected with unknown root cause
* **test-creation-strategy** - when coverage gaps found during validation

## Anti-Patterns to Catch

1. "Works on my machine" without test coverage
2. All tests pass but tests aren't meaningful
3. Assuming edge cases handled without testing
4. Silently accepting performance optimizations that degrade correctness
5. Ignoring flaky tests
6. Validating against code comments instead of requirements
7. Approving when requirements ambiguous
8. Skipping regression testing for "isolated" changes
