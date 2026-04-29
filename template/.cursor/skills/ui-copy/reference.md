# Skill Human Spec: UI Copy

```yaml
---
name: ui-copy
description: Generates player-facing UI strings as localisation-ready key/string pairs; validates tone, placeholder removal, and copy conventions
version: 1.0.0
category: QA & Diagnostics
tags: [unity, ui-copy, localisation, l10n, tone, placeholder, string-table]
priority: Medium

depends_on: [design-reference, ui-systems]
flags_skills: [scene-component-builder, ui-systems]

inputs: [ui_screen_context, element_list, tone_guide, existing_string_table]
outputs: [copy_assessment, key_string_pairs, violations_list, localisation_notes, approval_status]

rules_applied:
  - PS-1   # Product-First Clarity
  - PS-3   # User Communication Standards
  - DA-6   # Clarity Over Brevity Tradeoff
  - MF-1   # Feature Consistency
  - DT-1   # Decision Logging

documents_needed: [ndd_tone_guide, existing_string_table, ui_screen_spec]

execution_context: Runs after design-reference and ui-systems; generates copy and validates existing strings for tone, localisation readiness, and placeholder removal
---
```

---

# Skill: UI Copy

---

## Purpose

**What this skill does:**
Generates and validates player-facing Unity UI text content as localisation-ready key/string pairs. Enforces tone consistency with the Narrative Design Document (NDD), blocks placeholder text (`[TODO]`, `Lorem ipsum`), validates that button and menu labels are imperative verb-first and concise, ensures dynamic values use placeholder notation (`{player_name}`, `{score}`), and applies project key schema. Flags localisation integration decisions to ui-systems and TMP placement to scene-component-builder.

Hardcoded or placeholder strings block localisation, delay multi-region shipping, and damage product quality at launch. Consistent copy tone strengthens brand identity and player trust. Data-driven string tables allow marketing and localisation to iterate without engineering involvement.

Localisation-ready copy from the start eliminates costly string extraction refactors. Placeholder notation (`{score}`) decouples dynamic data from copywriting. Key schema consistency enables automated localisation pipeline validation and prevents key collision.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new UI screen or element with visible text is being authored
* Placeholder text (`[TODO]`, `Lorem ipsum`, `TBD`) exists in any visible UI element
* Button or label copy is verbose, passive, or violates tone guide
* A new string table key is created — validate naming convention
* Dynamic value tokens in copy strings are undocumented
* Localisation milestone review is requested

### Do NOT use this skill for:

* TextMeshProUGUI vs. legacy Text validation — use ui-systems
* TMP component placement or scene wiring — use scene-component-builder
* Per-frame text allocation — use performance-optimization
* Font, size, or visual text design — design concern

**Execution Context Details:**
Runs after design-reference (NDD consulted) and ui-systems (TextMeshProUGUI confirmed). Copy-only output — no prefab modification, no scene changes.

---

## Inputs

**Required inputs:**

* **UI screen context** — Which screen/panel is being authored; what elements are present

**Optional inputs:**

* **Element list** — List of UI elements requiring copy (buttons, labels, tooltips, errors)
* **Tone guide** — NDD section defining voice, formality, person, and style
* **Existing string table** — Current key/string pairs to check consistency

**Documents/Context needed:**

* **NDD tone guide** — Authoritative source for voice and style; must be consulted per design-reference
* **Existing string table** — Prevents vocabulary divergence and key collision
* **UI screen spec** — Design mockup or description of UI layout and interaction

---

## Outputs

**Primary outputs:**

* **Copy assessment** — Pass/Fail/Needs Review per copy convention category
* **Key/string pairs** — Localisation-ready output: `ui.[screen].[element_type].[name]: "Copy text"`
* **Violations list** — Placeholders, hardcoded strings, tone violations, undocumented tokens
* **Localisation notes** — Idioms, culture-specific strings, character limit constraints
* **Approval status** — Whether UI copy meets standards

**Output format:**

* Structured report with sections: Placeholder Removal, Localisation Readiness, Key Naming, Tone & Voice, Localisation Notes
* Key/string pairs in table format for handoff to localisation team

**Skill flags (if applicable):**

* Flags `scene-component-builder` when TMP placement or wiring is requested
* Flags `ui-systems` when localisation integration decision (string table binding approach) is needed

---

## Preconditions

**Conditions that must be met before execution:**

* design-reference has confirmed NDD tone guide is accessible
* ui-systems has confirmed TextMeshProUGUI components
* UI screen context and element list are provided

**Validation checks:**

* [ ] NDD tone guide consulted or baseline established via DT-1
* [ ] Existing string table key schema identified or default schema documented
* [ ] UI screen context provided — block generation without context per PS-1

---

## Step-by-Step Execution Procedure

### Step 1: Validate Context and Unblock Generation

**Questions to answer:**
- Is sufficient UI context provided to generate accurate copy?

**Actions:**
- [ ] Confirm screen name, element types, and interaction intent are known
- [ ] Confirm tone: casual vs. formal, first/second/third person, brand voice
- [ ] If context absent: BLOCK — request screen and element list before proceeding
- [ ] If tone absent: default to casual; log assumption via DT-1

**Red flags / Warning signs:**
- Request to generate copy with no screen name or element context
- Tone conflict between NDD and request — surface conflict, generate both versions

**Decision points:**
- No context: block, request
- No tone: default casual + DT-1 log
- Tone conflict: surface both options, await direction

---

### Step 2: Detect and Block Placeholder Text

**Questions to answer:**
- Does any visible text contain placeholder, temp, or dummy copy?

**Actions:**
- [ ] Scan all visible text for: `[TODO]`, `PLACEHOLDER`, `Lorem ipsum`, `TBD`, `Test`, `Temp`, `aaa`, empty string on visible label
- [ ] Flag every occurrence — no placeholder may ship
- [ ] Identify and provide production copy for each flagged placeholder

**Red flags / Warning signs:**
- `[TODO: Button Text]` on a primary CTA button
- `Lorem ipsum dolor sit amet` in tutorial panel
- Empty string `""` on a score label

