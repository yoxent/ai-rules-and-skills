# Skill Human Spec: UI Systems

```yaml
---
name: ui-systems
description: Enforces UGUI as primary UI system with TextMeshProUGUI, Raycast Target optimization, and UI Toolkit MVC separation
version: 1.0.0
category: Architecture
tags: [unity, ugui, textmeshpro, ui-toolkit, raycast, uss]
priority: Medium

depends_on: [code-standards]
flags_skills: []

inputs: [ui_canvas_hierarchy, ui_scripts, ui_toolkit_documents, text_components]
outputs: [ui_assessment, violations_list, corrected_patterns, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-7   # Architectural Consistency
  - PC-4   # Performance Budget

documents_needed: [project_ui_conventions, existing_ui_prefabs]

execution_context: Runs after code-standards on UI canvas hierarchies, UI scripts, and UI Toolkit documents
---
```

---

# Skill: UI Systems

---

## Purpose

**What this skill does:**
Enforces Unity UI conventions: UGUI (Canvas-based) as the default system, TextMeshProUGUI in place of legacy Text, Raycast Target disabled on non-interactive elements, MVC separation in UI Toolkit (Controller for business logic, View for UI-only logic), and USS for UI Toolkit theming. Ensures consistent, performant UI implementation across the project.

Mixed UI systems (some UGUI, some UI Toolkit, some legacy Text) create inconsistent player experience and maintenance confusion. Disabled Raycast Targets on static elements reduces overdraw and improves touch/pointer performance on mobile.

TextMeshProUGUI provides superior text rendering, Unicode support, and SDF-based scaling. Raycast Target on every element causes unnecessary hit-testing overhead on every pointer event. UI Toolkit MVC separation prevents UI logic from polluting game logic and vice versa.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new UI Canvas, Panel, or UI element is created
* A Text component (legacy) is found anywhere in UI prefabs or scenes
* UI Toolkit documents (UXML) are created or modified
* Business logic is found in a UI Toolkit View script
* Raycast Target is enabled on non-interactive UI elements
* A new UI system is being chosen (UGUI vs. UI Toolkit)

### Do NOT use this skill for:

* Non-UI game world scripts — use code-standards or architecture-patterns
* Addressable asset loading for UI sprites — use performance-optimization
* Copywriting and UI text content — use ui-copy

**Execution Context Details:**
Runs after code-standards on UI prefabs and UI scripts. Works alongside architecture-patterns when UI systems communicate with game systems via Event Channels.

---

## Inputs

**Required inputs:**

* **UI Canvas hierarchy** — The UGUI canvas and its child elements
* **UI scripts** — MonoBehaviour scripts controlling UI behaviour
* **Text components** — Any Text or TextMeshProUGUI components in the hierarchy

**Optional inputs:**

* **UI Toolkit documents** — UXML and USS files if UI Toolkit is in use
* **Project UI conventions** — Documented system choice and naming conventions

**Documents/Context needed:**

* **Existing UI prefabs** — To validate alignment with established UI patterns per DA-7
* **Project UI conventions** — Whether UGUI or UI Toolkit is the project standard

---

## Outputs

**Primary outputs:**

* **UI assessment** — Pass/Fail/Needs Review per UI convention category
* **Violations list** — Legacy Text, Raycast enabled on static, business logic in View
* **Corrected patterns** — Before/after for each violation
* **Approval status** — Whether UI implementation meets standards

**Output format:**

* Structured report with sections: System Choice, TextMeshPro, Raycast Optimization, UI Toolkit Separation, USS Styling
* Inline fix instructions for each violation

**Skill flags (if applicable):**

* No downstream flags — ui-systems is a standards gate

---

## Preconditions

**Conditions that must be met before execution:**

* code-standards has passed for any UI scripts
* At least one UI element (Canvas, Panel, or UXML) is under review
* Project UI convention is known or can be inferred from existing UI prefabs

**Validation checks:**

* [ ] TextMeshPro package is installed (com.unity.textmeshpro)
* [ ] Project UI convention is determinable (UGUI majority = UGUI project; UI Toolkit usage = UI Toolkit project)

---

## Step-by-Step Execution Procedure

### Step 1: Validate UI System Choice

