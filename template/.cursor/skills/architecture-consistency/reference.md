---
name: architecture_consistency
description: Validates that code changes, patterns, and design decisions align with established architecture and prior ADRs; detects and surfaces architectural drift
version: 1.0
category: Architecture
tags: [architecture, consistency, adr, drift-detection, design-governance]
priority: Medium
depends_on: []
flags_skills: [technical-debt-management, decision-confirmation-gate]
inputs: [proposed change or pattern, existing architecture documentation, ADR history]
outputs: [consistency assessment, drift report, ADR recommendation if deviation is justified]
rules_applied: [DA-7, DA-1, DA-3, GM-4, DT-1]
execution_context: Triggered when a new pattern is introduced, architectural drift is suspected, or a design decision may conflict with established architecture
---

# architecture-consistency

## 1. Purpose

architecture-consistency validates that proposed changes and design decisions remain aligned with the established architectural style, patterns, and prior Architecture Decision Records (ADRs). It detects architectural drift early — before it compounds — and surfaces deviations with evidence rather than assertion.

It does not block all deviations. Intentional deviations with documented justification and an ADR are acceptable. It blocks undocumented deviations and surfaces potentially inconsistent decisions for explicit resolution. Its goal is informed decision-making, not rigid enforcement.

## 2. When to Use This Skill

**Triggers (flagged from):**
- `code-maintenance` — when decayed or inconsistent patterns surface during maintenance
- `design-pattern-selection` — when a new pattern may conflict with established architecture

**Do NOT use for:**
- Writing ADRs from scratch (this skill recommends them; authoring is a separate concern)
- Code style or naming convention enforcement (use `clean-code-solid`)
- Full system design or architecture creation (use `system-design`)
- Evaluating whether the established architecture is good (use `system-design` or `technical-debt-management`)

**Execution context:** Activated when there is a risk of architectural inconsistency or drift in a proposed change.

## 3. Inputs

**Required:**
- Proposed change or pattern description
- Reference to existing architecture or discernible patterns in the codebase

**Optional:**
- Formal architecture documentation
- ADR history (prior decisions that constrain or inform this area)
- Examples of the established pattern from the codebase

**Documents needed:**
- Architecture documentation if it exists
- ADR log if available
- Representative examples of established patterns from the codebase

## 4. Outputs

**Primary outputs:**
- Consistency assessment: CONSISTENT, DEVIATION_JUSTIFIED, or DEVIATION_UNDOCUMENTED
- Drift report: description of how the proposed change differs from established architecture, with cited evidence
- ADR recommendation: if a deviation is intentional and justified, a recommendation to create or update an ADR

**Skill flags triggered:**
- `technical-debt-management` — when drift is widespread or a deviation is logged as accepted technical debt
- `decision-confirmation-gate` — when a deviation is high-risk or affects widely-shared components

## 5. Preconditions

- The proposed change or pattern is sufficiently defined to compare against existing architecture
- Some architecture baseline exists — either documented or discernible from consistent codebase patterns

**Validation checks before execution:**
- No documentation and no discernible codebase pattern → document this as a gap; note lower confidence; do not invent a baseline
- Proposed change too vague to assess → request clarification before proceeding

## 6. Step-by-Step Execution Procedure

### Step 1 — Establish the architecture baseline

- Identify what the established architecture says about the area in question: patterns, ADRs, existing implementations
- If formally documented: use documentation as the baseline
- If not formally documented: infer from consistent patterns across the codebase
- If neither exists: surface as an architecture documentation gap; note lower confidence; do not invent an authoritative baseline

**Red flags:** No documentation and inconsistent patterns across the codebase (indicates existing drift rather than an established baseline)

### Step 2 — Compare the proposed change against the baseline

- State explicitly how the proposed change aligns with or differs from the established baseline
- Cite specific evidence: documentation references, ADR IDs, codebase examples per GM-4
- Do not rely on assertion — every comparison must be grounded in observable evidence

### Step 3 — Classify the assessment

- **CONSISTENT**: Proposed change follows established patterns. Document briefly. No action required.
- **DEVIATION_JUSTIFIED**: Proposed change deviates, but the deviation has a sound technical justification. Recommend ADR creation or update. Log deviation per DT-1.
- **DEVIATION_UNDOCUMENTED**: Proposed change deviates with no stated justification. Block until justified or revised.