**Decision points:**
- Placeholder found: BLOCK — request or generate production copy before merge

---

### Step 3: Generate or Validate Key/String Pairs

**Questions to answer:**
- Do string table keys follow the project schema? Are dynamic values properly tokenised?

**Actions:**
- [ ] Identify project key schema from existing table (e.g., `ui.[screen].[element_type].[name]`)
- [ ] If no schema exists: apply default `ui.[screen].[element_type].[name]`; log via DT-1
- [ ] Generate keys for all UI elements
- [ ] Apply placeholder notation for all dynamic values: `{player_name}`, `{score}`, `{input}`
- [ ] Document every placeholder token in localisation notes

**Red flags / Warning signs:**
- Key `STRING_001` — non-descriptive, unsearchable
- `"Score: " + score` — hardcoded prefix outside string table
- `{0}` positional token — not self-documenting for localisation team

**Decision points:**
- Non-descriptive key: provide corrected name
- Positional token: replace with named placeholder `{score}` and document
- Schema conflict: match existing schema, log via DT-1

---

### Step 4: Validate Tone and Voice

**Questions to answer:**
- Does all copy match the NDD tone guide and interaction context?

**Actions:**
- [ ] Check button labels: imperative verb-first, ≤3-4 words, Title Case (e.g., `Play`, `Save Game`, `Quit to Menu`)
- [ ] Check error and status messages: Sentence case, action-oriented, non-technical (e.g., `Connection lost. Tap to retry.`)
- [ ] Check tooltips: describe benefit or action, not just function (e.g., `Restore 50 HP` not `This is a health potion`)
- [ ] Check titles and headers: consistent capitalisation per project style
- [ ] Flag passive, verbose, or technical copy

**Red flags / Warning signs:**
- `Click here to continue to the next screen` — passive, verbose
- `NullSocketException` visible to player — technical
- `This button saves your progress` — describes function instead of action

**Decision points:**
- Tone violation: warn, provide corrected copy
- Technical string to player: BLOCK

---

### Step 5: Generate Localisation Notes

**Questions to answer:**
- Are there any strings that require special localisation handling?

**Actions:**
- [ ] Flag idiomatic expressions that may not translate directly
- [ ] Flag strings with strict character limits (UI space constraints)
- [ ] Flag culture-specific references (currency, dates, units)
- [ ] Note strings where word order may change significantly in other languages
- [ ] Document all placeholder tokens and their data types

**Red flags / Warning signs:**
- Idiom: `Hit the ground running` — may not translate
- Button with 80px width expecting ≤10 chars — character limit constraint
- `$100 Gold` — currency symbol and formatting are locale-specific

**Decision points:**
- Idiom: flag in notes, do not remove — localisation team decides
- Character limit: note in output, provide shorter alternative if possible

---

### Final Step: Generate UI Copy Report

```markdown
## UI Copy Report

**Target:** [Screen or Panel Name]
**Date:** [YYYY-MM-DD]
**Status:** ✅ PASS / ❌ FAIL / ⚠️ NEEDS REVIEW

### Placeholder Removal
[Finding — any TODO, lorem ipsum, or empty visible labels]

### Key/String Pairs
| Key | String | Notes |
|-----|--------|-------|
| ui.main_menu.button.play | Play | |
| ui.main_menu.button.settings | Settings | |

### Tone & Voice
[Finding — NDD alignment, verb-first buttons, user-facing errors]

### Localisation Notes
[Idioms, character limits, culture-specific content, placeholder tokens]

### Overall Assessment
- ✅ PASS: All copy conventions met
- ❌ FAIL: Placeholder text or technical string visible to player
- ⚠️ NEEDS REVIEW: Tone violations or hardcoded strings

### Required Actions
- [ ] [Action 1]
```

---

## Core Responsibilities

**Primary responsibilities (in order):**

1. Block all placeholder text — no `[TODO]`, `Lorem ipsum`, or empty visible labels may ship
2. Generate localisation-ready key/string pairs using project key schema
3. Document all dynamic value placeholder tokens (`{score}`, `{player_name}`)
4. Validate tone and voice alignment with NDD — imperative verb-first buttons, user-facing errors
5. Generate localisation notes for idioms, character limits, and culture-specific strings

**Quality criteria:**

* Zero placeholder strings in any visible UI element
* All dynamic values use named placeholder notation, not positional (`{0}`)
* All button labels ≤4 words, imperative verb-first, Title Case

---

## Constraints (Rules Applied)

### Product Rules

* **PS-1: Product-First Clarity**
  - Applies: Copy must communicate clearly to the target player; block generation without context
  - In practice: `Connection lost. Tap to retry.` — not `Error: null socket exception`

* **PS-3: User Communication Standards**
  - Applies: Interactive elements must have descriptive, action-oriented labels
  - In practice: Buttons are verb-first; tooltips describe benefit, not function

### Design & Architecture Rules

* **DA-6: Clarity Over Brevity**
  - Applies: Prefer shorter, clearer copy; do not sacrifice clarity for character count
  - In practice: `Save Game` over `Save` when context is ambiguous

### Maintenance Rules

* **MF-1: Feature Consistency**
  - Applies: New copy must use established vocabulary — never unilaterally rename game terms
  - In practice: If `Health` is established, do not use `HP` in new copy without documented decision

---

## Tradeoff Handling

### Tradeoff 1: Brevity vs. Clarity on Constrained UI

**Scenario:** Button has 60px width; `Save Game` may truncate; `Save` fits but loses context.

**Default stance:** Prefer clarity; flag character limit in localisation notes; provide both versions for design decision. Document choice via DT-1.

---

### Tradeoff 2: Tone Conflict — NDD vs. Request

**Scenario:** NDD specifies formal tone; request asks for casual, friendly copy.

**Default stance:** Surface conflict; generate both formal and casual versions; await stakeholder direction. Log decision via DT-1.

---

## Failure & Escalation Behavior

### Escalation Scenario 1: Placeholder in Gold Build

**Trigger:** `[TODO: Final Score Copy]` found during final QA milestone.

