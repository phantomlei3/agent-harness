---
name: prototype
description: Build a disposable, code-first prototype on a new local Git branch plus a standalone HTML explainer before full implementation. Use when the user wants to clarify core code changes, inspect what the current codebase already implies, expose the agent's design assumptions, or review an implementation direction before committing to end-to-end engineering. Do not use it for product UI exploration.
---

# Prototype

Create a communication artifact that makes a proposed implementation concrete enough to discuss. Optimize for shared understanding, not completeness or production readiness.

Read [LOGIC.md](LOGIC.md) completely and follow its workflow.

## Required outcome

Produce both:

1. A small, clearly disposable code prototype containing only the decisive core changes, implemented directly in the current local checkout on a new branch.
2. A standalone HTML explainer under the current project's `agent-workspace/` directory that visualizes the question, evidence, assumptions, code path, proposed changes, omissions, and decisions still needed.

The HTML explains the code design; it is not a product UI prototype.

## Operating rules

- Inspect the existing code before choosing the prototype shape. Reuse real names, types, boundaries, and conventions where evidence exists.
- Before changing files, create and switch to a new local `prototype/<topic>` branch in the current checkout. Do not create a separate worktree or put prototype implementation code under `agent-workspace/`.
- Make the prototype changes directly in the repository paths where the eventual implementation would live. Keep them easy to identify and discard with the branch.
- Separate facts found in the repository from assumptions introduced by the agent and from open questions for the user.
- Keep only code needed to expose the central design direction. Stub peripheral integrations and label omissions explicitly.
- Do not add unit tests, production hardening, broad error handling, migration work, compatibility layers, or unrelated refactors.
- Allow incomplete or non-runnable code when completing it would hide the design signal in infrastructure work. Never imply that unverified code works.
- Mark prototype artifacts and speculative code clearly as `PROTOTYPE` and assumptions as `ASSUMPTION`.
- Name the HTML after the current project's short name, chosen when the skill runs; never use a fixed name such as `index.html`.
- Stop after presenting the prototype and targeted questions. Do not continue into the full implementation unless the user explicitly asks.

## Handoff

Give the user:

- the local prototype branch name;
- the prototype code paths;
- the HTML path and the simplest way to open it;
- a brief statement of what is known, what is assumed, and what remains undecided;
- the few decisions whose answers would materially change the eventual implementation.

Treat feedback as the primary result. Revise the prototype cheaply; do not defend throwaway code as if it were production code.
