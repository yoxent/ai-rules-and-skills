# Skill Human Spec: Testing Standards

```yaml
---
name: testing-standards
description: Enforces Unity test conventions using Unity Test Framework, EditMode/PlayMode separation, and NSubstitute mocking for isolated unit tests
version: 1.0.0
category: Quality
tags: [unity, testing, utf, editmode, playmode, nsubstitute, code-coverage]
priority: High

depends_on: [code-standards]
flags_skills: []

inputs: [test_scripts, system_under_test, mock_dependencies, test_runner_results]
outputs: [test_assessment, violations_list, corrected_patterns, approval_status]

rules_applied:
  - TQ-1   # Test Coverage Baseline
  - TQ-2   # Test Isolation
  - TQ-3   # Test Naming
  - TQ-4   # Test Determinism

documents_needed: [project_test_conventions, existing_test_suites]

execution_context: Runs after code-standards on test scripts and systems under test; validates UTF usage, EditMode/PlayMode placement, and NSubstitute isolation
---
```

---

# Skill: Testing Standards

---

## Purpose

**What this skill does:**
Enforces Unity test conventions: Unity Test Framework (UTF) over raw NUnit/xUnit standalone runners, EditMode tests for logic and PlayMode tests for runtime behaviour, NSubstitute for interface-based mocking, descriptive `Given_When_Then` test names, and code coverage thresholds per TQ-1. Ensures tests are isolated, deterministic, and placed in the correct test assembly.

Untested game logic accumulates regression bugs that are expensive to catch late. Consistent test conventions allow any team member to understand, run, and extend the test suite without tribal knowledge. Coverage thresholds prevent silent degradation of test quality over release cycles.

UTF EditMode tests run without entering Play Mode — they are fast and suitable for pure logic. PlayMode tests validate MonoBehaviour lifecycle, coroutines, and physics. NSubstitute isolates the system under test from engine dependencies and slow collaborators. Deterministic tests eliminate flaky failures that erode trust in CI.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new test file is created or modified
* A test references engine types from an EditMode assembly
* A test class lacks the `[TestFixture]` or `[UnityTest]` attribute
* Mock objects are created with `new FakeXxx()` instead of NSubstitute
* Test methods use non-descriptive names (`Test1`, `TestMethod`)
* A PlayMode test validates pure logic with no MonoBehaviour dependency
* Code coverage drops below project threshold

### Do NOT use this skill for:

* CI/CD pipeline configuration — use DevOps conventions
* Performance profiling tests — use performance-optimization
* Test data generation for content — use procedural-content

**Execution Context Details:**
Runs after code-standards on test scripts. Works alongside qa-test-generation when generating new test suites from scratch.

---

## Inputs

**Required inputs:**

* **Test scripts** — Any .cs file in an `Editor Tests` or `Play Mode Tests` asmdef assembly
* **System under test** — The MonoBehaviour, ScriptableObject, or plain C# class being tested

**Optional inputs:**

* **Mock dependencies** — Interface substitutes created via NSubstitute
* **Test runner results** — XML output from UTF for coverage analysis

**Documents/Context needed:**

* **Project test conventions** — Documented coverage thresholds, naming conventions, and assembly layout
* **Existing test suites** — To validate alignment with established patterns per DA-7

---

## Outputs

**Primary outputs:**

* **Test assessment** — Pass/Fail/Needs Review per test convention category
* **Violations list** — Wrong assembly, raw mocks, non-descriptive names, non-deterministic logic
* **Corrected patterns** — Before/after for each violation
* **Approval status** — Whether tests meet UTF standards

**Output format:**

* Structured report with sections: Assembly Placement, Test Naming, Isolation & Mocking, Determinism, Coverage
* Code blocks for all corrections

**Skill flags (if applicable):**

* No downstream flags — testing-standards is a quality gate

---

## Preconditions

**Conditions that must be met before execution:**

* Unity Test Framework package is installed (com.unity.test-framework in manifest)
* NSubstitute is installed and available to test assemblies
* code-standards has passed for test scripts
* Test assembly (.asmdef) exists with correct engine access flags

**Validation checks:**

* [ ] com.unity.test-framework present in manifest
* [ ] NSubstitute referenced in test assembly .asmdef
* [ ] Test assembly configured with `includeTestAssemblies: true`

---

## Step-by-Step Execution Procedure

### Step 1: Validate Test Assembly Placement

**Questions to answer:**
- Is the test in the correct assembly — EditMode for pure logic, PlayMode for MonoBehaviour/coroutine/physics?

