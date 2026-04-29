---
name: package-management
description: "Use when task requires On package addition, update, or audit. Manage dependencies for consistency, security, license compliance, and reproducible installs across all environments."
---

# Package Management

name:package-management|pri:M|deps:[]|flags:[dependency-safety-integration,security,dependency-license-compliance]|rules:[CL-2,MF-3,DD-3,DT-2]

SCOPE: On package addition, update, or audit. Manage dependencies for consistency, security, license compliance, and reproducible installs across all environments.

ENFORCE: Require license compatibility check for every new package (CL-2); Validate lock files are present and committed; Block major version upgrades without breaking-change assessment (MF-3); Require DT-2 gate for major version bumps; Verify package configurations produce consistent installs (DD-3); Flag security vulnerabilities to security skill.

PROHIBIT: Adding packages without license check; Committing without updated lock file; Floating version specs in lock-file-managed projects; Major upgrades without breaking-change assessment.

ON_VIOLATION: no_license_check→block→flag:dependency-license-compliance→require CL-2 assessment. missing_lock_file→block→require lock file commit. vulnerability_found→flag:security. major_upgrade_unassessed→block→flag:dependency-safety-integration→request:DT-2.

## Reference
- See [reference.md](reference.md) for distilled source details.
