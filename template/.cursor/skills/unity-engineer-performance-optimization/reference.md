# Skill Human Spec: Performance Optimization

```yaml
---
name: performance-optimization
description: Enforces Unity performance patterns including ObjectPool, Addressables lifecycle, StringBuilder for text, and Update loop hygiene
version: 1.0.0
category: Performance
tags: [unity, performance, objectpool, addressables, stringbuilder, update-loop]
priority: High

depends_on: [code-standards]
flags_skills: []

inputs: [source_code, hot_path_scripts, update_loop_methods, asset_loading_code]
outputs: [performance_assessment, violations_list, optimized_patterns, approval_status]

rules_applied:
  - PC-1   # Analyze Complexity
  - PC-4   # Performance Budget
  - MF-5   # Reliability Rule
  - DA-5   # Avoid Overengineering

documents_needed: [project_performance_targets, unity_profiler_baseline]

execution_context: Runs on performance-sensitive scripts; after code-standards; flags violations before they reach production
---
```

---

# Skill: Performance Optimization

---

## Purpose

**What this skill does:**
Enforces Unity-specific performance patterns: ObjectPool<T> for frequently instantiated objects, Addressables.Release for memory leak prevention, StringBuilder with TMP_Text.SetText for frequent text updates, and appropriate Update/FixedUpdate/LateUpdate usage. Catches performance anti-patterns at authoring time before profiling is needed.

Performance regressions in games are expensive to diagnose late. This skill catches the most common Unity-specific performance issues (GC allocations from Instantiate/Destroy loops, unclosed Addressable handles, per-frame string allocation) at code review time, reducing profiling and hotfix cycles.

Enforces patterns that eliminate common sources of GC pressure and frame spikes in Unity — object pooling, managed memory discipline, and correct loop hygiene.

---

## When to Use This Skill

### Triggers (Use this skill when):

* `Instantiate` or `Destroy` is called inside Update, FixedUpdate, or a frequently-called method
* An `Addressables.LoadAssetAsync` handle is loaded without a corresponding Release
* String concatenation or `ToString()` is used inside per-frame code
* UI text is updated every frame using `text.text = "..."` string assignment
* A script uses LateUpdate for physics or FixedUpdate for rendering
* Code review reveals any GC-allocating pattern in a hot path

### Do NOT use this skill for:

* One-time initialization code (Awake/Start) — pooling is not required there
* Non-performance-critical scripts with infrequent execution
* Pure DOTS/ECS code — use dots-ecs for allocator and Burst concerns
* Runtime profiling and measurement — this skill is static analysis only

**Execution Context Details:**
Runs after code-standards on performance-sensitive scripts. Works alongside dots-ecs (DOTS memory) and testing-standards (performance test coverage).

---

## Inputs

**Required inputs:**

* **Source code** — Scripts under review, particularly those with Update loop methods
* **Hot path scripts** — Any class that runs per-frame or at high frequency
* **Asset loading code** — Any Addressables.LoadAssetAsync usage

**Optional inputs:**

* **Project performance targets** — Frame budget per system to calibrate severity

**Documents/Context needed:**

* **Unity Profiler baseline** — Existing frame budget reference to determine if a violation is critical
* **Project performance targets** — Platform-specific budgets (mobile 30fps vs PC 60fps)

---

## Outputs

**Primary outputs:**

* **Performance assessment** — Pass/Fail/Needs Review per performance pattern category
* **Violations list** — Each violation with severity and impact description
* **Optimized patterns** — Before/after code showing the fix
* **Approval status** — Whether script meets performance standards

**Output format:**

* Structured report with sections: Object Pooling, Addressables, String/Text, Update Loop
* Code blocks for each fix

**Skill flags (if applicable):**

* No downstream flags — performance-optimization is a static analysis gate

---

## Preconditions

**Conditions that must be met before execution:**

* code-standards has passed for the script
* Script is intended to run at runtime (not editor-only)

**Validation checks:**

* [ ] Script contains at least one Update/FixedUpdate/LateUpdate method or frequently-called callback
* [ ] Script uses at least one pattern subject to performance review (Instantiate, Addressables, string ops, or TMP_Text)

---

## Step-by-Step Execution Procedure

### Step 1: Audit Object Instantiation and Destruction

**Questions to answer:**
- Is Instantiate or Destroy called inside a per-frame or frequently triggered method?
- Is a pool available for this object type?

