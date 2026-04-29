---
name: dependency-suitability-selection
description: "Use when task requires On new dependency proposals or existing dependency reviews. Evaluates suitability across maintenance health, security posture, necessity, and supply chain risk before adoption."
---

# Dependency Suitability Selection

name:dependency-suitability-selection|pri:M|deps:[]|flags:[dependency-license-compliance,ci-cd-pipeline-automation,incident-response]|rules:[DD-3,DA-5,DT-1,DT-2]

SCOPE: On new dependency proposals or existing dependency reviews. Evaluates suitability across maintenance health, security posture, necessity, and supply chain risk before adoption.

ENFORCE: Apply necessity check first — reject if standard library or existing dependency suffices. Evaluate maintenance health: reject if abandoned or deprecated. Reject candidates with known unpatched CVEs. Assess supply chain risk: block on typosquatting indicators, malicious install scripts, or active compromise. Flag dependency-license-compliance for all new adoptions. Document all adoption decisions and tradeoffs via DT-1. Require DT-2 for MEDIUM or HIGH risk adoptions.

PROHIBIT: Adopting dependencies with known unpatched CVEs; adopting without necessity check; skipping dependency-license-compliance flag for new adoptions; adopting under MEDIUM/HIGH risk without DT-2.

ON_VIOLATION: unpatched_cve→reject_immediately. supply_chain_compromise→remove_immediately→flag:incident-response. abandoned_no_activity→classify_URGENT_REPLACE→log:DT-1. high_risk_no_dt2→block→request:DT-2. necessity_check_skipped→require_check_before_proceeding. dep_scanner_config_needs_update→flag:ci-cd-pipeline-automation.

## Reference
- See [reference.md](reference.md) for distilled source details.
