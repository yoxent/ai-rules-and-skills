---
name: containerization
description: "Use when task requires Stage 7, on image build or review. Packages application artifacts into secure, minimal, vulnerability-scanned container images for consistent execution across environments."
---

# Containerization

name:containerization|pri:H|deps:[build-packaging-automation]|flags:[deployment-management,secrets-management]|rules:[CL-3,DD-3,MF-1,DA-5]

SCOPE: Stage 7, on image build or review. Packages application artifacts into secure, minimal, vulnerability-scanned container images for consistent execution across environments.

ENFORCE: Verify base image is pinned to a specific version or digest from an approved registry; reject mutable tags. Verify Dockerfile uses multi-stage builds separating build-time and runtime stages. Require non-root USER instruction in final image stage. Scan all layers for secrets including ARG-to-ENV patterns; block on any finding. Run vulnerability scan as blocking gate before image promotion; CRITICAL findings block promotion. Tag image with commit-traceable version; confirm retrievable from registry after publication.

PROHIBIT: Secrets or credentials in any image layer or build argument; container running as root without justification; vulnerability scan non-blocking without DT-2 confirmation; mutable-only image tags; build-time dependencies in final image stage.

ON_VIOLATION: secret_in_layer→block_immediately→report_location→flag:secrets-management. root_user_no_justification→block→require_USER_instruction. critical_vuln_no_fix→block_promotion→log:DT-1→request:DT-2. scan_non_blocking→log:DT-1→request:DT-2→block. base_image_unpinned→block→require_pinned_version. image_requires_deployment_config→flag:deployment-management.

## Reference
- See [reference.md](reference.md) for distilled source details.
