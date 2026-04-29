# Skill Human Spec
# File: shader-vfx-spec-docs.md
# Purpose: Human-readable comprehensive documentation
# NEVER loaded into agent context — for human review, authoring, and maintenance only

---

```yaml
---
name: shader-vfx-spec
description: Generates Unity Shader Graph/HLSL or VFX Graph specifications with performance targets. No compiled output.
version: 1.0.0
category: Content Generation
tags: [unity, shader, vfx, urp, hlsl, shader-graph, vfx-graph, performance, mobile, console]
priority: High

depends_on: [design-reference, performance-optimization]
flags_skills: [performance-optimization, architecture-patterns]

inputs: [effect-description, shader-type, performance-target, platform-constraints]
outputs: [shader-spec-json, node-graph-description, performance-notes]

rules_applied:
  - PC-4   # Performance Budget — all specs must include a named performance target and respect platform constraints
  - DA-5   # Avoid Overengineering — prefer cheaper shader operations; avoid speculative complexity
  - PS-3   # Scope Control — produce specifications only; do not modify materials or produce compiled artifacts
  - DT-1   # Tradeoff Logging — document performance tradeoffs when quality vs cost conflicts arise
  - PS-2   # Risk Communication — surface performance risks before finalizing a spec that exceeds budget

documents_needed: [design-reference, performance-optimization-guide]

execution_context: Stage 4 / Content generation. Produces shader and VFX effect specifications for implementation by rendering engineers or artists. Runs after design intent is defined; before compiled asset authoring.
---
```

---

# Skill: Shader & VFX Spec

---

## Purpose

**What this skill does:**
Generates detailed, structured specifications for Unity shaders and visual effects. This includes Shader Graph node descriptions, HLSL-style pass definitions, and VFX Graph context descriptions (spawn, initialize, update, output). All output is specification-level — human and engineer readable, not compiled bytecode or platform binaries.

Enables rapid iteration on visual effect intent without requiring immediate rendering engineer availability. Well-structured specs reduce implementation ambiguity, lower revision cycles, and give artists and engineers a shared reference that bridges design intent and technical execution.

Provides rendering engineers with structured, performance-aware specifications that include node topology, property definitions, operation costs, and explicit platform targets — reducing interpretation time and preventing performance regressions from over-complex effects.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A visual effect or shader needs to be designed for a Unity URP project
* A Shader Graph node structure needs to be specified before an artist implements it
* An HLSL-style shader pass needs to be described for a rendering engineer
* A VFX Graph effect (particle, simulation, or post-process) needs a structured spec
* An existing effect's performance is a concern and a spec for a lower-cost alternative is needed
* A post-process effect needs to be specified for a URP renderer feature
* Platform-specific performance targets need to be documented for an effect

### Do NOT use this skill for:

* Producing compiled shaders, shader bytecode, or platform-specific binaries — output is spec only
* Modifying existing materials, material instances, or their property values
* Writing Unity C# Renderer Feature or custom render pass code — use code skills
* Providing final art direction or visual outcome guarantees — this skill describes structure and operations, not visual results

**Execution Context Details:**
This skill runs after `design-reference` has established the visual intent and before the rendering engineer or artist begins implementation in Shader Graph or a text editor. It may flag `performance-optimization` if the spec's cost profile requires a broader performance investigation.

---

## Inputs

**Required inputs:**

* **Effect description** — What the effect should look like or do in gameplay/visual terms (e.g., "dissolve shader with edge glow," "rain particle VFX with surface splash").
* **Shader type** — One of: `URP_Unlit`, `URP_Lit`, `PostProcess`, `VFX_Graph`, `Particle_Unlit`.
* **Performance target** — One of: `mobile_30fps`, `pc_60fps`, `console_60fps`, `vr_90fps_low_overdraw`.

**Optional inputs:**

* **Platform constraints** — Specific hardware limits (e.g., "target Mali G76; no desktop-tier features," "must run on Quest 2").
* **Reference visual** — Description or name of a visual reference (concept art, existing effect) that informs the spec intent.
* **Existing shader/material name** — If speccing a replacement or optimization for an existing effect.

**Documents/Context needed:**

