---

```yaml
---
name: build-packaging-automation
description: Automates building and packaging of applications into versioned, reproducible, deployable artifacts with integrated quality checks.
version: 1.0.0
category: DevOps
tags: [build, packaging, automation, ci-cd, artifacts]
priority: High

depends_on: []
flags_skills: [ci-cd-pipeline-automation]

inputs: [source-code, build-configuration, ci-cd-pipeline-context]
outputs: [versioned-artifacts, build-logs, packaging-reports]

rules_applied:
  - DD-1  # CI/CD Enforcement — builds must run tests and quality checks; manual bypass forbidden
  - DD-3  # Infrastructure Validation — build scripts validated for idempotence and repeatability
  - MF-1  # Feature Consistency — build changes must not silently alter artifact behavior
  - DT-1  # Explicit Tradeoff Logging — document build speed vs thoroughness tradeoffs

documents_needed: [build-configuration, ci-cd-pipeline-definition, environment-specifications]

execution_context: Runs during CI/CD pipeline at build stage; precedes deployment; triggered by code commit or manual trigger.

---
```

---

# Skill: Build & Packaging Automation

---

## Purpose

**What this skill does:**
Automates the compilation, assembly, and packaging of application source code into versioned, reproducible artifacts (JARs, Docker images, tarballs, NPM packages, etc.) that can be reliably deployed to any target environment. It integrates quality checks — tests, linting, security scans — directly into the build process so that only validated artifacts progress downstream.

Eliminates manual build errors that cause production incidents, ensures every release is traceable to a specific commit, and shortens feedback loops by catching quality issues at build time rather than in production. Reproducible builds reduce environment-specific failures that waste developer time.

Guarantees deterministic outputs regardless of who or what triggers the build, enforces quality gates automatically, and produces artifact metadata that supports auditability, rollback, and compliance needs.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new application feature or bug fix is ready to be packaged for deployment
* A build configuration change is proposed (e.g. new build tool, changed Dockerfile, new dependency)
* Build reliability or reproducibility issues are reported (e.g. "works on my machine")
* Build pipeline performance is degraded and optimization is needed
* A new project or service needs its initial build pipeline established
* Build quality gate coverage is being reviewed or expanded (e.g. adding security scanning)
* Artifact versioning strategy is being defined or revised

### Do NOT use this skill for:

* Deploying built artifacts to environments — that is handled by the Deployment Management skill
* Designing the full CI/CD pipeline orchestration — that is handled by the CI/CD Pipeline Automation skill
* Infrastructure provisioning required by the build environment — that is handled by the Infrastructure as Code skill
* Dependency license checks — that is handled by the Dependency License Compliance skill

**Execution Context Details:**
This skill operates at Stage 7 (Skill Execution) of the orchestrator lifecycle. It is triggered early in any delivery pipeline — typically the first substantive action after source code is ready. It produces the artifact that all downstream skills (deployment, testing, release) consume. It feeds into CI/CD Pipeline Automation for pipeline integration and flags that skill when build failures require pipeline-level diagnosis.

---

## Inputs

**Required inputs:**

* **Source code and dependencies** — The application codebase and its declared dependency manifest (pom.xml, package.json, requirements.txt, go.mod, etc.). Used to compile and assemble the artifact.
* **Build configuration** — Build tool configuration files (Dockerfile, Makefile, webpack.config.js, build.gradle, etc.) and target environment definitions that specify how to build the artifact.
* **CI/CD pipeline context** — The pipeline environment (branch name, commit SHA, trigger type, environment target) used for versioning, artifact naming, and conditional quality gate activation.

**Optional inputs:**

* **Performance budget constraints** — If build time SLAs are defined, these constrain how aggressively quality checks can be parallelized or skipped.
* **Artifact registry credentials** — For publishing artifacts to a registry (Nexus, ECR, Artifactory, npm registry) as part of the build.

---

## Outputs

**Primary outputs:**

* **Versioned, reproducible artifacts** — Build outputs (binaries, container images, packages) tagged with a version derived from commit SHA, semantic version, or build number. Must be bit-for-bit reproducible given the same inputs.
* **Build logs and failure reports** — Complete logs from each build step. On failure, structured failure reports identifying the failing step, error output, and suggested resolution path.
* **Packaging reports with artifact metadata** — A manifest documenting artifact name, version, build timestamp, source commit, dependency checksums, and quality gate results.

