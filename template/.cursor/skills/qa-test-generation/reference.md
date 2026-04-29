# Skill Human Spec
# File: qa-test-generation-docs.md
# Purpose: Human-readable comprehensive documentation
# NEVER loaded into agent context — for human review, authoring, and maintenance only

---

```yaml
---
name: qa-test-generation
description: Generates functional test cases, edge cases, and regression scenarios for Unity features. Framework-agnostic. Test design only.
version: 1.0.0
category: QA & Diagnostics
tags: [unity, testing, test-cases, edge-cases, regression, automation, qa, functional]
priority: High

depends_on: [testing-standards, playtest-diagnostics]
flags_skills: [playtest-diagnostics]

inputs: [feature-description, acceptance-criteria, issue-list, regression-targets]
outputs: [test-cases, automation-ready-flag]

rules_applied:
  - TQ-1   # Test Coverage — ensure nominal, edge, error, and regression cases are generated
  - TQ-3   # Regression — confirmed issues must produce regression test cases
  - TQ-4   # Test Quality — tests must have unambiguous steps, inputs, and expected results
  - PS-3   # Scope Control — test design only; do not execute tests or modify code
  - DA-6   # Pragmatic — balance thoroughness with practicality; avoid test case proliferation

documents_needed: [testing-standards, feature-spec-or-acceptance-criteria]

execution_context: Stage 5 / QA & diagnostics. Runs after a feature is specified (acceptance criteria available) or after playtest-diagnostics identifies issues requiring regression coverage. Produces test cases for manual or automated QA execution.
---
```

---

# Skill: QA Test Generation

---

## Purpose

**What this skill does:**
Generates structured test cases for Unity game features, covering nominal (happy path) flows, edge and boundary conditions, error paths, and regression scenarios for known issues. All output is framework-agnostic — test cases are written in a structured format that can be executed manually or translated into any automation framework.

Structured test cases are the foundation of reliable QA coverage. Without them, QA is ad-hoc and regressions go undetected. Well-designed test cases reduce post-release defect rates, accelerate QA cycles by giving testers a clear playbook, and provide engineers with automation-ready specifications that reduce the cost of maintaining a test suite.

Framework-agnostic test case design decouples the test intent from any specific test runner, making cases portable across Unity Test Runner, NUnit, custom automation frameworks, or manual execution checklists. Clear preconditions, steps, and expected results eliminate ambiguity in both manual and automated execution.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new Unity feature has been specified with acceptance criteria and needs test coverage designed
* `playtest-diagnostics` has identified confirmed or suspected issues requiring regression test cases
* An existing feature is being modified and regression coverage needs to be updated
* A high-risk area of the game (combat, inventory, progression) needs structured edge case coverage
* Pre-sprint QA planning requires test case inventory for upcoming features
* A bug has been fixed and a non-regression test is needed to prevent recurrence

### Do NOT use this skill for:

* Executing tests — this skill designs tests; execution is a separate QA process
* Modifying game code or Unity assets in response to test failures
* Selecting or configuring a test automation framework — this skill is framework-agnostic by design
* Performing the diagnostic analysis of failures — use `playtest-diagnostics` for that

**Execution Context Details:**
This skill runs at the intersection of feature specification and QA execution. It consumes acceptance criteria (from product/engineering) or issue lists (from `playtest-diagnostics`) and produces test cases for QA to execute. The `automation_hint` field on each test case guides the QA team on automation suitability.

---

## Inputs

**Required inputs:**

* **Feature description or acceptance criteria** — A description of the feature to test, ideally with acceptance criteria in Given/When/Then or equivalent form. Used to derive nominal and edge test cases.

**Optional inputs:**

* **Issue list from playtest-diagnostics** — Confirmed or suspected issues from a prior diagnostic run. Used to generate regression test cases for each issue.
* **Regression targets** — Specific areas or scenarios the team wants regression coverage for (e.g., "test all inventory operations after the save system refactor").
* **Existing test case inventory** — If the team already has test cases, these prevent duplication and identify gaps.

