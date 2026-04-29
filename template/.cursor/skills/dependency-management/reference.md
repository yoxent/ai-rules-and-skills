```yaml
---
name: dependency-management
description: Analyzes and governs module and package dependencies to minimize coupling, prevent circular references, and enforce safe upgrade paths.
version: 1.0.0
category: Architecture
tags: [dependencies, coupling, modules, compatibility, architecture]
priority: High
depends_on: []
flags_skills: [refactoring, system-design, modularity, backward-compatibility, dependency-license-compliance, security]
inputs: [module-definitions, external-library-list, integration-requirements, dependency-graph]
outputs: [dependency-graph-analysis, version-constraints, coupling-risk-report, decoupling-recommendations]
rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-4   # Change Boundary Rule
  - MF-3   # Backward Compatibility
  - CL-2   # License Validation
  - DT-1   # Explicit Tradeoff Logging
  - GM-2   # Explain Before Acting
  - GM-4   # Behavioral Transparency
documents_needed: [module-definitions, dependency-lock-files, integration-architecture, license-requirements]
execution_context: Runs when modules are added or modified, when external dependencies change, when coupling risks are flagged by System Design, or during pre-release audits.
---
```

---

# Skill: Dependency Management

---

## Purpose

**What this skill does:**
Dependency Management analyzes the dependency graph of a system — both internal module-to-module dependencies and external library dependencies — to detect coupling risks, circular references, version conflicts, and unsafe upgrade paths. It produces explicit recommendations for decoupling, safe versioning, and dependency governance.

Dependency problems are silent until they become crises: circular dependencies trigger unpredictable initialization failures; transitive dependency updates break production builds; version conflicts between libraries cause runtime errors that are difficult to trace. This skill makes dependency health visible and manageable before these failures occur.

Clean dependency management enables independent component evolution, reduces merge conflicts, simplifies testing (components can be tested in isolation), and prevents cascading failures when a dependency changes. It is foundational to the maintainability of any system larger than a single module.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Adding a new external library or package to the codebase
* Updating an existing dependency to a new major or minor version
* Introducing a new internal module or service
* System Design flags coupling risks between components
* Recurring build or runtime failures traced to dependency conflicts
* Pre-release dependency audit (before a major release or upgrade cycle)
* A refactoring modifies module interfaces that other modules depend on
* License compliance audit is required for the dependency tree

### Do NOT use this skill for:

* Evaluating whether a dependency is architecturally appropriate for the system (use System Design or Abstraction & Domain Modeling)
* Implementing the actual decoupling refactoring (use Refactoring)
* Managing infrastructure-level dependencies like cloud services or hardware (out of scope)
* Resolving runtime performance issues caused by dependency overhead (use Performance Optimization)

**Execution Context Details:**
Dependency Management sits between System Design (which identifies coupling risks at component level) and Refactoring (which executes the fixes). It runs in two modes: proactive (during new dependency addition or module creation) and reactive (when coupling problems are reported or flagged). It may run before or after System Design depending on whether the trigger is a new design or an existing system problem.

---

## Inputs

**Required inputs:**

* **Module definitions** — The set of modules, packages, or services in scope with their import/require statements or dependency declarations. This is the primary input for internal dependency graph construction.
* **External library list** — The current dependency manifest (e.g., package.json, requirements.txt, pom.xml, go.mod) including version constraints and lock files. Used for version analysis and license checking.

**Optional inputs:**

* **Integration requirements** — Which external systems, APIs, or services must be integrated, and what library choices they require or constrain.
* **License requirements** — Organizational or project-specific license compatibility rules. Required when CL-2 compliance is in scope.
* **Dependency graph from previous audit** — Enables comparison-based analysis (what changed since the last audit).

**Documents/Context needed:**

* **Dependency lock files** (package-lock.json, Pipfile.lock, etc.) — Provide the resolved transitive dependency tree, not just direct dependencies. Transitive dependencies are frequently the source of version conflicts.
* **Module architecture documentation** — Helps interpret the intended (vs. actual) dependency structure.