**Output format:**

* Artifact files in the format required by the deployment target (e.g. Docker image in a registry, JAR in Nexus, NPM package in registry)
* Structured build log output parseable by CI/CD monitoring tools
* JSON or YAML artifact metadata manifest

**Skill flags (if applicable):**

* Flag **ci-cd-pipeline-automation** when a build failure appears to be caused by a pipeline configuration issue (e.g. wrong environment variable, missing secret injection, incorrect stage ordering) rather than a code issue.
* Flag **ci-cd-pipeline-automation** when build time consistently exceeds acceptable thresholds and pipeline restructuring (parallelism, caching) is needed.

---

## Preconditions

**Conditions that must be met before execution:**

* Source code is committed and available in the repository at a known ref (branch, tag, commit SHA)
* All declared dependencies are resolvable (registry accessible, versions available)
* Build environment is available and has required tooling (JDK, Node.js, Docker daemon, etc.)
* CI/CD pipeline context is available (branch name, trigger, target environment)

**Validation checks:**

* [ ] Dependency manifest is present and parseable
* [ ] Build configuration file(s) are present and syntactically valid
* [ ] Build environment tooling versions match the declared requirements
* [ ] Artifact registry credentials are available (if publishing is required)

---

## Step-by-Step Execution Procedure

### Step 1: Validate Build Environment and Configuration

**Questions to answer:**
- Is the build toolchain present and at the correct version?
- Are all required build configuration files present and syntactically valid?
- Are environment variables and secrets required by the build injected correctly?

**Actions:**
- [ ] Verify build tool version (e.g. `mvn --version`, `node --version`, `docker --version`)
- [ ] Parse build configuration file and check for syntax errors
- [ ] Confirm required environment variables are set (do not log secret values)
- [ ] Check network connectivity to dependency registries

**Red flags / Warning signs:**
- Build tool version mismatch between local and CI environments (reproducibility risk)
- Missing or incomplete environment variable injection (secrets not available at build time)
- Dependency registry unreachable (will cause transient build failures)

**Decision points:**
- If build toolchain is missing or wrong version, block and escalate with environment setup instructions.
- If build configuration is invalid, block and report specific syntax errors with line numbers.

---

### Step 2: Resolve and Validate Dependencies

**Questions to answer:**
- Are all declared dependencies resolvable at their pinned versions?
- Are any dependencies flagged with known vulnerabilities?
- Are dependency checksums consistent with prior builds (supply chain integrity)?

**Actions:**
- [ ] Run dependency resolution dry-run to detect unresolvable or version-conflicting dependencies
- [ ] Check dependency checksums or lock file consistency
- [ ] Flag dependencies with known CVEs for security review

**Red flags / Warning signs:**
- Unpinned dependency versions (e.g. `^1.2.3` in package.json without a lock file) — non-reproducible
- Lock file out of sync with dependency manifest
- Dependencies pulled from non-standard or unauthenticated registries

**Decision points:**
- If unpinned dependencies are detected and no lock file exists, log tradeoff via DT-1 and flag ci-cd-pipeline-automation.
- If supply chain integrity check fails (checksum mismatch), block and escalate immediately.

---

### Step 3: Execute Build with Integrated Quality Gates

**Questions to answer:**
- Does the build configuration include all required quality gates (tests, linting, security scans)?
- Are quality gates configured with failure-blocking behavior (not warnings-only)?
- What is the build parallelism strategy?

**Actions:**
- [ ] Execute build process (compile, assemble, package)
- [ ] Execute automated tests as part of the build (unit tests at minimum; integration tests where configured)
- [ ] Execute linting and static analysis checks
- [ ] Execute security vulnerability scan if configured
- [ ] Collect build output and quality gate results

**Red flags / Warning signs:**
- Tests configured as non-blocking warnings rather than build failures (bypasses quality gate)
- Security scan step missing entirely (no vulnerability detection)
- Build producing different artifact hashes on repeated runs with identical inputs (non-reproducible)

**Decision points:**
- If quality gate is configured as non-blocking, log tradeoff via DT-1 and notify.
- If security scan is absent, flag as monitoring gap and request confirmation to proceed without it.
- If build produces non-reproducible outputs, block and investigate before proceeding.

---

### Step 4: Version and Tag the Artifact