**Documents/Context needed:**

* **testing-standards** — Defines the project's test severity levels, what constitutes a passed test, and what environments test cases should be executable in.
* **Feature spec or acceptance criteria document** — Required to derive nominal case inputs; without at least one acceptance criterion, edge cases cannot be bounded correctly.

---

## Outputs

**Primary outputs:**

* **Test cases** — A structured list of test cases, each with ID, title, type, preconditions, steps, expected results, and automation hint.
* **Automation-ready flag** — A boolean indicating whether the majority of generated test cases are structured sufficiently for automation.

**Output format:**

```json
{
  "test_cases": [
    {
      "id": "",
      "title": "",
      "type": "",
      "preconditions": [],
      "steps": [],
      "expected_results": [],
      "automation_hint": ""
    }
  ],
  "automation_ready": true
}
```

**Type values:** `nominal` | `edge` | `boundary` | `error` | `regression`

**automation_hint values:** `Automatable` (with reasoning) | `Manual` (with reasoning) | `Automatable-with-tooling` (specify what tooling)

**Skill flags (if applicable):**

* Flag **playtest-diagnostics** when test execution reveals new failures that require diagnostic analysis before new regression cases can be written.

---

## Preconditions

**Conditions that must be met before execution:**

* At least one acceptance criterion, feature description, or confirmed issue is available as input
* The feature scope is bounded — an unbounded "test everything" request cannot produce quality test cases

**Validation checks:**

* [ ] Is there at least one acceptance criterion or feature description to derive nominal cases from?
* [ ] If regression cases are requested, is there a confirmed issue list or bug description available?
* [ ] Is the test scope bounded (specific feature, system, or issue — not the entire game)?

---

## Step-by-Step Execution Procedure

### Step 1: Parse and Classify the Test Scope

**Questions to answer:**
- What is the feature or system being tested?
- What acceptance criteria are defined?
- Are regression cases needed for specific confirmed issues?
- What types of test cases are most valuable for this scope (nominal, edge, regression)?

**Actions:**
- [ ] List the acceptance criteria or feature behaviors that define the test boundary
- [ ] Identify whether this is a new feature (nominal + edge focus) or a fix validation (regression focus)
- [ ] Determine the test environment context (editor play mode, standalone build, specific platform)
- [ ] Request the feature spec if acceptance criteria are not provided

**Red flags / Warning signs:**
- Scope is "test the whole game" — too broad; request to narrow to a specific feature or system
- No acceptance criteria and no issue list — cannot generate bounded test cases

**Decision points:**
- If scope is too broad, decompose into sub-features and generate test cases per sub-feature

---

### Step 2: Generate Nominal (Happy Path) Cases

**Questions to answer:**
- What is the expected user/player flow for this feature?
- What inputs produce the expected correct output?
- What does success look like, measurably?

**Actions:**
- [ ] For each acceptance criterion, write at least one nominal test case
- [ ] Ensure each nominal case has unambiguous steps and a single measurable expected result
- [ ] Write expected results in observable terms: "Player sees X" not "system does Y internally"

**Quality checks:**
- Each step is a specific action, not a vague instruction ("Click the Play button" not "Start the game")
- Expected result is observable and binary — pass or fail is determinable without interpretation

**Red flags / Warning signs:**
- Expected result contains subjective language ("game should feel responsive") — quantify or exclude
- Steps skip prerequisite state setup — always include preconditions for each test case

---

### Step 3: Generate Edge and Boundary Cases

**Questions to answer:**
- What are the minimum and maximum valid inputs for this feature?
- What inputs are at or just beyond the boundary of valid behavior?
- What states could the feature encounter that are technically valid but uncommon?

**Actions:**
- [ ] Identify numeric boundaries (min, max, min-1, max+1) for any numeric inputs
- [ ] Identify state boundaries (empty inventory, full inventory, zero health, max health)
- [ ] Identify sequence edge cases (action performed before initialization, action performed twice rapidly)
- [ ] For each boundary, write one test case for the valid boundary value and one for just outside it

