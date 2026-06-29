# Workflow 5 — Character Classes & Sets

Implement every character class and set behavior described in the Wiki.

## Features

Character classes: (most from lua patterns)

- `%a` — Alphabetic characters.
- `%d` — Decimal digits.
- `%w` — Word characters.
- `%s` — Whitespace characters.
- `%u` — Uppercase letters.
- `%l` — Lowercase letters.
- `%p` — Punctuation.
- `%x` — Hexadecimal digits.
- `%h` — Horizontal whitespace.
- `%c<X>` — Unicode character category.
- `%e<FFFF>` — Unicode codepoint escape.
- `%<magic>` — Engine-defined character class.
- `.` — Any character.
- `%%` — Literal `%`.

Sets:

- []
- [^]
- ranges
- escaped characters
- combinations
- nested behavior defined by the Wiki

## Dependencies

Requires:

- Core Engine

## Development Process

(identical)

## Testing

Include:

- every character class
- ranges
- unicode
- escaping
- invalid ranges
- malformed sets
- regression tests

## Deliverables

- Complete character class support
- Complete set support
- Passing tests