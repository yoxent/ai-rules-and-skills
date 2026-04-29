```yaml
---
name: system-design
description: Designs high-level system structures, component boundaries, and interaction patterns aligned with business requirements and validated against architectural rules.
version: 1.0.0
category: Architecture
tags: [architecture, system-design, components, scalability, design-patterns]
priority: High
depends_on: []
flags_skills: [dependency-management, scalability, modularity, performance-optimization, technical-debt-management, security, architecture-consistency]
inputs: [functional-requirements, non-functional-requirements, constraints, existing-architecture]
outputs: [architecture-diagrams, component-responsibility-map, data-flow-models, technology-rationale]
rules_applied:
  - DA-2   # Abstraction by Business Meaning
  - DA-5   # Avoid Overengineering
  - DA-7   # Architectural Consistency
  - PC-3   # Business Priority Override
  - DT-1   # Explicit Tradeoff Logging
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency
documents_needed: [functional-requirements, non-functional-requirements, existing-architecture-diagrams, business-constraints]
execution_context: Runs when designing a new system from scratch, re-architecting an existing system, or evaluating a major structural change.
---
```

---

# Skill: System Design

---

## Purpose

**What this skill does:**
System Design defines the high-level structure of a system: its major components, responsibilities, communication patterns, and the architectural patterns governing their relationships. It translates business requirements and non-functional constraints into an explicit architectural blueprint that all subsequent engineering decisions reference.

Poor upfront system design compounds in complexity with every feature added. This skill prevents that by establishing clear boundaries, explicit ownership, and justified technology choices before implementation begins, reducing rework and integration failures downstream.

Provides a stable reference architecture for module decomposition, API design, dependency decisions, and scalability planning. A well-defined system design constrains future decisions productively and makes the system's evolution manageable over time.

---

## When to Use This Skill

### Triggers:

* Designing a new system, service, or platform from scratch
* Re-architecting to address scalability, maintainability, or structural failures
* Evaluating whether current architecture can support a major new capability
* Introducing a new architectural pattern (e.g., shifting from monolith to event-driven)
* A component's responsibilities have grown far beyond original scope
* Integration with a new external system requires new boundary definitions
* Resolving repeated component-level conflicts indicating unclear ownership

### Do NOT use this skill for:

* Module-level design within an established component (use Modularity or Abstraction & Domain Modeling)
* Code-level class or method design (use Clean Code & SOLID or Design Pattern Selection)
* Evaluating individual dependency choices (use Dependency Management)
* Performance profiling of existing components (use Performance Optimization)

**Execution Context:**
System Design is foundational — it runs before most other Phase 2 architecture skills and sets the structural context they operate within. When invoked for re-architecture, it should follow existing code analysis (Correctness Validation, Code Maintenance). It is typically followed by Modularity and Scalability.

---

## Inputs

**Required inputs:**

* **Functional requirements** — Capabilities the system must deliver: features, integrations, data flows, business processes. Used to identify components and responsibilities.
* **Non-functional requirements (NFRs)** — Performance SLAs, availability targets, security requirements, compliance constraints, scalability goals. Shape architectural pattern selection.
* **Technology and infrastructure constraints** — Budget limits, mandated platforms, team skill sets, existing infrastructure. Constrain technology selection.

**Optional inputs:**

* **Existing architecture** — Required when re-architecting; informs gap analysis and migration planning.
* **Traffic and growth projections** — For scalability planning; prevents over- or under-engineering.
* **Identified pain points or failure modes** — Provides context for why re-architecture is justified.

---

## Outputs

**Primary outputs:**

* **Architecture diagrams (logical + physical)** — Logical: components and relationships. Physical: components mapped to deployment units.
* **Component responsibility mapping** — What each component owns, does not own, and its interface contracts.
* **Data flow models** — Synchronous vs. async flows, transformation points, persistence boundaries.
* **Technology selection rationale** — Alternatives considered and justification for each major choice, logged per DT-1.

**Output format:**
* Architecture diagrams accompanied by written component descriptions — not diagrams alone
* Technology rationale logged as decisions per DT-1
* All outputs traceable to specific requirements or constraints — no unexplained choices