---

## Outputs

**Primary outputs:**

* **Dependency graph analysis** — Visual or textual representation of the actual dependency relationships, distinguishing direct from transitive dependencies and internal from external.
* **Version constraints and compatibility check** — For each dependency, whether current version is safe, whether a newer version introduces breaking changes, and what the safe upgrade path is.
* **Coupling risk report** — Identification of circular dependencies, overly coupled modules, high-fan-in modules that become implicit bottlenecks, and shared mutable state.
* **Decoupling recommendations** — For each identified coupling problem, at least one concrete recommendation for redesign (introduce abstraction layer, extract interface, invert dependency, introduce event-based communication).

**Output format:**

* Coupling risks ranked by severity (blocking / high / medium / low)
* Version conflict findings include the conflicting packages, conflicting version requirements, and resolution options
* All recommendations reference specific modules and proposed changes — no vague guidance

**Skill flags (if applicable):**

* Flag **refactoring** when coupling severity requires module redesign that exceeds a localized change
* Flag **system-design** when coupling problems reveal an architectural misalignment between intended and actual component boundaries
* Flag **backward-compatibility** when a dependency version change involves breaking API changes that affect consumers
* Flag **dependency-license-compliance** when a new or updated dependency introduces a license that may conflict with the project's requirements
* Flag **security** when a dependency has known security vulnerabilities (CVEs)

---

## Preconditions

**Conditions that must be met before execution:**

* Module definitions or dependency manifests are available for analysis
* The scope of analysis is defined (full codebase, specific service, specific new dependency)

**Validation checks:**

* [ ] Dependency manifest files (lock files preferred) are accessible
* [ ] Internal module boundaries are defined sufficiently to construct a graph
* [ ] License requirements are known if CL-2 is in scope

---

## Step-by-Step Execution Procedure

### Step 1: Construct the Dependency Graph

**Questions to answer:**
- What are all internal modules and their import/dependency relationships?
- What are the direct external dependencies and their resolved transitive trees?
- Are dependency declarations (e.g., package.json) consistent with lock files (actual resolved versions)?

**Actions:**
- [ ] Map all internal module-to-module dependencies (imports, service calls, shared utilities)
- [ ] Extract full transitive dependency tree from lock files (not just declared dependencies)
- [ ] Identify whether dependencies are direct, transitive, or both
- [ ] Flag any dependencies declared without version constraints (floating dependencies)

**Red flags / Warning signs:**
- Dependencies declared without version pins — floating versions lead to non-reproducible builds
- Lock file absent or out of sync with manifest — actual runtime dependencies are unknown
- A single internal utility module imported by more than 50% of other modules — high fan-in bottleneck

**Decision points:**
- If lock files are absent, halt and request them before proceeding — analysis on unresolved dependencies is unreliable

---

### Step 2: Detect Circular Dependencies

**Questions to answer:**
- Are there cycles in the internal module dependency graph?
- If cycles exist, are they direct (A → B → A) or transitive (A → B → C → A)?
- What is the minimum cut to break each cycle?

**Actions:**
- [ ] Apply cycle detection to the internal module graph (DFS or topological sort failure)
- [ ] For each cycle detected: identify the coupling pair(s) creating it
- [ ] Evaluate each cycle for business justification — no cycle is acceptable without explicit justification

**Red flags / Warning signs:**
- Any circular dependency — there is no legitimate architectural use case for circular module dependencies
- Cycles that span domain boundaries (e.g., OrderModule → UserModule → OrderModule) — indicates domain boundary violation

**Decision points:**
- Every detected cycle → block approval → recommend break strategy → flag refactoring if redesign required

---

### Step 3: Assess Internal Coupling Risk

