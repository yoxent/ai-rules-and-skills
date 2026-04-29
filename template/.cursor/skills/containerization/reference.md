```yaml
---
name: containerization
description: Packages applications into secure, optimized container images for consistent, reproducible execution across all environments.
version: 1.0.0
category: DevOps
tags: [containers, docker, images, kubernetes, security]
priority: High

depends_on: [build-packaging-automation]
flags_skills: [deployment-management, secrets-management]

inputs: [application-artifacts, runtime-requirements, security-requirements, base-image-selection]
outputs: [optimized-container-images, deployment-configurations, versioned-registry-entries]

rules_applied:
  - CL-3  # Data Privacy — secrets must never be embedded in container images or layers
  - DD-3  # Infrastructure Validation — images must be scanned for vulnerabilities before promotion
  - MF-1  # Feature Consistency — image config changes must not alter application behavior unexpectedly
  - DA-5  # Avoid Overengineering — use standard base images; avoid custom runtime complexity without justification

documents_needed: [dockerfile, runtime-requirements, security-compliance-requirements, registry-configuration]

execution_context: Runs during build and packaging phase; produces container images consumed by deployment-management and ci-cd-pipeline-automation.

---
```

---

# Skill: Containerization

---

## Purpose

**What this skill does:**
Packages application artifacts and their runtime dependencies into container images that execute consistently across development, staging, and production environments. It enforces security best practices during image construction — non-root execution, minimal base images, no secrets in layers — and ensures images are vulnerability-scanned before promotion.

Eliminates environment-specific runtime failures by standardising the execution context. Reduces security exposure through minimal, scanned images. Enables horizontal scaling and rapid deployment through stateless, portable container design.

Guarantees environment parity between development and production. Reduces image size and attack surface through multi-stage builds. Provides a versioned, auditable image registry trail linking every running container to its source build.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new service or application needs its first Dockerfile or container image definition
* An existing image is being reviewed for security vulnerabilities or size optimisation
* A base image update is proposed (e.g. upgrading from Ubuntu 20.04 to 22.04)
* A security scan has identified vulnerabilities in an existing image
* Container startup failures or runtime dependency issues are being diagnosed
* Image build configuration changes are proposed that could affect runtime behaviour
* A service is being migrated from a VM or bare-metal deployment to containers

### Do NOT use this skill for:

* Deploying container images to environments — handled by Deployment Management
* Writing Kubernetes manifests or Helm charts for orchestration — handled by Deployment Management
* Managing secrets storage or rotation — handled by Secrets Management
* CI/CD pipeline configuration that builds images — handled by CI/CD Pipeline Automation

**Execution Context Details:**
This skill runs after Build & Packaging Automation (which produces the artifact to be containerised) and before Deployment Management (which deploys the resulting image). It is a prerequisite for any container-based deployment.

---

## Inputs

**Required inputs:**

* **Application artifacts and runtime requirements** — The compiled application artifact (JAR, binary, static files) and its runtime dependencies (JRE version, Node.js version, native libraries). Used to select the correct base image and construct the image layers.
* **Base image selection** — The proposed or existing base image (e.g. `eclipse-temurin:17-jre-alpine`, `node:20-alpine`). Must be validated for vulnerability status and minimal footprint.
* **Security and compliance requirements** — Any organisational or regulatory constraints on base images (e.g. approved image registry, required OS hardening, non-root enforcement).

**Optional inputs:**

* **Existing Dockerfile** — For review or modification tasks.
* **Vulnerability scan policy** — Severity thresholds that block image promotion (e.g. block on CRITICAL, warn on HIGH).

---

## Outputs

**Primary outputs:**

* **Optimised container images** — Multi-stage built images minimising final image size, running as non-root, with no development dependencies or secrets in any layer.
* **Container deployment configurations** — Dockerfile and any associated `.dockerignore`, build arguments, and label metadata.
* **Versioned image registry entries** — Images tagged with commit-traceable versions and published to the approved registry.

**Output format:**

* Dockerfile (and `.dockerignore`) as code
* Image registry entries with version tags
* Vulnerability scan report accompanying each promoted image

---

## Preconditions

**Conditions that must be met before execution:**

* Application artifact is available from Build & Packaging Automation
* Approved base image registry is accessible
* Vulnerability scanning tool is available in the build environment
* Runtime requirements are documented

**Validation checks:**

* [ ] Base image is from an approved registry
* [ ] No secrets or credentials present in Dockerfile or build context
* [ ] `.dockerignore` excludes development artifacts and sensitive files
* [ ] Vulnerability scan is configured and will block on defined severity thresholds

