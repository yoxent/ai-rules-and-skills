---
name: linting-and-formatting
description: "Use when task requires On code commit, PR creation, or linting rule change. Enforce automated style, formatting, and structural checks that block pipeline progression on violation."
---

# Linting And Formatting

name:linting-and-formatting|pri:M|deps:[]|flags:[build-systems]|rules:[DA-1,DD-1,MF-1]

SCOPE: On code commit, PR creation, or linting rule change. Enforce automated style, formatting, and structural checks that block pipeline progression on violation.

ENFORCE: Validate linting failures block pipeline progression (DD-1); Verify tool configuration is version-controlled and shared; Require pre-commit hooks to mirror CI linting checks; Enforce new or changed rules uniformly across all files — no selective application; Require documented justification for every suppressed finding.

PROHIBIT: Suppressing violations without documented justification; Applying new rules to new files only without a migration plan; Linting configuration diverging between local and CI environments.

ON_VIOLATION: suppressed_no_justification→block→require inline justification. ci_local_divergence→flag:build-systems→block until aligned. new_rule_no_migration→request migration plan→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
