# Skill Human Spec
# File: playtest-diagnostics-docs.md
# Purpose: Human-readable comprehensive documentation
# NEVER loaded into agent context — for human review, authoring, and maintenance only

---

```yaml
---
name: playtest-diagnostics
description: Analyzes Unity playtest logs and profiler data to detect crashes, exceptions, and performance spikes. Diagnostic only.
version: 1.0.0
category: QA & Diagnostics
tags: [unity, diagnostics, logs, profiler, crashes, exceptions, performance, gc, fps]
priority: High

depends_on: [testing-standards, performance-optimization]
flags_skills: [qa-test-generation, performance-optimization]

inputs: [unity-logs, profiler-captures, custom-game-logs, error-reports]
outputs: [issues-list, stack-traces, suspected-causes]

rules_applied:
  - TQ-2   # Failure Diagnosis — root-cause analysis from logs; no code modification
  - MF-4   # Root Cause — identify underlying cause, not just symptoms
  - MF-5   # Reliability — flag recurring or systemic issues as reliability risks
  - PS-2   # Risk Communication — surface crash or stability risks before dismissing them
  - PS-3   # Scope Control — diagnostic only; do not propose patches or fix code

documents_needed: [testing-standards, performance-optimization-guide]

execution_context: Stage 5 / QA & diagnostics. Runs after playtest sessions to analyze produced logs and profiler data. Feeds findings to qa-test-generation for regression coverage and to performance-optimization for performance issues.
---
```

---

# Skill: Playtest Diagnostics

---

## Purpose

**What this skill does:**
Analyzes Unity player logs, editor logs, custom game logs, and Unity Profiler captures to identify crashes, unhandled exceptions, assertion failures, garbage collection spikes, frame-time spikes, and expensive rendering or scripting operations. Produces a structured diagnostic report with issues, stack traces, and hypotheses grounded in the log data.

Playtest sessions generate raw data that engineers need to act on quickly. Fast, structured diagnostic analysis converts noisy log files into actionable issue lists, reducing the time from "something felt wrong" to "here is what happened and why."

Provides a systematic triage of log data that separates genuine issues from noise, correlates stack traces with log context, and surfaces root-cause hypotheses — saving senior engineer time on manual log triage and preventing superficial fixes that miss underlying causes.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A playtest session has completed and logs or profiler data are available for analysis
* A player or QA tester has reported a crash or unexpected behavior
* A build is exhibiting low FPS or stuttering and profiler data has been captured
* Unity console logs show exceptions that occurred during a play session
* GC allocation spikes are suspected based on reported stutter patterns
* A specific frame-time spike needs to be traced to its cause
* A post-build test run has produced editor or player logs for review

### Do NOT use this skill for:

* Fixing code — this skill identifies and describes issues; it does not write or modify code
* Modifying Unity assets or scene configurations in response to findings
* Proposing specific code patches or refactors — use code-oriented engineering skills for that
* Generating new test cases for identified issues — use `qa-test-generation` for regression coverage

**Execution Context Details:**
This skill is diagnostic only. Its output (issues, stack traces, suspected causes) is consumed by engineering skills for fixes and by `qa-test-generation` for regression test design. It never prescribes implementation changes.

---

## Inputs

**Required inputs:**

* **Unity player or editor logs** — The `.log` files produced by a Unity player build or Unity Editor play session. May include `Player.log`, `Editor.log`, or equivalents from target platform consoles.
* **Error reports or crash summaries** — Any crash reporter output, assertion failure messages, or manually captured error context from testers.

**Optional inputs:**

* **Unity Profiler captures** — `.data` or exported profiler frames showing CPU, GPU, memory, and rendering timelines.
* **Custom game logs** — Any in-game debug logging produced by project-specific systems (e.g., `Debug.Log` calls from game systems, analytics events, state machine logs).
* **Frame rate data** — Any captured FPS graphs or frame time recordings (from Unity Stats window or external tools).
* **Reproduction steps** — Tester-provided steps that led to the issue, used to contextualize log timestamps.

**Documents/Context needed:**

