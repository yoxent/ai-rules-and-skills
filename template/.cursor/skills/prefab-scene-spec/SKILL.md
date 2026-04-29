---
name: prefab-scene-spec
description: "Use when task requires After code-standards on prefab/scene submissions. Validates naming, component order, nesting depth, section markers, and child separation."
---

# Prefab Scene Spec

name:prefab-scene-spec|pri:M|deps:[code-standards,folder-structure]|flags:[scene-component-builder]|rules:[DA-7,MF-1,MF-3]
SCOPE: After code-standards on prefab/scene submissions. Validates naming, component order, nesting depth, section markers, and child separation.
ENFORCE: Prefab filenames PascalCase with type context (EnemyGoblin.prefab); scene filenames snake_case (level_01.unity); engine components (Collider/Renderer/Rigidbody) before custom MonoBehaviours; variant chain ≤2 levels deep; all scene roots under --- SYSTEMS ---, --- LEVEL ---, --- DYNAMIC ---; child GameObjects named descriptively (Visual, ColliderShape, WeaponSocket).
PROHIBIT: Unity default names (New Object, Prefab1); custom MonoBehaviour above engine components; variant chain >2 levels without justification; scene roots outside section markers; attachment points named Empty or numbered; MeshRenderer on root alongside game logic.
ON_VIOLATION: default_name→warn→PascalCase. component_order→warn→correct_stack. deep_nesting→warn→justify_or_flatten. missing_markers→warn→add_sections. vague_child→warn→descriptive_name. wiring_needed→flag:scene-component-builder.

## Reference
- See [reference.md](reference.md) for distilled source details.
