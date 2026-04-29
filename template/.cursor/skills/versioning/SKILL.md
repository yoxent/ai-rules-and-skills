---
name: versioning
description: "Use when task requires Classifies API/module changes as breaking or non-breaking, enforces semver increments, and defines deprecation timelines"
---

# Versioning

name:versioning|pri:M|deps:[system-design]|flags:[backward-compatibility,stakeholder-communication,technical-debt-management]|rules:[MF-3,PS-4,DD-4,DT-2,DT-1,GM-4]
SCOPE: Classifies API/module changes as breaking or non-breaking, enforces semver increments, and defines deprecation timelines
ENFORCE: Classify every planned change as BREAKING, NON-BREAKING ADDITION, or PATCH before determining version increment; Apply the highest-priority bump from all changes in the release — never understate breaking changes; Gate all MAJOR version bumps through stakeholder confirmation before release (DT-2); Require consumer impact analysis against the dependency map for every breaking change (DD-4); Define deprecation timeline with minimum notice period per consumer tier before sunsetting old version; Add deprecation warnings to old version responses and documentation before announcing sunset; Produce migration documentation for every breaking change — release notes alone are insufficient (PS-4)
PROHIBIT: Classifying a removal, rename, or behavioral change as a minor or patch increment; Deploying a breaking version without notifying consumers and providing a minimum deprecation period; Sunsetting a version with active consumers without documented stakeholder approval; Releasing a major version without a migration guide for each breaking change
ON_VIOLATION: breaking_as_minor → reclassify_as_major → gate_through_confirmation (DT-2). migration_path_missing → flag:backward-compatibility → block_release. no_consumer_notification → block_release → apply_DD-4 → require_notification_and_deprecation_period. consumer_not_migrated → flag stakeholder-communication → escalate_for_decision → log_per_DT-1. deprecated_accumulation → flag technical-debt-management → require_migration_drive_plan

## Reference
- See [reference.md](reference.md) for distilled source details.
