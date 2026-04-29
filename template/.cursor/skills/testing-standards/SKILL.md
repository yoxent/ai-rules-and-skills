---
name: testing-standards
description: "Use when task requires After code-standards on test scripts. Validates UTF assembly placement, naming, NSubstitute isolation, determinism, and coverage."
---

# Testing Standards

name:testing-standards|pri:H|deps:[code-standards]|flags:[qa-test-generation]|rules:[TQ-1,TQ-2,TQ-3,TQ-4]
SCOPE: After code-standards on test scripts. Validates UTF assembly placement, naming, NSubstitute isolation, determinism, and coverage.
ENFORCE: EditMode for pure-logic tests (no engine types); PlayMode only for MonoBehaviour lifecycle, coroutines, or physics; test method MethodName_GivenCondition_ExpectedBehavior; class <SUT>Tests; Substitute.For<IInterface>() for injectable collaborators; [UnitySetUp]/[UnityTearDown] for PlayMode state reset; ≥80% line coverage on new public methods.
PROHIBIT: Pure-logic test in PlayMode; non-descriptive names (Test1, ShouldWork); new Concrete() in setup where IInterface exists; DateTime.Now/Time.time in assertions without injected clock; Random without fixed seed; static state modified with no TearDown.
ON_VIOLATION: wrong_assembly→BLOCK→correct_assembly. bad_name→warn→GivenWhenThen. concrete_dep→warn→NSubstitute. time_random→BLOCK→inject_interface. coverage_gap→warn→flag:qa-test-generation.

## Reference
- See [reference.md](reference.md) for distilled source details.
