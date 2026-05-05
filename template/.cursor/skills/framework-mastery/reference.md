```yaml
---
name: framework-mastery
description: Applies framework-specific conventions, lifecycle patterns, and best practices for consistent, secure, and performant application development.
version: 1.1.0
category: Engineering
tags: [framework, lifecycle, conventions, integration, best-practices]
priority: Medium

depends_on: []
flags_skills: [language-specific-implementation, security, backward-compatibility]

inputs: [framework-version-and-docs, project-architecture-and-usage-patterns, functional-requirements]
outputs: [framework-compliant-code, framework-config, anti-pattern-findings]

rules_applied:
  - DA-1   # SOLID & Clean Code First — framework patterns must not override structural principles
  - DA-5   # Avoid Overengineering — use framework defaults before custom solutions
  - MF-3   # Backward Compatibility — framework upgrades must be assessed for breaking changes
  - TQ-1   # Test Coverage Requirement — framework integrations must have test coverage

documents_needed: [framework-official-docs, framework-version-changelog, project-architecture-docs]

execution_context: Activates when implementing framework-specific lifecycle, configuration, or integration patterns. Often runs alongside or after language-specific-implementation.
---
```

---

# Skill: Framework Mastery

---

## Purpose

**What this skill does:**
Applies the conventions, lifecycle patterns, and best practices of the specific framework in use to produce code that integrates correctly and consistently with the framework's model. This skill covers lifecycle hooks, dependency injection patterns, configuration idioms, routing, middleware, and framework-specific security or performance concerns.

Incorrect or inconsistent framework usage creates subtle bugs — misconfigured lifecycle hooks cause state corruption, inconsistent dependency injection causes test failures, deviation from framework conventions creates onboarding friction. Applying framework conventions correctly prevents a whole class of defects that are expensive to diagnose.

Frameworks provide tested, optimized implementations for cross-cutting concerns. Correct framework usage gets the team "free" correctness for authentication, session management, error handling, and request routing. Deviating from framework conventions trades away this correctness guarantee for no engineering benefit.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Implementing features that use framework lifecycle hooks (React component lifecycle, Spring bean lifecycle, Django request/response cycle)
* Configuring framework-managed services (DI containers, ORM configurations, middleware stacks)
* Adding framework-specific integrations (authentication, caching, task queues managed by the framework)
* Upgrading framework versions — breaking change assessment required
* Identifying inconsistent framework usage patterns across the project
* Security configurations managed by the framework (CSRF, CORS, session management)

### Do NOT use this skill for:

* Pure language idiom choices without framework involvement — delegate to **language-specific-implementation**
* Algorithmic optimization unrelated to framework behavior — delegate to **performance-optimization**
* Framework tooling setup (linting plugins, IDE extensions) — delegate to **tooling-and-ides**
* Architectural decisions about which framework to adopt — delegate to **system-design**

**Execution Context Details:**
Often invoked alongside or immediately after **language-specific-implementation** when feature development requires both idiomatic language code and framework integration. May also be invoked standalone for framework upgrade assessment (MF-3) or consistency audits.

---

## Inputs

**Required inputs:**

* **Framework documentation and version** — The specific framework version in use; conventions vary significantly between major versions (e.g., React class components vs hooks, Spring XML vs annotation-based config).
* **Project architecture and existing usage patterns** — How the framework is currently used in the project; new code must be consistent with established patterns (DA-7).
* **Functional requirements** — The feature to implement; determines which framework capabilities are relevant.

**Optional inputs:**

* **Framework version changelog** — Required for upgrade assessments (MF-3).
* **Security configuration requirements** — If security-sensitive framework features are in scope.

---

## Outputs

**Primary outputs:**

* **Framework-compliant code** — Feature implementation using correct lifecycle hooks, DI patterns, routing, and configuration for the specific framework version.
* **Framework configuration** — Any configuration files, annotations, or declarations required for the framework to wire the feature correctly.
* **Anti-pattern findings** — Documented instances of framework misuse detected in existing code or introduced inadvertently, with remediation guidance.

