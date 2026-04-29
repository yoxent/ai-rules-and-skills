# Skill Human Spec: Procedural Content

```yaml
---
name: procedural-content
description: Generates and validates Unity procedural content systems including runtime mesh generation, noise-based terrain, and data-driven spawn tables
version: 1.0.0
category: Content Generation
tags: [unity, procedural, mesh, perlin-noise, spawn-tables, runtime-generation]
priority: Medium

depends_on: [code-standards, architecture-patterns, performance-optimization]
flags_skills: [performance-optimization]

inputs: [generation_requirements, seed_parameters, content_spec, existing_generators]
outputs: [procedural_system_assessment, generated_code_scaffold, violations_list, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-5   # Abstraction Stability
  - PC-1   # Allocation Budget
  - PC-4   # Performance Budget

documents_needed: [gdd_procedural_section, existing_generators, content_distribution_spec]

execution_context: Runs after code-standards and architecture-patterns on procedural generation systems; flags performance-optimization when runtime mesh or heavy generation is involved
---
```

---

# Skill: Procedural Content

---

## Purpose

**What this skill does:**
Generates and validates Unity procedural content systems: seeded noise-based terrain and level layout, runtime mesh generation with correct UV and normal recalculation, data-driven spawn tables (ScriptableObject-based weighted lists), and object pooling integration for spawned content. Ensures procedural systems are deterministic (seed-reproducible), allocation-safe, and aligned with GDD content distribution specs.

Procedural systems multiply content without proportional art/design cost. Deterministic seed-based generation enables bug reproduction and level sharing. Data-driven spawn tables allow designers to adjust content distribution without code changes.

Runtime mesh generation without `Mesh.RecalculateNormals()` produces visual artefacts. Uncontrolled allocation per-frame in generators causes GC spikes. Non-seeded generation makes bugs non-reproducible. ScriptableObject spawn tables decouple spawn frequency from code.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new procedural generation system is being designed or implemented
* Runtime mesh is generated without `RecalculateNormals` or `RecalculateUVs`
* Spawn tables are hardcoded in MonoBehaviours instead of ScriptableObjects
* Generator uses `Random.Range` without a seeded `System.Random`
* Procedural content allocation is occurring per-frame (List.Add in Update)
* GDD specifies procedural level layout, terrain, or content distribution

### Do NOT use this skill for:

* Hand-authored prefab placement — use prefab-scene-spec
* Static terrain authored in the terrain editor — design concern
* NPC AI decisions — use architecture-patterns

**Execution Context Details:**
Runs after code-standards and architecture-patterns. Flags performance-optimization when runtime mesh generation or per-frame allocation is detected.

---

## Inputs

**Required inputs:**

* **Generation requirements** — What is being generated: terrain, dungeon, spawn events, mesh
* **Seed parameters** — How the seed is provided: player input, level ID, timestamp

**Optional inputs:**

* **Content spec** — GDD section defining content distribution (enemy frequency, loot rarity)
* **Existing generators** — Prior procedural systems to validate alignment with DA-7

**Documents/Context needed:**

* **GDD procedural section** — Designer intent for content distribution and generation rules
* **Content distribution spec** — Spawn weights, biome rules, rarity tiers

---

## Outputs

**Primary outputs:**

* **Procedural system assessment** — Pass/Fail/Needs Review per generation category
* **Generated code scaffold** — Seeded generator, ScriptableObject spawn table, or mesh builder skeleton
* **Violations list** — Unseeded random, missing RecalculateNormals, per-frame allocation
* **Approval status** — Whether procedural system meets standards

**Output format:**

* Structured report with sections: Determinism, Mesh Generation, Spawn Tables, Allocation Safety
* Code scaffolds for identified pattern gaps

**Skill flags (if applicable):**

* Flags `performance-optimization` when runtime mesh or per-frame allocation detected

---

## Preconditions

**Conditions that must be met before execution:**

* code-standards has passed for generator scripts
* architecture-patterns has validated cross-system communication
* GDD procedural section has been consulted per design-reference

**Validation checks:**

* [ ] Seed source is documented (level ID, player input, or deterministic timestamp)
* [ ] GDD consulted for content distribution rules
* [ ] ObjectPool<T> integration considered for spawned objects

---

## Step-by-Step Execution Procedure

### Step 1: Validate Determinism (Seeded Generation)

**Questions to answer:**
- Is all random generation driven by a seeded `System.Random` or Unity's `Random.InitState(seed)`?

