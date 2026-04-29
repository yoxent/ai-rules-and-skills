```yaml
---
name: build-systems
description: Designs and manages build pipelines for compilation, packaging, and artifact generation ensuring builds are fast, reproducible, and fully automated.
version: 1.1.0
category: Language & Platform Skills
tags: [build, ci-cd, reproducibility, artifacts, automation]
priority: Medium

depends_on: []
flags_skills: [linting-and-formatting, static-analysis, ci-cd-pipeline-automation]

inputs: [source-code, dependency-definitions, target-environment, ci-cd-context]
outputs: [build-scripts, reproducible-artifacts, build-failure-report]

rules_applied:
  - DD-1  # CI/CD Enforcement — builds must include tests and quality checks; no manual bypass
  - DD-3  # Infrastructure Validation — build scripts must be idempotent and safe to re-run
  - MF-1  # Feature Consistency — build changes must not silently alter artifact behavior
  - DT-1  # Explicit Tradeoff Logging — document build speed vs thoroughness tradeoffs

documents_needed: [build-tool-docs, ci-pipeline-config, dependency-lock-files]
execution_context: Activated when creating a new build pipeline, modifying an existing one, diagnosing a build failure, or integrating a new quality tool into the pipeline.
---
```

# Skill: Build Systems

---

## Purpose

**What this skill does:**
Designs, implements, and maintains the build pipeline — the automated process that takes source code and produces deployable artifacts. Ensures builds are deterministic (same input → same output), reproducible across environments, and integrated with quality gates.

Non-reproducible builds introduce environment-specific failures that are expensive to diagnose. Quality gates in the build pipeline provide the last automated check before code reaches deployment.

Deterministic builds eliminate "it works on my machine." Test and quality integration in builds catches regressions before human review is needed.

---

## When to Use This Skill

### Triggers:
* Creating a new build pipeline from scratch
* Modifying an existing build pipeline
* Diagnosing a build failure or non-reproducibility issue
* Integrating a new quality tool (linter, test runner) into the build
* Optimizing build performance

### Do NOT use this skill for:
* CI/CD orchestration and deployment — delegate to `ci-cd-pipeline-automation` (Phase 4)
* Linting rule configuration — delegate to `linting-and-formatting`
* Static analysis rule configuration — delegate to `static-analysis`
* Package version management — delegate to `package-management`

---

## Inputs

**Required inputs:**
* **Source code and dependency definitions** — what is being built
* **Target deployment environment** — affects artifact format and build flags
* **CI/CD pipeline context** — where the build runs; affects caching and parallelism

---

## Outputs

**Primary outputs:**
* **Build scripts** — version-controlled, idempotent automation
* **Reproducible artifacts** — versioned outputs that behave identically across environments
* **Build failure report** — root cause and remediation for failures

**Skill flags:**
* Flag **linting-and-formatting** when linting is missing from build pipeline
* Flag **static-analysis** when static analysis quality gate is absent
* Flag **ci-cd-pipeline-automation** when CI/CD orchestration or deployment scope is needed

---

## Preconditions

* Dependency definitions and lock files present
* [ ] Target environment confirmed
* [ ] CI pipeline structure understood

---

## Step-by-Step Execution Procedure

### Step 1: Audit Existing Build for Reproducibility

**Actions:**
- [ ] Verify all external build tool dependencies are pinned
- [ ] Check for environment-injected values that break determinism (timestamps, machine-local paths)
- [ ] Confirm lock files are committed and used

**Red flags:**
- `latest` or floating version pins in build tooling
- Artifacts differ between CI and local builds

---

### Step 2: Validate Quality Gate Integration

**Actions:**
- [ ] Confirm test execution is part of build (not optional)
- [ ] Check for linting and static analysis gates
- [ ] Verify quality gates block artifact promotion on failure

**Decision points:**
- If linting gate missing: flag `linting-and-formatting`
- If static analysis gate missing: flag `static-analysis`
- If tests skipped: require DT-2 confirmation

---

### Step 3: Validate Idempotence

**Actions:**
- [ ] Verify build can be re-run safely (DD-3)
- [ ] Check for non-idempotent side effects (file mutation, database writes in build)

---

### Step 4: Optimize (if performance is in scope)

**Actions:**
- [ ] Identify slow build steps
- [ ] Assess caching opportunities
- [ ] Log build-speed-vs-thoroughness tradeoffs via DT-1 if gates are relaxed for speed

---

### Final Step: Generate Output

```markdown
## Build Systems Report

**Build Tool:** [e.g. Gradle, Webpack, Make]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Reproducibility Assessment
[Determinism findings; pinning status]

### Quality Gate Integration
[Tests, linting, static analysis — present/absent/failing]

### Idempotence Assessment
[Safe to re-run? Findings]

### Performance Notes (if applicable)
[Slow steps; caching opportunities]

### Skills Flagged
- **linting-and-formatting**: [if gate missing]
- **static-analysis**: [if gate missing]

### Tradeoff Log (DT-1)
- [Tradeoff]: [Decision and justification]
```

---

## Core Responsibilities

1. Ensure builds are deterministic and reproducible
2. Enforce test and quality gate integration
3. Validate build script idempotence
4. Log speed-vs-thoroughness tradeoffs
5. Flag missing quality tool integrations

---

## Constraints (Rules Applied)

* **DD-1** — Builds must include tests and quality checks; no manual bypass
* **DD-3** — Build scripts must be idempotent and safe to re-run
* **MF-1** — Build changes must not silently alter artifact behavior
* **DT-1** — Document tradeoffs when build speed is optimized at the cost of thoroughness

---

## Tradeoff Handling

### Tradeoff 1: Build Speed vs. Test Thoroughness

```
Conflict: Skipping integration tests to speed up CI feedback loop
→ Require DT-2 confirmation
→ Log via DT-1: which tests are skipped, in which environments, and why
→ Fallback: Keep full test run; optimize parallelism instead
```

---

## Failure & Escalation Behavior

### Non-Reproducible Build

**Trigger:** Same source produces different artifacts in different environments

**Action:** Block promotion; trace source of non-determinism (floating dep, env injection, mutable state); require fix before unblocking

---

### Build Requires CI/CD Orchestration

**Trigger:** Build setup involves deployment scheduling, environment promotion, or pipeline orchestration beyond artifact generation

**Action:** Flag ci-cd-pipeline-automation. Delegate orchestration and deployment scope; build-systems handles artifact creation only.

---

## Anti-Patterns to Catch

❌ **Unpinned build tool dependencies (using `latest`)**
✅ Pin all build-time dependencies to specific versions in lock files

❌ **Tests not part of default build target**
✅ Default build target must include test execution

❌ **Build embeds machine-local paths or timestamps non-deterministically**
✅ Use build-time constants or reproducible timestamp injection

❌ **Different artifact behavior in CI vs. local due to env vars**
✅ Make all environment injection explicit and documented

❌ **Build scripts require manual pre-setup steps not in automation**
✅ Encode all steps in scripts; document prerequisites in README only if unavoidable

---

## Non-Goals

* ❌ CI/CD deployment orchestration — handled by Phase 4 skills
* ❌ Linting rule authoring — handled by `linting-and-formatting`
* ❌ Infrastructure provisioning — handled by infrastructure-as-code (Phase 4)

---
