---
name: shader-vfx-spec
description: "Use when task requires Shader/VFX spec only. Shader Graph node-graph, HLSL pass, and VFX Graph context specs. No compiled output, no material edits."
---

# Shader Vfx Spec

name:shader-vfx-spec|pri:H|deps:[design-reference,performance-optimization]|flags:[performance-optimization,architecture-patterns]|rules:[PC-4,DA-5,PS-3,DT-1,PS-2]
SCOPE: Shader/VFX spec only. Shader Graph node-graph, HLSL pass, and VFX Graph context specs. No compiled output, no material edits.
ENFORCE: shader_type and performance_target mandatory per PC-4 (default pc_60fps+DT-1 if absent); count texture samples against platform budget (mobile/vr≤3, console≤6, pc≤8); prefer baked over procedural noise and math over dynamic branching on mobile/vr per DA-5; VFX specs define all four contexts (Spawn/Initialize/Update/Output); surface budget overrun per PS-2 before delivery; log quality-vs-performance tradeoffs per DT-1.
PROHIBIT: Compiled bytecode/binaries; material/instance modification; C# renderer feature code; dynamic branching in fragment on mobile/vr; undefined node inputs in final spec.
ON_VIOLATION: budget_exceeded→surface_PS-2→propose_alt→flag:performance-optimization. type_ambiguous→BLOCK→resolve_first. target_missing→default_pc60fps→log:DT-1. compiled_output→redirect_spec. renderer_needed→flag:architecture-patterns. tradeoff→log:DT-1.

## Reference
- See [reference.md](reference.md) for distilled source details.
