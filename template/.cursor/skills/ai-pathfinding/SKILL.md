---
name: ai-pathfinding
description: "Use when task requires On NavMesh/AI scripts. Validates baking setup, destination hygiene, arrival detection, and decision decoupling."
---

# Ai Pathfinding

name:ai-pathfinding|pri:M|deps:[code-standards]|flags:[performance-optimization,architecture-patterns]|rules:[DA-1,DA-3,DA-7,PC-4]

SCOPE: On NavMesh/AI scripts. Validates baking setup, destination hygiene, arrival detection, and decision decoupling.

ENFORCE: NavMeshSurface for baked environments (com.unity.ai.navigation package); SetDestination rate-limited ≤5/s or on target-change only; NavMesh.SamplePosition before SetDestination; NavMeshObstacle+Carve on dynamic blockers; AI decisions in StateMachine<T>+IState per architecture-patterns; sensing separated from NavMeshAgent movement.

PROHIBIT: SetDestination per-frame without change-check; transform.position for arrival detection (use remainingDistance≤stoppingDistance); FindObjectOfType in Update; monolithic AI class.

ON_VIOLATION: setdest_per_frame→warn→flag:performance-optimization. transform_arrival→warn→remainingDistance. monolithic_ai→warn→flag:architecture-patterns. no_sample→warn→SamplePosition.

## Reference
- See [reference.md](reference.md) for distilled source details.
