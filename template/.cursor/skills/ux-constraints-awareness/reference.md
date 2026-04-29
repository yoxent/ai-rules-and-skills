```yaml
---
name: ux_constraints_awareness
description: Ensures feature designs adhere to UX guidelines, accessibility standards, and usability constraints before implementation; prevents UX violations from reaching production.
version: 1.0.0
category: Product
tags: [ux, accessibility, wcag, usability, design-constraints]
priority: Medium

depends_on: []
flags_skills: [feature-validation, risk-analysis]

inputs: [feature-designs, interaction-specs, ux-guidelines, accessibility-standards]
outputs: [ux-compliance-report, design-adjustment-recommendations, accessibility-alerts]

rules_applied:
  - CL-1
  - PS-1
  - CL-4

execution_context: Triggered before implementation of any user-facing design. Runs after requirement-interpretation and before sprint commitment on UI features.
---
```

---

# Skill: UX Constraints Awareness

---

## Purpose

**What this skill does:**
Evaluates proposed feature designs against UX principles, accessibility standards (WCAG, platform HIG), and internal design system constraints before implementation begins. Catches violations early — when design changes are cheap — rather than during QA or post-launch.

Accessibility violations create legal exposure (ADA, EN 301 549). Inconsistent UX patterns degrade learnability and increase support burden. Dark patterns damage user trust and may trigger regulatory action. All of these are cheaper to prevent at design time than to fix post-release.

Surfaces UX constraints as explicit sprint requirements before implementation begins. Prevents costly late-stage redesigns driven by QA or user research findings that could have been caught at design review.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new UI component, screen, or interaction pattern is being designed
* An existing UI flow is being modified or redesigned
* A feature introduces a new form, modal, navigation element, or data display
* Accessibility compliance is uncertain for a proposed design
* A design deviates from the established design system or platform conventions
* A dark pattern or potentially deceptive UI element is suspected
* `user-impact-analysis` flags a UX risk requiring deeper design assessment

### Do NOT use this skill for:

* Formal accessibility testing with assistive technologies — that is QA scope
* Visual design critique (color palettes, typography aesthetics) — this skill focuses on usability and compliance
* Backend API design — no UX surface
* Implementing design fixes — engineering task

---

## Inputs

**Required inputs:**

* **Feature design or interaction specification** — Wireframes, mockups, or written interaction descriptions.
* **Applicable UX guidelines** — Internal design system, platform HIG (iOS, Android, Web), or product-specific conventions.

**Optional inputs:**

* **WCAG checklist** — WCAG 2.1 AA as minimum standard unless higher level specified.
* **User research findings** — Inform whether the design matches established user mental models.
* **Existing component library** — Used to check whether the design deviates from established patterns.

---

## Outputs

**Primary outputs:**

* **UX compliance report** — Per-finding assessment against UX principles, accessibility standards, and design system consistency.
* **Design adjustment recommendations** — Specific changes required to resolve each violation, in design language not implementation language.
* **Accessibility alerts** — WCAG violations with the specific criterion violated and the affected user group.

---

## Preconditions

**Conditions that must be met before execution:**

* A feature design or interaction specification is available — this skill cannot assess unspecified designs
* Applicable UX guidelines and accessibility standard are known (default: WCAG 2.1 AA)
* The target platform is identified (web, iOS, Android, or cross-platform)

---

## Step-by-Step Execution Procedure

### Step 1: Identify Applicable Standards

**Actions:**
- [ ] Confirm target platform(s) and applicable standards: WCAG 2.1 AA minimum; platform HIG if native; internal design system if available
- [ ] Note any elevated standards (e.g., WCAG 2.1 AAA, EN 301 549 for EU compliance)
- [ ] Identify the design system components the feature should use

---

### Step 2: Accessibility Compliance Check

**Actions:**
- [ ] Check color contrast ratios for text and interactive elements (WCAG 1.4.3 minimum 4.5:1 for normal text)
- [ ] Verify keyboard navigability of all interactive elements (WCAG 2.1.1)
- [ ] Confirm focus indicators are visible (WCAG 2.4.7)
- [ ] Check that all non-text content has text alternatives (WCAG 1.1.1)
- [ ] Verify form elements have associated labels (WCAG 1.3.1)
- [ ] Check that error messages are descriptive and accessible (WCAG 3.3.1, 3.3.2)
- [ ] Confirm touch targets meet minimum size requirements (WCAG 2.5.5: 44×44px)

**Red flags:**
- Any interactive element unreachable by keyboard — WCAG 2.1.1 violation, HIGH severity
- Color as sole differentiator (e.g., red/green without icon or text) — WCAG 1.4.1 violation
- Missing ARIA labels on custom components

