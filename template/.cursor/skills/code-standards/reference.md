# Skill Human Spec: C# Code Standards

```yaml
---
name: code-standards
description: Enforces C# naming conventions, MonoBehaviour lifecycle ordering, serialization attributes, and XML documentation standards
version: 1.0.0
category: Design Governance
tags: [csharp, monobehaviour, unity, naming, serialization, lifecycle]
priority: High

depends_on: []
flags_skills: []

inputs: [source_code, monobehaviour_scripts, inspector_field_declarations]
outputs: [standards_assessment, violations_list, corrected_examples, approval_status]

rules_applied:
  - DA-1   # SOLID & Clean Code First
  - DA-7   # Architectural Consistency
  - MF-1   # Feature Consistency

documents_needed: [project_coding_standards, existing_monobehaviour_examples]

execution_context: Always active; evaluates every new or modified C# script against Unity coding standards before any other skill runs
---
```

---

# Skill: C# Code Standards

---

## Purpose

**What this skill does:**
Enforces Unity-specific C# conventions: MonoBehaviour lifecycle method ordering, serialization attribute usage ([Header], [Tooltip], [Range]), private field naming with _camelCase prefix, null-safe component retrieval via TryGetComponent, and XML documentation on all public API. Ensures every script is consistent, inspector-friendly, and readable.

Reduces onboarding time by guaranteeing predictable script structure, prevents inspector-related bugs from misconfigured or ungrouped fields, and makes code reviews faster through consistent shape across the codebase.

Lifecycle ordering violations cause silent runtime null references. Missing null checks on GetComponent cause NullReferenceExceptions in production. XML docs surface intent without requiring source dives. This skill prevents all three classes of issue at authoring time.

---

## When to Use This Skill

### Triggers (Use this skill when):

* Any new MonoBehaviour or NetworkBehaviour script is created
* An existing script gains new serialized fields, properties, or lifecycle methods
* Inspector fields are added or reorganised
* Public classes or methods are created without XML documentation
* Code review reveals naming or ordering inconsistencies
* A script uses `GetComponent` without checking the result
* A private field lacks the `_camelCase` naming convention

### Do NOT use this skill for:

* Pure C# classes with no Unity lifecycle (no MonoBehaviour — use clean-code-solid domain skill instead)
* Configuration or data files (ScriptableObjects with only data and no logic)
* Auto-generated code or IDE scaffolding
* Performance-critical paths where MonoBehaviour lifecycle is intentionally restructured with documented justification

**Execution Context Details:**
This is the foundational gate — it runs first, before architecture-patterns, networking, dots-ecs, or any other skill. All downstream skills assume code-standards compliance as a baseline.

---

## Inputs

**Required inputs:**

* **Source code** — The full C# script body under review
* **MonoBehaviour scripts** — Any class inheriting from MonoBehaviour, NetworkBehaviour, or similar
* **Inspector field declarations** — Serialized fields, their attributes, and their placement in the class

**Optional inputs:**

* **Project coding standards doc** — Project-specific conventions that extend or override defaults

**Documents/Context needed:**

* **Existing MonoBehaviour examples** — Reference implementations in the codebase to validate alignment with project norms per DA-7

---

## Outputs

**Primary outputs:**

* **Standards assessment** — Pass/Fail/Needs Review with per-category findings
* **Violations list** — Each violation with class/line context, severity (Safety/Style), and corrected form
* **Corrected examples** — Before/after code snippets for each violation
* **Approval status** — Whether the script is ready for the next skill gate

**Output format:**

* Structured report with checklist sections per standard category
* Severity labels: SAFETY (blocks merge), STYLE (warns only)
* Code blocks for every correction

**Skill flags (if applicable):**

* This skill has no downstream flags — it is a prerequisite gate only

---

## Preconditions

**Conditions that must be met before execution:**

* Script is syntactically valid C# (compiles without syntax errors)
* Script is the intended final form for review (not a work-in-progress stub)
* Class inherits from MonoBehaviour or a Unity base class with lifecycle methods

**Validation checks:**

