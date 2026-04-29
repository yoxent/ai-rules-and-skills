# Skill Human Spec: Design Reference

```yaml
---
name: design-reference
description: Requires Assets/Design/ to be consulted before implementing mechanics or lore, and references the authoritative GDD/NDD document
version: 1.0.0
category: Design Governance
tags: [unity, design-doc, gdd, ndd, mechanics, lore, authority]
priority: Medium

depends_on: []
flags_skills: []

inputs: [implementation_intent, source_code_or_plan, available_design_documents]
outputs: [design_alignment_assessment, traceability_confirmation, deviation_log, approval_status]

rules_applied:
  - GM-4   # Behavioral Transparency
  - DA-7   # Architectural Consistency
  - DT-1   # Explicit Tradeoff Logging

documents_needed: [Assets/Design/GDD, Assets/Design/NDD]

execution_context: Runs before implementing any mechanics, lore, or game logic; verifies Assets/Design/ has been consulted
---
```

---

# Skill: Design Reference

---

## Purpose

**What this skill does:**
Verifies that `Assets/Design/` is consulted before implementing any gameplay mechanic, economy rule, narrative element, or game logic. Requires a reference to the specific GDD (Game Design Document) or NDD (Narrative Design Document) in implementation comments or logs. Flags and logs any deviation from documented design intent via DT-1.

Disconnected implementation and design documents cause feature drift — mechanics that contradict the design intent, economy balancing errors, or lore inconsistencies that require expensive rework. This skill enforces traceability between code and intent.

Makes the implementation's design justification explicit and reviewable. Reduces rework caused by undocumented assumptions about intended behaviour. Establishes a clear audit trail from design decision to code.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new gameplay mechanic or rule is about to be implemented
* An economy system (currency, rewards, drops) is being coded
* Narrative logic, quest conditions, or dialogue triggers are being implemented
* A game rule or win/lose condition is coded
* A design assumption is being inferred from context rather than read from a document
* A developer is unsure whether a behaviour is "intended" or "assumed"

### Do NOT use this skill for:

* Pure technical scaffolding with no design intent (e.g., dependency injection setup, logging infrastructure)
* Refactoring existing mechanics without changing their behaviour
* Art asset import or material setup with no mechanics involved
* Performance optimisation of already-designed-and-approved mechanics

**Execution Context Details:**
Runs before implementation begins, not after. Intended as a pre-work gate that confirms the design source exists and has been read. Lightweight — not a full design review.

---

## Inputs

**Required inputs:**

* **Implementation intent** — What the developer plans to implement (brief description or task card)
* **Available design documents** — What GDD/NDD files exist in `Assets/Design/`

**Optional inputs:**

* **Source code or plan** — Draft code or pseudocode if work has begun; used to check for unexplained logic

**Documents/Context needed:**

* **Assets/Design/GDD** — Gameplay mechanics, economy, rules, win/lose conditions
* **Assets/Design/NDD** — Narrative, quests, world bible, character motivations

---

## Outputs

**Primary outputs:**

* **Design alignment assessment** — Confirms design document consulted and implementation matches intent
* **Traceability confirmation** — Specific document and section referenced in implementation comments
* **Deviation log** — Any implementation detail that diverges from the design doc, logged via DT-1
* **Approval status** — Whether implementation has documented design backing

**Output format:**

* Short confirmation or deviation report
* DT-1 log entry for any deviation

**Skill flags (if applicable):**

* No downstream flags — design-reference is an authoring-time gate

---

## Preconditions

**Conditions that must be met before execution:**

* `Assets/Design/` directory exists in the project
* At least one GDD or NDD file is present and accessible
* The mechanic or lore element being implemented is within scope of the GDD/NDD

**Validation checks:**

* [ ] `Assets/Design/` directory exists
* [ ] Relevant GDD or NDD document exists for the mechanic category
* [ ] Document is not a placeholder stub (has substantive content)

---

## Step-by-Step Execution Procedure

### Step 1: Identify the Design Document for the Mechanic

**Questions to answer:**
- What category does this mechanic fall into: gameplay, economy, or narrative?
- Which specific GDD or NDD section covers it?

**Actions:**
- [ ] Classify mechanic as: gameplay rule, economy, narrative logic, or world rule
- [ ] Identify the corresponding GDD/NDD document and section
- [ ] Confirm the document exists and has content covering the mechanic

