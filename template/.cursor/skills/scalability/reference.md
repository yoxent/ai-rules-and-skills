```yaml
---
name: scalability
description: Designs explicit scaling strategies for system components to handle projected load growth within defined performance budgets, without architectural redesign.
version: 1.1.0
category: Architecture
tags: [scalability, performance, load, bottlenecks, distributed-systems]
priority: High
depends_on: [system-design]
flags_skills: [performance-optimization, system-design, dependency-management, observability, technical-debt-management]
inputs: [system-design, performance-requirements, traffic-patterns, growth-projections, sla-definitions]
outputs: [scaling-strategies, bottleneck-analysis, load-distribution-plan, capacity-model]
rules_applied:
  - PC-1   # Analyze Complexity
  - PC-4   # Performance Budget
  - DA-5   # Avoid Overengineering
  - DA-7   # Architectural Consistency
  - PC-3   # Business Priority Override
  - DT-1   # Explicit Tradeoff Logging
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency
documents_needed: [system-architecture, sla-definitions, traffic-projections, performance-budgets]
execution_context: Runs after System Design when SLA or traffic projections require explicit scaling strategies, or when performance degradation indicates a scaling bottleneck.
---
```

---

# Skill: Scalability

---

## Purpose

**What this skill does:**
Scalability designs explicit strategies for how system components will handle increased load, data volume, and user growth — within defined cost and performance budgets. It identifies bottlenecks before they materialize, defines horizontal and vertical scaling approaches, and designs partitioning, caching, and load distribution strategies that keep the system within its SLA commitments as it grows.

Scaling failures are business-visible: slow responses, downtime during traffic spikes, and degraded service directly impact revenue and customer retention. Designing for scale reactively (after failure) is significantly more expensive than proactive planning. This skill converts SLAs and growth projections into concrete architectural decisions that prevent scaling crises before they occur.

Explicit scaling strategies prevent ad-hoc fixes under pressure (adding a cache everywhere, vertical scaling infinitely) and replace them with deliberate, cost-optimized approaches. Clear bottleneck identification before implementation prevents architectural rework when load increases. The capacity model produced makes scaling decisions traceable and auditable.

---

## When to Use This Skill

### Triggers (Use this skill when):

* System Design has produced a component architecture and SLAs or traffic projections require explicit scaling validation
* Observed or projected traffic growth approaches the capacity limits of the current design
* A performance SLA is being defined for a new system component
* A load test reveals bottlenecks that cannot be addressed at the code level alone
* The system has a single point of failure that violates availability SLAs
* A new data volume or partitioning requirement is being evaluated
* Architecture is being re-evaluated for horizontal scalability

### Do NOT use this skill for:

* Code-level performance optimization (use Performance Optimization)
* Capacity planning for infrastructure provisioning (DevOps Phase 4 scope)
* Load testing and measurement (use Load Test Creation, Phase 6)
* Diagnosing active performance incidents (use Bug Diagnosis or Incident Response)

**Execution Context Details:**
Scalability is a design-time skill, not a diagnostic tool. It operates on system architecture and projected requirements, not on live performance data. It is invoked proactively to validate that a design can scale, or reactively when a design has been proven insufficient. It is typically preceded by System Design and followed by observability design and capacity planning in DevOps.

---

## Inputs

**Required inputs:**

* **System design** — The component architecture and data flow model from System Design. Scalability cannot be planned without knowing what is being scaled.
* **Performance requirements and SLA definitions** — Specific, measurable targets: throughput (requests/second), latency (p50/p95/p99), availability (uptime %), error rate budget. Without measurable SLAs, scaling design is speculative.
* **Traffic patterns** — Peak vs. average load, read/write ratio, request distribution across components. Used to identify which components face the greatest load and where scaling strategies must be most precise.

**Optional inputs:**

* **Growth projections** — Expected traffic or data volume growth over 6-18 months. Used to size scaling strategies for the near-term future, not just current load.
* **Cost constraints** — Budget limits for scaling infrastructure. Without cost constraints, scaling strategies may be technically sound but economically unjustifiable.
* **Existing performance data** — Baseline measurements from current system. For re-architecture scenarios, actual data is more reliable than projections.

