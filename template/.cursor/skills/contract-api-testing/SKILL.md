---
name: contract-api-testing
description: "Use when task requires On API changes or before integration tests. Validate provider-spec and consumer-contract alignment; classify changes; enforce breaking-change gate."
---

# Contract API Testing

name:contract-api-testing|pri:H|deps:[]|flags:[versioning,api-design,ci-cd-pipeline-automation]|rules:[MF-3,TQ-1,DD-1,DT-2]

SCOPE: On API changes or before integration tests. Validate provider-spec and consumer-contract alignment; classify changes; enforce breaking-change gate.

ENFORCE: Classify every change first: additive, non-breaking, or breaking. Obtain DT-2 approval and migration plan before any breaking change merges. Validate provider against published spec; surface and block on contract drift. Validate all consumer contracts against current provider. Enforce contract test CI gate as mandatory before integration tests. Maintain change log with attribution, consumer impact, and migration plan reference. Log tradeoffs via DT-1.

PROHIBIT: Breaking changes without DT-2 and migration plan; contract tests as optional CI step; contract drift unresolved; breaking change with unknown blast radius.

ON_VIOLATION: breaking_change_no_approval→block→escalate_prompt_engineer. contract_drift→flag:api-design→block_until_resolved. consumer_contract_fails→block→classify_regression_or_approved_change. blast_radius_unknown→block_breaking_change. breaking_change_approved→flag:versioning. no_ci_gate→surface_required_action→flag:ci-cd-pipeline-automation→block_completion.

## Reference
- See [reference.md](reference.md) for distilled source details.
