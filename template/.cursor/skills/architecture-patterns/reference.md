# Skill Human Spec: Architecture Patterns

```yaml
---
name: architecture-patterns
description: Enforces Unity architecture conventions including ScriptableObject Event Channels, Service Locator, State Machines, and Command pattern
version: 1.0.0
category: Architecture
tags: [unity, architecture, event-channel, service-locator, state-machine, command-pattern]
priority: High

depends_on: [code-standards]
flags_skills: []

inputs: [system_design_intent, source_code, cross_system_dependencies, interaction_patterns]
outputs: [architecture_assessment, violations_list, pattern_recommendations, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-2   # Abstraction by Business Meaning
  - DA-3   # Conditional Logic Placement
  - DA-7   # Architectural Consistency

documents_needed: [existing_architecture_decisions, project_system_map]

execution_context: Runs after code-standards on new systems or cross-system interaction design; before networking and dots-ecs
---
```

---

# Skill: Architecture Patterns

---

## Purpose

**What this skill does:**
Enforces Unity-specific architectural patterns: ScriptableObject-based Event Channels for decoupled cross-system communication, a persistent Service Locator for manager registration and retrieval, generic StateMachine<T> with IState interfaces for characters and game flow, and ICommand + CommandManager for undo/redo and input playback systems. Validates that new patterns align with established architectural decisions.

Inconsistent architecture creates systems that are hard to debug, extend, and hand off. Enforcing a small set of well-understood patterns keeps the codebase navigable for the entire team across the lifetime of the project.

Event Channels eliminate MonoBehaviour-to-MonoBehaviour references. Service Locator removes singleton proliferation. State machines eliminate complex Update conditionals. Command pattern enables testable, replayable input. Each pattern has a specific problem it solves.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new system needs to communicate with another system
* A manager class is being created (AudioManager, UIManager, etc.)
* A character or game-flow state machine is being designed or implemented
* An undo/redo or input record/playback system is being built
* Code review reveals direct MonoBehaviour-to-MonoBehaviour field references between unrelated systems
* A new pattern is being introduced that may conflict with existing architectural decisions

### Do NOT use this skill for:

* Internal logic within a single, self-contained system (no cross-system concern)
* DOTS/ECS system design — use dots-ecs
* Network state management — use networking
* Performance or memory concerns — use performance-optimization or dots-ecs

**Execution Context Details:**
Runs after code-standards on new system design or cross-system wiring. Acts as the architectural integrity gate before domain-specific skills (networking, dots-ecs). Works alongside folder-structure to ensure systems live in the correct place.

---

## Inputs

**Required inputs:**

* **System design intent** — What the new system does and which other systems it interacts with
* **Source code** — The class(es) under review, particularly constructors, fields, and event wiring
* **Cross-system dependencies** — Any direct references to other MonoBehaviour systems

**Optional inputs:**

* **Existing architecture decisions** — Prior ADRs or documented pattern choices in the project

**Documents/Context needed:**

* **Project system map** — Which systems exist and how they currently communicate
* **Existing architectural decisions** — To validate new patterns align with project precedent per DA-7

---

## Outputs

**Primary outputs:**

* **Architecture assessment** — Pass/Fail/Needs Review per pattern category
* **Violations list** — Direct coupling, missing patterns, or inconsistent pattern choice
* **Pattern recommendations** — Specific pattern to apply with implementation sketch
* **Approval status** — Whether the system design meets architectural standards

**Output format:**

* Structured report with sections per pattern concern (Event Channels, Service Locator, State Machine, Command)
* Implementation sketch for recommended patterns
* Flagged violations with severity

**Skill flags (if applicable):**

* No downstream flags — architecture-patterns is a design gate

---

## Preconditions

**Conditions that must be met before execution:**

* code-standards has passed for the scripts under review
* The system's intended responsibilities are clear (not a TBD stub)

**Validation checks:**