---

## Step-by-Step Execution Procedure

### Step 1: Validate Base Image Selection

**Questions to answer:**
- Is the proposed base image from an approved registry?
- Is the base image minimal (distroless, alpine, or slim variant preferred)?
- Does the base image have known unpatched vulnerabilities?

**Actions:**
- [ ] Verify base image source is from approved registry
- [ ] Check base image vulnerability status via scan
- [ ] Confirm minimal variant is used (alpine/slim/distroless over full OS images)
- [ ] Verify base image version is pinned to a specific digest or tag — not `latest`

**Red flags / Warning signs:**
- Base image using `latest` tag — not reproducible, not auditable
- Full OS base image (e.g. `ubuntu:22.04`) when a minimal variant exists
- Base image from an unapproved or untrusted registry
- Known CRITICAL vulnerabilities in base image with no remediation plan

**Decision points:**
- If base image has CRITICAL vulnerabilities, block and require upgrade before proceeding.
- If `latest` tag is used, require pinning to specific digest or version tag.

---

### Step 2: Review Dockerfile for Security and Correctness

**Questions to answer:**
- Does the Dockerfile use multi-stage builds to separate build and runtime concerns?
- Does the final image stage run as a non-root user?
- Are any secrets, credentials, or environment-specific values present in any layer?
- Are development dependencies excluded from the final image stage?

**Actions:**
- [ ] Verify multi-stage build structure separates build-time and runtime stages
- [ ] Confirm final stage runs as non-root user (`USER nonroot` or equivalent)
- [ ] Scan all layers for secrets, tokens, or credentials (including build args used as ENV)
- [ ] Verify `.dockerignore` excludes `.git`, local config files, and development artifacts
- [ ] Confirm no `RUN apt-get install` or equivalent in final stage beyond runtime requirements

**Red flags / Warning signs:**
- Single-stage Dockerfile including build tools (compiler, package manager) in final image
- No `USER` instruction — container runs as root by default
- `ARG` values passed to `ENV` making build-time secrets available in image metadata
- Missing `.dockerignore` — entire build context including sensitive files sent to daemon

**Decision points:**
- If secrets found in any layer, block immediately — flag secrets-management.
- If running as root with no justification, require non-root USER instruction before proceeding.

---

### Step 3: Optimise Image Size and Layer Structure

**Questions to answer:**
- Are layers ordered to maximise cache reuse (dependencies before application code)?
- Are unnecessary files excluded from the final image?
- Is the final image size within acceptable bounds for the deployment target?

**Actions:**
- [ ] Verify dependency installation layers precede application code copy (cache efficiency)
- [ ] Confirm `RUN` commands chain operations with `&&` to minimise layer count
- [ ] Check final image size — flag if significantly larger than comparable services
- [ ] Verify only runtime-required files are present in the final stage

**Red flags / Warning signs:**
- Application source code copied before dependency installation (invalidates dependency cache on every code change)
- Separate `RUN` commands for operations that could be chained (creates unnecessary layers)
- Final image includes test files, documentation, or build tool caches

**Decision points:**
- If overengineering is detected (excessive complexity without size benefit), apply DA-5 and recommend simplification.

---

### Step 4: Execute Vulnerability Scan and Review Results

**Questions to answer:**
- Does the image pass the defined vulnerability severity threshold?
- Are any detected vulnerabilities in the base image or in installed packages?
- Is there a remediation path for detected vulnerabilities?

**Actions:**
- [ ] Run vulnerability scan against the built image
- [ ] Classify findings by severity (CRITICAL, HIGH, MEDIUM, LOW)
- [ ] Identify whether vulnerabilities are in base image or application dependencies
- [ ] Confirm remediation path exists for any blocking findings

**Red flags / Warning signs:**
- CRITICAL vulnerabilities with no available fix in the base image — requires base image change
- Vulnerability scan skipped or configured as non-blocking
- Same vulnerabilities recurring across multiple builds without remediation

**Decision points:**
- If CRITICAL findings with no available fix, escalate — may require base image change or risk acceptance with DT-2 confirmation.
- If scan is non-blocking, log via DT-1 and require DT-2 confirmation.

---

### Step 5: Tag, Publish, and Verify Image

**Questions to answer:**
- Is the image tagged with a commit-traceable version?
- Is the image published to the approved registry?
- Is the published image retrievable and scan report attached?

**Actions:**
- [ ] Tag image with commit-traceable version (not `latest` alone)
- [ ] Publish to approved registry
- [ ] Attach vulnerability scan report to registry entry
- [ ] Confirm image is pullable from registry after publication

