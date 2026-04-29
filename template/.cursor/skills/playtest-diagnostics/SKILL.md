---
name: playtest-diagnostics
description: "Use when task requires Post-playtest analysis. Analyzes Unity logs/profiler for crashes, exceptions, GC spikes, frame spikes. Diagnostic only — no fixes."
---

# Playtest Diagnostics

name:playtest-diagnostics|pri:H|deps:[testing-standards,performance-optimization]|flags:[qa-test-generation,performance-optimization]|rules:[TQ-2,MF-4,MF-5,PS-2,PS-3]
SCOPE: Post-playtest analysis. Analyzes Unity logs/profiler for crashes, exceptions, GC spikes, frame spikes. Diagnostic only — no fixes.
ENFORCE: Ground every cause in log evidence (cite lines/stack traces); label confidence CONFIRMED/PROBABLE/POSSIBLE per TQ-2; surface crashes prominently per PS-2; cluster exceptions by call site per MF-4 (root cause not count); flag exceptions >5×/session as reliability risk per MF-5; compare frame spikes to platform budget (mobile=33ms, pc/console=16ms, vr=11ms); flag:qa-test-generation for confirmed issues; flag:performance-optimization for profiler bottlenecks; mark incomplete data reports as PARTIAL.
PROHIBIT: Code fixes/patches; asset modification; generic advice without data; unlabeled suspected causes; treating warnings as bugs without elevation criteria.
ON_VIOLATION: no_log→halt→request_data. native_crash_no_managed_trace→log_Critical→flag_platform_crash_reporter→continue. fix_requested→deliver_diagnostic→redirect_engineering→do_not_propose_patch. truncated→mark_PARTIAL→note_limitation→proceed. cause_no_evidence→label_SPECULATIVE→note_required_data. recurring→reliability_risk:MF-5→flag:qa-test-generation.

## Reference
- See [reference.md](reference.md) for distilled source details.
