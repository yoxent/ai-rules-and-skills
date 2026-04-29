---
name: test-interpretation-failure-diagnosis
description: "Use when task requires Distinguishes between broken features and broken tests when failures occur, identifying root cause"
---

# Test Interpretation Failure Diagnosis

name:test-interpretation-failure-diagnosis|pri:H|deps:[correctness-validation]|flags:[bug-diagnosis,test-creation-strategy,regression-prevention,correctness-validation]|rules:[TQ-2,TQ-4,DT-1,GM-2,GM-4]
SCOPE: Distinguishes between broken features and broken tests when failures occur, identifying root cause
ENFORCE: Analyze failure message: parse error, stack trace, assertion details; Review recent changes: check what code/tests changed; Understand test intent: determine what business behavior test validates; Compare to requirements: verify test still reflects current requirements; Classify failure per TQ-2: code defect vs test defect vs requirement change; Recommend fix targeting correct artifact with evidence-based reasoning per GM-4; Document classification reasoning per DT-1; Flag brittle tests discovered during diagnosis per TQ-4; Investigate flaky tests for environmental factors, not just dismiss them
PROHIBIT: Fixing test to match broken code instead of fixing code; Deleting failing test without verifying it's incorrect; Assuming flaky tests are "just flaky" without investigation; Making changes without understanding test intent; Incomplete investigation leaving ambiguous failures unresolved; Misclassifying real regression as test defect; Ignoring test quality issues discovered during diagnosis
ON_VIOLATION: test_intent_unclear → request_clarification. code_defect → flag bug-diagnosis. brittle_test → flag test-creation-strategy. regression_misclassified → revert → reinvestigate. flaky_test → investigate_environment → flag regression-prevention. test_fix_reveals_correctness → flag correctness-validation

## Reference
- See [reference.md](reference.md) for distilled source details.
