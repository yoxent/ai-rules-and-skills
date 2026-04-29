# Skill Human Spec: Input System

```yaml
---
name: input-system
description: Enforces Unity New Input System conventions for Action Maps, Generated C# class usage, lifecycle wiring, and runtime rebinding
version: 1.0.0
category: Architecture
tags: [unity, input, new-input-system, action-maps, playerinput, rebinding]
priority: Medium

depends_on: [code-standards]
flags_skills: []

inputs: [input_handling_scripts, action_map_assets, player_input_components]
outputs: [input_assessment, violations_list, corrected_patterns, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-7   # Architectural Consistency
  - MF-1   # Feature Consistency

documents_needed: [input_actions_asset, project_input_conventions]

execution_context: Runs after code-standards on any script handling player input; validates New Input System usage and lifecycle wiring
---
```

---

# Skill: Input System

---

## Purpose

**What this skill does:**
Enforces Unity New Input System conventions: using the Generated C# class from the Input Actions asset (not legacy `Input.GetKey`), structured Gameplay and UI Action Maps, event subscription in OnEnable/unsubscription in OnDisable, and `InputActionRebindingExtensions` for runtime rebinding. Ensures input handling is event-driven, rebindable, and lifecycle-safe.

Legacy Input.GetKey/GetAxis APIs are deprecated and cannot support rebinding, gamepad abstraction, or multi-device input. Enforcing the New Input System ensures the game is ready for platform certification (controller support) and player quality-of-life features (rebinding).

Event-driven input prevents polling overhead in Update, ensures input is correctly paired with its consuming lifecycle, and enables rebinding without code changes. Generated C# class usage provides compile-time safety over string-based API access.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Any script handles player input (movement, jump, fire, UI navigation)
* A new Input Actions asset is created or modified
* `Input.GetKey`, `Input.GetAxis`, or `Input.GetButton` is found anywhere in the codebase
* A PlayerInput component is added to a GameObject
* Runtime key rebinding is being implemented
* Code review finds input subscription missing from lifecycle methods

### Do NOT use this skill for:

* Non-player input (AI decisions, procedural triggers) — use architecture-patterns
* Editor tooling input (editor shortcuts) — separate Unity Editor API
* Input for in-editor only scripts

**Execution Context Details:**
Runs after code-standards on any input-handling scripts. Validates the input implementation layer — not the game logic that responds to input.

---

## Inputs

**Required inputs:**

* **Input handling scripts** — Any MonoBehaviour that subscribes to input actions or uses Input APIs
* **Action map assets** — The .inputactions asset file defining Action Maps and bindings

**Optional inputs:**

* **PlayerInput component configuration** — If PlayerInput component is used instead of direct Generated C# class
* **Project input conventions** — Documented action naming conventions

**Documents/Context needed:**

* **Input Actions asset** — The .inputactions file for the project; defines what actions exist and their bindings

---

## Outputs

**Primary outputs:**

* **Input assessment** — Pass/Fail/Needs Review per input convention category
* **Violations list** — Legacy API usage, missing unsubscription, missing rebinding support
* **Corrected patterns** — Before/after showing the correct input wiring
* **Approval status** — Whether input handling meets New Input System standards

**Output format:**

* Structured report with sections: API Usage, Action Map Structure, Lifecycle Wiring, Rebinding
* Code blocks for all corrections

**Skill flags (if applicable):**

* No downstream flags — input-system is a standards gate

---

## Preconditions

**Conditions that must be met before execution:**

* Unity Input System package is installed (com.unity.inputsystem in manifest)
* code-standards has passed for the script
* An Input Actions asset exists in the project

**Validation checks:**

* [ ] Unity Input System package present in manifest
* [ ] .inputactions asset exists and has been generated into a C# class
* [ ] Generated C# class exists alongside the .inputactions asset

---

## Step-by-Step Execution Procedure

### Step 1: Check for Legacy Input API Usage