* **testing-standards** — Defines what log severity levels and what categories of errors are tracked as bugs vs. expected.
* **performance-optimization-guide** — Provides the project's performance budgets to contextualize whether observed frame times are within acceptable range.

---

## Outputs

**Primary outputs:**

* **Issues list** — A numbered list of distinct problems identified in the log/profiler data, each described in human-readable terms with a severity rating.
* **Stack traces** — Relevant stack traces extracted from logs, or summarized call chains from profiler data, associated with each issue.
* **Suspected causes** — Hypotheses grounded specifically in the log and profiler evidence, not generic guesses. Each hypothesis references the evidence that supports it.

**Output format:**

```json
{
  "issues": [],
  "stack_traces": [],
  "suspected_causes": []
}
```

Supplemented by the structured markdown Diagnostic Report (see Final Step).

**Skill flags (if applicable):**

* Flag **qa-test-generation** when a confirmed or suspected issue should have regression test coverage added.
* Flag **performance-optimization** when a profiler-identified bottleneck requires formal performance budget investigation.

---

## Preconditions

**Conditions that must be met before execution:**

* At least one log file, profiler capture, or error report is available for analysis
* The Unity version and target platform are known (context for interpreting platform-specific log patterns)

**Validation checks:**

* [ ] Is at least one log source available?
* [ ] Can the log source be attributed to a specific build or session (date, version if available)?
* [ ] Is the error severity taxonomy from testing-standards accessible?

---

## Step-by-Step Execution Procedure

### Step 1: Triage Log Sources

**Questions to answer:**
- What log sources are available (player log, editor log, profiler, custom)?
- What is the session context (platform, build version, duration)?
- Are there timestamps that allow sequencing of events?

**Actions:**
- [ ] Identify each log source and its type
- [ ] Note the build version and platform if present in log headers
- [ ] Establish a rough timeline from log timestamps to sequence events

**Red flags / Warning signs:**
- Log file is empty or cut off — may indicate a crash before log flushing; note this explicitly
- Multiple sessions concatenated in one log — segment them before analysis

**Decision points:**
- If no session context is available, note this as an analysis limitation — findings may apply to multiple sessions

---

### Step 2: Identify Crashes and Exceptions

**Questions to answer:**
- Are there any `Fatal Error`, `NullReferenceException`, `IndexOutOfRangeException`, `StackOverflowException`, or `UnityException` entries?
- Are there assertion failures or `Debug.Assert` violations?
- Are there managed-to-native transition exceptions (crash at native layer)?

**Actions:**
- [ ] Extract all entries at `Error` or `Fatal` severity
- [ ] Identify all exception types and their first occurrence timestamps
- [ ] Extract full stack traces for each unique exception
- [ ] Classify: crash (process termination), exception (caught or uncaught), assertion failure

**Red flags / Warning signs:**
- `NullReferenceException` in `Update()` — high probability of per-frame cost impact; high frequency risk
- `StackOverflowException` — indicates unbounded recursion; critical
- Native crash without managed stack trace — requires platform crash reporter; log as out-of-scope for this analysis

**Decision points:**
- If the same exception appears more than 5 times per session, classify as recurring issue with reliability risk (MF-5)

---

### Step 3: Identify Performance Issues

**Questions to answer:**
- Are there frame-time spikes visible in profiler data?
- Are there GC allocation events causing frame stutters?
- Which scripts or rendering operations appear most costly in the profiler?

**Actions:**
- [ ] Identify frames with CPU time above the platform budget (e.g., >33ms for 30fps, >16ms for 60fps)
- [ ] Identify GC.Collect events and the allocation size/source if available
- [ ] Identify the top 3 most expensive function calls in profiler CPU samples
- [ ] Identify rendering bottlenecks (batching cost, overdraw, shader cost) if GPU profiler data is present

**Performance spike reference:**

| Target | Frame Budget | Spike Threshold |
|---|---|---|
| mobile_30fps | 33ms | >50ms |
| console_60fps | 16ms | >25ms |
| pc_60fps | 16ms | >25ms |
| vr_90fps | 11ms | >16ms |

