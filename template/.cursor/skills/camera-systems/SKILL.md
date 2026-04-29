---
name: camera-systems
description: "Use when task requires On camera/Cinemachine scripts. Enforces Brain setup, Priority switching, ImpulseSource shake, target assignment, and post-processing alignment."
---

# Camera Systems

name:camera-systems|pri:H|deps:[code-standards]|flags:[performance-optimization]|rules:[DA-1,DA-5,DA-7,PC-4,MF-5]

SCOPE: On camera/Cinemachine scripts. Enforces Brain setup, Priority switching, ImpulseSource shake, target assignment, and post-processing alignment.

ENFORCE: One CinemachineBrain on Main Camera only; no script writes Camera.transform while CinemachineBrain is active; camera switching via Priority not vcam.enabled; screen shake via CinemachineImpulseSource.GenerateImpulse with ImpulseListener on affected vcams; explicit Follow/LookAt targets on all virtual cameras; FreeLook input via CinemachineInputProvider not raw Input.GetAxis; post-processing Volume layer included in camera Volume Mask.

PROHIBIT: Camera.main.transform.position/rotation assigned while CinemachineBrain active; vcam.enabled toggled for camera switching; screen shake via transform-offset coroutine; CinemachineFreeLook with raw Input.GetAxis strings; Post-processing Volume on layer excluded from camera mask.

ON_VIOLATION: transform_write_active_brain→BLOCK→vcam_config. enabled_switching→warn→Priority. coroutine_shake→warn→CinemachineImpulse. null_follow_target→warn→assign_target. volume_mask_mismatch→warn→align_layer.

## Reference
- See [reference.md](reference.md) for distilled source details.