**Questions to answer:**
- Does any script use `Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, or `Input.GetMouseButton`?

**Actions:**
- [ ] Search for `Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.GetMouseButton` across the script
- [ ] Flag all occurrences — these are deprecated in New Input System projects
- [ ] Identify the closest Generated C# action equivalent

**Red flags / Warning signs:**
- `if (Input.GetKeyDown(KeyCode.Space))` — legacy polling
- `Input.GetAxis("Horizontal")` — legacy axis polling

**Decision points:**
- If legacy API found: block, provide Generated C# class equivalent with event subscription

---

### Step 2: Validate Generated C# Class Usage

**Questions to answer:**
- Is input accessed via the Generated C# class (e.g., `PlayerInputActions`)?
- Is the Generated C# class instantiated in Awake?

**Actions:**
- [ ] Verify a `PlayerInputActions _inputActions` field is declared and instantiated in Awake
- [ ] Verify actions are accessed via generated property path (e.g., `_inputActions.Gameplay.Jump`)
- [ ] Flag string-based action access (e.g., `GetAction("Jump")`) where Generated class is available

**Red flags / Warning signs:**
- `_inputActions.FindAction("Jump")` — string-based, not compile-safe
- Generated class not instantiated — raw asset reference used instead

**Decision points:**
- If string-based access: warn, provide Generated class path equivalent
- If class not instantiated: block, show Awake instantiation pattern

---

### Step 3: Validate Action Map Structure

**Questions to answer:**
- Does the Input Actions asset have a Gameplay map (Move Vector2, Jump Button, Fire Button) and a UI map (Navigate, Submit, Cancel)?

**Actions:**
- [ ] Confirm Gameplay action map exists with at minimum: Move (Vector2), Jump (Button), Fire (Button)
- [ ] Confirm UI action map exists with: Navigate, Submit, Cancel
- [ ] Flag action maps with non-standard action names that differ from the project convention

**Red flags / Warning signs:**
- No separate UI action map — UI navigation hardcoded instead
- Move action defined as two separate Float actions instead of a Vector2

**Decision points:**
- If missing UI map: warn — required for proper UI navigation via input
- If Move not Vector2: warn, explain composite binding approach

---

### Step 4: Validate Lifecycle Wiring (Subscribe/Enable/Disable)

**Questions to answer:**
- Are action callbacks subscribed in OnEnable and unsubscribed in OnDisable?
- Are action maps explicitly enabled/disabled in the lifecycle?

**Actions:**
- [ ] Verify `_inputActions.Gameplay.Jump.performed += OnJump` in OnEnable
- [ ] Verify `_inputActions.Gameplay.Jump.performed -= OnJump` in OnDisable
- [ ] Verify `_inputActions.Gameplay.Enable()` called in OnEnable
- [ ] Verify `_inputActions.Gameplay.Disable()` called in OnDisable or OnDestroy

**Red flags / Warning signs:**
- Subscription in Awake with no unsubscription — event leak
- Action map enabled but never disabled — input active even when GameObject disabled

**Decision points:**
- If Subscribe without matching Unsubscribe: SAFETY block — event leak
- If Enable without Disable: SAFETY warn

---

### Step 5: Validate Runtime Rebinding Support

**Questions to answer:**
- Does the project require runtime rebinding? If yes, is `InputActionRebindingExtensions` used?

**Actions:**
- [ ] Determine if the project supports player rebinding (check GDD or project requirements)
- [ ] If yes: verify `InputActionRebindingExtensions.RebindingOperation` is used for interactive rebinding
- [ ] Verify rebinding operation is disposed after completion
- [ ] Flag hardcoded key references that cannot be rebound

**Red flags / Warning signs:**
- Rebinding implemented by swapping keybindings manually without RebindingExtensions
- RebindingOperation not disposed after completion (memory leak)

**Decision points:**
- If rebinding required but not implemented: warn, provide RebindingOperation pattern
- If RebindingOperation not disposed: warn

---

### Final Step: Generate Input System Report

```markdown
## Input System Report

