---
name: dots-ecs
description: "Use when task requires On DOTS/ECS code. Enforce struct ISystem+BurstCompile, IJobEntity in/ref, and correct NativeArray allocators."
---

# Dots Ecs

name:dots-ecs|pri:M|deps:[code-standards]|flags:[performance-optimization]|rules:[DA-1,PC-1,PC-4,MF-5]
SCOPE: On DOTS/ECS code. Enforce struct ISystem+BurstCompile, IJobEntity in/ref, and correct NativeArray allocators.
ENFORCE: [BurstCompile] on ISystem struct declaration and OnUpdate; partial struct on all IJobEntity; in for read-only component access, ref for write; Allocator by lifetime (Temp=single-frame, TempJob=job, Persistent=long-lived); Dispose all Persistent collections in system cleanup; reject managed types (List, string, class) inside Burst methods.
PROHIBIT: Class SystemBase on hot-path without documented justification; missing [BurstCompile] on performance-critical OnUpdate; Allocator.Temp in scheduled jobs; Persistent NativeArray without Dispose; managed exceptions or Debug.Log inside Burst.
ON_VIOLATION: missing_burst→BLOCK. temp_in_job→BLOCK→use_tempjob. persistent_no_dispose→BLOCK→flag:performance-optimization. managed_in_burst→BLOCK→native_equivalent. systembase_hotpath→warn→justification.

## Reference
- See [reference.md](reference.md) for distilled source details.
