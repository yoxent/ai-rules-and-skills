---
name: dependency_analyzer
description: >
  Dependency Tracker. Analyzes project references to identify impact zones
  and potential conflicts for changes.
---

# Dependency Analyzer Skill (Meta)

PURPOSE: trace references; surface impact + risk for proposed changes.
ROLE: analysis + risk surfacing only; no execution.

## Responsibilities
- Trace references between scripts, ScriptableObjects, prefabs, scenes, assemblies.
- Identify direct + indirect dependents of given files/systems.
- For a described/planned change: list systems, scripts, assets in the impact cone; clarify call chains, event subscriptions, data flow.
- Flag API changes that could break callers; removed/renamed assets referenced elsewhere; ordering/lifecycle issues.
- Surface risks for confirmation/mitigation before any change applied.

## Hard Constraints (DO NOT)
- Apply changes (no patches / refactors / edits).
- Modify files (source, assets, scenes, project settings).
- Assume dependencies safe by default; call out uncertainties; recommend confirmation for non-obvious cases.

## Required JSON Output (only; no extra text)
```json
{
  "affected_files": [],
  "dependent_systems": [],
  "risk_notes": []
}
```

- `affected_files`: paths directly or indirectly affected (scripts, assets, scenes).
- `dependent_systems`: high-level systems/features that depend on the code/assets (for example `"Save system"`, `"Combat UI"`, `"Enemy spawner"`).
- `risk_notes`: short notes on potential conflicts/breakages/areas needing confirmation.

## Algorithm
1. Identify scope of proposed change (files/types/systems).
2. Trace references -> affected files + dependent systems.
3. Assess interaction + risk; highlight conflicts/breakages.
4. Populate JSON fields.
5. Return JSON only.
