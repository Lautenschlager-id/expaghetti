# Workflow 2 — Parser Refactor

You have completed the architecture review.

Now refactor ONLY the parser.

The parser is one of the project's strengths and should remain tree-based.

Do NOT convert it into an NFA, DFA, graph parser, or state machine architecture.

The above is true unless absolutely necessary. Then you have to argument very well to convince me.

The parser should remain intuitive to inspect and debug.

## Objectives

Preserve behavior while improving:

- readability
- maintainability
- modularity
- testability

## Responsibilities

The parser should only be responsible for:

- token consumption
- syntax validation
- AST construction

It should **not** perform matching logic.

---

## Before writing code

Describe the future parser architecture.

Include:

- tokenizer responsibilities
- parser responsibilities
- AST node hierarchy
- ownership of node creation
- parser utilities
- error handling
- parser invariants

Explain why each change improves the project.

---

## Refactoring rules

Keep changes incremental.

Every commit should:

- preserve behavior
- compile
- pass every existing test

Avoid introducing new abstractions unless they simplify the parser.

Favor explicit code over clever code.

Avoid deeply nested conditionals.

Avoid duplicated parsing logic.

Document complex parsing rules.

---

## Testing

Before implementing a change:

1. Verify existing coverage.
2. Add missing parser tests.
3. Ensure every parser change is covered.

Parser tests should validate:

- AST structure
- Operator precedence
- Groups
- Alternation
- Quantifiers
- Character classes
- Anchors
- Empty expressions
- Invalid syntax
- Nested expressions
- Regression cases

---

## Deliverables

Produce:

1. Updated parser architecture
2. Incremental commits
3. Updated parser documentation
4. Passing parser tests
5. No matcher changes unless absolutely required