**Red flags / Warning signs:**
- GC alloc in a hot path (Update loop, FixedUpdate, rendering callbacks) — fix urgency: high
- A single function consuming >50% of frame time — critical bottleneck
- Continuous GC pressure (small allocations every frame) without a clear source

**Decision points:**
- If profiler data is unavailable but FPS logs or stutter reports are provided, note this as an analysis with limited precision — hypotheses only

---

### Step 4: Correlate and Cluster Issues

**Questions to answer:**
- Do multiple log entries relate to the same root cause?
- Are exceptions clustering around a specific system, scene, or time window?
- Are performance spikes correlated with specific game events (scene loads, spawning, audio triggers)?

**Actions:**
- [ ] Group related exceptions by type and call site
- [ ] Identify if performance spikes correlate with specific game events visible in the log
- [ ] Determine if a crash has a preceding chain of warnings or exceptions that indicate the cause

**Red flags / Warning signs:**
- Multiple different exception types from the same call site — the site itself is likely the root issue
- Performance spikes that occur at regular intervals — suggest Update-loop allocations or coroutine timing issues

**Decision points:**
- Merge issues that share a root cause into a single issue entry; note that they appeared as multiple symptoms

---

### Step 5: Form Suspected Causes

**Questions to answer:**
- What is the most likely cause of each identified issue, based on the log evidence?
- Is the cause definitely confirmed by the evidence, or is it a hypothesis?
- What additional information would confirm or rule out the hypothesis?

**Actions:**
- [ ] For each issue, write a suspected cause grounded in specific log evidence (cite log lines, stack frames)
- [ ] Label each suspected cause with confidence: CONFIRMED / PROBABLE / POSSIBLE
- [ ] Note what would be needed to elevate a POSSIBLE to CONFIRMED
- [ ] Do not propose fixes — describe the cause only

**Red flags / Warning signs:**
- Suspected cause that cannot be tied to specific log evidence — label as SPECULATIVE and note what log data is needed

**Decision points:**
- If a suspected cause requires code inspection to confirm, note this explicitly — do not block the report

---

### Final Step: Generate Diagnostic Report

**Report/Output structure:**

```markdown
## Playtest Diagnostic Report

**Session:** [Build version / date / platform if known]
**Date Analyzed:** [YYYY-MM-DD]
**Log Sources:** [List of log files / profiler captures analyzed]
**Status:** COMPLETE / PARTIAL (data limitations noted)

### Issue Summary
| # | Severity | Category | Description |
|---|----------|----------|-------------|
| 1 | Critical | Crash | NullReferenceException in PlayerController.Update() |
| 2 | High | Performance | GC spike in EnemySpawnManager.SpawnWave() — 45ms frame |

### Issue Details

**Issue 1: [Title]**
- Severity: Critical / High / Medium / Low
- Category: Crash / Exception / Performance / GC / Rendering
- Description: [Human-readable description of what happened]
- First occurrence: [Timestamp or log line reference]
- Frequency: [Once / N times / Recurring]

**Stack Trace:**
```
[Extracted stack trace or summarized call chain]
```

**Suspected Cause (CONFIRMED / PROBABLE / POSSIBLE):**
[Evidence-grounded hypothesis. Cite specific log lines or profiler measurements.]

**To Confirm:** [What additional data or inspection would confirm this cause]

---

### Performance Summary (if profiler data available)
- Peak frame time: [Xms on [timestamp or event]]
- GC events: [N events, largest: Xms]
- Top 3 expensive calls: [Function, cost]

### Skills Flagged
- qa-test-generation: [Issue numbers that need regression coverage]
- performance-optimization: [Issue numbers requiring formal budget review]
```

---

## Core Responsibilities

