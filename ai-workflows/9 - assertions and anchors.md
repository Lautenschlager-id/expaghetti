# Workflow 8 — Assertions & Anchors

Implement every zero-width assertion described in the Wiki.

## Features

- `^` — Beginning of the input (or line, depending on flags).
- `$` — End of the input (or line, depending on flags).
- `%b` — Word boundary. (from Lua patterns)
- `%B` — Non-word boundary. (from Lua patterns)
- `(?=...)` — Positive lookahead.
- `(?!...)` — Negative lookahead.
- `(?<=...)` — Positive lookbehind.
- `(?<!...)` — Negative lookbehind.

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