* [ ] code-standards has passed
* [ ] System purpose is documented or can be inferred from class name and fields
* [ ] Cross-system interaction intent is known (what does this system receive from or send to others?)

---

## Step-by-Step Execution Procedure

### Step 1: Identify Cross-System Communication Patterns

**Questions to answer:**
- Does this system send data or events to another system?
- Does it receive data or events from another system?
- Are these via direct field references or decoupled channels?

**Actions:**
- [ ] Identify all fields referencing other MonoBehaviour systems (e.g., `[SerializeField] private AudioManager _audio`)
- [ ] Classify each reference: is this manager retrieval (→ Service Locator) or event notification (→ Event Channel)?
- [ ] Flag direct MonoBehaviour-to-MonoBehaviour serialized references between unrelated systems

**Red flags / Warning signs:**
- `[SerializeField] private EnemySpawner _spawner` in `PlayerController` — unrelated systems directly coupled
- `_audioManager.PlaySFX(clip)` via a direct field reference instead of an event

**Decision points:**
- If tight coupling detected: recommend Event Channel or Service Locator depending on relationship type
- If same-system reference: pass — internal coupling is acceptable

---

### Step 2: Validate Event Channel Usage

**Questions to answer:**
- Are ScriptableObject-based Event Channels used for cross-system notifications?
- Does each event channel follow the standard Raise/Subscribe/Unsubscribe pattern?