**Red flags / Warning signs:**
- Image published with only a `latest` tag
- Scan report not attached to registry entry
- Image not retrievable after publication

**Decision points:**
- If publication fails or image not retrievable, block downstream deployment and escalate.

---

### Final Step: Generate Containerization Report

```markdown
## Containerization Report

**Target:** [Service/Image Name]
**Image:** [registry/image:tag]
**Base Image:** [base-image:version]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Security Checks
| Check | Status | Notes |
|-------|--------|-------|
| Non-root user | ✅ | USER appuser |
| No secrets in layers | ✅ | |
| Multi-stage build | ✅ | |
| Base image pinned | ✅ | digest sha256:abc123 |
| Vulnerability scan | ⚠️ | 2 HIGH, 0 CRITICAL |

### Image Metadata
- **Final size:** [MB]
- **Layers:** [count]
- **Registry:** [registry-url/image:tag]

### Skills Flagged
- **secrets-management**: [Reason if flagged]
- **deployment-management**: [Reason if flagged]

### Required Actions
- [ ] [Action 1 if any]
```

---

## Core Responsibilities

1. Ensure container images run as non-root with minimal required permissions.
2. Verify no secrets, credentials, or sensitive values exist in any image layer.
3. Enforce vulnerability scanning as a blocking gate before image promotion.
4. Ensure images are built using multi-stage builds that exclude build-time dependencies from the final stage.
5. Tag images with commit-traceable versions published to approved registries.

---

## Constraints (Rules Applied)

* **CL-3: Data Privacy** — Secrets must never appear in any image layer (including via `ARG` to `ENV` or copied files); use BuildKit `--secret` mounts for build-time credentials and runtime injection (Vault, Kubernetes Secrets) for application credentials.
* **DD-3: Infrastructure Validation** — Images must be vulnerability-scanned before promotion; scan must block on CRITICAL severity — a non-blocking scan is not a quality gate.
* **MF-1: Feature Consistency** — Image configuration changes must not alter application runtime behaviour outside the intended scope; base image upgrades require regression validation.
* **DA-5: Avoid Overengineering** — Use standard `alpine`, `slim`, or `distroless` base images; custom base images require explicit justification.

---

## Tradeoff Handling

### Tradeoff 1: Image Size vs Functionality

**Resolution:** If debugging tools or non-runtime packages are proposed for the production image, log via DT-1 (what, why, what risk), then recommend a separate debug image variant; keep production image minimal.

### Tradeoff 2: Base Image Vulnerability vs Upgrade Risk

**Resolution:** If a base image upgrade is required for vulnerability remediation, request DT-2 confirmation if it introduces breaking changes, then require a regression test pass before promoting the upgraded image.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Secret Found in Image Layer

**Trigger:** A secret, credential, API key, or token is found in any image layer during build review or scan.

**Action:**
- Block image build and publication immediately
- Report layer number and instruction where secret appears — never reproduce the value
- Flag secrets-management for remediation and secret rotation

---

### Escalation Scenario 2: CRITICAL Vulnerability with No Available Fix

**Trigger:** Vulnerability scan finds CRITICAL severity CVE in base image or installed package with no available patched version.

**Action:**
- Block image promotion beyond development
- Document finding via DT-1
- Escalate to stakeholder — require DT-2 confirmation for risk acceptance or base image change decision

---

### Escalation Scenario 3: Container Runs as Root

**Trigger:** Dockerfile has no `USER` instruction in final stage, meaning container runs as root by default.

**Action:**
- Block image promotion
- Require addition of non-root `USER` instruction before proceeding
- Document as security defect

---

### When to halt execution:

* Secret found in any image layer
* CRITICAL vulnerability with no remediation path and no DT-2 confirmation
* Image runs as root with no justification
* Vulnerability scan absent or non-blocking without DT-2 confirmation

---

## Skill Integration & Orchestration

This skill sits between Build & Packaging Automation (upstream) and Deployment Management (downstream). It consumes build artifacts and produces container images ready for deployment.

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Secret found in image layer | secrets-management | Secret rotation and vault integration needed |
| Runtime secret injection pattern needed | secrets-management | Injection mechanism design is secrets domain |
| Deployment configuration decisions needed | deployment-management | Resource limits, probes, orchestration manifests |

---

## Related Skills

**Skills this skill depends on:**
* **build-packaging-automation** — Produces the application artifact that is containerised by this skill.

