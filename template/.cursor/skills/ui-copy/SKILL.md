---
name: ui-copy
description: "Use when task requires UI copy and localisation. Generates key/string pairs for buttons, tooltips, errors, notifications. Copy only — no layout, prefab, or translation."
---

# UI Copy

name:ui-copy|pri:M|deps:[design-reference,ui-systems]|flags:[scene-component-builder,ui-systems]|rules:[PS-1,PS-3,DA-6,MF-1,DT-1]
SCOPE: UI copy and localisation. Generates key/string pairs for buttons, tooltips, errors, notifications. Copy only — no layout, prefab, or translation.
ENFORCE: Confirm UI context and tone before generating (BLOCK if absent per PS-1; default casual+DT-1 if tone unstated); key schema from project convention or ui.[screen].[element_type].[name] (log assumption per DT-1); buttons ≤4 words imperative verb Title Case; tooltips/messages Sentence case action-oriented; named placeholders ({score}, {player_name}) documented in output notes; no TMP rich text in values; vocabulary consistent with existing table per MF-1; flag idioms in localisation notes; prefer clear over elaborate per DA-6.
PROHIBIT: Embedded rich text tags in string values; hardcoded currency/date/number formats; layout or scene changes; undocumented placeholders; unilateral renaming of established terms.
ON_VIOLATION: no_context→BLOCK→request_screen_element_list. tone_conflict→generate_both→await_direction. schema_conflict→match_existing→log:DT-1. tmp_placement→flag:scene-component-builder→deliver_copy. l10n_decision→flag:ui-systems→continue. idiom→flag_localisation_notes. placeholder_undoc→document_first.

## Reference
- See [reference.md](reference.md) for distilled source details.