---

### Step 3: UX Principle Compliance Check

**Actions:**
- [ ] Check consistency with established interaction patterns in the design system
- [ ] Verify the design follows the principle of least surprise — no interactions that violate user mental models
- [ ] Check that error states and empty states are designed (not just happy path)
- [ ] Verify loading states are handled — no unexplained blank screens
- [ ] Check that destructive actions require confirmation

**Red flags:**
- Design only covers happy path — missing error, empty, and loading states
- Interaction pattern inconsistent with design system without documented justification
- Destructive actions (delete, irreversible submit) have no confirmation step

---

### Step 4: Dark Pattern and Ethical Check (CL-4)

**Actions:**
- [ ] Check for pre-checked opt-ins (deceptive defaults)
- [ ] Check for hidden costs or information revealed only at final step
- [ ] Check for confirm-shaming (guilt-framing opt-out copy)
- [ ] Check for misleading visual hierarchy that draws attention away from important information
- [ ] Check for roach motel patterns (easy to enter, hard to exit)

**Red flags — flag `risk-analysis` immediately on any of:**
- Pre-checked consent or opt-in
- Confirm-shaming copy
- Misleading visual hierarchy on consequential choices
- Subscription or trial that is difficult to cancel

---

### Step 5: Design System Consistency Check

**Actions:**
- [ ] Verify the design uses components from the established design system where applicable
- [ ] Flag any new components that duplicate existing ones
- [ ] Document justified deviations — deviations without justification are treated as inconsistencies

---

### Final Step: Generate UX Compliance Report

```markdown
## UX Constraints Awareness Report

**Feature:** [Name]
**Date:** [YYYY-MM-DD]
**Platform:** [Web / iOS / Android / Cross-platform]
**Standard:** WCAG 2.1 AA / [other]
**Status:** ✅ COMPLIANT / ⚠️ VIOLATIONS FOUND / ❌ BLOCK — DARK PATTERN OR LEGAL RISK

### Accessibility Findings
| # | Criterion | Finding | Severity | Recommendation |
|---|-----------|---------|----------|----------------|
| 1 | WCAG 1.4.3 | Contrast ratio 3.1:1 on body text | HIGH | Increase to 4.5:1 minimum |

### UX Principle Findings
- [Finding]: [Specific element], [Violation], [Recommendation]

### Dark Pattern / Ethical Findings
- ❌ [Pattern detected]: [Description] → flag:risk-analysis

### Design System Consistency
- [Deviation]: [Element], [Justification provided: Yes/No]

### Skills Flagged
- ⚡ **feature-validation**: [If structural UX violation affects go/no-go]
- 🛡️ **risk-analysis**: [Dark pattern or legal accessibility risk]

### Required Actions Before Implementation
- [ ] [Specific design change 1]
- [ ] [Specific design change 2]
```

---

## Core Responsibilities

1. Apply WCAG 2.1 AA as the minimum accessibility standard on all UI features
2. Flag CL-4 dark patterns immediately and unconditionally — regardless of business intent
3. Ensure error, empty, and loading states are designed — not just happy path
4. Surface UX constraints as sprint requirements before implementation begins per PS-1
5. Flag legal accessibility risk to `risk-analysis`; structural violations to `feature-validation`

---

## Constraints (Rules Applied)

* **CL-1:** Accessibility has legal compliance dimensions (ADA, EN 301 549). Violations are not just UX issues — they are compliance risks.
* **PS-1:** UX constraints must be surfaced as requirements before sprint commitment. Discovered in QA = requirement failure.
* **CL-4:** Dark patterns and deceptive UX flagged immediately regardless of business justification.

---

## Tradeoff Handling

### Tradeoff 1: Strict UX Adherence vs Rapid Feature Development

**Conflict:** UX review adds time; teams want to ship fast.

**Resolution:** HIGH-severity violations or legal risks block until resolved — no speed override. MEDIUM violations are a conditional go with design fix as a sprint entry criterion. LOW violations are logged and accepted for the next iteration. Never skip the accessibility check for delivery speed — CL-1 is not negotiable.

### Tradeoff 2: UX Consistency vs Feature-Specific Optimisation

**Conflict:** Deviation from the design system may be justified for a specific user context.

**Resolution:** Deviation is permitted only with explicit documented justification. Undocumented deviations are treated as violations. Log justified deviations in the report for design system review.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Dark Pattern Detected (CL-4)

**Trigger:** Any of the dark pattern criteria in Step 4 are met.