**Action:**
- BLOCK — no placeholder may ship post-alpha
- Escalate to production for copy sourcing
- Do not proceed until production copy provided and reviewed

---

### Escalation Scenario 2: No NDD Tone Guide and No Existing Copy

**Trigger:** New project, first UI screen, no tone reference.

**Action:**
- Establish baseline: verb-first buttons, Title Case labels, Sentence case messages, non-technical errors
- Document via DT-1 as project tone baseline
- Proceed with generation using baseline; flag for stakeholder review

---

### When to halt execution:

* No UI screen context provided — block per PS-1; cannot generate accurate copy without context
* Tone conflict unresolved after two options presented — await stakeholder direction

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
Runs after design-reference (NDD consulted) and ui-systems (TextMeshProUGUI confirmed). Terminal for copy content — flags scene-component-builder for TMP placement, flags ui-systems for localisation integration decisions.

**Integration workflow:**
1. design-reference confirms NDD consulted
2. ui-systems confirms correct text components
3. Orchestrator invokes ui-copy on screen copy requirements
4. Skill generates key/string pairs, validates placeholders, tone, localisation notes
5. If TMP placement requested: flag scene-component-builder
6. If string table binding approach needed: flag ui-systems

---

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| TMP placement or component wiring requested | scene-component-builder | Copy only — no prefab modification |
| Localisation integration approach needed | ui-systems | String table binding is ui-systems concern |

---

## Related Skills

**Skills this skill depends on:**

* **design-reference** — NDD tone guide is authoritative for voice and style
* **ui-systems** — TextMeshProUGUI must be confirmed before copy content is assessed

**Skills this skill cooperates with:**

* **prefab-scene-spec** — Prefab hierarchy confirmed before copy is assigned to elements

**Skills this skill may invoke/flag:**

* **scene-component-builder** — TMP placement or wiring requested
* **ui-systems** — Localisation integration approach decision needed

---

## Governance Hooks

**Mandatory behaviors this skill must follow:**

* [ ] Block generation without UI context — never guess screen or element intent per PS-1
* [ ] Block all placeholder text — `[TODO]` is never acceptable post-prototype
* [ ] Block technical strings visible to players — engineering terms must not reach player screens
* [ ] Consult NDD tone guide per design-reference before generating any copy
* [ ] Document all placeholder tokens in localisation notes before output
* [ ] Log key schema assumption via DT-1 if no schema is established
* [ ] Validate outputs before returning results

**Audit trail requirements:**

* Key schema and tone baseline documented via DT-1 on first use
* Vocabulary decisions (renaming established terms) logged via DT-1

---

## Example Use Cases

### Example 1: Placeholder Button Copy

**Scenario:** Main menu Play button has text `[TODO: Play Button]`.

**Execution steps:**
1. Detect `[TODO` prefix — placeholder
2. Block: request or generate production copy
3. Generate: key `ui.main_menu.button.play`, string `Play`

**Result:** ❌ FAIL (placeholder blocked; production copy generated)

---

### Example 2: Verb-Last Button Label

**Scenario:** Settings save button labelled `Game progress save`.

**Execution steps:**
1. Detect passive, non-imperative phrasing
2. Warn: rewrite as verb-first, ≤4 words
3. Provide: `Save Progress`

**Result:** ⚠️ NEEDS REVIEW

---

### Example 3: Technical Error to Player

**Scenario:** Network disconnect shows `NullReferenceException: SocketManager.OnDisconnect`.

**Execution steps:**
1. Detect technical exception string — player-facing
2. Block: must be replaced with user-facing copy
3. Provide: key `ui.error.network.disconnect`, string `Connection lost. Please check your connection and try again.`

**Result:** ❌ FAIL

---

### Example 4: Undocumented Placeholder Token

**Scenario:** Copy string `"Welcome back, {0}!"` — positional token, not self-documenting.

**Execution steps:**
1. Detect `{0}` positional token — not named
2. Warn: replace with `{player_name}`; document token in localisation notes
3. Provide: `"Welcome back, {player_name}!"` with note: `{player_name} = string, player's display name`

**Result:** ⚠️ NEEDS REVIEW

---

### Example 5: Fully Compliant Copy Submission

**Scenario:** Settings screen — all strings in key/string table format (`ui.settings.button.save: "Save Settings"`), verb-first buttons, Sentence case messages, all dynamic values named and documented, no placeholders, NDD tone confirmed.

**Result:** ✅ PASS

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** `[TODO: Add copy here]` on any visible label
✅ **Correct approach:** Production or approved draft copy; no placeholders post-prototype

❌ **Anti-pattern 2:** `_label.text = "Press to continue"` — hardcoded string
✅ **Correct approach:** String table key: `ui.prompt.button.continue: "Continue"`

❌ **Anti-pattern 3:** `Click here to start the game` — verbose, passive button label
✅ **Correct approach:** `Play` — imperative, ≤4 words, Title Case

❌ **Anti-pattern 4:** `NullReferenceException` displayed to player
✅ **Correct approach:** `Something went wrong. Please restart.` — user-facing, actionable

❌ **Anti-pattern 5:** Key `STRING_042` — non-descriptive
✅ **Correct approach:** `ui.main_menu.button.play` — schema-compliant

❌ **Anti-pattern 6:** `"Score: {0}"` — positional token, opaque to localisation team
✅ **Correct approach:** `"Score: {score}"` — named token, documented in localisation notes

❌ **Anti-pattern 7:** `This button saves your progress` — describes function
✅ **Correct approach:** `Save Progress` — action, not description

---

## Non-Goals

* ❌ Does not validate TextMeshProUGUI vs. legacy Text — use ui-systems
* ❌ Does not place or wire TMP components in scenes — use scene-component-builder
* ❌ Does not translate copy to other languages — localisation team concern
* ❌ Does not design font, size, or visual style of text — design concern

---

## Notes for LLM Implementation

