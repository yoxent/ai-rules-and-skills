---
name: bug-diagnosis
description: "Use when task requires Identifies, isolates, and documents defects by tracing logic failures from symptoms to root causes. When bugs reported"
---

# Bug Diagnosis

name:bug-diagnosis|pri:H|deps:[]|flags:[test-creation-strategy,error-handling-resilience,performance-optimization,technical-debt-management]|rules:[MF-4,DT-1,TQ-3,GM-2,GM-4]
SCOPE: Identifies, isolates, and documents defects by tracing logic failures from symptoms to root causes. When bugs reported
ENFORCE: Reproduce issue before proposing fix - verify bug exists with minimal reproduction case; Gather evidence: logs, stack traces, state snapshots, environmental factors; Trace from symptom to root cause - follow logic backward from observed failure; Distinguish symptom from actual origin per MF-4; Document findings with evidence per GM-4 - no guessing; Recommend fix targeting root cause, not just symptom; Require regression test coverage for fix per TQ-3; Log quick patches as technical debt if full fix deferred per DT-1; Explain diagnosis reasoning before recommending fix per GM-2
PROHIBIT: Proposing fix without reproducing bug; Guessing at root cause without evidence; Fixing symptoms without addressing root cause; Shipping fix without regression test; Closing bug without confirming fix works; Patching without understanding why bug occurred
ON_VIOLATION: cannot_reproduce → request_more_context → avoid_assumptions. symptom_patched → flag_technical_debt → require_followup_plan. fix_without_regression_test → flag test-creation-strategy. perf_regression → flag performance-optimization. unsafe_failure → flag error-handling-resilience. root_cause_needs_arch → flag technical-debt-management. evidence_insufficient → continue_investigation → gather_more_data

## Reference
- See [reference.md](reference.md) for distilled source details.