* [ ] File compiles without syntax errors
* [ ] Class body is complete (no TODO stubs in lifecycle methods that would affect ordering assessment)
* [ ] All referenced types are resolvable in the project

---

## Step-by-Step Execution Procedure

### Step 1: Validate Lifecycle Method Order

**Questions to answer:**
- Are all lifecycle methods present and in the canonical declared order?
- Are any lifecycle methods interspersed with business logic methods?

**Actions:**
- [ ] Identify all Unity lifecycle methods in the class
- [ ] Verify declared order: Serialized Fields → Private Fields → Properties → Awake/OnEnable/Start → Update/FixedUpdate/LateUpdate → OnDisable/OnDestroy
- [ ] Flag any method appearing out of canonical sequence

**Red flags / Warning signs:**
- `Start` declared before `Awake`
- `OnDisable` or `OnDestroy` appearing before Update methods
- Lifecycle methods mixed non-contiguously with helper methods

**Decision points:**
- If out of order: SAFETY warn, request reorder with correct sequence shown in report
- If one lifecycle method is missing entirely: pass — absence is not a violation

---

### Step 2: Validate Serialization Attributes

**Questions to answer:**
- Do inspector-visible fields use [Header] for grouping, [Tooltip] for documentation, and [Range] for numeric constraints?
- Are private fields using [SerializeField] instead of being declared public?

**Actions:**
- [ ] Check all serialized fields — groups of 3+ related fields warrant a [Header]
- [ ] Check all numeric (float/int) fields for [Range(min, max)]
- [ ] Check all fields for [Tooltip("...")]
- [ ] Flag public fields on MonoBehaviours where [SerializeField] private is appropriate

**Red flags / Warning signs:**
- Block of 5+ serialized fields with no [Header] grouping
- `public float speed;` on a MonoBehaviour (exposes unnecessary API surface)
- Float with arbitrary value range and no [Range] constraint

**Decision points:**
- Public field without intent: STYLE warn, suggest [SerializeField] private
- Missing [Range] on numeric: STYLE warn

---

### Step 3: Validate Component Retrieval

**Questions to answer:**
- Does the script use GetComponent? Is the result null-checked?
- Is TryGetComponent used in preference to GetComponent where component absence is possible?

**Actions:**
- [ ] Identify all GetComponent / GetComponentInChildren / GetComponentInParent calls
- [ ] Verify each result is checked for null or replaced with TryGetComponent
- [ ] Flag unchecked direct usage: `_rb = GetComponent<Rigidbody>(); _rb.AddForce(...)` without null check

**Red flags / Warning signs:**
- `GetComponent<T>()` result used immediately without null check
- Missing error log when expected component is absent

**Decision points:**
- If unchecked: SAFETY warn, provide TryGetComponent replacement with Debug.LogError

---

### Step 4: Validate Naming Conventions

**Questions to answer:**
- Do private fields follow the `_camelCase` prefix convention?
- Do public methods and properties follow `PascalCase`?
- Are magic numbers extracted to named constants or [Range]-constrained fields?

**Actions:**
- [ ] Scan all private field declarations for `_` prefix and camelCase body
- [ ] Scan public members for PascalCase
- [ ] Identify inline numeric literals in methods that should be named constants or inspector fields

**Red flags / Warning signs:**
- `private float speed;` — missing `_` prefix
- `private float Speed;` — PascalCase on private field
- `if (distance > 0.5f)` — magic number with no named reference

**Decision points:**
- Naming violation: STYLE warn with corrected name shown
- Magic number in logic: STYLE warn, request [SerializeField] private field or named constant

---

### Step 5: Validate XML Documentation

**Questions to answer:**
- Do all public classes have `<summary>` XML docs?
- Do all public methods with parameters have `<param>` tags?
- Do non-void public methods have `<returns>` tags?

**Actions:**
- [ ] Check all public class declarations for `/// <summary>` block
- [ ] Check all public methods with parameters for matching `<param name="...">` tags
- [ ] Check all non-void public methods for `<returns>` tag

**Red flags / Warning signs:**
- Public class with no XML documentation at all
- Public method with 3 parameters and no `<param>` tags

**Decision points:**
- Missing XML on public API: STYLE warn, provide template XML doc block

