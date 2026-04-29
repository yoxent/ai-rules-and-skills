# Skill Human Spec: Animation Systems

```yaml
---
name: animation-systems
description: Enforces Animator Controller setup, blend tree configuration, IK usage, root motion decisions, and animation event wiring in Unity
version: 1.0.0
category: Architecture
tags: [unity, animation, mecanim, animator, blendtree, ik, rootmotion]
priority: High
depends_on: [code-standards]
flags_skills: [performance-optimization, architecture-patterns]
inputs: [animator_scripts, animator_controller_assets, animation_clips]
outputs: [violations_list, animator_setup_recommendations, transition_corrections]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-5  # Avoid Overengineering
  - DA-7  # Architectural Consistency
  - PC-4  # Performance Budget
  - MF-5  # Reliability Rule
documents_needed: [gdd_character_movement_section]
execution_context: On scripts or Animator Controllers for characters, objects, or UI with Animator components; after code-standards
---
```

---

# Skill: Animation Systems

## Purpose

Validates Unity Mecanim animation implementation: Animator Controller structure, parameter-driven transitions, blend tree configuration, IK setup, root motion decisions, and Animation Event wiring. Prevents common animation bugs — string-based parameter access, missing transition conditions, and logic embedded in animation event callbacks.

---

## When to Use

**Triggers:**
- Script sets Animator parameters or reads animator state
- New Animator Controller or blend tree created
- IK pass or root motion enabled on a character
- Animation Events wired to MonoBehaviour methods
- Animator Override Controller used for character variants

**Do NOT use for:** Spine/DragonBones or non-Mecanim animation runtimes; VFX Graph particle animation (→ shader-vfx-spec); UI tweening without Animator.

---

## Inputs & Outputs

**Inputs:** Animator Controller assets; scripts driving Animator parameters; character prefabs with Animator
**Outputs:** Violations list; Animator setup recommendations; blend tree and transition corrections
**Flags:** `performance-optimization` for per-frame GetComponent<Animator> or string hash misuse; `architecture-patterns` for business logic in animation event callbacks

---

## Execution Steps

### 1 — Parameter Access
- All Animator.SetFloat/SetBool/SetInteger/SetTrigger calls use `Animator.StringToHash` cached in Awake — never raw strings at runtime
- Verify hash fields are `private static readonly int` — not recomputed per call

### 2 — Animator Controller Structure
- Entry state must have a valid default transition with no dangling Any State → target loops
- All parameters used in transitions must exist in the Animator Controller; flag unused parameters
- Transitions with no exit time and no condition → flag as unintentional infinite hold

### 3 — Blend Trees
- Locomotion blend trees use speed (float) and direction (float) parameters — not booleans
- 2D blend trees: Freeform Directional for radial movement, Simple Directional for cardinal-only
- Blend tree threshold values distributed evenly; flag clusters that cause snapping

### 4 — Root Motion
- `Animator.applyRootMotion` explicitly set — not left at Inspector default
- Root motion + CharacterController: override OnAnimatorMove to apply deltaPosition/deltaRotation
- Root motion + Rigidbody: disable root motion; drive via Rigidbody.MovePosition in FixedUpdate
- Script-driven movement with root motion enabled → warn, likely conflict

### 5 — IK
- `OnAnimatorIK(int layerIndex)` used for runtime IK goals; not transform-driven offsets
- Animator.SetIKPosition/SetIKPositionWeight both called — weight required for IK to apply
- IK pass enabled on the Animator layer that owns the IK goal

### 6 — Animation Events
- Animation Event methods contain only invocations — no game state reads or manager calls
- Animation Event method must be public and on the same GameObject as Animator
- Game logic triggered by animation event → extract to separate method called from event handler

---

## Core Responsibilities

1. Enforce hash-based parameter access (no runtime string lookup)
2. Validate Animator Controller structure (transitions, conditions, parameters)
3. Validate blend tree type and threshold distribution
4. Enforce correct root motion + physics component pairing
5. Enforce OnAnimatorIK for runtime IK; block transform-offset hacks
6. Block game logic inside Animation Event callbacks

---

## Rules Applied

- **DA-1:** Animation controller is configuration; game logic belongs in MonoBehaviours — not in event callbacks
- **DA-5:** Don't add layers, parameters, or blend trees not required by the current GDD section
- **DA-7:** All characters use the same parameter naming convention and blend tree structure
- **PC-4:** String hash at runtime is an allocation per call — cached hash is zero-cost
- **MF-5:** Missing IK weight or root motion conflict produces silent incorrect behaviour — must surface

---

## Tradeoffs

**Root motion vs script-driven movement:** Root motion gives animation-accurate displacement; script-driven gives physics predictability. Decide per character type; log via DT-1. Never mix both on the same axis.

**Animator Override Controller vs duplicate Animator Controller:** Override Controller for same-structure variants (character skins); duplicate only when transition graph differs significantly. Document choice via DA-7.

---

## Escalation

| Situation | Action |
|---|---|
| Raw string in SetFloat/SetBool/SetTrigger at runtime | warn → provide cached hash pattern |
| Root motion + Rigidbody without OnAnimatorMove | BLOCK → provide correct pairing |
| IK weight not set (goal has no effect) | warn → require SetIKPositionWeight call |
| Game logic in Animation Event callback | warn → flag:architecture-patterns |
| Transition with no condition and no exit time | warn → likely unintentional hold |

---

## Anti-Patterns

❌ `_animator.SetFloat("Speed", speed)` at runtime each frame
✅ `private static readonly int _speedHash = Animator.StringToHash("Speed");` cached in class; `_animator.SetFloat(_speedHash, speed)`

❌ Root motion enabled with Rigidbody — displacement doubles or conflicts
✅ Disable root motion; drive Rigidbody.MovePosition in FixedUpdate from animation speed value

❌ `OnAnimatorIK` not implemented but IK goals set via transform offsets
✅ `void OnAnimatorIK(int layer) { _animator.SetIKPosition(AvatarIKGoal.RightHand, _target.position); _animator.SetIKPositionWeight(AvatarIKGoal.RightHand, 1f); }`

❌ `void OnFootstep() { GameManager.Instance.PlaySound(clip); }` in Animation Event
✅ `void OnFootstep() { _footstepRequested?.Invoke(); }` — event/channel; AudioSystem subscribes

❌ Boolean parameter used for locomotion speed blend
✅ Float parameter with blend tree thresholds (0=idle, 0.5=walk, 1=run)

❌ Animator.GetCurrentAnimatorStateInfo(0).IsName("Run") polled every Update
✅ Use parameter-driven state machines; avoid polling state name strings

---

## Non-Goals

- Non-Mecanim animation runtimes (Spine, DOTween sequence animation)
- VFX particle animation — use shader-vfx-spec
- UI tweening without Animator component
- Authoring animation clips (keyframe data) — Editor workflow only

---

## LLM Notes

1. Always provide the cached `StringToHash` pattern when flagging raw string parameter access
2. Root motion + physics component pairing is the most common silent bug — always verify both are intentional
3. IK requires BOTH SetIKPosition AND SetIKPositionWeight — omitting weight silently produces no effect
4. Animation Event callbacks should be treated like UI event handlers (DA-1): invoke, don't contain logic

---