---

## Outputs

**Primary outputs:**

* **Scaling strategies per component** — For each component under load: horizontal vs. vertical scaling recommendation, partitioning approach (sharding, tenant isolation, read replicas), caching layer design, and load distribution strategy. Each strategy is justified against specific SLAs and cost constraints.
* **Bottleneck analysis** — Identification of the components most likely to become performance bottlenecks under projected load, with reasoning. Single points of failure explicitly identified.
* **Load distribution plan** — How load will be distributed across instances, regions, or partitions. Includes load balancing strategy, session affinity requirements, and failover behavior.
* **Capacity model** — A simplified model showing the relationship between expected load, component capacity, and scaling triggers. Defines when each component needs to scale and by how much.

**Output format:**

* Scaling strategies are per-component with explicit justification — not general advice
* Bottleneck analysis ranks components by risk with quantified reasoning
* Capacity model shows numbers: "Component X handles Y requests/second per instance; at projected peak of Z, N instances are required"
* All strategies reference the SLA targets they are designed to meet

**Skill flags (if applicable):**

* Flag **performance-optimization** when a bottleneck is code-level and cannot be addressed by scaling infrastructure alone
* Flag **system-design** when the scaling requirements reveal that the current architecture must change fundamentally to scale (not just add instances)
* Flag **observability** when scaling strategies require monitoring and alerting to trigger and validate correctly
* Flag **dependency-management** when scaling a component creates new coupling or coordination requirements
* Flag **technical-debt-management** when existing technical debt is the root cause of a scaling bottleneck

---

## Preconditions

**Conditions that must be met before execution:**

* System Design has produced a component architecture
* SLAs are defined with measurable targets — not vague requirements
* Traffic patterns or projections are available (even rough estimates)

**Validation checks:**

* [ ] System architecture is defined at the component level
* [ ] SLA targets are specific and measurable (e.g., p99 latency < 500ms, not "the system should be fast")
* [ ] At least an order-of-magnitude estimate of expected peak load is available

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:**
- [ ] Determine whether this invocation involves an existing codebase with code-level performance concerns (not a greenfield architecture-only design).
- [ ] If code-level performance decisions are in scope → flag **performance-optimization** → co-invoke before planning begins.

*Pure infrastructure scaling design for greenfield systems does not trigger co-invocation.*

---

### Step 1: Load Profile Analysis

**Questions to answer:**
- What is the expected peak load per component (requests/second, concurrent users, data volume)?
- What is the read/write ratio? (Read-heavy systems scale differently from write-heavy ones)
- Are load patterns bursty (sharp spikes) or gradual (steady growth)?
- Which components are on the critical path for latency SLAs?

**Actions:**
- [ ] Map peak load estimates to each component using traffic patterns and growth projections
- [ ] Classify each component's load type: read-heavy, write-heavy, mixed, batch
- [ ] Identify the critical path — the sequence of components that determines end-to-end latency
- [ ] Flag any component with load estimates that approach known capacity limits (e.g., a single-instance database at 80% of its write capacity)

**Red flags / Warning signs:**
- SLAs defined without corresponding load estimates — cannot validate that the SLA is achievable
- A single component on the critical path with no redundancy — any failure breaches availability SLA
- Read/write ratio assumed to be equal when it is likely highly asymmetric (most web applications are 80%+ read)

**Decision points:**
- If load estimates are entirely absent, escalate to stakeholder for projection data before proceeding with scaling design

---

### Step 2: Bottleneck Identification

**Questions to answer:**
- Which components are the most likely to become performance bottlenecks under projected peak load?
- Are there stateful components (databases, caches, session stores) that create scaling ceilings?
- Are there synchronous call chains that amplify latency under load?
- Are there single points of failure that create availability risks?

