---
name: error-handling-resilience
description: "Use when task requires Ensures systems fail safely, transparently, and recoverably with explicit error paths and actionable diagnostics"
---

# Error Handling Resilience

name:error-handling-resilience|pri:M|deps:[correctness-validation,clean-code-solid]|flags:[correctness-validation,bug-diagnosis,documentation-knowledge-transfer,observability,test-creation-strategy,regression-prevention]|rules:[MF-5,GM-2,DT-1,TQ-1]
SCOPE: Ensures systems fail safely, transparently, and recoverably with explicit error paths and actionable diagnostics
ENFORCE: Prevent silent failures that corrupt state or produce incorrect results per MF-5; Ensure all exception paths handled explicitly, never swallowed; Design retry logic with exponential backoff and jitter to prevent storms; Provide actionable, structured diagnostic information; Test error paths with same rigor as happy paths per TQ-1; Maintain system stability under partial failures; Log error-masking decisions per DT-1; Explain risky error-masking before implementing per GM-2
PROHIBIT: Silent exception swallowing without logging; Catch-all exception handlers without structured handling; Generic error messages with no diagnostic value; Retry storms without backoff; Masking errors for UX without logging per DT-1; Not testing error paths
ON_VIOLATION: error_masking → request_justification per GM-2 → log_decision per DT-1. monitoring_gaps → flag observability. error_path_untested → flag test-creation-strategy. silent_failure → reject → require_explicit_handling per MF-5. unsafe_failure → flag bug-diagnosis. complex_handling → flag:documentation-knowledge-transfer. code_produced → flag:correctness-validation → flag:regression-prevention → flag:test-creation-strategy

## Reference
- See [reference.md](reference.md) for distilled source details.