1. **Block without context** — never guess screen or intent; request the UI element list per PS-1
2. **Placeholder block is absolute** — `[TODO]` or `Lorem ipsum` is never acceptable post-prototype; block, do not warn
3. **Technical strings visible to players are a product quality failure** — exception names must never reach player screens
4. **Named placeholder tokens are mandatory** — `{score}` not `{0}`; document every token
5. **Tone requires NDD reference** — establish and log baseline via DT-1 if no NDD exists

---

## Metadata Summary

```yaml
name: ui-copy
category: QA & Diagnostics
priority: Medium
depends_on: [design-reference, ui-systems]
flags_skills: [scene-component-builder, ui-systems]
rules_applied: [PS-1, PS-3, DA-6, MF-1, DT-1]
documents_needed: [ndd_tone_guide, existing_string_table, ui_screen_spec]
tags: [unity, ui-copy, localisation, l10n, tone, placeholder, string-table]
```

**Key relationships:**
- Depends on: design-reference (NDD tone), ui-systems (text component confirmation)
- Flags: scene-component-builder (TMP wiring), ui-systems (localisation integration)
- Governed by: PS-1 (product clarity), PS-3 (user communication), DA-6 (clarity), MF-1 (consistency)

---

```yaml
---
name: ui-copy
description: Generates concise, tone-matched UI strings and localization-ready key/string mappings for Unity game interfaces.
version: 1.0.0
category: QA & Diagnostics
tags: [unity, ui, copy, localization, strings, ux, ugui, tmp, buttons, menus, tooltips, i18n]
priority: Medium

depends_on: [design-reference, ui-systems]
flags_skills: [scene-component-builder, ui-systems]

inputs: [ui-context-description, tone-directive, string-list, localization-key-schema]
outputs: [localization-keys, string-mapping, notes]

rules_applied:
  - PS-1   # Requirement Validation — confirm tone and context before generating strings
  - PS-3   # Scope Control — copy only; no layout design, no prefab modification
  - DA-6   # Pragmatic — concise, useful copy over literary elegance
  - MF-1   # Feature Consistency — strings must be consistent with established game vocabulary
  - DT-1   # Tradeoff Logging — document tone or length tradeoffs when constraints conflict

documents_needed: [design-reference, ui-systems-guide, existing-localization-table]

execution_context: Stage 5 / QA & diagnostics — copy review and localization. Runs after UI layout is defined and before localization tables are populated. Produces key/string pairs for integration into the game's localization workflow.
---
```

---

# Skill: UI Copy

---

## Purpose

**What this skill does:**
Generates player-facing UI text — button labels, menu items, tooltips, error messages, settings labels, tutorial prompts, and notification strings — in a concise, tone-consistent format. Produces output as localization-ready key/string pairs following the project's key naming schema, ready for integration into the game's string table.

Consistent, well-toned UI copy is a player-facing quality signal. Inconsistent or poorly worded strings break immersion, confuse players, and increase support burden. Localization-ready output from the start avoids costly retroactive string refactoring when the game ships to new markets.

Structured key/string output eliminates the copy handoff bottleneck between writers and engineers. Keys following a predictable schema are easy to integrate into Unity localization systems (Unity Localization package, custom string tables) without manual cleanup.

---

## When to Use This Skill

### Triggers (Use this skill when):

* A new UI screen, menu, or feature requires player-facing text
* Existing UI strings need to be rewritten to match a new tone or style guide
* A localization table entry is missing or needs a base-language string
* Button labels, tooltip text, error messages, or tutorial prompts need to be defined for a new feature
* A settings screen needs label copy for all options and their descriptions
* Notification or achievement strings need to be written in the game's established tone
* A new onboarding or tutorial flow needs player-facing instruction text

### Do NOT use this skill for:

* Designing UI layouts, screen flows, or information architecture — use `ui-systems` or `design-reference`
* Modifying Unity UI prefabs, Canvas objects, or TMP components — use `scene-component-builder`
* Writing backend-facing strings (log messages, console debug output, internal error codes) — these are engineering strings, not player-facing copy
* Translating strings to other languages — this skill produces base-language strings; translation is a separate localization workflow step

**Execution Context Details:**
This skill runs after the UI layout is defined and the context for each string is understood. It produces base-language (typically English) strings with localization keys, which are then integrated into the game's string table before translation begins.

---

## Inputs

**Required inputs:**

* **UI context description** — A description of the UI element or screen and what each string is for (e.g., "Main Menu: Play button, Settings button, Quit button, game title display," "Error dialog: connection failed message, retry button label, cancel button label").

**Optional inputs:**

* **Tone directive** — The desired tone for the strings: `casual`, `epic`, `formal`, `humorous`, or a custom description. Defaults to `casual` if not provided.
* **String list** — An enumeration of the specific strings needed (e.g., "Play, Settings, Quit, Continue, Save, Load, Back").
* **Localization key schema** — The project's key naming convention (e.g., `ui.screen.element`, `game.ui.menu.button`). Defaults to `ui.[screen].[element]` if not provided.
* **Existing localization table** — Any existing strings that must be consistent with new copy.

**Documents/Context needed:**

* **design-reference** — Provides the visual and narrative design intent to ensure copy tone aligns with the game's identity.
* **ui-systems-guide** — Provides information about the UI component structure and the localization system in use.
* **existing-localization-table** — Required to maintain consistency with established in-game vocabulary and previously written strings.

---

## Outputs

**Primary outputs:**

* **Localization keys** — An ordered list of localization keys following the project's naming schema.
* **String mapping** — A key-to-string dictionary in the base language (English by default).
* **Notes** — Tone assumptions, length constraints noted, alternative string suggestions for ambiguous cases.

**Output format:**

```json
{
  "keys": [],
  "strings": {}
}
```

Supplemented by the markdown Copy Report (see Final Step).

**Skill flags (if applicable):**

* Flag **scene-component-builder** when generated strings need to be applied to TMP components in a Unity scene that hasn't been built yet.
* Flag **ui-systems** when the key schema implies a localization system integration decision that hasn't been made.

---

## Preconditions

**Conditions that must be met before execution:**

