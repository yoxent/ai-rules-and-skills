---
name: release-preparation
description: "Use when task requires Pre-release gate; run before pushing a release tag to classify changes, enforce semver, and verify release readiness."
---

# Release Preparation

name:release-preparation|pri:H|deps:[]|flags:[backward-compatibility,versioning,ci-cd-pipeline-automation,stakeholder-communication,documentation-knowledge-transfer]|rules:[DD-4,DD-2,MF-3,PS-4,DT-2,DT-1,GM-4]

SCOPE: Pre-release gate; run before pushing a release tag to classify changes, enforce semver, and verify release readiness.

ENFORCE: Collect change set via git diff <last-tag>..HEAD; invoke backward-compatibility for aggregate classification — structured table output required; feed bc classification to versioning for semver determination; block on any unresolved UNKNOWN; verify migration docs exist for every BREAKING change; gate MAJOR bumps per DT-2; confirm rollback plan per DD-2; produce changelog before tag push.

PROHIBIT: Invoke versioning before bc aggregate classification completes; downgrade MAJOR to MINOR or PATCH without DT-2 approval and DT-1 log.

ON_VIOLATION: unresolved_unknown→block_release→resolve_or_escalate. no_migration_docs→block_release→flag:documentation-knowledge-transfer. major_bump→gate_DT-2→flag:stakeholder-communication→log:DT-1. no_tag_pipeline→flag:ci-cd-pipeline-automation. version_understated→reclassify_major→gate_DT-2→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