**Red flags / Warning signs:**
- Feature has numeric inputs but no boundary cases — always generate at least min, max, and one over-max
- Async operations without a test for "trigger X before Y completes" pattern

**Decision points:**
- If the number of edge cases is very large (>15 for one feature), prioritize the highest-risk boundaries and note which were omitted for time

---

### Step 4: Generate Error Path Cases

**Questions to answer:**
- What happens when invalid inputs are provided?
- What happens when required resources are unavailable (network offline, save file corrupt, required prefab missing)?
- What error messages or fallback behaviors are expected?

**Actions:**
- [ ] For each input, generate a test case with an invalid or unexpected value
- [ ] Include cases for missing dependencies (prefab unassigned, scene not loaded, service unavailable)
- [ ] Define the expected error state: message shown, fallback activated, or graceful degradation

**Red flags / Warning signs:**
- Error path test expects a crash — the expected result should be graceful handling, not a crash (unless testing that the crash reporter fires correctly)
- No error path cases for network or persistence features — these are always high-risk paths

---

### Step 5: Generate Regression Cases for Confirmed Issues

**Questions to answer:**
- For each confirmed issue from playtest-diagnostics, what sequence of actions triggered it?
- What is the expected correct behavior post-fix?
- Is the reproduction path deterministic enough to automate?

**Actions:**
- [ ] For each confirmed issue, write one regression test case that:
  - Reproduces the exact conditions that triggered the issue (as defined in the diagnostic report)
  - Defines the expected correct behavior after the fix
  - Is labeled `type: regression` with a reference to the issue ID from the diagnostic report
- [ ] Mark regression cases with the issue ID in the title for traceability

**Red flags / Warning signs:**
- Issue from diagnostics is labeled POSSIBLE (not CONFIRMED) — regression case can still be written but note that the reproduction path is uncertain; label as "Regression-Exploratory"
- No reference to the diagnostic issue ID in the regression case — always include for traceability

---

### Step 6: Classify Automation Suitability

**Questions to answer:**
- Can this test be executed without human perception judgments?
- Can the preconditions be programmatically established?
- Can the expected result be asserted without visual inspection?

**Actions:**
- [ ] For each test case, assign `automation_hint`:
  - `Automatable`: all steps are programmatic; expected result is assertable in code
  - `Manual`: requires visual inspection, platform-specific behavior, or subjective judgment
  - `Automatable-with-tooling`: automatable with a specific named tool (e.g., "Unity Test Runner with PlayMode tests," "Screenshot comparison tool")
- [ ] Set `automation_ready: true` if >50% of cases are `Automatable` or `Automatable-with-tooling`

**Red flags / Warning signs:**
- Marking all cases as `Automatable` without verifying that preconditions can be programmatically established
- Marking visual/audio cases as `Automatable` — these typically require human or specialized tool judgment

---

### Final Step: Generate Test Case Report

**Report/Output structure:**

```markdown
## QA Test Generation Report

**Feature / Scope:** [Feature name or issue reference]
**Date:** [YYYY-MM-DD]
**Input:** [Acceptance criteria / issue list / regression targets]
**Status:** COMPLETE / PARTIAL

### Test Case Summary
| # | ID | Title | Type | Automation |
|---|----|-------|------|------------|
| 1 | TC-001 | Load Level 3 — nominal | nominal | Automatable |

### Test Cases

**TC-001: [Title]**
- Type: nominal / edge / boundary / error / regression
- Preconditions:
  - [List each precondition]
- Steps:
  1. [Specific action]
  2. [Specific action]
- Expected Results:
  - [Observable, binary outcome]
- Automation Hint: [Automatable / Manual / Automatable-with-tooling — reason]

---

### Coverage Summary
- Nominal cases: [N]
- Edge/boundary cases: [N]
- Error path cases: [N]
- Regression cases: [N]
- Total: [N]
- Automation-ready: [true/false]

### Skills Flagged
- playtest-diagnostics: [Reason if flagged]
```

---

## Core Responsibilities

