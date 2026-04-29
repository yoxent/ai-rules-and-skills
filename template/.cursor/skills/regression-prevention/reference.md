---
name: regression_prevention
description: Detects behavioral regressions introduced by code modifications and blocks completion until regressions are resolved or the change is reverted
version: 1.0
category: Engineering
tags: [testing, regression, quality-gate, verification, stability]
priority: High
depends_on: []
flags_skills: [test-creation-strategy, test-interpretation-failure-diagnosis, correctness-validation]
inputs: [modified or fixed code, existing test suite, change scope definition]
outputs: [regression assessment (CLEAR or REGRESSION_FOUND), coverage gap analysis, revert action or fix if regression detected]
rules_applied: [TQ-3, TQ-1, MF-1, GM-2]
execution_context: Triggered when code is modified, fixed, or refactored; acts as a completion gate blocking completion if behavioral regressions are detected
---

# regression-prevention

## 1. Purpose

regression-prevention is a quality gate that activates whenever code is changed. Its job is to ensure that previously working behavior has not been broken by the change. It does not write tests — that is `test-creation-strategy`'s responsibility. It detects, responds to, and documents regressions. If a regression is found and cannot be fixed within the current scope, it reverts the change and surfaces the finding.

The engineering value is a hard guarantee: no change completes with a known regression.

## 2. When to Use This Skill

**Triggers (flagged from):**
- `bug-diagnosis` — after a fix is applied, verify it does not introduce new failures
- `refactoring` — after any refactor, verify behavior is preserved
- `code-maintenance` — after maintenance changes, verify no unintended side effects
- `test-interpretation-failure-diagnosis` — when a test regression is suspected
- `test-creation-strategy` — when new tests reveal existing regressions

**Do NOT use for:**
- Writing new tests from scratch (use `test-creation-strategy`)
- Validating correctness of new features (use `correctness-validation`)
- Root cause analysis of the original defect (use `bug-diagnosis`)
- Managing the full regression test suite over time (use `regression-test-suite-management`)

**Execution context:** Always the final check before a change-related task completes.

## 3. Inputs

**Required:**
- Modified or fixed code (diff or change description)
- Existing test suite results before and after the change
- Change scope: what was intended to change, and what should remain unchanged

**Optional:**
- Prior behavior specification or acceptance criteria
- Performance baselines if the change is performance-related

**Documents needed:**
- Existing test suite
- Change diff or description
- Prior behavior specification if available

## 4. Outputs

**Primary outputs:**
- Regression assessment: CLEAR (no regressions detected) or REGRESSION_FOUND (with evidence)
- Coverage gap analysis: specific paths in the risk surface lacking test coverage
- If REGRESSION_FOUND: attempted fix, or revert action with documented root cause
- If coverage gap: delegation to `test-creation-strategy` with specific gaps named

**Skill flags triggered:**
- `test-creation-strategy` — when coverage gaps are found, or when a manual regression fix completes and the fixed path needs coverage
- `test-interpretation-failure-diagnosis` — when regression is detected via a failing test, to classify before any fix attempt
- `correctness-validation` — when a regression cannot be fixed within current scope

## 5. Preconditions

- The change being assessed is complete enough to test
- The existing test suite is available or can be reasoned about
- Change scope is defined: what was intended to change vs. what was not

**Validation checks before execution:**
- No test suite exists → flag `test-creation-strategy` before proceeding
- Change scope unclear → request clarification before beginning

## 6. Step-by-Step Execution Procedure

### Step 1 — Identify the regression risk surface

- Review the change diff or description
- Identify all code paths that were modified
- Identify adjacent code that could be affected: callers, dependents, shared state, integration points
- State the risk surface explicitly before proceeding

**Red flags:** Change scope is unclear; modification touches widely-shared interfaces or state

### Step 2 — Assess test coverage for the risk surface

- For each path in the risk surface, determine whether a test exists that would catch a behavioral change
- If coverage is complete → proceed to Step 3
- If coverage gaps exist → flag `test-creation-strategy` with the specific uncovered paths; block until coverage is confirmed

### Step 3 — Execute regression check

- Run or reason through the test suite against the modified code
- Compare results against expected baseline (pre-change behavior)
- Check both directly modified paths and adjacent code that could be affected

**Red flags:** Test failure in code not directly modified; output changes in adjacent systems; previously stable paths now behaving differently

### Step 4 — Respond to findings

**If CLEAR:** Document what was checked, what passed, and the confidence level. Release the completion gate.

**If REGRESSION_FOUND — detected via failing test:**
- Document the failure with evidence: which test failed, what behavior changed, what was expected
- Flag `test-interpretation-failure-diagnosis` to classify: code defect or test defect — do not attempt any fix before classification
  - If code defect: fix the code within current scope (`fix_code`)
    - Fix successful → re-run from Step 3
    - Fix out of scope → revert per MF-1; document root cause; surface to user; flag `correctness-validation`
  - If test defect: flag `test-creation-strategy` to correct the test; do not modify production code