**Actions:**
- [ ] Identify all cross-system event wiring
- [ ] Verify events are raised via ScriptableObject Event Channel assets (not C# events shared by reference)
- [ ] Verify Subscribe is called in OnEnable and Unsubscribe in OnDisable
- [ ] Verify each channel is `[CreateAssetMenu]` and uses the `Action<T>` pattern internally

**Red flags / Warning signs:**
- Cross-system events via static C# events on manager classes
- `OnEnable` subscribes but `OnDisable` does not unsubscribe — memory leak risk
- Event channels defined as plain C# classes rather than ScriptableObjects

**Decision points:**
- If static event used cross-system: warn, recommend Event Channel ScriptableObject
- If missing unsubscribe: SAFETY warn — event subscription leak

---

### Step 3: Validate Service Locator Usage

**Questions to answer:**
- Are cross-system manager references retrieved via the Service Locator rather than direct serialized fields?
- Is the Service Locator persistent across scenes?

**Actions:**
- [ ] Identify all `[SerializeField]` fields referencing manager classes (AudioManager, UIManager, etc.)
- [ ] Verify managers are registered with and retrieved from ServiceLocator
- [ ] Verify ServiceLocator is on a DontDestroyOnLoad GameObject or a persistent bootstrapper
- [ ] Flag singleton pattern (static Instance) used where Service Locator should be

**Red flags / Warning signs:**
- `AudioManager.Instance.PlaySFX(clip)` — singleton anti-pattern
- `[SerializeField] private UIManager _ui` in a gameplay class — direct cross-system reference
- Service Locator not initialised before first consumer (boot order issue)

**Decision points:**
- If singleton used: warn, recommend Service Locator registration
- If serialized cross-system field: warn, recommend retrieval via Service Locator

---

### Step 4: Validate State Machine Usage

**Questions to answer:**
- Does a character or game-flow class use complex Update conditionals that should be a state machine?
- Is an existing state machine using the generic StateMachine<T> + IState pattern?

**Actions:**
- [ ] Scan Update methods for nested if/else or switch blocks on a state enum/flag
- [ ] Verify state machines use `StateMachine<T>` with `IState` interface
- [ ] Verify state transitions are explicit (`stateMachine.ChangeState(new RunState())`)
- [ ] Flag state logic embedded directly in Update without abstraction

**Red flags / Warning signs:**
- `if (_isGrounded && _isMoving && !_isAttacking)` — complex state logic in Update
- State controlled by 3+ bool flags toggled in multiple places
- Switch statement on enum with 5+ cases in Update

**Decision points:**
- If complex state in Update: warn, provide StateMachine<T> sketch
- If existing state machine uses ad-hoc pattern: warn, recommend migration to IState model

---

### Step 5: Validate Command Pattern Usage

**Questions to answer:**
- Does any system require undo/redo, input recording, or action replay?
- Is ICommand + CommandManager used for these systems?

**Actions:**
- [ ] Identify any undo/redo, replay, or playback requirements in the system
- [ ] Verify ICommand interface with Execute() and Undo() methods
- [ ] Verify CommandManager maintains a history stack
- [ ] Flag action history implemented via plain method calls with no command abstraction

**Red flags / Warning signs:**
- Undo implemented via storing previous field values manually in the calling class
- Input recording implemented without a serialisable Command structure

**Decision points:**
- If undo/redo implemented without Command pattern: warn, provide ICommand sketch

---

### Final Step: Generate Architecture Report

```markdown
## Architecture Patterns Report

**Target:** [System or class under review]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Cross-System Communication
[Finding — direct coupling or Event Channel usage]

### Event Channels
[Finding — ScriptableObject pattern, subscribe/unsubscribe]

### Service Locator
[Finding — manager retrieval pattern]

### State Machine
[Finding — Update conditionals vs. IState model]

### Command Pattern
[Finding — undo/redo or replay pattern if applicable]

### Overall Assessment
- ✅ PASS: All cross-system patterns correct
- ❌ FAIL: Direct coupling or event subscription leak
- ⚠️ NEEDS REVIEW: Pattern inconsistency with existing codebase

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce ScriptableObject Event Channels for all cross-system event communication
2. Require Service Locator for cross-system manager retrieval — no singletons or serialized cross-system fields
3. Require StateMachine<T> + IState for any character or game-flow with 3+ state conditions
4. Require ICommand + CommandManager for any system with undo/redo or input replay
5. Validate all new patterns align with existing architectural decisions per DA-7

**Quality criteria:**

* Zero unrelated-system MonoBehaviour-to-MonoBehaviour serialized field references
* All cross-system manager access via Service Locator
* No complex multi-flag state logic in Update without a state machine abstraction

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: Each system should have one reason to change; cross-system coupling violates this
  - In practice: PlayerController should not hold a reference to AudioManager — it raises an event

* **DA-2: Abstraction by Business Meaning**
  - Applies: Event channels are named by business event, not technical mechanism ("PlayerDied" not "OnHealthZero")
  - In practice: `PlayerDiedEvent` ScriptableObject is clearer than a static C# event on a manager class

* **DA-3: Conditional Logic Placement**
  - Applies: State logic belongs in dedicated state classes, not in Update conditionals
  - In practice: A `GroundedState`, `AirborneState`, and `AttackingState` class — not `if (grounded && !jumping)`

* **DA-7: Architectural Consistency**
  - Applies: New cross-system patterns must match how other systems in the project communicate
  - In practice: If AudioSystem uses Event Channels, UISystem must too — no mixing patterns

---

## Tradeoff Handling

### Tradeoff 1: Pattern Overhead vs. System Size

**Scenario:** A small utility system (e.g., a scene transition handler) benefits from a Service Locator but the overhead feels disproportionate.

**Default stance:** Apply DA-5 — require pattern only when the benefit is clear. For small, isolated systems, direct wiring may be acceptable. Document the exception.

**Resolution process:**
1. Assess system size and lifetime
2. If single-use, small, and unlikely to grow: allow direct wiring with documented exception
3. If likely to be reused or grow: require Service Locator

---

### Tradeoff 2: Event Channel vs. Direct Method Call for Performance

**Scenario:** A high-frequency event (60/s) routed through a ScriptableObject Event Channel creates measurable overhead.

**Default stance:** Confirm the performance concern is real (profiled, not assumed). If confirmed, allow direct callback — log the exception via DT-1.

**Resolution process:**
1. Request profiler data showing Event Channel overhead
2. If overhead is measured and exceeds budget: allow direct callback
3. Log via DT-1: "Direct callback used at [X system] due to [Y profiler result]"

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Pattern Conflict with Existing Codebase

**Trigger:** New system uses a different cross-system communication pattern than existing systems.

**Action:**
- Surface inconsistency per DA-7
- Request alignment with existing pattern OR an ADR documenting the intentional divergence
- Log decision via DT-1

---

### Escalation Scenario 2: Event Subscription Without Unsubscribe

**Trigger:** OnEnable subscribes to an Event Channel but OnDisable has no unsubscribe.

**Action:**
- SAFETY warn — this is a memory/reference leak risk
- Provide the matching Unsubscribe call in OnDisable

---

### Escalation Scenario 3: Singleton Pattern Entrenched in Project

**Trigger:** Project already has 10 singletons; introducing Service Locator would be a migration.

**Action:**
- Flag the inconsistency per DA-7
- Log existing singletons as technical debt via MF-2
- Enforce Service Locator on new systems going forward; do not require retroactive migration

---

### When to halt execution:

* System purpose is completely unclear — cannot assess pattern fit without knowing intent
* Architecture decisions are actively in flux and being revised by the team

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on new systems with cross-system interactions. Acts as the architectural integrity gate. Networking and dots-ecs assume correct architectural patterns are already in place.

**Integration workflow:**
1. code-standards passes
2. Orchestrator invokes architecture-patterns when cross-system interaction is detected
3. Skill assesses five pattern categories
4. After pass: networking or dots-ecs runs for domain-specific concerns

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — architecture-patterns is a design gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Lifecycle and naming correctness must be established before assessing cross-system wiring; OnEnable/OnDisable ordering affects event subscription patterns

**Skills this skill cooperates with:**

* **networking** — Network architecture (server authority, RPC patterns) builds on the same decoupling principles as Event Channels
* **folder-structure** — Systems must be in correct folders before their cross-system relationships are assessed

**Skills this skill may invoke/flag:**

* None — architectural integrity gate; escalates to team decision when needed

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block on direct cross-system coupling between unrelated systems — never warn-only
* [ ] Apply DA-5 for small isolated systems — do not over-engineer single-use utilities
* [ ] Log all pattern exceptions via DT-1 with justification
* [ ] Flag event subscription without unsubscribe as a SAFETY violation
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* All approved singleton exceptions logged as technical debt via MF-2
* Pattern divergence from existing codebase requires DT-1 entry or ADR

---

## Example Use Cases

### Example 1: Direct AudioManager Reference in PlayerController

**Scenario:** `PlayerController` has `[SerializeField] private AudioManager _audio` and calls `_audio.PlaySFX(jumpClip)` on jump.

**Execution steps:**
1. Detect serialized cross-system reference
2. Classify: notification → Event Channel
3. Recommend: `JumpEventChannel` ScriptableObject; AudioManager subscribes; PlayerController raises
4. Provide EventChannel implementation sketch

**Result:** ⚠️ NEEDS REVIEW — Event Channel migration recommended

---

### Example 2: Event Subscription Without Unsubscribe

**Scenario:** `OnEnable` subscribes to `PlayerDiedEvent.Subscribe(OnPlayerDied)` but `OnDisable` is missing the matching `Unsubscribe` call.

**Execution steps:**
1. Detect Subscribe without matching Unsubscribe
2. Flag as SAFETY — reference kept alive after disable, preventing GC
3. Provide matching `OnDisable` with `PlayerDiedEvent.Unsubscribe(OnPlayerDied)`

**Result:** ❌ FAIL — event leak must be fixed

---

### Example 3: Complex State Logic in Update

**Scenario:** `EnemyAI.Update()` has 4 nested if/else blocks checking `_isAggro`, `_isAttacking`, `_isRetreating`, `_isDead`.

**Execution steps:**
1. Detect 4+ state flags in Update conditional logic
2. Recommend StateMachine<EnemyAI> with AggroState, AttackState, RetreatState, DeadState
3. Provide IState interface and StateMachine<T> sketch

**Result:** ⚠️ NEEDS REVIEW — state machine migration strongly recommended

---

### Example 4: Correct Event Channel Usage

**Scenario:** `EnemySpawner` raises `EnemySpawnedEventChannel.Raise(enemy)` on spawn; `WaveManager` subscribes via ScriptableObject reference; Subscribe/Unsubscribe in OnEnable/OnDisable.

**Result:** ✅ PASS — Event Channel pattern correctly applied

---

### Example 5: Service Locator for AudioManager

**Scenario:** `PlayerController.Awake()` calls `ServiceLocator.Get<AudioManager>()` to retrieve the audio service registered at boot.

**Result:** ✅ PASS — Service Locator pattern correctly applied

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `[SerializeField] private AudioManager _audio` in PlayerController
✅ **Correct approach:** `JumpEventChannel.Raise()` — AudioManager subscribes to the event channel

❌ **Anti-pattern 2:** `AudioManager.Instance.PlaySFX(clip)` — singleton pattern
✅ **Correct approach:** `ServiceLocator.Get<AudioManager>().PlaySFX(clip)`

❌ **Anti-pattern 3:** `OnEnable` subscribes; `OnDisable` missing unsubscribe
✅ **Correct approach:** Matching Unsubscribe in every OnDisable for every OnEnable Subscribe

❌ **Anti-pattern 4:** 4+ state booleans toggled across multiple methods in Update
✅ **Correct approach:** `StateMachine<T>` with explicit `IState` implementations per state

❌ **Anti-pattern 5:** Undo implemented by storing previous values in the calling class
✅ **Correct approach:** `ICommand` with Execute/Undo; `CommandManager` history stack

❌ **Anti-pattern 6:** Cross-system C# static event (`AudioManager.OnSoundPlayed += ...`)
✅ **Correct approach:** ScriptableObject EventChannel asset subscribed via inspector reference

❌ **Anti-pattern 7:** Service Locator bypassed with direct `FindObjectOfType<Manager>()` in Awake
✅ **Correct approach:** Retrieve via `ServiceLocator.Get<Manager>()` after boot registration

❌ **Anti-pattern 8:** Different cross-system patterns mixed in the same project (some Event Channel, some singleton)
✅ **Correct approach:** Consistent pattern project-wide per DA-7; migrate or document exception

---

## Non-Goals

* ❌ Does not assess C# naming or lifecycle — use code-standards
* ❌ Does not assess DOTS system architecture — use dots-ecs
* ❌ Does not validate network authority model — use networking
* ❌ Does not enforce folder structure — use folder-structure

---

## Notes for LLM Implementation

1. **Provide the pattern sketch, not just the name** — when recommending Event Channel, show the ScriptableObject class template
2. **Distinguish notification (Event Channel) from retrieval (Service Locator)** — wrong pattern for the right problem is still a violation
3. **Apply DA-5 for small isolated systems** — do not require full pattern overhead for single-use utilities
4. **Event subscription leak is a SAFETY violation** — block, do not warn-only
5. **New patterns must align with existing ones per DA-7** — check the rest of the codebase before recommending a new pattern

**Output format preferences:**
* Code sketches for each recommended pattern
* Severity labels: SAFETY / ARCHITECTURE
* Required actions as checkboxes

---

## Metadata Summary

```yaml
name: architecture-patterns
category: Architecture
priority: High
depends_on: [code-standards]
flags_skills: []
rules_applied: [DA-1, DA-2, DA-3, DA-7]
documents_needed: [existing_architecture_decisions, project_system_map]
tags: [unity, architecture, event-channel, service-locator, state-machine, command-pattern]
```

**Key relationships:**
- Depends on: code-standards (lifecycle correctness, naming baseline)
- Flags: none — architectural gate
- Governed by: DA-1 (SOLID), DA-2 (business abstraction), DA-3 (conditional placement), DA-7 (consistency)