1. Generate test cases that cover all four case types: nominal, edge/boundary, error path, and regression (TQ-1)
2. Produce regression cases for every confirmed issue from `playtest-diagnostics` (TQ-3)
3. Ensure every test case has unambiguous preconditions, steps, and expected results (TQ-4)
4. Classify each test case for automation suitability with reasoning (DA-6)
5. Bound all test generation to the stated feature scope — no "test everything" expansion (PS-3)
6. Remain framework-agnostic — write tests that can be executed manually or translated to any framework
7. Never execute tests or modify code — test design only (PS-3)

**Quality criteria:**

* Every test case has at least one precondition, two or more steps, and one observable expected result
* Expected results are binary (pass/fail determinable without interpretation)
* Regression cases reference the diagnostic issue ID
* `automation_hint` is populated with reasoning for every case

---

## Constraints (Rules Applied)

### Testing & Quality Rules

* **TQ-1: Test Coverage**
  - How this rule applies: Every test generation run must produce cases across all four types. A set of only nominal cases is incomplete coverage by definition.
  - In practice: Minimum coverage: 1+ nominal, 2+ edge/boundary, 1+ error path per feature. Regression as needed.

* **TQ-3: Regression**
  - How this rule applies: Every confirmed issue from a diagnostic report must produce at least one regression test case.
  - In practice: When an issue list is provided, loop through each CONFIRMED issue and generate one regression case before moving to new feature cases.

* **TQ-4: Test Quality**
  - How this rule applies: Test cases with ambiguous steps or subjective expected results are invalid. Every case must be executable by a tester who has never seen the feature before.
  - In practice: "Click the Play button on the Main Menu" is valid. "Start the game appropriately" is not.

### Product & Stakeholder Rules

* **PS-3: Scope Control**
  - How this rule applies: Test design only. No test execution, no code modification, no framework selection.
  - In practice: If asked to "run the tests," redirect to QA execution. If asked to "fix the code," redirect to engineering skills.

### Design & Architecture Rules

* **DA-6: Pragmatic**
  - How this rule applies: Prioritize the highest-value test cases. An exhaustive set of low-value cases is less useful than a focused set of high-value ones.
  - In practice: If a feature has 30 possible edge cases, generate the 10 highest-risk ones and note the remainder. Don't generate every permutation for its own sake.

---

## Tradeoff Handling

### Tradeoff 1: Thoroughness vs Practicality

```
CONFLICT: Comprehensive coverage would produce 50+ test cases; QA bandwidth only supports 15.
DEFAULT: Prioritize by risk: regression > error paths > boundary > edge > additional nominal.
RESOLUTION:
  IF bandwidth_constraint_stated → generate to budget; note cases omitted and their risk
  IF no_constraint_stated → generate full set; note high-risk cases for prioritization
→ Log decision via: DT-1 if cases are omitted
→ Example: "Generated 15 of 32 possible cases; omitted 17 low-risk nominal variants."
```

### Tradeoff 2: Automation vs Correctness

```
CONFLICT: Making a test automatable may require simplifying the scenario, losing coverage fidelity.
DEFAULT: Correctness over automation convenience. Write the accurate test first; note if automation requires simplification.
RESOLUTION:
  IF automation_simplification_preserves_intent → note the simplification; mark Automatable
  IF automation_simplification_loses_coverage → mark Manual; note what is lost by automating
→ Never sacrifice test accuracy to achieve an Automatable label.
```

### Tradeoff 3: Framework-Agnostic vs Specific Tool Guidance

```
CONFLICT: Team may benefit from tool-specific guidance; maintaining framework-agnosticism limits this.
DEFAULT: Keep cases framework-agnostic; use automation_hint to suggest tools without prescribing them.
RESOLUTION:
  IF a_specific_tool_is_known_to_the_team → note it in automation_hint as a suggestion
  IF no_framework_is_specified → omit framework references entirely from steps
→ Steps describe actions and assertions, not API calls or framework constructs.
```

---

## Failure & Escalation Behavior