**Skills this skill cooperates with:**
* **ci-cd-pipeline-automation** — Image build steps are integrated into CI/CD pipelines managed by this skill.
* **deployment-management** — Consumes the container images produced here; coordinates on deployment configurations.
* **secrets-management** — Provides runtime secret injection patterns that replace secrets-in-image anti-patterns.

---

## Governance Hooks

* [ ] Block immediately on any secret found in image layers
* [ ] Enforce vulnerability scan as blocking gate before image promotion
* [ ] Require non-root USER in all production images
* [ ] Log all vulnerability risk acceptance decisions via DT-1 with DT-2 confirmation
* [ ] Confirm image retrievable from registry before reporting success

---

## Example Use Cases

### Example 1: Multi-Stage Docker Build for Java Service

**Scenario:** A Java microservice needs a production-ready Dockerfile. Currently using a single-stage build from `maven:3.9-eclipse-temurin-17` that includes Maven in the final image.

**Execution steps:**
1. Identify single-stage build anti-pattern — Maven included in production image unnecessarily.
2. Redesign as multi-stage: build stage uses `maven:3.9-eclipse-temurin-17`, final stage uses `eclipse-temurin:17-jre-alpine`.
3. Add `USER nonroot:nonroot` to final stage.
4. Add `.dockerignore` excluding `target/`, `.git`, local config files.
5. Run vulnerability scan — 0 CRITICAL, 2 HIGH in base image (fixes available).
6. Upgrade base image to patched version; re-scan to confirm clean.

**Result:** PASS — multi-stage build, non-root, clean scan.

---

### Example 2: Secret Found in Dockerfile ARG

**Scenario:** A Dockerfile review reveals `ARG NPM_TOKEN` passed to `ENV NPM_TOKEN` making the token available as image metadata.

**Execution steps:**
1. Detect `ARG` to `ENV` pattern for sensitive value.
2. Block immediately — CL-3 violation.
3. Report instruction line without reproducing token value.
4. Flag secrets-management.
5. Recommend BuildKit `--secret` mount as replacement pattern.

**Result:** FAIL — CL-3 violation; image blocked.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Single-stage Dockerfile including build tools in production image**
✅ **Correct approach:** Use multi-stage builds. Build stage uses full SDK; final stage uses minimal runtime image only.

❌ **Anti-pattern 2: Running container as root**
✅ **Correct approach:** Always add a `USER` instruction in the final stage. Create a dedicated non-root user in the image if needed.

❌ **Anti-pattern 3: Passing secrets via ARG or ENV**
✅ **Correct approach:** Use BuildKit `--secret` mounts for build-time credentials. Use runtime injection (Vault, Kubernetes Secrets) for application credentials.

❌ **Anti-pattern 4: Using `latest` tag for base image**
✅ **Correct approach:** Pin base images to a specific version tag or digest for reproducibility and auditability.

❌ **Anti-pattern 5: Missing .dockerignore**
✅ **Correct approach:** Always include `.dockerignore` excluding `.git`, local config, development artifacts, and any file that should not be in the build context.

❌ **Anti-pattern 6: Vulnerability scan configured as non-blocking**
✅ **Correct approach:** Scan must block on CRITICAL severity at minimum. Non-blocking scans provide false confidence and get ignored.

❌ **Anti-pattern 7: Copying application source before dependencies**
✅ **Correct approach:** Copy dependency manifests and install dependencies before copying application source. This maximises Docker layer cache reuse.

❌ **Anti-pattern 8: Full OS base image when minimal variant exists**
✅ **Correct approach:** Prefer `alpine`, `slim`, or `distroless` variants. Full OS images include unnecessary packages that increase attack surface.

---

## Non-Goals

* ❌ Deploying container images — handled by Deployment Management
* ❌ Writing Kubernetes manifests or Helm charts — handled by Deployment Management
* ❌ Managing secrets storage or rotation — handled by Secrets Management
* ❌ CI/CD pipeline configuration — handled by CI/CD Pipeline Automation
* ❌ Container orchestration platform setup — handled by Infrastructure as Code

---

## Notes for LLM Implementation

1. **Always check for secrets first:** Before reviewing any other aspect of a Dockerfile, scan for secrets in ARG, ENV, RUN commands, and COPY instructions.
2. **Never reproduce secret values:** Report location (layer, instruction, line number) only.
3. **Be specific about layer structure:** Vague advice like "optimise the Dockerfile" is not actionable. Identify specific instructions to change.
4. **Distinguish build-time from runtime concerns:** Build-time tools in the final stage are always wrong. Runtime debugging tools in the final stage require justification.
