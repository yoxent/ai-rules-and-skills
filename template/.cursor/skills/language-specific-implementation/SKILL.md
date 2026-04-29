---
name: language-specific-implementation
description: "Use when task requires Stage 7, on feature implementation. Apply language idioms, stdlib, and runtime-aware constructs to produce correct, idiomatic code."
---

# Language Specific Implementation

name:language-specific-implementation|pri:M|deps:[]|flags:[framework-mastery,regression-prevention,correctness-validation,test-creation-strategy]|rules:[DA-1,PC-1,DT-1]

SCOPE: Stage 7, on feature implementation. Apply language idioms, stdlib, and runtime-aware constructs to produce correct, idiomatic code.

ENFORCE: Confirm language version from project config before selecting idioms; Validate idiom against codebase patterns (DA-1); Prefer stdlib over custom; Account for runtime behavior (GC, GIL, async model); Log language-constraint deviations via DT-1; Flag framework-mastery when framework lifecycle integration is needed; Flag regression-prevention, correctness-validation, and test-creation-strategy after code is produced.

PROHIBIT: Unverified language version; Blocking I/O in async context without offload; Swallowing bare Exception/Throwable; Reinventing stdlib patterns; Proceeding past unresolved correctness risk.

ON_VIOLATION: framework_needed→flag:framework-mastery. lang_constraint→log:DT-1→confirm_if_material. correctness_risk→block→surface. version_unknown→clarify→block.

## Reference
- See [reference.md](reference.md) for distilled source details.
