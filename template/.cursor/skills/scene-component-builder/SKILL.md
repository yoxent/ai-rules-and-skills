---
name: scene-component-builder
description: "Use when task requires Scene authoring only. Creates/modifies Unity .unity scenes: hierarchy, component attachment, serialized field wiring. UGUI+TMP. No gameplay logic."
---

# Scene Component Builder

name:scene-component-builder|pri:H|deps:[folder-structure,design-reference]|flags:[prefab-scene-spec,architecture-patterns]|rules:[PS-1,PS-3,DA-4,DA-5,DT-1]
SCOPE: Scene authoring only. Creates/modifies Unity .unity scenes: hierarchy, component attachment, serialized field wiring. UGUI+TMP. No gameplay logic.
ENFORCE: Verify full Assets-relative path before creation per PS-1 (BLOCK if unverifiable); constrain edits to named scene(s) per DA-4; TMP_Text on all new text elements; CanvasScaler+GraphicRaycaster on Canvas roots; EventSystem in every UI scene; add only task-required components per DA-5; log hierarchy/wiring assumptions per DT-1; mark unresolvable wiring targets as unresolved — never guess.
PROHIBIT: Legacy Text on new elements; gameplay/system logic; script authoring; modifying unnamed scenes; guessing ambiguous wiring targets; speculative GameObjects outside task spec.
ON_VIOLATION: path_unverifiable→BLOCK→request_confirmation. spec_absent→flag:prefab-scene-spec. system_wiring→flag:architecture-patterns→log. logic_requested→redirect→continue. wiring_missing→mark_unresolved. legacy_text→replace_TMP. scope_drift→halt→log.

## Reference
- See [reference.md](reference.md) for distilled source details.
