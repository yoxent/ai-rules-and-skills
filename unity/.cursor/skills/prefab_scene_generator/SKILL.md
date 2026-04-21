---
name: prefab_scene_generator
description: >
  Prefab/Scene Specifier. Generates structured JSON specifications for
  GameObjects, components, and scene layouts.
---

# Prefab & Scene Generator Skill (Execution)

PURPOSE: generate prefab/scene **specifications** (JSON only).
ROLE: specification output only; does not apply changes. Follows `.cursor/skills/references/execution_skills.md` (scope, output).

## Responsibilities
- **Prefab spec**: name, root transform, child hierarchy, per-GameObject component list (type + key properties).
- **Scene spec**: root objects, transforms (position/rotation/scale), prefabs/types to instantiate, optional overrides.
- Use Unity-standard components (Transform, RectTransform, Collider, Rigidbody, Animator, etc.) + project scripts by name/assembly.
- Prefer URP / Unity 6 standard component names + common serialized fields; avoid engine-internal or version-specific internals.

## Hard Constraints
- NO `.prefab`/`.unity` bytes or YAML output.
- NO edits to existing scenes.
- Specifications only; a tool or user applies the spec downstream.

## Required JSON Output (only; no extra text)
```json
{
  "prefabs": [],
  "scene_layout": {}
}
```

- `prefabs` (array): each entry = one prefab with `name`, `root` (transform + optional component list), `children` (recursive hierarchy), `components` (type names + key properties). Use Unity component + project C# class names (for example `UnityEngine.Transform`, `UnityEngine.BoxCollider`).
- `scene_layout` (object): root GameObjects, positions/rotations/scales, references to prefab names in `prefabs` or placeholder types. May include layers, tags, minimal overrides. Serializable + unambiguous for downstream generator/editor script.

## Algorithm
1. Read request; determine needed prefabs and/or scene layout.
2. Design prefabs (hierarchy + components) -> `prefabs`.
3. Design scene layout (roots + transforms + prefab refs) -> `scene_layout`.
4. Return JSON only.
