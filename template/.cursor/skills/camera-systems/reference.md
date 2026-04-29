# Skill Human Spec: Camera Systems

```yaml
---
name: camera-systems
description: Enforces Cinemachine virtual camera setup, CinemachineBrain configuration, camera switching, screen shake via CinemachineImpulse, and post-processing integration
version: 1.0.0
category: Architecture
tags: [unity, cinemachine, camera, virtualcamera, postprocessing, screenshake]
priority: High
depends_on: [code-standards]
flags_skills: [performance-optimization]
inputs: [camera_scripts, cinemachine_virtual_cameras, post_processing_volumes]
outputs: [violations_list, camera_setup_recommendations, transition_corrections]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-5  # Avoid Overengineering
  - DA-7  # Architectural Consistency
  - PC-4  # Performance Budget
  - MF-5  # Reliability Rule
documents_needed: [gdd_camera_section]
execution_context: On scripts or prefabs managing camera behaviour; after code-standards
---
```

---

# Skill: Camera Systems

## Purpose

Validates Unity Cinemachine camera implementation: virtual camera lifecycle, CinemachineBrain configuration, camera switching via Priority, screen shake via CinemachineImpulse, and post-processing volume integration. Prevents the most common camera bugs — direct transform manipulation while CinemachineBrain is active, toggling camera enabled instead of Priority, and manual transform-jitter screen shake.

---

## When to Use

**Triggers:**
- Script modifies camera transform directly
- New CinemachineVirtualCamera or CinemachineFreeLook created
- Camera switching or blending logic implemented
- Screen shake or camera feedback effect needed
- Post-processing applied to the camera

**Do NOT use for:** Non-Cinemachine camera rigs (pure transform-driven); VR camera rigs managed by XR Plugin; 2D camera without Cinemachine (simple follow scripts).

---

## Inputs & Outputs

**Inputs:** Camera scripts; Cinemachine Virtual Camera prefabs; Post Processing Volume configurations
**Outputs:** Violations list; Cinemachine setup recommendations; transition and shake corrections
**Flags:** `performance-optimization` for per-frame camera transform reads/writes when Cinemachine is active

---

## Execution Steps

### 1 — CinemachineBrain Setup
- One CinemachineBrain on the Main Camera — not on child objects or secondary cameras
- CinemachineBrain.m_UpdateMethod set explicitly (SmartUpdate default; FixedUpdate for physics-following cameras)
- Verify no script writes to Camera.transform.position/rotation while CinemachineBrain is active on same camera

### 2 — Virtual Camera Configuration
- Each CinemachineVirtualCamera has explicit Priority value — not left at default 10
- Follow and LookAt targets set explicitly; null targets produce console warnings per-frame → flag
- CinemachineFreeLook axis input wired via CinemachineInputProvider, not raw Input.GetAxis strings

### 3 — Camera Switching
- Switch active camera via Priority (higher Priority = active) — not via vcam.enabled = true/false
- CinemachineBrain handles blending automatically; custom blend curves set in CinemachineBrain.m_CustomBlends asset
- Direct Camera.main replacement (assigning new Camera to Camera.main) prohibited when Cinemachine is active

### 4 — Screen Shake / Camera Feedback
- Screen shake via CinemachineImpulseSource.GenerateImpulse() — not via Camera.transform offset coroutine
- CinemachineImpulseListener added to each virtual camera that should react
- Impulse signal shape set per feedback type (explosion=rumble, hit=bump, landing=thud)

### 5 — Post-Processing
- Post-processing via Volume component on a layer the camera's Volume Mask includes
- Global Volume for scene-wide effects; Local Volume (with collider trigger) for zone-specific
- Post-processing profile assets shared via reference — not duplicated per scene
- Camera stacking (URP): Overlay cameras assigned to Base camera's Camera Stack list

---

## Core Responsibilities

1. Block direct camera transform writes when CinemachineBrain is active
2. Enforce Priority-based camera switching (not enabled/disabled)
3. Require CinemachineImpulse for all screen shake — no transform-jitter coroutines
4. Enforce explicit Follow/LookAt targets on virtual cameras
5. Validate post-processing Volume layer mask alignment

---

## Rules Applied

- **DA-1:** Camera behaviour is configuration-driven (Cinemachine assets); game scripts raise events, not drive transforms
- **DA-5:** Don't add virtual cameras not required by GDD camera section
- **DA-7:** All camera transitions use CinemachineBrain blending consistently — no mixed approaches
- **PC-4:** Per-frame camera transform reads with active CinemachineBrain causes redundant overwrite
- **MF-5:** Transform writes competing with CinemachineBrain produce unpredictable jitter — must block

---

## Tradeoffs

**Cinemachine vs pure script camera for simple 2D game:** Pure follow script acceptable for 2D games with no blending, screen shake, or dynamic targeting. Document as intentional DA-7 exception. Once blending or shake is needed, migrate to Cinemachine.

**Multiple CinemachineBrains for split-screen:** Legitimate use case — one Brain per split-screen camera. Verify each Brain targets its own set of virtual cameras via layer masking.

---

## Escalation

| Situation | Action |
|---|---|
| Script writes Camera.transform while CinemachineBrain active | BLOCK → remove transform write; use vcam configuration |
| vcam.enabled = true/false for switching | warn → use Priority instead |
| Screen shake via transform coroutine | warn → provide CinemachineImpulse pattern |
| VirtualCamera Follow/LookAt target null | warn → assign target or disable follow/aim modules |
| Post-processing Volume not on camera's Volume Mask layer | warn → align layer mask |

---

## Anti-Patterns

❌ `Camera.main.transform.position = targetPos` while CinemachineBrain is active
✅ Set `_virtualCamera.Follow = target` and let CinemachineBrain drive the camera

❌ `_vcamA.enabled = false; _vcamB.enabled = true` for camera switching
✅ `_vcamA.Priority = 9; _vcamB.Priority = 11` — CinemachineBrain blends automatically

❌ `StartCoroutine(ShakeCamera(0.3f, 0.1f))` — manual transform offset loop
✅ `_impulseSource.GenerateImpulse(force)` with CinemachineImpulseListener on the virtual camera

❌ CinemachineFreeLook wired with `Input.GetAxis("Mouse X")` directly
✅ CinemachineInputProvider component with InputActionReference from the Input System

❌ Post-processing Volume on Default layer while camera Volume Mask excludes Default
✅ Dedicated PostProcessing layer; add to camera Volume Mask and Volume GameObject layer

❌ Screen shake impulse generated every frame while hit state is active
✅ GenerateImpulse() once on hit event — impulse decay handles duration automatically

---

## Non-Goals

- VR camera rigs (managed by XR Plugin Management)
- Non-Cinemachine pure-script cameras (consult conversationally)
- Authoring Cinemachine tracks in Timeline (→ timeline consultation)
- Render texture / security camera setups (architecture-patterns for system design)

---

## LLM Notes

1. Direct camera transform write with active CinemachineBrain is a BLOCK — the conflict produces frame-by-frame jitter that's hard to debug
2. Priority switching is non-obvious to developers coming from other engines — always explain the pattern when warning
3. CinemachineImpulse requires BOTH ImpulseSource (generates) and ImpulseListener (on vcam) — missing listener means no shake effect
4. Post-processing layer mask misalignment is silent — no error, effect just doesn't appear

---