**Output format:**

* Code with framework-idiomatic structure (e.g., constructor injection not field injection, functional components with hooks not class components)
* Configuration in the framework's native format
* Findings documented with severity (correctness-breaking vs. maintainability risk)

---

## Preconditions

**Conditions that must be met before execution:**

* Framework name and version are confirmed.
* Existing framework usage patterns in the project are reviewed.
* Functional requirements are clear enough to determine which framework capabilities are involved.

**Validation checks:**

* [ ] Framework version confirmed from project dependencies
* [ ] Existing usage patterns reviewed for consistency baseline (DA-7)
* [ ] Framework-specific security defaults reviewed if security-sensitive features are in scope

---

## Step-by-Step Execution Procedure

### Pre-Execution: Detect Code Artifacts in Scope

**Action:**
- [ ] Determine whether this invocation involves code generation, framework implementation, or code-level integration (not a pure advisory or audit invocation).
- [ ] If code artifacts are in scope → flag **language-specific-implementation** → co-invoke before planning begins.

*Pure advisory invocations (e.g., upgrade risk assessment, anti-pattern audit without implementation scope) do not trigger co-invocation.*

---

### Step 1: Identify Framework Version and Established Patterns

**Questions to answer:**
- What exact framework version is in use?
- What patterns are established in the codebase (constructor injection vs field injection, functional vs class components, etc.)?
- Are there any deprecated patterns in use that should be migrated?

**Actions:**
- [ ] Confirm framework version from dependency files (pom.xml, package.json, requirements.txt)
- [ ] Review existing framework usage for pattern consistency
- [ ] Check framework changelog for deprecation notices relevant to current version

**Red flags / Warning signs:**
- Mixed patterns in the codebase without documentation (some classes use constructor injection, others use field injection)
- Framework APIs marked as deprecated still in active use
- Framework version is significantly behind latest stable — upgrade assessment may be warranted

**Decision points:**
- If multiple conflicting patterns exist → document inconsistency; use the more idiomatic pattern for new code; flag for consistency cleanup
- If deprecated API is in use → do not replicate it in new code; log tech debt via MF-2

---

### Step 2: Design Framework Integration

**Questions to answer:**
- Which framework lifecycle hooks, annotations, or configuration points are needed?
- Does the feature require framework-managed services (DI, caching, event bus)?
- Are there framework-provided defaults that should be used before custom implementations?

**Actions:**
- [ ] Identify the correct lifecycle hook or integration point for the feature
- [ ] Use framework defaults and conventions before building custom solutions (DA-5)
- [ ] Verify that the chosen approach is consistent with the framework version's supported APIs

**Red flags / Warning signs:**
- Custom implementation of something the framework provides (e.g., custom session manager when framework provides one)
- Direct constructor instantiation of framework-managed beans/components
- Business logic embedded in framework infrastructure code (controllers doing data access, middleware doing domain logic)

**Decision points:**
- If framework convention conflicts with project pattern → document and log; prefer framework convention for new code unless deviation is intentional
- If latest framework feature is unstable or in preview → assess risk; prefer stable APIs

---

### Step 3: Implement Framework Integration

**Questions to answer:**
- Is the lifecycle hook wired correctly for all execution paths (happy path, error path, test context)?
- Are dependency injection bindings correct and complete?
- Is configuration correct for the deployment environment (dev vs prod profile differences)?

**Actions:**
- [ ] Implement using correct framework patterns for this version
- [ ] Verify DI bindings are complete and will resolve at startup
- [ ] Ensure test context wiring mirrors production context as closely as possible (TQ-1)
- [ ] Check framework-specific security defaults are not inadvertently disabled

**Red flags / Warning signs:**
- DI bindings that work in unit tests but fail in integration context
- Framework lifecycle hooks that work in happy path but are skipped on error
- Security-sensitive framework configurations changed from defaults without documentation

