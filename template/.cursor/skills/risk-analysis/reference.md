```yaml
---
name: risk_analysis
description: Identifies, classifies, and prioritizes project and feature risks by business impact; produces mitigation strategies and escalation recommendations.
version: 1.0.0
category: Product
tags: [risk, analysis, mitigation, compliance, escalation]
priority: High

depends_on: []
flags_skills: [tradeoff-communication, decision-confirmation-gate]

inputs: [proposed-features, architectural-changes, incident-reports, compliance-flags]
outputs: [risk-register, mitigation-strategies, escalation-recommendations]

rules_applied:
  - PS-2
  - CL-4
  - DT-2
  - DT-1

execution_context: Triggered by compliance flags, HIGH-risk findings from feature-validation, or direct invocation for architectural changes. Produces risk register consumed by tradeoff-communication or decision-confirmation-gate.
---
```

---

# Skill: Risk Analysis

---

## Purpose

**What this skill does:**
Systematically identifies risks in proposed features, architectural changes, or operational contexts. Classifies each risk by severity, likelihood, and business impact. Produces a risk register with mitigation strategies and clear escalation paths for unacceptable risks.

Undetected risks become production incidents, compliance violations, or delivery failures — all of which cost more to fix than to prevent. A structured risk register makes the cost of proceeding visible before the commitment is made.

Forces systematic consideration of failure modes before implementation. Surfaces compliance and irreversibility constraints that would otherwise be discovered during QA or post-release.

---

## When to Use This Skill

### Triggers (Use this skill when):

* `feature-validation` classifies a feature as HIGH risk
* A compliance or data-sensitivity flag is raised by any upstream skill
* An architectural change affects production systems, authentication, or data storage
* A third-party dependency is being introduced for the first time
* A live system migration or schema change is proposed
* An incident post-mortem identifies a risk category not previously tracked
* Ethical concerns are raised about a feature's effect on users (CL-4)

### Do NOT use this skill for:

* Sprint prioritization — use `priority-negotiation`
* Communicating risks to stakeholders — use `tradeoff-communication` for that
* Security implementation — use `security` skill
* Routine code review risk — this skill handles project and feature level risks, not line-level issues

**Execution Context Details:**
Often invoked by `feature-validation` or `requirement-interpretation`. Outputs feed `tradeoff-communication` (for stakeholder framing) and may directly activate `decision-confirmation-gate` for HIGH-impact findings.

---

## Inputs

**Required inputs:**

* **Feature specs or change description** — What is being built or changed; the scope of the risk analysis.
* **Technical and business constraints** — Known constraints that bound acceptable risk levels.

**Optional inputs:**

* **Historical incident reports** — Inform likelihood estimates for recurring risk categories.
* **Compliance requirements** — GDPR, HIPAA, PCI, etc. — required when data processing is involved.
* **Architecture docs** — Required for changes that touch shared infrastructure.

---

## Outputs

**Primary outputs:**

* **Risk register** — Per-risk entries: description, category, severity (HIGH/MEDIUM/LOW), likelihood (HIGH/MEDIUM/LOW), business impact, mitigation strategy, owner.
* **Mitigation strategies** — Concrete, actionable steps to reduce each risk to an acceptable level.
* **Escalation recommendations** — Which risks require stakeholder acceptance; which block proceeding without mitigation.

---

## Preconditions

**Conditions that must be met before execution:**

* The scope of what is being analyzed is defined (feature, change, or system)
* At least one risk category is suspected or flagged by an upstream skill
* Compliance requirements are known or can be determined from context

---

## Step-by-Step Execution Procedure

### Step 1: Define Scope and Risk Categories

**Actions:**
- [ ] Confirm what is being analyzed: feature, architectural change, migration, dependency
- [ ] Identify applicable risk categories: compliance, data privacy, irreversibility, production impact, third-party dependency, ethical impact
- [ ] Note which categories are in scope vs explicitly out of scope

---

### Step 2: Identify Risks per Category

**Actions:**
- [ ] For each applicable category, enumerate specific risks
- [ ] State each risk as: "If X occurs, then Y happens to the business/user"
- [ ] Flag any ethical risk immediately per CL-4 regardless of likelihood

**Red flags:**
- Any risk involving user data, authentication, payments, or personally identifiable information
- Any change that cannot be rolled back once deployed
- Any third-party dependency with an unclear SLA or license

---

### Step 3: Classify Each Risk