**Actions:**
- [ ] Analyze each component's scalability ceiling: what limits its capacity? (CPU, memory, I/O, network, lock contention)
- [ ] Identify all stateful components — these are harder to scale horizontally and require explicit strategies
- [ ] Map synchronous call chains on the critical path — each hop adds latency and failure risk
- [ ] List every single point of failure (single instance, single region, synchronous external dependency) and classify its availability risk

**Red flags / Warning signs:**
- A database that is both the read and write bottleneck — scaling strategy must address both independently
- Synchronous chains of 4+ service calls on the critical path — latency adds; any failure cascades
- Session or state stored in-process on application servers — prevents horizontal scaling
- External dependency (third-party API) on the critical path with no timeout, retry, or fallback

**Decision points:**
- If a bottleneck cannot be resolved by scaling infrastructure (e.g., an algorithmic inefficiency), flag performance-optimization
- If the bottleneck reveals a fundamental architectural constraint, flag system-design

---

### Step 3: Scaling Strategy Design

**Questions to answer:**
- Should each bottleneck component be scaled horizontally (more instances) or vertically (bigger instances)?
- What data partitioning strategy is appropriate (sharding, read replicas, CQRS)?
- Where should caching be introduced to reduce load on bottleneck components?
- What load balancing strategy fits the traffic pattern?

**Actions:**
- [ ] For each bottleneck component: define the primary scaling strategy with justification
- [ ] Apply DA-5: do not design for 10x scale when 2x is the realistic near-term requirement
- [ ] For stateful components: define the partition or replica strategy explicitly
- [ ] For high-read workloads: design cache layers with explicit eviction policies and consistency requirements
- [ ] Design load balancing approach: round-robin, least-connections, consistent hashing, geographic routing

**Red flags / Warning signs:**
- Horizontal scaling applied to stateful components without a partitioning strategy — scaling stateful components requires explicit state distribution
- Caching without defined consistency requirements — a cache with undefined staleness is a correctness risk
- Scaling strategy that violates existing architectural conventions without justification (DA-7)

**Decision points:**
- If horizontal scaling introduces distributed systems complexity (consensus, distributed transactions), escalate for business priority decision per PC-3
- Log all scaling strategy decisions with alternatives considered per DT-1

---

### Step 4: Single Point of Failure Elimination

**Questions to answer:**
- For each SPOF identified: what is the recovery path if it fails?
- Can the SPOF be eliminated (redundancy, multi-region) or mitigated (circuit breakers, graceful degradation)?
- Does eliminating the SPOF require architectural changes beyond scaling (flag system-design)?

**Actions:**
- [ ] For each SPOF: define the failure scenario and its impact on availability SLAs
- [ ] Design the redundancy or mitigation strategy (active-active, active-passive, graceful degradation)
- [ ] For external dependencies: design circuit breakers, timeouts, and fallback behavior
- [ ] Calculate the resulting availability estimate after SPOF elimination and verify against SLA

**Red flags / Warning signs:**
- Availability SLA requires 99.9% uptime but design has unmitigated SPOFs that each contribute >0.1% failure risk
- Eliminating a SPOF requires changes so significant that it becomes a re-architecture (flag system-design)
- Circuit breaker design without fallback — a tripped circuit breaker with no fallback is just a slower failure

**Decision points:**
- If SPOF elimination cost (complexity, infrastructure cost) is disproportionate to the availability gain, escalate per PC-3 for business priority decision

---

### Step 5: Capacity Model and Scaling Triggers

**Questions to answer:**
- At what load level does each component need to scale?
- How quickly must scaling occur (reactive autoscaling vs. pre-provisioned)?
- What metrics trigger scaling decisions?

**Actions:**
- [ ] Define scaling trigger for each component: the metric and threshold that initiates scaling (e.g., CPU > 70% for 2 minutes, request queue depth > 1000)
- [ ] Estimate the number of instances required at peak load per component
- [ ] Validate that the scaling strategy can respond fast enough: if a traffic spike arrives in 30 seconds, autoscaling that takes 5 minutes is inadequate
- [ ] Flag observability for metric instrumentation required to implement scaling triggers