**If REGRESSION_FOUND — detected manually (code inspection, review):**
- Document the finding with evidence
- Fix the code within current scope (`fix_code`)
  - Fix successful → flag `test-creation-strategy` to ensure the fixed path has coverage; re-run from Step 3
  - Fix out of scope → revert per MF-1; document root cause; surface to user; flag `correctness-validation`

### Step 5 — Document outcome

- Always produce a documented outcome — CLEAR or REGRESSION_FOUND with full details per GM-2
- If reverted: explain what caused the regression and what must be addressed before re-attempting
- If coverage was flagged: note what tests were requested and whether they were resolved

## 7. Core Responsibilities

- Identify the regression risk surface from the change scope
- Verify test coverage exists for that surface — block and flag `test-creation-strategy` if not
- Detect behavioral regressions in modified and adjacent code
- Block completion if a regression is found
- When regression is detected via a failing test, flag `test-interpretation-failure-diagnosis` to classify before any fix attempt
- If code defect: attempt fix within scope; if test defect: flag `test-creation-strategy` to correct the test
- If manual regression: attempt fix then flag `test-creation-strategy` to ensure coverage
- Revert per MF-1 if fix exceeds scope
- Document all outcomes with evidence per GM-2

**Quality criteria:**
- Every invocation produces a documented outcome (CLEAR or REGRESSION_FOUND with details)
- No completion without an explicit CLEAR or a documented revert
- Coverage gaps are always flagged, never silently accepted

## 8. Constraints (Rules Applied)

* **TQ-3: Regression Test Coverage** — Require regression test coverage for any fix or change; if the risk surface lacks coverage, flag `test-creation-strategy` and block completion until coverage is confirmed.
* **TQ-1: Test Coverage Requirements** — All modified paths must have test coverage; gaps trigger delegation to `test-creation-strategy`, never silent acceptance.
* **MF-1: Backward Compatibility** — A change that cannot complete without introducing a regression must be reverted; existing behavior may not be unintentionally broken.
* **GM-2: Explain Before Acting** — The outcome (CLEAR, REGRESSION_FOUND, or revert) must be documented with evidence before any action is taken.

## 9. Tradeoff Handling

**Tradeoff 1: Reverting vs. shipping a known regression under deadline pressure**
- Scenario: A regression is found but fixing it is complex and time pressure is high
- Default stance: BLOCK — do not ship a known regression regardless of timeline
- Resolution: Revert per MF-1; create a tracked remediation item; re-attempt with scope that includes the fix

**Tradeoff 2: Partial coverage — some paths covered, risk appears low**
- Scenario: Coverage is incomplete for some paths; risk appears low based on the change
- Default stance: Flag `test-creation-strategy` for uncovered paths; block until confirmed
- Resolution: User may explicitly accept the risk — document as a DT-1 tradeoff; do not silently skip

**Tradeoff 3: Regression fix requires scope expansion**
- Scenario: Fixing the regression requires changes well beyond the original change scope
- Default stance: Revert the original change; address the regression fix as a separate task with its own scope
- Resolution: Document root cause; surface as a new tracked work item

## 10. Failure & Escalation Behavior

**Regression found via failing test**
- Trigger: Test failure detected during regression check
- Action: Flag `test-interpretation-failure-diagnosis` → classify → if code defect: attempt fix or revert per MF-1 and flag `correctness-validation`; if test defect: flag `test-creation-strategy`
- Format: "Test failure in [test]. Classification: [code defect | test defect]. Action: [fix applied | test corrected | change reverted]."

**Regression found manually, fix out of scope**
- Trigger: Regression identified through code inspection; fix exceeds current scope
- Action: Revert change → document root cause → flag `correctness-validation` → surface to user with remediation plan
- Format: "Regression detected in [path]. Root cause: [explanation]. Change reverted. Remediation required: [plan]."

**Coverage gap blocks assessment**
- Trigger: Risk surface identified but test coverage does not exist for it
- Action: Flag `test-creation-strategy` → block completion → do not issue CLEAR
- Format: "Coverage gap: [specific paths]. Delegating to test-creation-strategy before regression check can proceed."

**Scope unclear**
- Trigger: Change description insufficient to identify the regression risk surface
- Action: Request clarification — do not proceed with assumptions
- Format: "Scope unclear. Please clarify: [specific question about what was intended to change vs. remain stable]."

## 11. Skill Integration & Orchestration

This skill is always the final gate before a change-related task completes.

**Upstream (skills that flag this skill):**
- `bug-diagnosis` → after fix applied
- `refactoring` → after refactor complete
- `code-maintenance` → after maintenance change
- `test-interpretation-failure-diagnosis` → when regression suspected
- `test-creation-strategy` → when new tests reveal existing regressions