**Red flags / Warning signs:**
- No GDD/NDD document covers the mechanic being implemented
- The document is a stub ("TBD" or empty)
- Developer is unsure which document applies

**Decision points:**
- If document covers the mechanic: proceed to Step 2
- If no document exists: escalate — implementation cannot proceed without design authority
- If document is a stub: escalate — request design owner to complete the section

---

### Step 2: Verify Implementation Matches Design Intent

**Questions to answer:**
- Does the planned or drafted implementation match the GDD/NDD specification?
- Are there any interpretations or inferences not supported by the document?

**Actions:**
- [ ] Read the relevant GDD/NDD section
- [ ] Compare planned implementation against documented rules, parameters, and intent
- [ ] Flag any "assumed" behaviour not explicitly stated in the document
- [ ] Flag any deviation — even a "minor" one — for logging

**Red flags / Warning signs:**
- Implementation adds a mechanic not mentioned in the GDD ("it seemed like it should work this way")
- Parameters (damage values, cooldowns, probability weights) not matching GDD numbers
- Narrative trigger condition inferred rather than read

**Decision points:**
- If matches: proceed to Step 3
- If deviation: escalate to Step 3 with deviation flagged

---

### Step 3: Require Document Reference in Implementation

**Questions to answer:**
- Is the GDD/NDD section referenced in the implementation code comment or commit message?

**Actions:**
- [ ] Confirm a comment like `// Ref: GDD §3.2 — Player Combat Rules` exists in the relevant code
- [ ] If missing: request the developer add the reference before proceeding
- [ ] If deviation: add a log entry via DT-1 documenting what differs and why

**Red flags / Warning signs:**
- No reference comment in code touching a designed mechanic
- Reference is vague ("// per design doc") without specifying section

**Decision points:**
- If reference present and accurate: PASS
- If reference missing: warn, request addition
- If deviation logged: PASS with DT-1 entry

---

### Final Step: Generate Design Reference Report

```markdown
## Design Reference Report

**Target:** [Mechanic or feature being implemented]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Document Located
[GDD/NDD path and section confirmed or missing]

### Implementation Alignment
[Matches spec / Deviates — details below]

### Deviations Logged
[DT-1 entries for any deviation from design doc]

### Reference Comment
[Present in code / Requested]

### Overall Assessment
- ✅ PASS: Design consulted, implementation matches or deviation logged
- ❌ FAIL: No design document exists for the mechanic
- ⚠️ NEEDS REVIEW: Deviation from design doc not yet approved

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Confirm `Assets/Design/` is consulted before any mechanic implementation begins
2. Identify the specific GDD or NDD section covering the mechanic
3. Verify implementation matches documented intent — flag deviations explicitly
4. Require a reference comment in code pointing to the specific document and section
5. Log all deviations via DT-1 with rationale

**Quality criteria:**

* Every implemented mechanic traceable to a GDD/NDD section
* Zero undocumented assumptions treated as design intent
* Every deviation from design doc logged before implementation proceeds

---

## Constraints (Rules Applied)

### Global Meta-Rules

* **GM-4: Behavioral Transparency**
  - How it applies: All outputs (implemented mechanics, economy rules) must be traceable to a documented source; assumptions must be stated as such
  - In practice: "The GDD says the drop rate is 5%" not "I assumed 5% feels right"

### Design & Architecture Rules

* **DA-7: Architectural Consistency**
  - How it applies: All mechanics must follow the patterns and rules established in the GDD; ad-hoc mechanics that contradict the design create inconsistency
  - In practice: If GDD says jump is single-jump only, do not add double-jump without a GDD update

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How it applies: When implementation deviates from design (even for good technical reasons), the deviation must be logged with justification
  - In practice: "Implemented as X instead of Y (per GDD §4.1) because Y would cause Z technical issue — logged for design owner review"

---

## Tradeoff Handling

### Tradeoff 1: Design Document Lag vs. Implementation Momentum

**Scenario:** The GDD section for the mechanic is incomplete but implementation is scheduled.

**Default stance:** Block implementation until design document is complete. If urgency requires proceeding, treat the implementation as provisional and log it explicitly via DT-1.

**Resolution process:**
1. Flag incomplete GDD section to design owner
2. If team decides to proceed anyway: log as provisional via DT-1
3. Tag code with `// PROVISIONAL — pending GDD §X.X completion`
4. Set a review checkpoint when GDD section is complete