* **design-reference** — Provides the visual design intent that the spec must serve.
* **performance-optimization-guide** — Provides the project's performance budgets and platform capability tiers to calibrate the spec.

---

## Outputs

**Primary outputs:**

* **Shader/VFX specification JSON** — Structured node graph description in the canonical output format.
* **Performance notes** — Commentary on operation costs, overdraw risks, texture sample counts, and compliance with the stated performance target.
* **Implementation guidance** — Plain-language notes for the artist or engineer implementing the spec.

**Output format:**

```json
{
  "shader_type": "",
  "nodes": [
    {
      "id": "",
      "type": "",
      "inputs": [],
      "outputs": [],
      "parameters": {}
    }
  ],
  "performance_target": ""
}
```

For VFX Graph specs, `nodes` describes contexts and blocks: `spawn`, `initialize`, `update`, `output` contexts with their block lists and property bindings.

**Skill flags (if applicable):**

* Flag **performance-optimization** when the spec's operation count, texture sample count, or overdraw risk exceeds the stated performance target.
* Flag **architecture-patterns** when the effect requires a custom renderer feature or render pass that involves C# system design.

---

## Preconditions

**Conditions that must be met before execution:**

* The effect description is sufficient to determine the visual goal
* A valid shader type has been provided or can be confidently inferred from the effect description
* A performance target has been stated or can be derived from the target platform

**Validation checks:**

* [ ] Is the shader type one of the five supported types?
* [ ] Is the performance target one of the four supported targets?
* [ ] Is the effect description specific enough to determine node topology?
* [ ] Are there any platform constraints that require special consideration?

---

## Step-by-Step Execution Procedure

### Step 1: Classify the Effect

**Questions to answer:**
- Is this a surface shader (URP_Lit, URP_Unlit), a post-process effect, or a particle/VFX system?
- What rendering pipeline features does it require (transparency, depth, normals)?
- Does it use textures, procedural math, or both?

**Actions:**
- [ ] Confirm or infer `shader_type` from the effect description
- [ ] Identify whether the effect needs to read depth, normals, or scene color (post-process indicators)
- [ ] Determine whether the effect is screen-space, world-space, or object-space

**Red flags / Warning signs:**
- Effect description implies screen-space distortion or post-process blur on `URP_Unlit` — reconsider shader type
- Effect requires reading depth buffer on mobile — flag as performance risk immediately

**Decision points:**
- If the effect can be achieved as `Particle_Unlit` instead of `VFX_Graph`, prefer the simpler type and log the choice

---

### Step 2: Identify Performance Budget

**Questions to answer:**
- What is the performance target for this effect?
- How many texture samples are acceptable for this target?
- Is overdraw a primary concern (mobile, VR)?

**Actions:**
- [ ] Map the performance target to concrete operation budgets using the performance-optimization-guide
- [ ] Identify the maximum acceptable texture sample count for the target
- [ ] Flag any effect that requires dynamic branching or per-frame texture updates as potentially over-budget

**Performance budget reference:**

| Target | Max Tex Samples | Overdraw Priority | Dynamic Branch |
|---|---|---|---|
| mobile_30fps | 2-3 | Critical | Avoid |
| pc_60fps | 6-8 | Low | Acceptable |
| console_60fps | 4-6 | Medium | Minimal |
| vr_90fps_low_overdraw | 2-3 | Critical | Avoid |

**Red flags / Warning signs:**
- Effect description implies more than 4 texture samples on `mobile_30fps` — surface this before proceeding
- VFX effect with high particle count on VR target — overdraw risk, flag immediately

**Decision points:**
- If the described effect cannot meet the stated performance target without significant quality reduction, surface this tradeoff per PS-2 before completing the spec

---

### Step 3: Define Node Graph / Context Structure

**Questions to answer:**
- What are the input properties exposed on the material/VFX?
- What is the node topology (operations pipeline from inputs to outputs)?
- For VFX Graph: what are the spawn conditions, initialization properties, per-frame updates, and output rendering?

**Actions:**
- [ ] List all exposed properties with types (Float, Color, Texture2D, Vector, etc.)
- [ ] Define nodes in operation order from inputs to fragment/vertex output
- [ ] For VFX_Graph: define each context (Spawn, Initialize, Update, Output) with its block list
- [ ] Assign unique IDs to each node for referenceability

