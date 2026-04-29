---
name: complexity_analyzer
description: Analyzes algorithmic and structural complexity to identify optimization candidates and inform performance decisions before changes are made
version: 1.0
category: Engineering
tags: [performance, complexity, analysis, optimization, big-o]
priority: Medium
depends_on: []
flags_skills: [performance-optimization, correctness-validation]
inputs: [code to analyze, performance context, profiling data if available]
outputs: [complexity classification, bottleneck identification, ranked optimization candidates]
rules_applied: [PC-1, PC-2, DA-5, GM-2]
execution_context: Triggered by performance-optimization when deeper complexity analysis is needed; feeds structured findings back to performance-optimization for action
---

# complexity-analyzer

## 1. Purpose

complexity-analyzer performs systematic algorithmic and structural complexity analysis. It answers: where is the bottleneck, how bad is it, and what should be optimized first? It provides structured, evidence-based input to `performance-optimization`, which then acts on the findings.

This skill enforces the principle that optimization must be measurement-driven, not intuition-driven. It prevents premature optimization and ensures effort targets the actual bottleneck. It does not apply changes — that is `performance-optimization`'s responsibility.

## 2. When to Use This Skill

**Triggers (flagged from):**
- `performance-optimization` — when general optimization approaches are exhausted and deeper structural analysis is needed

**Do NOT use for:**
- Applying optimizations (use `performance-optimization`)
- Correctness validation of optimized code (use `correctness-validation`)
- Profiling tool setup or configuration (external tooling, out of scope)
- Architectural performance redesign (surface the finding; escalation handles the decision)

**Execution context:** Analysis-only. Feeds structured findings to `performance-optimization`. Does not apply changes itself.

## 3. Inputs

**Required:**
- Code to analyze (specific paths, modules, or functions — bounded scope)
- Performance context: what is slow, under what conditions, at what scale

**Optional (but strongly preferred):**
- Profiling data or benchmark results (actual measurements)
- Performance requirements or budget (latency target, throughput target, SLA)

**Documents needed:**
- Profiling output or benchmark results if available
- Performance requirements or SLA definitions

## 4. Outputs

**Primary outputs:**
- Complexity classification: time and space complexity (Big-O) for each identified path in scope
- Bottleneck identification: which paths are actual hotspots, grounded in profiling data
- Ranked optimization candidates: ordered by impact, with estimated effort and correctness risk noted

**Skill flags triggered:**
- `performance-optimization` — with structured analysis findings as input
- `correctness-validation` — when a candidate optimization risks output correctness

## 5. Preconditions

- Code to analyze is available and its scope is bounded
- A performance problem exists — profiling data or a reproducible symptom
- Code is functionally correct — do not analyze code whose correctness is unknown

**Validation checks before execution:**
- No profiling data and no reproducible symptom → request measurement before proceeding
- Code correctness unknown → defer to `correctness-validation` first

## 6. Step-by-Step Execution Procedure

### Step 1 — Establish the performance context

- Identify what is slow, under what conditions, and at what scale
- Confirm that profiling data or a reproducible performance symptom exists
- If neither exists: request measurement — do not proceed on theory alone

**Red flags:** Optimization requested with no specific symptom; "make it faster" with no measurement

### Step 2 — Bound the analysis scope

- Determine which code paths are in scope based on profiling hotspots or the symptom location
- Limit scope to the hot path — do not analyze the full codebase
- State the analysis scope explicitly before proceeding

### Step 3 — Analyze time and space complexity

- For each in-scope path, determine Big-O time complexity (worst case and average case where they differ significantly)
- Determine space complexity where memory is a concern
- Identify hidden costs: repeated allocations, unnecessary copies, lock contention, I/O inside loops, N+1 query patterns

### Step 4 — Identify the bottleneck

- Cross-reference complexity analysis with profiling data
- Distinguish theoretical complexity from empirical hotspots — they may differ due to constants, cache effects, or I/O
- Identify the single most impactful bottleneck before listing secondary candidates

**Red flags:** Bottleneck is I/O or network, not algorithmic (optimization approach will differ); N is too small for Big-O class to matter; complexity hidden by abstraction layers

### Step 5 — Rank optimization candidates

- List candidates ordered by: measured or estimated impact, feasibility, risk to correctness
- For each candidate: state current complexity, target complexity, estimated improvement, and correctness risk
- Any candidate that modifies algorithmic behavior in a way that could affect output → flag `correctness-validation`

### Step 6 — Hand off to performance-optimization

- Present structured findings: bottleneck location, complexity classification, ranked candidates with risk notes
- Explain reasoning per GM-2 before recommendations are acted on
- Do not apply changes — hand off findings to `performance-optimization`

## 7. Core Responsibilities

- Require profiling data or a reproducible symptom before proceeding — reject theoretical analysis without evidence per PC-1
- Bound scope to identified hot paths — do not analyze broadly
- Classify time and space complexity (Big-O) for each in-scope path
- Identify empirical bottleneck by cross-referencing complexity with profiling data
- Rank optimization candidates by impact, feasibility, and correctness risk
- Flag `correctness-validation` for any candidate that risks output correctness per PC-1
- Explain findings before they are acted on per GM-2

**Quality criteria:**
- Every analysis is grounded in profiling data or a reproducible symptom
- Bottleneck identification is evidence-based, not assumed
- Candidates are ranked, not presented as a flat unordered list

## 8. Constraints (Rules Applied)

* **PC-1: Correctness Over Performance** — Analysis must not lead to correctness-breaking optimizations; flag `correctness-validation` if a candidate risks correctness; no recommendation made without noting correctness risk.
* **PC-2: Performance Budget** — Analysis framed against the performance requirement; an optimization achieving the budget is sufficient — further optimization is not warranted.
* **DA-5: Complexity Management** — Optimization candidates must not increase structural complexity beyond what the performance gain justifies; algorithmic improvement preferred over structural complexity.
* **GM-2: Explain Before Acting** — Findings explained with clear reasoning before being handed to `performance-optimization`; the user must understand the bottleneck before it is acted on.

