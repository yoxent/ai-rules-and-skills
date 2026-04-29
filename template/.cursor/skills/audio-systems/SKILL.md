---
name: audio-systems
description: "Use when task requires On audio scripts and AudioSource configurations. Enforces mixer routing, spatial config, event architecture, SFX pooling, and source lifecycle."
---

# Audio Systems

name:audio-systems|pri:H|deps:[code-standards,architecture-patterns]|flags:[performance-optimization]|rules:[DA-1,DA-5,DA-7,PC-4,MF-5]

SCOPE: On audio scripts and AudioSource configurations. Enforces mixer routing, spatial config, event architecture, SFX pooling, and source lifecycle.

ENFORCE: Every AudioSource.outputAudioMixerGroup assigned to a named mixer group; spatialBlend=0 for UI/music, =1 for world-positioned SFX; 3D sources have explicit rolloffMode, minDistance, maxDistance; gameplay-triggered audio via ScriptableObject AudioEventChannel per architecture-patterns; high-frequency SFX (>10/s or positional) via ObjectPool<AudioSource>; looping AudioSource stopped in OnDisable/OnDestroy; AudioMixer.SetFloat parameter name matches exposed parameter exactly.

PROHIBIT: AudioSource.outputAudioMixerGroup left as None; Instantiate/Destroy per-SFX on high-frequency paths; spatialBlend=1 on UI AudioSource; direct AudioSource.Play() called cross-system from gameplay class; looping source with no Stop on disable.

ON_VIOLATION: no_mixer_group→warn→assign_group. looping_no_stop→BLOCK→OnDisable_Stop. hf_sfx_no_pool→warn→flag:performance-optimization. cross_system_direct_play→warn→AudioEventChannel. spatial_ui→warn→spatialBlend_0.

## Reference
- See [reference.md](reference.md) for distilled source details.