1. Analyze Unity player/editor logs and profiler data systematically — do not cherry-pick only visible errors
2. Identify all crashes, unhandled exceptions, assertion failures, GC spikes, and frame-time spikes present in the data
3. Extract and associate stack traces with each identified issue
4. Form suspected causes grounded in specific log and profiler evidence — never generic guesses
5. Classify issue severity consistently (Critical for crashes, High for recurring exceptions or significant performance spikes)
6. Flag `qa-test-generation` for confirmed issues needing regression coverage (TQ-3)
7. Flag `performance-optimization` for profiler-identified bottlenecks requiring formal budget review
8. Remain strictly diagnostic — never propose code patches or asset changes

**Quality criteria:**

* Every issue entry has a severity, category, description, and at least one piece of log evidence
* Every suspected cause cites specific evidence from the provided data
* No fixes or code modifications are proposed in the output
* Recurring issues are explicitly marked as reliability risks (MF-5)

---

## Constraints (Rules Applied)

### Testing & Quality Rules

* **TQ-2: Failure Diagnosis**
  - How this rule applies: Analysis must focus on identifying root causes from evidence, not just listing symptoms. An exception without a suspected cause is incomplete.
  - In practice: Every issue must have a suspected cause section, even if labeled POSSIBLE.

### Maintainability & Feature Rules

* **MF-4: Root Cause**
  - How this rule applies: Do not stop at the surface symptom. If a NullReferenceException is the symptom, identify what was null and why, based on the stack trace and log context.
  - In practice: "NullReferenceException at line 47" is a symptom. "PlayerController.currentWeapon was null because the weapon prefab was not assigned in the Inspector, confirmed by missing reference warning at session start" is a root cause.

* **MF-5: Reliability**
  - How this rule applies: Recurring issues (same exception type, same call site, appearing in multiple sessions or many times in one session) are classified as reliability risks, not isolated bugs.
  - In practice: Flag any exception appearing more than 5 times in a session as a reliability risk.

### Product & Stakeholder Rules

* **PS-2: Risk Communication**
  - How this rule applies: Crashes and stability-threatening issues must be surfaced prominently in the report, not buried in a flat issue list.
  - In practice: Critical-severity issues appear first in the Issue Summary. Crash issues are highlighted as blocking if they affect core game paths.

* **PS-3: Scope Control**
  - How this rule applies: This skill is diagnostic only. No code fixes, no asset modifications, no patch proposals.
  - In practice: If asked "how do I fix this?", redirect to engineering skills. Describe the cause, not the remedy.

---

## Tradeoff Handling

### Tradeoff 1: Thoroughness vs Speed

```
CONFLICT: Complete analysis of all log entries takes time; engineering team may need a fast triage.
DEFAULT: Prioritize Critical and High severity issues first; complete lower severity analysis after.
RESOLUTION:
  IF urgency_stated → deliver Critical/High findings immediately; log remaining as pending
  IF no_urgency → complete full analysis before delivering
→ Log decision via: DT-1 if partial report is delivered
```

### Tradeoff 2: Confirmed vs Speculative Causes

```
CONFLICT: Labeling a cause CONFIRMED may lead to incorrect fix prioritization if the evidence is circumstantial.
DEFAULT: Label causes conservatively. CONFIRMED requires direct evidence; PROBABLE requires strong correlation; POSSIBLE requires weak correlation.
RESOLUTION:
  IF evidence_is_direct (stack trace pins the call site and data) → CONFIRMED
  IF evidence_is_correlational (spike coincides with event) → PROBABLE
  IF evidence_is_circumstantial (pattern suggests but doesn't confirm) → POSSIBLE
→ Never elevate confidence without evidence.
```

### Tradeoff 3: Issue Clustering vs Granularity

```
CONFLICT: Clustering multiple related exceptions under one root cause may hide important detail; over-splitting inflates the issue list.
DEFAULT: Cluster when the same call site produces the same exception type; split when different systems are involved.
RESOLUTION:
  IF same_type AND same_call_site → merge into one issue; note occurrence count
  IF same_type AND different_call_sites → separate issues; note the pattern across systems
→ Log decision via: DT-1 if clustering decision is non-obvious.
```

---

## Failure & Escalation Behavior

### Scenario 1: Log File Is Empty or Truncated

**Trigger:** The provided log file is empty, extremely short, or appears cut off at the start.

