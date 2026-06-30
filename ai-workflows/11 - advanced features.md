# Workflow 11 — Advanced Features

Implement every advanced regex feature described in the Wiki.

These features typically interact with captures, alternation, quantifiers, assertions, and the matching engine itself. The Wiki is the source of truth for syntax, semantics, validation rules, edge cases, and expected behavior.

## Features

### Atomic Groups

- `(?>...)` — Atomic group.

### Branch Reset Groups

- `(?|...)` — Branch reset group.

### Recursion & Subroutines

Implement support for:

- `(?R)` — Whole-pattern recursion.
- `(?0)` — Whole-pattern recursion (alias to `(?R)`).
- `(?1)` — Numbered recursive group (`?N` where `N >= 0`).
- `(?&name)` — Named recursive group.

## Integration

Ensure these features correctly interact with:

- capturing groups
- named groups
- backreferences
- alternation
- quantifiers
- assertions
- capture numbering
- recursion depth and validation
- backtracking behavior

Refer to the Wiki for the exact syntax, semantics, validation rules, edge cases, and expected behavior. The Wiki is the source of truth; this workflow defines only the implementation strategy.