# Skill Human Spec: Prefab & Scene Spec

```yaml
---
name: prefab-scene-spec
description: Generates and validates Unity prefab structures and scene hierarchies, enforcing naming, component ordering, nested prefab rules, and scene section markers
version: 1.0.0
category: Content Generation
tags: [unity, prefab, scene, hierarchy, nested-prefab, component-order, section-markers]
priority: Medium

depends_on: [code-standards, folder-structure]
flags_skills: [scene-component-builder]

inputs: [prefab_hierarchy, scene_hierarchy, component_list, prefab_spec]
outputs: [prefab_assessment, scene_assessment, violations_list, corrected_hierarchy, approval_status]

rules_applied:
  - DA-7   # Architectural Consistency
  - MF-1   # Feature Consistency
  - MF-3   # Dependency Clarity

documents_needed: [existing_prefabs, project_prefab_conventions, scene_layout_spec]

execution_context: Runs after code-standards and folder-structure on prefab and scene submissions; flags scene-component-builder when new component wiring is needed
---
```

---

# Skill: Prefab & Scene Spec

---

## Purpose

**What this skill does:**
Generates and validates Unity prefab structures and scene hierarchies: naming conventions (PascalCase prefabs, snake_case scenes), component ordering (Transform first, then rendering, then custom MonoBehaviours), nested prefab rules (max two levels unless justified), and scene section markers (`--- SYSTEMS ---`, `--- LEVEL ---`, `--- DYNAMIC ---`). Ensures prefabs and scenes are consistent, navigable, and maintainable.

Inconsistent prefab and scene organisation creates merge conflicts, slows down level design iteration, and makes it hard to find and diagnose issues at runtime. Consistent structure reduces the cost of onboarding new team members and reviewing scene changes in version control.

Component ordering affects Inspector readability and `GetComponent` search order. Scene section markers allow fast navigation and structured scene diffing in version control. Nested prefab depth limits prevent unmanageable variant chains. Naming conventions make prefab assets findable by name without memorising folder structure.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new prefab is created or an existing prefab is modified
* A new scene is created or scene hierarchy is reorganised
* A prefab uses non-standard component ordering
* A scene lacks section markers
* Nested prefabs exceed two levels deep without documented justification
* Prefab or scene name does not follow project conventions

### Do NOT use this skill for:

* MonoBehaviour scripting logic — use code-standards
* Asset folder placement — use folder-structure
* UI canvas prefabs in detail — use ui-systems

**Execution Context Details:**
Runs after code-standards and folder-structure. Flags scene-component-builder when new component wiring or scene object construction is required.

---

## Inputs

**Required inputs:**

* **Prefab hierarchy** — The GameObject tree for the prefab under review
* **Component list** — Components attached to each node in the hierarchy

**Optional inputs:**

* **Scene hierarchy** — Scene root GameObjects and their section organisation
* **Prefab spec** — GDD or design document describing intended prefab structure

**Documents/Context needed:**

* **Existing prefabs** — Established patterns to check alignment per DA-7
* **Project prefab conventions** — Documented naming, component ordering, nesting depth rules
* **Scene layout spec** — Expected section markers and root object names

---

## Outputs

**Primary outputs:**

* **Prefab assessment** — Pass/Fail/Needs Review per prefab convention category
* **Scene assessment** — Pass/Fail/Needs Review per scene convention category
* **Violations list** — Naming, component order, nesting depth, section marker issues
* **Corrected hierarchy** — Before/after showing the compliant structure
* **Approval status** — Whether prefab/scene meets standards

**Output format:**

* Structured report with sections: Naming, Component Ordering, Nested Prefab Depth, Scene Markers
* Corrected hierarchy diagrams for violations

**Skill flags (if applicable):**

* Flags `scene-component-builder` when new component wiring is required

---

## Preconditions

**Conditions that must be met before execution:**

* code-standards has passed for any scripts attached to the prefab
* folder-structure has validated that the prefab is in the correct folder
* Project naming conventions are known or inferable from existing prefabs

**Validation checks:**

* [ ] Prefab file in correct Assets/ subfolder per folder-structure
* [ ] Project PascalCase prefab naming convention confirmed
* [ ] Scene section marker convention confirmed from existing scenes

---

## Step-by-Step Execution Procedure

### Step 1: Validate Prefab Naming

**Questions to answer:**
- Does the prefab name follow `PascalCase` with a meaningful type suffix or prefix?

**Actions:**
- [ ] Check prefab filename: must be `PascalCase` (e.g., `PlayerCharacter.prefab`, `EnemyGoblin.prefab`)
- [ ] Verify name includes type context — not just `Enemy.prefab` but `EnemyGoblin.prefab`
- [ ] Check scene filename: must be `snake_case` (e.g., `level_01_forest.unity`, `main_menu.unity`)
- [ ] Flag generic or numeric names: `Prefab1.prefab`, `NewObject.prefab`