**Action:**
- Note that the log may have been truncated due to a crash before log flushing
- Document this as a data limitation
- Request the crash reporter output or device-level crash dump if available
- Proceed with whatever data is available; mark report as PARTIAL

**Escalation:** No hard block; deliver partial findings with data limitation noted prominently.

---

### Scenario 2: Native Crash Without Managed Stack Trace

**Trigger:** Log contains a crash at the native layer with no C# managed stack trace.

**Action:**
- Note that native crashes require platform crash reporter tools (e.g., Crashlytics, Windows Error Reporting, console-specific tools) to resolve
- Log the crash occurrence as Critical severity
- Note the crash address if present
- Describe what was happening in the managed layer immediately before the crash, based on surrounding log entries

**Escalation:** Flag as outside managed-layer diagnostic scope; recommend platform crash reporter integration.

---

### Scenario 3: No Log Data Provided

**Trigger:** No log files, profiler captures, or error reports are provided as input.

**Action:**
- Halt analysis — cannot produce meaningful diagnostics without data
- Request the specific log files needed (player log path, profiler capture)
- Provide guidance on where to find Unity player logs on the relevant platform

**Escalation:** Hard block — cannot proceed without data.

---

### Scenario 4: Fix Request Embedded in Analysis Request

**Trigger:** User asks for the diagnostic analysis AND for the issues to be fixed.

**Action:**
- Complete the diagnostic analysis and deliver the report
- Note clearly that fix implementation is outside this skill's scope
- Flag the relevant engineering skill for fix implementation

**Escalation:** Deliver diagnostic output; redirect fix request without blocking the diagnostic.

---

### Scenario 5: Performance Issue With No Profiler Data

**Trigger:** Performance problems are reported but only FPS logs or tester descriptions are available, not profiler captures.

**Action:**
- Analyze available data; note that hypotheses are less precise without profiler frame data
- Label all performance suspected causes as POSSIBLE rather than CONFIRMED or PROBABLE
- Recommend capturing a profiler session to confirm hypotheses

**Escalation:** Deliver POSSIBLE-labeled findings; recommend profiler capture for confirmation.

---

### When to halt execution:

* No log data is available and none can be requested
* The log data is in a proprietary platform format that cannot be parsed without a platform-specific tool

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
This skill is the post-playtest analysis layer. It converts raw session data into structured diagnostic findings that feed downstream skills for regression test design and performance investigation.

### How This Skill Integrates

1. Playtest session produces logs and/or profiler data
2. **playtest-diagnostics** (this skill) analyzes that data into structured issues
3. **qa-test-generation** (downstream) uses the issue list to design regression test cases
4. **performance-optimization** (downstream) receives performance findings for formal investigation
5. Engineering skills receive suspected causes as input for fix implementation

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Confirmed or suspected issue needs regression coverage | qa-test-generation | Regression test design required to prevent recurrence |
| Profiler-identified bottleneck requires budget analysis | performance-optimization | Formal performance budget investigation required |

---

## Related Skills

**Skills this skill depends on:**
- **testing-standards** — defines log severity taxonomy and what constitutes a tracked bug vs. expected behavior
- **performance-optimization** — provides platform performance budgets for contextualizing profiler findings

**Skills this skill cooperates with:**
- **qa-test-generation** — receives issue list as input for regression test case design
- **performance-optimization** — receives performance findings for formal investigation

**Skills this skill may invoke/flag:**
- **qa-test-generation** — flagged for confirmed issues requiring regression coverage
- **performance-optimization** — flagged for performance bottlenecks requiring formal budget analysis

---

## Governance Hooks

* [ ] Never propose code fixes or asset modifications — diagnostic output only (PS-3)
* [ ] Surface crash-severity issues prominently in every report (PS-2)
* [ ] Ground every suspected cause in specific log evidence; label confidence level (TQ-2, MF-4)
* [ ] Flag recurring issues as reliability risks per MF-5
* [ ] Flag qa-test-generation for confirmed issues needing regression coverage

**Audit trail requirements:**

