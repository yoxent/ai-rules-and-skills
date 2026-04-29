# Skill Human Spec: Folder Structure

```yaml
---
name: folder-structure
description: Enforces Unity Assets/ subdirectory layout, Assembly Definition boundaries, and scene/prefab hierarchy conventions
version: 1.0.0
category: Design Governance
tags: [unity, folder-structure, asmdef, scene-hierarchy, prefab-organization]
priority: High

depends_on: []
flags_skills: []

inputs: [project_folder_layout, asmdef_files, scene_hierarchy, prefab_structure]
outputs: [structure_assessment, violations_list, organization_recommendations, approval_status]

rules_applied:
  - DA-7   # Architectural Consistency
  - MF-1   # Feature Consistency
  - DA-4   # Change Boundary Rule

documents_needed: [project_folder_conventions, existing_asmdef_files]

execution_context: Always active; evaluates project organization whenever new scripts, folders, scenes, or prefabs are created
---
```

---

# Skill: Folder Structure

---

## Purpose

**What this skill does:**
Enforces the canonical Unity project folder layout under Assets/, requires Assembly Definition (.asmdef) files for all major systems, and validates scene hierarchy section markers and prefab child-object separation. Ensures every new file and folder lands in the right place and that scenes and prefabs are structured consistently.

Disorganised projects accumulate technical debt that slows navigation, causes merge conflicts, and makes onboarding difficult. Enforcing structure early keeps the project navigable as it grows.

Assembly Definitions enforce compilation boundaries that reduce incremental build times and make dependency direction explicit. Scene hierarchy markers make large scenes navigable. Prefab child separation enables targeted component replacement without restructuring.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new script or folder is added to the Assets/ directory
* A new Assembly Definition is created or an existing one is modified
* A new scene is created or a scene's hierarchy is reorganised
* A new prefab is created or its component layout is changed
* Code review reveals scripts placed in the wrong folder
* A new system or feature is scaffolded

### Do NOT use this skill for:

* Content of scripts — use code-standards for C# conventions
* Addressable asset naming or label strategy — separate concern
* CI/CD or build output directories — DevOps concern
* Third-party plugin folders (Plugins/, ThirdParty/) — external, not subject to project conventions

**Execution Context Details:**
Runs alongside or immediately after code-standards when new files are created. Also runs on scene and prefab work. Acts as a structural gate before architecture-patterns.

---

## Inputs

**Required inputs:**

* **Project folder layout** — Current Assets/ directory tree showing where files are placed
* **Asmdef files** — All existing .asmdef declarations and their references
* **Scene hierarchy** — The GameObject hierarchy of the scene being reviewed
* **Prefab structure** — The component and child layout of prefabs under review

**Optional inputs:**

* **Project folder conventions doc** — Any documented project-specific layout decisions

**Documents/Context needed:**

* **Existing .asmdef files** — To validate reference direction and avoid circular dependencies
* **Project layout doc** — For projects with custom folder conventions that extend the baseline

---

## Outputs

**Primary outputs:**

* **Structure assessment** — Pass/Fail/Needs Review per organization category
* **Violations list** — Misplaced scripts, missing .asmdef, flat hierarchies, monolithic prefabs
* **Organization recommendations** — Correct target path or refactoring suggestion
* **Approval status** — Whether the structure is ready for the next gate

**Output format:**

* Structured report with sections: Folder Layout, Assembly Definitions, Scene Hierarchy, Prefab Structure
* File path suggestions for misplaced items

**Skill flags (if applicable):**

* No downstream flags — structure is a prerequisite gate

---

## Preconditions

**Conditions that must be met before execution:**

* The file or folder being assessed exists in the project
* The overall project has enough existing structure to infer conventions (or a conventions doc is available)

**Validation checks:**

* [ ] Assets/ root directory exists and is the working root
* [ ] At least one existing .asmdef is present to validate reference direction
* [ ] Scene file is a valid Unity scene (not a raw text file)

---

## Step-by-Step Execution Procedure

### Step 1: Validate Assets/ Subdirectory Mapping

**Questions to answer:**
- Is every new script, asset, or folder placed in the correct Assets/ subdirectory?
- Does the project follow the canonical mapping?