**Red flags / Warning signs:**
- More than 3 texture samples without justification for the given platform — reconsider
- Procedural noise generation in fragment shader on mobile — high ALU cost; prefer baked texture
- Overdraw-heavy particle effects without `Depth Test` or `Early-Z` considerations

**Decision points:**
- If a desired visual requires a technique that exceeds budget, define a budget-compliant approximation and log the tradeoff per DT-1

---

### Step 4: Optimize for Platform Target

**Questions to answer:**
- Can any texture samples be replaced with cheaper math operations?
- Are there LOD variants needed for the effect?
- Can vertex operations replace fragment operations for mobile?

**Actions:**
- [ ] Review each node for cheaper alternatives given the performance target
- [ ] Prefer baked textures over real-time procedural noise on mobile/VR
- [ ] Avoid dynamic branching in fragment shaders for mobile/VR targets
- [ ] For particle effects: specify max particle count and particle budget per the performance target

**Red flags / Warning signs:**
- Any real-time convolution (e.g., blur) on mobile — replace with pre-blurred textures
- Unbounded particle emission rate — always specify a maximum count

**Decision points:**
- If optimization requires significantly changing the visual intent, log the compromise and flag `performance-optimization` for formal budget review

---

### Step 5: Validate Spec Completeness

**Questions to answer:**
- Does every node have defined inputs, outputs, and parameters?
- Is the performance target field populated?
- Are all exposed properties named and typed?

**Actions:**
- [ ] Verify all node `id` fields are unique
- [ ] Verify `shader_type` and `performance_target` are populated with valid enum values
- [ ] Verify no compiled output (bytecode, platform binary) is present in the spec
- [ ] Verify no material modifications are implied by the spec

**Red flags / Warning signs:**
- Node has undefined inputs — incomplete spec, cannot be implemented unambiguously
- `shader_type` or `performance_target` left empty — these are required fields

**Decision points:**
- Incomplete specs with undefined nodes should be marked PARTIAL and flagged for clarification

---

### Final Step: Generate Shader/VFX Spec Report

**Report/Output structure:**

```markdown
## Shader / VFX Spec Report

**Effect Name:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** COMPLETE / PARTIAL / NEEDS CLARIFICATION

### Shader Type
[URP_Unlit | URP_Lit | PostProcess | VFX_Graph | Particle_Unlit]

### Performance Target
[mobile_30fps | pc_60fps | console_60fps | vr_90fps_low_overdraw]

### Exposed Properties
| Name | Type | Default | Description |
|------|------|---------|-------------|

### Node Graph / Context Description
[Structured description of the node topology or VFX contexts]

### Spec JSON
[The full JSON output as defined in the Outputs section]

### Performance Notes
- Texture sample count: [N]
- Overdraw risk: [Low/Medium/High]
- ALU cost estimate: [Low/Medium/High]
- Compliance with target: [Yes / At Risk / Exceeds — with reasoning]

### Assumptions Logged (DT-1)
- [What was assumed; what changes if assumption is wrong]

### Skills Flagged
- performance-optimization: [Reason if flagged]
- architecture-patterns: [Reason if flagged]
```

---

## Core Responsibilities

1. Classify the effect and select the appropriate shader/VFX type from the supported set
2. Identify the performance target and apply platform-appropriate operation budgets
3. Define a complete node graph or VFX context structure with typed properties and operations
4. Prefer cheaper operations over complex ones at every decision point — fewer texture samples, no dynamic branching on mobile/VR
5. Produce specification-only output — no compiled shaders, no material modifications, no C# code
6. Surface performance risks before finalizing specs that exceed the stated target (PS-2)
7. Log all tradeoffs between visual quality and performance cost (DT-1)

**Quality criteria:**

* Every node has a unique ID, defined inputs, defined outputs, and parameters
* `shader_type` and `performance_target` are always populated with valid enum values
* Texture sample count is within the platform budget for the stated target
* No compiled output, no material modifications, no C# code appears in the spec
* All quality-vs-performance tradeoffs are documented

---

## Constraints (Rules Applied)

### Performance & Quality Rules

