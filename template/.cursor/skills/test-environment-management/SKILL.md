---
name: test-environment-management
description: "Use when task requires Before any test suite requiring isolation. Provision isolated reproducible environments from code; enforce clean state per run; validate parity and data privacy."
---

# Test Environment Management

name:test-environment-management|pri:H|deps:[]|flags:[ci-cd-pipeline-automation,infrastructure-as-code,test-data-management]|rules:[DD-1,MF-1,DA-5,CL-3]

SCOPE: Before any test suite requiring isolation. Provision isolated reproducible environments from code; enforce clean state per run; validate parity and data privacy.

ENFORCE: Provision from code — no manual steps. Confirm isolation before execution. Guarantee teardown on failure and success. Verify no PII before each run; anonymize any production data. Use lightest isolation adequate for test tier. Use health-check probes for readiness. Document mocking decisions and parity gaps. Log fidelity gaps via DT-1.

PROHIBIT: Manual setup; teardown on success only; PII without anonymization; hardcoded env vars; fixed-duration readiness waits.

ON_VIOLATION: pii_detected→halt→flag:test-data-management→confirm_clean_before_resume. isolation_unconfirmed→halt→block_test_execution. teardown_failure→halt_subsequent_runs→restore_clean_state. ci_provisioning_failure→flag:ci-cd-pipeline-automation. persistent_infra_issue→flag:infrastructure-as-code.

## Reference
- See [reference.md](reference.md) for distilled source details.
