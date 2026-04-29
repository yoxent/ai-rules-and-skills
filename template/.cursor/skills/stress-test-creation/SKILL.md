---
name: stress-test-creation
description: "Use when task requires After load baselines exist, pre-launch of SLA-governed services. Exceed normal operating envelope to find breaking points, classify failure modes, and measure recovery vs SLA RTO."
---

# Stress Test Creation

name:stress-test-creation|pri:H|deps:[load-test-creation]|flags:[performance-optimization,risk-analysis,test-environment-management]|rules:[PC-1,PC-4,TQ-1,DT-2]

SCOPE: After load baselines exist, pre-launch of SLA-governed services. Exceed normal operating envelope to find breaking points, classify failure modes, and measure recovery vs SLA RTO.

ENFORCE: Require load-test baselines before scenario design. Confirm isolation before execution. Obtain DT-2 for destructive or shared-infra scenarios. Define recovery measurement plan before any destructive run. Include kill switches; reset env between scenarios. Classify every failure: graceful, hard-crash, silent, or cascade. Compare recovery time to SLA RTO. Log findings, untested scenarios, and tradeoffs via DT-1.

PROHIBIT: Execution without baselines or confirmed isolation; destructive scenarios without DT-2; silent failures treated as non-critical.

ON_VIOLATION: no_baselines→block→invoke:load-test-creation. isolation_unconfirmed→halt→flag:test-environment-management. no_dt2→block→document_untested. silent_failure→halt→flag:risk-analysis. cascade→flag:risk-analysis→flag:performance-optimization. rto_breach→flag:risk-analysis→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
