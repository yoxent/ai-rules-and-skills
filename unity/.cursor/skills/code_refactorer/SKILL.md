---
name: code_refactorer
description: >
  Unity C# Refactoring tool. Improves code readability and performance
  without changing observable behavior or APIs.
---

# Code Refactorer Skill (Execution)

PURPOSE: improve readability / performance without changing behavior or public APIs.
ROLE: follows `.cursor/skills/references/execution_skills.md` (code-only: no assets/settings, no public API changes; JSON-only output).

## Responsibilities
- Simplify complex code; remove duplication; clarify intent.
- Apply safe micro-optimizations that do not alter observable behavior.
- Refactored code must be functionally equivalent; gameplay outcomes + side effects unchanged.

## Hard Constraints
- Do not change gameplay logic.
- Code-only; no assets/settings changes.
- No public API changes.

## Required JSON Output (only; no extra text)
```json
{
  "patch": "",
  "refactor_type": "",
  "behavior_changed": false
}
```

- `patch`: refactor changes; env-expected format (ApplyPatch-style or unified diff).
- `refactor_type`: short label (for example `"extract_method"`, `"rename_private_field"`, `"remove_duplication"`, `"loop_optimization"`, `"early_return"`).
- `behavior_changed`: MUST be `false` for valid refactors. Set `true` only if behavior might have changed (caller treats as unsafe).

## Algorithm
1. Analyze code; identify clarity/structure/performance opportunities.
2. Select safe refactors (no observable behavior change).
3. Construct `patch`.
4. Set `refactor_type` (dominant pattern).
5. Set `behavior_changed` = `false` if preserved, `true` if any doubt.
6. Return JSON only.
