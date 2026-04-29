---
name: environment-parity-enforcement
description: "Use when task requires Pipeline gate before production promotion and on environment-specific failure reports. Detects and classifies configuration, dependency, and runtime drift between environment tiers."
---

# Environment Parity Enforcement

name:environment-parity-enforcement|pri:M|deps:[infrastructure-as-code]|flags:[deployment-management,ci-cd-pipeline-automation]|rules:[DD-3,MF-1,DD-1,DT-1]

SCOPE: Pipeline gate before production promotion and on environment-specific failure reports. Detects and classifies configuration, dependency, and runtime drift between environment tiers.

ENFORCE: Compare runtime versions, dependency lock files, and configuration key sets across all tiers; block promotion on any unintentional difference. Classify each difference as intentional with DT-1 documentation or unintentional and blocking. Verify parity validation is a blocking pipeline step before production promotion. Block promotion if any configuration key present in staging is absent in production.

PROHIBIT: Production promotion with unintentional drift unresolved; intentional environment differences without DT-1 documentation; parity check configured as non-blocking.

ON_VIOLATION: missing_config_key_in_production→block_promotion→flag:deployment-management. unintentional_runtime_diff→block_promotion→require_remediation. intentional_diff_no_dt1→require:DT-1→block_until_documented. parity_check_absent→flag:ci-cd-pipeline-automation→recommend_manual_review.

## Reference
- See [reference.md](reference.md) for distilled source details.