**Actions:**
- [ ] Identify whether the test uses `MonoBehaviour`, `IEnumerator` (UnityTest), or Play Mode bootstrapping
- [ ] Check the .asmdef for the test file — confirm `testPlatforms: ["EditMode"]` or `["PlayMode"]`
- [ ] Flag if a PlayMode test contains no engine types — should be EditMode for speed

**Red flags / Warning signs:**
- `[UnityTest]` attribute in an EditMode assembly — requires PlayMode runner
- Pure arithmetic or data-transform test in PlayMode assembly — unnecessarily slow

**Decision points:**
- Engine-dependent test in EditMode → BLOCK, move to PlayMode assembly
- Pure logic test in PlayMode → warn, move to EditMode for speed

---

### Step 2: Validate Test Naming Convention

**Questions to answer:**
- Does the test method name describe the scenario being tested?

**Actions:**
- [ ] Verify test method follows `MethodName_GivenCondition_ExpectedBehavior` or `Given_Condition_When_Action_Then_Result` pattern
- [ ] Flag names like `Test1`, `TestMethod`, `ShouldWork`
- [ ] Verify test class is named `<SystemUnderTest>Tests`

**Red flags / Warning signs:**
- `public void TestJump()` — non-descriptive
- `public class UtilityTests` — class name doesn't identify the SUT

**Decision points:**
- Non-descriptive name: warn, provide corrected name following convention

---

### Step 3: Validate Isolation and Mocking

**Questions to answer:**
- Is the system under test isolated from collaborators using NSubstitute?
- Are external collaborators referenced via interfaces?

**Actions:**
- [ ] Identify all dependencies of the system under test
- [ ] Verify each dependency is mocked via `Substitute.For<IInterface>()`
- [ ] Flag `new ConcreteService()` where `IService` interface exists
- [ ] Flag static method calls on engine types that cannot be mocked (warn, note limitation)

**Red flags / Warning signs:**
- `var svc = new InventoryService()` in test setup — real collaborator, not isolated
- Test directly reads `File.ReadAllText(path)` — I/O dependency leaking into test

**Decision points:**
- Concrete collaborator instantiated: warn, provide interface + NSubstitute pattern
- Interface absent on collaborator: note limitation; recommend interface extraction

---

### Step 4: Validate Test Determinism

**Questions to answer:**
- Does the test produce the same result on every run regardless of execution order or time?

**Actions:**
- [ ] Flag `System.DateTime.Now` or `UnityEngine.Time.time` used as test input without control
- [ ] Flag test that depends on dictionary iteration order or random seed
- [ ] Verify PlayMode tests use `[UnitySetUp]`/`[UnityTearDown]` to reset state between runs
- [ ] Flag shared static state modified in test without teardown

**Red flags / Warning signs:**
- `Assert.AreEqual(expected, DateTime.Now.Second)` — time-dependent
- `Random.Range` used in assertion without fixed seed
- Static field set in test body with no cleanup

**Decision points:**
- Time-dependent test: warn, inject time provider interface
- Random without seed: warn, fix seed in `[SetUp]`

---

### Step 5: Validate Code Coverage

**Questions to answer:**
- Does the system under test have adequate coverage per project threshold?

**Actions:**
- [ ] Check if test runner output reports line/branch coverage
- [ ] Compare against documented project threshold (default: 80% line coverage for new code)
- [ ] Flag public methods on the system under test with no corresponding test case
- [ ] Flag happy-path-only coverage with no error/edge case tests

**Red flags / Warning signs:**
- Public `CalculateDamage(int base, int modifier)` with only `CalculateDamage_GivenPositiveInputs_ReturnsExpected`
- Zero tests for exception or null input paths

**Decision points:**
- Below threshold: warn, list untested public methods
- Happy-path-only: recommend at minimum one edge/error test per public method

---

### Final Step: Generate Testing Standards Report

