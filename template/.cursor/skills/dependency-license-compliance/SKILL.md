---
name: dependency-license-compliance
description: "Use when task requires Pipeline gate on dependency changes and periodic full audits. Classifies all direct and transitive dependency licenses against the product distribution model before production deployment."
---

# Dependency License Compliance

name:dependency-license-compliance|pri:M|deps:[]|flags:[ci-cd-pipeline-automation]|rules:[CL-1,CL-2,DD-1,DT-1]

SCOPE: Pipeline gate on dependency changes and periodic full audits. Classifies all direct and transitive dependency licenses against the product distribution model before production deployment.

ENFORCE: Resolve and classify licenses for the full transitive dependency tree — not direct dependencies only. Treat unknown or unresolvable licenses as prohibited until resolved; never assume permissive. Escalate Category C (strong copyleft) and Category D (prohibited/unknown) findings to legal via CL-2 before deployment. Verify automated license scanning is a blocking pipeline step. Document all risk acceptance decisions via DT-1.

PROHIBIT: Deploying with prohibited or unresolved licenses; treating unknown licenses as permissive; making legal determinations on ambiguous licenses without escalating via CL-2; non-blocking license scans.

ON_VIOLATION: agpl_in_saas→block_immediately→escalate:CL-2. gpl_in_commercial_distribution→block→escalate:CL-2. unknown_license→block→treat_as_prohibited→require_resolution. prohibited_license→block_pipeline→require_replacement. scanner_non_blocking→flag:ci-cd-pipeline-automation→require_remediation.

## Reference
- See [reference.md](reference.md) for distilled source details.