## 9. Tradeoff Handling

**Tradeoff 1: Theoretical analysis vs. empirical measurement**
- Scenario: No profiling data available, but a bottleneck appears obvious from code inspection
- Default stance: Request measurement — do not proceed on theory alone per PC-1
- Resolution: If measurement is genuinely unavailable, document the assumption explicitly, note lower confidence, and proceed with stated uncertainty

**Tradeoff 2: Algorithmic improvement vs. increased structural complexity**
- Scenario: A better algorithm is significantly more complex to implement and maintain
- Default stance: Prefer the simpler implementation unless the performance budget demands otherwise per DA-5
- Resolution: Document the tradeoff; require explicit decision before choosing the complex path

**Tradeoff 3: Local optimization vs. architectural bottleneck**
- Scenario: Analysis reveals the bottleneck requires architectural change, not local optimization
- Default stance: Surface the finding; do not recommend local workarounds that mask an architectural problem
- Resolution: Hand finding to `performance-optimization` with architectural context; let it escalate as appropriate

## 10. Failure & Escalation Behavior

**No profiling data, no reproducible symptom**
- Trigger: Optimization requested without evidence of where the problem is
- Action: Block analysis → request measurement → do not proceed theoretically
- Format: "No profiling data or reproducible symptom available. Cannot determine actual bottleneck. Please provide: [specific measurement request]."

**Optimization candidate risks correctness**
- Trigger: A candidate changes algorithmic behavior in a way that could affect output correctness
- Action: Flag `correctness-validation` → exclude candidate from ranked list until correctness confirmed
- Format: "Candidate [name] risks correctness: [specific concern]. Delegating to correctness-validation before including in recommendations."

**Bottleneck is architectural, not local**
- Trigger: Analysis reveals the performance problem cannot be addressed through local optimization
- Action: Document finding → hand to `performance-optimization` → do not recommend local workarounds
- Format: "Bottleneck identified as architectural: [description]. Local optimization will not achieve the performance budget. Escalating."

## 11. Skill Integration & Orchestration

**Upstream (skills that flag this skill):**
- `performance-optimization` — when general optimization is exhausted and deeper structural analysis is needed

**Downstream (this skill flags):**
- `performance-optimization` — with structured analysis findings as input
- `correctness-validation` — when a candidate optimization risks output correctness

## 12. Related Skills

- `performance-optimization` — applies the changes; this skill provides the analysis that informs them
- `correctness-validation` — escalation target when an optimization candidate risks correctness
- `clean-code-solid` — structural complexity concerns may surface as clean-code issues as well

## 13. Governance Hooks

**Mandatory behaviors:**
- Every analysis must be grounded in profiling data or a reproducible symptom
- Correctness risk must be explicitly noted for any candidate that modifies algorithmic behavior
- Findings must be explained before being handed to `performance-optimization` per GM-2

**Audit trail:**
- Document: analysis scope, profiling data used, Big-O classifications, ranked candidates, correctness risks flagged

## 14. Example Use Cases

**Example 1: Linear scan in a hot path**
`performance-optimization` flags `complexity-analyzer` after profiling shows 80% of request time in a search function called 10,000 times per request. Analysis: O(n) linear scan. Candidate: replace with hash lookup → O(1). No correctness risk. Findings handed to `performance-optimization`.

**Example 2: N+1 query pattern**
Analysis of a report generation module reveals a database query inside a nested loop. Theoretical: O(n²) queries. Confirmed by profiling. Candidate: batch query outside loop → O(n). No correctness risk. Findings handed to `performance-optimization`.

**Example 3: Optimization risks correctness**
A sort optimization on a financial calculation module would change output ordering for equal values. `correctness-validation` flagged. Candidate withheld from recommendations until correctness confirmed.

**Example 4: No profiling data**
Performance optimization requested on "the whole API." No profiling data, no specific symptom. Analysis blocked. Request: "Please provide profiling data or identify the specific operation that is slow."

## 15. Anti-Patterns to Catch

1. **Optimizing without measurement** — assuming where the bottleneck is without profiling evidence.
2. **Micro-optimizing non-bottleneck code** — spending effort on code that is not in the identified hot path.
3. **Theoretical Big-O over empirical data** — Big-O is a model; actual performance depends on N, constants, cache behavior, and I/O.
4. **Recommending complex algorithms for small N** — algorithmic improvement only matters when N is large enough for the class to dominate.
5. **Ignoring correctness risk** — optimizations that change output for edge cases are bugs, not improvements.
6. **Analyzing the entire codebase** — scope must always be bounded to the identified hot path.
7. **Applying changes** — this skill analyzes; `performance-optimization` applies.
8. **Presenting a flat unranked list** — candidates must be ranked by impact to be actionable.

## 16. Non-Goals

- Applying optimizations (use `performance-optimization`)
- Profiling tool setup or execution (external tooling concern)
- Correctness validation of optimized code (use `correctness-validation`)
- Architectural redesign decisions (this skill surfaces the finding; escalation handles the decision)

## 17. Notes for LLM Implementation

- Always ask for profiling data before beginning; if unavailable, state this explicitly and note lower confidence
- State Big-O for both time and space; note worst-case vs. average-case when they differ significantly
- Rank candidates explicitly as a numbered list with impact, effort, and correctness risk for each
- Do not apply changes — present findings in structured form for `performance-optimization` to act on
- Distinguish "this looks slow" (intuition) from "profiling shows this is the bottleneck" (evidence)