**Questions to answer:**
- What versioning scheme is in use (semantic versioning, CalVer, commit-SHA-based)?
- Is the version derivable deterministically from pipeline context?
- Does the artifact version match the source commit it was built from?

**Actions:**
- [ ] Derive artifact version from pipeline context (commit SHA, semantic version tag, build number)
- [ ] Apply version to artifact (embedded manifest, image tag, package.json version, etc.)
- [ ] Verify artifact name and version conform to registry naming conventions
- [ ] Confirm version is unique and does not overwrite an existing published artifact

**Red flags / Warning signs:**
- Artifact version not traceable to a specific source commit
- Mutable version tags (e.g. `latest` as the only tag on a Docker image) — not auditable
- Version collision with an existing published artifact

**Decision points:**
- If version scheme is ambiguous or not enforced, log tradeoff via DT-1.
- If a version collision is detected, block publication and escalate.

---

### Step 5: Publish Artifact and Generate Report

**Questions to answer:**
- Is the artifact registry accessible and authenticated?
- Should the artifact be published immediately or held for approval?
- What metadata must accompany the published artifact?

**Actions:**
- [ ] Publish artifact to registry with version tag and metadata manifest
- [ ] Generate packaging report (artifact name, version, build timestamp, source commit, quality gate results)
- [ ] Archive build logs
- [ ] Confirm artifact is retrievable from registry after publication (smoke check)

**Red flags / Warning signs:**
- Publication succeeds but artifact is not retrievable (registry indexing delay or access control issue)
- Metadata manifest incomplete (missing source commit or quality gate results)

**Decision points:**
- If publication fails, block downstream deployment and escalate with registry error details.
- If artifact retrieval smoke check fails, flag ci-cd-pipeline-automation.

---

### Final Step: Generate Build & Packaging Report

**Report/Output structure:**

```markdown
## Build & Packaging Automation Report

**Target:** [Service/Application Name]
**Version:** [Artifact version]
**Commit:** [Source commit SHA]
**Date:** [YYYY-MM-DD HH:MM:SS UTC]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Quality Gate Results
| Gate | Status | Details |
|------|--------|---------|
| Unit Tests | ✅ PASS | 347 tests, 0 failures |
| Linting | ✅ PASS | No violations |
| Security Scan | ⚠️ REVIEW | 2 low-severity CVEs in transitive deps |
| Build Reproducibility | ✅ PASS | Checksum verified |

### Artifact Details
- **Name:** [artifact-name:version]
- **Registry:** [registry-url/path]
- **Size:** [artifact size]
- **Checksum:** [sha256:...]

### Skills Flagged for Follow-up
- **ci-cd-pipeline-automation**: [Reason if flagged]

### Overall Assessment
**Decision:**
- ✅ PASS: All required quality gates pass; artifact is published and retrievable.
- ❌ FAIL: One or more blocking quality gates failed; artifact not published.
- ⚠️ NEEDS REVIEW: Non-blocking issues detected; artifact published but review required.

### Required Actions
- [ ] [Action 1 — if any]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Ensure builds are reproducible and deterministic across all environments and triggering contexts.
2. Integrate quality checks (tests, linting, security) as blocking gates — never as warnings-only.
3. Produce artifacts with deterministic, traceable versioning linked to source commits.
4. Generate complete build metadata enabling downstream auditability and rollback.
5. Flag pipeline-level issues to ci-cd-pipeline-automation rather than silently failing.

**Quality criteria:**

* Artifact checksum is identical given identical inputs (reproducibility verified)
* All quality gates configured as build-blocking (failure halts pipeline)
* Artifact version is traceable to a specific source commit
* Build log is complete and parseable by monitoring tools
* Metadata manifest accompanies every published artifact

---

## Constraints (Rules Applied)

* **DD-1: CI/CD Enforcement** — Every build must execute configured tests and quality checks; manual bypass requires DT-2 confirmation and DT-1 log.
* **DD-3: Infrastructure Validation** — Build scripts must be idempotent; identical inputs must produce identical artifacts. Non-idempotent builds are a blocking defect.
* **MF-1: Feature Consistency** — Build configuration changes must not inadvertently alter application behavior; validate functional equivalence unless the change is intentional.
* **DT-1: Explicit Tradeoff Logging** — Document all build speed vs thoroughness decisions: what was skipped, why, and what compensating control exists.

---

## Tradeoff Handling

### Tradeoff 1: Build Speed vs Quality Gate Thoroughness

**Conflict:** Fast builds improve developer feedback loops but may skip slow-running tests or expensive security scans.

**Resolution:** Detect skipped/non-blocking gate → log via DT-1 (gate skipped, compensating control) → if no compensating control, request DT-2 confirmation → block if confirmation not provided.

---

### Tradeoff 2: Build Automation Complexity vs Maintainability

**Conflict:** Optimized builds (parallelism, caching, incremental) improve performance but increase complexity and failure surface.

**Resolution:** Detect unjustified complexity → log via DT-1 (complexity introduced, maintenance risk) → recommend simplest approach meeting performance budget (DA-5: Avoid Overengineering).

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Build Tool or Environment Configuration Failure

**Trigger:** Build toolchain is missing, wrong version, or environment variables required for the build are absent.

**Action:**
- Block build execution immediately
- Report specific missing component with version requirement
- Escalate to user with environment setup instructions

**Escalation format:**
```
⚠️ BUILD ENVIRONMENT FAILURE