**Target:** [ClassName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Legacy API Usage
[Finding — any Input.GetKey/GetAxis occurrences]

### Generated C# Class
[Finding — instantiation and access pattern]

### Action Map Structure
[Finding — Gameplay and UI maps]

### Lifecycle Wiring
[Finding — Subscribe/Enable in OnEnable; Unsubscribe/Disable in OnDisable]

### Runtime Rebinding
[Finding — RebindingExtensions usage if required]

### Overall Assessment
- ✅ PASS: All New Input System conventions met
- ❌ FAIL: Legacy API or event subscription leak
- ⚠️ NEEDS REVIEW: Rebinding not implemented or action map incomplete

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Block all legacy `Input.GetKey/GetAxis/GetButton` usage — migrate to Generated C# class
2. Require Generated C# class instantiated in Awake and accessed via typed properties
3. Validate Gameplay and UI action map structure meets project minimum
4. Enforce Subscribe/Unsubscribe in OnEnable/OnDisable and Enable/Disable action maps in lifecycle
5. Validate `InputActionRebindingExtensions` used for rebinding where required

**Quality criteria:**

* Zero legacy Input API calls in any script
* Every action subscription has a matching unsubscription in OnDisable
* Every action map Enable has a matching Disable

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: Input handling should be in a dedicated input component, not mixed with gameplay logic
  - In practice: A `PlayerInputHandler` component subscribes to events and raises them via Event Channel; `PlayerController` subscribes to the channel — not directly to input actions

* **DA-7: Architectural Consistency**
  - Applies: All input in the project must use the same API (New Input System); mixing legacy and new is not acceptable
  - In practice: If Jump uses the Generated C# class, Move must too

### Maintenance & Feature Consistency Rules

* **MF-1: Feature Consistency**
  - Applies: New input actions must follow the same naming and map structure as existing actions
  - In practice: A new Dodge action belongs in the Gameplay map, not a standalone map

---

## Tradeoff Handling

### Tradeoff 1: Generated Class vs. PlayerInput Component

**Scenario:** Developer uses PlayerInput component with Unity Events in inspector instead of Generated C# class.

**Default stance:** Both are valid New Input System patterns. Generated C# class is preferred for compile-time safety; PlayerInput component is acceptable for simpler cases. Document the project choice.

**Resolution process:**
1. Confirm project convention for one pattern
2. Enforce consistently — no mixing of approaches in the same project
3. Log convention choice via DT-1 if not already documented

---

### Tradeoff 2: Input Polling vs. Event-Based for Simple Cases

**Scenario:** A simple prototype checks input once in Update for rapid prototyping.

**Default stance:** Allow during prototype phase. Log as provisional. Require migration to event-based before production merge.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Legacy Input Entrenched in Existing Codebase

**Trigger:** Project has 20+ scripts using `Input.GetKey` — full migration is a large effort.

**Action:**
- Flag all violations as technical debt via MF-2
- Enforce new scripts use New Input System
- Do not require retroactive migration in a single PR — create a migration plan

---

### Escalation Scenario 2: Event Subscription Leak

**Trigger:** Subscribe in OnEnable, no Unsubscribe in OnDisable.

**Action:**
- SAFETY block
- Provide matching Unsubscribe and Disable calls

---

### When to halt execution:

* Unity Input System package not installed — New Input System cannot be used; flag as missing dependency
* No .inputactions asset exists in the project — cannot assess Generated class usage

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on input-handling scripts. Works alongside architecture-patterns (Event Channel from input handler to game systems).

**Integration workflow:**
1. code-standards passes
2. Orchestrator invokes input-system on input scripts
3. Skill validates API usage, action maps, lifecycle wiring, rebinding
4. After pass: architecture-patterns assesses how input events are propagated to game systems

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — input-system is a standards gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Lifecycle ordering (OnEnable/OnDisable) must be correct for input subscription patterns to be assessed

**Skills this skill cooperates with:**

* **architecture-patterns** — Input events raised from the input handler are typically propagated via Event Channels; cooperates on cross-system input propagation design

**Skills this skill may invoke/flag:**

* None — standards gate only

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block all legacy Input API usage — never accept with warning only
* [ ] Block event subscription without matching unsubscription — SAFETY violation
* [ ] Apply DA-5 for prototypes — allow provisional patterns with logged note
* [ ] Document project input convention (Generated class vs. PlayerInput) via DT-1 if not already documented
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Legacy input migration plan logged as technical debt via MF-2
* Project input convention (class vs. component) documented via DT-1

---

## Example Use Cases

### Example 1: Legacy Input in Jump Handler

**Scenario:** `PlayerJump.Update()` contains `if (Input.GetKeyDown(KeyCode.Space)) { Jump(); }`

**Execution steps:**
1. Detect `Input.GetKeyDown` — legacy API
2. Block: provide Generated class equivalent
3. Show: `_inputActions.Gameplay.Jump.performed += _ => Jump();` in OnEnable

**Result:** ❌ FAIL

---

### Example 2: Subscribe Without Unsubscribe

**Scenario:** `OnEnable` has `_inputActions.Gameplay.Jump.performed += OnJump;` but `OnDisable` is empty.

**Execution steps:**
1. Detect Subscribe without matching Unsubscribe
2. SAFETY block — event leak
3. Provide OnDisable with `_inputActions.Gameplay.Jump.performed -= OnJump;` and `_inputActions.Gameplay.Disable();`

**Result:** ❌ FAIL

---

### Example 3: Fully Compliant Input Handler

**Scenario:** `PlayerInputHandler.cs` instantiates Generated class in Awake, subscribes in OnEnable, unsubscribes and disables in OnDisable, raises Event Channels instead of calling game logic directly.

**Result:** ✅ PASS

---

### Example 4: Missing UI Action Map

**Scenario:** Input Actions asset has only a Gameplay map; no UI map defined.

**Execution steps:**
1. Check action maps — UI map absent
2. Warn: UI navigation via Input System requires UI map
3. Provide UI map structure: Navigate (Vector2), Submit (Button), Cancel (Button)

**Result:** ⚠️ NEEDS REVIEW

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `Input.GetKeyDown(KeyCode.Space)` in Update
✅ **Correct approach:** `_inputActions.Gameplay.Jump.performed += OnJump` in OnEnable

❌ **Anti-pattern 2:** `Input.GetAxis("Horizontal")` for movement
✅ **Correct approach:** `_inputActions.Gameplay.Move.ReadValue<Vector2>()`

❌ **Anti-pattern 3:** Subscribe in OnEnable with no Unsubscribe in OnDisable
✅ **Correct approach:** Matching Unsubscribe and Disable calls in every OnDisable

❌ **Anti-pattern 4:** `_inputActions.FindAction("Jump")` — string-based access
✅ **Correct approach:** `_inputActions.Gameplay.Jump` — Generated class typed property

❌ **Anti-pattern 5:** Action map enabled in Awake but never disabled
✅ **Correct approach:** Enable in OnEnable, Disable in OnDisable

❌ **Anti-pattern 6:** Rebinding implemented by manually swapping KeyCode values
✅ **Correct approach:** `InputActionRebindingExtensions.RebindingOperation` with interactive binding UI

❌ **Anti-pattern 7:** Input polling in Update when event-based subscription is available
✅ **Correct approach:** Subscribe to `performed`, `started`, `canceled` callbacks

❌ **Anti-pattern 8:** PlayerInputActions instantiated as static field (singleton pattern)
✅ **Correct approach:** Instance per-actor; instantiate in Awake on the owning MonoBehaviour

---

## Non-Goals

* ❌ Does not design how input events propagate to game systems — use architecture-patterns (Event Channels)
* ❌ Does not validate game logic that responds to input — use code-standards
* ❌ Does not configure Input Actions asset bindings — authoring concern
* ❌ Does not validate Editor input (editor shortcuts, editor tools)

---

## Notes for LLM Implementation

1. **Always show the Generated C# class pattern** — not just "use New Input System"; show the actual class name and path
2. **Event subscription leak is SAFETY** — block, never warn-only
3. **Distinguish the two valid patterns** (Generated class vs. PlayerInput component) — enforce the one the project uses consistently
4. **Apply DA-5 for prototypes** — provisional patterns are acceptable with a logged note; do not block prototype velocity

---

## Metadata Summary

```yaml
name: input-system
category: Architecture
priority: Medium
depends_on: [code-standards]
flags_skills: []
rules_applied: [DA-1, DA-7, MF-1]
documents_needed: [input_actions_asset, project_input_conventions]
tags: [unity, input, new-input-system, action-maps, playerinput, rebinding]
```

**Key relationships:**
- Depends on: code-standards (lifecycle baseline for OnEnable/OnDisable)
- Flags: none — standards gate
- Governed by: DA-1 (clean code), DA-7 (consistency), MF-1 (feature consistency)
