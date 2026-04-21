---
name: behavior_tree_designer
description: >
  NPC Behavior Designer. Design AI Behavior Trees (BT) and Finite State
  Machines (FSM) structures.
---

# Behavior Tree Designer Skill (Execution)

PURPOSE: design BT or FSM structures (node/state graphs + transitions).
ROLE: design only; not implementation or balance.

## Responsibilities
- **BT**: composites (Sequence, Selector, Parallel), decorators, leaf nodes with clear roles.
- **FSM**: states + transitions with conditions; keep state count + branching manageable.
- Optimize for clarity + performance: shallow trees, minimal states, no redundant nodes.

## Hard Constraints (DO NOT)
- Implement code (no C# / scripts). Design only.
- Modify or extend existing in-game behaviors; only produce new designs/specs.
- Change game balance / difficulty / timings / tuning.

## Required JSON Output (only; no extra text)
```json
{
  "behavior_type": "BT | FSM",
  "nodes": [],
  "transitions": []
}
```

- `behavior_type`: `"BT"` or `"FSM"`.
- `nodes`:
  - BT: `id`, `type` (`"Sequence"`, `"Selector"`, `"Action"`, `"Condition"`, etc.), `name`/`label`, optional `children` (node ids).
  - FSM: `id`, `name`, optional `entry`/`exit` descriptions (text only, no code).
- `transitions`:
  - BT: optional; may describe parent-child edges `{"from": "nodeId", "to": "childId"}` if flat.
  - FSM: `from` (state id), `to` (state id), `condition` (short text description).

## Algorithm
1. Clarify scope (BT vs FSM; which NPC/scenario).
2. Design structure (nodes/states + transitions; keep clear + performant).
3. Populate `behavior_type`, `nodes`, `transitions`.
4. Return JSON only.