```markdown
## Testing Standards Report

**Target:** [TestClassName.cs / SUT: SystemName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Assembly Placement
[Finding — EditMode vs. PlayMode assignment]

### Test Naming
[Finding — Given_When_Then compliance]

### Isolation & Mocking
[Finding — NSubstitute usage, concrete collaborators]

### Determinism
[Finding — time/random/static dependencies]

### Coverage
[Finding — threshold compliance, untested paths]

### Overall Assessment
- ✅ PASS: All testing conventions met
- ❌ FAIL: Wrong assembly or no isolation
- ⚠️ NEEDS REVIEW: Coverage below threshold or naming violations

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Validate test assembly placement — EditMode for pure logic, PlayMode for engine-dependent tests
2. Enforce `MethodName_GivenCondition_ExpectedBehavior` naming on all test methods
3. Require NSubstitute isolation for all injectable dependencies
4. Enforce determinism — no uncontrolled time, random, or shared static state
5. Verify code coverage meets project threshold for new and modified code

**Quality criteria:**

* Zero non-descriptive test method names
* Every external collaborator mocked via NSubstitute where interface exists
* Every test produces identical results across runs and execution orders

---

## Constraints (Rules Applied)

### Test Quality Rules

* **TQ-1: Test Coverage Baseline**
  - Applies: New and modified public methods must meet documented line coverage threshold
  - In practice: PR adding `DamageCalculator` must include tests covering normal, zero, and overflow inputs

* **TQ-2: Test Isolation**
  - Applies: SUT must be isolated from real collaborators; NSubstitute for interfaces
  - In practice: `IInventoryService` is substituted; `InventoryService` is not instantiated in test

* **TQ-3: Test Naming**
  - Applies: All test methods follow `MethodName_GivenCondition_ExpectedBehavior`
  - In practice: `ApplyDamage_GivenZeroArmour_ReturnsFull` — describes condition and expectation

* **TQ-4: Test Determinism**
  - Applies: No time, random, or execution-order dependencies in assertions
  - In practice: Fixed seed for random; inject IClock instead of DateTime.Now

---

## Tradeoff Handling

### Tradeoff 1: PlayMode Test Speed vs. Coverage Accuracy

**Scenario:** Integration test requires MonoBehaviour lifecycle but is slow in CI.

**Default stance:** Accept PlayMode test when engine lifecycle is genuinely required. Warn if the same coverage could be achieved with EditMode by extracting logic to a plain C# class.

**Resolution process:**
1. Check if business logic can be extracted from MonoBehaviour to a plain class
2. If yes: extract and write EditMode test — faster and more isolated
3. If no: accept PlayMode test with documented justification

---

### Tradeoff 2: 100% Coverage vs. Diminishing Returns

**Scenario:** 95% coverage achieved; remaining 5% is defensive null-check in a private method.

**Default stance:** Accept. Coverage gates apply to public API surface. Private defensive guards are acceptable without dedicated tests. Document via DT-1 if threshold formally adjusted.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: No Tests Exist for Modified System

**Trigger:** PR modifies `CombatSystem.cs` — no corresponding test file exists.

**Action:**
- Warn per TQ-1
- Block merge if project requires test coverage for PRs
- Invoke qa-test-generation to scaffold test suite

---

### Escalation Scenario 2: Flaky PlayMode Test

**Trigger:** Test passes locally, fails in CI intermittently.

**Action:**
- Flag as non-deterministic per TQ-4
- Identify source: timing dependency, frame ordering, uninitialized state
- Block merge until root cause resolved; do not mark as acceptable flakiness

---

### When to halt execution:

* Unity Test Framework not installed — cannot assess UTF conventions
* No test files exist in the target system — nothing to assess; trigger qa-test-generation

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on test scripts. Works alongside qa-test-generation when new test suites are generated from scratch for untested systems.

**Integration workflow:**
1. code-standards passes on both SUT and test scripts
2. Orchestrator invokes testing-standards on test files
3. Skill validates assembly, naming, isolation, determinism, coverage
4. If coverage gap found: qa-test-generation may be invoked to scaffold missing tests

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Coverage gap found on untested public methods | qa-test-generation | Scaffold missing test cases |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Test scripts must meet C# lifecycle and naming standards before test-specific assessment

**Skills this skill cooperates with:**

* **qa-test-generation** — Generates test scaffolding; testing-standards validates the quality of what is generated
* **performance-optimization** — PlayMode tests for performance-critical paths may overlap with benchmarking

**Skills this skill may invoke/flag:**

* **qa-test-generation** — When coverage gaps are detected, scaffold test generation

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block test in wrong assembly — EditMode test requiring engine types cannot run
* [ ] Block non-deterministic assertion — time or random without control is a CI risk
* [ ] Apply TQ-3 naming on every method — no exceptions for "temporary" names
* [ ] Log coverage threshold decisions via DT-1 if project adjusts the default
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Coverage threshold deviations logged via DT-1
* Test scaffold gaps logged via MF-2 as technical debt

---

## Example Use Cases

### Example 1: Wrong Assembly Placement

**Scenario:** `PlayerStatTests.cs` in PlayMode assembly tests pure arithmetic stat calculations with no engine types.

**Execution steps:**
1. Inspect test class — no MonoBehaviour, no IEnumerator, no engine API
2. Flag: in PlayMode assembly unnecessarily
3. Recommend: move to EditMode assembly; test runs 10x faster without Play Mode bootstrap

**Result:** ⚠️ NEEDS REVIEW

---

### Example 2: Non-Descriptive Test Name

**Scenario:** `public void TestDamage()` in `CombatTests.cs`.

**Execution steps:**
1. Check method name — no condition or expectation described
2. Flag: rename to `CalculateDamage_GivenMaxArmour_ReturnsMinimumDamage`
3. Class name `CombatTests` is acceptable — SUT is `CombatSystem`

**Result:** ⚠️ NEEDS REVIEW

---

### Example 3: Concrete Collaborator in Test

**Scenario:** `var inventory = new InventoryService()` in test `[SetUp]` — real service, not mocked.

**Execution steps:**
1. Identify `InventoryService` as a concrete dependency
2. Check if `IInventoryService` interface exists — it does
3. Flag: replace with `Substitute.For<IInventoryService>()`
4. Provide corrected `[SetUp]` with NSubstitute wiring

**Result:** ❌ FAIL

---

### Example 4: Fully Compliant Test Suite

**Scenario:** `CombatSystemTests.cs` — EditMode assembly, `CalculateDamage_GivenZeroArmour_ReturnsFullDamage` naming, NSubstitute mocks for all collaborators, no time or random dependencies, 85% line coverage.

**Result:** ✅ PASS

---

### Example 5: Time-Dependent Assertion

**Scenario:** Test asserts on `System.DateTime.Now.Ticks` modulo for a cooldown timer.

**Execution steps:**
1. Detect `DateTime.Now` in assertion — non-deterministic
2. Flag: inject `IClock` interface; substitute in test with fixed time
3. Provide `IClock` pattern with `Substitute.For<IClock>().UtcNow.Returns(fixedTime)`

**Result:** ❌ FAIL

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `[UnityTest]` test with no MonoBehaviour or coroutine logic — placed in PlayMode unnecessarily
✅ **Correct approach:** Move to EditMode assembly for speed; PlayMode only when engine lifecycle required

❌ **Anti-pattern 2:** `public void Test1()` — non-descriptive test name
✅ **Correct approach:** `MethodName_GivenCondition_ExpectedBehavior` naming convention

❌ **Anti-pattern 3:** `var svc = new ConcreteService()` in test setup — real collaborator
✅ **Correct approach:** `var svc = Substitute.For<IConcreteService>()` — NSubstitute isolation

❌ **Anti-pattern 4:** `Assert.AreEqual(expected, DateTime.Now.Second)` — time-dependent
✅ **Correct approach:** Inject `IClock`; substitute with fixed `DateTimeOffset` in `[SetUp]`

❌ **Anti-pattern 5:** Only happy-path test case for a method with multiple branches
✅ **Correct approach:** At minimum one test per distinct branch, including null/error paths

❌ **Anti-pattern 6:** Static field modified in test body with no `[TearDown]` cleanup
✅ **Correct approach:** Reset static state in `[TearDown]` or eliminate shared static state

❌ **Anti-pattern 7:** NSubstitute mock created but `.Returns()` never configured — silent no-op
✅ **Correct approach:** Configure all expected interactions; assert `Received()` calls

---

## Non-Goals

* ❌ Does not generate test cases from scratch — use qa-test-generation
* ❌ Does not validate runtime performance benchmarks — use performance-optimization
* ❌ Does not configure CI/CD test runners — infrastructure concern
* ❌ Does not validate test data content accuracy — domain concern

---

## Notes for LLM Implementation

1. **EditMode vs. PlayMode is the first check** — wrong assembly means the test may not even run correctly
2. **NSubstitute is the project standard** — do not suggest Moq or manual fakes unless documented
3. **TQ-4 determinism is a CI safety concern** — flaky tests degrade CI trust; block, don't warn
4. **Coverage threshold applies to new/modified code** — do not require retroactive coverage for untouched legacy code
5. **Naming is non-negotiable** — a well-named test documents intent; a poorly named one hides it

---

## Metadata Summary

```yaml
name: testing-standards
category: Quality
priority: High
depends_on: [code-standards]
flags_skills: [qa-test-generation]
rules_applied: [TQ-1, TQ-2, TQ-3, TQ-4]
documents_needed: [project_test_conventions, existing_test_suites]
tags: [unity, testing, utf, editmode, playmode, nsubstitute, code-coverage]
```

**Key relationships:**
- Depends on: code-standards (C# standards baseline for test scripts)
- Flags: qa-test-generation (when coverage gaps detected)
- Governed by: TQ-1 (coverage), TQ-2 (isolation), TQ-3 (naming), TQ-4 (determinism)
