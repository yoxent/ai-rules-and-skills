---
name: tooling-and-ides
description: "Use when task requires On project setup or toolchain change. Configure and standardize IDE settings, plugins, and developer tooling for consistent code quality and CI/CD integration across all team members."
---

# Tooling And Ides

name:tooling-and-ides|pri:L|deps:[]|flags:[build-systems,linting-and-formatting]|rules:[DA-1,DD-1,MF-1]

SCOPE: On project setup or toolchain change. Configure and standardize IDE settings, plugins, and developer tooling for consistent code quality and CI/CD integration across all team members.

ENFORCE: Validate all tool configuration is version-controlled — reject machine-local-only config; Verify each tool has a CI enforcement counterpart (DD-1); Require pre-commit hooks to mirror CI checks; Flag tool changes that silently alter existing code-check behavior (MF-1); Reject tools that duplicate existing capability without documented justification.

PROHIBIT: Machine-local configuration not committed to source control; Toolchain additions without CI integration plan; Bypassing CI tool checks without documented exception.

ON_VIOLATION: machine_local_config→block→require version-controlled equivalent. no_ci_integration→flag:build-systems→block. tool_change_alters_checks→flag:linting-and-formatting→log:DT-1. duplicate_tool→request justification.

## Reference
- See [reference.md](reference.md) for distilled source details.
