# Skill Human Spec: Networking

```yaml
---
name: networking
description: Enforces Netcode for GameObjects conventions for NetworkVariables, RPC patterns, and spawn lifecycle management
version: 1.0.0
category: Architecture
tags: [unity, netcode, multiplayer, ngo, rpc, networkobject]
priority: Medium

depends_on: [code-standards, architecture-patterns]
flags_skills: []

inputs: [multiplayer_scripts, network_variable_declarations, rpc_methods, spawn_lifecycle_code]
outputs: [networking_assessment, violations_list, corrected_patterns, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-7   # Architectural Consistency
  - MF-5   # Reliability Rule
  - PC-5   # Correctness Priority

documents_needed: [netcode_for_gameobjects_docs, project_networking_architecture]

execution_context: Runs on any multiplayer script creation or modification; requires code-standards and architecture-patterns to have passed
---
```

---

# Skill: Networking

---

## Purpose

**What this skill does:**
Enforces Unity Netcode for GameObjects (NGO) conventions including explicit NetworkVariable permission declarations, server-side RPC validation, correct ClientRpc/ServerRpc usage patterns, and proper NetworkObject spawn lifecycle via OnNetworkSpawn and OnNetworkDespawn.

Prevents exploitable client-authoritative game state, reduces cheating surface area, and ensures multiplayer sessions remain stable and consistent across all connected clients.

Enforces server authority as the source of truth, ensures NetworkVariables have predictable read/write semantics, and makes spawn/despawn lifecycle explicit and deterministic.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Any NetworkBehaviour script is created or modified
* A NetworkVariable is declared without explicit permissions
* A ServerRpc or ClientRpc method is added or changed
* Initialization logic is placed outside OnNetworkSpawn
* A multiplayer bug involves desynchronised state
* Code review reveals client-authoritative patterns

### Do NOT use this skill for:

* Single-player code with no NetworkBehaviour inheritance
* Server-side only services with no client communication
* Non-multiplayer MonoBehaviour lifecycle issues (use code-standards)
* Transport layer or relay configuration

**Execution Context Details:**
Runs after code-standards and architecture-patterns have passed. Focuses exclusively on NGO-specific correctness — state authority, RPC safety, and spawn lifecycle.

---

## Inputs

**Required inputs:**

* **Multiplayer scripts** — NetworkBehaviour subclasses under review
* **NetworkVariable declarations** — All network state fields with their permission parameters
* **RPC methods** — All ServerRpc and ClientRpc method signatures and bodies

**Optional inputs:**

* **Project networking architecture doc** — Describes authoritative model (server/client/host) used

**Documents/Context needed:**

* **Netcode for GameObjects documentation** — For accurate API surface reference
* **Project authority model** — Which entities are server-authoritative vs client-predicted

---

## Outputs

**Primary outputs:**

* **Networking assessment** — Pass/Fail/Needs Review per NGO convention category
* **Violations list** — Each violation with location, severity, and corrected form
* **Corrected patterns** — Before/after code snippets
* **Approval status** — Whether script meets NGO standards

**Output format:**

* Structured report with sections per NGO concern (NetworkVariables, RPCs, lifecycle)
* Code blocks showing violation and fix

**Skill flags (if applicable):**

* No downstream flags — networking is a correctness gate

---

## Preconditions

**Conditions that must be met before execution:**

* Script compiles without errors
* code-standards has passed for the same script
* Script inherits from NetworkBehaviour (not plain MonoBehaviour)

**Validation checks:**

* [ ] Class inherits NetworkBehaviour
* [ ] NGO package is present in project manifest
* [ ] No legacy UNET/Mirror APIs are referenced

---

## Step-by-Step Execution Procedure

### Step 1: Validate NetworkVariable Declarations

**Questions to answer:**
- Does every NetworkVariable specify both read and write permission explicitly?
- Is server write / everyone read the correct default for this variable?

**Actions:**
- [ ] Identify all `NetworkVariable<T>` field declarations
- [ ] Verify each has `NetworkVariableReadPermission` and `NetworkVariableWritePermission` parameters
- [ ] Check that server-only state uses `NetworkVariableWritePermission.Server`
- [ ] Flag any `new NetworkVariable<T>(value)` without explicit permissions