**Downstream (this skill flags):**
- `test-creation-strategy` — when coverage gaps found, or when manual regression fix completes and path needs coverage, or when failing test is a test defect
- `test-interpretation-failure-diagnosis` — when regression is detected via a failing test, to classify before fixing
- `correctness-validation` — when regression cannot be fixed within scope

## 12. Related Skills

- `test-creation-strategy` — writes the tests this skill uses and delegates to when gaps are found
- `correctness-validation` — escalation target when regression cannot be fixed within scope
- `bug-diagnosis` — diagnoses root causes; typically precedes this skill in the pipeline
- `refactoring` — triggers this skill; refactors must preserve behavior
- `regression-test-suite-management` — manages the full test suite over time; this skill uses it, does not manage it

## 13. Governance Hooks

**Mandatory behaviors:**
- Every invocation must produce a documented outcome (CLEAR or REGRESSION_FOUND with evidence)
- Revert actions must document root cause per GM-2 before being applied
- Coverage gaps must be flagged — never silently accepted
- CLEAR may not be issued without evidence that the risk surface was checked

**Audit trail:**
- Document: what was checked, what passed, what failed, what action was taken
- Link to: the triggering skill, the change scope, any TQ-3 or MF-1 rule applications

## 14. Example Use Cases

**Example 1: Bug fix introduces regression**
A fix to `PaymentProcessor.charge()` is applied. `bug-diagnosis` flags `regression-prevention`. Risk surface: three call sites. Two have test coverage; one (a refund flow) does not. `test-creation-strategy` is flagged for the refund path. After tests are added, the suite runs — the refund path fails. The fix introduced a regression in that path. The fix is revised; all tests pass. CLEAR issued.

**Example 2: Refactor preserves behavior**
Auth middleware is refactored. `refactoring` flags `regression-prevention`. Risk surface: all auth-protected routes. Coverage is complete. Test suite runs. All pass. CLEAR issued and documented.

**Example 3: Regression unfixable within scope**
A maintenance change to a shared utility introduces a regression in a downstream service. The fix requires modifying that service — outside current scope. Change reverted per MF-1. Root cause documented. Flagged as a separate work item.

**Example 4: Coverage gap prevents assessment**
A new caching layer is added. No tests exist for cache invalidation paths. `test-creation-strategy` flagged. CLEAR cannot be issued until tests exist and pass.

## 15. Anti-Patterns to Catch

1. **Shipping with a known regression** — "it's minor, we'll fix it later." Block regardless of size or severity.
2. **Skipping the regression check on small changes** — "it's a one-line fix, nothing could break." All changes go through the gate.
3. **Issuing CLEAR without evidence** — asserting no regression without running or reasoning through tests.
4. **Treating a test failure as flaky without investigation** — investigate every failure before dismissing it.
5. **Fixing the symptom without the root cause** — surface to `bug-diagnosis` if root cause is unclear.
6. **Scope creep during fix** — expanding the change to fix the regression when it should be reverted and re-scoped.
7. **Silently accepting coverage gaps** — if coverage is incomplete, always flag; never assume risk is low enough to skip.
8. **Reverting without documenting root cause** — a revert with no explanation is not an acceptable outcome.

## 16. Non-Goals

- Writing new test cases (delegated to `test-creation-strategy`)
- Root cause analysis of the original defect (delegated to `bug-diagnosis`)
- Validating correctness of new features (use `correctness-validation`)
- Managing the full regression suite over time (use `regression-test-suite-management`)
- Performance regression detection (use `performance-optimization` → `complexity-analyzer`)

## 17. Notes for LLM Implementation

- Always state the outcome explicitly: CLEAR or REGRESSION_FOUND — never leave it ambiguous
- When flagging `test-creation-strategy`, name the specific uncovered paths, not just "coverage is missing"
- When reverting, explain the regression clearly: what failed, what behavior changed, what must be addressed before re-attempting
- Do not silently fix regressions — surface the finding and the fix attempt
- Tone should be definitive: "Regression detected. Change reverted." Not: "There may potentially be a regression."
- If reasoning about tests rather than executing them, state that explicitly and note lower confidence
- When a test fails, always flag `test-interpretation-failure-diagnosis` first — never assume the test is correct or incorrect without classification

## 18. Version History

- **v1.1.0** (2026-04-26): Split `regression_detected` into two distinct paths: `regression_detected_failing_test` (routes through `test-interpretation-failure-diagnosis` for classification before any fix) and `regression_detected_manually` (attempts fix directly, then flags `test-creation-strategy` for coverage). Added `test-interpretation-failure-diagnosis` to `flags_skills`. Added PROHIBIT: fixing test-detected failures before classification.
- **v1.0.0**: Initial creation
