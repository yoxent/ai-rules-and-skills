```yaml
---
name: modularity
description: Decomposes system components into cohesive, loosely coupled modules with explicit interfaces and single-responsibility boundaries at architectural scale.
version: 1.1.0
category: Architecture
tags: [modularity, cohesion, coupling, interfaces, boundaries]
priority: High
depends_on: [system-design]
flags_skills: [dependency-management, refactoring, abstraction-domain-modeling, api-design, technical-debt-management]
inputs: [system-architecture-draft, domain-model, feature-boundaries, existing-module-structure]
outputs: [module-map, interface-definitions, responsibility-matrix, boundary-violation-report]
rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-2   # Abstraction by Business Meaning
  - DA-4   # Change Boundary Rule
  - DA-5   # Avoid Overengineering
  - DA-7   # Architectural Consistency
  - DT-1   # Explicit Tradeoff Logging
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency
documents_needed: [system-architecture, domain-model, feature-boundaries]
execution_context: Runs after System Design to define internal module structure, or when existing modules accumulate unrelated responsibilities or exhibit boundary violations.
---
```

---

# Skill: Modularity

---

## Purpose

**What this skill does:**
Modularity applies the Single Responsibility Principle at the architectural scale: decomposing a system's components into cohesive modules with explicit interfaces, minimal cross-module dependencies, and clear ownership of domain responsibilities. It defines what belongs inside each module, what the module exposes, and what it depends upon.

Poorly modularized systems slow delivery: changes cascade unexpectedly, bugs are harder to isolate, and onboarding takes longer with no clear boundaries. Good modularity compounds positively — delivery velocity remains sustainable as the system grows.

Clean module boundaries enable parallel development, independent testing, independent deployment (when appropriate), and clean code ownership. Each module can evolve independently as long as its interface contract is preserved. This dramatically reduces the blast radius of any change and makes refactoring tractable.

---

## When to Use This Skill

### Triggers (Use this skill when):

* System Design has defined component boundaries and those components need internal structure
* An existing module has grown to the point where it handles multiple unrelated concerns
* A new feature crosses what should be a module boundary, suggesting the boundary is wrong
* Code review reveals that changes to one module frequently require changes to another
* Test coverage is difficult to achieve because modules are too tightly coupled to test in isolation
* A "god class" or "god module" has accumulated responsibilities from multiple domains
* The team debates where new code "belongs" — indicating missing or unclear boundaries

### Do NOT use this skill for:

* Top-level system component definition (use System Design for that)
* Code-level class design within a module (use Clean Code & SOLID, Design Pattern Selection)
* Designing the external API surface of a service (use API Design)
* Executing the refactoring required to fix modularity violations (use Refactoring)

**Execution Context Details:**
Modularity runs after System Design, which establishes the component-level map. Modularity zooms into each component and defines its internal module structure. It is often paired with Dependency Management (which validates that the module dependency graph is clean) and API Design (which formalizes module interface contracts). When invoked for existing systems, it is frequently followed by Refactoring.

---

## Inputs

**Required inputs:**

* **System architecture draft** — The component map from System Design. Defines the components within which module boundaries will be drawn. Modularity cannot proceed without knowing the component-level context.
* **Domain model** — The business domain entities, aggregates, and bounded contexts that should map to module boundaries. The domain model is the primary guide for module decomposition.
* **Feature boundaries** — The scope of current and planned features. Used to ensure module boundaries do not create friction for foreseeable feature development.

**Optional inputs:**