---

## Preconditions

**Conditions that must be met before execution:**

* Functional and non-functional requirements are available (even if partial)
* Technology and infrastructure constraints are known
* For re-architecture: existing system analyzed sufficiently to understand current structure

**Validation checks:**

* [ ] Requirements are specific enough to derive component boundaries
* [ ] Known constraints (budget, platform, compliance) are documented
* [ ] Stakeholder agreement exists on the scope of the design exercise

---

## Step-by-Step Execution Procedure

### Step 1: Requirement Analysis and Constraint Inventory

**Questions:** What capabilities must the system deliver? What are the non-negotiable NFRs with measurable targets? What constraints restrict technology or structure?

**Actions:**
- [ ] Enumerate functional capabilities grouped by domain area
- [ ] List all NFRs with explicit measurable targets (e.g., "p99 latency < 200ms", not "fast")
- [ ] Document all constraints as hard boundaries
- [ ] If re-architecting: map existing components to current responsibilities

**Watch-fors:** Requirements too vague to derive component ownership; NFRs absent or unmeasurable; constraints conflict with requirements.

**Decisions:** If requirements insufficient → halt per Escalation Scenario 1. If constraints conflict with requirements → escalate per PC-3.

---

### Step 2: Domain Decomposition and Component Identification

**Questions:** What distinct business domains exist? What responsibilities cluster by domain semantics? What must be independently deployable or ownable?

**Actions:**
- [ ] Apply DA-2: group by business meaning, not technical convenience
- [ ] Define candidate components with single-sentence responsibility statements
- [ ] Identify shared state and cross-component coordination points

**Watch-fors:** Components defined by technical layer rather than business domain; vague responsibility statements; components that must be deployed together.

**Decisions:** If responsibility can't be stated in one sentence → decompose further. If two components share significant state → evaluate whether they belong to the same boundary.

---

### Step 3: Architectural Pattern Selection

**Questions:** Which pattern fits domain structure and NFRs? Does it introduce operational complexity the team can sustain? Have alternatives been explicitly considered?

**Actions:**
- [ ] Evaluate ≥2 patterns against requirements and constraints
- [ ] Apply DA-5: reject patterns adding complexity beyond what requirements justify
- [ ] Apply DA-7: if pattern differs from existing conventions → flag architecture-consistency
- [ ] Log pattern selection and alternatives per DT-1

**Watch-fors:** Pattern selected for fashion not NFR justification; distributed systems complexity without scale justification; pattern selected without evaluating operational burden.

**Decisions:** If pattern violates DA-7 → escalate to stakeholder for approval. If tradeoffs pit performance vs. maintainability → invoke PC-3.

---

### Step 4: Communication and Data Flow Design

**Questions:** How do components communicate (sync/async)? Who owns each data store? Where are consistency boundaries?

**Actions:**
- [ ] Map all inter-component communication with explicit protocol and synchronicity
- [ ] Assign data ownership to exactly one component per entity — no shared writes
- [ ] Identify eventual consistency boundaries and document implications
- [ ] Flag coupling patterns (shared databases, synchronous chains of 3+ calls)

**Watch-fors:** Multiple components writing to the same table; synchronous chains causing cascading failure risk; unclear data ownership.

**Decisions:** If shared data stores unavoidable → flag dependency-management. If consistency conflicts with performance → escalate per PC-3.

---

### Step 5: Technology Selection and Rationale

**Questions:** What database type fits data model and access patterns? What messaging infrastructure is required? Are there existing technology standards to respect?

**Actions:**
- [ ] Evaluate ≥2 alternatives per major technology choice
- [ ] Apply DA-5: no new technology category without clear justification
- [ ] Document selection rationale and rejected alternatives per DT-1
- [ ] Verify proposed technologies against compliance and licensing requirements

**Watch-fors:** Technology selected on familiarity alone; new technology for team with no operational experience on a critical path.

**Decisions:** If technology introduces compliance risk → flag security and escalate.

---