* The UI context is described sufficiently to know what each string is for
* The tone directive is known or can be defaulted to `casual`
* The localization key schema is known or can be defaulted to `ui.[screen].[element]`

**Validation checks:**

* [ ] Is the UI screen or feature context clear enough to determine player intent for each string?
* [ ] Is the tone known or derivable from the game's design-reference?
* [ ] Are there existing strings that new copy must be consistent with?

---

## Step-by-Step Execution Procedure

### Step 1: Establish Context and Tone

**Questions to answer:**
- What is the UI screen or feature these strings belong to?
- What is the player's emotional context when seeing these strings (excited, lost, making a decision)?
- What tone has been requested, and does it align with the game's established voice?

**Actions:**
- [ ] Identify the UI screen and the role of each string within it
- [ ] Confirm or infer the tone directive from the design-reference or task description
- [ ] Check the existing localization table for any established vocabulary that new strings must match
- [ ] Log the tone assumption if it was inferred rather than stated (DT-1)

**Red flags / Warning signs:**
- Tone directive conflicts with existing game vocabulary — note the conflict and request clarification
- Context is ambiguous about whether a string is player-facing or internal — always clarify before writing

**Decision points:**
- If tone is not specified and no design-reference is available, default to `casual` and log the assumption per DT-1

---

### Step 2: Define the Key Schema

**Questions to answer:**
- What is the project's localization key naming convention?
- What screen/section prefix applies to these strings?
- Are there existing keys to follow as a pattern?

**Actions:**
- [ ] Confirm the key schema from the localization guide or existing table
- [ ] Map each string context to a key path: `ui.[screen].[element_type]`
- [ ] For buttons: `ui.[screen].button.[action]` (e.g., `ui.main_menu.button.play`)
- [ ] For labels: `ui.[screen].label.[name]` (e.g., `ui.settings.label.audio_volume`)
- [ ] For errors: `ui.[screen].error.[error_type]` (e.g., `ui.network.error.connection_failed`)
- [ ] For tooltips: `ui.[screen].tooltip.[element]`

**Red flags / Warning signs:**
- Inconsistent key structure in existing table — match the established pattern, even if imperfect, to avoid schema fragmentation
- Key paths that are overly generic (e.g., `ui.button.play`) — add specificity to prevent collision

**Decision points:**
- If no schema is provided, use `ui.[screen].[element_type].[name]` as the default and log the assumption per DT-1

---

### Step 3: Write the Strings

**Questions to answer:**
- Is the string short enough for its UI context (button vs. tooltip vs. notification)?
- Does it match the requested tone?
- Does it avoid embedded formatting, hardcoded values, or culture-specific references?
- Does it use consistent verb forms and capitalization with existing strings?

**Actions:**
- [ ] Write each string to fit its UI context length constraint:
  - Buttons: 1-3 words maximum
  - Menu items: 1-4 words
  - Tooltips: 1-2 sentences, under 100 characters
  - Error messages: 1-2 sentences, action-oriented ("Try again" vs. "Error occurred")
  - Tutorial prompts: 1-3 sentences, second person ("You can…" / "Tap to…")
- [ ] Apply tone consistently across all strings in a batch
- [ ] Use placeholder syntax for dynamic values: `{player_name}`, `{score}` (no hardcoded values)
- [ ] Avoid idiomatic expressions that don't translate well (culture-specific metaphors, puns)
- [ ] Check against existing vocabulary for consistency (MF-1)

**Red flags / Warning signs:**
- Button label is more than 4 words — too long for most button UI elements; shorten
- String contains a hardcoded culture-specific reference (currency symbol, date format) — use placeholders
- Error message says "Error occurred" with no action — always include what the player should do next

**Decision points:**
- If a string requires context the player doesn't have access to, simplify rather than over-explain

---

### Step 4: Review for Localization Safety

**Questions to answer:**
- Are there any strings that will be difficult to translate?
- Are all dynamic values properly wrapped in placeholder notation?
- Are there any strings that embed formatting (bold, color codes) directly in the copy?

**Actions:**
- [ ] Verify no embedded HTML/rich text formatting in copy strings (formatting is a UI concern, not copy)
- [ ] Verify all variable content uses placeholder tokens (`{variable_name}`)
- [ ] Flag strings that contain idioms or culturally specific references for localization review
- [ ] Verify that strings with placeholders have a note documenting what each placeholder represents

**Red flags / Warning signs:**
- Strings with `<b>`, `<color>`, or TMP rich text tags in the copy value — remove; these belong in the UI rendering layer
- Strings that assume a specific date, number, or currency format — always use placeholders

**Decision points:**
- If a string is inherently culture-specific and an alternative exists that is equally clear — prefer the culture-neutral alternative

---

### Step 5: Validate Consistency

**Questions to answer:**
- Are verb forms consistent across all strings? (imperative for buttons, second-person for tutorials)
- Is capitalization consistent? (Title Case for buttons and menus; Sentence case for tooltips and messages)
- Does the tone hold consistently across the full string batch?

**Actions:**
- [ ] Apply Title Case to button labels and menu items
- [ ] Apply Sentence case to messages, tooltips, and tutorial text
- [ ] Check verb form: all buttons should use imperative ("Play", "Save", not "Playing", "Saved")
- [ ] Read all strings aloud in sequence to verify tone consistency

**Red flags / Warning signs:**
- Mix of "Continue" (imperative) and "Continuing..." (progressive) for the same button across screens
- Tooltips using Title Case and messages using Sentence case within the same batch

**Decision points:**
- If the existing table uses a different capitalization convention than the standard, match the existing convention for consistency (MF-1)

---

### Final Step: Generate Copy Report

**Report/Output structure:**