Issue: Build tool [name] version [required] not found; found [actual] or absent.
Context: Build configuration requires [specific toolchain version].
Options considered:
  A. Update CI build agent to include correct toolchain version.
  B. Update build configuration to use toolchain version available in agent.

Recommendation: Option A — pin build agent toolchain to required version for consistency.

Question: Which option should be applied? (Or: is there a third constraint I should know about?)
```

---

### Escalation Scenario 2: Quality Gate Bypass Requested

**Trigger:** A build configuration includes a flag that disables or demotes a quality gate from blocking to non-blocking (e.g. `-DskipTests`, `--no-verify`, `failOnError: false`).

**Action:**
- Log the bypass via DT-1 (what is bypassed, why, compensating control)
- If no compensating control exists, request confirmation via DT-2
- Block publication of artifact until confirmation is received or bypass is removed

---

### Escalation Scenario 3: Non-Reproducible Build Detected

**Trigger:** Artifact checksum differs between two build runs with identical source inputs.

**Action:**
- Block artifact publication immediately
- Flag ci-cd-pipeline-automation for pipeline diagnosis
- Log as blocking defect via DT-1

---

### Escalation Scenario 4: Artifact Registry Publication Failure

**Trigger:** Artifact cannot be published to registry (authentication failure, network failure, naming collision).

**Action:**
- Block downstream deployment (do not deploy an artifact that is not confirmed published and retrievable)
- Report specific registry error
- Flag ci-cd-pipeline-automation for pipeline remediation

---

### When to halt execution:

* Supply chain integrity check fails (dependency checksum mismatch) — potential tampering
* Non-reproducible build detected and root cause is unknown
* Artifact publication fails and artifact is not retrievable from registry
* A required quality gate is entirely absent and no confirmation has been provided to proceed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**

Build & Packaging Automation runs early in every delivery pipeline — it is the first skill to produce a deployable artifact. It is a prerequisite for Deployment Management, CI/CD Pipeline Automation, and any testing skill that operates on a built artifact.

### How This Skill Integrates

1. **Orchestrator** invokes this skill when source code is ready and a build is requested
2. This skill validates the environment, resolves dependencies, builds, applies quality gates, versions, and publishes the artifact
3. This skill **outputs flags** for ci-cd-pipeline-automation if pipeline-level issues are detected
4. **Orchestrator** invokes ci-cd-pipeline-automation if flagged, or Deployment Management if build is clean

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Build failure caused by pipeline misconfiguration (wrong env var, missing secret injection) | ci-cd-pipeline-automation | The failure is in pipeline setup, not source code; requires pipeline-level fix |
| Build time consistently exceeds SLA | ci-cd-pipeline-automation | Pipeline restructuring (parallelism, caching strategy) needed |
| Non-reproducible build (checksum mismatch) | ci-cd-pipeline-automation | Build environment or pipeline configuration likely causing non-determinism |

---

## Related Skills

**Skills this skill depends on:**
* None — this is a foundational skill; it is the first in the build-deploy chain.

**Skills this skill cooperates with:**
* **ci-cd-pipeline-automation** — This skill builds artifacts that are deployed by pipelines managed by ci-cd-pipeline-automation. Build failures and pipeline configuration issues are escalated to it.
* **containerization** — If the artifact is a container image, containerization skill governs image construction standards; this skill applies those standards during the packaging step.
* **deployment-management** — Deployment Management consumes artifacts produced by this skill; artifact versioning and metadata produced here are required by deployment.

**Skills this skill may invoke/flag:**
* **ci-cd-pipeline-automation** — Flagged when build failures indicate pipeline configuration problems rather than code problems, or when build performance requires pipeline-level intervention.

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Log all quality gate bypass decisions via DT-1 with compensating control documented
* [ ] Explain build risks before recommending quality gate relaxation
* [ ] Respect confirmation gates — do not bypass DT-2 for quality gate removal
* [ ] Never publish artifacts that fail blocking quality gates without explicit confirmation
* [ ] Document all non-reproducible build incidents
* [ ] Validate artifact retrievability after publication before reporting success

**Audit trail requirements:**

* Every build must produce a metadata manifest (source commit, version, quality gate results, timestamp)
* Quality gate bypass decisions must be logged with rationale and compensating control
* Artifact registry publication must be confirmed retrievable (not just acknowledged by registry API)

---

## Example Use Cases

### Example 1: Maven Multi-Module Build for Java Microservice

**Scenario:** A Java microservice CI pipeline triggers on a pull request merge to main. The build uses Maven with a multi-module structure (3 modules: API, service, persistence).

**Inputs provided:**
- `pom.xml` with `<version>1.4.2-SNAPSHOT</version>` and pinned dependency versions
- GitHub Actions pipeline context: commit `abc1234`, branch `main`, trigger `push`
- Nexus artifact registry credentials injected via CI secrets

**Execution steps:**
1. Validate Java 17 is available in build agent; confirm Maven 3.9.x present.
2. Resolve dependencies from Nexus; confirm lock file (`.mvn/wrapper/maven-wrapper.properties`) is consistent.
3. Execute `mvn clean verify` — compiles all modules, runs 412 unit tests, runs integration tests.
4. Version artifact as `1.4.2+abc1234` (base version + commit SHA suffix).
5. Publish `service-1.4.2+abc1234.jar` to Nexus; confirm retrievable.

**Result:** PASS — all quality gates passed, artifact published and retrievable.

**Skills flagged:** None.

**Output produced:**
```
## Build & Packaging Automation Report
Target: payment-service
Version: 1.4.2+abc1234
Commit: abc1234
Status: ✅ PASS
Quality Gates: Unit Tests ✅ 412/412 | Integration Tests ✅ 28/28 | Linting ✅
Artifact: nexus.internal/payment-service:1.4.2+abc1234
```

---

### Example 2: Docker Multi-Stage Build with Skipped Integration Tests

**Scenario:** A frontend team proposes a Dockerfile change that skips integration tests in the production image build to reduce build time from 8 minutes to 2 minutes.

**Inputs provided:**
- Proposed Dockerfile with `RUN npm run build` and no test execution
- Pipeline context: production build trigger
- No compensating control documented

**Execution steps:**
1. Detect that test execution is absent from Dockerfile build stage.
2. Check pipeline configuration — no separate test stage configured.
3. Log tradeoff via DT-1: "Integration tests absent from build; no compensating control identified."
4. Request confirmation via DT-2 before proceeding.

**Result:** NEEDS REVIEW — quality gate bypass without compensating control; escalated for confirmation.

**Skills flagged:** ci-cd-pipeline-automation (to add a separate test stage to the pipeline).

---

### Example 3: Non-Reproducible Webpack Build Detected

**Scenario:** A Node.js frontend service produces different asset hash values on two consecutive builds from the same commit.

**Inputs provided:**
- `webpack.config.js` using timestamp-based content hashing (`[contenthash:8]` with Date.now() seed)
- Commit SHA `def5678`

**Execution steps:**
1. Build artifact once: `main.a1b2c3d4.js`
2. Build artifact again from same commit: `main.e5f6g7h8.js` — hash differs.
3. Identify root cause: `Date.now()` seeding in webpack config introduces non-determinism.
4. Block artifact publication.
5. Flag ci-cd-pipeline-automation. Log via DT-1.

**Result:** FAIL — non-reproducible build; artifact blocked.

**Skills flagged:** ci-cd-pipeline-automation.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Skipping tests in production builds**
✅ **Correct approach:** Tests are a required quality gate. If build speed is a concern, parallelize test execution or split fast/slow test suites into separate pipeline stages — but never remove tests from production artifact builds without explicit confirmation.

❌ **Anti-pattern 2: Using `latest` as the only Docker image tag**
✅ **Correct approach:** Always tag images with a deterministic, commit-linked version (e.g. `service:1.4.2-abc1234`). `latest` may be added as an alias but must not be the only tag; it is mutable and not auditable.

❌ **Anti-pattern 3: Unpinned dependency versions without a lock file**
✅ **Correct approach:** All dependencies must be pinned (exact version or lock file). `^1.2.3` in npm without `package-lock.json` is a reproducibility defect, not a convenience feature.

❌ **Anti-pattern 4: Embedding secrets in Dockerfile layers**
✅ **Correct approach:** Use multi-stage builds to ensure credentials used during build (e.g. npm auth tokens, private registry credentials) do not appear in any layer of the final image. Use `--secret` mount in BuildKit.

❌ **Anti-pattern 5: Build configuration that diverges between CI and local**
✅ **Correct approach:** CI build configuration must be executable locally with the same results. "Works on my machine" is a sign that the build environment is not controlled. Use Docker-in-Docker or dev containers to ensure parity.

❌ **Anti-pattern 6: Treating security scan results as informational only**
✅ **Correct approach:** Security scans must be configured with severity thresholds that block the build. Informational-only scans are not quality gates — they are noise that gets ignored.

❌ **Anti-pattern 7: Build numbering scheme not linked to source control**
✅ **Correct approach:** Artifact versions must be traceable to the source commit that produced them. Sequential build numbers (`build-42`) are acceptable only if the pipeline links them to a commit SHA in artifact metadata.

❌ **Anti-pattern 8: Overly complex build scripts that only the original author understands**
✅ **Correct approach:** Build scripts are production code. They must be readable, documented, and maintainable by any team member. Apply Rule DA-5 (Avoid Overengineering) — use standard build tool idioms, not custom shell magic.

❌ **Anti-pattern 9: Publishing artifacts before quality gates complete**
✅ **Correct approach:** Artifact publication must be the final build step, after all quality gates pass. Never publish in parallel with test execution.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ Deploying artifacts to environments — handled by Deployment Management skill
* ❌ Designing or managing CI/CD pipeline orchestration — handled by CI/CD Pipeline Automation skill
* ❌ Provisioning build infrastructure (build agents, registries) — handled by Infrastructure as Code skill
* ❌ Dependency license compliance checking — handled by Dependency License Compliance skill
* ❌ Container image orchestration (Kubernetes manifests, Helm charts) — handled by Containerization skill

**Boundary clarifications:**

* This skill builds and publishes artifacts; it does not decide when or where to deploy them.
* This skill integrates quality gates into the build; it does not own the test suite design (that is Test Creation & Strategy) or failure diagnosis (that is Test Interpretation & Failure Diagnosis).
* This skill enforces that secrets are not embedded in artifacts; it does not manage secret storage or rotation (that is Secrets Management).

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Check reproducibility explicitly:** Do not assume a build is reproducible — verify by checking for timestamp-based seeds, non-deterministic ordering, or environment-specific paths in build outputs.
2. **Treat quality gate bypass as a blocking issue by default:** Any `-skip`, `failOnError: false`, or `--no-verify` flag should be flagged immediately and require DT-1 log + DT-2 confirmation.
3. **Validate artifact retrievability after publication:** A successful registry API response does not guarantee the artifact is retrievable. Perform a pull/download verification step.
4. **Be specific in build failure reports:** Do not report "build failed" — report the specific step, error message, and line number from logs.
5. **Distinguish code failures from pipeline failures:** A failing test is a code issue (do not flag ci-cd-pipeline-automation). A missing environment variable is a pipeline issue (flag ci-cd-pipeline-automation).

6. Use structured reports with tables for quality gate results; highlight ❌ blocking, ⚠️ non-blocking, ✅ passing. Include artifact version and commit SHA in every report header; provide actionable next steps for every failure.
7. Be systematic — validate environment before building; be conservative about quality gate relaxation; be specific in failure reports.
8. Multi-module builds: verify all modules pass quality gates. Docker multi-stage: verify no credentials leak into final image layers. Monorepo: confirm only affected modules rebuild and versioning distinguishes them.

---