**Decision points:**
- If framework integration requires a performance tradeoff → confirm via PC-2
- If security-relevant framework config is changed from defaults → flag security skill

---

### Step 4: Validate and Test Framework Integration

**Questions to answer:**
- Does the integration work in the test context as well as production context?
- Are framework lifecycle events tested (initialization, teardown, error handling)?

**Actions:**
- [ ] Write or update tests covering framework integration paths (TQ-1)
- [ ] Include tests for lifecycle edge cases (startup failure, graceful shutdown, error handling in middleware)
- [ ] Verify backward compatibility if a framework upgrade was part of this task (MF-3)

---

### Final Step: Generate Output Report

**Report/Output structure:**

```markdown
## Framework Mastery Report

**Target:** [Feature or module implemented]
**Framework/Version:** [e.g., React 18, Spring Boot 3.2, Django 5.0]
**Status:** ✅ COMPLETE / ⚠️ FINDINGS / ❌ BLOCKED

### Framework Patterns Applied
- [Pattern 1]: [Where applied and why]
- [Pattern 2]: [Where applied and why]

### Anti-Pattern Findings
- [Finding 1]: [Description, severity, remediation]

### Upgrade Assessment (if applicable)
- Breaking changes identified: [List]
- Migration path: [Description]

### Skills Flagged for Follow-up
- **security**: [If security misconfiguration detected]
- **backward-compatibility**: [If breaking changes found in upgrade]

### Overall Assessment
**Decision:**
- ✅ COMPLETE: Integration is correct, consistent, and tested
- ⚠️ FINDINGS: Anti-patterns or inconsistencies detected; documented and logged
- ❌ BLOCKED: Framework constraint cannot be resolved without architectural decision
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Apply framework-specific lifecycle patterns, DI conventions, and configuration idioms correctly
2. Enforce uniform framework usage across the project (DA-7 via DA-1)
3. Identify and document framework-specific anti-patterns (incorrect lifecycle usage, misused DI, insecure defaults)
4. Assess framework upgrades for breaking changes before they are applied (MF-3)
5. Flag security when framework security configurations deviate from safe defaults

**Quality criteria:**

* Framework integration is correct for all execution paths including error paths
* No framework anti-patterns introduced or replicated
* Test coverage includes framework lifecycle paths (TQ-1)
* Upgrade assessments document all breaking API changes before upgrade proceeds

---

## Constraints (Rules Applied)

* **DA-1: SOLID & Clean Code First** — Framework patterns must not override structural principles; keep framework infrastructure code separate from domain logic (e.g., no data access in controllers).
* **DA-5: Avoid Overengineering** — Use framework defaults before custom solutions; never build a custom auth filter or DI container when the framework provides one.
* **MF-3: Backward Compatibility** — Framework upgrades must be assessed for breaking API changes; run the migration guide against the codebase before any major version upgrade.
* **TQ-1: Test Coverage Requirement** — Framework integrations must have test coverage including lifecycle edge cases; test DI resolution, lifecycle hook ordering, and error path behavior.

---

## Tradeoff Handling

### Tradeoff 1: Framework Convention vs Project-Specific Pattern

**Resolution:** If the existing project pattern is a framework anti-pattern, use framework convention for new code, log the inconsistency, and flag for cleanup. If not an anti-pattern, match the existing pattern and log the deviation via DT-1. Escalate to architect if the inconsistency spans many modules.

### Tradeoff 2: Cutting-Edge Framework Feature vs Stability

**Resolution:** If the framework feature is experimental or preview: HIGH risk → use stable alternative, log future migration path via DT-1; LOW risk → use the feature with explicit documentation of its stability status. Log decision via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Framework Security Misconfiguration Detected

**Trigger:** Framework security defaults have been changed (CSRF disabled, CORS wildcarded, insecure session config) without documentation.

**Action:**
- Flag **security** immediately.
- Do not proceed with integration until security configuration is reviewed.

**Escalation format:**
```
🛡️ SECURITY REVIEW NEEDED