---

### Tradeoff 2: Technical Constraint Requires Deviation from Design

**Scenario:** The GDD specifies a mechanic that cannot be implemented as written due to a technical constraint (e.g., physics limitation, platform constraint).

**Default stance:** Log the deviation via DT-1 with both the design intent and the technical constraint. Surface to design owner for approval of the modified behaviour.

**Resolution process:**
1. Document the GDD-specified behaviour
2. Document the technical constraint preventing exact implementation
3. Log via DT-1: what was intended, what was implemented, why
4. Request design owner sign-off on the modified behaviour

---

## Failure & Escalation Behavior

### Escalation Scenario 1: No Design Document Exists for the Mechanic

**Trigger:** Developer is implementing a mechanic but no GDD/NDD covers it.

**Action:**
- Block implementation
- Request design owner to document the mechanic in GDD before coding begins
- If truly exploratory (prototype): log as "design TBD" via DT-1 and flag as provisional

---

### Escalation Scenario 2: Implementation Contradicts Design Without Justification

**Trigger:** Coded mechanic diverges from GDD and no DT-1 entry exists.

**Action:**
- Block merge
- Request developer to either align with GDD or log deviation with rationale via DT-1
- Escalate to design owner for approval if deviation is significant

---

### Escalation Scenario 3: Design Document Is a Placeholder/Stub

**Trigger:** GDD section exists but contains only "TBD" or minimal content.

**Action:**
- Block — stub is not sufficient design authority
- Request design owner to complete the section
- If deadline requires proceeding: log as provisional via DT-1

---

### When to halt execution:

* `Assets/Design/` directory does not exist — design workflow not established; cannot enforce
* The feature being implemented is explicitly a technical prototype with no design intent yet

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs as a pre-implementation gate before any mechanic or lore work begins. Lightweight — does not block code review, only implementation start. Works alongside code-standards and folder-structure as a foundational check.

**Integration workflow:**
1. Developer begins a mechanics or lore implementation task
2. Orchestrator invokes design-reference
3. Skill confirms GDD/NDD exists, matches intent, reference comment added
4. After pass: implementation proceeds; code-standards runs on output

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — design-reference is a pre-implementation gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* None — runs independently before implementation begins

**Skills this skill cooperates with:**

* **code-standards** — After design-reference confirms intent, code-standards validates the implementation's structure
* **architecture-patterns** — Design intent from GDD informs architectural decisions assessed by architecture-patterns

**Skills this skill may invoke/flag:**

* None — escalates to design owner directly, not to another skill

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never allow implementation to proceed without GDD/NDD backing (or explicit provisional log)
* [ ] Log all deviations via DT-1 before implementation proceeds
* [ ] Surface all assumptions as assumptions — never treat inferred intent as documented fact per GM-4
* [ ] Do not enforce on pure technical scaffolding with no design intent
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* All provisional implementations logged via DT-1 with "pending GDD completion" tag
* All design deviations logged via DT-1 with technical justification and design owner review status

---

## Example Use Cases

### Example 1: Implementing Combat Damage

**Scenario:** Developer is about to implement the damage calculation for melee combat.

**Execution steps:**
1. Classify: gameplay rule → GDD
2. Locate: `Assets/Design/GDD.md §4.2 — Melee Combat Rules` — found, has content
3. Compare: GDD says base damage = 10, crit multiplier = 2x — matches planned implementation
4. Request: add `// Ref: GDD §4.2 — Melee Combat Rules` comment above DealDamage method
5. PASS

**Result:** ✅ PASS

---

### Example 2: No GDD Section for New Mechanic

**Scenario:** Developer plans to implement a combo system not mentioned in the GDD.

**Execution steps:**
1. Classify: gameplay rule → GDD
2. Locate: no GDD section for combo system found
3. Block: request design owner to add combo system to GDD before implementation
4. Log as escalation in report

**Result:** ❌ FAIL — design backing required before implementation

---

### Example 3: Technical Constraint Requires Deviation

**Scenario:** GDD specifies a ragdoll death animation, but Unity's physics setup cannot support it on the target mobile platform.

