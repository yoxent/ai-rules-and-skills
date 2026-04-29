```yaml
---
name: user_impact_analysis
description: Evaluates how features, changes, or incidents affect end-user experience; recommends adjustments to maximize positive impact and mitigate negative effects.
version: 1.1.0
category: Product
tags: [user-experience, impact, ux, accessibility, user-research]
priority: Medium

depends_on: []
flags_skills: [feature-validation, risk-analysis, stakeholder-communication]

inputs: [user-research, feature-designs, behavioral-data, metrics]
outputs: [user-impact-report, mitigation-recommendations, stakeholder-communication-plan]

rules_applied:
  - PS-1
  - PS-2
  - CL-4

execution_context: Triggered before release of user-facing changes, or when UX risk is flagged by feature-validation. Runs alongside or after requirement-interpretation; before sprint commitment on user-facing features.
---
```

---

# Skill: User Impact Analysis

---

## Purpose

**What this skill does:**
Evaluates the effect of proposed features, changes, or incidents on end-user experience. Identifies both positive and negative impacts, quantifies affected user segments where measurable, and recommends design or implementation adjustments to improve outcomes before release.

Poor user impact leads to low adoption, churn, negative reviews, and support burden — all measurable business costs. Catching UX regressions and unintended negative effects before release is far cheaper than post-release remediation.

Surfaces implicit user assumptions embedded in technical decisions before they become user-facing defects. Connects technical choices to measurable user outcomes.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A user-facing feature or change is about to be committed to sprint
* A change modifies existing user flows, navigation, or interaction patterns
* Performance changes may affect perceived responsiveness (not just measured latency)
* An incident has impacted users and a post-incident impact assessment is needed
* A feature redesigns or replaces existing UI components used by multiple user segments
* Accessibility compliance is in question for a new interface element
* Ethical concerns about user manipulation or dark patterns are raised

### Do NOT use this skill for:

* Backend-only changes with no user-visible effect
* Pure performance optimization with no UX surface change — use `performance-optimization`
* Formal accessibility audit — this skill flags UX risk; deep accessibility testing is handled by QA
* Stakeholder communication of findings — use `tradeoff-communication` or `stakeholder-communication`

---

## Inputs

**Required inputs:**

* **Feature design or change description** — What is changing from the user's perspective.
* **User segments affected** — Which user groups are impacted (new users, power users, accessibility users, mobile users, etc.).

**Optional inputs:**

* **User research and behavioral data** — Existing research informing how users currently behave. Used to assess deviation from established patterns.
* **Metrics and KPIs** — Quantitative targets (retention, conversion, task completion rate) used to frame impact magnitude.
* **UX guidelines and accessibility standards** — WCAG, platform HIG, internal design system rules.

---

## Outputs

**Primary outputs:**

* **User impact report** — Per-segment assessment of positive and negative effects with severity.
* **Mitigation recommendations** — Specific design or implementation adjustments to reduce negative impact.
* **Stakeholder communication plan** — Which findings need to be communicated to which stakeholders before release, and in what form.

---

## Preconditions

**Conditions that must be met before execution:**

* At least one user-facing change is in scope
* Affected user segments are identifiable
* Feature design or change description is available

---

## Step-by-Step Execution Procedure

### Step 1: Identify Affected User Segments

**Actions:**
- [ ] List all user segments who will encounter the change (new users, returning users, power users, accessibility users, mobile users, international users)
- [ ] For each segment, identify: frequency of interaction with the affected feature, dependency on current behavior, vulnerability to negative change

**Red flags:**
- A segment with high dependency on current behavior is being changed without a migration path
- Accessibility users are not explicitly considered as a segment

---

### Step 2: Assess Positive and Negative Effects per Segment

**Actions:**
- [ ] For each segment, state the primary positive effect of the change (if any)
- [ ] For each segment, state the primary negative effect or regression risk (if any)
- [ ] Quantify where possible: affected user count, frequency of impact, severity (HIGH/MEDIUM/LOW)

**Red flags:**
- A change that benefits new users at the expense of existing power users without acknowledgment
- Perceived performance regression (e.g., loading behavior change) even when measured metrics improve
- Dark patterns or manipulative design elements — flag CL-4 immediately