### Scenario 1: No Acceptance Criteria Provided

**Trigger:** Feature description is provided but no acceptance criteria or observable success definition is given.

**Action:**
- Request at least one acceptance criterion before generating nominal cases
- Can generate error path and boundary cases based on the feature description alone; flag these as lacking nominal verification
- Do not block entirely — generate what can be generated; mark nominal cases as INCOMPLETE pending criteria

**Escalation:** Soft block on nominal cases; surface the gap; continue with edge and error cases.

---

### Scenario 2: Issue List Contains Only POSSIBLE-Level Issues

**Trigger:** `playtest-diagnostics` provides suspected issues but none are CONFIRMED — all are POSSIBLE.

**Action:**
- Generate regression cases for POSSIBLE issues labeled as "Regression-Exploratory"
- Note that reproduction path is uncertain; the case may need refinement after the issue is confirmed
- Do not block regression generation — early coverage is better than no coverage

**Escalation:** Deliver exploratory regression cases; recommend re-running `playtest-diagnostics` with more log data to confirm.

---

### Scenario 3: Scope Exceeds Practical Test Case Volume

**Trigger:** Feature scope or regression target implies generating more than 30 test cases without bandwidth guidance.

**Action:**
- Generate a prioritized subset (15-20 cases) covering the highest-risk paths
- List the omitted case types with their risk classification
- Request bandwidth confirmation before expanding the set

**Escalation:** Deliver prioritized subset with gap analysis; await confirmation to expand.

---

### Scenario 4: Test Execution Request

**Trigger:** User asks this skill to execute tests or verify results.

**Action:**
- Redirect: test execution is outside this skill's scope
- Deliver the test cases designed for execution by the QA team or test runner
- Note that `playtest-diagnostics` can analyze the results of executed tests

**Escalation:** Redirect without blocking; deliver test cases.

---

### When to halt execution:

* The feature scope is completely undefined and cannot be bounded through clarification
* No acceptance criteria, issue list, or feature description is available in any form

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
This skill translates feature specifications and diagnostic findings into executable test coverage. It consumes upstream outputs (acceptance criteria, issue lists) and produces test cases for QA teams and automation frameworks.

### How This Skill Integrates

1. **playtest-diagnostics** (upstream) provides confirmed issues → this skill generates regression cases
2. Feature spec/acceptance criteria (upstream) → this skill generates nominal and edge cases
3. **qa-test-generation** (this skill) produces test cases for QA execution or automation
4. **playtest-diagnostics** (downstream/flagged) analyzes new failures surfaced during test execution

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Test execution reveals new failures | playtest-diagnostics | New failures require diagnostic analysis before regression cases can be written |

---

## Related Skills

**Skills this skill depends on:**
- **testing-standards** — defines the project's test categories, environments, and pass/fail criteria
- **playtest-diagnostics** — provides confirmed issue lists that drive regression case generation

**Skills this skill cooperates with:**
- **playtest-diagnostics** — bidirectional: receives issue lists; can flag back when new failures emerge
- **performance-optimization** — test cases may include performance-assertion cases derived from profiler findings

**Skills this skill may invoke/flag:**
- **playtest-diagnostics** — flagged when test execution reveals new failures requiring diagnostic analysis

---

## Governance Hooks

* [ ] Generate all four test case types (nominal, edge, error, regression) for every feature scope (TQ-1)
* [ ] Produce regression cases for every confirmed issue from playtest-diagnostics (TQ-3)
* [ ] Ensure every test case has unambiguous steps and binary expected results (TQ-4)
* [ ] Never execute tests or modify code (PS-3)
* [ ] Classify automation suitability with reasoning for every case

**Audit trail requirements:**

* Coverage summary table in every output (counts by type)
* Regression cases reference the diagnostic issue ID
* Omitted cases documented with risk classification when scope was narrowed

---

## Example Use Cases

### Example 1: New Feature — Save System

**Scenario:** The save system has been implemented with these acceptance criteria: (1) Player can save at a checkpoint, (2) Game loads saved state on restart.

