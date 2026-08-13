---
name: to-xllm-spec
description: Create a concise, implementation-oriented specification for xLLM large-model inference framework work from the current conversation and codebase context. Use when the user wants to turn an xLLM feature, bugfix, optimization, model adaptation, scheduler/runtime/cache change, serving API change, hardware-backend requirement, or verification plan into a lightweight engineering spec without User Stories.
---

# to-xllm-spec

Turn the current conversation and relevant codebase context into a compact xLLM engineering spec. Synthesize what is already known instead of interviewing the user by default. Ask only when missing information would materially change the solution; otherwise record uncertainty in `Further Notes`.

## Process

1. Read `CONTEXT.md`, `AGENTS.md`, `RULES.md`, domain glossaries, and relevant ADRs when present. Inspect only the source, tests, scripts, and docs needed to understand the current behavior.
2. Describe the problem and intended outcome in terms of observable behavior.
3. Record the implementation decisions already established by the conversation and repository. Avoid inventing decisions to fill the template.
4. Identify the highest practical test seam. Prefer existing seams and public behavior; introduce fewer new seams when possible.
5. Write the spec with the template below in the user's language unless the repository clearly uses another convention.

Return Markdown by default. Publish to an issue tracker only when explicitly requested.

## Spec Template

```markdown
## Problem Statement

Describe the current problem, its impact, and the behavior that needs to change from the perspective of a user, operator, or developer.

## Solution

Describe the target behavior and overall solution. Include measurable outcomes here when they are important to correctness, performance, compatibility, or operability.

## Implementation Decisions

- Identify affected module boundaries and responsibilities.
- Record interface, configuration, API, state-transition, and component-interaction decisions.
- Capture relevant compatibility, model, topology, or hardware-backend behavior.

## Testing Decisions

- Define the externally observable behavior to verify.
- Name the highest practical test seam and relevant existing test patterns.
- Include build, service, benchmark, or evaluation checks only when the change requires them.

## Out of Scope

State what this spec deliberately does not address.

## Further Notes

Record constraints, assumptions, risks, and unresolved questions that materially affect implementation.
```

## Writing Rules

- Keep the spec concise and decision-oriented. Do not add `User Stories`.
- Include only sections that add information; keep required headings brief when there is little to say.
- Do not repeat the same requirement across `Solution`, `Implementation Decisions`, and `Testing Decisions`.
- Do not include volatile file paths or full code snippets. Include a small state machine, schema, or type shape only when it captures a decision more precisely than prose.
- Consider xLLM-specific dimensions only when relevant: model loading, scheduler/runtime behavior, prefill/decode, streaming, KV cache, distributed topology, hardware backends, OpenAI-compatible APIs, and performance baselines.
- For xLLM code changes, include the `$xllm-build` gate in `Testing Decisions`; omit it for documentation-only work.