**Questions to answer:**
- What UI system is this project using as primary: UGUI (Canvas) or UI Toolkit?
- Is the new UI being created consistent with the project's primary system?

**Actions:**
- [ ] Inspect existing UI prefabs/scenes to determine project standard
- [ ] Check if new UI is being added in the same system
- [ ] Flag if new UI introduces a second system without documented justification

**Red flags / Warning signs:**
- UI Toolkit document added to a primarily UGUI project without explicit decision
- New UGUI Canvas added to a UI Toolkit-primary project

**Decision points:**
- If system mismatch: warn, request documentation of the conscious choice
- Default is UGUI unless project has adopted UI Toolkit

---

### Step 2: Validate TextMeshPro Usage

**Questions to answer:**
- Does any UI element use the legacy `Text` component instead of `TextMeshProUGUI`?

**Actions:**
- [ ] Scan all UI prefabs and scene hierarchies for `UnityEngine.UI.Text` components
- [ ] Flag every instance — no exceptions for "simple" text
- [ ] Provide the `TextMeshProUGUI` replacement for each

**Red flags / Warning signs:**
- `Text` component on any element in a UI Canvas
- `text.text = "..."` assignment to a UnityEngine.UI.Text field in a script

**Decision points:**
- If legacy Text found: block, must be replaced with TextMeshProUGUI before merge

---

### Step 3: Validate Raycast Target Settings

**Questions to answer:**
- Is Raycast Target enabled on any non-interactive (decorative) UI elements?

**Actions:**
- [ ] Identify all non-interactive elements: background panels, decorative images, static labels
- [ ] Verify Raycast Target is unchecked on all non-interactive elements
- [ ] Verify Raycast Target is checked only on Buttons, Toggles, Sliders, and other interactive elements

**Red flags / Warning signs:**
- Background Image with Raycast Target enabled — blocks pointer events unnecessarily
- TextMeshProUGUI label with Raycast Target enabled — pure display, not interactive

**Decision points:**
- If Raycast Target enabled on decorative element: STYLE warn — performance impact on mobile
- If Raycast Target disabled on a Button: SAFETY warn — will break click detection

---

### Step 4: Validate UI Toolkit MVC Separation (if applicable)

**Questions to answer:**
- Is the UI Toolkit View class free of business logic?
- Does the Controller handle all game-state decisions?

**Actions:**
- [ ] Identify UI Toolkit View scripts (those that reference UIDocument or VisualElement)
- [ ] Scan View for game state access (ScriptableObject data reads, game manager calls)
- [ ] Verify Controller class handles business decisions and updates the View via method calls
- [ ] Flag any `if (player.health <= 0) ShowDeathScreen()` in a View class

**Red flags / Warning signs:**
- View class directly accessing `PlayerManager.Instance` or similar
- Business conditionals inside a UXML-bound View class

**Decision points:**
- If business logic in View: warn, describe Controller extraction pattern

---

### Step 5: Validate USS for UI Toolkit Styling

**Questions to answer:**
- Is all UI Toolkit styling applied via USS files rather than inline C# style assignments?

**Actions:**
- [ ] Scan UI Toolkit View scripts for `element.style.color = ...` or similar inline style assignments
- [ ] Verify theme and layout properties are in .uss files
- [ ] Verify USS is applied via `AddToClassList` or `styleSheets.Add(sheet)` — not inline

**Red flags / Warning signs:**
- `_button.style.backgroundColor = Color.red;` in C# — inline style
- No .uss file in the UI Toolkit document folder

**Decision points:**
- If inline style for theme/layout: warn, extract to USS
- Inline style for dynamic/runtime state (e.g., opacity animation) is acceptable

---

### Final Step: Generate UI Systems Report