```markdown
## UI Copy Report

**UI Context:** [Screen or feature name]
**Date:** [YYYY-MM-DD]
**Tone:** [casual / epic / formal / custom]
**Key Schema:** [ui.[screen].[element_type].[name]]
**Base Language:** English
**Status:** COMPLETE / PARTIAL

### String Table

| Key | String | Notes |
|-----|--------|-------|
| ui.main_menu.button.play | Play | |
| ui.main_menu.button.settings | Settings | |
| ui.main_menu.button.quit | Quit | |

### JSON Output
```json
{
  "keys": ["ui.main_menu.button.play", ...],
  "strings": {
    "ui.main_menu.button.play": "Play",
    ...
  }
}
```

### Placeholders Used
| Key | Placeholder | Represents |
|-----|-------------|------------|

### Localization Notes
- [Flag any strings requiring special handling during translation]
- [Note idiomatic strings that may need free translation vs. literal]

### Assumptions Logged (DT-1)
- [Tone assumption if not stated]
- [Key schema assumption if not stated]

### Skills Flagged
- scene-component-builder: [Reason if strings need to be applied to scene TMP objects]
- ui-systems: [Reason if localization system integration decision is needed]
```

---

## Core Responsibilities

1. Write player-facing UI strings that are concise, tone-consistent, and contextually appropriate for their UI element type
2. Produce all strings as localization-ready key/string pairs following the project's key naming schema
3. Avoid embedded formatting, hardcoded culture-specific values, and untranslatable idioms
4. Maintain vocabulary consistency with existing game strings (MF-1)
5. Log all tone and schema assumptions when not explicitly provided (DT-1)
6. Flag localization-safety concerns proactively — placeholder gaps, embedded formatting, cultural specificity
7. Remain strictly in the copy domain — no layout design, no prefab modification (PS-3)

**Quality criteria:**

* Every string fits its UI context length constraint
* All keys follow the project's naming schema
* No embedded formatting characters in string values
* All dynamic values use placeholder notation
* Tone is consistent across all strings in a batch

---

## Constraints (Rules Applied)

### Product & Stakeholder Rules

* **PS-1: Requirement Validation**
  - How this rule applies: Confirm UI context and tone before writing strings. Writing in the wrong tone or for the wrong UI element is a wasted output.
  - In practice: If tone is unclear, ask once before generating. If context is clear enough, default with logged assumption.

* **PS-3: Scope Control**
  - How this rule applies: Copy only. Do not design layouts, modify prefabs, or make localization system architecture decisions.
  - In practice: "Place this text in the TMP component on the Play button" is out of scope. Deliver the string; flag `scene-component-builder` for placement.

### Design & Architecture Rules

* **DA-6: Pragmatic**
  - How this rule applies: Concise, clear copy beats poetic but long copy. UI strings are utility text, not literary work.
  - In practice: "Play" beats "Begin Your Adventure". "Settings" beats "Customize Your Experience". Use the shorter, clearer option unless tone explicitly requires otherwise.

### Maintainability & Feature Rules

* **MF-1: Feature Consistency**
  - How this rule applies: New strings must use the same vocabulary, verb forms, and capitalization as existing strings in the same game.
  - In practice: If the game uses "Continue" for returning to play, don't write "Resume" for a new screen that does the same thing.

### Decision & Tradeoff Rules

* **DT-1: Explicit Tradeoff Logging**
  - How this rule applies: Tone assumptions, schema assumptions, and length tradeoffs must be documented.
  - In practice: "Defaulted to 'casual' tone as none was specified; 'epic' tone is an alternative if the design intent is more dramatic."

---

## Tradeoff Handling

### Tradeoff 1: Conciseness vs Clarity

```
CONFLICT: Shorter strings fit UI better but may be unclear to new players; longer strings explain but overflow UI elements.
DEFAULT: Prefer conciseness; use tooltips for additional context rather than extending button/menu labels.
RESOLUTION:
  IF button_label → max 3 words; clarity via tooltip if needed
  IF tooltip → can extend to 2 sentences; clarity prioritized over brevity
  IF notification → 1 sentence; action-oriented
→ Log decision via: DT-1 if length was constrained below natural clarity threshold
```

### Tradeoff 2: Tone vs Localization Safety

```
CONFLICT: Epic or casual tone often uses idioms that don't translate well; safe copy is tone-neutral.
DEFAULT: Prefer tone with localization flags over tone-neutral copy that breaks immersion.
RESOLUTION:
  IF idiom_is_central_to_tone AND alternative_exists → write both; recommend the safer option
  IF idiom_has_no_equivalent → flag for localization team; note free-translation intent
  IF tone_is_formal → fewer idioms; localization risk is lower
→ Log decision via: DT-1
```

### Tradeoff 3: Vocabulary Consistency vs Better Copy

```
CONFLICT: An established term in the game's vocabulary is suboptimal, but changing it risks inconsistency.
DEFAULT: Maintain consistency with established vocabulary; flag the improvement for a future style guide update.
RESOLUTION:
  IF established_term_is_clearly_confusing → surface the issue; propose the alternative; await confirmation before changing
  IF established_term_is_merely_suboptimal → match it; note the improvement suggestion in notes
→ Never unilaterally change established vocabulary without flagging it.
```

### Tradeoff 4: Tone Request vs Game Voice

```
CONFLICT: Requested tone (e.g., "humorous") conflicts with the established game voice from design-reference.
DEFAULT: Surface the conflict; do not silently write in a tone that contradicts the established voice.
RESOLUTION:
  IF tone_requested AND conflicts_with_design_reference → surface the conflict; generate both; await direction
  IF no_design_reference → use requested tone; log that design-reference was not available
→ Log decision via: DT-1
```

---

## Failure & Escalation Behavior

### Scenario 1: No UI Context Provided

**Trigger:** Request for UI copy with no description of what strings are needed or what screen they belong to.

**Action:**
- Request the UI screen name and a list of elements that need strings
- Cannot generate useful copy without context
- Hard block on generation until context is provided

**Escalation:** Hard block — cannot produce strings without knowing what they're for.

---

### Scenario 2: Tone Conflict with Established Voice

**Trigger:** The requested tone (e.g., "humorous") is inconsistent with the game's established voice from `design-reference`.

**Action:**
- Surface the conflict explicitly
- Generate one version in the requested tone and one in the established voice
- Await direction before delivering a single version

**Escalation:** Soft block — deliver both versions; request direction.

---

### Scenario 3: Schema Conflict with Existing Table