* **PC-4: Performance Budget**
  - How this rule applies: Every spec must include a named `performance_target` and the node design must be validated against that target's operation budget before output is finalized.
  - In practice: Count texture samples and assess overdraw/ALU cost before writing the final spec. Exceed budget → surface tradeoff or redesign.

### Design & Architecture Rules

* **DA-5: Avoid Overengineering**
  - How this rule applies: Default to the simplest node topology that achieves the stated visual intent. Add complexity only when simpler operations demonstrably cannot achieve the goal.
  - In practice: Start with 2 texture samples; justify any additional samples. Start with math before adding textures.

### Product & Stakeholder Rules

* **PS-3: Scope Control**
  - How this rule applies: Output is specification only. Do not produce compiled shaders, modify materials, or generate C# code.
  - In practice: If asked to "write the shader code," redirect to specification form. Note that implementation is out of scope.

* **PS-2: Risk Communication**
  - How this rule applies: When a spec cannot meet its stated performance target without significant quality compromise, this must be communicated before finalizing the spec.
  - In practice: Include a "Performance Risk" flag in the output before delivering a spec that is at budget limit or over.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How this rule applies: Any design decision that trades visual quality for performance (or vice versa) must be documented in the spec.
  - In practice: "Using baked noise texture instead of real-time noise to stay within mobile_30fps texture sample budget — reduces animatability."

---

## Tradeoff Handling

### Tradeoff 1: Visual Quality vs Performance Budget

```
CONFLICT: The described visual effect requires operations that exceed the stated performance target.
DEFAULT: Reduce visual complexity to meet the performance target; log the compromise.
RESOLUTION:
  IF effect_can_approximate_intent_within_budget → spec the approximation; log tradeoff per DT-1
  IF effect_fundamentally_cannot_meet_target → surface risk per PS-2; request priority decision before finalizing
→ Log decision via: DT-1
→ Example: "Requested 8-sample blur on mobile_30fps → replaced with 1-sample pre-blurred texture; animated effect lost."
```

### Tradeoff 2: Procedural Math vs Baked Textures

```
CONFLICT: Procedural math is more flexible and asset-free, but ALU-heavy on mobile/VR.
DEFAULT: Prefer baked textures on mobile_30fps and vr_90fps_low_overdraw; prefer procedural on pc_60fps.
RESOLUTION:
  IF target∈{mobile_30fps,vr_90fps_low_overdraw} → use baked texture; note animatability limitation
  IF target∈{pc_60fps,console_60fps} → procedural acceptable if within budget; prefer if animation is required
→ Log decision via: DT-1
```

### Tradeoff 3: VFX Graph vs Particle System

```
CONFLICT: VFX Graph offers more power but has higher setup complexity and GPU compute cost.
DEFAULT: Prefer Particle_Unlit for simple effects; use VFX_Graph only when GPU simulation is required.
RESOLUTION:
  IF effect_requires_physics_simulation OR custom_GPU_compute → VFX_Graph
  IF effect_achievable_with_CPU_particles → Particle_Unlit; log the simplification
→ Log decision via: DT-1
```

### Tradeoff 4: Feature Completeness vs Spec Clarity

```
CONFLICT: A full spec is more accurate but may exceed what can be unambiguously described without implementation.
DEFAULT: Describe the intent and topology completely; mark ambiguous sections as implementation-defined.
RESOLUTION:
  IF node_behavior_is_standard → specify fully
  IF node_behavior_is_implementation_specific → describe intent; label as "implementation-defined"
→ Never block spec delivery because of implementation-level uncertainty.
```

---

## Failure & Escalation Behavior

### Scenario 1: Effect Exceeds Performance Budget

**Trigger:** Node count, texture samples, or overdraw implies the effect cannot meet the stated `performance_target`.

**Action:**
- Surface the specific budget exceedance (which operations, by how much)
- Propose a budget-compliant alternative specification
- Flag `performance-optimization` for formal review

**Escalation format:**
```
PERFORMANCE RISK DETECTED

Effect: [Name]
Target: [mobile_30fps etc.]
Issue: [e.g., 6 texture samples required; budget is 3 for mobile_30fps]
Proposed Alternative: [Cheaper spec description]
Impact: [Visual quality change description]

Flag: performance-optimization — formal budget review required before implementation.
```