**Actions:**
- [ ] Search for `Instantiate(` and `Destroy(` calls
- [ ] Check the calling context — is it Update, a coroutine ticking frequently, or a callback firing many times per second?
- [ ] If yes: flag and provide ObjectPool<T> replacement
- [ ] Verify pool is created in Awake with correct createFunc/actionOnGet/actionOnRelease

**Red flags / Warning signs:**
- `Instantiate` in Update without guard condition
- `Destroy(gameObject)` in a tight loop (e.g., bullet hit handler called 60+ times/second)

**Decision points:**
- If Instantiate in Update: block, provide ObjectPool<T> implementation
- If Instantiate in Start (one-time): pass, pooling not required

---

### Step 2: Audit Addressables Handle Lifecycle

**Questions to answer:**
- Is every `LoadAssetAsync` handle stored and released in OnDestroy?
- Are handles released before the loading object is destroyed?

**Actions:**
- [ ] Find all `Addressables.LoadAssetAsync<T>` calls
- [ ] Confirm each stores the returned `AsyncOperationHandle<T>` as a field
- [ ] Confirm `Addressables.Release(handle)` is called in `OnDestroy`
- [ ] Flag any fire-and-forget load without a stored handle

**Red flags / Warning signs:**
- `await Addressables.LoadAssetAsync<T>(...).Task` with no handle stored
- `OnDestroy()` exists but does not call `Addressables.Release`

**Decision points:**
- If handle not stored: block, require field declaration and Release
- If Release in wrong lifecycle (OnDisable vs OnDestroy): warn

---

### Step 3: Audit String and Text Operations in Hot Paths

**Questions to answer:**
- Is string concatenation (+) or interpolation ($"...") used inside Update or a frequent callback?
- Is TMP_Text.text assigned a new string every frame?

**Actions:**
- [ ] Identify string-building operations in Update/FixedUpdate/LateUpdate or event handlers called frequently
- [ ] Flag `text.text = "Score: " + score` patterns
- [ ] Verify StringBuilder is used with `TMP_Text.SetText(stringBuilder)` for frequent updates
- [ ] Check for `ToString()` calls on value types in hot paths (GC allocation)

**Red flags / Warning signs:**
- `_label.text = $"HP: {_health}"` in Update — allocates a new string every frame
- `_score.text = score.ToString()` — allocates every frame

**Decision points:**
- If string concat in Update: block, provide StringBuilder + SetText replacement
- If ToString() on value type: warn

---

### Step 4: Audit Update Loop Method Assignments

**Questions to answer:**
- Is Update used for physics that should be in FixedUpdate?
- Is LateUpdate used for non-camera/post-frame logic?
- Is FixedUpdate used for rendering or UI concerns?

**Actions:**
- [ ] Review Update methods for physics forces, Rigidbody operations → should be FixedUpdate
- [ ] Review FixedUpdate for UI, camera, or frame-rate-dependent logic → should be Update or LateUpdate
- [ ] Review LateUpdate for anything other than camera follow or post-frame reads

**Red flags / Warning signs:**
- `_rigidbody.AddForce(...)` inside Update
- Camera position set in FixedUpdate (stutters at non-matching frame rates)

**Decision points:**
- If physics in Update: warn, explain frame-rate dependency risk
- If camera in FixedUpdate: warn, suggest LateUpdate

---

### Final Step: Generate Performance Report

