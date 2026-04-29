---
name: physics-systems
description: "Use when task requires After code-standards on physics scripts. Enforces component choice, query masks, mutation timing, and collision semantics."
---

# Physics Systems

name:physics-systems|pri:H|deps:[code-standards]|flags:[performance-optimization]|rules:[DA-1,DA-5,DA-7,PC-4,MF-5]

SCOPE: After code-standards on physics scripts. Enforces component choice, query masks, mutation timing, and collision semantics.

ENFORCE: Rigidbody for simulated objects; CharacterController for player-driven movement without full simulation; all Physics queries include LayerMask; PhysicMaterial for non-default friction/bounciness; AddForce/MovePosition in FixedUpdate only; kinematic Rigidbody via MovePosition not transform; OnTriggerEnter for overlap-only, OnCollisionEnter for physics-response.

PROHIBIT: transform.position on non-kinematic Rigidbody; AddForce in Update; queries without LayerMask; CharacterController+Rigidbody on same GameObject.

ON_VIOLATION: transform_on_rb→BLOCK→MovePosition. force_in_update→warn→FixedUpdate. query_no_mask→warn→flag:performance-optimization. cc_rb_conflict→BLOCK→DT-3.

## Reference
- See [reference.md](reference.md) for distilled source details.