**Red flags / Warning signs:**
- `new object.prefab` — Unity default name, not renamed
- `enemy_goblin.prefab` — snake_case on a prefab (scene convention, not prefab)

**Decision points:**
- Incorrect naming: warn, provide corrected name following convention

---

### Step 2: Validate Component Ordering

**Questions to answer:**
- Are components on each GameObject ordered: Transform → Collider/Renderer → Audio/Rigidbody → Custom MonoBehaviours?

**Actions:**
- [ ] Inspect component stack on each GameObject node
- [ ] Verify Transform (or RectTransform) is first — always Unity default
- [ ] Verify engine components (Collider, Renderer, Rigidbody, AudioSource) precede custom MonoBehaviours
- [ ] Verify related custom components are grouped: state before controller before view

**Red flags / Warning signs:**
- Custom `PlayerHealth` component above `Collider` on player root
- Unrelated components interleaved with no logical grouping

**Decision points:**
- Wrong order: warn, provide correct component stack ordering

---

### Step 3: Validate Nested Prefab Depth

**Questions to answer:**
- Does the prefab contain nested prefab variants more than two levels deep?

**Actions:**
- [ ] Identify the prefab variant chain: Base → Variant → Variant → ...
- [ ] Count nesting depth — flag if exceeding two levels without documented justification
- [ ] Verify nested child prefabs are for genuine reuse (e.g., `WeaponSocket` as a shared child), not organisation
- [ ] Flag prefabs that are broken-out purely for hierarchy grouping rather than reuse

**Red flags / Warning signs:**
- `EnemyBase → EnemyGoblin → EnemyGoblinArmoured → EnemyGoblinArmouredElite` — four levels
- Child GameObjects broken out as prefabs purely for grouping (not reused elsewhere)

**Decision points:**
- Depth > 2: warn, request justification or propose flattening
- Grouping-only nested prefabs: warn, suggest plain GameObjects

---

### Step 4: Validate Scene Section Markers

**Questions to answer:**
- Does the scene hierarchy use the canonical section markers: `--- SYSTEMS ---`, `--- LEVEL ---`, `--- DYNAMIC ---`?

**Actions:**
- [ ] Check scene root for empty GameObjects named with section markers
- [ ] Verify `--- SYSTEMS ---`: managers, singletons, service locator, audio mixer
- [ ] Verify `--- LEVEL ---`: static geometry, lighting, terrain, trigger volumes
- [ ] Verify `--- DYNAMIC ---`: spawn points, runtime-created objects parent
- [ ] Flag root GameObjects placed outside any section marker

**Red flags / Warning signs:**
- Player prefab placed at scene root without a section marker parent
- No `--- SYSTEMS ---` section — game managers floating at root
- Custom section names not matching project convention

**Decision points:**
- Missing section: warn, provide correct marker hierarchy
- Wrong section placement: warn, move to correct section

---

### Step 5: Validate Prefab Child Separation

**Questions to answer:**
- Are child GameObjects in the prefab separated by purpose (visual, collider, socket, audio)?

**Actions:**
- [ ] Verify visual mesh is on a child named `Visual` or `Mesh`, not on the root
- [ ] Verify Collider is on a child named `Collider` if separated from visual for physics reasons
- [ ] Verify attachment points (weapon sockets, VFX spawn points) are empty GameObjects with descriptive names
- [ ] Flag all logic-bearing components on a deeply nested child — should be on root or direct child

**Red flags / Warning signs:**
- `MeshRenderer` on the root GameObject alongside game logic components — mixing concerns
- Attachment point named `Empty` or `GameObject (1)` — not descriptive

**Decision points:**
- Mixed visual+logic on root: warn, suggest Visual child separation
- Non-descriptive attachment names: warn, provide naming convention

---

### Final Step: Generate Prefab & Scene Spec Report