### Final Step: Generate System Design Report

**Output sections:** Requirements Summary · Component Architecture (table) · Architectural Pattern + rationale + alternatives considered · Data Flow Summary · Technology Decisions (table) · Skills Flagged · Risks and Open Questions · Overall Assessment (✅ COMPLETE / ⚠️ NEEDS CLARIFICATION / ❌ BLOCKED) · Required Actions.

---

## Core Responsibilities

1. Translate business requirements into a component-level architecture with explicit responsibility boundaries
2. Select architectural patterns justified by requirements and constraints — never by convention alone
3. Define all inter-component communication patterns, data ownership, and consistency boundaries
4. Document all technology decisions with alternatives considered and selection rationale
5. Identify and flag follow-on concerns (dependency risks, scaling requirements, security needs)
6. Log all architectural tradeoffs and their business context per DT-1

**Quality criteria:** Every component has a single-sentence responsibility; every technology decision has documented rationale and rejected alternatives; no boundary exists for purely technical reasons; design is explainable to a non-technical stakeholder at the component level.

---

## Constraints (Rules Applied)

* **DA-2: Abstraction by Business Meaning** — Component boundaries must reflect domain separations, not technical layers. Each component's responsibility must reference a business concept in one sentence. "UserService" handling authentication, profile, and notifications signals DA-2 violation.
* **DA-5: Avoid Overengineering** — Complexity introduced by a pattern must be justified by a specific NFR or constraint. Microservices impose distributed systems complexity — unjustified for a system with one team and modest load.
* **DA-7: Architectural Consistency** — New structural patterns must be consistent with established conventions unless deviation is deliberately justified, documented, and approved. Inconsistency fragments the team's mental model.
* **PC-3: Business Priority Override** — When scalability, cost, and maintainability conflict, escalate to stakeholder. Do not silently resolve in favor of technical preference.
* **DT-1: Explicit Tradeoff Logging** — Every architectural decision with alternatives must be logged with reasoning. "We chose PostgreSQL" is insufficient; alternatives and criteria must be recorded.
* **GM-2: Explain Before Acting** — For high-cost or irreversible choices (vendor lock-in, managed services), explain consequences and alternatives before committing.
* **GM-4: Behavioral Transparency** — All recommendations must be traceable to specific inputs. State what is known, assumed, and unknown. Do not present assumptions as design conclusions.

---

## Tradeoff Handling

### Simplicity vs. Scalability

**Scenario:** The simplest architecture (monolith) doesn't scale to projected load; the scalable architecture (distributed services) adds significant operational complexity.

**Default stance:** Default to simplicity unless specific NFRs require distribution.

**Resolution:** Quantify scaling requirement with numbers; estimate operational cost of distributed approach; invoke PC-3 if priority between scalability and delivery speed unclear; log per DT-1. Fallback: design as monolith with clean module boundaries to enable future extraction.

---

### Performance vs. Maintainability

**Scenario:** Most performant architecture violates clean component boundaries; maintainable architecture introduces latency.

**Default stance:** Default to maintainability unless a measured performance requirement conflicts.

**Resolution:** Quantify performance requirement first — if speculative, reject. If real conflict exists, escalate per PC-3; log per DT-1.

---

### Flexibility vs. Coupling

**Scenario:** Highly flexible architecture (plugin systems, generic event buses) reduces coupling but increases indirection and makes behavior harder to trace.

**Default stance:** Prefer explicitness over flexibility unless extensibility is a stated business requirement.

**Resolution:** Identify whether flexibility serves a current requirement or speculative future need. Apply DA-5: reject speculative flexibility. Document concrete use cases that justify extensibility; log per DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Requirements Too Vague

**Trigger:** Requirements don't contain sufficient specificity to derive component boundaries or select patterns.

**Action:** Halt design work; document specific requirement gaps; request clarification from stakeholder per PS-1.

**Escalation format:**
```
⚠️ REQUIREMENTS CLARIFICATION NEEDED
Issue: System design cannot proceed — requirements insufficiently specified
Missing:
  A. [Specific requirement absent or unmeasurable]
  B. [Specific requirement absent or unmeasurable]
Question: [Specific question for stakeholder]
```

