---
name: to-xllm-tickets
description: Convert an xLLM plan, specification, design, or conversation into dependency-ordered local ticket files under agent-workspace/issues/. Use when the user wants xLLM work broken into implementation-ready tickets, agent tasks, or independently verifiable slices without publishing to an external issue tracker.
---

# To xLLM Tickets

Break xLLM work into small, dependency-ordered tickets. Use local Markdown files as the only ticket store; never publish to GitHub, Linear, or another external tracker.

## Process

### 1. Gather context

Use the plan, specification, design, path, URL, or conversation supplied by the user. Read referenced material in full when accessible.

For xLLM code work, read and follow `RULES.md` when it exists.

### 2. Explore the codebase (optional)

If the current codebase state is not already clear, inspect the relevant code, tests, glossary, and architectural decisions. Use the project's real terminology in ticket titles and descriptions.

Identify small prefactors that would make the change easier. Put necessary prefactoring before the behavior that depends on it.

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- Title.
- What it delivers end to end.
- Blocked by.

Ask whether:

- The granularity is too coarse or too fine.
- Each blocking edge represents a genuine dependency.
- Any tickets should be merged or split.

Iterate until the user approves the breakdown.

If the user explicitly asks to generate tickets immediately, treat the proposed breakdown as approved.

### 5. Write local ticket files

Write one Markdown file per approved ticket under `agent-workspace/issues/`. Create the directory if needed.

- Use four-digit dependency-order prefixes: `0001-<slug>.md`.
- Continue from the highest existing prefix.
- Do not overwrite existing tickets unless the user explicitly requests it.
- Do not create an index or modify files outside this directory unless requested.

Use the same language as the source unless the user asks otherwise.

## Ticket Template

```markdown
# Ticket title

## What to build

Describe the behavior or outcome this ticket delivers.

## Acceptance criteria

- A concrete, verifiable completion condition.
- Required tests or validation.

## Blocked by

None — can start immediately.
```

For blocked tickets, list each blocking ticket by number and title. Avoid brittle file-by-file instructions and code snippets unless they are necessary to preserve a design decision.
