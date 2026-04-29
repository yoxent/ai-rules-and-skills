# Skill Human Spec
# File: scene-component-builder-docs.md
# Purpose: Human-readable comprehensive documentation
# NEVER loaded into agent context — for human review, authoring, and maintenance only

---

```yaml
---
name: scene-component-builder
description: Creates and modifies Unity scenes, hierarchies, and component wiring without gameplay logic.
version: 1.0.0
category: Content Generation
tags: [unity, scene, hierarchy, components, ugui, tmp, serialized-references]
priority: High

depends_on: [folder-structure, design-reference]
flags_skills: [prefab-scene-spec, architecture-patterns]

inputs: [scene-requirements, feature-path, component-list, reference-wiring-spec]
outputs: [scene-file-manifest, gameobjects-added, serialized-wiring-report, notes]

rules_applied:
  - PS-1   # Requirement Validation — validate scene spec against project structure before creating
  - PS-3   # Scope Control — do not touch unrelated scenes or restructure beyond instruction
  - DA-4   # Change Boundary — confine edits to the specified scene/feature scope only
  - DA-5   # Avoid Overengineering — keep scenes minimal; add only required components
  - DT-1   # Tradeoff Logging — document assumptions about hierarchy or wiring when spec is ambiguous

documents_needed: [design-reference, folder-structure-guide, prefab-scene-spec]

execution_context: Stage 4 / Content generation. Runs after architecture and prefab specs are defined. Produces or modifies .unity scene files aligned to feature paths.
---
```

---

# Skill: Scene Component Builder

---

## Purpose

**What this skill does:**
Creates or modifies Unity `.unity` scene files, including GameObject hierarchies, required component attachment, and serialized field wiring. It operates strictly within the content-generation mandate: structuring and wiring, never implementing gameplay or system logic.

Accelerates scene authoring for new features, onboarding flows, UI screens, and bootstrapped environments. Consistent, convention-aligned scenes reduce integration friction between designers and engineers.

Produces scenes that conform to the project's folder structure, UGUI + TextMeshPro conventions, and serialization standards, reducing manual wiring errors and component mismatches during review.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new Unity scene must be created for a feature, level, or UI screen
* An existing scene needs new GameObjects added or hierarchy restructuring per an explicit spec
* Components must be added to GameObjects and serialized references must be wired
* A bootstrap or initialization scene needs to be assembled from existing prefabs and components
* A UI canvas structure (UGUI + TMP) needs to be scaffolded under a given feature path
* An existing scene has missing component references that need to be resolved without logic changes
* A scene needs to be aligned to the project's folder structure after a reorganization

### Do NOT use this skill for:

* Implementing or modifying gameplay logic, state machines, or system behaviors — use `architecture-patterns` or domain-specific engineering skills
* Generating or refactoring C# scripts beyond minimal, trivially wired MonoBehaviours — use code-oriented skills
* Destructive restructuring of scenes not mentioned in the task spec — scope is strictly additive or as explicitly instructed
* Designing the feature's data flow or interaction patterns — use `design-reference` first

**Execution Context Details:**
This skill runs after `prefab-scene-spec` has defined the structural intent. It materializes the spec as actual scene file changes. It may flag `prefab-scene-spec` if the specification is incomplete or flag `architecture-patterns` if system-level wiring decisions are required.

---

## Inputs

**Required inputs:**

* **Scene requirements / task description** — What scene to create or modify, which feature path it belongs to, and the intent of the scene (e.g., "Main Menu UI scene," "Bootstrap scene for game initialization").
* **Feature path** — The directory in the Unity project Assets folder where the scene must reside, per the project's folder structure conventions.
* **Component list** — The GameObjects to add and the components each requires (e.g., `Canvas`, `CanvasScaler`, `EventSystem`, `TMP_Text`, `Button`).

**Optional inputs:**

* **Reference wiring spec** — Specific serialized field assignments (e.g., "Assign `UIManager` script's `titleText` field to the `TitleLabel` TMP_Text object").
* **Existing scene file reference** — If modifying an existing scene, a description or path of its current state.
* **Naming conventions guide** — If the project uses non-default naming for GameObjects or Canvas layers.

