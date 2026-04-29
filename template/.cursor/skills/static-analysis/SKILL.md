---
name: static-analysis
description: "Use when task requires On code commit, PR creation, or CI quality gate. Detect defects, security vulnerabilities, and quality violations without execution; enforce findings as blocking CI gates by severity."
---

# Static Analysis

name:static-analysis|pri:M|deps:[]|flags:[security,bug-diagnosis,build-systems]|rules:[TQ-1,DD-1,CL-3,DT-1]

SCOPE: On code commit, PR creation, or CI quality gate. Detect defects, security vulnerabilities, and quality violations without execution; enforce findings as blocking CI gates by severity.

ENFORCE: Validate CRITICAL and HIGH findings block pipeline progression (DD-1); Require analysis integrated into CI as non-optional step; Flag security-category findings to security (CL-3); Flag defect-category findings to bug-diagnosis; Require documented justification for every suppressed finding via DT-1; Require DT-2 confirmation to suppress CRITICAL findings; Calibrate rules to keep false-positive rate below actionable threshold.

PROHIBIT: Treating static analysis as advisory for CRITICAL/HIGH findings; Suppressing findings without justification; Disabling analysis for entire file subtrees without documented exception.

ON_VIOLATION: critical_suppressed_no_gate→block→request:DT-2. security_finding→flag:security→block. defect_finding→flag:bug-diagnosis. analysis_not_in_ci→flag:build-systems.

## Reference
- See [reference.md](reference.md) for distilled source details.