```markdown
## UI Systems Report

**Target:** [Canvas or UIDocument under review]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### UI System Choice
[Finding — UGUI vs. UI Toolkit alignment]

### TextMeshPro
[Finding — legacy Text occurrences]

### Raycast Target Optimization
[Finding — non-interactive elements with Raycast enabled]

### UI Toolkit MVC Separation
[Finding — business logic in View, if applicable]

### USS Styling
[Finding — inline styles vs. USS, if applicable]

### Overall Assessment
- ✅ PASS: All UI conventions met
- ❌ FAIL: Legacy Text component found
- ⚠️ NEEDS REVIEW: Raycast optimization or MVC separation needed

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Default to UGUI as the primary UI system unless UI Toolkit is the documented project choice
2. Replace all legacy Text components with TextMeshProUGUI — no exceptions
3. Disable Raycast Target on all non-interactive UI elements for performance
4. Enforce MVC separation in UI Toolkit: Controller for business logic, View for UI-only logic
5. Enforce USS for UI Toolkit theme and layout styling

**Quality criteria:**

* Zero legacy Text components in any UI prefab or scene
* Raycast Target enabled only on interactive elements
* No business logic inside UI Toolkit View scripts

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: UI View classes have one responsibility — rendering state; Controllers have one responsibility — business decisions
  - In practice: A `HealthBarView` updates the bar fill; a `HealthBarController` decides when the bar should flash or hide

* **DA-7: Architectural Consistency**
  - Applies: All UI in the project uses the same system; no mixing legacy Text, TextMeshProUGUI, and UI Toolkit components without documented plan
  - In practice: If project is UGUI, all new canvases are UGUI

### Performance & Complexity Rules

* **PC-4: Performance Budget**
  - Applies: Raycast Target on every element increases pointer event processing cost; on mobile this matters
  - In practice: A HUD with 20 elements all Raycast-enabled costs more than 3 interactive + 17 disabled

---

## Tradeoff Handling

### Tradeoff 1: UGUI vs. UI Toolkit for New UI

**Scenario:** Team wants to use UI Toolkit for a new settings screen in a primarily UGUI project.

**Default stance:** Flag the system inconsistency. If team consciously adopts UI Toolkit going forward, require a documented decision. Mixed projects without a migration plan are discouraged.

**Resolution process:**
1. Surface inconsistency per DA-7
2. Request team decision: adopt UI Toolkit for all future UI, or use UGUI
3. Document via DT-1

---

### Tradeoff 2: Inline Style for Runtime State

**Scenario:** A View dynamically changes opacity on hover via `element.style.opacity = 0.5f`.

**Default stance:** Runtime state changes via inline style are acceptable. Only block inline styles used for theme/layout that belong in USS.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Widespread Legacy Text in Existing Project

**Trigger:** 50+ legacy Text components found across existing prefabs.

**Action:**
- Flag all as technical debt via MF-2
- Enforce TextMeshProUGUI on all new and modified prefabs
- Do not require retroactive migration in one sprint; create a migration plan

---

### Escalation Scenario 2: Business Logic Deeply Embedded in View

**Trigger:** UI Toolkit View class contains 200 lines of business logic mixed with UI binding.

**Action:**
- Warn — suggest extraction of business logic to Controller class
- If blocking a merge: request minimum extraction of the most egregious business decisions
- Log full refactoring as technical debt via MF-2

---

### When to halt execution:

* TextMeshPro package not installed — cannot require TextMeshProUGUI without the package
* No UI elements exist in the target yet — nothing to assess

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on UI prefabs and scripts. Works alongside architecture-patterns when UI elements communicate via Event Channels with game systems.

**Integration workflow:**
1. code-standards passes on UI scripts
2. Orchestrator invokes ui-systems on canvas hierarchy and UI scripts
3. Skill checks system choice, TMP, Raycast, MVC, USS
4. After pass: architecture-patterns may run if UI communicates with game systems

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — ui-systems is a standards gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — UI scripts must meet C# code standards before UI-specific assessment begins

**Skills this skill cooperates with:**

* **architecture-patterns** — UI communication with game systems via Event Channels; cooperates on cross-system UI event design
* **ui-copy** — UI copy skill provides text content; ui-systems validates the text components that render it

**Skills this skill may invoke/flag:**

* None — standards gate only

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block legacy Text component — never warn-only for this violation
* [ ] Apply DA-5 — do not require UI Toolkit MVC separation for single-element simple views
* [ ] Log system choice decisions via DT-1 when UGUI/UI Toolkit is formally adopted
* [ ] Log widespread legacy Text as technical debt via MF-2 with migration plan
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* UI system choice (UGUI vs. UI Toolkit) documented via DT-1
* Legacy Text migration plan logged as technical debt via MF-2

---

## Example Use Cases

### Example 1: Legacy Text in HUD Prefab

**Scenario:** `HUD.prefab` has 8 Text components for score, health, timer, and labels.

**Execution steps:**
1. Scan hierarchy — find 8 `UnityEngine.UI.Text` components
2. Block: all must be replaced with `TextMeshProUGUI`
3. Provide replacement steps: swap component, re-assign font asset, update script field references

**Result:** ❌ FAIL

---

### Example 2: Background Panel Raycast Target Enabled

**Scenario:** `MainMenu` panel background Image has Raycast Target enabled. No click handler exists on it.

**Execution steps:**
1. Identify Image component on background — non-interactive
2. Flag Raycast Target enabled — unnecessary hit-testing
3. Recommend: uncheck Raycast Target in Inspector

**Result:** ⚠️ NEEDS REVIEW — performance optimisation

---

### Example 3: Business Logic in UI Toolkit View

**Scenario:** `InventoryView.cs` contains `if (PlayerInventory.Instance.Gold >= item.Cost) { ... }` in a UI binding callback.

**Execution steps:**
1. Detect business logic (affordability check) in View class
2. Warn: extract to InventoryController
3. Controller checks affordability; View receives bool and updates UI

**Result:** ⚠️ NEEDS REVIEW — MVC extraction recommended

---

### Example 4: Fully Compliant UI HUD

**Scenario:** HUD prefab with TextMeshProUGUI on all labels, Raycast Target off on all decorative images, Raycast Target on on health bar slider and settings button.

**Result:** ✅ PASS

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `UnityEngine.UI.Text` component on any UI element
✅ **Correct approach:** `TextMeshProUGUI` from the TextMeshPro package

❌ **Anti-pattern 2:** Background Image with Raycast Target enabled (no interactive use)
✅ **Correct approach:** Raycast Target unchecked on all decorative/non-interactive elements

❌ **Anti-pattern 3:** Business logic (`if player.health <= 0`) inside a UI Toolkit View class
✅ **Correct approach:** Business logic in Controller; Controller calls `view.ShowDeathScreen()`

❌ **Anti-pattern 4:** `element.style.color = Color.red;` for theme styling in C#
✅ **Correct approach:** Define colour in USS class; apply via `element.AddToClassList("error-color")`

❌ **Anti-pattern 5:** Mixing UGUI and UI Toolkit in the same project without a migration plan
✅ **Correct approach:** Document the system choice; adopt one consistently going forward

❌ **Anti-pattern 6:** TextMeshProUGUI label with Raycast Target enabled (display-only)
✅ **Correct approach:** Uncheck Raycast Target on display-only TMP labels

❌ **Anti-pattern 7:** `_text.text = score.ToString()` from Update (allocates per frame)
✅ **Correct approach:** Use `_text.SetText(sb)` via StringBuilder in performance-optimization

❌ **Anti-pattern 8:** UI Toolkit View directly calling GameManager.Singleton methods
✅ **Correct approach:** View exposes callbacks; Controller wires GameManager → View update

---

## Non-Goals

* ❌ Does not validate UI text content — use ui-copy
* ❌ Does not validate per-frame text allocation — use performance-optimization
* ❌ Does not design game HUD layout — design concern
* ❌ Does not validate addressable sprite loading — use performance-optimization

---

## Notes for LLM Implementation

1. **Legacy Text is always a block** — no exceptions, regardless of how "simple" the text element is
2. **Raycast Target optimisation is mobile-critical** — enforce as STYLE warn; explain the performance impact
3. **MVC separation for UI Toolkit only applies when the View is non-trivial** — single-element views don't need a separate Controller
4. **Inline style for dynamic runtime state is acceptable** — only flag inline styles used for theme/layout
5. **Know the project's UI system choice before enforcing** — don't penalise UGUI on a UI Toolkit project

---

## Metadata Summary

```yaml
name: ui-systems
category: Architecture
priority: Medium
depends_on: [code-standards]
flags_skills: []
rules_applied: [DA-1, DA-7, PC-4]
documents_needed: [project_ui_conventions, existing_ui_prefabs]
tags: [unity, ugui, textmeshpro, ui-toolkit, raycast, uss]
```

**Key relationships:**
- Depends on: code-standards (C# standards baseline)
- Flags: none — standards gate
- Governed by: DA-1 (MVC separation), DA-7 (system consistency), PC-4 (Raycast performance budget)