```markdown
## Prefab & Scene Spec Report

**Target:** [PrefabName.prefab / SceneName.unity]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Naming
[Finding — PascalCase prefab, snake_case scene, meaningful type context]

### Component Ordering
[Finding — engine components before custom MonoBehaviours]

### Nested Prefab Depth
[Finding — chain depth, justification if >2]

### Scene Section Markers
[Finding — SYSTEMS, LEVEL, DYNAMIC markers present and correct]

### Child Separation
[Finding — Visual, Collider, attachment point naming]

### Overall Assessment
- ✅ PASS: All prefab/scene conventions met
- ❌ FAIL: Non-standard naming or missing section markers
- ⚠️ NEEDS REVIEW: Component ordering or nesting depth issue

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce PascalCase on prefab names, snake_case on scene names, with meaningful type context
2. Validate component ordering: engine components before custom MonoBehaviours
3. Flag nested prefab chains deeper than two levels — request justification or flatten
4. Enforce `--- SYSTEMS ---`, `--- LEVEL ---`, `--- DYNAMIC ---` section markers in all scenes
5. Require descriptive names on child GameObjects (Visual, Collider, WeaponSocket)

**Quality criteria:**

* Zero prefabs with Unity default names (`New Object`, `Prefab1`)
* All scenes have canonical section markers
* No nested prefab chain deeper than two levels without documented justification

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-7: Architectural Consistency**
  - Applies: Prefab structure and scene hierarchy must match the pattern established by existing assets
  - In practice: If all enemies use `Visual` child for mesh, a new enemy must too

* **MF-1: Feature Consistency**
  - Applies: New prefab variants follow the same structure as existing variants
  - In practice: `EnemyGoblinArmoured.prefab` inherits from `EnemyGoblin.prefab` following the same child layout

* **MF-3: Dependency Clarity**
  - Applies: Component dependencies visible in hierarchy — components that depend on each other are co-located on the same node
  - In practice: `CharacterController` and `PlayerMovement` on the same root; not split across root and child

---

## Tradeoff Handling

### Tradeoff 1: Nested Prefab Depth vs. Reuse

**Scenario:** UI system requires five levels of nested prefabs for fine-grained reskin variants.

**Default stance:** Document the justification per DA-7. If variants exist only for reskin, consider Sprite/Material swapping on a two-level prefab instead of deep nesting.

**Resolution process:**
1. Count variant levels
2. If >2: request justification
3. If justified (genuine reuse, not cosmetic): document via DT-1
4. If cosmetic only: propose material/sprite swap approach

---

### Tradeoff 2: Visual Child vs. Performance

**Scenario:** Separating Mesh to a child GameObject adds a draw call overhead in static batching.

**Default stance:** For static geometry that will be batched, mesh on root is acceptable. For character prefabs with animation, Visual child is required. Document via DT-1 if performance reason overrides convention.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Entire Scene Lacks Section Markers

**Trigger:** Existing production scene has 50+ root GameObjects with no markers.

**Action:**
- Warn — do not require retroactive reorganisation in one PR
- Enforce section markers on all new root objects added
- Create migration plan logged as technical debt via MF-2

---

### Escalation Scenario 2: 5-Level Nested Prefab Chain

**Trigger:** Prefab variant chain 5 levels deep — no documented justification.

**Action:**
- BLOCK the deepest additional nesting
- Propose flattening: consolidate variants at level 2 with material/data overrides
- Request documented justification if chain is genuinely required

---

### When to halt execution:

* No prefab or scene hierarchy provided — nothing to assess
* Project naming conventions not determinable from existing assets — request before assessing

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards and folder-structure. Flags scene-component-builder when new component wiring or scene object setup is required after hierarchy validation.

**Integration workflow:**
1. code-standards and folder-structure pass
2. Orchestrator invokes prefab-scene-spec on prefab or scene hierarchy
3. Skill validates naming, component order, nesting depth, section markers, child separation
4. If new component wiring required: scene-component-builder may be flagged

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| New component wiring required after hierarchy approval | scene-component-builder | Wire components to scripts and configure Inspector values |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Scripts on prefab GameObjects must meet C# standards
* **folder-structure** — Prefab must be in the correct Assets/ subfolder

**Skills this skill cooperates with:**

* **scene-component-builder** — Builds component configuration once hierarchy is validated
* **ui-systems** — UI canvas prefabs have additional UGUI-specific structure rules

**Skills this skill may invoke/flag:**

* **scene-component-builder** — When new component wiring or configuration is needed

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Warn on any Unity default prefab name — never allow `New Object` or `Prefab1` to pass
* [ ] Enforce scene section markers — missing markers always flagged
* [ ] Apply DA-7 — check existing asset patterns before flagging as violation
* [ ] Log nesting depth exception via DT-1 when >2 levels is formally justified
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Nested prefab depth exceptions documented via DT-1
* Scene reorganisation plans logged as technical debt via MF-2

---

## Example Use Cases

### Example 1: Default-Named Prefab

**Scenario:** `New Object.prefab` submitted in Assets/Characters/Enemies/.

**Execution steps:**
1. Detect Unity default name
2. Block: rename following PascalCase with type context
3. Suggest: `EnemyGoblin.prefab`

**Result:** ❌ FAIL

---

### Example 2: Scene Without Section Markers

**Scenario:** `level_02_caves.unity` has 30 root GameObjects — no `--- SYSTEMS ---`, `--- LEVEL ---`, `--- DYNAMIC ---`.

**Execution steps:**
1. Inspect scene root — no section marker empty GameObjects
2. Warn: add canonical markers; reorganise existing roots under correct sections
3. Provide section hierarchy:
   ```
   --- SYSTEMS --- (GameManager, AudioMixer, ServiceLocator)
   --- LEVEL --- (terrain, static geometry, triggers)
   --- DYNAMIC --- (spawn points, pooled object parents)
   ```

**Result:** ⚠️ NEEDS REVIEW

---

### Example 3: Component Ordering Violation

**Scenario:** `PlayerCharacter.prefab` root has: `PlayerHealth` → `Rigidbody` → `CapsuleCollider` → `PlayerMovement`.

**Execution steps:**
1. Inspect component stack
2. Flag: custom `PlayerHealth` before engine `Rigidbody` and `CapsuleCollider`
3. Correct order: `CapsuleCollider` → `Rigidbody` → `PlayerHealth` → `PlayerMovement`

**Result:** ⚠️ NEEDS REVIEW

---

### Example 4: Fully Compliant Prefab

**Scenario:** `EnemyOrc.prefab` — PascalCase name, engine components first, Visual child for mesh, WeaponSocket child for attachment, two-level variant chain from `EnemyBase`.

**Result:** ✅ PASS

---

### Example 5: Four-Level Nested Prefab Chain

**Scenario:** `EnemyOrcEliteAncient.prefab` is a variant of `EnemyOrcElite` → `EnemyOrc` → `EnemyBase` — four levels.

**Execution steps:**
1. Count variant chain: Base → Orc → OrcElite → OrcEliteAncient = 4 levels
2. Warn: exceeds two-level guideline
3. Request justification; if cosmetic only, propose material/data override on two-level base

**Result:** ⚠️ NEEDS REVIEW

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `New Object.prefab` or `Prefab1.prefab` — Unity default name
✅ **Correct approach:** `PascalCase` with type context: `EnemyGoblin.prefab`

❌ **Anti-pattern 2:** `enemy_goblin.prefab` — snake_case on a prefab
✅ **Correct approach:** `EnemyGoblin.prefab` — PascalCase for prefabs; snake_case for scene files only

❌ **Anti-pattern 3:** Custom MonoBehaviour above engine Collider/Rigidbody in component stack
✅ **Correct approach:** Engine components first, then custom MonoBehaviours

❌ **Anti-pattern 4:** Scene root GameObjects with no section markers
✅ **Correct approach:** All roots under `--- SYSTEMS ---`, `--- LEVEL ---`, or `--- DYNAMIC ---`

❌ **Anti-pattern 5:** Prefab variant chain >2 levels deep without justification
✅ **Correct approach:** Max two variant levels; deeper = flatten + data/material override

❌ **Anti-pattern 6:** MeshRenderer on root alongside game logic components
✅ **Correct approach:** `Visual` child GameObject for mesh; root holds logic components

❌ **Anti-pattern 7:** Attachment point named `Empty` or `GameObject (3)`
✅ **Correct approach:** Descriptive name: `WeaponSocketRight`, `VFXSpawnPoint`

---

## Non-Goals

* ❌ Does not validate script logic on prefab components — use code-standards
* ❌ Does not validate asset folder placement — use folder-structure
* ❌ Does not wire or configure component field values — use scene-component-builder
* ❌ Does not validate UI prefab UGUI specifics — use ui-systems

---

## Notes for LLM Implementation

1. **Naming is the first check** — Unity default names must never pass; rename is always a fast fix
2. **Section markers are mandatory in all scenes** — even small utility scenes benefit from markers
3. **Component order is a readability standard** — engine components before custom; flag but do not block
4. **Nesting depth >2 requires justification** — do not block automatically; request documented reason
5. **Child separation pattern (Visual, Collider, Socket) reduces merge conflicts** — it is a structural best practice, not a strict block

---

## Metadata Summary

```yaml
name: prefab-scene-spec
category: Content Generation
priority: Medium
depends_on: [code-standards, folder-structure]
flags_skills: [scene-component-builder]
rules_applied: [DA-7, MF-1, MF-3]
documents_needed: [existing_prefabs, project_prefab_conventions, scene_layout_spec]
tags: [unity, prefab, scene, hierarchy, nested-prefab, component-order, section-markers]
```

**Key relationships:**
- Depends on: code-standards (scripts on prefab), folder-structure (asset placement)
- Flags: scene-component-builder (component wiring after hierarchy approval)
- Governed by: DA-7 (consistency), MF-1 (feature consistency), MF-3 (dependency clarity)