### Step 4 — Respond based on classification

**CONSISTENT:** Surface evidence and release gate.

**DEVIATION_JUSTIFIED:**
- Document the deviation with rationale per DT-1
- Recommend ADR creation or update with enough detail to be actionable
- Flag `technical-debt-management` if the deviation creates ongoing maintenance risk
- Flag `decision-confirmation-gate` if the deviation is significant or affects widely-shared components

**DEVIATION_UNDOCUMENTED:**
- Block the change
- State what the deviation is and what justification or evidence is required
- Offer two paths: revise to align with existing patterns, or provide justification and an ADR

### Step 5 — Document outcome

- Always document the assessment with cited evidence per GM-4
- If drift is widespread, flag `technical-debt-management` with the scope of the drift
- If a deviation is logged, produce a DT-1-compliant log entry

## 7. Core Responsibilities

- Establish and cite the architecture baseline before assessing
- Compare proposed changes against the baseline with evidence, not intuition per GM-4
- Classify every assessment as CONSISTENT, DEVIATION_JUSTIFIED, or DEVIATION_UNDOCUMENTED
- Block DEVIATION_UNDOCUMENTED until justified or revised
- Recommend ADRs for intentional deviations
- Surface widespread drift to `technical-debt-management`
- Escalate high-risk deviations to `decision-confirmation-gate`

**Quality criteria:**
- Every assessment cites specific evidence from documentation or codebase
- No deviation is silently accepted
- Justified deviations are always logged and ADR-tracked

## 8. Constraints (Rules Applied)

* **DA-7: Architectural Consistency** — All proposed changes assessed against established architecture; undocumented deviations blocked until justified.
* **DA-1: SOLID Principles** — Patterns violating SOLID principles are flagged as inconsistent even without an explicit ADR.
* **DA-3: Design Pattern Application** — Introduced patterns assessed for consistency with the established design pattern strategy in the codebase.
* **GM-4: Evidence-Based Reasoning** — All assessments must cite specific evidence (documentation references, codebase examples, ADR IDs); no assessment valid on assertion alone.
* **DT-1: Explicit Tradeoff Logging** — Justified deviations logged with rationale, scope, and impacted areas before the deviation is accepted.

## 9. Tradeoff Handling

**Tradeoff 1: Strict consistency vs. pragmatic deviation**
- Scenario: The established pattern is outdated or ill-suited for the new context
- Default stance: Allow deviation with documented justification and a recommended ADR
- Resolution: Classify as DEVIATION_JUSTIFIED; recommend ADR; log per DT-1

**Tradeoff 2: Blocking vs. acknowledging widespread drift**
- Scenario: The deviation is already widespread across the codebase — blocking the current change seems disproportionate
- Default stance: Surface the drift; flag `technical-debt-management`; do not treat existing drift as a valid baseline
- Resolution: Document scope of drift; recommend a remediation plan; do not continue drifting silently

**Tradeoff 3: Assessment with incomplete baseline**
- Scenario: Architecture documentation is missing; patterns in codebase are inconsistent
- Default stance: Note the documentation gap; infer from codebase as best as possible; flag uncertainty explicitly
- Resolution: Recommend establishing a baseline ADR as part of resolving the current change

## 10. Failure & Escalation Behavior

**Undocumented deviation detected**
- Trigger: Proposed change conflicts with established pattern; no justification provided
- Action: Block change → state deviation with evidence → request justification or revision
- Format: "Deviation from established pattern: [description]. Established approach: [cited example]. Please provide justification or revise to align."

**Drift is widespread**
- Trigger: Proposed change is inconsistent, but the same inconsistency exists broadly across the codebase
- Action: Flag `technical-debt-management` → document drift scope → do not validate drift as consistency
- Format: "Architectural drift detected across [scope]. This is accumulated inconsistency, not an established pattern. Flagging technical-debt-management for remediation planning."

**No architecture baseline available**
- Trigger: No documentation; codebase patterns are inconsistent; cannot establish a reliable baseline
- Action: Document the gap → note lower confidence in assessment → recommend establishing a baseline ADR
- Format: "No architecture baseline available for [area]. Assessment confidence is low. Recommend establishing a baseline ADR before proceeding."

