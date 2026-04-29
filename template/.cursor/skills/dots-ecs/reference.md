# Skill Human Spec: DOTS/ECS

```yaml
---
name: dots-ecs
description: Enforces Unity DOTS/ECS conventions for struct ISystem, BurstCompile, IJobEntity iteration, and NativeArray allocation
version: 1.0.0
category: Performance
tags: [unity, dots, ecs, burst, jobs, nativearray, entities]
priority: Medium

depends_on: [code-standards]
flags_skills: [performance-optimization]

inputs: [ecs_systems, job_structs, native_collections, component_data]
outputs: [dots_assessment, violations_list, corrected_patterns, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - PC-1   # Analyze Complexity
  - PC-4   # Performance Budget
  - MF-5   # Reliability Rule

documents_needed: [unity_entities_docs, project_ecs_architecture]

execution_context: Runs on any DOTS system, job, or native collection code; requires code-standards to have passed
---
```

---

# Skill: DOTS/ECS

---

## Purpose

**What this skill does:**
Enforces Unity DOTS/ECS conventions including struct-based ISystem with BurstCompile attributes, partial struct IJobEntity for component iteration, correct in/ref access declarations, and lifetime-appropriate NativeArray allocator selection. Ensures DOTS code is Burst-compatible, memory-safe, and leak-free.

DOTS code that bypasses Burst or misuses allocators silently degrades performance or causes memory leaks — both invisible until late in development. This skill catches those issues at authoring time.

Burst compilation provides significant CPU throughput gains, but only when code follows strict structural requirements. NativeArray leaks cause editor instability. This skill enforces correctness of the entire DOTS authoring surface.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Any ISystem, IJobEntity, or ComponentData struct is created or modified
* NativeArray, NativeList, NativeHashMap, or other native collection is declared
* BurstCompile attribute is missing on a performance-critical system
* Memory leaks are suspected in DOTS code
* Code review reveals class-based SystemBase on a hot path
* DOTS job is reading from components it should only write or vice versa

### Do NOT use this skill for:

* MonoBehaviour-based code (use code-standards)
* Non-DOTS C# class design (use clean-code-solid)
* Managed ECS (class-based SystemBase for tooling/editor systems is acceptable)
* Performance profiling and measurement (use performance-optimization)

**Execution Context Details:**
Runs after code-standards on ECS-specific files. DOTS code lives in Systems/ or a dedicated ECS feature folder. performance-optimization may be flagged if leak or budget violations are found.

---

## Inputs

**Required inputs:**

* **ECS systems** — ISystem or SystemBase structs/classes under review
* **Job structs** — IJobEntity partial structs with component access declarations
* **Native collections** — NativeArray, NativeList, and similar declarations with allocator choices

**Optional inputs:**

* **Project ECS architecture doc** — Describes which systems belong to which SystemGroup and expected update order

**Documents/Context needed:**

* **Unity Entities documentation** — Authoritative reference for Burst compatibility requirements and allocator semantics
* **Project ECS architecture** — SystemGroup assignments and expected performance budgets

---

## Outputs

**Primary outputs:**

* **DOTS assessment** — Pass/Fail/Needs Review per DOTS convention category
* **Violations list** — Each violation with file location, severity, and corrected form
* **Corrected patterns** — Before/after code showing the fix
* **Approval status** — Whether code meets DOTS standards

**Output format:**

* Structured report with sections: ISystem Structure, Burst Compatibility, Job Iteration, Memory Management
* Code blocks for every correction

**Skill flags (if applicable):**

* Flag **performance-optimization** when undisposed NativeArrays or allocator mismatches are found

---

## Preconditions

**Conditions that must be met before execution:**

* Code compiles without errors
* Unity Entities package is present in project manifest
* code-standards has passed for associated files

**Validation checks:**

* [ ] Unity.Entities namespace is referenced
* [ ] Entities package present in manifest
* [ ] No managed types inside IComponentData (classes, strings, arrays — not Burst-compatible)

---

## Step-by-Step Execution Procedure

### Step 1: Validate ISystem Structure

**Questions to answer:**
- Is the system declared as a struct implementing ISystem (not a class)?
- Is the [BurstCompile] attribute present on both the struct and OnUpdate?

**Actions:**
- [ ] Confirm `public partial struct MySystem : ISystem` — not a class
- [ ] Check `[BurstCompile]` on the struct declaration
- [ ] Check `[BurstCompile]` on the `OnUpdate(ref SystemState state)` method
- [ ] Flag any `public class MySystem : SystemBase` on performance-critical paths