**Documents/Context needed:**

* **design-reference** — Required to validate that the scene layout intent aligns with design decisions already made.
* **folder-structure-guide** — Required to confirm the correct feature path before creating files.
* **prefab-scene-spec** — If available, the upstream spec that defined the scene's intended structure.

---

## Outputs

**Primary outputs:**

* **Scene file manifest** — A list of `.unity` scene file paths created or modified, with a description of each.
* **GameObjects added report** — Each GameObject added, with its parent path in the hierarchy and attached components.
* **Serialized wiring report** — Fields that were wired and the targets assigned (or flagged as unresolvable if reference targets don't exist).
* **Notes** — Assumptions made, deferred items, or flags for follow-up.

**Output format:**

```json
{
  "scenes_created": [{"scene_path": "", "description": ""}],
  "scenes_modified": [{"scene_path": "", "changes": []}],
  "gameobjects_added": [{"scene_path": "", "name": "", "components": []}],
  "notes": ""
}
```

**Skill flags (if applicable):**

* Flag **prefab-scene-spec** when the incoming task lacks a clear structural specification and a spec must be authored before scene building can proceed.
* Flag **architecture-patterns** when a component wiring request implies system-level dependencies (e.g., service locator, DI container wiring) outside this skill's mandate.

---

## Preconditions

**Conditions that must be met before execution:**

* The target feature path is known and exists (or is explicitly authorized to be created) within the project's Assets folder structure
* The list of GameObjects and required components is determinable from the task description
* No gameplay logic implementation is required to complete the wiring

**Validation checks:**

* [ ] Is the feature path aligned with the project's folder structure convention?
* [ ] Can each component be identified as a Unity built-in or a named project script?
* [ ] Are all serialized reference targets identifiable within the scene or project?
* [ ] Is the task free of gameplay/system logic implementation requirements?

---

## Step-by-Step Execution Procedure

### Step 1: Validate Scope and Feature Path

**Questions to answer:**
- What is the exact scene file path and name, per the folder structure convention?
- Is this a new scene or a modification to an existing one?
- Are there any scenes adjacent to this one that must not be touched?

**Actions:**
- [ ] Confirm the feature path against the folder-structure-guide
- [ ] Identify the scene file name following project naming conventions (e.g., `MainMenu.unity`, `GameBootstrap.unity`)
- [ ] Confirm that no other scenes in the same directory are in scope for this task
- [ ] If path is ambiguous, request clarification before proceeding (PS-1)

**Red flags / Warning signs:**
- Task references a vague path like "the main scene" without a concrete path — always resolve to an absolute Assets-relative path
- Task implies touching multiple scenes without explicit instruction for each

**Decision points:**
- If the feature path does not exist and the project structure doc does not authorize creating it, flag PS-3 scope concern and request confirmation before creating new directories

---

### Step 2: Define GameObject Hierarchy

**Questions to answer:**
- What is the root GameObject for this feature's hierarchy within the scene?
- What are the parent-child relationships between GameObjects?
- Are any GameObjects shared/reused prefabs or new standalone objects?

**Actions:**
- [ ] Sketch the hierarchy as a tree (can be in markdown bullet notation)
- [ ] Label each node with its intended purpose and component set
- [ ] Distinguish between prefab instances (reference to existing asset) and new GameObjects

**Red flags / Warning signs:**
- A deep hierarchy (more than 5 levels) with no design justification — flag as potential overengineering (DA-5)
- Request to create GameObjects whose names suggest gameplay logic (e.g., `PlayerStateController`) — redirect to code skill

**Decision points:**
- If hierarchy is not specified and task is ambiguous, use UGUI conventions as default (Canvas > Panel > [content children]) and log assumption per DT-1

---

### Step 3: Attach Components

**Questions to answer:**
- Which Unity built-in components are required on each GameObject?
- Which project-specific MonoBehaviour scripts are required?
- Are there component dependencies to satisfy (e.g., `Button` requires `Image`)?

**Actions:**
- [ ] For each GameObject, list required components in dependency order
- [ ] Validate that all named scripts exist in the project (or flag as unresolved if not)
- [ ] Apply UGUI + TMP conventions: prefer `TMP_Text` over legacy `Text`; include `CanvasScaler` on root Canvas

**Red flags / Warning signs:**
- Request to attach a script that implements complex logic in-scene — note that script attachment is valid; script authoring is out of scope
- Missing `EventSystem` for UI scenes — always add when a Canvas is the root
- Legacy `Text` component referenced — replace with `TMP_Text` per project convention

**Decision points:**
- If a named script does not exist in the project, log as unresolved reference in `notes` and proceed with component slot marked for manual assignment

---

### Step 4: Wire Serialized References

**Questions to answer:**
- Which serialized fields on each script need to be assigned?
- Are the target objects available in the same scene?
- Are any targets in a different scene or loaded dynamically (out of scope for scene-time wiring)?

**Actions:**
- [ ] For each script with serialized fields, list fields and their assigned target by GameObject path
- [ ] Confirm targets exist in the scene hierarchy as defined in Step 2
- [ ] Mark cross-scene or dynamic assignments as out-of-scope and log them in `notes`

**Red flags / Warning signs:**
- Wiring request references an object in a different scene — this is a runtime dependency, not a scene-wiring task
- Circular reference patterns (A wires to B, B wires to A) — log and flag for architecture review

**Decision points:**
- If a wiring target cannot be resolved from the scene hierarchy, leave field unassigned and document in `notes` for follow-up

---

### Step 5: Validate Against Conventions

**Questions to answer:**
- Does the scene conform to UGUI + TMP conventions?
- Does the hierarchy follow the project's naming convention?
- Are there any redundant, duplicate, or unnecessary GameObjects?

**Actions:**
- [ ] Verify `TMP_Text` used in place of legacy `Text` everywhere
- [ ] Verify `Canvas` has `CanvasScaler` and `GraphicRaycaster`
- [ ] Verify naming follows PascalCase convention for GameObjects
- [ ] Remove or flag any duplicate components or empty GameObjects with no purpose

**Red flags / Warning signs:**
- Canvas missing `CanvasScaler` — always required for responsive UI
- GameObjects named generically (`GameObject`, `Empty`) — rename to reflect purpose

**Decision points:**
- If a convention violation is found in an existing scene being modified, note it in `notes` but do not fix unrelated conventions without explicit instruction (PS-3, DA-4)

---

### Final Step: Generate Scene Build Report

**Report/Output structure:**

```markdown
## Scene Component Builder Report

**Task:** [Scene name / feature]
**Date:** [YYYY-MM-DD]
**Status:** COMPLETE / PARTIAL / BLOCKED

### Scenes Created
| Path | Description |
|------|-------------|
| Assets/Features/... | ... |

### Scenes Modified
| Path | Changes |
|------|---------|
| Assets/Features/... | Added Canvas hierarchy for MainMenu |

### GameObjects Added
| Scene | GameObject | Parent | Components |
|-------|------------|--------|------------|
| MainMenu.unity | MainCanvas | (root) | Canvas, CanvasScaler, GraphicRaycaster |

### Serialized Wiring
| GameObject | Script | Field | Assigned To |
|------------|--------|-------|-------------|
| UIManager | UIManager.cs | titleText | MainCanvas/Header/TitleLabel |

### Unresolved References
- [Field or object that could not be wired, with reason]

### Assumptions Logged (DT-1)
- [What was assumed; what changes if assumption is wrong]

### Skills Flagged
- prefab-scene-spec: [Reason]
- architecture-patterns: [Reason]
```

---

## Core Responsibilities

1. Create or modify `.unity` scene files at the correct feature path within the project's Assets folder
2. Add and organize GameObjects with clear hierarchy structure using UGUI and TMP conventions
3. Attach required Unity built-in and project-specific components in dependency order
4. Wire serialized references between scripts and scene objects when both endpoints are in scope
5. Keep scenes minimal — no unnecessary GameObjects, components, or structural complexity (DA-5)
6. Log all assumptions about hierarchy, naming, or wiring when the spec is ambiguous (DT-1)
7. Confine all changes to the explicitly specified scene(s) — no side effects on adjacent scenes (DA-4, PS-3)

**Quality criteria:**

* Every created GameObject has a clear, purpose-reflecting name
* All UGUI Canvases include `CanvasScaler` and `GraphicRaycaster`; all UI scenes include `EventSystem`
* `TMP_Text` is used in all text display contexts; no legacy `Text` components
* All serialized references are either resolved and documented, or explicitly logged as unresolved
* No gameplay logic is introduced through component wiring

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-1: Requirement Validation**
  - How this rule applies: The target feature path and scene name must be validated against the project structure before any file creation begins.
  - In practice: Always confirm the Assets path with `folder-structure-guide` before creating a scene. If the path is unrecognized, surface this before proceeding.

* **PS-3: Scope Control**
  - How this rule applies: Only the explicitly mentioned scene(s) are in scope. Adjacent scenes, shared prefabs, or project-wide settings must not be modified as a side effect.
  - In practice: If a fix to an adjacent scene would "be nice," log it in `notes` as a follow-up — do not execute it.

### Design & Architecture Rules

* **DA-4: Change Boundary**
  - How this rule applies: All modifications are confined to the stated scene(s) and the declared hierarchy additions. Do not restructure existing hierarchies beyond what was asked.
  - In practice: When modifying an existing scene, add or wire only; do not reorganize or delete existing GameObjects unless explicitly instructed.

* **DA-5: Avoid Overengineering**
  - How this rule applies: Scenes should be minimal. Add only the components and GameObjects required by the task — no speculative scaffolding.
  - In practice: If tempted to add a "manager" object that wasn't asked for, don't. Log the suggestion in `notes` only.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How this rule applies: Any assumption about hierarchy structure, naming, or wiring (when not explicitly specified) must be logged.
  - In practice: Document every assumption in the Assumptions section of the output report.

---

## Tradeoff Handling

### Tradeoff 1: Minimal vs Anticipatory Scaffolding

```
CONFLICT: A minimal scene is correct per DA-5, but the engineer knows future features will need more objects.
DEFAULT: Build only what is asked for. Anticipatory scaffolding introduces undocumented structure.
RESOLUTION:
  IF explicit_future_requirement_stated → include with note explaining the addition
  IF assumed_future_need → log suggestion in notes; do not add to scene
→ Log decision via: DT-1
→ Example: "Feature will need a loading panel later" → add only if in the task spec; otherwise note it.
```

### Tradeoff 2: Prefab Instances vs New GameObjects

```
CONFLICT: A required component pattern exists as a shared prefab, but the task didn't mention using it.
DEFAULT: Prefer prefab instances if a canonical prefab is documented in design-reference.
RESOLUTION:
  IF prefab_documented_in_design_reference → use prefab instance; log decision
  IF no_prefab_reference → create new GameObject; log assumption that no prefab is available
→ Log decision via: DT-1
→ Example: "Standard Dialog prefab exists" → use it; don't recreate the hierarchy manually.
```

### Tradeoff 3: Legacy vs TMP Text Components

```
CONFLICT: Existing scene uses legacy Text; task adds new text elements.
DEFAULT: New elements always use TMP_Text. Do not modify existing legacy Text without explicit instruction.
RESOLUTION:
  IF adding new text → use TMP_Text unconditionally
  IF existing legacy text in scene → note in output but do not convert (DA-4 scope boundary)
→ Example: "Old menu uses legacy Text, new tooltip added" → tooltip uses TMP_Text; legacy left as-is.
```

### Tradeoff 4: Strict Spec vs Missing Wiring Detail

```
CONFLICT: Wiring is required but the exact field names or target paths aren't specified.
DEFAULT: Attempt inference from naming conventions and document the inference; do not block execution.
RESOLUTION:
  IF field_name_inferable_from_type_and_convention → wire and log assumption per DT-1
  IF target_ambiguous_or_nonexistent → mark as unresolved; do not guess; log in notes
→ Example: "UIManager.titleText" with no assigned target → mark as unresolved if no TitleLabel exists.
```

---

## Failure & Escalation Behavior

### Scenario 1: Feature Path Does Not Exist

**Trigger:** The stated feature path is not present in the project's Assets folder and the folder-structure-guide does not authorize its creation.

**Action:**
- Surface the missing path to the user with the expected path per convention
- Request confirmation to create the path before proceeding
- Do not create the scene or path without confirmation

**Escalation:** Block execution at Step 1; wait for explicit path confirmation.

---

### Scenario 2: Spec Lacks Hierarchy Detail

**Trigger:** The task description specifies a scene but does not provide a component list or hierarchy structure.

**Action:**
- Flag `prefab-scene-spec` for a specification to be authored first
- If urgency requires proceeding, apply UGUI defaults and log all assumptions per DT-1
- Surface the assumed structure for confirmation before finalizing

**Escalation:** Soft block — proceed with assumptions only if the user requests continuation without waiting for spec.

---

### Scenario 3: Wiring Target Missing from Scene

**Trigger:** A serialized reference wiring request names a GameObject that is not present in the defined hierarchy.

**Action:**
- Log the unresolved reference in the output `notes` section
- Do not guess a substitute target
- Proceed with all other wiring; mark the field as manually-assignable

**Escalation:** No hard block; output clearly marks the gap.

---

### Scenario 4: Gameplay Logic Embedded in Wiring Request

**Trigger:** A wiring request implies implementing script logic (e.g., "make the button call SaveGame()") rather than just wiring a reference.

**Action:**
- Note that script authoring is outside this skill's scope
- Log the requirement for follow-up with a code-oriented skill
- Wire the component reference only (e.g., assign the script component); do not write logic

**Escalation:** Log in `notes`; do not block other scene work.

---

### When to halt execution:

* The feature path is completely unknown and no folder-structure-guide is available — cannot create in correct location
* Every required component is an undefined script with no project reference — cannot produce a meaningful scene
* The task explicitly requires gameplay logic to be implemented before the scene is useful

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
This is a content-generation execution skill. It materializes the scene structure defined by `prefab-scene-spec` into actual Unity scene descriptions. It runs after structural and design decisions are made and before QA validation or playtesting.

### How This Skill Integrates

1. **prefab-scene-spec** (upstream) produces the structural specification
2. **scene-component-builder** (this skill) executes the spec as scene file creation/modification
3. **playtest-diagnostics** (downstream) may identify issues in scenes built by this skill
4. **qa-test-generation** (downstream) may generate test scenarios for the resulting scene

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Scene spec is absent or incomplete | prefab-scene-spec | A proper scene spec is required before building |
| Wiring implies system-level DI or service locator patterns | architecture-patterns | System wiring decisions exceed scene-builder scope |
| Scene requires a new feature folder path not in structure guide | folder-structure | Folder creation must be validated against structure conventions |

---

## Related Skills

**Skills this skill depends on:**
- **folder-structure** — must be consulted to confirm valid feature paths before scene creation
- **design-reference** — provides the design intent that governs hierarchy and component choices

**Skills this skill cooperates with:**
- **prefab-scene-spec** — the spec-authoring counterpart; typically runs before this skill
- **procedural-content** — may generate content that gets placed into scenes built by this skill

**Skills this skill may invoke/flag:**
- **prefab-scene-spec** — flagged when the incoming task lacks a scene specification
- **architecture-patterns** — flagged when wiring implies system-level decisions

---

## Governance Hooks

* [ ] Validate feature path against folder-structure-guide before creating any file (PS-1)
* [ ] Confine all edits to specified scene(s); do not touch adjacent scenes (PS-3, DA-4)
* [ ] Use UGUI + TMP conventions unconditionally for all new UI elements (DA-5)
* [ ] Log all assumptions about hierarchy, naming, and wiring (DT-1)
* [ ] Flag gameplay logic requests without executing them; redirect to appropriate skill

**Audit trail requirements:**

* Every created or modified scene is listed with its path and description
* Every unresolved wiring reference is documented with the reason it could not be resolved
* All assumptions documented with: what was assumed, alternative if assumption is wrong

---

## Example Use Cases

### Example 1: New Main Menu Scene

**Scenario:** Create a Main Menu scene with a title label, Play button, and Settings button.

**Inputs provided:**
- Feature path: `Assets/Features/MainMenu/`
- Components: Canvas, TMP_Text (title), two Buttons with TMP_Text labels
- UIManager script to be wired to titleText and playButton fields

**Execution steps:**
1. Validate path: `Assets/Features/MainMenu/MainMenu.unity` per folder-structure-guide ✅
2. Define hierarchy: `MainCanvas (Canvas, CanvasScaler, GraphicRaycaster) > Panel > TitleLabel (TMP_Text), PlayButton (Button, TMP_Text), SettingsButton (Button, TMP_Text)` + standalone `EventSystem`
3. Attach components in dependency order; apply TMP_Text everywhere
4. Wire UIManager.titleText → TitleLabel; UIManager.playButton → PlayButton
5. Validate: CanvasScaler present ✅, EventSystem present ✅, TMP_Text used ✅

**Result:** COMPLETE — Scene created, all references wired

**Skills flagged:** None

---

### Example 2: Scene Missing Spec

**Scenario:** "Add a game over screen somewhere in the project."

**Inputs provided:**
- Vague description with no path or hierarchy detail

**Execution steps:**
1. Path cannot be determined — no feature path provided; folder-structure-guide does not have a default for game-over screens
2. Flag `prefab-scene-spec` to produce a proper spec first
3. If user requests proceeding with assumptions: use `Assets/Features/GameOver/GameOver.unity`, apply UGUI defaults, log all structure assumptions per DT-1

**Result:** PARTIAL — Blocked pending spec; assumptions documented if user chooses to continue

**Skills flagged:** prefab-scene-spec

---

### Example 3: Modifying Existing Scene

**Scenario:** Add a notification banner to the existing HUD scene.

**Inputs provided:**
- Scene: `Assets/Features/HUD/HUD.unity`
- Add: NotificationBanner GameObject with TMP_Text and CanvasGroup
- Wire: HUDManager.notificationBanner field to the new object

**Execution steps:**
1. Scope confirmed: only `HUD.unity` in scope; no other scenes touched
2. Hierarchy addition: `HUDCanvas/NotificationBanner (CanvasGroup, TMP_Text)` — appended to existing root
3. Attach components; use TMP_Text per convention
4. Wire HUDManager.notificationBanner → NotificationBanner
5. Convention check: existing legacy Text components in scene noted in output; not modified (DA-4)

**Result:** COMPLETE — GameObject added and wired; one convention note logged

**Skills flagged:** None

---

### Example 4: Bootstrap Scene Assembly

**Scenario:** Create a bootstrap scene that loads required manager prefabs.

**Inputs provided:**
- Scene: `Assets/Bootstrap.unity`
- Add: GameManager prefab instance, AudioManager prefab instance, empty SceneLoader object with SceneLoader.cs attached

**Execution steps:**
1. Path validated: `Assets/Bootstrap.unity` ✅
2. No Canvas needed — not a UI scene; no EventSystem required
3. Add three root GameObjects: GameManager (prefab instance), AudioManager (prefab instance), SceneLoader (SceneLoader.cs)
4. No serialized wiring specified — note that SceneLoader dependencies are runtime-resolved; log assumption
5. Convention check: no UI components, UGUI convention N/A; naming follows PascalCase ✅

**Result:** COMPLETE — Bootstrap scene assembled; runtime wiring noted as out of scope

**Skills flagged:** None

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Creating scenes in an unverified or incorrect Assets path
✅ **Correct approach:** Always resolve the exact path from `folder-structure-guide` before creating any file. An incorrectly placed scene is a structural defect.

❌ **Anti-pattern 2:** Using legacy `Text` component for any new UI text element
✅ **Correct approach:** All new text elements must use `TMP_Text`. Never use the legacy `Text` component for content created by this skill.

❌ **Anti-pattern 3:** Adding "might be useful" GameObjects not in the task spec
✅ **Correct approach:** Add only what is explicitly required. Log speculative additions in `notes` as suggestions; do not include them in the scene.

❌ **Anti-pattern 4:** Modifying existing GameObjects in adjacent scenes not in scope
✅ **Correct approach:** Scope is strictly limited to the named scene(s). Any adjacent scene changes require a separate explicit task.

❌ **Anti-pattern 5:** Silently guessing a wiring target when the target is ambiguous
✅ **Correct approach:** If a wiring target cannot be unambiguously identified, mark the field as unresolved and document in `notes`. Never assign a guessed target.

❌ **Anti-pattern 6:** Implementing gameplay logic through component configuration (e.g., configuring a script's behavior in-inspector to act as a state machine)
✅ **Correct approach:** Wiring serialized fields is in scope. Configuring logic through inspector values that implement game behavior is not — log and redirect to code skills.

❌ **Anti-pattern 7:** Omitting `CanvasScaler` from a Canvas root in a UI scene
✅ **Correct approach:** Every Canvas root must include `Canvas`, `CanvasScaler`, and `GraphicRaycaster`. This is non-negotiable for responsive UI.

❌ **Anti-pattern 8:** Omitting `EventSystem` from a UI scene
✅ **Correct approach:** Every scene with interactive UI elements must include exactly one `EventSystem` at the scene root.

❌ **Anti-pattern 9:** Restructuring or renaming existing hierarchy nodes without instruction
✅ **Correct approach:** Only add new nodes and components as instructed. Restructuring existing hierarchy is a separate, explicit task.

❌ **Anti-pattern 10:** Creating the scene without documenting what was built
✅ **Correct approach:** Always produce the full structured output report, even for simple scenes. The report is the audit trail.

---

## Non-Goals

* **Gameplay and system logic implementation** — handled by domain-specific engineering skills and `architecture-patterns`
* **C# script authoring or refactoring** — handled by code-oriented skills; this skill only attaches and wires existing scripts
* **Asset creation (textures, audio, prefab content)** — handled by `procedural-content` and art pipeline skills
* **Scene layout design decisions** — handled by `design-reference` and `prefab-scene-spec` upstream

---

## Notes for LLM Implementation

1. **Path first**: Always resolve the full Assets-relative path before any other work. A correct scene in the wrong location is a structural defect.
2. **Hierarchy before components**: Define the full GameObject tree first, then attach components per node. This prevents dependency ordering errors.
3. **TMP_Text is non-negotiable**: Never use legacy `Text`. If legacy text exists in a scene being modified, note it but do not touch it unless explicitly asked.
4. **Unresolved is better than guessed**: When a wiring target doesn't exist, mark the field as unresolved and document it clearly. A guessed assignment creates a hidden bug.
5. **No logic through the back door**: Inspector configuration that implements game behavior (e.g., an extensive animator controller setup that substitutes for script logic) is out of scope. Add, attach, and wire; don't configure logic.

**Output format:**
- Always produce the full JSON output shape defined in the Outputs section
- Always produce the markdown Scene Build Report from the Final Step
- Use the structured table format for hierarchy descriptions

**Tone and approach:**
- Structural and precise: name every GameObject, every component, every field
- Conservative: when in doubt, do less and log more
- Transparent: every assumption and every unresolved item must be visible in the output

---

## Metadata Summary

```yaml
name: scene-component-builder
category: Content Generation
priority: High
depends_on: [folder-structure, design-reference]
flags_skills: [prefab-scene-spec, architecture-patterns]
rules_applied: [PS-1, PS-3, DA-4, DA-5, DT-1]
documents_needed: [design-reference, folder-structure-guide, prefab-scene-spec]
tags: [unity, scene, hierarchy, components, ugui, tmp, serialized-references]
```

**Key relationships:**
- Depends on: folder-structure (path validation), design-reference (design intent)
- Flags: prefab-scene-spec (missing spec), architecture-patterns (system wiring complexity)
- Governed by: PS-1 (path validation gate), PS-3 (scope control), DA-4 (change boundary), DA-5 (minimal scenes), DT-1 (assumption logging)

---

*End of Skill Human Spec — scene-component-builder-docs.md*
