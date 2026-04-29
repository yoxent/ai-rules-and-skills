---
name: folder-structure
description: "Use when task requires Always active. Enforce Assets/ layout, .asmdef per system, scene section markers, and prefab child separation."
---

# Folder Structure

name:folder-structure|pri:H|deps:[]|flags:[]|rules:[DA-7,MF-1,DA-4]
SCOPE: Always active. Enforce Assets/ layout, .asmdef per system, scene section markers, and prefab child separation.
ENFORCE: Assets/ subdirs (Art/Systems/Features/Core/AddressableAssets/Prefabs); .asmdef per major system with correct direction (Core←Gameplay←UI); scene section markers (--- SYSTEMS ---, --- LEVEL ---, --- DYNAMIC ---) when root count >6; prefab child separation (visual/colliders/effects/audio as distinct children); scripts only in Systems/ or Features/ unless justified.
PROHIBIT: Scripts in Assets/ root; mixed concerns in one .asmdef; circular .asmdef references; scene hierarchies >6 roots without markers.
ON_VIOLATION: script_in_root→warn→target_path. circular_asmdef→BLOCK→dependency_review. missing_asmdef→warn→provide_template. flat_hierarchy→warn→section_structure. monolithic_prefab→warn→child_separation.

## Reference
- See [reference.md](reference.md) for distilled source details.