**Actions:**
- [ ] Verify scripts go into `Systems/` (reusable) or `Features/` (project-specific) — not Assets/ root
- [ ] Verify art assets (Materials, Models, Textures, Animations, Sprites) are under `Art/`
- [ ] Verify shared project glue (EventBus, ServiceLocator, shared UI) is in `Core/`
- [ ] Verify Addressable content is under `AddressableAssets/`
- [ ] Verify prefabs are under `Prefabs/` with subfolders (Characters, Environment, UI, Effects)
- [ ] Flag any script found directly in Assets/ root

**Red flags / Warning signs:**
- Scripts placed directly in Assets/ root
- Art assets in Features/ alongside scripts
- A "Misc" or "Other" folder with heterogeneous content

**Decision points:**
- If script in wrong folder: STYLE warn, provide target path
- If Assets/ root script: SAFETY warn — will cause asmdef boundary violations

---

### Step 2: Validate Assembly Definitions

**Questions to answer:**
- Do all major systems have their own .asmdef?
- Do asmdef references follow a clear dependency direction (Core ← Gameplay ← UI)?

**Actions:**
- [ ] Verify Core.asmdef exists for the Core/ folder
- [ ] Verify Gameplay.asmdef exists for the main gameplay systems
- [ ] Verify UI.asmdef exists for UI code
- [ ] Check asmdef reference direction — no circular references
- [ ] Verify test asmdefs reference the appropriate runtime asmdef and UnityEngine.TestRunner

**Red flags / Warning signs:**
- A major system folder with scripts but no .asmdef — contributes to slow global recompile
- Gameplay.asmdef referencing UI.asmdef (wrong direction — UI should depend on Gameplay, not vice versa)
- Scripts in a folder not covered by any asmdef

**Decision points:**
- Missing asmdef: STYLE warn, provide asmdef template
- Circular reference: SAFETY warn — will fail compilation

---

### Step 3: Validate Scene Hierarchy

**Questions to answer:**
- Does the scene use section markers (--- SYSTEMS ---, --- LEVEL ---, --- DYNAMIC ---)?
- Are GameObjects organised under the appropriate section?

**Actions:**
- [ ] Check top-level hierarchy for section marker GameObjects
- [ ] Verify system managers, bootstrappers, and service locator are under `--- SYSTEMS ---`
- [ ] Verify level geometry, environment, and static objects are under `--- LEVEL ---`
- [ ] Verify runtime-spawned and pooled objects are under `--- DYNAMIC ---`
- [ ] Flag flat hierarchies with no section organisation

**Red flags / Warning signs:**
- 30+ root GameObjects with no grouping
- Manager objects mixed with environment objects at root level
- No `--- DYNAMIC ---` section in a scene that uses pooled or spawned objects

**Decision points:**
- If no section markers: STYLE warn, provide example hierarchy structure
- If only a few root objects (< 6): pass — section markers add overhead for tiny scenes

---

### Step 4: Validate Prefab Structure

**Questions to answer:**
- Are prefab components separated into distinct child GameObjects (visual, colliders, effects, audio)?
- Is the root GameObject free of non-essential components?

**Actions:**
- [ ] Check that visual mesh/renderer is on a child, not the root
- [ ] Check that colliders are on a dedicated child (or physics root)
- [ ] Check that particle systems / VFX are on separate child objects
- [ ] Check that AudioSource is on a dedicated child
- [ ] Flag prefabs with all components collapsed onto the root

**Red flags / Warning signs:**
- `Renderer + Collider + AudioSource + ParticleSystem` all on the prefab root
- Deeply nested hierarchy (>5 levels) without clear purpose

**Decision points:**
- Monolithic root: STYLE warn, describe child-separation pattern
- Excessive nesting: STYLE warn — note is informational

---

### Final Step: Generate Structure Report

