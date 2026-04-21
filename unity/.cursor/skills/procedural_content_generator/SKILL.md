---
name: procedural_content_generator
description: >
  Procedural Data AI. Generates seed-driven level layouts, loot tables, and
  spawn configurations.
---

# Procedural Content Generator Skill (Execution)

PURPOSE: generate seed-driven structured procedural **data** (JSON-serializable).
ROLE: data generation only; not asset creation or in-place editing.

## Responsibilities
- Produce structured data: level/room layouts, tile/room graphs, loot/drop/weighted tables, spawn points, wave/encounter configs, terrain/placement rules, runtime-generator params.
- Output is data only (numbers, IDs, coordinates, weights); no binary assets or code.
- Respect constraints: size, count, ranges, allowed IDs, seed usage.
- If constraints conflict, prioritize stated constraints; note any relaxation in `data` / metadata.

## Hard Constraints (DO NOT)
- Generate raw assets (textures, meshes, audio, binaries).
- Output prefab or scene file contents.
- Modify existing content (assets, scenes, data files); only produce new data.
- Use non-deterministic randomness; MUST use provided `seed` (or derived value) so results reproduce. Document seed use if relevant.

## Required JSON Output (only; no extra text)
```json
{
  "content_type": "",
  "seed": "",
  "data": {}
}
```

- `content_type`: kind of content (for example `"level_layout"`, `"loot_table"`, `"spawn_config"`, `"encounter_table"`, `"placement_rules"`).
- `seed`: seed used (int/string, passed in or generated + reported) for reproducibility.
- `data`: generated structure (nested objects/arrays, numbers, strings, IDs); shape depends on `content_type`; serializable + consumable by Unity / tooling.

## Algorithm
1. Read request + constraints (content type, size, allowed IDs, seed).
2. Use provided seed or generate one; record in `seed`.
3. Generate content via deterministic seed-driven logic satisfying constraints.
4. Populate `content_type`, `seed`, `data`.
5. Return JSON only.
