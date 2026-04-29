---
name: skill-orchestration
description: "Use when task requires ORCH-1 Stages 2 and 3, after intent-parsing completes. Selects, loads, and sequences skills from the intent model into an ordered execution chain ready for rule evaluation."
---

# Skill Orchestration

name:skill-orchestration|pri:H|deps:[intent-parsing]|flags:[skill-dependency-resolution,rule-enforcement-engine]|rules:[DT-1,PS-3,MF-3]

SCOPE: ORCH-1 Stages 2 and 3, after intent-parsing completes. Selects, loads, and sequences skills from the intent model into an ordered execution chain ready for rule evaluation.

ENFORCE: Validate all candidate skills against skill_registry.md before including in chain; load each selected skill file via view and read depends_on and rules_applied from skill header — never from registry; build dependency graph from depends_on declarations and topologically sort to determine execution order; activate Stage 3 if skill_count>1 OR any skill declares depends_on; trace every skill in the final chain to a specific element of the intent model (PS-3); log all substitutions, de-selections, and inferred ordering decisions via DT-1; flag rule-enforcement-engine when a valid ordered chain is produced.

PROHIBIT: Including skills not traceable to the intent model (scope creep); reading depends_on from skill_registry.md — read from loaded skill header only; proceeding with a chain containing an unresolved circular dependency; loading skills speculatively beyond what the task requires.

ON_VIOLATION: circular_dependency_detected→flag:skill-dependency-resolution→block execution. candidate_skill_not_in_registry→remove from chain→log via DT-1→flag:skill-gap-detection if list empty. scope_creep_detected→remove unjustified skill→log via DT-1. unresolvable_conflict→flag:skill-dependency-resolution→abort with explanation if unresolved. chain_valid→flag:rule-enforcement-engine→proceed to Stage 5.

## Reference
- See [reference.md](reference.md) for distilled source details.