* **Existing module structure** — For re-modularization of existing systems: the current module layout, import graph, and identified pain points. Needed for gap analysis between intended and actual structure.
* **Team structure** — How the engineering teams are organized. Influences which module boundaries are practical to maintain (Conway's Law consideration).

---

## Outputs

**Primary outputs:**

* **Module map** — A complete listing of modules within each system component, with single-sentence responsibility statements and their interface contracts (what they expose). Analogous to a table of contents for the system's internal structure.
* **Interface definitions** — Explicit definitions of what each module exposes to other modules: functions, types, events, or service contracts. Unexported concerns are documented as internal-only.
* **Responsibility matrix** — A mapping of which module owns each domain concern. Ensures no concern is owned by multiple modules (overlap) and no concern is unowned (gap).
* **Boundary violation report** — For existing systems: identification of where current code violates the intended module boundaries, with severity classification and recommended remediation path.

**Output format:**

* Module map should be machine-readable (table or structured list) and human-readable
* Interface definitions include the module name, what it exports, and what it prohibits from export
* Responsibility matrix calls out overlaps and gaps explicitly — neither is acceptable without deliberate justification

**Skill flags (if applicable):**

* Flag **dependency-management** when module boundaries reveal cross-module coupling that the dependency graph must validate
* Flag **refactoring** when existing code must be reorganized to conform to the module boundaries defined
* Flag **abstraction-domain-modeling** when module responsibilities reveal domain modeling ambiguities that need resolution
* Flag **api-design** when a module's interface is an external-facing API contract complex enough to warrant formal API design
* Flag **technical-debt-management** when existing boundary violations are too numerous to fix immediately and must be tracked

---

## Preconditions

**Conditions that must be met before execution:**

* System Design has established the component boundaries within which modules will be defined
* The domain model (or a working understanding of domain concepts) is available
* For existing systems: the current module structure is accessible for analysis

**Validation checks:**

* [ ] Component-level architecture is defined (from System Design or existing documentation)
* [ ] Domain model entities and bounded contexts are identifiable
* [ ] Scope of modularization is agreed (full system, specific component, new feature)

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:**
- [ ] Determine whether this invocation involves existing code (not a greenfield design).
- [ ] If existing code is in scope → flag **refactoring** → co-invoke before planning begins.

*Pure greenfield design invocations (no existing code to reorganize) do not trigger co-invocation.*

---

### Step 1: Domain Decomposition Within Components

**Questions to answer:**
- What are the distinct domain concepts within each system component?
- Which concepts naturally belong together (high cohesion)?
- Which concepts are logically separable (enabling low coupling)?
- Is there existing code to analyze, or are we designing from scratch?

**Actions:**
- [ ] For each system component: list all domain concepts it handles
- [ ] Group concepts by semantic relatedness — concepts that change together, are understood together, and serve the same domain function
- [ ] Apply DA-2: group by business meaning, not technical function
- [ ] Draft a candidate module list with one-sentence responsibility statements per module

**Red flags / Warning signs:**
- A candidate module's responsibility statement requires "and" to be complete — two responsibilities means two modules
- Domain concepts from different bounded contexts lumped into one module (cross-domain coupling)
- Technical groupings (e.g., "all database access") rather than domain groupings (e.g., "order persistence")

**Decision points:**
- If a concept could belong to two candidate modules, apply DA-4: assign it to the module whose business responsibility encompasses it, not the module that currently happens to use it most

---

### Step 2: Define Module Interface Contracts

**Questions to answer:**
- What does each module need to expose to other modules in order to fulfill the system's responsibilities?
- What must each module keep internal to protect its implementation from external coupling?
- Are there circular interface dependencies (Module A's interface depends on types from Module B's interface, which depends on types from Module A)?

**Actions:**
- [ ] For each module: define the explicit public interface (exported functions, types, events, commands)
- [ ] Mark everything not in the public interface as private/internal — default to private
- [ ] Verify no circular interface dependencies exist (if they do, a shared types module or interface redesign is needed)
- [ ] Validate that public interfaces are defined by consumer need, not by implementation convenience

**Red flags / Warning signs:**
- Interface exposes internal implementation types (leaky abstraction)
- Interface is larger than necessary — most of the exposed surface is used by only one consumer (over-exposure)
- Interface requires consumers to understand module internals to use it correctly

**Decision points:**
- If an interface is large, identify whether this indicates the module has too many responsibilities (split it) or that it legitimately serves many consumers (acceptable if cohesive)
- If interface types create circular dependencies, flag abstraction-domain-modeling for shared type redesign

---

### Step 3: Dependency Direction Validation

**Questions to answer:**
- Do module dependencies flow in one direction (high-level → low-level, domain → infrastructure)?
- Are there any modules that depend on higher-level modules than themselves (dependency inversion violation)?
- Do infrastructure/utility modules depend on domain modules? (They should not — this inverts the dependency direction.)

**Actions:**
- [ ] Map the directed dependency graph of the proposed module structure
- [ ] Verify dependencies flow from high-level (domain, application) to low-level (infrastructure, utilities)
- [ ] Identify any upward dependencies (infrastructure importing domain concepts) and flag them
- [ ] Apply DA-1: dependency direction should follow the Dependency Inversion Principle

**Red flags / Warning signs:**
- An infrastructure module (e.g., database access layer) imports domain types directly — creates coupling that prevents infrastructure from being swapped
- A utility module imports application-layer concepts — utilities should be domain-agnostic
- A module at the domain layer imports a module at the infrastructure layer without an abstraction boundary

**Decision points:**
- Every upward dependency requires either introducing an abstraction (interface/protocol) or reassigning the concern to the correct layer
- Flag dependency-management when upward dependencies are complex to resolve

---

### Step 4: Existing System Boundary Violation Analysis

*(Skip for greenfield designs — applicable to existing systems only)*

**Questions to answer:**
- Where does existing code violate the intended module boundaries?
- Which violations are structural (code in the wrong module) vs. coupling violations (correct module, wrong dependency)?
- What is the severity and remediation effort for each violation?

**Actions:**
- [ ] Map the actual import/dependency graph of the existing codebase
- [ ] Compare against the intended module map from Step 1-3
- [ ] Classify violations: BLOCKING (prevents independent testing or deployment), HIGH (creates significant coupling risk), MEDIUM (reduces cohesion), LOW (cosmetic misplacement)
- [ ] Prioritize violations by severity and remediation effort

**Red flags / Warning signs:**
- A module with more imports from other modules than internal references — indicates it is a coordination layer, not a cohesive domain module
- A module that is imported by every other module — hidden shared state or utility accumulation
- Violations that span domain boundaries (cross-domain coupling) are higher severity than within-domain violations

**Decision points:**
- BLOCKING violations must be escalated and remediation planned before new feature work proceeds
- HIGH/MEDIUM violations should be logged in technical debt and scheduled
- If violations are numerous, flag technical-debt-management for systematic planning

---

### Final Step: Generate Modularity Report

```markdown
## Modularity Report

**Component / System:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ⚠️ NEEDS ATTENTION / ❌ BLOCKED

### Module Map
| Module | Responsibility | Public Interface (exports) | Dependencies |
|--------|---------------|--------------------------|--------------|
| [Name] | [One sentence] | [What it exposes] | [Other modules] |

### Responsibility Matrix
| Domain Concern | Owning Module | Overlap? | Gap? |
|---------------|---------------|---------|------|
| [Concern] | [Module] | [Yes/No] | [Yes/No] |

### Dependency Direction Assessment
- ✅ / ❌ Dependencies flow high-level → low-level
- Violations: [List any upward dependency violations]

### Boundary Violations (Existing Systems)
| Violation | Modules Involved | Severity | Remediation |
|-----------|-----------------|----------|-------------|
| [Description] | [A, B] | [BLOCKING/HIGH/MED/LOW] | [Action] |

### Skills Flagged for Follow-up
- **[Skill]**: [Specific reason]

### Overall Assessment
- ✅ PASS: Module boundaries are clean, interfaces are well-defined, no blocking violations
- ⚠️ NEEDS ATTENTION: Non-blocking violations logged, remediation planned
- ❌ BLOCKED: Blocking violations prevent safe development — must be resolved first

### Required Actions
- [ ] [Action with owner and priority]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Decompose components into cohesive modules aligned with domain boundaries (DA-2)
2. Define explicit interface contracts for each module — default to private
3. Validate dependency direction (high-level → low-level only)
4. For existing systems: identify and classify boundary violations with remediation priorities
5. Produce a responsibility matrix that eliminates ownership ambiguity
6. Flag downstream skills for coupling validation, refactoring, and interface formalization

**Quality criteria:**

* Every module has a one-sentence responsibility statement containing no conjunctions ("and")
* No module's public interface exposes internal implementation types
* No responsibility is owned by more than one module
* No responsibility is unowned (gap)
* Dependency graph is acyclic and directionally consistent

---

## Constraints (Rules Applied)

* **DA-1: SOLID & Clean Code First** — SRP at module level: one reason to change. Dependency Inversion: modules depend on abstractions, not on other modules' concrete implementations.

* **DA-2: Abstraction by Business Meaning** — Module boundaries must reflect domain concerns, not technical function. "UserDatabaseAccess" is a technical boundary; "UserProfile" (including persistence) is a domain boundary — the latter is correct.

* **DA-4: Change Boundary Rule** — A module should only change when its own business responsibility changes. If a module changes because a different module's concern changed, there is a coupling violation.

* **DA-5: Avoid Overengineering** — Do not create modules for speculative future decomposition. Every boundary must be justified by a current domain separation.

* **DA-7: Architectural Consistency** — Module naming and boundary conventions must be consistent across the codebase. A different modularization pattern in one component creates team-wide confusion.

* **DT-1: Explicit Tradeoff Logging** — Any module boundary compromise must be logged with rationale and a time-boxed remediation plan.

---

## Tradeoff Handling

### Tradeoff 1: Granularity vs. Coordination Overhead

**Scenario:** Very fine-grained modules (one concern per module) are maximally cohesive but increase the number of inter-module interfaces and coordination overhead for development.

**Default stance:** Lean toward fewer, more cohesive modules. Fine-grained decomposition is only justified when the domain genuinely separates concerns AND when independent evolution/deployment is a requirement.

**Resolution process:**
1. Identify the business driver for fine granularity — is independent deployment needed? Do different teams own different modules?
2. If yes: fine granularity is justified; define clear interfaces and accept the coordination cost
3. If no: merge closely related concerns into a single module with internal sub-structure
4. Log the granularity decision per DT-1

---

### Tradeoff 2: Strict Boundaries vs. Development Speed

**Scenario:** Enforcing strict module boundaries early in a project slows down feature development because every cross-module interaction requires interface design.

**Default stance:** Define boundaries explicitly from the start, even if interfaces are initially simple. Retroactive modularization is far more expensive than proactive boundary definition.

**Resolution process:**
1. Accept that initial interface design adds upfront cost
2. Keep interfaces minimal early — expose only what is demonstrably needed
3. Avoid exceptions to boundaries "just for now" — every exception becomes permanent coupling
4. If delivery pressure is extreme, accept a temporary exception, log it as debt per MF-2, and set a remediation sprint

---

### Tradeoff 3: Reusability vs. Coupling

**Scenario:** A shared module that is used by many other modules enables code reuse but becomes a high-fan-in bottleneck that is difficult to change.

**Default stance:** Prefer duplication over coupling for domain-specific logic. Shared modules should be reserved for genuinely domain-agnostic utilities.

**Resolution process:**
1. Evaluate whether the shared concern is truly domain-agnostic (e.g., date formatting) or domain-specific (e.g., pricing logic)
2. Domain-agnostic shared modules are acceptable; domain-specific shared modules indicate a missing bounded context
3. If a shared module accumulates domain-specific logic, it should be decomposed and ownership assigned to the correct domain module
4. Log per DT-1

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Module Has Multiple Unresolvable Responsibilities

**Trigger:** A module handles concerns from multiple business domains and the team cannot agree on a decomposition because the domains are genuinely coupled in the current design.

**Action:**
- Document the specific responsibilities and the domain boundary conflict
- Flag abstraction-domain-modeling for domain model clarification
- Escalate to stakeholder: domain boundary disputes are business decisions, not engineering decisions

---

### Escalation Scenario 2: Boundary Violations Too Numerous to Fix Immediately

**Trigger:** Existing system analysis reveals extensive boundary violations that cannot be resolved within the current sprint or release cycle.

**Action:**
- Classify all violations by severity
- Escalate BLOCKING violations for immediate resolution
- Flag technical-debt-management for systematic planning of HIGH/MEDIUM violations
- Produce a debt register entry per MF-2 for all violations not immediately fixed

---

### Escalation Scenario 3: Circular Module Dependencies

**Trigger:** The proposed or existing module structure contains circular dependencies.

**Action:**
- Block approval immediately — circular module dependencies are never acceptable
- Identify the minimum cut to break the cycle
- Flag dependency-management for coupling resolution
- Recommend abstraction strategy (shared types module, event-based decoupling, interface extraction)

---

### When to halt execution:

* System Design has not established component boundaries — Modularity cannot proceed without component-level context
* Domain model is entirely absent — module boundary placement requires domain knowledge
* Circular module dependencies exist and no break strategy is identified — halt until resolved

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Modularity runs after System Design and produces the internal module structure that Dependency Management validates and API Design formalizes. For existing systems, Modularity analysis frequently triggers Refactoring.

### How This Skill Integrates

**Does NOT directly call other skills.** This skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes Modularity after System Design completes (or on existing system trigger)
2. Skill performs domain decomposition, interface definition, dependency direction validation, and boundary violation analysis
3. Skill **outputs flags** for dependency-management, refactoring, api-design, etc.
4. **Orchestrator** invokes flagged skills based on findings

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|-------------------|-----------------|---------|
| Cross-module coupling risks in dependency graph | dependency-management | Validate that dependency graph matches intended module structure |
| Existing boundary violations require code reorganization | refactoring | Module restructuring requires code movement and interface changes |
| Domain model ambiguity prevents clear boundary placement | abstraction-domain-modeling | Domain model needs clarification before boundaries can be finalized |
| Module's external-facing API interface is complex enough to warrant formal design | api-design | External API contract needs formal design treatment |
| Boundary violations too numerous for immediate remediation | technical-debt-management | Violations must be tracked and scheduled |

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides the component-level architecture that Modularity refines into module-level structure. Modularity cannot define internal module boundaries without knowing the component context.

**Skills this skill cooperates with:**

* **dependency-management** — Validates that the module dependency graph is clean. Modularity defines intended boundaries; Dependency Management verifies the actual import graph respects them.
* **abstraction-domain-modeling** — Provides domain model input for boundary placement. When domain boundaries are ambiguous, these skills collaborate to resolve the ambiguity.
* **api-design** — Formalizes module interface contracts that Modularity defines.

**Skills this skill may invoke/flag:**

* **dependency-management** — When coupling analysis is needed to validate the module graph
* **refactoring** — When existing code must be reorganized to conform to module boundaries
* **abstraction-domain-modeling** — When domain model ambiguity prevents boundary decisions
* **api-design** — When module interfaces are complex and need formal design
* **technical-debt-management** — When boundary violations are numerous and must be tracked

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Validate every module boundary against DA-2 — domain meaning, not technical function
* [ ] Assign ownership of every domain concern to exactly one module — no overlaps, no gaps
* [ ] Log all boundary tradeoffs and deliberate exceptions per DT-1
* [ ] Escalate domain boundary disputes to stakeholder — they are business decisions
* [ ] Never proceed with circular module dependencies — block until resolved
* [ ] Document remediation plan for all boundary violations not fixed immediately

**Audit trail requirements:**

* All identified boundary violations must be logged (even if subsequently resolved)
* All deliberate boundary compromises must have documented rationale and remediation timeline
* All module interface decisions must be traceable to consumer requirements (not implementation convenience)

---

## Example Use Cases

### Example 1: Decomposing an E-Commerce Order Component

**Scenario:** An e-commerce system's "Order" component has grown to include order creation, payment processing, inventory reservation, fulfillment tracking, and customer notification logic — all in a single module.

**Inputs provided:**
- Existing Order component codebase
- Domain model: Order, Payment, Inventory, Fulfillment, Notification are distinct bounded contexts

**Execution steps:**
1. Domain decomposition: OrderLifecycle (creation, state machine), PaymentProcessing (charge, refund, dispute), InventoryReservation (check, hold, release), FulfillmentTracking (ship, track, deliver), CustomerNotification (email, SMS triggers)
2. Interface definition: OrderLifecycle exposes `createOrder()`, `cancelOrder()`, `getOrderStatus()`. It does not expose internal order state machine transitions.
3. Dependency direction: CustomerNotification depends on OrderLifecycle (subscribes to events) — correct. OrderLifecycle must NOT depend on CustomerNotification.
4. Current code analysis: OrderLifecycle directly calls NotificationService — violation (downward coupling inverted). Must be decoupled via event emission.

**Result:** ⚠️ NEEDS ATTENTION — Structure defined, one boundary violation to fix

**Skills flagged:** refactoring (OrderLifecycle → NotificationService coupling must be decoupled via events), dependency-management (validate new module graph)

---

### Example 2: Greenfield Module Design for Authentication Component

**Scenario:** Designing the internal module structure of a new Authentication component before implementation begins.

**Inputs provided:**
- System Design output: Authentication is a standalone component
- Domain model: identity, credentials, sessions, permissions are distinct concerns

**Execution steps:**
1. Candidate modules: IdentityManagement (user lifecycle), CredentialStore (password, MFA), SessionManagement (token issuance, validation), PermissionsRegistry (role assignments, policy evaluation)
2. Interface contracts: CredentialStore exports `verifyCredentials()`, `updatePassword()` — internal encryption is unexposed. SessionManagement exports `issueToken()`, `validateToken()`, `revokeSession()`.
3. Dependency direction: IdentityManagement depends on CredentialStore and SessionManagement — correct. CredentialStore must NOT depend on IdentityManagement.
4. No boundary violations (greenfield) — all modules cleanly defined.

**Result:** ✅ PASS — Module map complete, interfaces defined, dependency direction clean

**Skills flagged:** api-design (SessionManagement token interface is complex, warrants formal design), dependency-management (validate graph after implementation)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Technical Layer Modules**
Modules named and organized by technical function ("Repository", "Service", "Controller", "Utils") rather than domain concern. These accumulate unrelated domain logic under a technical umbrella.
✅ **Correct approach:** Name modules after the domain concept they serve ("OrderRepository" is still wrong — "OrderPersistence" within "Order" module is better; "Order" as a module containing its own persistence logic is often best).

❌ **Anti-pattern 2: God Module**
A single module accumulating responsibilities from multiple domains — typically the "main" module or a "common" module that becomes the default home for anything that doesn't have an obvious place.
✅ **Correct approach:** Every new responsibility must be explicitly assigned to the module whose domain it belongs to. If it belongs nowhere, that is a signal to create a new module, not to dump it in "common".

❌ **Anti-pattern 3: Anemic Module Interfaces**
A module exposes all of its internal types and functions without a deliberate interface contract — essentially no encapsulation. Every function is public; every type is exported.
✅ **Correct approach:** Default to private. Every exported symbol requires a justification: which consumer uses it, and why must it be public rather than accessed through a higher-level abstraction.

❌ **Anti-pattern 4: Leaky Abstractions**
A module's public interface exposes internal implementation types, requiring consumers to understand the module's internals to use it. When the implementation changes, all consumers break.
✅ **Correct approach:** Interface types should be defined independently of implementation. If the interface references an internal ORM model, it is a leaky abstraction.

❌ **Anti-pattern 5: Implicit Shared State**
Modules sharing mutable state through a global variable, a singleton, or a shared database table written by multiple modules. The shared state creates hidden coupling that makes the module interaction unpredictable.
✅ **Correct approach:** State ownership must be explicit. Exactly one module owns each piece of state. Other modules access it through the owning module's interface.

❌ **Anti-pattern 6: Premature Decomposition**
Breaking a module into sub-modules before the domain is understood well enough to define stable boundaries. This creates boundaries that must be immediately redesigned when the domain model clarifies.
✅ **Correct approach:** Start with fewer, larger modules with clear domain alignment. Decompose only when a module demonstrably has multiple distinct reasons to change.

❌ **Anti-pattern 7: Interface by Implementation**
Designing a module interface to match how the implementation works internally rather than what the consumer needs. Results in leaky, unstable interfaces that break consumers when implementation details change.
✅ **Correct approach:** Design interfaces from the consumer's perspective: what does the consumer need to accomplish, and what is the minimal interface that serves that need?

❌ **Anti-pattern 8: Cross-Domain Module Dependencies Without Abstraction**
Module A in Domain 1 directly imports Module B in Domain 2, creating tight cross-domain coupling. Changes in Domain 2 ripple into Domain 1.
✅ **Correct approach:** Cross-domain dependencies must be mediated by abstraction: events, interfaces, or shared kernel types. Direct imports across domain boundaries are forbidden.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ **Top-level system component definition** — That is System Design's responsibility. Modularity works within components.
* ❌ **Code-level class and method design** — Clean Code & SOLID and Design Pattern Selection handle code-level structure within modules.
* ❌ **External API surface design** — API Design handles the formal design of service-level APIs. Modularity defines internal module interfaces.
* ❌ **Executing module reorganization refactors** — Refactoring executes. Modularity defines the target structure.
* ❌ **Version management of module interfaces** — Versioning handles module/API versioning strategy.

---

## Notes for LLM Implementation

1. **Enforce the one-sentence rule**: Every module must have a responsibility statement with no conjunctions. If it can't be stated that way, split the module.
2. **Default to private**: Start with nothing exported; add only what is justified by consumer need.
3. **Trace every boundary to the domain model**: Every boundary decision must trace to a specific domain concept, not a technical convenience.
4. **Be explicit about overlaps and gaps**: In the responsibility matrix, call out any concern belonging to two modules (overlap) or no module (gap) — these are design defects, not ambiguities to silently resolve.
5. **Treat circular dependencies as non-negotiable blockers**: Do not suggest accepting a circular module dependency even temporarily.
6. Module map as a table (Module, Responsibility, Exports, Dependencies); responsibility matrix with overlap/gap indicators; violations sorted by severity (BLOCKING first). Distinguish design defects (must fix) from stylistic preferences (document but don't block).

---