**Inputs provided:**
- Acceptance criteria as above
- testing-standards: nominal and regression cases required for all persistence features

**Execution steps:**
1. Parse: 2 acceptance criteria → 2 nominal cases minimum; persistence = high-risk → prioritize error paths
2. Nominal: TC-001 (Save at checkpoint → state persists), TC-002 (Load game → correct state restored)
3. Edge/boundary: TC-003 (Save with full inventory), TC-004 (Save with empty inventory), TC-005 (Load when save file is missing)
4. Error paths: TC-006 (Save fails — disk full simulation), TC-007 (Save file corrupt → graceful fallback)
5. Automation: TC-001, TC-002, TC-005 → Automatable (programmatic state setup and assertion); TC-006, TC-007 → Manual (requires environment simulation)
6. automation_ready: true (>50% automatable)

**Result:** COMPLETE — 7 test cases, 3 automatable

**Skills flagged:** None

---

### Example 2: Regression Coverage from Diagnostic Report

**Scenario:** `playtest-diagnostics` confirmed NullReferenceException in Level 3 scene load (Issue #1).

**Inputs provided:**
- Diagnostic report with Issue #1: CONFIRMED NullReferenceException on Level 3 load (EnemySpawner.SpawnPrefab unassigned)

**Execution steps:**
1. Parse: 1 regression case required for Issue #1
2. Regression TC-REG-001: "Level 3 load — EnemySpawner with unassigned SpawnPrefab" — type: regression; ref Issue #1
3. Steps: (1) Open Level 3 scene, (2) Clear EnemySpawner.SpawnPrefab field in Inspector, (3) Enter Play Mode
4. Expected result: "No NullReferenceException; EnemySpawner logs a clear error and disables gracefully"
5. Automation hint: Automatable-with-tooling (Unity Test Runner PlayMode test; requires Inspector field manipulation API)
6. Add nominal case: TC-001 Level 3 load with SpawnPrefab assigned → game starts normally

**Result:** COMPLETE — 2 test cases (1 regression, 1 nominal confirm)

**Skills flagged:** None

---

### Example 3: Edge Cases for Combat System

**Scenario:** Combat system needs edge case coverage before a milestone release.

**Inputs provided:**
- Feature: player melee attack system
- Known boundaries: attack damage range 1-999, attack cooldown 0.1s min
- No issue list

**Execution steps:**
1. Parse: edge/boundary focus; no regressions
2. Boundary: TC-001 (damage=1, min), TC-002 (damage=999, max), TC-003 (damage=0, below min — should clamp or reject), TC-004 (damage=1000, over max)
3. Boundary: TC-005 (attack at exactly cooldown boundary — 0.1s), TC-006 (attack before cooldown expires)
4. Edge: TC-007 (attack while dead — no damage applied), TC-008 (attack target with 1 HP — exact kill), TC-009 (attack during scene transition)
5. Error: TC-010 (attack with no weapon equipped), TC-011 (attack while stunned)
6. Automation hints: TC-001-TC-008 → Automatable; TC-009 → Manual (scene transition timing); TC-010, TC-011 → Automatable
7. automation_ready: true

**Result:** COMPLETE — 11 test cases covering 5 boundary, 3 edge, 3 error scenarios

**Skills flagged:** None

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Writing expected results in subjective terms ("game should feel smooth")
✅ **Correct approach:** Expected results must be binary and observable. "FPS remains above 55 for the duration of the sequence" is testable; "feels smooth" is not.

❌ **Anti-pattern 2:** Generating only nominal (happy path) test cases
✅ **Correct approach:** Every test generation run must include edge/boundary, error path, and regression cases. Nominal-only coverage misses the most common failure modes.

❌ **Anti-pattern 3:** Writing test steps that skip required preconditions
✅ **Correct approach:** Every test case must list all preconditions required to reach the starting state. A tester who has never seen the feature must be able to set up and execute the case without additional guidance.

❌ **Anti-pattern 4:** Generating regression cases without referencing the diagnostic issue ID
✅ **Correct approach:** Every regression case must cite the diagnostic issue ID it covers in the title and in the case metadata. Traceability is required.

❌ **Anti-pattern 5:** Marking visual or audio cases as Automatable without specifying the required tooling
✅ **Correct approach:** Visual/audio assertions require specialized tools (screenshot diff, audio analysis). Mark as `Automatable-with-tooling` and specify what tooling is needed.

❌ **Anti-pattern 6:** Generating 40+ test cases for a simple feature without prioritization
✅ **Correct approach:** Apply DA-6 pragmatism. Prioritize by risk; generate the highest-value cases first; note omissions with risk reasoning.

❌ **Anti-pattern 7:** Accepting "test the whole game" as a valid scope
✅ **Correct approach:** Scope must be bounded. Request the specific feature, system, or issue list before generating cases. Unbounded scope produces unusable output.

❌ **Anti-pattern 8:** Writing framework-specific API calls in test steps
✅ **Correct approach:** Steps describe actions and assertions in natural language. "Assert player health equals 50" not "Assert.AreEqual(player.Health, 50)". Framework translation is the implementer's job.

❌ **Anti-pattern 9:** Proposing to execute tests as part of this skill's output
✅ **Correct approach:** This skill designs test cases. Execution is a separate process. If asked to run tests, deliver the test cases and redirect.

❌ **Anti-pattern 10:** Failing to set `automation_ready` flag based on actual case analysis
✅ **Correct approach:** Evaluate each case's automation suitability before setting the flag. The flag must reflect the actual composition of the case set, not an optimistic assumption.

---

## Non-Goals

* **Test execution** — handled by QA teams or automation frameworks using these test cases; this skill produces cases only
* **Framework configuration or tooling setup** — framework selection and tooling is outside this skill's scope
* **Code fixes for failing tests** — handled by engineering skills; this skill designs tests
* **Diagnostic analysis of test failures** — handled by `playtest-diagnostics`; this skill generates tests

---

## Notes for LLM Implementation

1. **Preconditions before steps**: Every test case must list preconditions that establish the starting state before step 1. Missing preconditions make cases non-executable.
2. **Binary expected results**: Write every expected result so that a tester can determine pass/fail without interpretation. If a result is ambiguous, rewrite it or mark it as requiring human judgment.
3. **Four types every time**: Never deliver a test generation output with only nominal cases. Edge/boundary, error, and regression coverage must be represented.
4. **Regression always references the issue**: A regression case without a diagnostic issue ID reference is not traceable and loses its value over time.
5. **automation_hint is not optional**: Every test case must have an `automation_hint` field with reasoning. Unmarked cases create ambiguity in QA planning.

**Output format:**
- Always produce the JSON output shape defined in the Outputs section
- Always produce the markdown Test Case Report from the Final Step
- Coverage summary table is mandatory at the end of every output

**Tone and approach:**
- Precise and actionable: test steps should read as instructions a QA tester can follow immediately
- Risk-aware: higher-risk cases (error paths, regressions) are noted as such
- Framework-neutral: no testing framework syntax in steps or expected results

---

## Metadata Summary

```yaml
name: qa-test-generation
category: QA & Diagnostics
priority: High
depends_on: [testing-standards, playtest-diagnostics]
flags_skills: [playtest-diagnostics]
rules_applied: [TQ-1, TQ-3, TQ-4, PS-3, DA-6]
documents_needed: [testing-standards, feature-spec-or-acceptance-criteria]
tags: [unity, testing, test-cases, edge-cases, regression, automation, qa, functional]
```

**Key relationships:**
- Depends on: testing-standards (test taxonomy and environments), playtest-diagnostics (confirmed issue lists for regression)
- Flags: playtest-diagnostics (new failures from test execution requiring diagnosis)
- Governed by: TQ-1 (coverage breadth), TQ-3 (regression mandate), TQ-4 (case quality), PS-3 (test design only), DA-6 (pragmatic prioritization)

---

*End of Skill Human Spec — qa-test-generation-docs.md*