---

### Scenario 2: Shader Type Cannot Be Determined

**Trigger:** Effect description is ambiguous — could be `URP_Unlit` or `PostProcess` or `VFX_Graph`.

**Action:**
- Present the two or three candidate types with their implications
- Ask for selection before proceeding
- Do not produce a spec with an assumed type that could lead to a wrong implementation path

**Escalation:** One clarifying question; block spec until answered.

---

### Scenario 3: Platform Constraints Not Provided

**Trigger:** No `performance_target` is given and no platform can be inferred.

**Action:**
- Default to `pc_60fps` as the most permissive target; log the assumption per DT-1
- Note in the output that this spec may need re-evaluation for other platforms

**Escalation:** No hard block; proceed with logged assumption and explicit caveat.

---

### Scenario 4: Compiled Output Requested

**Trigger:** User asks for compiled shader bytecode, a `.hlsl` file to compile, or a `.shader` asset.

**Action:**
- Redirect: this skill produces specifications, not compiled assets
- Offer the spec as the output and note that compiled implementation is outside this skill's scope
- Do not produce compiled output even partially

**Escalation:** Redirect without blocking; deliver spec form of the same content.

---

### When to halt execution:

* The effect description is completely undefined and no clarification can be made
* The shader type is fundamentally irresolvable between incompatible options (e.g., surface shader vs. post-process vs. VFX)
* The stated performance target contradicts a hard platform constraint that makes the effect impossible even at minimum quality

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
This skill bridges design intent and rendering implementation. It runs after `design-reference` establishes the visual goal and produces the specification that rendering engineers or technical artists implement in Unity's Shader Graph or VFX Graph editors.

### How This Skill Integrates