* Every issue entry includes severity, category, and log evidence
* Every suspected cause is labeled with confidence level and evidence citation
* Partial reports are explicitly marked with data limitations

---

## Example Use Cases

### Example 1: Crash on Scene Load

**Scenario:** QA reports the game crashes when loading Level 3. A player log from the session is available.

**Inputs provided:**
- `Player.log` from a Windows standalone build
- Tester note: "Crashed every time when clicking Play on Level 3 screen"

**Execution steps:**
1. Triage: player log, Windows, one session
2. Exception scan: `NullReferenceException` at `EnemySpawner.Awake()` followed by `Fatal Error` 0.2s later
3. Stack trace: `EnemySpawner.Awake() → EnemySpawner.InitializePool() → NullReferenceException`
4. Correlate: preceding log shows warning `[EnemySpawner] SpawnPrefab is not assigned`
5. Suspected cause: CONFIRMED — `SpawnPrefab` serialized field is unassigned in Level 3 scene; `InitializePool()` calls `Instantiate(SpawnPrefab)` without null check; crashes on Awake

**Result:** COMPLETE — 1 Critical issue with CONFIRMED suspected cause

**Skills flagged:** qa-test-generation (regression test for Level 3 load with unassigned prefab field)

---

### Example 2: Frame Rate Stutter Every 10 Seconds

**Scenario:** Players report a recurring stutter in combat. Profiler capture available.

**Inputs provided:**
- Profiler capture: 30 seconds of combat gameplay
- FPS log showing drops from 60fps to 18fps every ~10 seconds

**Execution steps:**
1. Triage: profiler capture + FPS log
2. Performance scan: frames at 10s intervals show GC.Collect taking 42ms; GC triggered by EnemyPool allocating `new List<Enemy>()` in `SpawnWave()`
3. Top expensive call: `GC.Collect` 42ms; `EnemyPool.SpawnWave` 8ms baseline
4. Correlation: stutter timing matches wave spawn interval (configured at 10s in inspector)
5. Suspected cause: CONFIRMED — `SpawnWave()` allocates a new `List<Enemy>` every call; GC pressure builds over ~10s and triggers collection synchronously

**Result:** COMPLETE — 1 High performance issue (GC alloc in hot path)

**Skills flagged:** performance-optimization (GC pressure from per-wave allocation pattern), qa-test-generation (regression test for frame time during wave spawning)

---

### Example 3: Multiple Exceptions, Unknown Root

**Scenario:** Post-playtest log review shows 15 different exception types from last night's session.

**Inputs provided:**
- `Editor.log` from a 2-hour play session with multiple testers

**Execution steps:**
1. Triage: editor log, 2-hour session, multiple testers
2. Exception scan: 15 exception types; cluster by call site — 12 of 15 originate from `UIEventRouter`
3. Identify pattern: `UIEventRouter.DispatchEvent()` throws `InvalidOperationException` when `_eventQueue` is modified during enumeration
4. Suspected cause: PROBABLE — concurrent modification of `_eventQueue` during enumeration in `DispatchEvent`; exact thread context unclear without profiler but enumeration pattern is consistent
5. Remaining 3 exceptions: unrelated; separate issue entries for each
6. Reliability risk: `UIEventRouter` exceptions appear 47 times in session — reliability risk (MF-5)

**Result:** COMPLETE — 4 issues identified; 1 flagged as reliability risk

**Skills flagged:** qa-test-generation (regression coverage for UIEventRouter under concurrent event load)

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Proposing or implying a code fix in the diagnostic output
✅ **Correct approach:** Describe the cause; do not prescribe the remedy. Fix implementation belongs to engineering skills.

❌ **Anti-pattern 2:** Listing exception messages without extracting stack traces
✅ **Correct approach:** Every exception issue must include the associated stack trace or summarized call chain.

❌ **Anti-pattern 3:** Labeling a suspected cause as CONFIRMED without direct log evidence
✅ **Correct approach:** CONFIRMED requires direct evidence (stack trace pins the exact call site and data state). Without it, label as PROBABLE or POSSIBLE.