```markdown
## Performance Optimization Report

**Target:** [ClassName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Object Pooling
[Finding — Instantiate/Destroy in hot paths]

### Addressables Lifecycle
[Finding — handle storage and Release calls]

### String & Text Operations
[Finding — per-frame allocation patterns]

### Update Loop Hygiene
[Finding — physics/rendering in wrong loop]

### Overall Assessment
- ✅ PASS: No GC-allocating hot paths detected
- ❌ FAIL: Instantiate in Update or unreleased Addressable handle
- ⚠️ NEEDS REVIEW: Update loop placement or minor string allocations

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Detect and block Instantiate/Destroy in per-frame or high-frequency methods
2. Verify every Addressables handle is stored and released in OnDestroy
3. Flag string concatenation and TMP_Text assignment in hot paths
4. Enforce correct Update/FixedUpdate/LateUpdate assignment per operation type
5. Avoid over-engineering — only flag patterns in actual hot paths, not rare callbacks

**Quality criteria:**

* No GC-allocating patterns (Instantiate, string concat) in methods called more than ~10 times per second
* Every Addressable handle has a corresponding Release call
* Physics operations exclusively in FixedUpdate

---

## Constraints (Rules Applied)

### Performance & Complexity Rules

* **PC-1: Analyze Complexity**
  - Applies: Understand allocation frequency — Instantiate once on init is fine; Instantiate in Update every frame is not
  - In practice: Assess call frequency before flagging

* **PC-4: Performance Budget**
  - Applies: Violations are measured against platform budget; mobile 30fps has less tolerance than PC 60fps
  - In practice: On mobile projects, string allocation in Update is a block; on PC it is a strong warn

### Maintenance & Feature Consistency Rules

* **MF-5: Reliability**
  - Applies: Unreleased Addressable handles cause memory leaks that grow over session duration
  - In practice: Release is as mandatory as null safety

### Design & Architecture Rules

* **DA-5: Avoid Overengineering**
  - Applies: Do not require pooling for objects instantiated once at load or rarely; only enforce where frequency warrants it
  - In practice: A settings menu that spawns once does not need a pool

---

## Tradeoff Handling

### Tradeoff 1: Pooling Complexity vs. Object Frequency

**Scenario:** A rarely-fired ability effect uses Instantiate — technically correct to pool but adds complexity.

**Default stance:** Apply DA-5 — pooling is required when frequency warrants it. Define threshold as > ~10 instantiations/second or > ~60/minute in sustained play.

**Resolution process:**
1. Assess actual frequency of the Instantiate call
2. If below threshold: pass with note
3. If above: require pool

---

### Tradeoff 2: Addressables vs. Direct Asset Reference

**Scenario:** Small, always-loaded asset uses Addressables unnecessarily.

**Default stance:** Out of scope — this skill validates handle lifecycle when Addressables is already in use, not whether Addressables is appropriate. Address in architecture-patterns.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Instantiate in High-Frequency Callback

**Trigger:** `Instantiate` found inside a collision callback or OnTriggerEnter that fires continuously.

**Action:**
- Block merge
- Provide full ObjectPool<T> implementation with createFunc, actionOnGet, actionOnRelease
- Estimate frame impact based on expected call frequency

---

### Escalation Scenario 2: Addressable Handle Never Released

**Trigger:** `Addressables.LoadAssetAsync<T>` with no stored handle and no Release call found.

**Action:**
- Block merge
- Request field declaration: `private AsyncOperationHandle<T> _handle;`
- Request Release in OnDestroy

---

### Escalation Scenario 3: Platform Budget Ambiguity

**Trigger:** String allocation in Update on a project targeting both mobile and PC.

**Action:**
- Flag as NEEDS REVIEW
- Request clarification of minimum target platform
- Apply mobile standard if unspecified

---

### When to halt execution:

* Script is editor-only utility code — performance standards do not apply
* Script has no per-frame execution path — nothing to audit

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after code-standards on performance-sensitive scripts. Works alongside dots-ecs for DOTS memory concerns. Cooperates with testing-standards when performance tests should accompany an optimization.

**Integration workflow:**
1. code-standards passes
2. Orchestrator invokes performance-optimization on hot-path or flagged scripts
3. Skill assesses four performance pattern categories
4. Outputs report; blocks on critical violations
5. testing-standards may follow for coverage of optimized code paths

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No flags — this is a static analysis gate | — | — |

---

## Related Skills

**Skills this skill depends on:**

* **code-standards** — Lifecycle correctness (OnDestroy for Release, Awake for pool init) must be validated first

**Skills this skill cooperates with:**

* **dots-ecs** — Cooperates on native memory management; dots-ecs flags performance-optimization for NativeArray leaks
* **testing-standards** — Performance tests should accompany optimizations where benchmarks are required

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block on Instantiate in Update — never accept with warning alone
* [ ] Block on unreleased Addressable handle — memory leak is reliability violation per MF-5
* [ ] Apply DA-5 — do not flag rare, low-frequency Instantiate calls
* [ ] State call frequency estimation before flagging (not just "Instantiate found")
* [ ] Document all approved exceptions via DT-1

**Audit trail requirements:**

* Any approved exception to pooling requirement (e.g., infrequent spawn) must be logged via DT-1 with frequency justification

---

## Example Use Cases

### Example 1: Bullet Instantiate in Update

**Scenario:** `PlayerShoot.cs` calls `Instantiate(_bulletPrefab, ...)` inside `Update()` when fire button held.

**Execution steps:**
1. Detect Instantiate in Update context
2. Assess frequency: could fire 10+ times/second → high frequency
3. Block: provide ObjectPool<Bullet> with Awake init and Get/Release pattern

**Result:** ❌ FAIL

---

### Example 2: Unreleased Addressable in SceneLoader

**Scenario:** `Addressables.LoadAssetAsync<Scene>(_sceneRef)` called but handle not stored; `OnDestroy` present but empty.

**Execution steps:**
1. Find LoadAssetAsync — no stored handle
2. Find OnDestroy — no Release
3. Block: require handle field and Release in OnDestroy

**Result:** ❌ FAIL

---

### Example 3: Score UI Updated Every Frame

**Scenario:** `_scoreLabel.text = $"Score: {_score}"` in Update.

**Execution steps:**
1. Detect string interpolation assignment to TMP_Text.text in Update
2. Flag: allocates a new string every frame
3. Provide StringBuilder + `_scoreLabel.SetText(_sb)` replacement

**Result:** ❌ FAIL

---

### Example 4: One-Time Prefab Spawn in Start

**Scenario:** `Instantiate(_playerPrefab, spawnPoint.position, Quaternion.identity)` in `Start()`.

**Execution steps:**
1. Detect Instantiate — in Start, one-time
2. Apply DA-5: pooling not warranted for one-time spawn
3. Pass with note

**Result:** ✅ PASS

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `Instantiate(_bullet, pos, rot)` inside `Update()`
✅ **Correct approach:** `ObjectPool<Bullet>` with `_pool.Get()` and `_pool.Release(b)` in OnDisable

❌ **Anti-pattern 2:** `Destroy(gameObject)` inside a per-frame collision callback
✅ **Correct approach:** Return to pool via `_pool.Release(this)` instead of Destroy

❌ **Anti-pattern 3:** `await Addressables.LoadAssetAsync<T>(ref).Task` with no handle stored
✅ **Correct approach:** Store `AsyncOperationHandle<T> _handle` and call `Addressables.Release(_handle)` in OnDestroy

❌ **Anti-pattern 4:** `_label.text = "HP: " + _health` in Update
✅ **Correct approach:** `_sb.Clear(); _sb.Append("HP: "); _sb.Append(_health); _label.SetText(_sb);`

❌ **Anti-pattern 5:** `_rigidbody.AddForce(direction)` in Update
✅ **Correct approach:** Physics operations in FixedUpdate only

❌ **Anti-pattern 6:** Camera follow logic in FixedUpdate
✅ **Correct approach:** Camera updates in LateUpdate to follow after physics resolves

❌ **Anti-pattern 7:** `_health.ToString()` called inside Update for display
✅ **Correct approach:** Cache formatted string on value change; use SetText with StringBuilder

❌ **Anti-pattern 8:** Creating a new ObjectPool inside Update or Start per-instance
✅ **Correct approach:** Pool created once in a manager's Awake; objects retrieved via manager

❌ **Anti-pattern 9:** Ignoring the returned AsyncOperationHandle from Addressables.LoadAssetAsync
✅ **Correct approach:** Always store the handle for future Release

---

## Non-Goals

* ❌ Does not profile or measure frame time at runtime — use Unity Profiler directly
* ❌ Does not validate DOTS native collection allocators — use dots-ecs
* ❌ Does not optimize shader or rendering pipelines — use shader-vfx-spec
* ❌ Does not require pooling for objects created once at initialization

---

## Notes for LLM Implementation

1. **Assess call frequency before flagging** — Instantiate in Start is fine; Instantiate in Update is not
2. **Apply DA-5 explicitly** — state the frequency threshold when accepting a rare Instantiate
3. **Always provide the full pool implementation** — createFunc, actionOnGet, actionOnRelease with correct signatures
4. **Addressable Release is a reliability rule** — treat it the same as null safety, not a style suggestion
5. **Platform context matters** — mobile budgets are tighter; if target is unknown, apply mobile standard

**Output format preferences:**
* Code blocks for every before/after fix
* Severity labels: GC-ALLOC / MEMORY-LEAK / LOOP-HYGIENE
* Required actions as checkboxes

---

## Metadata Summary

```yaml
name: performance-optimization
category: Performance
priority: High
depends_on: [code-standards]
flags_skills: []
rules_applied: [PC-1, PC-4, MF-5, DA-5]
documents_needed: [project_performance_targets, unity_profiler_baseline]
tags: [unity, performance, objectpool, addressables, stringbuilder, update-loop]
```

**Key relationships:**
- Depends on: code-standards (lifecycle baseline for Awake/OnDestroy)
- Flags: none — static analysis gate
- Governed by: PC-1 (complexity/frequency), PC-4 (budget), MF-5 (reliability), DA-5 (avoid over-engineering)