**Red flags / Warning signs:**
- Scaling triggers defined on lagging metrics (e.g., scale on error rate — by the time errors spike, the damage is done; scale on queue depth or latency instead)
- Scaling strategy that requires minutes to respond to a spike measured in seconds
- No capacity estimate provided — scaling without numbers is guesswork

---

### Final Step: Generate Scalability Report

```markdown
## Scalability Report

**System / Component:** [Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ SCALABLE / ⚠️ RISKS IDENTIFIED / ❌ REDESIGN REQUIRED

### Load Profile Summary
| Component | Peak Load Estimate | Load Type | Critical Path? |
|-----------|-------------------|-----------|---------------|
| [Name] | [N req/s] | [Read/Write/Mixed] | [Yes/No] |

### Bottleneck Analysis
| Component | Bottleneck Type | Severity | Scaling Ceiling |
|-----------|----------------|----------|----------------|
| [Name] | [CPU/IO/Lock/State] | [High/Med/Low] | [At N req/s] |

### Scaling Strategies
| Component | Strategy | Justification | SLA Target Met? |
|-----------|---------|--------------|-----------------|
| [Name] | [H-scale/V-scale/Shard/Cache] | [Why] | [Yes/No] |

### Single Points of Failure
| SPOF | Availability Impact | Mitigation | Residual Risk |
|------|-------------------|-----------|---------------|
| [Name] | [% downtime per year] | [Strategy] | [Acceptable?] |

### Capacity Model
| Component | Current Capacity | Peak Requirement | Instances at Peak |
|-----------|-----------------|-----------------|-------------------|
| [Name] | [N req/s/instance] | [N req/s] | [N instances] |

### Skills Flagged for Follow-up
- **[Skill]**: [Specific reason]

### Overall Assessment
- ✅ SCALABLE: Design meets SLAs under projected load with defined strategies
- ⚠️ RISKS IDENTIFIED: Scalable with specific mitigations implemented
- ❌ REDESIGN REQUIRED: Fundamental architectural change required to scale

### Required Actions
- [ ] [Action with owner and priority]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Analyze load profiles per component against SLA targets and growth projections
2. Identify bottlenecks and single points of failure before they materialize under load
3. Design per-component scaling strategies justified against specific SLAs and cost constraints
4. Eliminate or mitigate all single points of failure that violate availability SLAs
5. Produce a capacity model with scaling triggers per component
6. Flag follow-on skills for monitoring, code-level optimization, and architectural redesign

**Quality criteria:**

* Every scaling strategy is traceable to a specific SLA target and load estimate — no generic advice
* Every identified SPOF has a defined mitigation or documented risk acceptance
* Capacity model includes numbers: instances, throughput per instance, trigger thresholds
* DA-5 applied: scaling complexity is proportional to actual load requirements, not speculative maxima

---

## Constraints (Rules Applied)

### Performance & Complexity Rules

* **PC-1: Analyze Complexity**
  - Quantify scaling assumptions explicitly. "The system should handle high load" is not a scaling requirement. "The system must handle 5,000 requests/second at p99 < 300ms with 99.9% availability" is a scaling requirement that this skill can design for.

* **PC-4: Performance Budget**
  - Scaling strategies must fit within defined cost and latency budgets. A horizontally scaled solution that quadruples infrastructure cost requires explicit business justification.

### Design & Architecture Rules

* **DA-5: Avoid Overengineering**
  - Do not design distributed scaling infrastructure for a system that does not require it. A monolith handling 1,000 concurrent users does not need Kafka and a microservices fleet. Scale to the realistic near-term requirement, not the hypothetical maximum.

* **DA-7: Architectural Consistency**
  - Scaling strategies must be consistent with the existing architectural approach. Introducing event-driven scaling in one component of a synchronous request-response system creates operational inconsistency without justification.

### Decision & Tradeoff Rules

* **PC-3: Business Priority Override**
  - When performance and cost conflict (the most scalable solution is too expensive; the cheapest solution doesn't meet SLAs), escalate to stakeholder for business priority resolution. Do not silently compromise SLAs or silently accept excessive cost.

* **DT-1: Explicit Tradeoff Logging**
  - Log all scaling decisions with alternatives considered. "We chose read replicas over CQRS because our read/write ratio is 10:1, CQRS adds significant operational complexity, and read replicas meet our latency SLA at lower operational cost" is the required standard.

---

## Tradeoff Handling

### Tradeoff 1: Cost vs. Performance

**Scenario:** The scaling strategy that guarantees SLA compliance at all projected load levels is significantly more expensive than a simpler approach that meets SLAs under normal load but degrades under peak.

**Default stance:** Design to meet SLAs under projected peak load within the cost budget. If cost budget and SLA are mutually incompatible, escalate — this is a business decision.

**Resolution process:**
1. Quantify both the cost of the full scaling solution and the risk of the cheaper alternative (probability of SLA breach, business impact of breach)
2. Escalate to PC-3 with both options and their costs/risks
3. Document the decision per DT-1 regardless of which option is chosen

---

### Tradeoff 2: Distributed Complexity vs. Scalability

**Scenario:** Horizontal scaling of stateful components (database sharding, distributed caching) enables scale but introduces distributed systems complexity: consistency challenges, split-brain scenarios, increased operational burden.

**Default stance:** Accept distributed complexity only when the alternative (vertical scaling, read replicas) is demonstrably insufficient for the load requirement.

**Resolution process:**
1. Determine whether a simpler scaling approach (read replicas, vertical scaling, query optimization) can meet the SLA at lower complexity cost
2. If distributed strategy is required: document the consistency model, failure modes, and operational requirements explicitly
3. Escalate to PC-3 if the team does not have distributed systems operational experience — the expertise risk is a business-relevant factor
4. Log per DT-1

---

### Tradeoff 3: Pre-Provisioned vs. Auto-Scaled Capacity

**Scenario:** Pre-provisioning capacity guarantees availability for known traffic spikes but wastes cost during low-traffic periods. Autoscaling is cost-efficient but may be too slow to respond to sudden spikes.

**Default stance:** Prefer autoscaling with a pre-provisioned baseline that handles expected base load without scaling delay.

**Resolution process:**
1. Characterize traffic patterns — is growth gradual (autoscaling is sufficient) or bursty (pre-provisioning required)?
2. Measure autoscaling response time against spike ramp-up time
3. If autoscaling cannot respond in time, accept the cost of pre-provisioning and document the cost/risk tradeoff per DT-1

---

## Failure & Escalation Behavior

### Escalation Scenario 1: SLAs Undefined or Unmeasurable

**Trigger:** Scaling design is requested but SLA targets are absent or expressed as non-measurable requirements ("must be fast", "should handle lots of users").

**Action:**
- Halt scaling design
- Request specific measurable SLAs from the stakeholder
- Provide examples of measurable SLA formats to assist the stakeholder

**Escalation format:**
```
⚠️ SLA DEFINITION REQUIRED

