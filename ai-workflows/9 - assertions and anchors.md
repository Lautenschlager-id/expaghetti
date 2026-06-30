# Workflow 9 — Assertions & Anchors

Implement every zero-width assertion described in the Wiki.

## Features

- `^` — Beginning of the input (or line, depending on flags).
- `$` — End of the input (or line, depending on flags).
- `%bxy` — Balanced match between characters `x` and `y`, accounting for nesting.
- `%f[set]` — Frontier boundary: zero-width match at a transition into or out of the given character set. Generalizes `\b` to any set. `%f[%w]` ≡ `\b`.
- `%F[set]` — Non-frontier: complement of `%f[set]`. Generalizes `\B`.
- `(?=...)` — Positive lookahead.
- `(?!...)` — Negative lookahead.
- `(?<=...)` — Positive lookbehind (fixed-length only).
- `(?<!...)` — Negative lookbehind (fixed-length only).

Implement anchors first, then lookarounds.

## Dependencies

Requires:

- Groups
- Quantifiers

## Testing

Cover:

- start/end
- multiline
- nested assertions
- assertions inside alternations
- assertions inside quantifiers

## Deliverables

Complete assertion support.