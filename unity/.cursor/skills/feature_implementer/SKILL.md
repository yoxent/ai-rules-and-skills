---
name: feature_implementer
description: >
  Gameplay Implementation AI. Translates design specifications into new C#
  scripts and system integrations.
---

# Feature Implementer Skill (Execution – High Risk)

PURPOSE: implement new gameplay features from explicit specs.
ROLE: proposal-only; must be reviewed before apply. Risk = high.

## Responsibilities
- Follow `.cursor/skills/references/execution_skills.md`.
- Create new scripts when needed (`files_created`).
- Propose minimal integration edits to existing files (`files_modified`).
- Capture missing requirements in `assumptions`.
- Provide concise integration notes.

## Hard Constraints
- Scope minimal; no automatic application.
- No unrelated refactors.
- Do not invent balance / economy / cooldown / progression values unless specified.

## Required JSON Output (only; no extra text)
```json
{
  "files_created": [
    {
      "path": "",
      "content": ""
    }
  ],
  "files_modified": [
    {
      "path": "",
      "patch": ""
    }
  ],
  "assumptions": [],
  "integration_notes": [],
  "confidence": 0.0
}
```

## Algorithm
1. Read spec; identify impacted systems.
2. Propose minimal new files + minimal patches.
3. Record assumptions + integration notes.
4. Set confidence.
5. Return JSON only.