**Trigger:** The key schema implied by the request conflicts with the key naming used in the existing localization table.

**Action:**
- Match the existing schema for consistency (MF-1)
- Note the deviation from the requested schema and the reason (consistency with existing table)
- Log the assumption per DT-1

**Escalation:** No hard block; apply consistent schema; document the decision.

---

### Scenario 4: Prefab or Scene Placement Request

**Trigger:** User asks to place the generated strings into TMP components in a Unity scene or prefab.

**Action:**
- Deliver the string/key output
- Flag `scene-component-builder` for placement of strings into scene TMP components
- Note that TMP component wiring is outside this skill's scope

**Escalation:** Redirect without blocking; deliver copy output.

---

### When to halt execution:

* UI context is completely undefined and cannot be clarified
* Requested strings contain profanity or content that violates platform content guidelines — flag and request revision

---

## Skill Integration & Orchestration

**This skill's role in the pipeline:**
This skill sits at the intersection of design and engineering in the UI pipeline. It runs after UI structure is defined and produces the copy that gets integrated into the localization workflow and wired into TMP components by `scene-component-builder`.

### How This Skill Integrates

1. **design-reference** and **ui-systems** (upstream) define the UI context and game voice
2. **ui-copy** (this skill) generates the localization-ready string table
3. **scene-component-builder** (downstream/flagged) receives flags to apply strings to TMP components
4. **ui-systems** (downstream/flagged) receives flags for localization system integration decisions

### Skills That May Be Flagged

| Scenario Detected | Flag This Skill | Reason |
|---|---|---|
| Strings need to be wired into TMP components in a scene | scene-component-builder | TMP placement is a scene-building task, not copy |
| Localization system integration requires architectural decision | ui-systems | Key schema integration into Unity Localization or custom system requires system design |

---

## Related Skills

**Skills this skill depends on:**
- **design-reference** — provides the game's narrative voice and visual identity to calibrate copy tone
- **ui-systems** — provides context about the localization system in use and key schema conventions

**Skills this skill cooperates with:**
- **scene-component-builder** — receives copy output to apply strings to TMP components in scenes
- **prefab-scene-spec** — may define UI component contexts that drive copy requirements

**Skills this skill may invoke/flag:**
- **scene-component-builder** — flagged when generated strings need to be applied to scene TMP objects
- **ui-systems** — flagged when the key schema implies a localization system integration decision

---

## Governance Hooks

* [ ] Confirm tone and UI context before writing strings (PS-1)
* [ ] Use placeholder notation for all dynamic values — no hardcoded values (PS-3 localization safety)
* [ ] No embedded rich text formatting in string values (PS-3)
* [ ] Maintain vocabulary consistency with existing game strings (MF-1)
* [ ] Log all tone and schema assumptions (DT-1)

**Audit trail requirements:**

* Tone directive documented in every output (stated or defaulted with DT-1 log)
* Key schema documented in every output
* Localization flags noted for any strings with translation risk

---

## Example Use Cases

### Example 1: Main Menu Strings

**Scenario:** Generate copy for a fantasy RPG Main Menu with Play, Settings, Credits, and Quit buttons. Tone: epic.

**Inputs provided:**
- Screen: Main Menu
- Elements: Play, Settings, Credits, Quit buttons; game title display
- Tone: epic
- Key schema: `ui.[screen].[element]`

**Execution steps:**
1. Context: main menu; player is at the start of their session, primed for adventure; epic tone = dramatic, short
2. Key schema: `ui.main_menu.[element]`
3. Strings: Play → "Embark" (epic, imperative), Settings → "Settings" (functional, consistent), Credits → "Chronicles" (epic flavor), Quit → "Depart", Title → game's actual title (no copy needed)
4. Localization check: "Embark" and "Chronicles" may need free translation in some languages; flag for localization team
5. Consistency check: all buttons are imperative single words; consistent capitalization ✅

**Result:** COMPLETE — 4 button strings in epic tone; 2 flagged for localization review

**Skills flagged:** None

---

### Example 2: Error Messages for Network Disconnect

**Scenario:** Write copy for network disconnection error dialog. Tone: casual. Elements: error title, error body, retry button, cancel button.

**Inputs provided:**
- Screen: network_error_dialog
- Elements: title, body_message, retry_button, cancel_button
- Tone: casual

**Execution steps:**
1. Context: player lost connection; frustrated, needs clear action; casual tone = friendly, not alarming
2. Keys: `ui.network_error.label.title`, `ui.network_error.label.body`, `ui.network_error.button.retry`, `ui.network_error.button.cancel`
3. Strings: title → "Connection Lost", body → "Looks like you've lost connection. Check your internet and try again.", retry → "Try Again", cancel → "Back to Menu"
4. Localization check: "Looks like" is casual English idiom; flag for free translation; no hardcoded values; no formatting ✅
5. Consistency: imperative buttons ✅; Sentence case for body ✅; Title Case for title and buttons ✅

**Result:** COMPLETE — 4 strings; 1 idiom flagged for localization

**Skills flagged:** None

---

### Example 3: Settings Screen Labels

**Scenario:** Settings screen for an action game. Elements: Audio Volume slider label, Music toggle, SFX toggle, Graphics Quality dropdown, Back button. Tone: formal.

**Inputs provided:**
- Screen: settings
- Elements: audio_volume, music_toggle, sfx_toggle, graphics_quality, back_button
- Tone: formal

**Execution steps:**
1. Context: settings screen; player making configuration decisions; formal = clear, no flair
2. Keys: `ui.settings.label.audio_volume`, `ui.settings.label.music`, `ui.settings.label.sfx`, `ui.settings.label.graphics_quality`, `ui.settings.button.back`
3. Strings: "Audio Volume", "Music", "Sound Effects", "Graphics Quality", "Back"
4. Note: "SFX" expanded to "Sound Effects" per formal tone — abbreviations are informal; log as preference
5. Localization check: all strings are industry-standard UI terms; no localization risk ✅

**Result:** COMPLETE — 5 strings; SFX expansion noted as tone-driven decision

