# Skill Human Spec: Test Interpretation & Failure Diagnosis

```yaml
---
name: test-interpretation-failure-diagnosis
description: Distinguishes between broken features and broken tests when failures occur, identifying root cause
version: 1.0.0
category: Testing & QA
tags: [testing, test-quality, diagnosis, failure-analysis, regression]
priority: High
depends_on: [correctness-validation]
flags_skills: [bug-diagnosis, test-creation-strategy, regression-prevention, correctness-validation]
inputs: [test_execution_logs, failure_messages, recent_code_changes, test_intent, business_requirement]
outputs: [root_cause_report, failure_classification, recommended_fix, test_quality_issues]
rules_applied:
  - TQ-2  # Test Failure Diagnosis
  - TQ-4  # Test Quality Rule
  - DT-1  # Explicit Tradeoff Logging
  - GM-2  # Explain Before Acting
  - GM-4  # Behavioral Transparency
documents_needed: [test-specifications, business-requirements]
execution_context: Runs when tests fail in CI/CD or during code reviews; critical for understanding test vs code issues
---
```

# Skill: Test Interpretation & Failure Diagnosis

## Purpose

Distinguishes between broken features and broken tests when test failures occur, identifying the root cause and recommending whether code or test requires correction.

## When to Use This Skill

**Triggers:**
* Tests fail in CI/CD pipeline
* Tests fail during code review
* Test failures after refactoring
* Flaky test investigation
* Mock-based test failures
* Time-sensitive or environment-dependent test failures

**Do NOT use for:**
* Tests that pass (no failure to diagnose)
* Test creation (different skill)
* Bug diagnosis when failure cause is obvious
* Performance test failures (different analysis)

**Execution Context:** Runs when tests fail. Critical for understanding whether code is broken or test is broken.

## Inputs & Outputs

**Required inputs:**
* Test execution logs and failure messages
* Recent code changes
* Test intent and original business requirement

**Primary outputs:**
* Root cause report classifying failure as code defect or test defect
* Recommended fix with reasoning
* Notes on test quality issues discovered during investigation

## Step-by-Step Execution

1. **Analyze Failure Message** - Parse error, stack trace, assertion details
2. **Review Recent Changes** - Check what code/tests changed recently
3. **Understand Test Intent** - Determine what business behavior test validates
4. **Compare to Requirements** - Check if test still reflects current requirements
5. **Classify Failure** - Code defect vs test defect vs requirement change
6. **Recommend Fix** - Target correct artifact with reasoning per TQ-2

## Core Responsibilities

1. Determine whether failure indicates real regression or test that no longer reflects intent
2. Identify intent mismatches between test assertions and current business requirements
3. Recommend fix targeting correct artifact (code or test)
4. Flag brittle or misleading tests discovered during diagnosis per TQ-4

## Constraints (Rules Applied)

* **TQ-2**: Determine whether code or test is at fault before fixing either
* **TQ-4**: Failures caused by brittle tests must be escalated for test improvement
* **DT-1**: Document classification reasoning so it can be reviewed
* **GM-2**: Explain diagnosis reasoning before recommending fix
* **GM-4**: All diagnosis must be evidence-based, not assumed

## Tradeoff Handling

**Investigation Depth vs Fix Speed:** Thorough diagnosis takes time but prevents misclassification and recurring failures
**Fix Test vs Fix Code:** Misclassification causes real defects to be hidden; default to thorough investigation

## Failure & Escalation

* Test intent unclear → request clarification before proceeding
* Failure indicates genuine defect → flag bug-diagnosis skill
* Brittle test discovered → flag test-creation-strategy for improvement
* Recurring flaky test → investigate environmental factors

## Skills Flagged

* **bug-diagnosis** - when failure indicates genuine code defect requiring deeper investigation
* **test-creation-strategy** - when test quality issues discovered (brittle tests, unclear assertions)
* **regression-prevention** - when failure reveals inadequate regression coverage
* **correctness-validation** - when test fix reveals correctness issue in code

## Anti-Patterns to Catch

1. Misclassifying real regression as test defect and deleting test
2. Fixing symptom in test without addressing underlying code issue
3. Incomplete investigation leaving ambiguous failures unresolved
4. Assuming flaky tests are "just flaky" without investigating
5. Fixing test to match broken code instead of fixing code
6. Not verifying test intent before modifying assertions
7. Ignoring test quality issues discovered during diagnosis
8. Making changes without understanding why test was written