**Red flags / Warning signs:**
- `NetworkVariable<int>` constructed with only a default value, no permissions
- Client write permission on game-critical state (health, score)

**Decision points:**
- If missing permissions: block, show full constructor with explicit params
- If client write on critical state: block, request design review

---

### Step 2: Validate ServerRpc Patterns

**Questions to answer:**
- Does every ServerRpc validate its inputs before applying state changes?
- Is the ServerRpc only handling client requests, not server-initiated logic?

**Actions:**
- [ ] Identify all `[ServerRpc]` methods
- [ ] Verify server-side validation exists before any state mutation
- [ ] Check that no state is applied directly from RPC parameter without sanitisation
- [ ] Flag ServerRpcs that trust client input unconditionally

**Red flags / Warning signs:**
- `_health.Value = damage;` directly from RPC parameter without bounds check
- ServerRpc performing actions that should be server-initiated (use ClientRpc instead)

**Decision points:**
- If no validation: block, request guard conditions on RPC body
- If wrong RPC type: warn, suggest ClientRpc or server-only method

---

### Step 3: Validate ClientRpc Patterns

**Questions to answer:**
- Is ClientRpc used only for server-to-client notifications?
- Are ClientRpcs avoiding any state that should be a NetworkVariable?

**Actions:**
- [ ] Identify all `[ClientRpc]` methods
- [ ] Verify they are called from server context only
- [ ] Check they do not set state that belongs in a NetworkVariable
- [ ] Flag ClientRpcs called from client code

**Red flags / Warning signs:**
- ClientRpc called from within another ClientRpc
- Client state being set via ClientRpc when NetworkVariable would be appropriate

**Decision points:**
- If client-called ClientRpc: block, explain server-only context requirement

---

### Step 4: Validate Spawn Lifecycle

**Questions to answer:**
- Is all network initialization in OnNetworkSpawn and cleanup in OnNetworkDespawn?
- Is Start or Awake used for network state that is not yet ready?

**Actions:**
- [ ] Identify all initialization logic in Awake/Start that references NetworkVariables or IsOwner
- [ ] Verify initialization moved to OnNetworkSpawn override
- [ ] Verify cleanup in OnNetworkDespawn override
- [ ] Flag use of IsOwner or IsServer outside OnNetworkSpawn context

**Red flags / Warning signs:**
- `if (IsOwner)` check in `Start()` — ownership not guaranteed at Start
- NetworkVariable.Value read in `Awake()` before spawn

**Decision points:**
- If lifecycle outside spawn: warn, provide OnNetworkSpawn migration example

---

### Final Step: Generate Networking Report

