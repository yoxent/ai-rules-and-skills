---
name: documentation-knowledge-transfer
description: "Use when task requires Preserves understanding through documentation explaining why, not just what, enabling knowledge transfer"
---

# Documentation Knowledge Transfer

name:documentation-knowledge-transfer|pri:L|deps:[]|flags:[api-design,abstraction-domain-modeling,stakeholder-communication]|rules:[DA-1,MF-2,PS-4,GM-2]
SCOPE: Preserves understanding through documentation explaining why, not just what, enabling knowledge transfer
ENFORCE: Explain intent and reasoning, not just mechanics; Keep documentation synchronized with code as it evolves; Document non-obvious decisions and alternatives considered per PS-4; Distinguish between what code does and why designed that way; Create ADRs for architectural decisions; Write inline comments explaining why, not what; Track undocumented decisions as knowledge debt per MF-2; Focus on decisions that reduce documentation burden per DA-1
PROHIBIT: Documentation describing what code does (redundant with reading code); Letting documentation fall out of sync with code; Leaving design decisions undocumented; Documentation as afterthought
ON_VIOLATION: docs_out_of_sync → update_or_remove. undocumented_decision → create_adr → log_knowledge_debt per MF-2. sensitive_info → request_guidance per GM-2. docs_nontechnical → flag stakeholder-communication. api_needs_docs → flag api-design. domain_needs_explanation → flag abstraction-domain-modeling

## Reference
- See [reference.md](reference.md) for distilled source details.
