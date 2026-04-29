---
name: procedural-content
description: "Use when task requires After code-standards on procedural generators. Validates seeded determinism, mesh generation order, SpawnTable SOs, and allocation."
---

# Procedural Content

name:procedural-content|pri:M|deps:[code-standards,architecture-patterns,performance-optimization]|flags:[performance-optimization]|rules:[DA-1,DA-5,PC-1,PC-4]
SCOPE: After code-standards on procedural generators. Validates seeded determinism, mesh generation order, SpawnTable SOs, and allocation.
ENFORCE: All random via seeded System.Random(seed) or Random.InitState(seed), seed stored/logged; mesh order: vertices→triangles→RecalculateNormals()→RecalculateBounds(); spawn weights in [CreateAssetMenu] ScriptableObject with [Range] weight fields and serializable structs; ObjectPool<T> for runtime-spawned objects; pre-allocate collections in Awake for reuse; GDD procedural section consulted per design-reference.
PROHIBIT: Random.Range or new System.Random() without seed; mesh.triangles before mesh.vertices; hardcoded spawn probabilities in MonoBehaviour; Instantiate on per-frame or per-spawn path; new List<T>/new T[] per Update; generator class responsible for both data generation and object placement.
ON_VIOLATION: unseeded→BLOCK→InitState_pattern. mesh_order→warn→correct_sequence. hardcoded_weights→warn→SpawnTableSO. instantiate_hotpath→warn→ObjectPool→flag:performance-optimization. per_frame_alloc→warn→flag:performance-optimization.

## Reference
- See [reference.md](reference.md) for distilled source details.