```markdown
## Networking Report

**Target:** [ClassName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### NetworkVariable Declarations
[Finding per variable]

### ServerRpc Validation
[Finding per RPC]

### ClientRpc Usage
[Finding per RPC]

### Spawn Lifecycle
[Finding per lifecycle method]

### Overall Assessment
- ✅ PASS: All authority and lifecycle patterns correct
- ❌ FAIL: Unvalidated ServerRpc or missing permissions
- ⚠️ NEEDS REVIEW: Lifecycle placement warnings

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce explicit NetworkVariable read/write permission declarations
2. Require server-side validation in all ServerRpc methods before state mutation
3. Enforce ClientRpc as server-to-client notification only
4. Enforce OnNetworkSpawn/OnNetworkDespawn for all network-dependent initialization and cleanup
5. Reject any client-authoritative state modification

**Quality criteria:**

* Zero NetworkVariables constructed without explicit permission parameters
* Every ServerRpc has guard conditions validating input before applying state
* No IsOwner/IsServer checks in Awake or Start

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: NetworkBehaviour classes should have single network concerns; avoid mixing game logic with network state management in one class
  - In practice: A `PlayerNetworkState` class manages network variables; a `PlayerController` handles input — not one class for both

* **DA-7: Architectural Consistency**
  - Applies: The project's authority model (server-authoritative) must be consistent across all NetworkBehaviours
  - In practice: If health is server-authoritative in enemies, it must be in players too

### Maintenance & Feature Consistency Rules

* **MF-5: Reliability**
  - Applies: Multiplayer state must fail safely; network disconnects must leave the game in a consistent state
  - In practice: OnNetworkDespawn must clean up subscriptions and state references

### Performance & Complexity Rules

* **PC-5: Correctness Priority**
  - Applies: Client input must never be trusted without server validation; correctness over convenience
  - In practice: Even if validation slows RPC handling, it is mandatory for authoritative state

---

## Tradeoff Handling

### Tradeoff 1: Server Validation Overhead vs. Responsiveness

**Scenario:** Strict server validation adds latency to all player actions.

**Default stance:** Correctness first — validation is mandatory. Client-side prediction is a separate concern and does not bypass server validation.

**Resolution process:**
1. Flag the latency concern
2. Recommend client-side prediction as a complementary pattern (not a replacement for validation)
3. Document the tradeoff via DT-1

---

### Tradeoff 2: NetworkVariable vs. RPC for State Sync

**Scenario:** Developer chooses ClientRpc to sync state that changes frequently.

**Default stance:** NetworkVariable is preferred for persistent state; RPC is for events/triggers.

**Resolution process:**
1. Classify: is this persistent state or a one-time event?
2. If persistent: recommend NetworkVariable
3. If event: ClientRpc is appropriate

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Client-Authoritative State Detected

**Trigger:** Game state (health, position, score) is set directly by client without server involvement.

**Action:**
- Block — this is a security and correctness violation
- Request redesign to server-authoritative model
- Log via DT-1

---

### Escalation Scenario 2: Missing NGO Package

**Trigger:** NetworkBehaviour referenced but NGO package not in manifest.

**Action:**
- Halt execution
- Request package installation before assessment

---

### Escalation Scenario 3: Ambiguous Authority Model

**Trigger:** Project mixes server-authoritative and client-authoritative patterns across different systems.

**Action:**
- Surface inconsistency
- Request a single authority model decision documented via DT-1

---

### When to halt execution:

* Script does not inherit NetworkBehaviour — wrong skill
* NGO package is absent from the project
* No clear authority model exists and the team has not decided one

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards and architecture-patterns on multiplayer scripts. Acts as a network correctness gate.

**Integration workflow:**
1. code-standards passes on the script
2. architecture-patterns passes (confirming decoupled design)
3. Orchestrator invokes networking
4. networking outputs assessment and blocks on violations
5. Orchestrator proceeds to testing-standards after pass

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No flags — networking is a correctness gate | — | — |

---

### Flag Format in Report

```markdown
### Skills Flagged for Follow-up
(none — networking is terminal in its validation chain)
```

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Ensures MonoBehaviour lifecycle correctness before network-layer assessment; OnNetworkSpawn ordering relies on clean lifecycle
* **architecture-patterns** — Ensures decoupled design (Event Channels, Service Locator) is in place before validating network state management

**Skills this skill cooperates with:**

* **performance-optimization** — NetworkVariable change callbacks and RPC frequency can affect performance; cooperates when RPCs are high-frequency

**Skills this skill may invoke/flag:**

* None — acts as a blocking gate

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Log all authority model deviations via DT-1
* [ ] Block on unvalidated ServerRpc — never allow with warning only
* [ ] Explain security implications of client-authoritative state before requesting fix
* [ ] Do not proceed past NetworkVariable permission violations
* [ ] Document all exceptions and special cases

**Audit trail requirements:**

* Authority model decisions must be logged via DT-1
* Any approved deviation from server-authoritative model requires documented rationale

---

## Example Use Cases

### Example 1: Missing NetworkVariable Permissions

**Scenario:** `EnemyHealth.cs` declares `NetworkVariable<int> _health = new NetworkVariable<int>(100);`

**Execution steps:**
1. Scan NetworkVariable declarations — found one without permissions
2. Flag: missing `NetworkVariableReadPermission` and `NetworkVariableWritePermission`
3. Provide fix: `new NetworkVariable<int>(100, NetworkVariableReadPermission.Everyone, NetworkVariableWritePermission.Server)`

**Result:** ❌ FAIL — permissions required before merge

---

### Example 2: Unvalidated ServerRpc

**Scenario:** `TakeDamageServerRpc(int damage)` applies damage directly: `_health.Value -= damage;`

**Execution steps:**
1. Inspect ServerRpc body — no guard on `damage` value
2. Flag: client can send negative damage (healing exploit) or overflow value
3. Provide fix: `if (damage < 0 || damage > MaxDamage) return;`

**Result:** ❌ FAIL — validation required

---

### Example 3: Compliant NetworkBehaviour

**Scenario:** Full `PlayerNetworkState.cs` with explicit permissions, validated ServerRpc, OnNetworkSpawn initialization.

**Result:** ✅ PASS — all NGO conventions met

---

### Example 4: Initialization in Start Instead of OnNetworkSpawn

**Scenario:** `if (IsOwner) { EnableInput(); }` placed in `Start()`.

**Execution steps:**
1. Flag: IsOwner unreliable in Start; network spawn not guaranteed
2. Provide migration to OnNetworkSpawn override

**Result:** ⚠️ NEEDS REVIEW — functional risk in some topologies

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `NetworkVariable<int> _health = new NetworkVariable<int>(100);` — no permissions
✅ **Correct approach:** Always specify `NetworkVariableReadPermission` and `NetworkVariableWritePermission` explicitly

❌ **Anti-pattern 2:** Applying ServerRpc parameters to state without validation
✅ **Correct approach:** Guard all RPC inputs: `if (value < 0 || value > max) return;`

❌ **Anti-pattern 3:** `if (IsOwner)` check in `Start()`
✅ **Correct approach:** All ownership-dependent logic in `OnNetworkSpawn` override

❌ **Anti-pattern 4:** ClientRpc called from client code
✅ **Correct approach:** ClientRpc is server-only; use `[ServerRpc]` for client requests

❌ **Anti-pattern 5:** Using ClientRpc to sync persistent state that changes every frame
✅ **Correct approach:** Use `NetworkVariable<T>` for persistent replicated state

❌ **Anti-pattern 6:** Network initialization logic in `Awake()` before spawn
✅ **Correct approach:** All network-dependent init in `OnNetworkSpawn()`

❌ **Anti-pattern 7:** No cleanup in `OnNetworkDespawn`
✅ **Correct approach:** Unsubscribe events and clear references in `OnNetworkDespawn()`

❌ **Anti-pattern 8:** Trusting `NetworkObject.IsSpawned` in `Awake()`
✅ **Correct approach:** IsSpawned is only reliable after `OnNetworkSpawn` fires

❌ **Anti-pattern 9:** Client directly modifying a NetworkVariable value
✅ **Correct approach:** Client sends ServerRpc; server modifies NetworkVariable

---

## Non-Goals

* ❌ Does not configure transport layers or relay servers — infrastructure concern
* ❌ Does not assess MonoBehaviour lifecycle unrelated to networking — use code-standards
* ❌ Does not validate overall multiplayer architecture — use architecture-patterns
* ❌ Does not test connectivity or session management at runtime

---

## Notes for LLM Implementation

1. **Always block on unvalidated ServerRpc** — this is a security issue, not a style issue
2. **Distinguish state from events** — NetworkVariable for state, RPC for events/triggers
3. **Explain the exploit** — when flagging client-authoritative patterns, explain the specific cheat vector
4. **Always show OnNetworkSpawn migration** when lifecycle is outside spawn
5. **Do not penalize host-mode patterns** — IsServer and IsClient can both be true in host mode

**Output format preferences:**
* Code blocks for every fix
* Severity labels: SECURITY / CORRECTNESS / LIFECYCLE
* Required actions as checkboxes

**Special considerations:**
* Host mode (IsServer + IsClient == true) is a valid topology; do not flag it
* Clientside prediction is out of scope — do not flag its absence

---

## Metadata Summary

```yaml
name: networking
category: Architecture
priority: Medium
depends_on: [code-standards, architecture-patterns]
flags_skills: []
rules_applied: [DA-1, DA-7, MF-5, PC-5]
documents_needed: [netcode_for_gameobjects_docs, project_networking_architecture]
tags: [unity, netcode, multiplayer, ngo, rpc, networkobject]
```

**Key relationships:**
- Depends on: code-standards (lifecycle baseline), architecture-patterns (decoupled design)
- Flags: none — correctness gate
- Governed by: DA-1 (clean code), DA-7 (consistency), MF-5 (reliability), PC-5 (correctness first)