```markdown
## Folder Structure Report

**Target:** [Folder/Scene/Prefab under review]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Assets/ Folder Layout
[Finding — misplaced files with target paths]

### Assembly Definitions
[Finding — missing asmdefs or circular references]

### Scene Hierarchy
[Finding — section marker presence and object placement]

### Prefab Structure
[Finding — child separation or monolithic root]

### Overall Assessment
- ✅ PASS: All structure conventions met
- ❌ FAIL: Script in Assets/ root or circular asmdef reference
- ⚠️ NEEDS REVIEW: Missing section markers or monolithic prefab root

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce the canonical Assets/ subdirectory mapping for all file types
2. Require .asmdef per major system with correct reference direction
3. Enforce scene hierarchy section markers for navigability
4. Require prefab child-object separation for targeted component replacement
5. Maintain consistency with existing project structure per DA-7

**Quality criteria:**

* No scripts in Assets/ root
* Every major system folder has a .asmdef
* Every scene with >6 root objects has section markers
* No monolithic prefab root with all components collapsed

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-7: Architectural Consistency**
  - How it applies: New folders and files must match the existing project layout; no ad-hoc folder creation
  - In practice: Creating a `Scripts/` folder under Assets/ when the project uses `Systems/` is a violation

* **DA-4: Change Boundary Rule**
  - How it applies: Each system folder has a single responsibility; mixed content breaks change boundaries
  - In practice: `Systems/Movement/` should contain only movement-related scripts — not input or UI

### Maintenance & Feature Consistency Rules

* **MF-1: Feature Consistency**
  - How it applies: Every new system introduced must follow the same folder and asmdef pattern as existing systems
  - In practice: If AudioSystem has Audio.asmdef, the new InputSystem must have Input.asmdef

---

## Tradeoff Handling

### Tradeoff 1: Structure Overhead vs. Small Project

**Scenario:** Early prototype with 5 scripts — full folder structure adds navigation overhead with no benefit.

**Default stance:** Apply DA-5 — do not require full structure for prototype-scale projects (< 10 scripts total). Flag as recommendation, not violation.

**Resolution process:**
1. Assess project scale
2. If prototype: suggest structure but do not block
3. If production: enforce fully

---

### Tradeoff 2: Third-Party Plugin Placement

**Scenario:** A third-party asset installs itself into Assets/Scripts/ which conflicts with convention.

**Default stance:** Third-party assets are exempt from project layout enforcement. Flag for human awareness but do not block.

**Resolution process:**
1. Identify as third-party
2. Note the conflict as informational
3. Recommend moving if the asset supports it — do not enforce if it does not

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Circular .asmdef Reference

**Trigger:** System A's .asmdef references System B's .asmdef which references System A's — circular.

**Action:**
- Block — will cause compilation failure
- Request dependency direction review
- Recommend extracting shared code to Core.asmdef

---

### Escalation Scenario 2: Script in Assets/ Root

**Trigger:** A new script is placed directly in Assets/ with no enclosing folder.

**Action:**
- SAFETY warn — outside all .asmdef boundaries, contributes to global recompile
- Provide correct target path based on script purpose
- Request move before merge

---

### Escalation Scenario 3: No Existing Structure to Infer From

**Trigger:** Brand-new project with no existing folder conventions.

**Action:**
- Apply canonical baseline as the default
- Present canonical structure to team for confirmation
- Log adoption of baseline via DT-1

---

### When to halt execution:

* Project is a single-file prototype with no Assets/ structure yet — apply suggestions only, no enforcement
* Cannot determine if a folder is project-created or third-party — flag for human decision

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs alongside code-standards on file creation and before architecture-patterns. Structural violations should be resolved before assessing architectural patterns.

**Integration workflow:**
1. New script/folder/scene/prefab created
2. Orchestrator invokes folder-structure alongside code-standards
3. Structure gate passes → orchestrator proceeds to architecture-patterns or domain skill
4. Structure violations block — must resolve placement before continuing

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — structure is a prerequisite gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* None — structure is evaluated independently

**Skills this skill cooperates with:**

* **code-standards** — Runs alongside; both are foundational gates before domain skills
* **architecture-patterns** — Assumes correct folder/asmdef structure before assessing architectural patterns

**Skills this skill may invoke/flag:**

* None — prerequisite gate only

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Apply DA-5 for prototype-scale projects — do not over-enforce on early-stage work
* [ ] Exempt third-party plugin folders from enforcement
* [ ] Always provide the correct target path when flagging a misplaced file
* [ ] Log canonical baseline adoption on new projects via DT-1
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Canonical baseline adoption on new projects logged via DT-1
* Any approved exceptions to asmdef requirement documented

---

## Example Use Cases

### Example 1: Script in Assets/ Root

**Scenario:** `GameManager.cs` placed directly in Assets/ with no enclosing folder.

**Execution steps:**
1. Detect script in Assets/ root
2. Classify as SAFETY warn — outside .asmdef boundary
3. Suggest: move to `Assets/Core/Scripts/Runtime/GameManager.cs`

**Result:** ⚠️ NEEDS REVIEW — move required before production

---

### Example 2: Missing .asmdef for New System

**Scenario:** `Assets/Systems/Inventory/` folder contains 8 scripts but no Inventory.asmdef.

**Execution steps:**
1. Detect system folder without .asmdef
2. Flag: contributes to full project recompile on any script change
3. Provide .asmdef template with correct name and references

**Result:** ⚠️ NEEDS REVIEW — asmdef recommended before feature grows

---

### Example 3: Flat Scene Hierarchy

**Scenario:** Scene has 40 root GameObjects — Camera, Player, Enemy, Wall, Floor, UI, Manager... all at the same level.

**Execution steps:**
1. Count root objects: 40 → warrants section markers
2. Flag: recommend --- SYSTEMS ---, --- LEVEL ---, --- DYNAMIC --- sections
3. Provide example grouped hierarchy

**Result:** ⚠️ NEEDS REVIEW — organisation improves navigability significantly

---

### Example 4: Monolithic Prefab Root

**Scenario:** `Player.prefab` root has: Transform, Rigidbody, BoxCollider, MeshRenderer, AudioSource, ParticleSystem, PlayerController.

**Execution steps:**
1. Detect all components on root
2. Flag: child-separation recommended
3. Suggest: Visual (child), Collider (child), Audio (child), Effects (child)

**Result:** ⚠️ NEEDS REVIEW — separating components enables targeted replacement

---

### Example 5: Fully Compliant New Feature

**Scenario:** New `Combat` feature added under `Assets/Features/Combat/` with `Combat.asmdef`, scripts in `Scripts/Runtime/`, tests in `Tests/`.

**Result:** ✅ PASS — all structure conventions met

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Scripts placed in `Assets/Scripts/` flat folder
✅ **Correct approach:** `Assets/Systems/` for reusable modules, `Assets/Features/` for gameplay-specific

❌ **Anti-pattern 2:** No .asmdef on a major system folder
✅ **Correct approach:** One .asmdef per major system (Core.asmdef, Gameplay.asmdef, UI.asmdef minimum)

❌ **Anti-pattern 3:** UI.asmdef references Gameplay.asmdef which references UI.asmdef (circular)
✅ **Correct approach:** Core ← Gameplay ← UI dependency direction; extract shared code to Core

❌ **Anti-pattern 4:** 30+ root GameObjects in a scene with no grouping
✅ **Correct approach:** Section markers: --- SYSTEMS ---, --- LEVEL ---, --- DYNAMIC ---

❌ **Anti-pattern 5:** All components on a prefab's root GameObject
✅ **Correct approach:** Visual/Collider/Effects/Audio on separate child objects

❌ **Anti-pattern 6:** Art assets (textures, materials) in `Features/` alongside scripts
✅ **Correct approach:** Art assets in `Assets/Art/` with type subfolders

❌ **Anti-pattern 7:** Addressable content scattered across `Features/` without a dedicated `AddressableAssets/` folder
✅ **Correct approach:** All addressable content under `Assets/AddressableAssets/` organised by load group

❌ **Anti-pattern 8:** Test scripts placed in `Scripts/Runtime/` alongside production code
✅ **Correct approach:** Tests in a separate `Tests/EditMode/` or `Tests/PlayMode/` folder with their own .asmdef

---

## Non-Goals

* ❌ Does not enforce C# naming or lifecycle within scripts — use code-standards
* ❌ Does not validate Addressables asset naming or label strategy — separate tooling concern
* ❌ Does not assess build system or CI/CD output paths — DevOps concern
* ❌ Does not enforce third-party plugin folder structure

---

## Notes for LLM Implementation

1. **Apply DA-5 for early-stage projects** — enforce structure on production-scale; suggest on prototypes
2. **Always provide the correct target path** — never just say "wrong place"; say where it should go
3. **Distinguish project vs. third-party folders** — exempt third-party from enforcement
4. **Asmdef circular reference is a compile error** — always block; never warn-only
5. **Scene hierarchy markers are navigability tools** — enforce only when scene scale warrants them (> 6 root objects)

**Output format preferences:**
* File path suggestions in code-formatted paths
* Severity labels: SAFETY / STYLE
* Required actions as checkboxes

---

## Metadata Summary

```yaml
name: folder-structure
category: Design Governance
priority: High
depends_on: []
flags_skills: []
rules_applied: [DA-7, MF-1, DA-4]
documents_needed: [project_folder_conventions, existing_asmdef_files]
tags: [unity, folder-structure, asmdef, scene-hierarchy, prefab-organization]
```

**Key relationships:**
- Depends on: nothing — structural baseline skill
- Flags: nothing — prerequisite gate
- Governed by: DA-7 (consistency), MF-1 (feature consistency), DA-4 (change boundary)