**Actions:**
- [ ] Assign severity: HIGH (production impact / compliance / irreversible), MEDIUM (recoverable / user-visible), LOW (internal / reversible)
- [ ] Assign likelihood: HIGH (likely under normal conditions), MEDIUM (possible under edge cases), LOW (unlikely but worth noting)
- [ ] Compute priority: HIGH severity always escalates regardless of likelihood

**Classification rules:**
- Compliance violations are always HIGH severity
- Irreversible changes are always at least MEDIUM severity
- Ethical risks (CL-4) are always HIGH severity and cannot be downgraded

---

### Step 4: Define Mitigation Strategies

**Actions:**
- [ ] For each MEDIUM and HIGH risk, define at least one concrete mitigation
- [ ] Mitigation must be specific and actionable — not "add more testing"
- [ ] Classify mitigation effectiveness: eliminates / reduces / accepts the risk
- [ ] For risks where mitigation only reduces (not eliminates), flag for stakeholder acceptance

---

### Step 5: Escalation and Acceptance

**Actions:**
- [ ] Identify risks that cannot be mitigated to acceptable level within current constraints
- [ ] For each such risk: escalate via `tradeoff-communication` and require DT-2 confirmation
- [ ] Log all risk acceptance decisions per DT-1 with stakeholder identity and date

---

### Final Step: Generate Risk Register

```markdown
## Risk Analysis Report

**Scope:** [Feature or change being analyzed]
**Date:** [YYYY-MM-DD]
**Overall Risk Level:** HIGH / MEDIUM / LOW

### Risk Register

| # | Risk | Category | Severity | Likelihood | Business Impact | Mitigation | Status |
|---|------|----------|----------|------------|----------------|------------|--------|
| 1 | ... | Compliance | HIGH | MEDIUM | ... | ... | OPEN/MITIGATED/ACCEPTED |

### Escalation Required
- Risk #[N]: [Reason escalation needed] → flag: [skill-name]

### Risk Acceptance Log (DT-1)
- Risk #[N]: Accepted by [name/role] on [date]. Rationale: [...]

### Overall Recommendation
- PROCEED: All risks mitigated or accepted
- CONDITIONAL PROCEED: [Specific conditions]
- BLOCK: [Unacceptable risk(s) with no viable mitigation]
```

---

## Core Responsibilities

1. Enumerate risks systematically by category — no category silently skipped
2. Classify every risk with severity AND likelihood — both required for prioritization
3. Provide concrete mitigations — vague mitigations are non-compliant
4. Escalate all HIGH-severity risks for explicit stakeholder acceptance per DT-2
5. Log all acceptance decisions per DT-1

---

## Constraints (Rules Applied)

* **PS-2:** Risk descriptions in business impact terms for stakeholder communication.
* **CL-4:** Ethical risks flagged immediately and unconditionally — no business justification overrides this.
* **DT-2:** HIGH-severity risks require explicit stakeholder acceptance before proceeding.
* **DT-1:** Every risk acceptance decision logged with approver, date, and rationale.

---

## Tradeoff Handling

### Tradeoff 1: Risk Mitigation Depth vs Resource Cost

**Conflict:** Exhaustive mitigation consumes more resources than the feature itself.

**Resolution:** HIGH-severity risks require full mitigation — no resource shortcuts. MEDIUM risks get proportional mitigation calibrated to impact. LOW risks are documented and accepted with no mitigation work required. Log per DT-1 if mitigation is intentionally limited.

### Tradeoff 2: Conservative vs Aggressive Delivery

**Conflict:** Higher risk tolerance accelerates delivery but increases incident probability.

**Resolution:** Surface as an explicit option via `tradeoff-communication`. Never accept higher risk tolerance silently — requires DT-2 stakeholder confirmation. Log per DT-1 with approver.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Unmitigable HIGH-Severity Risk

**Trigger:** A HIGH-severity risk has no viable mitigation within current constraints.

**Action:**
- Document the risk with full impact description
- Flag `tradeoff-communication` to present the block/proceed/defer options to stakeholders
- Do not proceed without DT-2 confirmation

**Escalation format:**
```
⚠️ UNMITIGABLE HIGH-RISK DETECTED

Risk: [Description]
Impact: [Business-language consequence if risk materializes]
Why not mitigable: [Specific constraint preventing mitigation]
Options:
  A. Block — defer feature until mitigation is feasible
  B. Accept — proceed with explicit documented acceptance of the risk
  C. Reduce scope — remove the risky component from current delivery

Recommendation: [Option with reasoning]
Requires: Explicit stakeholder approval (DT-2)
```

### Escalation Scenario 2: Ethical Risk Detected (CL-4)

**Trigger:** Feature has potential for user harm, manipulation, or discrimination.

