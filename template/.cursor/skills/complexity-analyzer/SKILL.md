---
name: complexity-analyzer
description: "Use when task requires Analyzes algorithmic and structural complexity to identify optimization candidates; triggered by performance-optimization when deeper analysis is needed before changes are applied."
---

# Complexity Analyzer

name:complexity-analyzer|pri:M|deps:[]|flags:[performance-optimization,correctness-validation]|rules:[PC-1,PC-2,DA-5,GM-2]

SCOPE: Analyzes algorithmic and structural complexity to identify optimization candidates; triggered by performance-optimization when deeper analysis is needed before changes are applied.

ENFORCE: Require profiling data or reproducible symptom before proceeding — reject theoretical analysis without evidence per PC-1; bound scope to identified hot paths only; classify time and space complexity (Big-O) for each in-scope path; identify empirical bottleneck by cross-referencing profiling data with complexity findings; rank optimization candidates by impact, feasibility, and correctness risk; flag correctness-validation for any candidate that risks output correctness per PC-1; explain findings before handing off to performance-optimization per GM-2; do not apply changes

PROHIBIT: Analyzing without measurement data or reproducible symptom; micro-optimizing code outside the identified hot path; recommending candidates that risk correctness without flagging correctness-validation; presenting candidates as a flat unranked list; applying optimizations directly

ON_VIOLATION: no_profiling_data→request_measurement→if_genuinely_unavailable document_assumption→note_lower_confidence→proceed. optimization_risks_correctness→flag correctness-validation→exclude_candidate_until_confirmed. bottleneck_architectural→surface_finding→flag performance-optimization→do_not_recommend_local_workarounds. scope_too_broad→bound_to_hot_path.

## Reference
- See [reference.md](reference.md) for distilled source details.
