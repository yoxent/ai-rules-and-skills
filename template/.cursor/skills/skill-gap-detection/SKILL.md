---
name: skill-gap-detection
description: "Use when task requires ORCH-1 on missing_capability failure or when skill-orchestration finds no registry match for parsed intent. Confirms missing capabilities, produces governed skill outline, and blocks improvisation."
---

# Skill Gap Detection

name:skill-gap-detection|pri:H|deps:[intent-parsing]|flags:[decision-confirmation-gate,engineering-decision-logging]|rules:[PS-1,PS-3,DT-2]

SCOPE: ORCH-1 on missing_capability failure or when skill-orchestration finds no registry match for parsed intent. Confirms missing capabilities, produces governed skill outline, and blocks improvisation.

ENFORCE: Re-validate intent and search all registry phases before confirming a gap; distinguish genuine gap from misuse — reject false positives before escalating; classify confirmed gap by phase, category, and risk level; produce new skill outline in AI spec format before escalating; flag decision-confirmation-gate on every confirmed gap before any registry change; flag engineering-decision-logging on every confirmed gap regardless of outcome; block all execution that would improvise outside registered skills.

PROHIBIT: Declaring a gap without full registry search and intent re-validation; proposing a new skill whose SCOPE overlaps >50% with an existing skill — recommend extension instead; proceeding with improvised behavior after gap is confirmed; updating skill_registry.md without a confirmed decision-confirmation-gate approval.

ON_VIOLATION: improvised_execution_without_gap_report→block→surface gap→flag:decision-confirmation-gate. proposed_skill_overlaps_existing→recommend extension→flag:skill-version-management. registry_update_without_confirmation→block→abort. false_gap_declaration→re-run intent-parsing→re-validate before re-escalating.

## Reference
- See [reference.md](reference.md) for distilled source details.