---

### Step 6: Validate Modern C# Usage

**Questions to answer:**
- Are verbose null checks replaceable with pattern matching (`is not null`, `is T x`)?
- Is string concatenation replaceable with interpolation (`$"..."`)?
- Are simple single-expression getters/setters expression-bodied?

**Actions:**
- [ ] Flag legacy null checks: `if (x != null)` → `if (x is not null)`
- [ ] Flag concatenation: `"Name: " + name` → `$"Name: {name}"`
- [ ] Flag verbose getters: `get { return _value; }` → `=> _value`

**Decision points:**
- Modern C# suggestion: STYLE suggestion only — never block; team may prefer legacy form if documented

---

### Final Step: Generate Standards Report

```markdown
## Code Standards Report

**Target:** [ClassName.cs]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Lifecycle Order
[Finding — correct order or reorder instruction]

### Serialization Attributes
[Finding — field-by-field attribute coverage]

### Component Retrieval
[Finding — TryGetComponent suggestions if needed]

### Naming Conventions
[Finding — violations with corrected names]

### XML Documentation
[Finding — template blocks where missing]

### Modern C# Usage
[Suggestions — style only, non-blocking]

### Overall Assessment
- ✅ PASS: No SAFETY violations
- ❌ FAIL: Lifecycle order wrong or unchecked GetComponent in active path
- ⚠️ NEEDS REVIEW: STYLE improvements pending

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Enforce MonoBehaviour lifecycle method ordering as the foundational Unity structural rule
2. Validate serialization attribute completeness for inspector-safe, grouped fields
3. Enforce null-safe component retrieval patterns (TryGetComponent with error log)
4. Validate naming conventions across private fields, public members, and constants
5. Require XML documentation on all public API surface

**Quality criteria:**

* No lifecycle ordering violations in any reviewed script
* All serialized numeric fields have [Range] or documented justification for omission
* Zero unchecked GetComponent calls in Awake/Start/Update
* All public classes and non-trivial public methods have XML docs

---

## Constraints (Rules Applied)

### Design & Architecture Rules

* **DA-1: SOLID & Clean Code First**
  - How it applies: Naming and ordering rules enforce single-purpose, readable classes
  - In practice: A class named `PlayerController` should have clear, intention-revealing field names that reflect its responsibility

* **DA-7: Architectural Consistency**
  - How it applies: All scripts in the project must follow the same conventions — `_camelCase` private fields cannot coexist with `camelCase` private fields
  - In practice: If the codebase uses [Header] grouping, every new script must do the same

### Maintenance & Feature Consistency Rules

* **MF-1: Feature Consistency**
  - How it applies: New scripts must not introduce naming or structural patterns that diverge from the existing codebase
  - In practice: Introduce no new conventions without team agreement

---

## Tradeoff Handling

### Tradeoff 1: Standards Strictness vs. Delivery Speed

**Scenario:** Developer pushes a script under deadline with minor naming violations.

**Default stance:** Block only SAFETY violations (lifecycle order, unchecked GetComponent). Warn on STYLE violations (naming, missing [Tooltip]), log as technical debt if accepted.

**Resolution process:**
1. Classify each violation as SAFETY or STYLE
2. Block SAFETY — these cause runtime errors
3. Log STYLE violations via MF-2 if accepted under pressure
4. Set a remediation ticket before next sprint

---

### Tradeoff 2: Modern C# vs. Team Familiarity

**Scenario:** Team is unfamiliar with expression-bodied members or `is not null` pattern matching.

**Default stance:** Suggest, never block. Modern idioms improve readability only if the team knows them. Document the team's preference.

**Resolution process:**
1. Flag the opportunity with a comment
2. Provide the modern equivalent
3. Accept the legacy form if team preference is documented

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Lifecycle Order Causes Runtime Null Reference

**Trigger:** Awake references a component initialised in Start of another script in a dependency chain.

**Action:**
- Flag as SAFETY
- Request explicit initialization order documentation
- Recommend lazy init (null-check on use) or [DefaultExecutionOrder] attribute

---

### Escalation Scenario 2: Project-Wide Naming Convention Conflict

**Trigger:** Existing codebase uses mixed conventions — some files `_camelCase`, some plain `camelCase`.

**Action:**
- Surface inconsistency to team per DA-7
- Request a single convention decision before enforcement
- Log decision via DT-1; do not flag either convention until decided

---

### Escalation Scenario 3: No Project Coding Standards Document Exists

**Trigger:** No reference standards document found; conventions must be inferred from codebase.

**Action:**
- Infer from the majority pattern in existing scripts
- Flag that inferred standards are being applied
- Recommend creation of a formal coding standards document

---

### When to halt execution:

* Script does not compile — cannot assess standards on broken code
* No clear project convention exists and patterns are 50/50 split — request a decision before flagging

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
The foundational gate. Runs on any script creation or modification before all other skills. architecture-patterns, networking, dots-ecs, and testing-standards all assume code-standards compliance.

**Integration workflow:**
1. Orchestrator invokes code-standards on any script creation or modification
2. Skill assesses six categories (lifecycle, attributes, retrieval, naming, XML docs, modern C#)
3. SAFETY violations block; STYLE violations warn
4. After PASS: orchestrator invokes domain-specific skill (architecture-patterns, networking, etc.)

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| No downstream flags — prerequisite gate only | — | — |

---

### Flag Format in Report

```markdown
### Skills Flagged for Follow-up
(none — code-standards is a prerequisite gate)
```

---

## Related Skills

**Skills this skill depends on:**

* None — code-standards is the root dependency for all other unity-engineer skills

**Skills this skill cooperates with:**

* **architecture-patterns** — Assumes code-standards has validated lifecycle and naming before assessing architectural patterns
* **networking** — Relies on lifecycle correctness (OnNetworkSpawn ordering) already validated
* **testing-standards** — Assumes clean MonoBehaviour structure before assessing test placement

**Skills this skill may invoke/flag:**

* None — prerequisite gate only

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Always classify violations as SAFETY or STYLE before reporting
* [ ] Always provide corrected form alongside each violation — never flag without fix
* [ ] Log STYLE violations accepted under delivery pressure via MF-2
* [ ] Do not enforce modern C# as a block — suggestions only
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Any accepted STYLE violations logged as technical debt via MF-2
* Project-wide convention decisions logged via DT-1

---

## Example Use Cases

### Example 1: New PlayerController with Lifecycle Violation

**Scenario:** `PlayerController.cs` has `Start()` declared before `Awake()`, no [Header] on 6 inspector fields, `GetComponent<Rigidbody>()` result used without null check.

**Inputs provided:** Full class body

**Execution steps:**
1. Lifecycle check: Start (line 8) before Awake (line 15) → SAFETY FAIL
2. Attribute check: 6 floats, no [Header] → STYLE WARN
3. Component retrieval: `GetComponent<Rigidbody>()` unchecked → SAFETY WARN
4. Naming: all `_camelCase` → PASS
5. XML docs: public class missing `<summary>` → STYLE WARN

**Result:** ❌ FAIL — lifecycle reorder required before merge

**Output produced:** Report with SAFETY: reorder Awake before Start; SAFETY: TryGetComponent replacement provided; STYLE: [Header] grouping suggestion.

---

### Example 2: Fully Compliant EnemyAI Script

**Scenario:** `EnemyAI.cs` follows all conventions: correct order, [Header]/[Tooltip]/[Range] on all fields, TryGetComponent, `_camelCase` fields, XML docs on all public methods.

**Result:** ✅ PASS — no violations found

---

### Example 3: Magic Numbers in Movement Logic

**Scenario:** `MovementController.cs` contains `if (speed > 0.1f)` and `transform.Rotate(0, 180f, 0)` inline.

**Execution steps:**
1. Lifecycle: PASS
2. Naming: PASS
3. Magic number audit: `0.1f` → suggest `_movementThreshold` [SerializeField]; `180f` → suggest named constant `TurnAngle = 180f`

**Result:** ⚠️ NEEDS REVIEW — STYLE warnings for magic number extraction

---

### Example 4: Mixed Convention Project

**Scenario:** Half the project uses `_camelCase`, half uses plain `camelCase` for private fields.

**Execution steps:**
1. Detect inconsistency across project files
2. Surface conflict per DA-7
3. Halt enforcement until convention decided
4. Log in report as escalation

**Result:** ⚠️ ESCALATION — convention decision required before assessment

---

### Example 5: Modern C# Suggestion Applied

**Scenario:** Script uses `if (component != null)` and `"HP: " + health` concatenation.

**Execution steps:**
1. Detect legacy null check → suggest `if (component is not null)`
2. Detect string concat → suggest `$"HP: {health}"`
3. Both are STYLE suggestions only — not blocks

**Result:** ✅ PASS with suggestions

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `public float speed;` on a MonoBehaviour
✅ **Correct approach:** `[SerializeField] private float _speed;`

❌ **Anti-pattern 2:** `GetComponent<Rigidbody>()` used directly without null check
✅ **Correct approach:** `if (!TryGetComponent(out Rigidbody _rb)) { Debug.LogError("Missing Rigidbody", this); }`

❌ **Anti-pattern 3:** `Start()` declared before `Awake()`
✅ **Correct approach:** Awake always precedes Start in the class body

❌ **Anti-pattern 4:** Inline magic number `0.5f` in a method body
✅ **Correct approach:** `[Range(0f, 1f)] [SerializeField] private float _damping = 0.5f;`

❌ **Anti-pattern 5:** No [Header] on a block of 5+ serialized fields
✅ **Correct approach:** `[Header("Movement Settings")]` above the field group

❌ **Anti-pattern 6:** `"Player HP: " + hp + "/" + max` in display logic
✅ **Correct approach:** `$"Player HP: {hp}/{max}"`

❌ **Anti-pattern 7:** Public method with parameters, no XML `<param>` tags
✅ **Correct approach:** Full `/// <summary>` + `/// <param name="x">description</param>` block

