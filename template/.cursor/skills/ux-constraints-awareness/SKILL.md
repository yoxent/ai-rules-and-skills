---
name: ux-constraints-awareness
description: "Use when task requires Before implementation of any user-facing design. Evaluate against WCAG 2.1 AA, platform HIG, and design system; surface violations as sprint requirements before commitment."
---

# Ux Constraints Awareness

name:ux-constraints-awareness|pri:M|deps:[]|flags:[feature-validation,risk-analysis]|rules:[CL-1,PS-1,CL-4]

SCOPE: Before implementation of any user-facing design. Evaluate against WCAG 2.1 AA, platform HIG, and design system; surface violations as sprint requirements before commitment.

ENFORCE: Flag CL-4 dark patterns (pre-checked opt-ins, confirm-shaming, misleading hierarchy, roach motel) immediately on detection — before rest of review. Check: contrast ratios, keyboard nav, focus indicators, text alternatives, form labels, error messages, touch target size. Verify all four states designed: happy path, error, empty, loading. Design system deviations require documented justification. Surface violations as sprint requirements per PS-1. Flag legal accessibility risk to risk-analysis; structural violations to feature-validation.

PROHIBIT: Happy-path-only review. Accessibility deferred to code without design spec. CL-4 suppressed for business reasons. Undocumented design system deviations. UX review deferred to QA.

ON_VIOLATION: CL4_detected→flag:risk-analysis→block_implementation. structural_inaccessibility→flag:feature-validation. missing_states→block_sprint_commit. legal_a11y_risk→flag:risk-analysis.

## Reference
- See [reference.md](reference.md) for distilled source details.
