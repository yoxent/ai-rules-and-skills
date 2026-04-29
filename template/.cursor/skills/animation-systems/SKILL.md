---
name: animation-systems
description: "Use when task requires On Animator/character scripts. Enforces hash-based parameter access, blend tree config, root motion pairing, IK setup, and event callback hygiene."
---

# Animation Systems

name:animation-systems|pri:H|deps:[code-standards]|flags:[performance-optimization,architecture-patterns]|rules:[DA-1,DA-5,DA-7,PC-4,MF-5]

SCOPE: On Animator/character scripts. Enforces hash-based parameter access, blend tree config, root motion pairing, IK setup, and event callback hygiene.

ENFORCE: Cache Animator.StringToHash per parameter in Awake as static readonly int — no runtime string lookups; blend tree locomotion uses float speed/direction parameters not booleans; applyRootMotion explicitly set — root motion+CharacterController via OnAnimatorMove, root motion+Rigidbody disabled; OnAnimatorIK for IK goals with both SetIKPosition and SetIKPositionWeight; Animation Event methods invoke only — no game state access.

PROHIBIT: animator.SetFloat/SetBool/SetTrigger with raw string at runtime; root motion enabled alongside Rigidbody without OnAnimatorMove override; IK goal set without matching weight call; game logic inside Animation Event callbacks; Animator.GetCurrentAnimatorStateInfo().IsName() polled in Update.

ON_VIOLATION: raw_string_param→warn→StringToHash_pattern. rootmotion_rb_conflict→BLOCK→disable_rootmotion. ik_no_weight→warn→SetIKPositionWeight. logic_in_event→warn→flag:architecture-patterns. statename_poll→warn→parameter_driven.

## Reference
- See [reference.md](reference.md) for distilled source details.