**Skills flagged:** None

---

### Example 4: Tutorial Prompts

**Scenario:** First-time player tutorial. Prompts for: movement, attacking, and opening inventory. Tone: casual.

**Inputs provided:**
- Screen: tutorial_overlay
- Elements: move_prompt, attack_prompt, inventory_prompt
- Tone: casual

**Execution steps:**
1. Context: new player learning controls; casual + encouraging + second-person
2. Keys: `ui.tutorial.prompt.move`, `ui.tutorial.prompt.attack`, `ui.tutorial.prompt.inventory`
3. Strings: move → "Use {move_input} to move around. Explore your surroundings!", attack → "Press {attack_input} to strike. Hit enemies to defeat them!", inventory → "Open your bag with {inventory_input} to check your items."
4. Placeholders: `{move_input}`, `{attack_input}`, `{inventory_input}` — represent platform-specific input labels (keyboard key or gamepad button); document each placeholder
5. Localization check: second-person casual English; "bag" for inventory is casual and may not translate directly — flag for localization team

**Result:** COMPLETE — 3 strings with 3 placeholders documented; 1 vocabulary flag for localization

**Skills flagged:** None

---

## Anti-Patterns to Catch

❌ **Anti-pattern 1:** Writing button labels longer than 3-4 words
✅ **Correct approach:** Button labels are short, imperative, and immediately readable. "Begin Your Adventure Now" → "Play". Add context via tooltip if needed.

❌ **Anti-pattern 2:** Embedding TMP rich text tags (`<b>`, `<color>`) in string values
✅ **Correct approach:** String values are plain text only. Formatting is applied at the UI rendering layer, not in the copy strings. Rich text in string tables breaks localization workflows.

❌ **Anti-pattern 3:** Using hardcoded currency symbols, date formats, or number formats
✅ **Correct approach:** All culture-specific values must use placeholder notation: `{currency}`, `{price}`, `{date}`. Let the localization system handle formatting per locale.

❌ **Anti-pattern 4:** Writing error messages that only describe the error without telling the player what to do
✅ **Correct approach:** Every error message must include an action: "Connection failed. Try again or return to the main menu." Players need direction, not just a diagnosis.

❌ **Anti-pattern 5:** Using inconsistent vocabulary for the same game concept across different screens
✅ **Correct approach:** If the existing table uses "Continue" for returning to play, all new strings must also use "Continue" — not "Resume", "Return", or "Keep Playing". (MF-1)

❌ **Anti-pattern 6:** Writing copy in a tone that conflicts with the established game voice without flagging it
✅ **Correct approach:** If a tone is requested that conflicts with the design-reference voice, surface the conflict and generate both versions. Never silently write in an incompatible tone.

❌ **Anti-pattern 7:** Generating localization keys with inconsistent naming structure
✅ **Correct approach:** All keys within a batch must follow the same schema. `ui.settings.label.audio_volume` and `settings_music` in the same output is a schema collision waiting to happen.

❌ **Anti-pattern 8:** Using idioms or culturally specific expressions without flagging them
✅ **Correct approach:** Casual or epic tone often involves idioms. Always flag them in the localization notes section so the translation team knows to use free translation rather than literal translation.

❌ **Anti-pattern 9:** Including strings that are not player-facing (log messages, internal error codes)
✅ **Correct approach:** This skill generates player-facing copy only. Internal strings belong to engineering. If a string is not displayed to the player, it is out of scope.

❌ **Anti-pattern 10:** Leaving placeholder tokens undocumented
✅ **Correct approach:** Every placeholder used in a string must be documented with what it represents (e.g., `{player_name}` = the authenticated player's display name). Undocumented placeholders break localization workflows.

---

## Non-Goals

* **UI layout and screen flow design** — handled by `ui-systems` and `design-reference`
* **Prefab or TMP component modification** — handled by `scene-component-builder`; this skill delivers strings only
* **Translation to other languages** — this skill produces base-language strings; translation is a separate localization workflow
* **Backend or internal strings** — log messages, debug output, and internal error codes are engineering strings, not player-facing copy

---

## Notes for LLM Implementation

1. **Context before copy**: Never write strings without understanding the UI element type (button, tooltip, error, tutorial). The element type determines length, verb form, and capitalization convention.
2. **Short wins on buttons**: Button and menu item copy should be the shortest possible string that communicates the action. Every additional word is a UI fitting problem waiting to happen.
3. **Placeholders, always**: Any dynamic content (names, numbers, dates, input bindings) must be placeholder notation. Never hardcode.
4. **Tone consistency is a batch concern**: Evaluate all strings in a batch together for tone consistency before delivering. One casual string in an epic batch breaks immersion.
5. **Localization flags are proactive**: Don't wait for a localization team to discover idioms. Flag them in the notes section of every output where they appear.

**Output format:**
- Always produce the JSON output shape defined in the Outputs section
- Always produce the markdown Copy Report from the Final Step
- String table in the report uses the markdown table format; JSON follows for integration

**Tone and approach:**
- Concise and functional: copy serves the player, not the writer
- Consistent: match the established voice; document deviations
- Localization-aware: every string is written as if it will be translated

---

## Metadata Summary

```yaml
name: ui-copy
category: QA & Diagnostics
priority: Medium
depends_on: [design-reference, ui-systems]
flags_skills: [scene-component-builder, ui-systems]
rules_applied: [PS-1, PS-3, DA-6, MF-1, DT-1]
documents_needed: [design-reference, ui-systems-guide, existing-localization-table]
tags: [unity, ui, copy, localization, strings, ux, ugui, tmp, buttons, menus, tooltips, i18n]
```

**Key relationships:**
- Depends on: design-reference (game voice and tone), ui-systems (localization system and key schema)
- Flags: scene-component-builder (TMP placement), ui-systems (localization system integration)
- Governed by: PS-1 (context and tone validation), PS-3 (copy only), DA-6 (concise over elaborate), MF-1 (vocabulary consistency), DT-1 (assumption logging)

---

*End of Skill Human Spec — ui-copy-docs.md*