---

### Escalation Scenario 2: Conflicting Architecture Constraints

**Trigger:** Business-specified constraints conflict with each other or with requirements in a technically unresolvable way.

**Action:** Document the conflict with both constraints cited; present mutually exclusive options and tradeoffs; escalate to DT-2 Confirmation Gate for stakeholder resolution.

---

### Escalation Scenario 3: Proposed Pattern Inconsistent with Existing Architecture

**Trigger:** Best technical solution differs from existing architectural conventions (DA-7 violation).

**Action:** Flag **architecture-consistency** with the deviation details; present the consistency-preserving alternative and its tradeoffs; request approval before proceeding; if approved, log deviation with rationale per DT-1.

---

### Escalation Scenario 4: Module Coupling Risks Detected

**Trigger:** Component dependency analysis reveals high coupling, circular dependency risks, or shared state undermining boundary integrity.

**Action:** Flag **dependency-management** with specific coupling details; block approval of the design until coupling risks are evaluated.

---

### When to halt execution:

* Requirements are too vague or conflicting to produce a defensible design
* Constraints from different stakeholders are mutually exclusive and unresolved
* Design introduces compliance risk not yet reviewed (flag security, escalate)

---

## Skill Integration & Orchestration

**Role in pipeline:** Foundational Phase 2 skill. Runs at the start of architectural work and produces the structural context all other architecture skills operate within. Does not depend on other architecture skills; typically followed by Modularity and Scalability.

**Integration workflow:**
1. **Orchestrator** invokes System Design based on design trigger
2. Skill performs requirement analysis, component decomposition, pattern selection, data flow design, and technology selection
3. Skill **outputs flags** for dependency-management, scalability, modularity, security, etc. in report
4. **Orchestrator** invokes flagged skills based on design findings

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Inter-component dependencies are complex or at coupling risk | dependency-management | Coupling analysis needed before design is finalized |
| SLA or traffic projections require scaling strategy | scalability | Explicit scaling approach needed per design requirements |
| Component boundaries need formal interface definitions | modularity | Module-level decomposition needed within components |
| Design includes sensitive data or access control requirements | security | Security architecture must be defined alongside system design |
| Current architecture has structural debt limiting design | technical-debt-management | Debt must be visible and planned before design builds on top of it |
| Critical latency paths identified in data flows | performance-optimization | Code-level performance constraints must be designed for |
| Pattern deviates from existing architectural conventions | architecture-consistency | Architectural deviation must be reviewed and approved per DA-7 |

---

## Related Skills

**Skills this skill depends on:**
* None — System Design is foundational and does not depend on other Phase 2 skills.

**Skills this skill cooperates with:**
* **abstraction-domain-modeling** — Informs component responsibility assignment; System Design works at a higher abstraction level.
* **modularity** — System Design defines component boundaries; Modularity defines internal structure and interface contracts.
* **scalability** — System Design identifies scaling requirements and flags Scalability for strategy design.

---

## Governance Hooks

* [ ] Log all technology selection tradeoffs via engineering_decision_logger (DT-1)
* [ ] Explain consequences and alternatives before recommending high-cost or irreversible choices (GM-2)
* [ ] Do not proceed past conflicting constraints without stakeholder resolution (DT-2)
* [ ] Reference all design decisions to specific requirements or constraints — no unexplained choices (GM-4)
* [ ] Document all exceptions and deviations from existing architectural conventions (DA-7)
* [ ] Escalate business priority conflicts rather than resolving them silently (PC-3)

---

## Example Use Cases

### General: Greenfield E-Commerce Platform

A startup needs a new e-commerce platform with product catalog, cart, checkout, order management, and notifications; NFRs include 99.9% availability, p95 checkout latency < 500ms, and PCI DSS compliance. Domain decomposition yields Catalog, Cart, Order, Payment, and Notification as distinct domains; DA-5 is applied to reject microservices at 2-engineer scale, resulting in a modular monolith with Payment as an isolated service to minimize PCI scope. Skills flagged: security (PCI compliance), modularity (internal module boundaries), dependency-management (payment service integration).

