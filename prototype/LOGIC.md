# Code-first prototype

Build the smallest core-code slice that makes an implementation direction inspectable, then explain it with a standalone HTML document. The prototype exists to improve information exchange before full engineering begins.

## 1. Frame the design question

Write one concrete question the prototype will answer. Prefer questions such as:

- Which components own each step of the core flow?
- Where should a new capability enter the existing call path?
- What data crosses the important boundaries?
- Which lifecycle, state, or failure decisions must the user confirm?

Record the intended audience and the feedback needed. If the request contains several questions, select the smallest connected set whose answers would change the implementation direction.

## 2. Build an evidence map

Inspect the repository before drafting code. Find the relevant entry points, core abstractions, data structures, call sites, configuration, and extension seams. Follow repository instructions and existing conventions.

Maintain three explicit buckets throughout the prototype:

- **Known**: supported by repository code, documentation, configuration, or the user's statements.
- **Assumed**: an agent-selected design direction not yet confirmed.
- **Open**: a decision or missing fact that could materially change the design.

Attach a source path or user statement to important known facts. Never present an assumption as existing behavior.

## 3. Create the local prototype branch

Use the current local checkout for the prototype:

1. Confirm the project is a Git repository and inspect `git status --short --branch`.
2. Preserve all pre-existing user changes. Never stash, reset, discard, or overwrite them to prepare the prototype.
3. Before changing any files, create and switch to a new local branch named `prototype/<topic>`. Choose a concise, filesystem-safe topic and add a short numeric suffix if the name already exists.
4. Work in the current checkout. Do not create a separate worktree, clone, scratch repository, or implementation directory under `agent-workspace/`.

If pre-existing changes would be carried onto the new branch or overlap the intended prototype edits, explain the conflict and ask the user how to proceed. Do not commit or publish the branch unless the user explicitly asks.

## 4. Choose the decisive code slice

Trace one end-to-end conceptual path, but implement only its decisive seams. Usually this means:

- the entry point or public contract;
- the central type, interface, or state transition;
- the orchestration or dispatch path;
- one representative implementation;
- thin stubs at external or peripheral boundaries.

Prefer the host project's language and naming. Reuse real types when practical. Do not introduce a new runtime, framework, package manager, or architectural layer merely to support the prototype.

Implement the prototype directly in the existing repository paths where the eventual code would live. Do not place prototype implementation code in `agent-workspace/` or another scratch area. The new branch is the isolation and disposal boundary; keep the diff narrow and mark speculative code clearly.

## 5. Write the core-code prototype

Keep the code direct and easy to compare with the eventual implementation:

- Optimize for visible control flow and data movement.
- Include the happy path and, at most, the one edge case that determines the architecture.
- Stub storage, networking, hardware, generated code, and other peripheral systems unless one is the design question.
- Use comments sparingly for `PROTOTYPE`, `ASSUMPTION`, and `OMITTED` markers.
- Prefer a few coherent files over a broad but hollow skeleton.
- Preserve ambiguity when the evidence is ambiguous; expose the choice instead of silently resolving it.

The prototype may be incomplete, fail to compile, or contain functional gaps. Run a cheap syntax or compile check only when it improves confidence without expanding the task. Do not create unit tests or spend time making every branch operational.

## 6. Choose the project short name

Determine the current project's short name when the skill runs. Infer it from the repository name, package metadata, build configuration, documentation title, or the abbreviation already used in code and docs. Prefer an established abbreviation over inventing a new one.

Normalize the short name into a concise, filesystem-safe filename while preserving recognizable word boundaries. For example, a project commonly called `Example Runtime` might use `er.html` if `ER` is established, otherwise `example-runtime.html`. Do not hardcode a name in the skill and do not use `index.html`. Ask the user only when multiple plausible names would be materially confusing.

## 7. Generate the HTML explainer

Create the explainer at `<project-root>/agent-workspace/<project-short-name>.html`. Create `agent-workspace/` if it does not exist. This HTML is a communication artifact only; all prototype implementation code belongs in the repository's normal code paths on the new branch.

Make the HTML a portable, standalone file with inline CSS and, only when useful, small inline JavaScript. Do not require a build step or external CDN.

The page must make these items quickly understandable:

1. **Question and proposed direction**: what is being explored and the current provisional answer.
2. **Known / assumed / open**: visually distinct groups with evidence paths for known facts.
3. **Current and proposed flow**: a compact diagram showing components, boundaries, and data or control movement.
4. **Core change map**: affected or prototype files, their responsibility, and whether each is new, changed, stubbed, or only proposed.
5. **Key code ideas**: short, escaped code excerpts from the prototype with annotations explaining why each seam matters.
6. **Deliberate omissions and risks**: what is not represented, what is unverified, and where functional gaps may exist.
7. **Feedback needed**: a small set of concrete decisions for the user, ordered by architectural impact.

Use typography, spacing, color, and diagrams to reduce cognitive load. Simple HTML/CSS boxes, arrows, tables, timelines, or inline SVG are sufficient. Add navigation, disclosure controls, or current/proposed toggles only when they materially help. Do not turn the explainer into a generic dashboard or polish it as a product interface.

Every code excerpt and file label must match the prototype artifacts. Clearly badge assumptions and unverified behavior. The page should remain useful when opened directly from disk.

## 8. Check communication integrity

Before handoff, verify:

- the proposed flow agrees with the prototype code;
- referenced paths and symbols exist, or are explicitly labeled proposed;
- known facts have evidence and assumptions are visibly marked;
- omissions include tests, hardening, and any skipped integrations;
- the HTML does not claim successful execution unless it was actually verified;
- the implementation diff is on the new local `prototype/<topic>` branch and no prototype code is under `agent-workspace/`;
- the HTML is located directly under `agent-workspace/` and its filename reflects the project short name selected for this run;
- the user can identify the highest-impact unanswered decisions in a few minutes.

This is a consistency review, not a production validation pass.

## 9. Hand off and iterate

Provide the local branch name, code paths, HTML path, and a short summary of the provisional direction. Lead with the decisions that need user feedback. If the user changes a premise, revise the cheapest relevant slice on the same prototype branch and keep discarded alternatives out of the main narrative.

Do not proceed into full implementation automatically. The prototype is complete when the user can understand, challenge, and refine the design direction—not when the feature is complete.

## Anti-patterns

- Building a product UI or offering visual style variants.
- Creating a nearly production-ready implementation before asking for design feedback.
- Adding tests, exhaustive error handling, deployment work, or broad compatibility code.
- Inventing repository behavior without labeling it as an assumption.
- Showing diagrams that do not correspond to the code prototype.
- Hiding the key design choice inside a large scaffold.
- Putting prototype implementation code under `agent-workspace/` instead of the repository's normal code paths.
- Treating compile or runtime success as more important than communicating the core design.