**Execution steps:**
1. Document GDD intent: ragdoll death (GDD §5.3)
2. Document constraint: mobile physics budget insufficient for ragdoll
3. Log via DT-1: "Implementing dissolve-and-fade instead of ragdoll per mobile budget constraint — pending design owner approval"
4. Tag code: `// DEVIATION from GDD §5.3 — see DT-1 log [date]`

**Result:** ✅ PASS with deviation logged — pending design owner approval

---

### Example 4: Stub GDD Section

**Scenario:** `Assets/Design/GDD.md §7.1 — Economy System` contains only "TBD — will define later."

**Execution steps:**
1. Locate GDD section — found but stub
2. Block: insufficient design authority to proceed
3. Request design owner to complete §7.1 before economy implementation begins

**Result:** ❌ FAIL — stub is not sufficient design authority

---

### Example 5: Narrative Trigger Implementation

**Scenario:** Developer implements a quest completion trigger based on kill count.

**Execution steps:**
1. Classify: narrative logic → NDD
2. Locate: `Assets/Design/NDD.md §2.4 — Quest: The First Hunt` — specifies "complete after 5 kills"
3. Compare: implementation uses `killCount >= 5` — matches
4. Request: `// Ref: NDD §2.4 — Quest: The First Hunt` comment added
5. PASS

**Result:** ✅ PASS

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Implementing a mechanic because "it felt right" with no GDD backing
✅ **Correct approach:** Locate the GDD section first; if none exists, escalate to design owner

❌ **Anti-pattern 2:** Vague reference comment `// per design` with no section citation
✅ **Correct approach:** `// Ref: GDD §4.2 — Melee Combat Rules`

❌ **Anti-pattern 3:** Treating a stub GDD entry as sufficient authority to implement
✅ **Correct approach:** Block; request design owner to complete the section

❌ **Anti-pattern 4:** Implementing a "minor" deviation from the GDD without logging
✅ **Correct approach:** Every deviation, however minor, logged via DT-1

❌ **Anti-pattern 5:** Proceeding with implementation before the GDD section exists
✅ **Correct approach:** Block implementation; request design doc first or log as provisional

❌ **Anti-pattern 6:** Using narrative logic from memory rather than the NDD
✅ **Correct approach:** Read the NDD section; cite it in implementation

❌ **Anti-pattern 7:** Assuming economy values (drop rates, prices) not stated in GDD
✅ **Correct approach:** Request GDD owner to specify values; do not invent them

❌ **Anti-pattern 8:** Treating exploratory prototype code as exempt from design traceability indefinitely
✅ **Correct approach:** Log as provisional via DT-1; require GDD backing before feature enters production

---

## Non-Goals

* ❌ Does not review or validate the GDD/NDD content itself — that is the design owner's responsibility
* ❌ Does not assess technical implementation quality — use code-standards
* ❌ Does not enforce game balance or design quality — only traceability
* ❌ Does not run on pure technical scaffolding, infrastructure, or tooling code

---

## Notes for LLM Implementation

1. **Never infer design intent** — if it is not in the GDD/NDD, it is not confirmed design; flag it per GM-4
2. **Block is appropriate for missing design backing** — do not allow implementation to proceed without it
3. **Provisional logging is a valid resolution** — not all design docs are complete; provisional + DT-1 is an acceptable path
4. **Do not review the design quality** — this skill validates traceability, not whether the design is good
5. **Reference comment specificity matters** — "§4.2 — Melee Combat Rules" is good; "design doc" is not

**Output format preferences:**
* Short, structured report
* DT-1 log entries clearly formatted
* Code comment template for reference citation

**Tone and approach:**
* Be collaborative — design reference is about alignment, not gatekeeping
* Be specific — cite exact GDD/NDD sections in all findings

---

## Metadata Summary

```yaml
name: design-reference
category: Design Governance
priority: Medium
depends_on: []
flags_skills: []
rules_applied: [GM-4, DA-7, DT-1]
documents_needed: [Assets/Design/GDD, Assets/Design/NDD]
tags: [unity, design-doc, gdd, ndd, mechanics, lore, authority]
```

**Key relationships:**
- Depends on: nothing — pre-implementation gate
- Flags: nothing — escalates to design owner directly
- Governed by: GM-4 (transparency), DA-7 (consistency), DT-1 (deviation logging)
