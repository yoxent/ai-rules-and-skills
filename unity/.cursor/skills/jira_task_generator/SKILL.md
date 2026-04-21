---
name: jira_task_generator
description: >
  Jira Task Utility. Converts features/bugs into JSON-ready Kanban tasks
  with actionable checklists.
---

# Jira Task Generator (Execution)

PURPOSE: convert a feature/bug/improvement/idea into ONE Jira-ready Kanban task.
ROLE: **human productivity tool**, not an agent execution tool. MUST NEVER be called by the Orchestrator, used to store output in `memory_manager`, or used to plan/drive AI execution. Intended for a human to request + copy-paste the result into Jira.

## Responsibilities
- Produce one task per input (single responsibility, trackable scope).
- **Title**: verb-first, actionable, Kanban-scannable (for example "Implement object pooling system", "Add mouse-based parallax").
- **Short description**: brief context + scope; no fluff or AI/agent language; developer-friendly + neutral.
- **Checklist**: actionable items that clearly define "done" and are verifiable.

## Hard Constraints (DO NOT)
- Connect to Jira or any external API.
- Assume team-specific workflows, labels, or sprint structures.
- Generate overly large or vague tasks.
- Include AI-specific instructions / agent-related language.
- Modify or reference other AI skills / systems.

## Output Format (plain text only; no JSON / code fences / extra labels)

Use exactly this layout so users can copy-paste directly into Jira:

```
Title:
<one line, concise task title>

Short description:
<one or two sentences: context and scope>

Checklist:
- <first actionable, verifiable item>
- <second item>
- ...
```

- **Title**: one line, verb-first (Implement X / Add Y / Fix Z). Avoid noun-only or category-prefix titles (not "Parallax: mouse-based movement"; use "Implement mouse-based parallax movement").
- **Short description**: brief developer-friendly (context + scope).
- **Checklist**: ordered actionable + verifiable items defining "done"; prefix each with `- ` so it pastes as a list.

## Workflow
1. Parse user input (feature / bug / improvement / idea).
2. Scope to one task with single responsibility.
3. Draft **Title** — verb-first + actionable (Implement/Add/Fix/Refactor + feature), short, Kanban-friendly.
4. Draft **Short description** — neutral, human-readable, no AI/agent wording.
5. Draft **Checklist** — concrete, verifiable "done" criteria.
6. Emit only the plain-text block above; no JSON or markdown wrapping.
