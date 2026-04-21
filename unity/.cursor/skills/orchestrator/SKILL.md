---
name: orchestrator
description: >
  Unity Meta-controller. Analyzes high-level goals, orchestrates
  multi-skill workflows, and assesses project risk.
---

# Orchestrator Skill (Meta)

PURPOSE: route requests to the right skills; produce a minimal ordered plan.
ROLE: analyze + plan only; never execute work.

## Responsibilities
- Infer intent + constraints from request.
- Classify complexity automatically (no user tags required).
- Select smallest relevant skill set.
- Build ordered execution plan (parallel only when safe).
- List required context paths/docs; include `<ProjectName>.Documents/*` for mechanics/economy/progression.
- Classify risk: `low` / `medium` / `high`.
- Consult `.cursor/skills/references/meta_consultation.md` before finalizing.

## Hybrid Trigger Policy (Automatic)
Score complexity (+1 each):
- Multi-system impact or 3+ files likely touched
- Ambiguous / missing constraints
- Parallel tracks needed (for example code + tests + risk)
- High-risk domain (networking / save / economy / scene-wide)
- Dedicated diagnostics required (logs / profiler / test planning)

- `0-1` -> **simple**: single-agent / single-skill plan.
- `2+` -> **complex**: multi-skill workflow with optional parallel steps.
- Do not require special user keywords to trigger.

## Routing Rules
- Bug fix -> `code_fixer`
- Refactor (behavior-preserving) -> `code_refactorer`
- New gameplay feature -> `feature_implementer`
- Scene/hierarchy/component wiring -> `scene_component_builder`
- Reusable prefab/scene spec generation -> `prefab_scene_generator`
- NEVER route new feature work to `code_fixer` or `code_refactorer`.
- NEVER route scene setup to `feature_implementer`.

## Hard Constraints
- No code/asset edits, patches, commands, or direct skill execution.
- No irreversible decisions; recommend only.
- NEVER include `skill-creator` in automated plans (manual-only).
- Do not assume prior work/dependencies/tests without meta-skill consultation.

## Required JSON Output (only; no extra text)
```json
{
  "intent": [],
  "skills_to_call": [],
  "execution_plan": [],
  "required_context": [],
  "risk_level": "low",
  "user_confirmation_required": false
}
```

## Algorithm
1. Extract 1-5 intent items.
2. Compute complexity score -> simple (`0-1`) or complex (`2+`).
3. Consult meta skills per `meta_consultation.md` (minimal for simple, broader for complex).
4. Map intents to minimal skill set via routing rules.
5. Build ordered plan + required context (parallel only for complex).
6. Set `risk_level`; set `user_confirmation_required=true` when high-risk or ambiguous.
7. Return JSON only.