❌ **Anti-pattern 8:** `private float speed;` — missing underscore prefix
✅ **Correct approach:** `private float _speed;`

❌ **Anti-pattern 9:** `get { return _value; }` as a full property body
✅ **Correct approach:** `public float Value => _value;`

❌ **Anti-pattern 10:** `OnDisable` declared before `Update` in the class body
✅ **Correct approach:** Update/FixedUpdate/LateUpdate before OnDisable/OnDestroy

---

## Non-Goals

* ❌ Does not enforce SOLID or design patterns — that is clean-code-solid (senior-software-engineer domain)
* ❌ Does not assess test coverage — that is testing-standards
* ❌ Does not evaluate performance patterns — that is performance-optimization
* ❌ Does not validate Unity-version-specific API deprecations
* ❌ Does not assess architectural decisions — that is architecture-patterns

---

## Notes for LLM Implementation

1. **Lifecycle ordering is the most critical check** — wrong order causes silent runtime null references that are hard to debug
2. **Classify before reporting** — every violation must be labelled SAFETY or STYLE; only SAFETY blocks
3. **Always show the corrected form** — never just flag; always provide the fix inline
4. **Do not force modern C# idioms** — they are suggestions; accept legacy form if team prefers it
5. **If project conventions are ambiguous**, surface the conflict and halt — do not pick one arbitrarily

**Output format preferences:**
* Structured sections per standard category
* Severity labels on every finding (SAFETY / STYLE)
* Code blocks for every correction
* Checklist of required actions at end of report

**Tone and approach:**
* Be precise — name the exact class/field/line if known
* Be constructive — always provide the correct form
* Be conservative — when in doubt whether something is a convention violation, warn rather than block

---

## Metadata Summary

```yaml
name: code-standards
category: Design Governance
priority: High
depends_on: []
flags_skills: []
rules_applied: [DA-1, DA-7, MF-1]
documents_needed: [project_coding_standards, existing_monobehaviour_examples]
tags: [csharp, monobehaviour, unity, naming, serialization, lifecycle]
```

**Key relationships:**
- Depends on: nothing — foundational root skill
- Flags: nothing — prerequisite gate for all other unity-engineer skills
- Governed by: DA-1 (clean code), DA-7 (consistency), MF-1 (feature consistency)
