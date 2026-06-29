# Workflow 7 — Groups & Captures

Implement every grouping feature described in the Wiki.

## Features

Implement every group-related feature described in the Wiki.

This includes, but is not limited to:

### Capturing Groups

- `(...)` — Captures the matched expression as a numbered group.
- `()` — Empty capturing group.
- `(?:...)` — Non-capturing group used for grouping without creating a capture.

### Named Groups

- `(?<name>...)` — Named capturing group.
- `%<name>` — Reference or invoke a named group (according to the Wiki).

### Backreferences

- `%1`, `%2`, ... — Reference a previously captured numbered group.
- `%<name>` — Reference a previously captured named group.

### Advanced Groups

- `(?>...)` — Atomic group.
- `(?|...)` — Branch reset group.
- `(?(condition)...|...)` — Conditional group.
- `(?R)` — Whole-pattern recursion.
- `(?1)` — Numbered recursive group.
- `(?&name)` — Named recursive group.

### Comments & Options

- `(?# comment )` — Inline comment.
- `(?i)` — Inline option modifier.
- `(?i:...)` — Scoped option modifier.

### Capture Management

Implement support for:

- numbered captures
- named captures
- nested captures
- capture history (multiple captures produced by quantified groups)
- capture metadata (start/end positions)
- group numbering
- group validation

Refer to the Wiki for the exact syntax, semantics, validation rules, edge cases, and expected behavior.
The Wiki is the source of truth; this workflow defines only the implementation strategy.