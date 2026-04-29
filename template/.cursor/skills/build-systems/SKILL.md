---
name: build-systems
description: "Use when task requires On build pipeline creation, modification, or failure. Design and manage build pipelines for deterministic, reproducible, test-integrated artifact generation."
---

# Build Systems

name:build-systems|pri:M|deps:[]|flags:[linting-and-formatting,static-analysis,ci-cd-pipeline-automation]|rules:[DD-1,DD-3,MF-1,DT-1]

SCOPE: On build pipeline creation, modification, or failure. Design and manage build pipelines for deterministic, reproducible, test-integrated artifact generation.

ENFORCE: Validate builds are deterministic — same inputs produce same outputs across environments; Require tests and quality gates integrated into pipeline (DD-1); Validate build scripts are idempotent and safe to re-run (DD-3); Block test-skipping without DT-2 confirmation; Flag missing linting and static analysis gates to respective skills; Log build-speed-vs-thoroughness tradeoffs via DT-1.

PROHIBIT: Manual build steps not encoded in scripts; Artifact promotion without passing quality gates; Unpinned build tool dependencies; Silent test bypass in build.

ON_VIOLATION: non_reproducible_build→block→require input pinning. test_skipped_no_gate→block→request:DT-2. manual_step→block→require script encoding. quality_gate_missing→flag:linting-and-formatting→flag:static-analysis. ci_cd_orchestration_needed→flag:ci-cd-pipeline-automation→delegate_scope.

## Reference
- See [reference.md](reference.md) for distilled source details.
