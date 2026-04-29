---
name: risk-analysis
description: "Use when task requires On compliance flag, HIGH-risk finding, architectural change, or new third-party dependency. Enumerate, classify, and prioritize risks; produce register with mitigations and escalation paths."
---

# Risk Analysis

name:risk-analysis|pri:H|deps:[]|flags:[tradeoff-communication,decision-confirmation-gate]|rules:[PS-2,CL-4,DT-2,DT-1]

SCOPE: On compliance flag, HIGH-risk finding, architectural change, or new third-party dependency. Enumerate, classify, and prioritize risks; produce register with mitigations and escalation paths.

ENFORCE: Enumerate risks by category: compliance, data-privacy, irreversibility, production-impact, third-party, ethical. Flag CL-4 ethical risks immediately before continuing — unconditional. Classify every risk with severity AND likelihood (both required). Compliance=always HIGH; irreversible=at least MEDIUM. Provide specific actionable mitigation per MEDIUM/HIGH risk. Escalate all HIGH-severity risks via DT-2. Log acceptances per DT-1 with approver and date. Business-language impact per PS-2.

PROHIBIT: Risk entry missing severity or likelihood. Vague mitigation. Downgrading ethical or compliance risk. Silent HIGH-risk acceptance. DT-1 log without approver.

ON_VIOLATION: CL4_detected→flag_immediately→require_ethics_review→block. HIGH_severity_no_approval→flag:decision-confirmation-gate→block_commit. stakeholder_decision_needed→flag:tradeoff-communication. compliance_unresolved→block_commit. acceptance_unlogged→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