**High-risk deviation requires explicit approval**
- Trigger: Deviation affects a critical or widely-shared component
- Action: Flag `decision-confirmation-gate` → do not accept deviation without explicit approval

## 11. Skill Integration & Orchestration

**Upstream (skills that flag this skill):**
- `code-maintenance` — when decayed or inconsistent patterns surface during maintenance
- `design-pattern-selection` — when a new pattern may conflict with established architecture

**Downstream (this skill flags):**
- `technical-debt-management` — when drift is widespread or deviation is accepted as debt
- `decision-confirmation-gate` — when deviation is high-risk or affects widely-shared components

## 12. Related Skills

- `technical-debt-management` — manages remediation planning once drift is surfaced
- `decision-confirmation-gate` — gates high-risk or significant deviations
- `design-pattern-selection` — selects patterns; this skill validates them against existing architecture
- `system-design` — establishes the architecture this skill validates against
- `engineering-decision-logging` — logs the architectural decisions this skill surfaces

## 13. Governance Hooks

**Mandatory behaviors:**
- Every assessment cites specific evidence — no assertions without references per GM-4
- Undocumented deviations are always blocked until justified
- Justified deviations are always logged per DT-1
- Widespread drift is always flagged to `technical-debt-management`

**Audit trail:**
- Document: baseline used and how it was established, comparison made, classification, evidence cited, DT-1 log entry if applicable, ADR recommended if applicable

## 14. Example Use Cases

**Example 1: New pattern consistent with established architecture**
A new service follows the repository pattern used throughout the codebase. `design-pattern-selection` flags `architecture-consistency`. Baseline: five existing services using the same pattern — cited. Assessment: CONSISTENT. Gate released.

**Example 2: Justified deviation with ADR**
A performance-critical component introduces a cache layer that bypasses the standard repository abstraction. Assessment: DEVIATION_JUSTIFIED. Rationale: performance budget requires direct cache access; repository abstraction adds unacceptable latency. ADR recommended. DT-1 log entry created.

**Example 3: Undocumented deviation blocked**
A new module introduces a global singleton for configuration, conflicting with the dependency injection pattern used everywhere else. No justification provided. Assessment: DEVIATION_UNDOCUMENTED. Change blocked. Justification or revision requested.

**Example 4: Widespread drift surfaces technical debt**
Code maintenance review reveals six modules have bypassed the established error handling pattern over time. Assessment: drift is widespread. `technical-debt-management` flagged with scope of the drift. The proposed change is not validated as consistent — drift is named and tracked, not normalized.

## 15. Anti-Patterns to Catch

1. **Validating drift as consistency** — because something is done in many places does not make it the established pattern.
2. **Blocking all deviations without evaluating justification** — justified deviations with ADRs are acceptable and should be logged, not blocked.
3. **Assessing without evidence** — asserting CONSISTENT or DEVIATION_UNDOCUMENTED without citing documentation or codebase examples.
4. **Inventing a baseline** — if no documentation exists and codebase patterns are inconsistent, say so; do not infer a definitive baseline and treat it as authoritative.
5. **Ignoring widespread drift** — surface it to `technical-debt-management` rather than quietly allowing it to accumulate.
6. **Treating style preferences as architectural concerns** — naming conventions and formatting are not architectural consistency issues.
7. **Requiring ADRs for trivial decisions** — only significant deviations from established patterns warrant ADR recommendations.
8. **Assessing the change in isolation** — understanding the broader drift context is part of a complete assessment.

## 16. Non-Goals

- Writing ADRs from scratch (this skill recommends them; authoring is a separate concern)
- Code style or naming convention enforcement (use `clean-code-solid`)
- Full system design or architecture creation (use `system-design`)
- Evaluating whether the established architecture is sound (use `system-design` or `technical-debt-management`)

## 17. Notes for LLM Implementation

- Always cite specific evidence when making an assessment — name files, ADR IDs, or documentation sections
- Use the three-state classification (CONSISTENT, DEVIATION_JUSTIFIED, DEVIATION_UNDOCUMENTED) explicitly in every output
- When drift is widespread, quantify it: "6 of 12 modules" rather than "many places"
- ADR recommendations should include enough context to be actionable: what needs to be decided and why
- If the baseline is uncertain, state the confidence level explicitly and explain what is and is not known