Issue: Scalability design cannot proceed without measurable performance targets
Context: [What was provided vs. what is needed]
Required:
  A. Throughput target: [N] requests/second at peak
  B. Latency target: p95/p99 in milliseconds
  C. Availability target: % uptime over [period]
  D. Growth projection: expected peak in [timeframe]

Question: Can you provide these targets before scaling design proceeds?
```

---

### Escalation Scenario 2: Bottleneck Requires Architectural Redesign

**Trigger:** The bottleneck analysis reveals that a component cannot be scaled by adding instances — its design requires a fundamental architectural change (e.g., a stateful monolithic component that must be decomposed to scale).

**Action:**
- Document the bottleneck and why infrastructure scaling alone is insufficient
- Flag system-design for architectural re-evaluation
- Do not continue scaling strategy design for this component until architectural resolution is clear

---

### Escalation Scenario 3: Cost and SLA Are Mutually Incompatible

**Trigger:** The cost estimate for the required scaling strategy exceeds the available infrastructure budget by a significant margin.

**Action:**
- Present both the cost of meeting the SLA and the risk of not meeting it
- Present alternative approaches at lower cost with their SLA tradeoffs
- Escalate to stakeholder via PC-3 — this is a business priority decision

---

### Escalation Scenario 4: Bottleneck Is Code-Level, Not Architectural

**Trigger:** Bottleneck analysis identifies that a component cannot scale because of inefficient algorithms or queries, not because of architectural constraints.

**Action:**
- Flag performance-optimization with specific bottleneck details
- Do not design infrastructure scaling as a substitute for code-level fixes
- Note that infrastructure scaling on top of an algorithmic bottleneck is a waste of cost

---

### When to halt execution:

* SLAs are entirely undefined — cannot design scaling without targets
* Growth projections are so uncertain that no meaningful capacity model can be produced
* A bottleneck requires architectural redesign before scaling can be addressed

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Scalability runs after System Design as a validation and extension of the architecture for load requirements. It is a design-time skill that informs DevOps capacity planning and Observability instrumentation.

### How This Skill Integrates

**Does NOT directly call other skills.** This skill **flags** when other skills should review.

**Integration workflow:**
1. **Orchestrator** invokes Scalability when SLAs or load projections require scaling validation
2. Skill analyzes load profiles, identifies bottlenecks, designs scaling strategies, eliminates SPOFs, and produces capacity model
3. Skill **outputs flags** for performance-optimization, system-design, observability, etc.
4. **Orchestrator** invokes flagged skills based on findings
5. Flagged skills address code-level bottlenecks, architectural redesign, or monitoring instrumentation

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|-------------------|-----------------|---------|
| Bottleneck is algorithmic, not architectural | performance-optimization | Code-level fix required; infrastructure scaling alone is insufficient |
| Component cannot be scaled without architectural redesign | system-design | Architecture must change before scaling can be addressed |
| Scaling triggers require monitoring instrumentation | observability | Metrics and alerting must be designed to support autoscaling |
| Scaling creates new inter-component coupling | dependency-management | New coupling introduced by scaling strategy must be validated |
| Technical debt is causing the scalability bottleneck | technical-debt-management | Debt must be addressed rather than scaled around |

---

## Related Skills

**Skills this skill depends on:**

* **system-design** — Provides the component architecture that Scalability designs strategies for. Scaling strategy cannot be designed without knowing what is being scaled and how components interact.

**Skills this skill cooperates with:**

* **performance-optimization** — When scaling reveals code-level bottlenecks, Performance Optimization addresses them. The two skills complement each other: architecture scaling and code-level optimization are both required for a fully scalable system.
* **observability** — Scaling triggers and capacity monitoring require instrumentation that Observability designs. The two skills work sequentially: Scalability defines what to measure; Observability defines how to measure and alert on it.

**Skills this skill may invoke/flag:**

* **performance-optimization** — Algorithmic bottlenecks that scaling infrastructure cannot resolve
* **system-design** — Fundamental architectural changes required to enable scaling
* **observability** — Monitoring and alerting required to implement and validate scaling strategies
* **dependency-management** — New coupling introduced by scaling (e.g., shared cache, messaging infrastructure)
* **technical-debt-management** — Debt that is the root cause of a scaling bottleneck

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Never design scaling strategies without measurable SLA targets — halt and request them
* [ ] Quantify all scaling estimates with numbers: instances, throughput, latency, cost
* [ ] Log all scaling strategy decisions with alternatives considered per DT-1
* [ ] Apply DA-5: scaling complexity must be proportional to actual requirements
* [ ] Escalate cost-vs-SLA conflicts to stakeholder per PC-3 — do not resolve silently
* [ ] Flag observability for every scaling strategy that requires monitoring to trigger

**Audit trail requirements:**

* All scaling strategy decisions must be logged with SLA targets, load estimates, and alternatives considered
* All SPOF mitigations must be documented with residual risk assessment
* All capacity model assumptions must be documented — estimates presented as facts are a governance violation (GM-4)

---

## Example Use Cases

### Example 1: API Service Scaling for 10x Traffic Growth

**Scenario:** A REST API service currently handles 500 requests/second at p99 < 200ms on 3 instances. The product team projects 10x traffic growth in 12 months. SLA: p99 < 300ms at 5,000 req/s.

**Inputs provided:**
- Current: 500 req/s, 3 instances, p99 = 150ms
- Projected peak: 5,000 req/s
- SLA: p99 < 300ms, 99.9% availability

**Execution steps:**
1. Load profile: read-heavy API (85% GET, 15% POST). Database is the primary bottleneck at projected load.
2. Bottleneck: single database instance cannot sustain 5,000 req/s write throughput + read queries at SLA latency
3. Scaling strategy: (a) read replicas for GET endpoints, routing 85% of queries to replicas; (b) horizontal scaling API servers to ~18 instances at projected peak; (c) application-layer cache for high-read, low-mutation data
4. SPOF: single-region deployment. Mitigation: active-passive failover to second region (meets 99.9% SLA)
5. Capacity model: 18 API instances × 280 req/s/instance = 5,040 req/s capacity; 1 write + 2 read replicas sufficient at projected write rate

**Result:** ✅ SCALABLE — Scaling strategy defined, capacity model validated against SLA

**Skills flagged:** observability (autoscaling triggers on p99 latency and queue depth), dependency-management (read replica routing layer is a new dependency)

---

### Example 2: Database Bottleneck Requiring Architectural Escalation

**Scenario:** An e-commerce platform's order database is a PostgreSQL monolith. Projected growth requires 50,000 orders/day written with complex cross-table joins. Performance testing shows the DB maxes out at 30,000 orders/day.

**Inputs provided:**
- Current: PostgreSQL single instance, 30,000 orders/day limit
- Required: 50,000 orders/day within 6 months
- SLA: order confirmation p99 < 500ms

**Execution steps:**
1. Bottleneck analysis: write throughput limited by cross-table join complexity on order creation. Read replicas do not help (write-bound). Vertical scaling estimate: 2x current spec covers 40,000/day — insufficient.
2. Sharding evaluated: tenant-based sharding possible but requires application routing layer, schema migration, and cross-shard query elimination. Significant complexity.
3. CQRS evaluated: separating write model (optimized for order creation) from read model (optimized for queries) could reduce write-path complexity — viable but significant architectural change.
4. Code-level bottleneck identified: query analysis shows N+1 queries on order creation. A code-level fix could reduce DB load by ~40%.

**Result:** ⚠️ RISKS IDENTIFIED — Code fix first (flag performance-optimization), then re-evaluate

**Skills flagged:** performance-optimization (N+1 query fix may resolve bottleneck without architectural change), system-design (if code fix is insufficient, CQRS architectural change required)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Scaling to Speculative Maximums**
Designing for 100x current load "because we might go viral" without a business case for that growth trajectory. Distributed scaling infrastructure has significant operational cost.
✅ **Correct approach:** Apply DA-5. Design for the realistic near-term projected peak (12-18 months). Ensure the architecture can evolve to handle further scale, but do not build for hypothetical extremes.

❌ **Anti-pattern 2: Caching Without Consistency Requirements**
Adding a cache to reduce database load without defining the acceptable staleness window and cache invalidation strategy. Stale data can cause correctness failures.
✅ **Correct approach:** Every cache layer must have explicitly defined consistency requirements: maximum staleness tolerated, invalidation triggers, and what happens when the cache is cold or stale.

❌ **Anti-pattern 3: Vertical Scaling as the Only Strategy**
Scaling by upgrading to bigger servers indefinitely, without a plan for when vertical scaling hits its ceiling (cost, availability of larger instances, or database write-lock behavior under high memory pressure).
✅ **Correct approach:** Vertical scaling is appropriate and cost-effective up to a defined threshold. Define that threshold and the horizontal scaling strategy that takes over when it is reached.

❌ **Anti-pattern 4: Ignoring Stateful Component Scaling**
Designing horizontal scaling for stateless application servers without addressing the stateful components (database, session store, cache) that are the actual bottleneck. Adding application servers doesn't help if the database is saturated.
✅ **Correct approach:** Stateful components have fundamentally different scaling constraints. Address them explicitly: read replicas, connection pooling, sharding, or architectural decomposition.

❌ **Anti-pattern 5: Undefined SPOF Risk Acceptance**
Leaving single points of failure in a design that has a 99.9% availability SLA without explicitly documenting the risk acceptance decision. The SLA cannot be met with unmitigated SPOFs.
✅ **Correct approach:** Every SPOF must either be eliminated (redundancy) or explicitly accepted with a quantified risk assessment and stakeholder sign-off. Silent acceptance is a governance violation.

❌ **Anti-pattern 6: Infrastructure Scaling on Top of Algorithmic Bottlenecks**
Adding more instances to a component whose bottleneck is an O(n²) algorithm or N+1 query. This scales cost linearly while scaling capacity logarithmically — expensive and ineffective.
✅ **Correct approach:** Flag performance-optimization before designing infrastructure scaling. Fix algorithmic bottlenecks first; the resulting scaling requirement may be substantially smaller.

❌ **Anti-pattern 7: Autoscaling Without Response Time Analysis**
Designing autoscaling as the primary capacity strategy without verifying that the autoscaling response time is faster than the traffic spike ramp-up time.
✅ **Correct approach:** Compare spike ramp-up time with autoscaling provisioning time. If spikes arrive faster than the autoscaler can respond, pre-provisioned baseline capacity is required.

❌ **Anti-pattern 8: Scaling Without Observability**
Designing scaling strategies that require metric-based triggers without verifying that those metrics will be instrumented and available.
✅ **Correct approach:** For every scaling trigger defined (CPU %, queue depth, p99 latency), confirm with observability design that the metric will be instrumented and alertable. Flag observability explicitly.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ **Code-level performance optimization** — Algorithmic improvements, query optimization, memory efficiency are Performance Optimization's scope. Scalability flags that skill when bottlenecks are code-level.
* ❌ **Infrastructure provisioning and capacity planning** — Selecting instance types, cloud provider configuration, and provisioning automation are DevOps Phase 4 concerns.
* ❌ **Load test execution and measurement** — Actual load testing is Phase 6 (Load Test Creation). Scalability designs strategies; Load Testing validates them.
* ❌ **Active performance incident response** — Diagnosing and resolving live performance degradation is Bug Diagnosis or Incident Response. Scalability is a design-time skill.

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Always quantify**: Every scaling claim requires a number. "This will scale" is meaningless; "3 read replicas handle the projected 4,200 read req/s while keeping p95 < 150ms" is actionable.
2. **Refuse to proceed without measurable SLAs**: Vague requirements produce vague strategies. Halt and request specific targets.
3. **Apply DA-5 assertively**: The default answer to "should we design for 100x?" is "no — design for 2-3x with a clear path to more." Justify every increment of scaling complexity with specific requirements.
4. **Separate architectural from code-level concerns**: When a bottleneck is algorithmic, flag performance-optimization rather than designing infrastructure around it. Infrastructure scaling is not a substitute for correct code.
5. **Make SPOF risks explicit**: Every identified SPOF must be acknowledged in the report with its availability impact quantified, not left as an implicit assumption.

**Output format preferences:**

* Use tables for load profiles, bottleneck analysis, scaling strategies, and capacity models
* Include numbers everywhere: throughput, latency, instance counts, cost estimates (even rough)
* Use ✅/⚠️/❌ for component-level scalability assessment
* All strategies reference specific SLA targets they are designed to meet

**Tone and approach:**

* Be conservative: over-promising scalability is more damaging than conservative estimates
* Be quantitative: estimates with reasoning are far more useful than qualitative assessments
* Be explicit about assumptions: when load projections are uncertain, state the uncertainty and provide sensitivity analysis

---
