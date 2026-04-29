---
name: build-packaging-automation
description: "Use when task requires Stage 7, on build trigger. Compile, package, and publish versioned reproducible artifacts with integrated blocking quality gates."
---

# Build Packaging Automation

name:build-packaging-automation|pri:H|deps:[]|flags:[ci-cd-pipeline-automation]|rules:[DD-1,DD-3,MF-1,DT-1]

SCOPE: Stage 7, on build trigger. Compile, package, and publish versioned reproducible artifacts with integrated blocking quality gates.

ENFORCE: Validate toolchain and env vars; block on mismatch. Verify dependency lock file and checksums; block on mismatch. Run all quality gates as build-blocking; non-blocking config is a bypass requiring DT-1+DT-2 with documented compensating control. Verify reproducibility — same inputs must yield same checksum. Tag with commit-traceable version; reject mutable-only tags. Generate metadata manifest. Confirm artifact retrievable from registry before reporting success.

PROHIBIT: Publishing before blocking gates complete; publishing failed-gate artifact without DT-2; secrets in artifact layers; security scan configured as non-blocking without DT-2 confirmation.

ON_VIOLATION: gate_bypass_no_compensating_control→log:DT-1→request:DT-2→block. non_reproducible→block→flag:ci-cd-pipeline-automation→log:DT-1. registry_fail→block_downstream→flag:ci-cd-pipeline-automation. toolchain_missing OR checksum_fail→block→escalate_user.

## Reference
- See [reference.md](reference.md) for distilled source details.
