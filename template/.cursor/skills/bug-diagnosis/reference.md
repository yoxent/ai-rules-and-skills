# Skill Human Spec: Bug Diagnosis

```yaml
---
name: bug-diagnosis
description: Identifies, isolates, and documents defects by tracing logic failures from symptoms to root causes
version: 1.0.0
category: Engineering
tags: [debugging, root-cause-analysis, defect-investigation, troubleshooting]
priority: High
depends_on: []
flags_skills: [test-creation-strategy, error-handling-resilience, performance-optimization, technical-debt-management]
inputs: [bug_reports, user_symptoms, logs, stack_traces, error_messages, code_paths, recent_changes]
outputs: [root_cause_analysis, reproduction_steps, recommended_fix, investigation_path]
rules_applied:
  - MF-4  # Root Cause Analysis
  - DT-1  # Explicit Tradeoff Logging
  - TQ-3  # Regression Prevention
  - GM-2  # Explain Before Acting
  - GM-4  # Behavioral Transparency
documents_needed: [incident-reports, production-logs]
execution_context: Runs when bugs reported, production incidents occur, or anomalies detected
---
```

# Skill: Bug Diagnosis

## Purpose

Identifies, isolates, and documents defects by tracing logic failures from observed symptoms to root causes using evidence-based investigation.

## When to Use This Skill

**Triggers:**
* Bug reports from users or QA
* Production incidents or anomalies
* Unexpected behavior in testing
* Data corruption or inconsistency detected
* Performance degradation traced to logic issue
* Error logs showing unusual patterns

**Do NOT use for:**
* Test failures (use test-interpretation-failure-diagnosis first)
* Expected errors or validation failures
* Feature requests disguised as bugs
* Performance issues without logic defects

**Execution Context:** Runs when bugs reported or production incidents occur. Critical for production issues.

## Inputs & Outputs

**Required inputs:**
* Bug reports, user-reported symptoms, or anomaly observations
* Logs, stack traces, and error messages
* Relevant code paths and recent changes

**Primary outputs:**
* Root cause analysis with evidence
* Reproduction steps
* Recommended fix or investigation path

## Step-by-Step Execution

1. **Reproduce Issue** - Verify bug exists, create minimal reproduction case
2. **Gather Evidence** - Collect logs, stack traces, state snapshots
3. **Trace from Symptom to Cause** - Follow logic backward from observed failure
4. **Distinguish Symptom from Root Cause** - Identify actual origin, not just manifestation
5. **Document Findings** - Evidence-based analysis per GM-4, reproduction steps
6. **Recommend Fix** - Target root cause, not symptom per MF-4

## Core Responsibilities

1. Reproduce issue before proposing fix
2. Trace logic failure from symptom to origin
3. Distinguish between symptoms and causes
4. Document findings clearly for review and prevention per MF-4

## Constraints (Rules Applied)

* **MF-4**: Recurring issues require root cause documentation, not just symptom patching
* **DT-1**: When quick patch applied instead of full fix, log the debt
* **TQ-3**: Fixes must include or trigger regression test coverage
* **GM-2**: Explain diagnosis reasoning before recommending fix
* **GM-4**: All diagnosis must be evidence-based, not guessed

## Tradeoff Handling

**Investigation Thoroughness vs Fix Urgency:** Production incidents may require quick patch first, but root cause analysis must follow
**Fix Symptom vs Fix Root Cause:** Quick patches acceptable when logged as debt with follow-up plan

## Failure & Escalation

* Bug cannot be reproduced → request more context, avoid assumptions
* Bug manifests as performance regression → flag performance-optimization
* Bug reveals unsafe failure path → flag error-handling-resilience
* Root cause requires architectural change → flag technical-debt-management

## Skills Flagged

* **test-creation-strategy** - when bug reveals test coverage gap
* **error-handling-resilience** - when bug reveals unsafe failure path
* **performance-optimization** - when bug manifests as performance regression
* **technical-debt-management** - when root cause requires architectural change

## Anti-Patterns to Catch

1. Fixing symptoms without addressing root cause (leads to recurrence)
2. Guessing at root cause without evidence (introduces new defects)
3. Missing reproduction path (shipping fix that doesn't address real issue)
4. Not documenting diagnosis for future reference
5. Skipping regression test after fix
6. Assuming recent changes caused bug without verification
7. Patching without understanding why bug occurred
8. Closing bug without confirming fix works
