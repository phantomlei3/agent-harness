---
name: tdd
description: Apply behavior-first test-driven development to xLLM large-model inference framework changes. Use when building a feature or fixing a bug test-first, working in a red-green loop, adding regression or integration tests, choosing public test seams, deciding whether to use fakes/mocks/stubs, or validating scheduler/runtime/cache/model/layer/service behavior.
---

# xLLM Test-Driven Development

Drive xLLM changes through a red → green loop that produces tests worth keeping. Verify observable behavior through stable public interfaces so tests survive internal refactors.

## Prepare

1. Read local instructions before choosing a test seam:
   - Read `RULES.md`, `CONTEXT.md`, and `AGENTS.md` when present.
   - Respect ADRs that govern the affected area.
   - In xLLM repositories, read `.agents/skills/add-unit-test/SKILL.md` and `.agents/skills/add-unit-test/references/xllm-test-patterns.md` when present.
   - Before editing files under `xllm/`, read the code-style reference required by the repository's `AGENTS.md`.

2. Describe the behavior in xLLM terms:
   - Identify the request shape, model family, backend, affected scheduler/runtime/cache/model/layer/service boundary, and externally visible outcome.
   - Record the regression trigger and the smallest deterministic input that proves it.
   - Choose a feasible validation command: a narrow unit binary, CTest target, service probe, eval, or required build gate.

3. Write down the proposed test seams and confirm them with the user before writing tests. Treat a seam as the public boundary where behavior can be observed without reaching into internals. Ask: "What is the public interface, and which seams should we test?"

## What a Good Test Is

Write tests as executable behavior specifications. Use public interfaces, assert outcomes that callers care about, and obtain expected values from an independent source of truth such as a specification, a worked example, a known-good literal, or an eager/reference implementation.

For xLLM, prefer assertions on scheduled batches, token order, tensor values, cache state transitions, generated response fields, errors, or backend-visible execution results. Avoid assertions about which private helper ran.

Read [tests.md](tests.md) for C++ examples and [mocking.md](mocking.md) before introducing a fake, mock, stub, monkeypatch, or test-only subclass.

## Choose the Test Scope

- Use pure logic tests for parsers, config coercion, request parameters, token transforms, and small scheduling rules.
- Use integration-style C++ tests when behavior crosses scheduler, batch, KV cache, tokenizer, runtime, layer, or service boundaries.
- Use device tests only when behavior depends on CUDA/NPU/MLU kernels, graph capture, collectives, dtype, memory layout, or backend-specific runtime state.
- Use service or eval checks when the observable contract is OpenAI-compatible serving behavior, streaming output, accuracy, or performance.

## Avoid These Anti-Patterns

- **Implementation-coupled tests** mock internal collaborators, call private methods, or verify through a side channel. If an internal refactor breaks the test while behavior is unchanged, the test is at the wrong seam.
- **Tautological tests** recompute the expected result with the same logic as production. Use an independent literal, specification, worked example, or reference result instead.
- **Horizontal slicing** writes all tests before all implementation. Use vertical tracer-bullet slices so each completed cycle informs the next one.
- **Over-mocking** replaces cheap deterministic xLLM domain objects or hides the device, memory, backend, or distributed constraint responsible for the bug.

## Run the Loop

For each vertical slice:

1. Add one test at one confirmed seam.
2. Run it and verify that it fails for the intended reason.
3. Implement only enough production code to pass that test. Do not anticipate later tests or add speculative behavior.
4. Run the narrow test and verify that it passes.
5. Start the next red → green slice using what the previous cycle revealed.

Keep refactoring outside the red → green implementation loop. Perform it during review, keeping behavior assertions unchanged, and rerun the relevant tests after every refactor.

## Validate

Validate narrowly first, then broaden according to risk. For xLLM code changes, follow local build-gate instructions. Do not run the xLLM build gate for markdown-only changes.

Before declaring the work complete, verify that:

- Each test name describes behavior rather than implementation.
- Each new test failed for the intended regression before the fix and passes afterward.
- Tests exercise only confirmed public seams.
- Helpers remain file-local unless multiple nearby tests reuse them.
- New CMake and test wiring follows existing xLLM patterns.
- The final response records validation commands and any skipped checks.