**Questions to answer:**
- Which modules have the highest coupling (number of outbound dependencies)?
- Which modules are the most depended-upon (high fan-in) and therefore highest-risk to change?
- Does the coupling pattern match the intended domain boundaries?

**Actions:**
- [ ] Calculate afferent coupling (fan-in: how many modules depend on this module) for each module
- [ ] Calculate efferent coupling (fan-out: how many modules this module depends on) for each module
- [ ] Identify modules with high instability (high efferent, low afferent) that frequently change and have many dependents
- [ ] Validate coupling pattern against DA-1 (SRP at module level) and DA-4 (modules should only change when their business responsibility changes)

**Red flags / Warning signs:**
- A module changes frequently but is depended on by many others — high instability combined with high fan-in is a maintenance liability
- A module declared as infrastructure or utility is importing domain-specific modules — violates dependency direction
- Coupling between modules in different domain boundaries without an interface abstraction

**Decision points:**
- If coupling violates domain boundaries, flag system-design
- If coupling requires significant redesign, flag refactoring with specific modules and recommended approach

---

### Step 4: Evaluate External Dependency Health

**Questions to answer:**
- Are all external dependencies at versions without known CVEs?
- Are there version conflicts in the transitive dependency tree?
- Are any dependencies abandoned, deprecated, or end-of-life?
- Do all dependency licenses comply with project requirements?

**Actions:**
- [ ] Check each direct dependency against known vulnerability databases (or note if tooling should be applied)
- [ ] Identify version conflicts in the transitive tree where two packages require incompatible versions of the same library
- [ ] Flag any dependency that has no active maintenance (no releases in 24+ months)
- [ ] Apply CL-2: verify license of each new or updated dependency against project license policy

**Red flags / Warning signs:**
- Known CVEs in direct dependencies — must be addressed before production deployment
- Transitive version conflicts that are silently resolved by the package manager — the resolved version may not satisfy all consumers correctly
- New dependency introduced under a copyleft license (GPL, AGPL) in a proprietary project

**Decision points:**
- CVE detected → flag security and block production deployment approval
- License conflict detected → flag dependency-license-compliance → escalate to legal review if needed
- Transitive conflict detected → recommend explicit version pin + document rationale

---

### Step 5: Evaluate Version Upgrade Safety

**Questions to answer:**
- For proposed version upgrades: is this a major, minor, or patch change?
- Does the changelog or release notes document breaking changes?
- Are consumers of this dependency (internal modules) prepared for any breaking changes?
- What is the rollback path if the upgrade causes failures?

**Actions:**
- [ ] Classify each proposed upgrade by semver category
- [ ] Review changelog for breaking changes in major and minor upgrades
- [ ] Apply MF-3: verify that version changes do not silently break existing consumers
- [ ] Identify the rollback path (pin previous version) for each upgrade

**Red flags / Warning signs:**
- Major version upgrades without reviewing breaking changes in the changelog
- Upgrading a dependency that is used in multiple modules simultaneously without staged rollout plan
- Dependency that itself has dependency conflicts after upgrade (upgrading causes transitive tree to break)

**Decision points:**
- Breaking change confirmed → flag backward-compatibility → require consumer impact analysis
- High-risk upgrade → escalate to DT-2 Confirmation Gate

---

### Final Step: Generate Dependency Management Report