**Actions:**
- [ ] Check for `UnityEngine.Random.Range` calls without prior `Random.InitState(seed)`
- [ ] Check for `System.Random` instantiated without a seed parameter
- [ ] Verify seed is stored and logged for reproduction
- [ ] Verify same seed produces identical output across runs

**Red flags / Warning signs:**
- `Random.Range(0, enemies.Count)` with no `InitState` — non-reproducible
- `new System.Random()` with no seed — time-seeded, non-deterministic

**Decision points:**
- Unseeded random: warn, provide seeded pattern with stored seed
- Random.InitState called but seed not logged: warn, recommend seed persistence

---

### Step 2: Validate Runtime Mesh Generation

**Questions to answer:**
- Is generated mesh data valid and complete before assignment to MeshFilter?

**Actions:**
- [ ] Verify `mesh.vertices`, `mesh.triangles` assigned before `RecalculateNormals()`
- [ ] Verify `mesh.RecalculateNormals()` called after all geometry is set
- [ ] Verify `mesh.RecalculateBounds()` called for correct frustum culling
- [ ] Check UV assignment for textured meshes
- [ ] Verify NativeArray used for Burst-compatible generation (if DOTS path)

**Red flags / Warning signs:**
- `mesh.triangles` assigned before `mesh.vertices` — causes index out of bounds
- No `RecalculateNormals()` — flat or inverted lighting
- `new Vector3[count]` allocated every frame — GC pressure

**Decision points:**
- Missing RecalculateNormals: warn, add call
- Per-frame allocation: flag performance-optimization

---

### Step 3: Validate Spawn Tables

**Questions to answer:**
- Are spawn weights defined in ScriptableObject assets rather than hardcoded in code?

**Actions:**
- [ ] Identify spawn selection logic — weighted random, frequency tables, biome rules
- [ ] Verify spawn weights are in a `[CreateAssetMenu]` ScriptableObject with `[Range]` weights
- [ ] Verify spawn selection uses the seeded random from Step 1
- [ ] Flag magic numbers: `if (Random.value < 0.15f)` without named constant or SO field

**Red flags / Warning signs:**
- `spawnChance = 0.25f` hardcoded in MonoBehaviour — designer cannot adjust without code change
- Parallel arrays for prefab+weight instead of `[System.Serializable]` struct

**Decision points:**
- Hardcoded weights: warn, provide SpawnTable ScriptableObject pattern
- Parallel array: warn, consolidate into serializable struct with weight and prefab fields

---

### Step 4: Validate Allocation Safety

**Questions to answer:**
- Does the generator allocate memory on the hot path (Update, per-frame generation)?

**Actions:**
- [ ] Identify generator invocation frequency — once at level load, per chunk, or per frame
- [ ] Flag `new List<T>()`, `new T[]`, LINQ `.ToList()` on per-frame or per-chunk paths
- [ ] Verify spawned objects use `ObjectPool<T>` rather than `Instantiate` at runtime
- [ ] Verify mesh generation reuses existing `Mesh` object rather than creating new

**Red flags / Warning signs:**
- `Instantiate(prefab)` called in Update for spawn events — bypasses pool
- `new List<Vector3>()` per generation call — should be pre-allocated field

**Decision points:**
- Instantiate on hot path: warn, provide ObjectPool<T> integration
- New collection on hot path: warn, pre-allocate in Awake or use stack allocation

---

### Final Step: Generate Procedural Content Report