1. **design-reference** (upstream) provides the visual design intent
2. **shader-vfx-spec** (this skill) translates that intent into a structured technical specification
3. **performance-optimization** (downstream/flagged) reviews specs that are at or over budget
4. **architecture-patterns** (flagged) handles any C# Renderer Feature or render pass C# design required

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Spec exceeds stated performance target | performance-optimization | Formal performance budget review required |
| Effect requires a custom URP Renderer Feature (C# layer) | architecture-patterns | System design for render pass is outside spec scope |

---

## Related Skills

**Skills this skill depends on:**
- **design-reference** — establishes the visual intent the spec must serve
- **performance-optimization** — provides platform capability tiers and operation budgets

**Skills this skill cooperates with:**
- **prefab-scene-spec** — may describe where in a scene an effect is placed
- **scene-component-builder** — assembles scenes that contain materials and VFX objects

**Skills this skill may invoke/flag:**
- **performance-optimization** — flagged when spec cost profile requires formal budget investigation
- **architecture-patterns** — flagged when C# rendering infrastructure is required alongside the spec

---

## Governance Hooks

* [ ] Always populate `shader_type` and `performance_target` in output — both are mandatory fields (PC-4)
* [ ] Never produce compiled shader output, bytecode, or platform binaries (PS-3)
* [ ] Never modify existing materials as part of this skill's output (PS-3)
* [ ] Surface performance risks before finalizing specs that exceed budget (PS-2)
* [ ] Log all quality-vs-performance tradeoffs explicitly (DT-1)

**Audit trail requirements:**

* `shader_type` and `performance_target` documented in every output
* Texture sample count and overdraw risk noted in Performance Notes
* All tradeoffs documented: what was simplified, why, what was lost

---

## Example Use Cases

### Example 1: Dissolve Shader with Edge Glow (Mobile)

**Scenario:** Create a dissolve shader spec for a mobile card game. Cards should dissolve away with a glowing edge when discarded.

**Inputs provided:**
- Effect: dissolve with edge glow
- Shader type: URP_Unlit (card surface)
- Performance target: mobile_30fps

**Execution steps:**
1. Classify: URP_Unlit, object-space, uses noise texture for dissolve mask
2. Budget: mobile_30fps — max 3 texture samples; avoid dynamic branching
3. Node graph: SampleTexture2D (dissolve noise) → Step (dissolve threshold property) → edge detection via smoothstep → lerp(0, emissive color, edge mask) → Alpha Clip
4. Optimize: baked noise texture (1 sample); no real-time noise; 2 total samples (noise + edge color lookup); within budget ✅
5. Validate: shader_type=URP_Unlit, performance_target=mobile_30fps, 2 texture samples ✅

**Result:** COMPLETE — Spec within mobile budget

**Skills flagged:** None

---

### Example 2: Rain VFX System (PC)

**Scenario:** Spec a rain VFX Graph system with splash effects for a PC RPG.

**Inputs provided:**
- Effect: rain particles with ground splash
- Shader type: VFX_Graph
- Performance target: pc_60fps

**Execution steps:**
1. Classify: VFX_Graph — requires GPU simulation for large particle count + spawn-on-collision for splash
2. Budget: pc_60fps — up to 6 texture samples, dynamic branching acceptable
3. VFX contexts: Spawn (continuous rate property, wind direction), Initialize (position: area volume, velocity: downward + variance), Update (collision with terrain → trigger splash sub-effect), Output (Particle Unlit quad, rain streak texture, soft particle depth fade)
4. Splash sub-system: separate VFX event with short lifetime, splat texture animated UV
5. Validate: all contexts defined, max particle count specified (1000 rain + 200 splash), performance_target=pc_60fps ✅

**Result:** COMPLETE — Full VFX Graph spec with spawn/initialize/update/output contexts

**Skills flagged:** None

---

### Example 3: Bloom Post-Process (VR)

**Scenario:** Spec a bloom post-process effect for a VR game.

**Inputs provided:**
- Effect: bloom on bright surfaces
- Shader type: PostProcess
- Performance target: vr_90fps_low_overdraw

**Execution steps:**
1. Classify: PostProcess — reads scene color; bloom is a screen-space effect
2. Budget: vr_90fps_low_overdraw — overdraw critical; full-screen passes extremely expensive in VR
3. Performance risk detected: full-screen bloom at 90fps in VR with dual-eye rendering is over budget for any real-time approach at standard quality
4. Surface risk per PS-2: "Standard multi-pass bloom cannot meet vr_90fps_low_overdraw. Propose single-pass lightweight bloom with threshold clamping and 1-sample tent filter. Visual quality significantly reduced."
5. Spec: single-pass, threshold (property) → sample scene color → tent filter (1 sample) → additive composite; no iterative downsampling

**Result:** COMPLETE with PERFORMANCE RISK flagged

**Skills flagged:** performance-optimization (formal review recommended before committing to VR bloom)

---

### Example 4: Hologram Shader (Console)

**Scenario:** Spec a hologram surface shader for console sci-fi game.

**Inputs provided:**
- Effect: holographic surface with scanlines and rim glow
- Shader type: URP_Unlit
- Performance target: console_60fps

**Execution steps:**
1. Classify: URP_Unlit; object-space; needs screenspace UV for scanlines (uses fragment position) and rim lighting (needs view direction and normal)
2. Budget: console_60fps — 4-6 texture samples acceptable
3. Nodes: NormalMap (1 sample) → ViewDirection → FresnelEffect (rim) → ScreenPosition → frac(UV.y * scanline_density) → step threshold (scanline mask) → lerp(base_color, rim_color, fresnel) * scanline_mask → alpha from fresnel
4. 1 texture sample (normal map); no additional samples needed; procedural scanlines via math ✅
5. Validate: within 4-sample budget; dynamic branching absent; all nodes defined ✅

**Result:** COMPLETE — Within console budget; procedural scanlines, no extra texture samples

**Skills flagged:** None

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Producing compiled shader code or HLSL files intended for direct compilation
✅ **Correct approach:** Output is always a structured specification describing node topology and operations, not executable code. Redirect compile requests.

❌ **Anti-pattern 2:** Modifying or referencing changes to existing material assets
✅ **Correct approach:** This skill specifies new effects. Material property modification is out of scope and must be explicitly called out as such.

❌ **Anti-pattern 3:** Omitting `shader_type` or `performance_target` from output
✅ **Correct approach:** Both fields are mandatory in every output. Default to inferable values with DT-1 logging if not explicitly provided; never leave them blank.

❌ **Anti-pattern 4:** Specifying more texture samples than the platform budget allows without surfacing the issue
✅ **Correct approach:** Count texture samples early (Step 2) and surface over-budget designs before completing the spec. Always flag if budget is exceeded.

❌ **Anti-pattern 5:** Using real-time procedural noise in a fragment shader for mobile or VR targets
✅ **Correct approach:** On `mobile_30fps` and `vr_90fps_low_overdraw`, always prefer baked noise textures. Real-time procedural noise is ALU-expensive on these targets.

❌ **Anti-pattern 6:** Leaving nodes with undefined inputs or outputs
✅ **Correct approach:** Every node in the specification must have all inputs, outputs, and parameters defined. Incomplete nodes cannot be implemented unambiguously.

❌ **Anti-pattern 7:** Using dynamic branching in fragment shaders for mobile or VR targets
✅ **Correct approach:** Avoid `if` branching in fragment operations on `mobile_30fps` and `vr_90fps_low_overdraw`. Use math alternatives (step, lerp, smoothstep).

❌ **Anti-pattern 8:** Specifying an unbounded particle emission rate for VFX Graph effects
✅ **Correct approach:** Every VFX Graph spec must include a maximum particle count appropriate for the performance target.

❌ **Anti-pattern 9:** Treating a screen-space post-process effect as a URP_Unlit or URP_Lit shader
✅ **Correct approach:** Post-process effects that read scene color, depth, or normals must be classified as `PostProcess` and handled with awareness of their full-screen cost.

❌ **Anti-pattern 10:** Silently downgrading visual quality to meet a budget without documenting the tradeoff
✅ **Correct approach:** Every quality-performance tradeoff must be logged per DT-1, including what was simplified and what visual impact results.

---

## Non-Goals

* **Compiled shader production** — this skill produces specifications; compiled implementation is the domain of the rendering engineer using the spec
* **Material property editing** — handled as a separate asset-editing task; this skill does not touch existing materials
* **C# Renderer Feature or render pass authoring** — handled by code-oriented skills and `architecture-patterns`
* **Art direction and visual outcome guarantees** — the spec describes structure and operations; visual results depend on the implementation and content

---

## Notes for LLM Implementation

1. **Type and target first**: Always confirm `shader_type` and `performance_target` before describing any nodes. These two fields determine the valid operation space.
2. **Count texture samples explicitly**: For every spec, count the texture samples in the node graph and compare against the platform budget table before finalizing.
3. **Avoid dynamic branching on mobile/VR**: Use math alternatives (step, lerp, smoothstep, saturate) instead of conditional branching in fragment shaders on `mobile_30fps` and `vr_90fps_low_overdraw`.
4. **VFX Graph = context-first**: For `VFX_Graph` specs, define all four contexts (Spawn, Initialize, Update, Output) before defining blocks within them. Missing contexts make the spec non-implementable.
5. **Spec is not code**: Output must be readable as a design document, not as executable code. Node descriptions should be unambiguous in intent but not in syntax.

**Output format:**
- Always produce the JSON output shape defined in the Outputs section
- Always produce the markdown Shader/VFX Spec Report from the Final Step
- Performance Notes section is mandatory in every output

**Tone and approach:**
- Technical and precise: use correct shader/graphics terminology (overdraw, ALU, UV, fragment, vertex)
- Performance-conscious: frame every design choice in terms of its cost
- Specification-mode: describe what the nodes do, not how to write them

---

## Metadata Summary

```yaml
name: shader-vfx-spec
category: Content Generation
priority: High
depends_on: [design-reference, performance-optimization]
flags_skills: [performance-optimization, architecture-patterns]
rules_applied: [PC-4, DA-5, PS-3, DT-1, PS-2]
documents_needed: [design-reference, performance-optimization-guide]
tags: [unity, shader, vfx, urp, hlsl, shader-graph, vfx-graph, performance, mobile, console]
```

**Key relationships:**
- Depends on: design-reference (visual intent), performance-optimization (platform budgets)
- Flags: performance-optimization (over-budget specs), architecture-patterns (C# renderer features)
- Governed by: PC-4 (performance budget mandate), DA-5 (minimal complexity), PS-3 (spec-only output), PS-2 (risk surfacing), DT-1 (tradeoff logging)

---

*End of Skill Human Spec — shader-vfx-spec-docs.md*