**Action:**
- Flag immediately regardless of likelihood or business justification
- Require explicit ethics/legal review before proceeding
- Cannot be downgraded or bypassed by business priority

### Escalation Scenario 3: Compliance Obligation Identified

**Trigger:** Feature touches regulated data (PII, payment, health).

**Action:**
- Classify as HIGH severity regardless of other factors
- Require compliance review before sprint commitment
- Document specific regulation(s) that apply

---

### When to halt execution:

* An ethical risk (CL-4) is identified and no review process is available
* A compliance obligation is identified but the applicable regulation cannot be determined
* A HIGH-severity irreversible change has no stakeholder available to accept the DT-2 gate

---

## Skill Integration & Orchestration

Frequently invoked by `feature-validation` and `requirement-interpretation`. Outputs consumed by `tradeoff-communication` for stakeholder framing and by `decision-confirmation-gate` for approval tracking.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Risk needs stakeholder decision | tradeoff-communication | Frame as business-language options |
| HIGH-severity risk with stakeholder acceptance needed | decision-confirmation-gate | Written approval required |

---

## Related Skills

* **Invoked by:** `feature-validation`, `requirement-interpretation`
* **Feeds into:** `tradeoff-communication`, `decision-confirmation-gate`
* **No hard dependencies** — can be invoked standalone

---

## Governance Hooks

* [ ] CL-4 ethical risk flags are unconditional — cannot be suppressed
* [ ] Every HIGH-severity finding escalated via DT-2 — no silent acceptance
* [ ] All acceptance decisions logged per DT-1
* [ ] Compliance risks always documented with specific regulation reference

---

## Example Use Cases

### Example 1: Live Database Migration

**Scenario:** Zero-downtime migration of a high-traffic orders table with schema changes.

**Risks identified:** Data loss during migration (HIGH/MEDIUM), extended lock time causing downtime (HIGH/LOW), rollback failure if migration partially completes (HIGH/LOW).

**Mitigations:** Blue-green migration with read replica; automated rollback script tested in staging; maintenance window negotiated.

**Result:** CONDITIONAL PROCEED — all mitigations in place; DT-2 confirmation obtained from engineering lead.

### Example 2: Third-Party OAuth Provider

**Scenario:** Integrating a new OAuth provider for social login.

**Risks identified:** Third-party outage causes login failure (MEDIUM/MEDIUM); provider data sharing violates GDPR (HIGH/HIGH); license terms restrict commercial use (MEDIUM/LOW).

**Mitigations:** Fallback to email login if OAuth fails; legal review of data sharing agreement; license review before integration.

**Result:** BLOCK on GDPR risk until legal review completes. Compliance flag per CL-4.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Listing risks without likelihood — severity alone doesn't prioritize work
✅ Every risk entry requires both severity AND likelihood.

❌ **Anti-pattern 2:** Vague mitigation ("add more tests", "review before release")
✅ Mitigation must be specific: "Add integration test for rollback path covering partial migration scenario."

❌ **Anti-pattern 3:** Downgrading an ethical risk because business value is high
✅ CL-4 ethical risks are unconditional — business justification does not override.

❌ **Anti-pattern 4:** Accepting a HIGH-severity risk without logging the approver
✅ DT-1 requires name, role, date, and rationale. Anonymous acceptance is non-compliant.

❌ **Anti-pattern 5:** Treating "unlikely" as "ignore"
✅ LOW likelihood HIGH severity risks still require a documented mitigation or acceptance decision.

❌ **Anti-pattern 6:** Performing risk analysis after sprint commitment
✅ Risk analysis must precede commitment. Post-commitment risk findings require scope renegotiation.

---

## Non-Goals

* ❌ Stakeholder-facing risk communication — use `tradeoff-communication`
* ❌ Security implementation — use `security` skill
* ❌ Sprint prioritization of risk mitigation work — use `priority-negotiation`
* ❌ Line-level code risk review — handled by Phase 1 engineering skills

---

## Notes for LLM Implementation

1. **Enumerate by category, not by intuition:** Always work through the category checklist (compliance, data privacy, irreversibility, production impact, third-party, ethical) systematically. Do not rely on pattern recognition alone.
2. **Both dimensions required:** A risk entry without both severity and likelihood is incomplete — do not output partial entries.
3. **CL-4 is a hard stop:** When an ethical risk is identified, flag it before continuing. Do not finish the risk register and mention it at the end.
4. **Mitigation specificity:** If you cannot state a mitigation in one specific actionable sentence, it is not specific enough.

---