```markdown
## Procedural Content Report

**Target:** [GeneratorClassName.cs or System Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Determinism
[Finding — seeded random, seed storage]

### Mesh Generation
[Finding — vertex/triangle order, RecalculateNormals, bounds]

### Spawn Tables
[Finding — ScriptableObject weights vs. hardcoded values]

### Allocation Safety
[Finding — per-frame allocation, Instantiate vs. pool]

### Overall Assessment
- ✅ PASS: All procedural conventions met
- ❌ FAIL: Unseeded random or missing RecalculateNormals
- ⚠️ NEEDS REVIEW: Hardcoded spawn weights or pool missing

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce seeded, reproducible random generation — all `Random` usage must be seed-controlled
2. Validate runtime mesh generation order: vertices → triangles → RecalculateNormals → RecalculateBounds
3. Require ScriptableObject spawn tables for designer-adjustable content distribution
4. Enforce ObjectPool<T> for spawned objects on hot paths
5. Flag per-frame allocation to performance-optimization

**Quality criteria:**

* Same seed always produces identical level/content output
* No per-frame allocation in active generators
* Spawn weights editable by designers via Inspector without code changes

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: Generator classes have one responsibility — generate data; consumers handle placement
  - In practice: `DungeonLayoutGenerator` returns room data; `DungeonBuilder` instantiates prefabs from that data

* **DA-5: Abstraction Stability**
  - Applies: `IProceduralGenerator<T>` interface allows swapping generation algorithms without changing consumers
  - In practice: Dungeon generator replaced with new algorithm without touching `DungeonBuilder`

### Performance & Complexity Rules

* **PC-1: Allocation Budget**
  - Applies: No runtime allocation on per-frame or per-chunk generation paths
  - In practice: Pre-allocate vertex array in Awake; reuse across generation calls

* **PC-4: Performance Budget**
  - Applies: Mesh generation and spawn resolution stay within frame budget
  - In practice: Chunked generation spread across frames using coroutines or Jobs

---

## Tradeoff Handling

### Tradeoff 1: Full Determinism vs. Perceived Variety

**Scenario:** Game design wants "random" variation every session but also needs bug reproduction.

**Default stance:** Use seeded generation with session-unique seed (timestamp or player ID hash). Store and log the seed. Allow design to disable seed persistence for "pure random" mode — document via DT-1.

---

### Tradeoff 2: Burst Mesh Generation vs. Managed Mesh API

**Scenario:** Large terrain mesh benefits from Burst-compiled Job but requires NativeArray and DOTS context.

**Default stance:** Burst + NativeArray for large meshes (>10k verts) where performance profiling shows managed allocation bottleneck. Require profiling data (PC-4) before introducing DOTS dependency on a non-DOTS project.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Unseeded Generator in Shipped Build

**Trigger:** Generator uses `UnityEngine.Random` without `InitState` and the system is in a production branch.

**Action:**
- BLOCK merge
- Provide seeded pattern with seed serialized to save data
- Log as PC-4 risk — non-reproducible bugs in production

---

### Escalation Scenario 2: Per-Frame Mesh Rebuild

**Trigger:** `mesh.vertices = new Vector3[count]` called in Update every frame.

**Action:**
- Flag performance-optimization
- Suggest dirty-flag pattern — rebuild only when input data changes
- Suggest NativeArray reuse if Burst path is warranted

---

### When to halt execution:

* GDD procedural section not consulted — cannot validate content distribution alignment
* No generation code exists yet — scaffold only, no violation check possible

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards and architecture-patterns. Flags performance-optimization when runtime mesh or per-frame allocation is detected. Cooperates with prefab-scene-spec when procedurally placed content uses authored prefabs.

**Integration workflow:**
1. code-standards and architecture-patterns pass
2. Orchestrator invokes procedural-content on generator scripts
3. Skill validates determinism, mesh, spawn tables, allocation
4. If per-frame allocation flagged: performance-optimization runs
5. After pass: prefab-scene-spec may validate spawned prefab correctness

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Per-frame allocation or runtime mesh rebuild | performance-optimization | Allocation/performance budget violation |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Generator scripts must meet C# standards
* **architecture-patterns** — Spawn events propagated via Event Channels; generator results consumed via service interfaces
* **performance-optimization** — Allocation and mesh generation performance standards

**Skills this skill cooperates with:**

* **prefab-scene-spec** — Procedurally placed content uses authored prefabs; validates prefab correctness
* **design-reference** — GDD procedural and content distribution sections must be consulted

**Skills this skill may invoke/flag:**

* **performance-optimization** — Runtime mesh, per-frame allocation, or Instantiate on hot path

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block unseeded Random — non-determinism is a debug/QA risk
* [ ] Enforce GDD consultation for content distribution — design-reference must be cited
* [ ] Log algorithm choice (noise function, spawn strategy) via DT-1 when formally adopted
* [ ] Flag per-frame allocation to performance-optimization — never ignore
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Seed strategy and persistence approach documented via DT-1
* Allocation violations logged as technical debt via MF-2

---

## Example Use Cases

### Example 1: Unseeded Random in Dungeon Generator

**Scenario:** `DungeonGenerator.Generate()` uses `Random.Range` throughout with no `InitState` call.

**Execution steps:**
1. Detect unseeded `Random.Range` — non-deterministic
2. Block: provide `Random.InitState(seed)` at generation entry point
3. Recommend: expose `int seed` parameter; log to console for reproduction

**Result:** ❌ FAIL

---

### Example 2: Hardcoded Enemy Spawn Weights

**Scenario:** `SpawnManager` has `if (Random.value < 0.15f) SpawnElite()` in code.

**Execution steps:**
1. Detect magic spawn probability `0.15f` hardcoded
2. Warn: extract to `SpawnTableSO` with `[Range(0,1)]` weight field
3. Provide `EnemySpawnEntry { Prefab, Weight }` struct and `SpawnTableSO` pattern

**Result:** ⚠️ NEEDS REVIEW

---

### Example 3: Missing RecalculateNormals

**Scenario:** Terrain mesh generated procedurally but lighting appears flat/incorrect.

**Execution steps:**
1. Inspect mesh generation code — `mesh.vertices` and `mesh.triangles` set
2. No `RecalculateNormals()` call found
3. Flag: add after `mesh.triangles` assignment; also add `RecalculateBounds()`

**Result:** ❌ FAIL

---

### Example 4: Fully Compliant Procedural Generator

**Scenario:** `ChunkGenerator` uses `System.Random(seed)`, pre-allocates vertex arrays in Awake, calls RecalculateNormals, uses ScriptableObject spawn table, spawns via ObjectPool<T>.

**Result:** ✅ PASS

---

### Example 5: Per-Frame Instantiate for Spawn Events

**Scenario:** `WaveManager.Update()` calls `Instantiate(enemyPrefab)` when spawn timer fires.

**Execution steps:**
1. Detect `Instantiate` on Update hot path
2. Flag: use `ObjectPool<EnemyController>` for all runtime spawns
3. Flag performance-optimization for review

**Result:** ⚠️ NEEDS REVIEW (performance-optimization flagged)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `Random.Range(min, max)` without `Random.InitState(seed)` — non-deterministic
✅ **Correct approach:** `Random.InitState(seed)` at generation entry; store seed for reproduction

❌ **Anti-pattern 2:** `mesh.triangles = ...` before `mesh.vertices = ...` — index out of bounds
✅ **Correct approach:** Assign vertices first, then triangles, then RecalculateNormals + RecalculateBounds

❌ **Anti-pattern 3:** Hardcoded spawn probability `0.15f` in MonoBehaviour
✅ **Correct approach:** `[Range(0,1)] public float weight` in SpawnTableSO ScriptableObject

❌ **Anti-pattern 4:** `Instantiate(prefab)` in Update for runtime spawning
✅ **Correct approach:** `ObjectPool<T>.Get()` — warm pool during load, return on despawn

❌ **Anti-pattern 5:** `new List<Vector3>()` per generation call — GC spike
✅ **Correct approach:** Pre-allocate `_vertices = new Vector3[maxCount]` in Awake; reuse

❌ **Anti-pattern 6:** Generator class handles both generation and placement — two responsibilities
✅ **Correct approach:** Generator returns data (room positions, prefab types); Builder places objects

---

## Non-Goals

* ❌ Does not design content distribution rules — use design-reference (GDD)
* ❌ Does not author terrain in the Unity Terrain Editor — design concern
* ❌ Does not validate NPC AI decisions — use architecture-patterns
* ❌ Does not validate shader generation — use shader-vfx-spec

---

## Notes for LLM Implementation

1. **Determinism is the first check** — unseeded generation is always a block; non-reproducible bugs cost disproportionate debug time
2. **Mesh generation order matters** — vertices → triangles → RecalculateNormals is the fixed sequence; deviation causes engine errors or visual artefacts
3. **ScriptableObject spawn tables are the correct data-driven pattern** — not config files, not CSV, not hardcoded arrays
4. **Flag performance-optimization proactively** — do not assess allocation budgets in depth; defer to the dedicated skill
5. **GDD consultation is mandatory before validating content distribution** — design intent overrides engineering preference

---

## Metadata Summary

```yaml
name: procedural-content
category: Content Generation
priority: Medium
depends_on: [code-standards, architecture-patterns, performance-optimization]
flags_skills: [performance-optimization]
rules_applied: [DA-1, DA-5, PC-1, PC-4]
documents_needed: [gdd_procedural_section, existing_generators, content_distribution_spec]
tags: [unity, procedural, mesh, perlin-noise, spawn-tables, runtime-generation]
```

**Key relationships:**
- Depends on: code-standards, architecture-patterns, performance-optimization
- Flags: performance-optimization (runtime mesh, per-frame allocation)
- Governed by: DA-1 (SRP), DA-5 (interface stability), PC-1 (allocation), PC-4 (performance budget)