```markdown
## Dependency Management Report

**Scope:** [Service / Module / Full codebase]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ⚠️ NEEDS ATTENTION / ❌ BLOCKED

### Circular Dependencies
| Cycle | Severity | Break Strategy |
|-------|----------|---------------|
| [A → B → A] | BLOCKING | [Specific recommendation] |

### Coupling Risk Summary
| Module | Fan-In | Fan-Out | Risk Level | Action |
|--------|--------|---------|------------|--------|
| [Name] | [N] | [N] | [High/Med/Low] | [Action] |

### External Dependency Issues
| Package | Issue Type | Severity | Recommendation |
|---------|-----------|----------|---------------|
| [Name@version] | [CVE / License / Abandoned / Conflict] | [Critical/High/Med] | [Action] |

### Version Upgrade Findings
| Package | Current | Proposed | Breaking Changes | Safe? |
|---------|---------|---------|-----------------|-------|
| [Name] | [v] | [v] | [Yes/No — summary] | [Yes/No] |

### Skills Flagged for Follow-up
- **[Skill]**: [Specific reason]

### Overall Assessment
**Decision:** ✅ PASS / ⚠️ NEEDS ATTENTION / ❌ BLOCKED

### Required Actions
- [ ] [Action with owner and priority]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Construct the complete dependency graph (internal and external, direct and transitive)
2. Detect and block all circular dependencies with specific break strategies
3. Assess coupling severity per module and flag redesign needs
4. Verify external dependency health: CVEs, license compliance, version conflicts, abandonment
5. Evaluate upgrade safety for all proposed version changes
6. Log all significant findings and tradeoffs per DT-1

**Quality criteria:**

* No circular dependency may pass without explicit recommendation and escalation
* All CVEs in direct dependencies must be flagged with severity
* Every coupling risk finding includes a specific actionable recommendation
* License compliance checked for every new or changed dependency

---

## Constraints (Rules Applied)

* **DA-1: SOLID & Clean Code First** — Enforces SRP at module level: high efferent coupling violates SRP. Each dependency must represent a justified architectural requirement; a module should not import another without a defined interface contract.

* **DA-4: Change Boundary Rule** — Modules should only change when their own business responsibility changes. If changing LibraryX forces changes in unrelated modules, the abstraction layer is missing.

* **MF-3: Backward Compatibility** — Version changes must not silently break existing consumers. Read changelogs and verify consumers explicitly — semver alone is not sufficient.

* **CL-2: License Validation** — Every new or updated dependency must have its license verified before merge. Copyleft licenses (GPL, AGPL) in proprietary projects must be flagged at dependency addition time.

* **DT-1: Explicit Tradeoff Logging** — When coupling is accepted as a deliberate design tradeoff, log it with rationale. Undocumented coupling is assumed unintentional.

* **GM-2: Explain Before Acting** — For high-risk dependency changes (major version upgrades, removal of a widely-used dependency), explain consequences and alternatives before recommending.

* **GM-4: Behavioral Transparency** — Analysis findings must be based on actual graph data. When tooling is unavailable, state what could not be verified and why.

---

## Tradeoff Handling

### Tradeoff 1: Strict Dependency Rules vs. Developer Velocity

**Scenario:** Enforcing clean dependency rules (no shared mutable state, strict interface contracts) slows down feature development in early-stage projects where quick iteration is prioritized.

**Default stance:** Apply dependency rules strictly; document deliberate exceptions with time-boxed remediation plans.

**Resolution process:**
1. Identify whether the velocity concern is short-term (sprint) or systemic
2. If short-term: accept the temporary coupling, log it as technical debt per MF-2, and set a remediation date — coupling without a remediation timeline is unbounded debt
3. If systemic: escalate to stakeholder — the tradeoff between velocity and technical debt is a business decision (PC-3)
4. Log per DT-1

---

### Tradeoff 2: Stability vs. Security (Avoiding Known CVEs)

**Scenario:** Upgrading a dependency to address a CVE introduces breaking changes that require significant consumer updates.

**Default stance:** Security takes priority over stability. CVEs in production dependencies must be addressed.

**Resolution process:**
1. Assess CVE severity (Critical/High/Medium/Low)
2. For Critical/High: upgrade is mandatory; plan consumer updates
3. For Medium/Low: evaluate risk in context (is the vulnerable code path exercised? is the system internet-exposed?)
4. Document resolution decision per DT-1
5. For breaking upgrades: flag backward-compatibility and escalate to DT-2

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Circular Dependency Detected

**Trigger:** Cycle detected in the internal module dependency graph.

**Action:**
- Block approval immediately
- Identify the minimum cut to break the cycle
- Recommend abstraction strategy (introduce interface, invert dependency, extract shared concern)
- Flag refactoring if the redesign requires structural changes beyond localized edits

**Escalation format:**
```
❌ CIRCULAR DEPENDENCY DETECTED