---

### Step 3: Validate Against User Requirements and KPIs

**Actions:**
- [ ] Cross-reference findings against stated user requirements per PS-1
- [ ] Check whether the change moves KPIs in the intended direction
- [ ] Flag any finding where the change technically meets requirements but contradicts user intent

---

### Step 4: Define Mitigations for Negative Impacts

**Actions:**
- [ ] For each HIGH or MEDIUM negative impact, define a specific mitigation
- [ ] Classify mitigation: eliminates / reduces / accepts the impact
- [ ] For accepted impacts, document the business rationale

---

### Step 5: Determine Communication Requirements

**Actions:**
- [ ] Identify which negative impacts must be communicated to stakeholders before release per PS-2
- [ ] For HIGH-severity negative impacts: require explicit stakeholder acknowledgment
- [ ] For ethical or accessibility risks: flag `risk-analysis`

---

### Final Step: Generate User Impact Report

```markdown
## User Impact Analysis Report

**Feature/Change:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ LOW IMPACT / ⚠️ MITIGABLE IMPACT / ❌ HIGH IMPACT — REVIEW REQUIRED

### Affected Segments
| Segment | Positive Effect | Negative Effect | Severity |
|---------|----------------|----------------|----------|
| ...     | ...            | ...            | H/M/L    |

### Mitigation Recommendations
- [Segment]: [Specific mitigation action]

### Communication Required (PS-2)
- [Stakeholder]: [What to communicate and when]

### Skills Flagged
- ⚡ **feature-validation**: [Reason — severity threshold exceeded]
- 🛡️ **risk-analysis**: [Reason — ethical/accessibility risk]
- 📢 **stakeholder-communication**: [Reason — undisclosed HIGH-severity impact]

### Overall Assessment
- ✅ LOW IMPACT: Proceed; no stakeholder communication required
- ⚠️ MITIGABLE: Proceed with mitigations applied
- ❌ HIGH IMPACT: Flag feature-validation; do not release without review
```

---

## Core Responsibilities

1. Identify all affected user segments — no segment silently excluded
2. Assess both positive and negative effects per segment with severity
3. Flag CL-4 ethical/dark-pattern risks immediately and unconditionally
4. Provide specific mitigations for every HIGH and MEDIUM negative finding
5. Communicate negative impacts to stakeholders before release per PS-2

---

## Constraints (Rules Applied)

* **PS-1:** Impact assessed against stated user requirements, not just technical correctness.
* **PS-2:** Negative user impacts communicated to stakeholders before release — not surfaced post-launch.
* **CL-4:** Ethical risks (dark patterns, manipulation, discriminatory behavior) flagged immediately regardless of business intent.

---

## Tradeoff Handling

### Tradeoff 1: Feature Richness vs Usability

**Conflict:** Adding capabilities increases complexity; may degrade comprehension for some segments.

**Resolution:** Quantify the comprehension cost per affected segment. If the cost exceeds the benefit for a primary segment, recommend scoping the feature. Surface via `tradeoff-communication` if a stakeholder decision is needed.

### Tradeoff 2: Performance Optimization vs Perceived Experience

**Conflict:** Measured metric improves but perceived experience changes negatively (e.g., loading skeleton replaced by instant render that feels jarring).

**Resolution:** Distinguish measured impact from perceived impact explicitly. Recommend user testing if perceived impact is uncertain. Do not approve the change as low-impact based on metrics alone.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: HIGH-Severity Negative Impact

**Trigger:** A change will significantly degrade the experience of a primary user segment.

**Action:**
- Flag `feature-validation` to reconsider go/no-go
- Document the specific segment, impact description, and severity
- Do not recommend release without mitigation or explicit stakeholder acceptance

### Escalation Scenario 2: Ethical Risk / Dark Pattern (CL-4)

**Trigger:** Feature contains manipulative UI, deceptive flows, or discriminatory behavior.

**Action:**
- Flag `risk-analysis` immediately
- Document the specific pattern and why it constitutes an ethical risk
- Block release pending ethics review — cannot be overridden by business priority

### Escalation Scenario 3: Accessibility Violation

