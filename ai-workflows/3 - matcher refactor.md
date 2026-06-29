# Workflow 3 — Matcher Refactor

The parser has already been refactored.

Do not modify the parser unless a bug requires it.

Now refactor the matcher.

The matcher should execute directly against the parser tree.

Avoid introducing graph-based execution unless absolutely necessary.

Maintain readability over clever optimizations.

---

## Goals

Improve:

- correctness
- maintainability
- separation of concerns
- testability

---

## Responsibilities

The matcher should own:

- cursor movement
- captures
- backtracking
- quantifier execution
- anchors
- assertions
- alternation
- matching state

The parser should not perform matching responsibilities.

---

## Before changing code

Describe:

- matcher architecture
- execution pipeline
- state representation
- backtracking strategy
- capture handling
- recursion strategy
- quantifier execution

Identify duplicated logic before refactoring.

---

## Refactoring rules

Proceed in very small commits.

Each commit must:

- preserve behavior
- pass every test
- remain understandable

Avoid "magic" optimizations.

Every optimization should be justified with benchmarks.

---

## Testing

Ensure dedicated tests exist for:

- successful matches
- failed matches
- captures
- nested captures
- backtracking
- greedy quantifiers
- lazy quantifiers
- possessive quantifiers
- lookarounds
- anchors
- unicode
- alternation
- edge cases
- regression cases

---

## Deliverables

Produce:

- cleaner matcher architecture
- simplified execution flow
- updated documentation
- complete passing test suite