❌ **Anti-pattern 4:** Treating every log warning as a bug
✅ **Correct approach:** Classify by severity. Warnings are noted but only elevated to issues if they precede errors or are part of an issue chain. Consult testing-standards for the project's severity taxonomy.

❌ **Anti-pattern 5:** Delivering a report without grouping related exceptions by root cause
✅ **Correct approach:** Cluster exceptions that share a call site and type; identify the systemic issue rather than listing 15 separately.

❌ **Anti-pattern 6:** Ignoring GC events in profiler data
✅ **Correct approach:** GC events are a primary performance concern in Unity. Always scan profiler data for GC.Collect events and identify the allocation source.

❌ **Anti-pattern 7:** Reporting performance spikes without comparing to the project's platform budget
✅ **Correct approach:** Frame times are only meaningful relative to the target frame budget. Always contextualize spike severity against the applicable performance target.

❌ **Anti-pattern 8:** Delivering a partial report without clearly marking it as partial
✅ **Correct approach:** If data is incomplete (truncated log, missing profiler), mark the report as PARTIAL and describe the limitation explicitly.

❌ **Anti-pattern 9:** Failing to flag qa-test-generation for confirmed issues
✅ **Correct approach:** Every confirmed issue that could recur should be flagged for regression test coverage. This is the primary handoff to the QA pipeline.

❌ **Anti-pattern 10:** Offering generic performance advice not grounded in the provided data
✅ **Correct approach:** All suspected causes and notes must reference specific log lines, profiler measurements, or stack frames from the provided data.

---

## Non-Goals

* **Code fixing** — handled by domain-specific engineering skills; this skill is diagnostic only
* **Asset modification** — out of scope; diagnostics inform asset changes but do not implement them
* **Regression test case design** — handled by `qa-test-generation`; this skill provides the issue input
* **Formal performance budget analysis** — handled by `performance-optimization`; this skill identifies and flags the issue

---

## Notes for LLM Implementation

1. **Evidence first**: Never write a suspected cause without a specific log line, stack trace, or profiler measurement backing it. Generic guesses are not hypotheses.
2. **Cluster before listing**: Group exceptions by call site before enumerating. Fifteen exceptions from one bad function are one issue, not fifteen.
3. **No fixes**: The moment output shifts from "what happened and why" to "here's how to fix it," scope has drifted. Redirect to engineering skills.
4. **Confidence labeling is mandatory**: Every suspected cause must carry CONFIRMED, PROBABLE, or POSSIBLE. Unlabeled causes suggest false certainty.
5. **Reliability threshold**: Any exception appearing more than 5 times in a session is automatically a reliability risk (MF-5), regardless of individual severity.

**Output format:**
- Always produce both the JSON output (`issues`, `stack_traces`, `suspected_causes`) and the markdown Diagnostic Report
- Issue Summary table appears first; detailed entries follow
- Skills flagged section appears at the end of the report

**Tone and approach:**
- Analytical and evidence-grounded: cite log data, not intuition
- Conservative on confidence: label accurately; do not overclaim
- Focused: diagnosis only; no implementation guidance

---

## Metadata Summary

```yaml
name: playtest-diagnostics
category: QA & Diagnostics
priority: High
depends_on: [testing-standards, performance-optimization]
flags_skills: [qa-test-generation, performance-optimization]
rules_applied: [TQ-2, MF-4, MF-5, PS-2, PS-3]
documents_needed: [testing-standards, performance-optimization-guide]
tags: [unity, diagnostics, logs, profiler, crashes, exceptions, performance, gc, fps]
```

**Key relationships:**
- Depends on: testing-standards (severity taxonomy), performance-optimization (budget context)
- Flags: qa-test-generation (regression coverage), performance-optimization (formal performance review)
- Governed by: TQ-2 (evidence-based diagnosis), MF-4 (root cause), MF-5 (reliability risks), PS-2 (risk prominence), PS-3 (no fixes)

---

*End of Skill Human Spec — playtest-diagnostics-docs.md*