**Red flags / Warning signs:**
- SystemBase class used where hot-path performance is required
- [BurstCompile] on struct but missing on OnUpdate method

**Decision points:**
- If class-based on hot path: warn, request migration to ISystem with justification for exception
- If BurstCompile missing: warn on struct, block on OnUpdate (most impactful)

---

### Step 2: Validate IJobEntity Structure

**Questions to answer:**
- Are job structs declared as `partial struct` implementing `IJobEntity`?
- Is read-only component access declared with `in` and write access with `ref`?

**Actions:**
- [ ] Confirm `public partial struct MyJob : IJobEntity` — partial struct
- [ ] Scan component parameters for `in` (read-only) and `ref` (read-write) declarations
- [ ] Flag any component accessed with `ref` that is only read
- [ ] Check `[BurstCompile]` on the Execute method if performance-critical

**Red flags / Warning signs:**
- `ref ComponentData` when only reading — prevents Burst from optimising read-only paths
- Missing `partial` keyword on job struct — will not compile with source generators

**Decision points:**
- If ref used on read-only: warn, change to `in`
- If partial missing: block — will not compile

---

### Step 3: Validate NativeArray Allocator Selection

**Questions to answer:**
- Is the allocator lifetime appropriate for the usage scope?
- Are Persistent allocators disposed before going out of scope?

**Actions:**
- [ ] Identify all `NativeArray<T>` (and other native collection) declarations
- [ ] Verify allocator choice: Temp (single frame only), TempJob (job duration), Persistent (long-lived)
- [ ] Confirm Temp collections are not passed to jobs (use TempJob instead)
- [ ] Confirm Persistent collections are disposed in OnDestroy/OnNetworkDespawn/system cleanup

**Red flags / Warning signs:**
- `Allocator.Temp` passed to a scheduled job — will cause errors
- `Allocator.Persistent` created in OnUpdate without tracking disposal
- NativeArray declared in a method with no dispose call or `using` block

**Decision points:**
- If Temp in job: block, change to TempJob
- If Persistent without dispose: block, flag performance-optimization

---

### Step 4: Validate Burst Compatibility

**Questions to answer:**
- Does the Burst-compiled code reference any managed types (classes, strings, List<T>)?
- Are there any managed exceptions (throw new Exception) inside [BurstCompile] methods?

**Actions:**
- [ ] Scan [BurstCompile] methods for managed type references
- [ ] Flag string operations, Debug.Log, or class instantiation inside Burst-compiled paths
- [ ] Check for `throw` statements in Burst context (not supported)

**Red flags / Warning signs:**
- `Debug.Log()` inside [BurstCompile] method — not Burst-compatible
- Managed List<T> or Dictionary inside a Burst job struct

**Decision points:**
- If managed type in Burst context: block, show NativeArray/FixedString alternative

---

### Final Step: Generate DOTS Report