**Trigger:** Change violates WCAG guidelines or platform accessibility standards.

**Action:**
- Flag `risk-analysis` (legal compliance dimension — CL-1)
- Document the specific violation and affected user group
- Require remediation before release

---

### When to halt execution:

* Ethical risk (CL-4) detected with no review process available
* Affected user segments cannot be identified with sufficient specificity to assess impact

---

## Skill Integration & Orchestration

Runs before sprint commitment on user-facing features. Feeds `feature-validation` (severity findings) and `risk-analysis` (ethical/accessibility findings). Does not depend on any skill but consumes outputs from `requirement-interpretation`.

### Skills That May Be Flagged

| Scenario | Flag | Reason |
|---|---|---|
| HIGH-severity negative impact on primary segment | feature-validation | Go/no-go reconsideration needed |
| Ethical risk, dark pattern, or accessibility violation | risk-analysis | Formal risk assessment and compliance review required |
| Impact left undisclosed before release | stakeholder-communication | Ensure HIGH-severity findings reach stakeholders |

---

## Related Skills

* **Cooperates with:** `requirement-interpretation` (user requirements context), `tradeoff-communication` (surfacing impact tradeoffs to stakeholders)
* **Flags:** `feature-validation`, `risk-analysis`
* **No hard dependencies**

---

## Governance Hooks

* [ ] CL-4 ethical risk flags are unconditional — cannot be suppressed by business priority
* [ ] All HIGH-severity negative impacts communicated to stakeholders before release (PS-2)
* [ ] No segment silently excluded from assessment

---

## Example Use Cases

### Example 1: Navigation Redesign

**Scenario:** Global navigation restructured to improve discoverability for new users.

**Segments:** New users (positive — clearer entry points), power users (negative — muscle memory disrupted), mobile users (positive — better thumb-zone layout), accessibility users (neutral if ARIA labels maintained).

**Findings:** MEDIUM negative impact on power users. Mitigation: in-app tooltip on first post-launch login mapping old locations to new. No ethical risk.

**Result:** ⚠️ MITIGABLE — proceed with tooltip mitigation.

### Example 2: Onboarding Flow with Opt-Out Pre-Checked

**Scenario:** Marketing requests email opt-in pre-checked by default in onboarding.

**Findings:** Dark pattern detected — pre-checked opt-in is deceptive and violates GDPR consent requirements.

**Result:** ❌ CL-4 flagged → `risk-analysis` → block pending ethics/legal review.

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Assessing only the primary happy-path user segment
✅ All segments — including edge cases like accessibility users and international users — must be explicitly considered.

❌ **Anti-pattern 2:** Approving a change as low-impact based solely on improved metrics
✅ Perceived experience can diverge from measured metrics. Distinguish both explicitly.

❌ **Anti-pattern 3:** Treating a dark pattern as acceptable because the business case is strong
✅ CL-4 is unconditional. Business justification does not override ethical risk.

❌ **Anti-pattern 4:** Deferring negative impact communication to post-release
✅ PS-2 requires stakeholder communication before release for HIGH-severity findings.

❌ **Anti-pattern 5:** Vague mitigations ("consider user testing")
✅ Mitigations must be specific and actionable: "Add tooltip on first post-launch login for power users showing old-to-new navigation mapping."

---

## Non-Goals

* ❌ Formal accessibility audit — this skill flags risk; QA handles detailed testing
* ❌ Stakeholder briefing content — use `tradeoff-communication` or `stakeholder-communication`
* ❌ UX design decisions — this skill assesses impact, not design
* ❌ Backend-only changes with no user-visible surface

---

## Notes for LLM Implementation

1. **Segment completeness:** Always explicitly consider accessibility users and mobile users as segments, even if not mentioned in the requirement. These are commonly omitted and carry legal risk.
2. **Perceived vs measured:** When performance changes are in scope, always distinguish "measured improvement" from "perceived experience change" — they can diverge.
3. **CL-4 first:** If a dark pattern or manipulative element is suspected at any point, flag it before completing the rest of the assessment.
4. **Specific mitigations only:** "Consider user testing" is not a mitigation. State what specifically should be tested, by whom, and what outcome would clear the risk.

---