### Edge Case: Re-Architecting a Monolith for Scalability

An existing SaaS monolith faces 5x load growth in 12 months, with analytics queries blocking transactional operations on the shared database. Full microservices extraction is rejected per DA-5; instead, analytics is extracted to a separate service with a read replica, preserving the transactional path. Skills flagged: scalability (read replica strategy), dependency-management (analytics/transactional coupling), migration-strategy (execution plan needed).

### Edge Case: Conflicting Constraints Block Design Progress

A team requires real-time event processing but the infrastructure mandate is batch-only with no infrastructure changes allowed. Requirements and constraints are technically irreconcilable — design is halted, options are presented, and the conflict is escalated to DT-2 Confirmation Gate with explicit tradeoff documentation before any pattern is selected.

---

## Anti-Patterns to Catch

❌ **Design by Technology, Not Domain:** Components named after technical functions ("DatabaseLayer") rather than business domains. ✅ Name and define by business domain — responsibility must be derivable from the component name.

❌ **Microservices Without Justification:** Adopted for convention without NFRs requiring it. ✅ Default to modular monolith; extract to services only when specific NFRs justify the operational overhead.

❌ **Shared Database Across Components:** Multiple components writing to the same tables create hidden coupling. ✅ Assign database ownership to exactly one component per data domain.

❌ **Speculative Flexibility:** Plugin systems or generic event buses for hypothetical future extensibility. ✅ Apply DA-5; introduce extensibility only when a concrete use case currently requires it.

❌ **Undocumented Technology Choices:** Technologies selected without recording why alternatives were rejected. ✅ Apply DT-1 for every significant technology choice.

❌ **Architecture Matches Org Chart:** Boundaries mirror reporting lines rather than domain cohesion. ✅ Apply DA-2; acknowledge team-structure constraints explicitly if unavoidable.

❌ **Single Points of Failure in HA Designs:** 99.9% SLA with unaddressed single-instance dependencies. ✅ Explicitly audit for SPOFs against availability SLAs and define mitigations.

❌ **Designing Without Measured NFRs:** "Fast" or "scalable" without specific targets. ✅ Require measurable NFRs before committing to architectural patterns.

---

## Non-Goals

* ❌ Module-level internal design — handled by Modularity and Abstraction & Domain Modeling
* ❌ Code-level class or method design — handled by Clean Code & SOLID and Design Pattern Selection
* ❌ Dependency version management — handled by Dependency Management
* ❌ Performance profiling of existing components — handled by Performance Optimization
* ❌ Migration execution planning — handled by Migration Strategy
* ❌ Detailed security implementation — handled by Security

**Boundary clarifications:**
* System Design operates at the component level (5–15 components). Modularity operates within a component. There should be no overlap.
* System Design selects architectural patterns. Design Pattern Selection selects code-level patterns. These are distinct scopes.
* System Design flags Scalability when scaling strategies are needed but does not define them — that is Scalability's responsibility.

---

## Notes for LLM Implementation

1. **Always reference requirements explicitly:** Every component, boundary, or technology choice should cite the specific requirement or constraint that justifies it. Avoid design by intuition — if a choice can't be traced to an input, it shouldn't be in the design.
2. **State assumptions explicitly:** When requirements are ambiguous, state what is being assumed and note it as a risk or open question in the report. Never silently resolve ambiguity.
3. **Apply DA-5 aggressively:** The default posture is simplicity. Complexity must be earned by specific requirements. When in doubt, recommend the simpler approach and document the escalation path if requirements grow.
4. **Quantify tradeoffs:** Tradeoffs between simplicity, scalability, and cost should be expressed in concrete terms where possible — not "this adds complexity" but "this adds roughly 3 additional services to operate, each requiring their own deployment pipeline."
5. **Produce actionable flags:** Skill flags should be specific about what the flagged skill needs to investigate — not just "flag security" but "flag security because the payment component handles cardholder data and PCI DSS compliance must be validated."