```markdown
## DOTS/ECS Report

**Target:** [SystemName.cs / JobName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### ISystem Structure
[Finding — struct vs class, BurstCompile presence]

### IJobEntity Structure
[Finding — partial struct, in/ref correctness]

### NativeArray Allocators
[Finding — allocator selection and disposal]

### Burst Compatibility
[Finding — managed type usage in Burst context]

### Overall Assessment
- ✅ PASS: All DOTS conventions met, no leaks detected
- ❌ FAIL: Missing BurstCompile, wrong allocator, or managed types in Burst
- ⚠️ NEEDS REVIEW: SystemBase on hot path or ref/in mismatches

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce struct ISystem with BurstCompile on both struct and OnUpdate
2. Require partial struct IJobEntity with correct in/ref access declarations
3. Validate NativeArray allocator selection matches usage lifetime
4. Confirm all Persistent native collections are explicitly disposed
5. Reject managed types inside Burst-compiled methods

**Quality criteria:**

* Zero systems on hot path using class-based SystemBase without justification
* Every NativeArray with Persistent allocator has a corresponding Dispose call
* No managed types referenced inside [BurstCompile] scope

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - Applies: Systems should have single, focused responsibilities; one system per concern
  - In practice: A `MovementSystem` handles position updates; a separate `DamageSystem` handles health — not combined

### Performance & Complexity Rules

* **PC-1: Analyze Complexity**
  - Applies: Native collection operations have specific complexity profiles; NativeHashMap lookups vs NativeArray linear scans
  - In practice: Choose collection type based on access pattern, not familiarity

* **PC-4: Performance Budget**
  - Applies: DOTS systems are expected to meet frame budget targets; Burst non-compliance is a budget violation
  - In practice: If a system is in a SystemGroup with a 1ms budget, it must be Burst-compiled

### Maintenance & Feature Consistency Rules

* **MF-5: Reliability**
  - Applies: Native memory leaks destabilise the editor and runtime; all Persistent allocations must have explicit disposal paths
  - In practice: Dispose in OnStopRunning or a dedicated system cleanup method

---

## Tradeoff Handling

### Tradeoff 1: Burst Compliance vs. Debugging Convenience

**Scenario:** Developer adds `Debug.Log` in a Burst method to debug an issue.

**Default stance:** Allow temporarily during active debugging; block on merge. Debug.Log is not Burst-compatible and must be removed before commit.

**Resolution process:**
1. Flag as temporary dev pattern
2. Suggest `Unity.Burst.BurstDiscard` attribute for debug-only paths
3. Log as must-remove before merge via MF-2

---

### Tradeoff 2: ISystem vs. SystemBase for Tooling

**Scenario:** An editor/tooling system needs managed type access — ISystem is not appropriate.

**Default stance:** SystemBase is acceptable for non-hot-path editor/tooling systems. Block ISystem requirement only for runtime performance systems.

**Resolution process:**
1. Classify system as runtime/hot-path or tooling/editor
2. If tooling: allow SystemBase, document the exception
3. If runtime: require ISystem with Burst

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Persistent NativeArray Without Dispose

**Trigger:** `NativeArray<float3> _positions = new NativeArray<float3>(count, Allocator.Persistent)` with no Dispose call found.

**Action:**
- Block merge
- Request Dispose in system OnStopRunning or IDisposable implementation
- Flag performance-optimization

---

### Escalation Scenario 2: Managed Type in Burst Context

**Trigger:** `List<Entity>` or `string` referenced inside a [BurstCompile] method.

**Action:**
- Block — code will fail Burst compilation
- Request NativeList<Entity> or FixedString equivalent

---

### Escalation Scenario 3: Allocator.Temp Passed to Job

**Trigger:** `new NativeArray<int>(count, Allocator.Temp)` scheduled in a job.

**Action:**
- Block — runtime error in safety checks
- Change to `Allocator.TempJob`

---

### When to halt execution:

* Unity Entities package not present — DOTS conventions cannot apply
* Code does not involve any ISystem, IJobEntity, or native collections — wrong skill

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on DOTS-specific files. Acts as a DOTS correctness gate. Flags performance-optimization for memory leak concerns.

**Integration workflow:**
1. code-standards passes
2. Orchestrator invokes dots-ecs
3. dots-ecs assesses structure, Burst compliance, allocators
4. If Persistent leak found: flag performance-optimization
5. After pass: testing-standards may run

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Persistent NativeArray without dispose | performance-optimization | Memory leak impacts runtime stability |
| Allocator misuse causing GC pressure | performance-optimization | Wrong allocator degrades frame budget |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Ensures C# structural conventions before DOTS-specific checks; partial struct and naming conventions come from code-standards

**Skills this skill cooperates with:**

* **performance-optimization** — Cooperates on memory and frame budget concerns; DOTS is the authoring layer, performance-optimization addresses measurement and pooling

**Skills this skill may invoke/flag:**

* **performance-optimization** — When native memory leaks or allocator mismatches are found that will impact frame performance

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block on Persistent NativeArray without dispose — never warn-only
* [ ] Explain memory leak consequence before requesting fix
* [ ] Log all approved SystemBase-on-hot-path exceptions via DT-1
* [ ] Do not apply BurstCompile requirement to editor/tooling systems
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* SystemBase exceptions (allowed on tooling systems) must be documented via DT-1
* Any approved Burst non-compliance must be logged with remediation timeline

---

## Example Use Cases

### Example 1: Missing BurstCompile on OnUpdate

**Scenario:** `MovementSystem : ISystem` struct has [BurstCompile] on the struct but not on OnUpdate.

**Execution steps:**
1. Validate ISystem struct — [BurstCompile] present on struct ✅
2. Check OnUpdate — [BurstCompile] missing ❌
3. Provide fix: add `[BurstCompile]` above `public void OnUpdate(ref SystemState state)`

**Result:** ❌ FAIL

---

### Example 2: NativeArray with Wrong Allocator in Job

**Scenario:** `new NativeArray<Entity>(100, Allocator.Temp)` passed to a scheduled IJobEntity.

**Execution steps:**
1. Identify NativeArray with Allocator.Temp
2. Detect usage in scheduled job context
3. Block: Temp allocator invalid in jobs; change to TempJob

**Result:** ❌ FAIL

---

### Example 3: Fully Compliant ECS System

**Scenario:** MovementSystem as `[BurstCompile] public partial struct MovementSystem : ISystem`, with correct `in` on read-only components, `ref` on written components, TempJob allocators in jobs.

**Result:** ✅ PASS

---

### Example 4: SystemBase on Tooling Path

**Scenario:** `EditorSpawnSystem : SystemBase` used in an editor-only system that references managed types.

**Execution steps:**
1. Classify: editor-only tooling system
2. SystemBase acceptable — not a hot-path runtime system
3. Document exception in report

**Result:** ✅ PASS with documented exception

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `public class MovementSystem : SystemBase` on a hot-path runtime system
✅ **Correct approach:** `[BurstCompile] public partial struct MovementSystem : ISystem`

❌ **Anti-pattern 2:** Missing [BurstCompile] on OnUpdate method
✅ **Correct approach:** Apply [BurstCompile] to both the struct and OnUpdate

❌ **Anti-pattern 3:** `ref HealthComponent` when only reading health
✅ **Correct approach:** `in HealthComponent` for read-only component access

❌ **Anti-pattern 4:** `new NativeArray<int>(count, Allocator.Temp)` passed to scheduled job
✅ **Correct approach:** `new NativeArray<int>(count, Allocator.TempJob)` for job-duration collections

❌ **Anti-pattern 5:** Persistent NativeArray with no Dispose call
✅ **Correct approach:** Dispose in `OnStopRunning` or system `OnDestroy` equivalent

❌ **Anti-pattern 6:** `Debug.Log("value: " + x)` inside [BurstCompile] method
✅ **Correct approach:** Remove before merge; use `[BurstDiscard]` attribute for debug-only paths

❌ **Anti-pattern 7:** `List<Entity>` field inside an IJobEntity struct
✅ **Correct approach:** `NativeList<Entity>` with appropriate allocator

❌ **Anti-pattern 8:** Job struct not declared as `partial`
✅ **Correct approach:** `public partial struct MyJob : IJobEntity`

❌ **Anti-pattern 9:** `throw new Exception("error")` inside [BurstCompile] method
✅ **Correct approach:** Use Burst-compatible error signaling (return codes, bool flags)

---

## Non-Goals

* ❌ Does not profile or measure system performance at runtime — use performance-optimization
* ❌ Does not validate SystemGroup ordering or update loop architecture — use architecture-patterns
* ❌ Does not assess non-DOTS MonoBehaviour code — use code-standards
* ❌ Does not validate ECS baking workflows or baker correctness

---

## Notes for LLM Implementation

1. **Distinguish runtime vs. tooling systems** — SystemBase is acceptable for editor/tooling; only flag on hot-path runtime systems
2. **Always show the Burst-compatible alternative** — never just flag; provide the fix
3. **Allocator semantics matter** — explain WHY Temp is invalid in jobs, not just that it is
4. **partial struct is a compile requirement** — missing partial is a hard block, not a style issue
5. **in vs. ref is a performance and safety issue** — wrong access declaration prevents Burst optimisation

**Output format preferences:**
* Code blocks for every correction
* Severity labels: BURST-COMPAT / MEMORY-SAFETY / PERFORMANCE
* Required actions as checkboxes

---

## Metadata Summary

```yaml
name: dots-ecs
category: Performance
priority: Medium
depends_on: [code-standards]
flags_skills: [performance-optimization]
rules_applied: [DA-1, PC-1, PC-4, MF-5]
documents_needed: [unity_entities_docs, project_ecs_architecture]
tags: [unity, dots, ecs, burst, jobs, nativearray, entities]
```

**Key relationships:**
- Depends on: code-standards (structural baseline)
- Flags: performance-optimization (for native memory leaks)
- Governed by: DA-1 (single responsibility), PC-1 (complexity), PC-4 (budget), MF-5 (reliability)
