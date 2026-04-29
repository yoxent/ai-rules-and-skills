# Skill Human Spec: Audio Systems

```yaml
---
name: audio-systems
description: Enforces AudioMixer routing, spatial audio configuration, audio event architecture, SFX pooling, and AudioSource lifecycle in Unity
version: 1.0.0
category: Architecture
tags: [unity, audio, audiomixer, audiosource, spatial, sfx, pooling]
priority: High
depends_on: [code-standards, architecture-patterns]
flags_skills: [performance-optimization]
inputs: [audio_scripts, audiomixer_asset, audiosource_configurations]
outputs: [violations_list, routing_recommendations, pooling_corrections]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-5  # Avoid Overengineering
  - DA-7  # Architectural Consistency
  - PC-4  # Performance Budget
  - MF-5  # Reliability Rule
documents_needed: [gdd_audio_section, audiomixer_group_layout]
execution_context: On scripts managing audio playback, AudioSource configuration, or AudioMixer control; after code-standards and architecture-patterns
---
```

---

# Skill: Audio Systems

## Purpose

Validates Unity audio implementation: AudioMixer group routing, spatial audio configuration, ScriptableObject-based audio event architecture, SFX pooling, and AudioSource lifecycle management. Prevents common audio bugs — unrouted sources, Play/Stop called without pooling, exposed parameter name mismatches, and 3D audio with incorrect rolloff.

---

## When to Use

**Triggers:**
- Script creates, plays, or stops an AudioSource
- AudioMixer exposed parameter modified via script
- Spatial (3D) audio configured on an AudioSource
- New sound category introduced (SFX, Music, UI, Ambience)
- Audio triggered from gameplay events

**Do NOT use for:** FMOD/Wwise native plugin integration (different API); video player audio passthrough; audio authoring (DAW/clip editing).

---

## Inputs & Outputs

**Inputs:** Audio scripts; AudioMixer asset; AudioSource configurations on prefabs
**Outputs:** Violations list; routing recommendations; pool and lifecycle corrections
**Flags:** `performance-optimization` when AudioSource.PlayOneShot or Instantiate used for high-frequency SFX

---

## Execution Steps

### 1 — AudioMixer Routing
- Every AudioSource.outputAudioMixerGroup set — never left as None (plays to Master unclassified)
- Groups: Master → Music, SFX, UI, Ambience (minimum); expand per GDD audio section
- Exposed parameters named with prefix convention (e.g. MusicVolume, SFXVolume) — document in AudioMixer asset
- AudioMixer.SetFloat uses the exact exposed parameter name — flag string mismatches

### 2 — Spatial Audio
- AudioSource.spatialBlend: 0=2D (music, UI), 1=3D (world SFX, ambience)
- 3D sources: rolloffMode set explicitly (Logarithmic for realistic; Linear for designed spread)
- MinDistance and MaxDistance set per sound type — not left at Unity defaults (1, 500)
- 3D audio on UI AudioSource → warn (UI is 2D by definition)

### 3 — Audio Event Architecture
- Audio triggered by gameplay → ScriptableObject AudioEventChannel (Raise/Register pattern per architecture-patterns)
- AudioSource not directly referenced cross-system — audio system subscribes to channels
- One AudioManager registered via ServiceLocator handles playback routing

### 4 — SFX Pooling
- High-frequency SFX (footsteps, impacts, projectiles) use ObjectPool<AudioSource> — not PlayOneShot or Instantiate
- PlayOneShot acceptable for low-frequency, non-overlapping SFX only
- AudioSource returned to pool in OnAudioClipEnd callback or after clip.length

### 5 — AudioSource Lifecycle
- AudioSource.Play() called only after clip assigned; clip null-checked before Play
- AudioSource.Stop() called in OnDisable/OnDestroy for looping sources
- Looping music sources: single persistent AudioSource on DontDestroyOnLoad object — not re-instantiated per scene

---

## Core Responsibilities

1. Require AudioMixer group routing on every AudioSource
2. Enforce correct spatialBlend and rolloff configuration for 3D sources
3. Enforce ScriptableObject AudioEventChannel for gameplay-triggered audio
4. Require ObjectPool for high-frequency SFX
5. Enforce AudioSource Stop on looping sources in OnDisable/OnDestroy

---

## Rules Applied

- **DA-1:** Audio playback is a service — gameplay classes raise events, AudioManager handles playback
- **DA-5:** Don't create AudioMixer groups or exposed parameters not needed by current GDD scope
- **DA-7:** All audio triggered via consistent channel pattern — no direct AudioSource.Play() cross-system
- **PC-4:** Instantiate+Destroy per SFX at high frequency causes GC spikes — pool required
- **MF-5:** Looping source not stopped on destroy continues playing in background — must block

---

## Tradeoffs

**PlayOneShot vs ObjectPool for medium-frequency SFX:** PlayOneShot is simpler and acceptable if frequency <10/s and no positional audio needed. Pool required at higher frequency or for 3D positioned SFX.

**AudioEventChannel vs direct AudioManager call from UI:** UI may call AudioManager directly via ServiceLocator for simple button SFX — document as intentional DA-7 exception via DT-1.

---

## Escalation

| Situation | Action |
|---|---|
| AudioSource.outputAudioMixerGroup = None | warn → assign to correct mixer group |
| Looping AudioSource with no Stop in OnDisable | BLOCK → add Stop in OnDisable |
| High-frequency SFX via PlayOneShot or Instantiate | warn → flag:performance-optimization |
| Gameplay class holds direct AudioSource reference cross-system | warn → AudioEventChannel |
| AudioMixer.SetFloat with mismatched parameter name | warn → verify exposed parameter name |
| spatialBlend=1 on a UI AudioSource | warn → set spatialBlend=0 for UI |

---

## Anti-Patterns

❌ `AudioSource.outputAudioMixerGroup` left as None
✅ Assign to a named group (SFX, Music, UI, Ambience) in AudioMixer

❌ `Instantiate(sfxPrefab); Destroy(sfxPrefab, clip.length)` per impact event
✅ `ObjectPool<AudioSource>` — rent on impact, return after clip.length

❌ `_audioSource.spatialBlend = 1` on UI button sounds
✅ `_audioSource.spatialBlend = 0` for all UI/Music; `= 1` for world-positioned SFX

❌ `_audioSource.Play()` called directly from PlayerController
✅ `_jumpAudioEvent.Raise()` → AudioManager subscribes and handles playback

❌ `AudioMixer.SetFloat("MasterVol", value)` — hardcoded string
✅ `private const string MasterVolumeParam = "MasterVolume";` matching exposed parameter name exactly

❌ Music AudioSource re-instantiated on each scene load
✅ Single persistent AudioSource on DontDestroyOnLoad object; scene transitions cross-fade via AudioMixer snapshot

❌ Looping ambient AudioSource.Play() with no Stop in OnDisable
✅ `void OnDisable() { if (_audioSource.isPlaying) _audioSource.Stop(); }`

---

## Non-Goals

- FMOD or Wwise native plugin API
- Audio clip authoring / mixing in a DAW
- Video player audio passthrough configuration
- Audio compression format selection (→ build-pipeline consultation)

---

## LLM Notes

1. AudioMixer routing is always required — no exceptions for "quick" or "temp" audio
2. Looping source without Stop is a BLOCK — background audio playing after object destruction is a reliability failure (MF-5)
3. The AudioEventChannel pattern mirrors architecture-patterns — reuse the same ScriptableObject event infrastructure
4. Always confirm spatialBlend intent: 0 for UI/music, 1 for diegetic world sounds

---
