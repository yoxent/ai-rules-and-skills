---
name: goal-task-tracking
description: "Use when task requires Stage-1 on explicit user continuation signal from intent-parsing; Stage-10 on orchestrator task-completion trigger. Manages goals/goal-[id].md lifecycle. Never activates proactively or via session-start scan."
---

# Goal Task Tracking

name:goal-task-tracking|pri:H|deps:[goal-task-decomposition]|flags:[goal-task-decomposition,engineering-decision-logging]|rules:[GM-4,DT-1,MF-1,MF-5,PS-4]

SCOPE: Stage-1 on explicit user continuation signal from intent-parsing; Stage-10 on orchestrator task-completion trigger. Manages goals/goal-[id].md lifecycle. Never activates proactively or via session-start scan.

ENFORCE: Activate only when intent-parsing surfaces explicit continuation signal OR Stage-10 sends completion trigger; never self-trigger. At Stage-1 identify target goal file from signal; if ambiguous and multiple in-progress files exist surface disambiguation list and require explicit selection before loading. Load and validate goal state file before any operation; halt on missing or corrupt file. Surface next pending task whose full dependency chain is done in declaration order (GM-4). Log task activation on first load for each task via DT-1. At Stage-10 verify all completion criteria met before marking task done; write status update atomically; confirm write before reporting completion. After each Stage-10 write check if all tasks done; if yes set goal status complete, write update, emit explicit goal-completion signal to user (PS-4). Log task completion events and state anomalies via DT-1. Validate no partial writes; on write failure halt and retain previous state (MF-5). Ensure task status updates do not affect other tasks or overall goal integrity (MF-1).

PROHIBIT: Activating without explicit continuation signal or Stage-10 trigger; proactive session-start scan of goals/; marking task done without Stage-10 orchestrator confirmation; auto-selecting goal when signal is ambiguous; silently closing completed goal without user notification; auto-repairing corrupt state file; non-atomic state file writes; surfacing a task whose dependency chain is not fully done; modifying task objectives, names, or dependencies after file creation.

ON_VIOLATION: missing_state_file→halt→report_path→offer:goal-task-decomposition. corrupt_state_file→halt→report_parse_failure→flag:engineering-decision-logging. dependency_deadlock→surface_blocked_tasks→request_user_resolution→block_Stage2. ambiguous_signal_multiple_goals→surface_disambiguation_list→require_explicit_selection. write_failure→halt→report_error→retain_previous_state→do_not_declare_complete. goal_already_complete→notify_user→do_not_surface_next_task.

## Reference
- See [reference.md](reference.md) for distilled source details.