**Action:**
- Flag `risk-analysis` immediately
- Block implementation pending ethics/legal review
- Document the specific pattern and why it qualifies
- Cannot be overridden by business priority

### Escalation Scenario 2: Structural Accessibility Violation

**Trigger:** A core interaction flow is inaccessible (keyboard navigation broken, no text alternatives for primary content).

**Action:**
- Classify as HIGH severity
- Flag `feature-validation` — structural inaccessibility may affect go/no-go
- Require design revision before sprint commitment

### Escalation Scenario 3: Missing States in Design

**Trigger:** Error, empty, or loading states are not designed.

**Action:**
- Flag as MEDIUM severity violation
- Require states to be designed before sprint commitment
- Do not allow "we'll handle it in code" — states must be designed, then implemented

---

### When to halt execution:

* No design or interaction specification is available — cannot assess what hasn't been designed
* Applicable standard cannot be determined — request clarification before proceeding

---

## Skill Integration & Orchestration

Runs before sprint commitment on UI features. Called after `requirement-interpretation` and alongside `user-impact-analysis`. Feeds `feature-validation` (structural violations) and `risk-analysis` (legal/ethical risks).

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| Structural UX violation affecting feasibility | feature-validation | Go/no-go reconsideration needed |
| Dark pattern or legal accessibility risk | risk-analysis | Ethics/legal review required |

---

## Related Skills

* **Co-runs with:** `user-impact-analysis` (complementary pre-release checks)
* **Called after:** `requirement-interpretation`
* **Flags:** `feature-validation`, `risk-analysis`

---

## Governance Hooks

* [ ] WCAG 2.1 AA applied as minimum on all UI features — no exceptions for delivery speed
* [ ] CL-4 dark pattern flags are unconditional
* [ ] UX constraints logged as sprint requirements, not post-implementation findings
* [ ] All design deviations documented with justification

---

## Example Use Cases

### Example 1: Form Design Review

**Scenario:** New checkout address form with custom styled inputs.

**Findings:** Labels are visually present but not programmatically associated with inputs (WCAG 1.3.1 violation, HIGH). Contrast on placeholder text is 2.8:1 (WCAG 1.4.3 violation, HIGH). Error messages use color only with no icon (WCAG 1.4.1, MEDIUM).

**Result:** ❌ VIOLATIONS FOUND — 2 HIGH, 1 MEDIUM. Sprint entry criteria: all three resolved before implementation begins.

### Example 2: Email Unsubscribe Flow

**Scenario:** Marketing requests an email preference center where "Unsubscribe from all" is visually de-emphasized compared to "Keep receiving emails."

**Findings:** Misleading visual hierarchy on a consequential choice — dark pattern (CL-4).

**Result:** ❌ BLOCK — `risk-analysis` flagged. Implementation blocked pending ethics/legal review.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Reviewing only the happy path design
✅ Error, empty, and loading states are required deliverables — review all four states.

❌ **Anti-pattern 2:** Accepting "we'll handle accessibility in code" without a design spec
✅ Accessibility must be designed, then implemented. Code-only accessibility is fragile and incomplete.

❌ **Anti-pattern 3:** Treating color contrast as a visual preference
✅ Contrast ratios are WCAG requirements with legal backing. Non-compliant contrast is a HIGH-severity violation.

❌ **Anti-pattern 4:** Allowing a dark pattern because the business case is strong
✅ CL-4 is unconditional. Business justification does not override ethical/legal risk.

❌ **Anti-pattern 5:** Treating design system deviations as acceptable without documentation
✅ Every deviation requires explicit justification. Undocumented deviations are violations.

❌ **Anti-pattern 6:** Deferring UX review to QA
✅ UX constraints are sprint requirements per PS-1. QA discovery means the requirement process failed.

---

## Non-Goals

* ❌ Formal accessibility testing with screen readers or assistive technologies — QA scope
* ❌ Visual aesthetic critique — this skill focuses on compliance and usability
* ❌ Implementing design fixes — engineering task
* ❌ A/B test design — separate skill

---

## Notes for LLM Implementation

1. **Standards first:** Always confirm the applicable accessibility standard before starting the review. Default is WCAG 2.1 AA — but confirm, don't assume.
2. **All four states:** For every form, screen, or interaction — check that happy path, error, empty, and loading states are all specified.
3. **CL-4 before everything else:** If you spot a potential dark pattern at any point in the review, flag it immediately. Do not finish the review and mention it at the end.
4. **Design language in recommendations:** Recommendations must be stated in design terms ("increase contrast ratio to 4.5:1"), not implementation terms ("add a CSS class").

---