Issue: Framework security configuration deviated from safe defaults
Config: [Specific setting and its current value]
Risk: [What attack vector this enables]
Recommendation: [Restore default or document justification]

Question: Is this deviation intentional and approved?
```

---

### Escalation Scenario 2: Framework Upgrade Breaking Changes

**Trigger:** A framework version upgrade is in scope and breaking changes are identified.

**Action:**
- Document all breaking changes with migration path.
- Flag **backward-compatibility** for review before upgrade proceeds.
- Do not apply the upgrade until migration plan is approved (DT-2).

---

### Escalation Scenario 3: Framework Anti-Pattern Deeply Embedded

**Trigger:** A framework anti-pattern (field injection throughout, lifecycle misuse) is pervasive and cannot be corrected in this task scope.

**Action:**
- Log as technical debt (MF-2).
- Do not replicate the anti-pattern in new code.
- Flag to prompt engineer with scope estimate for remediation.

---

### When to halt execution:

* Framework security configuration cannot be verified as safe
* Framework upgrade breaking changes cannot be resolved without architectural decisions
* Framework version cannot be confirmed and version-specific APIs are in play

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs during feature implementation (Stage 7). Often invoked alongside **language-specific-implementation**. May also be invoked standalone for consistency audits or upgrade assessments.

### How This Skill Integrates

1. **Orchestrator** invokes this skill when framework integration is part of the task
2. This skill implements the framework integration layer
3. This skill **flags security** if misconfiguration is detected
4. This skill **flags backward-compatibility** if upgrade breaking changes are identified
5. Output feeds into **correctness-validation** and **test-creation-strategy**

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Security misconfiguration in framework config | security | Framework security defaults changed without justification |
| Framework upgrade with breaking changes | backward-compatibility | Migration plan needed before upgrade proceeds |
| Language layer incomplete | language-specific-implementation | Language idiom selection needed alongside framework integration |

---

## Related Skills

**Skills this skill depends on:** None at runtime.

**Skills this skill cooperates with:**

* **language-specific-implementation** — Complementary; language idioms are the base layer, framework patterns are the integration layer.
* **security** — Framework security configurations overlap with security skill scope; flag when in doubt.
* **test-creation-strategy** — Framework lifecycle integration must be covered in integration tests.

---

## Governance Hooks

* [ ] Log all tradeoff decisions via DT-1 when deviating from framework convention
* [ ] Flag security before proceeding when framework security configuration is modified
* [ ] Do not apply framework upgrades without a breaking change assessment (MF-3)
* [ ] Do not use experimental framework APIs without explicit documentation of stability status
* [ ] Ensure test coverage for framework lifecycle paths (TQ-1)

---

## Example Use Cases

### Example 1: React Hook Migration from Class Component

**Scenario:** Existing class component uses `componentDidMount` and `componentDidUpdate` for data fetching. Framework convention (React 18) is hooks.

**Inputs provided:**
- Functional requirement: add a loading state to the component
- Framework: React 18, project has a mix of class and function components

**Execution steps:**
1. Identify that class component is a framework anti-pattern in React 18 context
2. Apply hook-based idiom: `useEffect` for lifecycle, `useState` for loading state
3. Note: existing class components are inconsistent with convention — log for cleanup
4. Ensure hook dependencies array is correct to avoid stale closure

**Result:** ✅ COMPLETE — Hook-based implementation is correct and consistent with React 18 convention
**Skills flagged:** None (inconsistency logged as tech debt, not flagged to skill)

---

### Example 2: Spring Boot Constructor Injection Enforcement

**Scenario:** New service class uses `@Autowired` field injection. Project convention is constructor injection.

**Execution steps:**
1. Identify field injection as framework anti-pattern (harder to test, hides dependencies)
2. Convert to constructor injection as per Spring best practice and project convention
3. Verify test context wiring works with constructor injection
4. Note in PR that field injection was changed — document reasoning

**Result:** ✅ COMPLETE — Constructor injection applied; test passes

---

### Example 3: Django CSRF Disabled Without Justification

**Scenario:** A new API view has `@csrf_exempt` applied without documentation.

**Execution steps:**
1. Identify `@csrf_exempt` as a deviation from framework security default
2. Flag **security** immediately; do not proceed with other framework integration until reviewed
3. Document the specific risk: CSRF attacks now possible on this endpoint

**Result:** ❌ BLOCKED pending security review
**Skills flagged:** security

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1: Field Injection in Spring**
`@Autowired` on fields makes dependencies invisible to the constructor, making classes harder to test and breaking immutability.
✅ Use constructor injection; mark dependencies `final`.

❌ **Anti-pattern 2: Business Logic in Framework Infrastructure**
Putting data access in controllers, domain logic in middleware, or validation in route handlers.
✅ Keep framework infrastructure thin; delegate to domain/service layer.

❌ **Anti-pattern 3: Misused React useEffect Dependencies**
Omitting dependencies from the `useEffect` array causes stale closures; exhaustive deps with unstable references causes infinite re-renders.
✅ Include all reactive values in deps; stabilize callbacks with `useCallback`.

❌ **Anti-pattern 4: Framework Version Upgrade Without Migration Check**
Upgrading a major framework version and relying on "it still compiles" as validation.
✅ Run the framework's migration guide against the codebase; check for deprecated API usage before upgrading.

❌ **Anti-pattern 5: Disabled Framework Security Defaults**
Disabling CSRF, CORS policies, or content security headers because they "block the feature."
✅ Understand why the security mechanism is blocking the feature; apply the correct configuration rather than disabling the protection.

❌ **Anti-pattern 6: Mixed Framework Patterns Without Rationale**
Some modules use DI, others use service locator; some use functional components, others use class components — without a migration path.
✅ Document a pattern standard; apply it consistently in new code; track migration as tech debt.

❌ **Anti-pattern 7: Using Framework Preview APIs in Production**
Adopting experimental or preview-marked APIs because they provide a convenient shortcut.
✅ Use stable APIs only; track preview API graduation and plan migration when stable.

❌ **Anti-pattern 8: Skipping Framework Lifecycle Testing**
Testing only happy-path functionality without testing framework lifecycle (startup, shutdown, error propagation through middleware).
✅ Integration tests must cover lifecycle edge cases: startup failure, graceful shutdown, middleware error propagation.

---

## Non-Goals

* ❌ **Pure language idiom choices** — handled by **language-specific-implementation**
* ❌ **Algorithmic optimization** — handled by **performance-optimization** (Phase 1)
* ❌ **Framework tool/IDE setup** — handled by **tooling-and-ides**
* ❌ **Which framework to adopt** — handled by **system-design** (Phase 2)
* ❌ **Platform-level runtime tuning** — handled by **platform-specific-optimization**

---

## Notes for LLM Implementation

**When executing this skill, the LLM should:**

1. **Confirm framework version first** — framework conventions change significantly between major versions; never assume
2. **Check existing patterns before introducing new ones** — consistency (DA-7) matters as much as correctness
3. **Flag security immediately** if framework security defaults have been changed — this is not a deferred finding
4. **Do not use preview APIs without documenting the stability risk** — label them explicitly
5. **Cover lifecycle paths in test guidance** — framework integration bugs typically surface in lifecycle edge cases, not happy paths.
6. Flag security and backward-compatibility findings prominently; list anti-patterns with severity (correctness-breaking vs. maintainability); separate framework configuration from code implementation.
7. Be concrete: name the specific framework anti-pattern, not just "bad practice"; be decisive on security findings — do not soft-pedal a disabled CSRF token.
