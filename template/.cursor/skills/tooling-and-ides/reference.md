```yaml
---
name: tooling-and-ides
description: Configures and standardizes development tools, IDEs, and plugins for consistent code quality, productivity, and CI/CD integration.
version: 1.0.0
category: Language & Platform Skills
tags: [tooling, ide, configuration, developer-experience, ci-integration]
priority: Low

depends_on: []
flags_skills: [build-systems, linting-and-formatting]

inputs: [project-language-stack, team-workflow, ci-cd-context]
outputs: [shareable-ide-config, tool-setup-docs, ci-integration-plan]

rules_applied:
  - DA-1  # SOLID & Clean Code First — tooling enforces code quality standards automatically
  - DD-1  # CI/CD Enforcement — IDE-level tools must integrate with the pipeline
  - MF-1  # Feature Consistency — tool changes must not silently alter existing code-check behavior

documents_needed: [project-style-guide, ci-pipeline-config]
execution_context: Activated on project setup, toolchain change, or when developer environment inconsistencies are reported.
---
```

# Skill: Tooling & IDEs

---

## Purpose

**What this skill does:**
Configures and standardizes the development toolchain — IDE settings, plugins, linters, formatters, and debugging tools — so all team members work in a consistent, automated, and CI-integrated environment.

"Works on my machine" failures are a hidden productivity tax. Standardized tooling eliminates entire categories of environment-specific bugs and ensures automated checks run consistently for all developers.

Early detection of issues at the editor level is cheaper than catching them in CI or code review. Consistent configuration means tool output is reproducible and comparable across machines.

---

## When to Use This Skill

### Triggers:
* New project setup requiring toolchain configuration
* New team member environment setup
* Developer reports inconsistent behavior between machines
* Adding or removing a tool from the project toolchain
* CI pipeline integration for a dev tool is missing or broken

### Do NOT use this skill for:
* Linting rule authoring — delegate to `linting-and-formatting`
* Build pipeline design — delegate to `build-systems`
* Static analysis rule configuration — delegate to `static-analysis`

---

## Inputs

**Required inputs:**
* **Project language stack** — determines appropriate tools
* **Team workflow** — PR process, commit conventions, review expectations
* **CI/CD context** — what pipeline the tools must integrate with

---

## Outputs

**Primary outputs:**
* **Shareable IDE configuration** — version-controlled settings files (`.vscode/settings.json`, `.editorconfig`, etc.)
* **Tool setup documentation** — how to set up from scratch
* **CI integration plan** — how each tool hooks into the pipeline

**Skill flags:**
* Flag **build-systems** if tool integration with CI pipeline is blocked
* Flag **linting-and-formatting** when tool changes alter linting behavior

---

## Preconditions

* Language and framework stack confirmed
* [ ] Existing toolchain inventory completed
* [ ] CI pipeline structure understood

---

## Step-by-Step Execution Procedure

### Step 1: Inventory Existing Tools

**Actions:**
- [ ] List all current IDE configs, plugins, linting, and formatting tools
- [ ] Identify which are version-controlled vs. machine-local
- [ ] Identify gaps and duplications

---

### Step 2: Standardize Configuration

**Actions:**
- [ ] Move all configuration to version-controlled files
- [ ] Ensure configs are editor-agnostic where possible (`.editorconfig`)
- [ ] Document any tool requiring manual developer setup

---

### Step 3: Integrate with CI/CD

**Actions:**
- [ ] Confirm each tool has a CI enforcement step
- [ ] Verify pre-commit hooks mirror CI checks
- [ ] Flag to `build-systems` if CI integration is blocked

---

### Step 4: Validate No Silent Behavior Change

**Actions:**
- [ ] Compare tool output before and after configuration change
- [ ] If behavior changes, flag to `linting-and-formatting` and log via DT-1

---

### Final Step: Generate Output

```markdown
## Tooling & IDEs Report

**Project Stack:** [Languages/frameworks]
**Status:** ✅ PASS / ⚠️ NEEDS REVIEW

### Tools Configured
[List: tool name, version, config file, CI integration status]

### Machine-Local Config Eliminated
[What was moved to version control]

### CI Integration Status
[Per-tool pipeline integration status]

### Skills Flagged
- **build-systems**: [if CI integration blocked]
- **linting-and-formatting**: [if behavior changed]
```

---

## Core Responsibilities

1. Ensure all tool config is version-controlled and shareable
2. Integrate tools into pre-commit hooks and CI pipeline
3. Detect and eliminate environment inconsistencies
4. Flag tool changes that alter linting or check behavior

---

## Constraints (Rules Applied)

* **DA-1** — Tooling enforces quality principles automatically; it doesn't replace them
* **DD-1** — Every tool must have a CI enforcement counterpart
* **MF-1** — Tool changes must not silently break existing checks

---

## Tradeoff Handling

### Tradeoff 1: Tool Complexity vs. Developer Adoption

```
Conflict: Comprehensive toolchain vs. friction for developers
→ Prefer fewer, higher-value tools
→ Document setup time and justify each addition
→ Log via DT-1 if adding a tool with overhead above team threshold
```

---

## Failure & Escalation Behavior

### Escalation: CI Integration Blocked

**Trigger:** Tool cannot integrate with existing CI pipeline

**Action:** Flag `build-systems`; document the gap; do not declare toolchain complete until resolved

---

## Anti-Patterns to Catch

❌ **IDE config not committed to source control**
✅ Use `.vscode/settings.json`, `.editorconfig`, or equivalent committed files

❌ **Pre-commit hooks don't match CI checks**
✅ Keep pre-commit and CI checks in sync using shared config

❌ **Multiple tools doing the same job (two formatters, two linters)**
✅ Consolidate; justify any overlap with documented rationale

❌ **Debug configurations requiring manual environment setup**
✅ Provide launch.json or equivalent for all common debug scenarios

---

## Non-Goals

* ❌ Linting rules authoring — handled by `linting-and-formatting`
* ❌ Build pipeline design — handled by `build-systems`

---

## Metadata Summary

```yaml
name: tooling-and-ides
category: Language & Platform Skills
priority: Low
depends_on: []
flags_skills: [build-systems, linting-and-formatting]
rules_applied: [DA-1, DD-1, MF-1]
documents_needed: [project-style-guide, ci-pipeline-config]
tags: [tooling, ide, configuration, developer-experience, ci-integration]
```