Cycle: [ModuleA] → [ModuleB] → [ModuleA]
Severity: BLOCKING
Break strategy: [Specific recommendation with architectural reasoning]
Required action: Redesign before merge approval
```

---

### Escalation Scenario 2: CVE in Direct Dependency

**Trigger:** Known CVE identified in a direct dependency.

**Action:**
- Flag security with CVE details (CVE ID, CVSS score, affected versions, patched version)
- Block production deployment approval until resolved
- Provide the safe upgrade path or workaround

---

### Escalation Scenario 3: Coupling Reveals Architectural Misalignment

**Trigger:** Dependency analysis shows coupling patterns that violate the intended component boundaries established in System Design (e.g., cross-domain module imports without interface abstractions).

**Action:**
- Document the misalignment with specific module pairs
- Flag system-design for boundary re-evaluation
- Flag refactoring if immediate redesign is actionable

---

### Escalation Scenario 4: Major Version Upgrade with Breaking Changes

**Trigger:** Proposed dependency upgrade is a major version with documented breaking changes affecting multiple consumers.

**Action:**
- Flag backward-compatibility with consumer impact analysis
- Escalate to DT-2 Confirmation Gate for stakeholder approval before proceeding
- Provide staged upgrade plan (version pin strategy, consumer update sequence)

---

### When to halt execution:

* Lock files are absent and transitive dependency tree cannot be determined
* A circular dependency is detected — halt approval pending resolution
* A critical CVE is present in a direct dependency — halt production deployment approval

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Dependency Management runs as both a proactive gate (triggered by new dependency additions) and a reactive analysis tool (triggered by system design flags, build failures, or coupling incidents). It operates between System Design (structural intent) and Refactoring (structural fixes).

### How This Skill Integrates

**Does NOT directly call other skills.** This skill **flags** downstream skills based on findings.

**Integration workflow:**
1. **Orchestrator** invokes Dependency Management based on triggers
2. Skill constructs the dependency graph, analyzes coupling and external dependency health
3. Skill **outputs flags** for refactoring, system-design, security, backward-compatibility, etc.
4. **Orchestrator** invokes flagged skills based on findings

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|-------------------|-----------------|---------|
| Circular dependency requiring module redesign | refactoring | Structural change needed to break cycle |
| Coupling violates intended component boundaries | system-design | Architecture boundaries need re-evaluation |
| Breaking dependency version change affecting consumers | backward-compatibility | Consumer impact analysis and migration plan required |
| Dependency with known CVE | security | Security vulnerability must be assessed and patched |
| New dependency with potentially conflicting license | dependency-license-compliance | License compatibility must be verified |
| High coupling in module that has poor modularity | modularity | Module boundary redesign may be warranted |

---

## Related Skills

**Skills this skill depends on:**
* None — Dependency Management is foundational and can run without dependencies. In practice it is often preceded by System Design which may identify coupling concerns.

**Skills this skill cooperates with:**

* **system-design** — System Design identifies component boundaries at the architectural level; Dependency Management validates that actual dependencies respect those boundaries.
* **modularity** — Modularity defines intra-component interfaces; Dependency Management validates that cross-component dependencies are properly mediated by those interfaces.
* **backward-compatibility** — Works closely with Dependency Management when external dependency upgrades involve breaking API changes that affect consumers.

**Skills this skill may invoke/flag:**

* **refactoring** — When coupling severity requires structural redesign, Refactoring executes the changes
* **system-design** — When coupling analysis reveals that the architectural component boundaries are not respected
* **backward-compatibility** — When version upgrades involve breaking changes for existing consumers
* **security** — When CVEs are detected in the dependency tree
* **dependency-license-compliance** — When license conflicts are detected
* **modularity** — When coupling issues suggest module boundary redesign is needed

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Flag all circular dependencies immediately — none may pass without escalation and resolution plan
* [ ] Check CL-2 for every new or updated dependency addition
* [ ] Log all accepted coupling tradeoffs via engineering_decision_logger per DT-1
* [ ] Explain risks before approving high-risk dependency changes per GM-2
* [ ] Never approve production deployment with Critical or High CVEs in direct dependencies
* [ ] Validate against lock files, not just manifests — manifests do not represent the resolved transitive tree

**Audit trail requirements:**

* All detected circular dependencies must be logged, even if subsequently resolved
* CVE findings must be logged with severity, affected package, and resolution status
* All accepted coupling tradeoffs must be logged with rationale and remediation timeline

---

## Example Use Cases

### Example 1: Detecting a Circular Dependency Before Merge

**Scenario:** A code review reveals that a newly added import in `OrderService` creates a circular dependency: `OrderService` → `InventoryService` → `PricingService` → `OrderService`.

**Inputs provided:**
- Updated module dependency declarations after feature branch changes
- Module responsibility map

**Execution steps:**
1. Graph constructed — cycle detected: OrderService → InventoryService → PricingService → OrderService
2. PricingService's dependency on OrderService examined — it imports `OrderService.calculateTax()` which is not order-specific logic
3. Recommendation: extract `TaxCalculationService` from `OrderService` as a shared utility with no upward dependencies; all three modules import from it instead

**Result:** ❌ BLOCKED — circular dependency must be resolved before merge approval

**Skills flagged:** refactoring (extracting TaxCalculationService requires structural change)

---

### Example 2: Pre-Release External Dependency Audit

**Scenario:** Pre-release audit of an e-commerce service's dependencies before a major version launch.

**Inputs provided:**
- package-lock.json (full transitive tree)
- Project license: MIT
- Known CVE policy: Critical/High must be resolved before release

**Execution steps:**
1. Full transitive tree extracted from lock file (187 packages total)
2. CVE check: `lodash@4.17.15` has a known prototype pollution CVE (High) — must be upgraded to 4.17.21
3. License check: new dependency `pdf-lib` carries MIT license — compatible. `node-forge` carries BSD-3-Clause — compatible
4. Version conflict found: two packages require `semver@6.x` and `semver@7.x` — package manager resolved to `7.x`; verify both consumers work with resolved version
5. Abandoned dependency: `request` package (no release in 3 years) — recommend migration to `node-fetch` or `axios`

**Result:** ⚠️ NEEDS ATTENTION — CVE must be patched before release; abandoned dependency should be scheduled for replacement

**Skills flagged:** security (lodash CVE), dependency-license-compliance (licensing verified — no action needed, informational)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Analyzing Manifests Without Lock Files**
Reviewing only declared dependencies (package.json `dependencies`) without the resolved transitive tree (package-lock.json). Transitive dependencies are often the source of version conflicts and CVEs.
✅ **Correct approach:** Always work from lock files. If lock files are absent, request them before analysis proceeds.

❌ **Anti-pattern 2: Accepting Circular Dependencies "Just This Once"**
Allowing circular dependencies with the intention of fixing them later. They rarely get fixed and compound as more code assumes the cycle exists.
✅ **Correct approach:** Treat every circular dependency as a blocking issue. Every cycle must have a concrete break strategy before merge approval.

❌ **Anti-pattern 3: Version Pinning Without Documentation**
Pinning a dependency to a specific version to resolve a conflict without documenting why the pin was needed and when it should be revisited.
✅ **Correct approach:** Every manual version pin must be accompanied by a comment in the manifest explaining why and referencing the issue/CVE/conflict it resolves.

❌ **Anti-pattern 4: Ignoring Transitive Dependency CVEs**
Addressing CVEs only in direct dependencies while ignoring CVEs in transitive dependencies. The vulnerable code path may be reached through transitive calls.
✅ **Correct approach:** Audit the full transitive tree for CVEs. Severity determines priority, but no CVE should be unknown.

❌ **Anti-pattern 5: Coupling via Shared Utility Modules**
All modules importing a central "utils" or "helpers" module that accumulates unrelated shared logic. This creates high fan-in on an unstable module that changes frequently.
✅ **Correct approach:** Shared utilities should be stable, minimal, and domain-agnostic. Domain-specific logic belongs in the domain module, not a shared utility. If a utility module becomes a dumping ground, split it by domain.

❌ **Anti-pattern 6: Floating Dependency Versions**
Declaring dependencies without version constraints (`"lodash": "*"` or `"lodash": "latest"`). This makes builds non-reproducible and allows breaking changes to enter undetected.
✅ **Correct approach:** All dependencies must have explicit version constraints. Use lock files to pin transitive versions. Never use `*` or `latest` in production manifests.

❌ **Anti-pattern 7: Upgrading Dependencies Without Reading Changelogs**
Treating semver as a complete safety guarantee — assuming minor version bumps have no breaking changes. Semver discipline varies; breaking changes in minor versions exist in the wild.
✅ **Correct approach:** For any dependency update affecting production paths, review the changelog explicitly for breaking changes, not just the semver classification.

❌ **Anti-pattern 8: Skipping License Checks for Internal or Trusted Dependencies**
Assuming that dependencies from "trusted" sources (internal packages, well-known open-source libraries) don't require license checks. License changes happen on version upgrades.
✅ **Correct approach:** Check license on every new dependency AND on every major version upgrade — licenses can change between versions.

---

## Non-Goals

**This skill explicitly does NOT handle:**

* ❌ **Evaluating the architectural fitness of a dependency** — Whether a library is architecturally appropriate for the system (e.g., using a heavyweight ORM when simple queries would suffice) is a System Design or Design Pattern Selection concern.
* ❌ **Implementing decoupling refactors** — Dependency Management identifies and recommends; Refactoring executes the changes.
* ❌ **Infrastructure or cloud service dependencies** — Cloud provider services, hardware dependencies, and infrastructure-level concerns are out of scope (DevOps Phase 4 skills handle these).
* ❌ **Performance profiling of dependency overhead** — Whether a dependency adds unacceptable performance overhead is a Performance Optimization concern.

**Boundary clarifications:**

* Dependency Management flags backward-compatibility when version changes break consumers; it does not design the migration path — that is Backward Compatibility's responsibility.
* Dependency Management detects CVEs and flags security; it does not determine the security architecture response — that is Security's responsibility.
* Dependency Management identifies coupling violations; it flags Refactoring for the redesign but does not implement it.

---

## Notes for LLM Implementation

1. **Work from lock files, not manifests**: Always request lock files if not provided. Manifests show intent; lock files show reality.
2. **Treat circular dependencies as blocking**: Never soft-pedal a cycle. Every cycle must have a concrete break strategy.
3. **Be specific in coupling risk findings**: "Module A is too coupled" is not actionable. "Module A imports 12 modules including OrderService and InventoryService, creating a 3-way circular dependency — recommend extracting shared types to a dedicated types module" is actionable.
4. **Apply CL-2 proactively**: License checks are automatic for every new dependency. Note the license in the report even when it passes — audit trail.
5. **Differentiate direct from transitive issues**: A CVE in a transitive dependency is a real finding but a different priority than a direct one. Clearly distinguish in the report.
6. Use tables for dependency findings, coupling metrics, and version analysis. All findings include specific module names, package names, and versions. All recommendations include the specific change required.
7. In monorepos, distinguish cross-package from within-package dependencies. For multi-language codebases, analyze each ecosystem separately. Tool-specific outputs (dependency checkers, SAST) are inputs to this skill, not replacements for it.

---
