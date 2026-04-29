---
name: unity-engineer-performance-optimization
description: "Use when task requires On performance-sensitive scripts. Enforce ObjectPool, Addressables Release, StringBuilder for TMP, and Update loop assignment."
---

# Unity Engineer Performance Optimization

name:performance-optimization|pri:H|deps:[code-standards]|flags:[]|rules:[PC-1,PC-4,MF-5,DA-5]
SCOPE: On performance-sensitive scripts. Enforce ObjectPool, Addressables Release, StringBuilder for TMP, and Update loop assignment.
ENFORCE: ObjectPool<T> for Instantiate/Destroy on per-frame or high-frequency paths (DA-5: only flag when frequency warrants); Addressables.LoadAssetAsync handle stored as field, released via Addressables.Release in OnDestroy; StringBuilder via TMP_Text.SetText for text updated >~10x/second; physics in FixedUpdate, camera in LateUpdate.
PROHIBIT: Instantiate/Destroy in Update without pooling; fire-and-forget Addressables with no stored handle; string concat/interpolation assigned to TMP_Text.text per-frame; camera logic in FixedUpdate.
ON_VIOLATION: instantiate_in_update→BLOCK→pool_impl. unreleased_handle→BLOCK→release_in_ondestroy. string_hot→BLOCK→stringbuilder. physics_in_update→warn→fixedupdate.

## Reference
- See [reference.md](reference.md) for distilled source details.
