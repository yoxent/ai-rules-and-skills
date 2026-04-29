# Skill Human Spec: AI Pathfinding

```yaml
---
name: ai-pathfinding
description: Validates NavMesh baking setup, NavMeshAgent destination hygiene, arrival detection correctness, and AI decision/sensing decoupling
version: 1.0.0
category: Architecture
tags: [unity, ai, navmesh, pathfinding, navmeshagent, statemachine]
priority: Medium
depends_on: [code-standards]
flags_skills: [performance-optimization, architecture-patterns]
inputs: [ai_agent_scripts, navmesh_configuration, decision_logic]
outputs: [violations_list, setup_recommendations, architecture_assessment]
rules_applied:
  - DA-1  # SOLID & Clean Code First
  - DA-3  # Conditional Logic Placement
  - DA-7  # Architectural Consistency
  - PC-4  # Performance Budget
documents_needed: [gdd_enemy_behaviour_section]
execution_context: On scripts using NavMeshAgent or NavMeshSurface; after code-standards
---
```

---

# Skill: AI Pathfinding

## Purpose

Validates Unity NavMesh-based AI implementation: baking approach, destination update hygiene, arrival detection correctness, and separation of sensing from decision from movement. Prevents the most common AI bugs — per-frame SetDestination, transform-based arrival detection, and monolithic god-object AI classes.

---

## When to Use

**Triggers:**
- Script uses NavMeshAgent or NavMeshSurface
- New enemy/NPC type introduced
- AI Update method mixes sensing + decision + movement logic
- Runtime-generated environment requires NavMesh rebuild

**Do NOT use for:** Manual A* pathfinding; DOTS movement (→ dots-ecs); player input movement (→ input-system).

---

## Inputs & Outputs

**Inputs:** AI agent scripts; NavMeshSurface configuration; NPC/enemy behaviour scripts
**Outputs:** Violations list; setup recommendations; decision-architecture assessment
**Flags:** `performance-optimization` for per-frame SetDestination; `architecture-patterns` for monolithic AI class

---

## Execution Steps

### 1 — NavMesh Baking
- Verify NavMeshSurface used (com.unity.ai.navigation package), not legacy static NavMesh baking
- Flag NavMesh.CalculatePath direct usage if project targets Unity 6
- NavMeshSurface.BuildNavMesh() allowed on static build or explicit runtime trigger only — never per-frame

### 2 — Agent Configuration
- Verify explicit stoppingDistance, speed, angularSpeed, acceleration set in script or inspector — not silent Unity defaults
- Dynamic path-blocking objects use NavMeshObstacle (Carve=true), not a second NavMeshAgent
- Off-mesh links via OffMeshLink component — not manual transform position jumps

### 3 — Destination Hygiene
- SetDestination must be gated: position-change threshold or target-change event — never unconditional per-frame
- NavMesh.SamplePosition to validate reachability before SetDestination
- Check agent.isActiveAndEnabled before calling SetDestination

### 4 — Arrival Detection
- Correct pattern: `!agent.pathPending && agent.remainingDistance <= agent.stoppingDistance`
- Flag Vector3.Distance(transform.position, target) for arrival — not path-aware, breaks on obstacles

### 5 — Decision Architecture
- Sensing + decision + NavMeshAgent movement in one class → warn + flag:architecture-patterns
- AI state logic in StateMachine<T>+IState per DA-3 — not inline Update conditionals
- Field-of-view/hearing checks in dedicated sensor component, not in the agent mover

---

## Core Responsibilities

1. Enforce NavMeshSurface-based baking (not legacy)
2. Rate-limit or event-gate all SetDestination calls
3. Require NavMesh.SamplePosition before destination assignment
4. Enforce remainingDistance-based arrival detection
5. Flag monolithic AI for sensing/state/movement decoupling via architecture-patterns

---

## Rules Applied

- **DA-1:** Sensing, decision, movement are separate responsibilities — one class must not own all three
- **DA-3:** AI state logic in IState implementations, not Update conditional chains
- **DA-7:** All NPCs use NavMesh consistently — no mixed pathfinding approaches in one project
- **PC-4:** SetDestination per-frame recalculates path even when target is stationary — redundant CPU cost

---

## Tradeoffs

**NavMesh vs custom pathfinding for special movement (flying, swimming):** Use NavMeshSurface area types first; fall back to custom only with documented ADR via DT-1 and DA-7 consistency note.

**StateMachine overhead for simple 2-state AI:** Apply DA-5 — 2-state logic may be inline; 3+ states require StateMachine<T>.

---

## Escalation

| Situation | Action |
|---|---|
| SetDestination every Update unconditionally | warn → provide change-check pattern → flag:performance-optimization |
| transform.position for arrival detection | warn → provide remainingDistance pattern |
| Monolithic sense-decide-move class | warn → flag:architecture-patterns → sketch sensor/state/mover split |
| No NavMesh.SamplePosition before SetDestination | warn → provide guard pattern |
| NavMesh not baked / NavMeshSurface missing | BLOCK → request setup before proceeding |

---

## Anti-Patterns

❌ `_agent.SetDestination(target.position)` in `Update()` unconditionally
✅ Gate with change-check: `if ((_lastDest - target.position).sqrMagnitude > _threshold) { _agent.SetDestination(target.position); _lastDest = target.position; }`

❌ `Vector3.Distance(transform.position, target.position) < 0.5f` for arrival
✅ `!_agent.pathPending && _agent.remainingDistance <= _agent.stoppingDistance`

❌ Sensing + decisions + agent calls all in one MonoBehaviour Update
✅ `EnemySensor` (detects player) → `EnemyStateMachine` (decides state) → `EnemyMover` (drives NavMeshAgent)

❌ NavMeshAgent on a dynamic object that blocks other agents' paths
✅ NavMeshObstacle with Carve=true on non-agent dynamic blockers

❌ `_agent.SetDestination(targetPos)` with no reachability check
✅ `if (NavMesh.SamplePosition(targetPos, out var hit, 2f, NavMesh.AllAreas)) _agent.SetDestination(hit.position)`

❌ Legacy static NavMesh baking (Window > AI > Navigation) in Unity 6
✅ NavMeshSurface.BuildNavMesh() via com.unity.ai.navigation package

---

## Non-Goals

- Custom A* or non-NavMesh pathfinding implementations
- DOTS agent movement — use dots-ecs
- Player input-driven movement — use input-system
- AI difficulty tuning / enemy behaviour design (game-designer domain)

---

## LLM Notes

1. Always provide the change-check pattern when blocking per-frame SetDestination — the fix is non-obvious
2. Arrival detection requires BOTH `!pathPending` AND `remainingDistance` — either alone produces false positives
3. Monolithic AI → flag:architecture-patterns and sketch the split; do not attempt full refactor within this skill
4. NavMesh.SamplePosition is a reachability guard, not a SetDestination replacement — both calls are required

---
