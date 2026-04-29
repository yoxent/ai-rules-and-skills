# Skill Human Spec: Physics Systems

```yaml
---
name: physics-systems
description: Enforces Rigidbody/CharacterController selection, Physics query masks, FixedUpdate mutation timing, and collision event semantics
version: 1.0.0
category: Architecture
tags: [unity, physics, rigidbody, charactercontroller, collision, fixedupdate]
priority: High
depends_on: [code-standards]
flags_skills: [performance-optimization]
inputs: [physics_scripts, collider_configurations, physics_query_code]
outputs: [violations_list, component_recommendations, corrected_patterns]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-5  # Avoid Overengineering
  - DA-7  # Architectural Consistency
  - PC-4  # Performance Budget
  - MF-5  # Reliability Rule
documents_needed: [project_physics_layer_matrix]
execution_context: After code-standards on scripts using Rigidbody, CharacterController, Physics queries, or collision callbacks
---
```

---

# Skill: Physics Systems

## Purpose

Validates Unity physics implementation: component selection (Rigidbody vs CharacterController), query LayerMask hygiene, FixedUpdate timing enforcement, and trigger/collision event semantics. Prevents the most common physics bugs — transform-driven Rigidbodies, framerate-dependent forces, and unbounded world queries.

---

## When to Use

**Triggers:**
- Script uses Rigidbody, CharacterController, or Physics.Raycast/Overlap/Cast variants
- Collision or trigger callbacks implemented
- Kinematic Rigidbody movement code written
- New physics object type introduced to the project

**Do NOT use for:** DOTS Physics (→ dots-ecs); NavMesh movement (→ ai-pathfinding); ragdoll authoring in Editor only (no scripting concern).

---

## Inputs & Outputs

**Inputs:** Physics scripts; collider setups; Physics query calls
**Outputs:** Violations list; component recommendation; corrected query/mutation patterns
**Flags:** `performance-optimization` when maskless queries detected on a hot path

---

## Execution Steps

### 1 — Component Selection
- Rigidbody for physics-simulated/dynamic objects; CharacterController for direct player movement without full simulation
- No GameObject may have both; CharacterController + physics force combination → escalate to DT-3

### 2 — Query Hygiene
- Physics.Raycast/OverlapSphere/OverlapBox/SphereCast/CapsuleCast must each include a LayerMask argument
- Flag queries inside Update with no cached result on hot paths → flag:performance-optimization

### 3 — Mutation Timing
- AddForce, AddTorque, MovePosition, MoveRotation → FixedUpdate only
- Block transform.position/rotation assigned directly on non-kinematic Rigidbody
- Kinematic Rigidbody: MovePosition/MoveRotation inside FixedUpdate only

### 4 — Collision Semantics
- OnTriggerEnter: Collider.isTrigger=true, overlap-only response, no physics impulse
- OnCollisionEnter: physical impact with physics-engine response
- Flag swapped semantics (trigger used as collision or vice versa)

---

## Core Responsibilities

1. Enforce Rigidbody/CharacterController selection by use-case
2. Require LayerMask on all Physics queries
3. Enforce physics mutations in FixedUpdate exclusively
4. Block transform mutation on non-kinematic Rigidbodies
5. Validate trigger vs collision callback semantics

---

## Rules Applied

- **DA-1:** One physics component per responsibility — no mixed simulation approaches on one object
- **DA-5:** Don't over-engineer compound colliders beyond geometry requirements
- **DA-7:** Project-wide consistent component approach (e.g. all player characters use CharacterController)
- **PC-4:** Maskless queries scan every collider in the scene — performance violation on hot paths
- **MF-5:** Direct transform on non-kinematic Rigidbody causes unpredictable simulation — block, not warn

---

## Tradeoffs

**Rigidbody + CharacterController both needed:** Toggle `isKinematic` contextually, or split physics hit-receiver from movement controller. Log deviation via DT-1.

**Maskless query in prototype:** Require LayerMask regardless — mask cost is zero; scene-wide scan cost scales with scene complexity.

---

## Escalation

| Situation | Action |
|---|---|
| transform.position on non-kinematic Rigidbody | BLOCK → redirect to MovePosition |
| CharacterController + Rigidbody on same GameObject | BLOCK → request architectural choice via DT-3 |
| AddForce in Update | warn → move to FixedUpdate |
| Maskless query on hot path | warn → flag:performance-optimization |
| Unclear object type (static/kinematic/dynamic) | request clarification before assessing |

---

## Anti-Patterns

❌ `_rb.transform.position = target` on a non-kinematic Rigidbody
✅ `_rb.MovePosition(target)` inside FixedUpdate

❌ `Physics.Raycast(ray, out hit)` — no LayerMask
✅ `Physics.Raycast(ray, out hit, distance, _groundLayer)`

❌ `_rb.AddForce(force)` in `Update()` — framerate-dependent magnitude
✅ `_rb.AddForce(force)` in `FixedUpdate()`

❌ CharacterController + Rigidbody on same GameObject
✅ Choose one; document rationale via DT-1

❌ `OnTriggerEnter` on a Collider with `isTrigger = false`
✅ Match callback to `isTrigger` setting; use OnCollisionEnter for solid impacts

❌ `Vector3.Distance(transform.position, target.position) < 0.5f` to detect physics rest
✅ `_rb.IsSleeping()` or `_rb.velocity.sqrMagnitude < _restThreshold`

---

## Non-Goals

- DOTS Physics / ECS physics — use dots-ecs
- Ragdoll joint authoring in Editor (no scripting concern)
- Physics performance profiling — use playtest-diagnostics
- NavMesh/AI movement — use ai-pathfinding

---

## LLM Notes

1. `transform_on_rb` is a BLOCK not a warn — silent transform mutation corrupts physics simulation irreversibly per frame
2. Always provide the corrected `MovePosition` snippet when blocking, not just the flag
3. LayerMask warn escalates to flag:performance-optimization only on measured or clearly hot paths (Update/FixedUpdate with no cache)
4. CharacterController + Rigidbody conflict requires a team architectural decision — escalate via DT-3, do not guess a resolution

---
