# Workflow 14 — Public API

The regex engine is now feature-complete, architecturally stable, and performance optimized.

The objective of this workflow is to design and implement a clean, intuitive, extensible public API.

This workflow should not redesign the parser or matcher. It should expose the engine through a well-designed interface while keeping all implementation details internal.

## Goals

Design an API that is:

* intuitive
* easy to discover
* Lua-friendly
* consistent
* extensible

The parser, matcher, AST, and internal state objects should remain implementation details.

## API Design

Support both one-off operations and compiled patterns.

### One-off Operations

```lua
local exp = require("expaghetti")

exp.test(pattern, string, options)

exp.match(pattern, string, options)

exp.matchAll(pattern, string, options)

exp.gmatch(pattern, string, options) (similar to matchAll, but behaves differently, like Lua's)

exp.find(pattern, string, options)

exp.replace(pattern, string, replacement, options) (alias: exp.gsub)

exp.split(pattern, string, options)
```

### Compiled Patterns

Compiled patterns should expose equivalent functionality.

```lua
local pattern = exp.compile("(%w+)", options)

pattern:test(string)

pattern:match(string)

pattern:matchAll(string)

pattern:gmatch(string)

pattern:find(string)

pattern:replace(string, replacement) (alias: pattern:gsub)

pattern:split(string)
```

Compiled patterns should be reusable.

## Configuration

Support configuration at multiple levels.

### Global

```lua
exp.configure({...})
```

### Engine

```lua
local engine = exp({...})

local pattern = engine:compile(...)
```

### Pattern

```lua
local pattern = engine:compile(regex, {
    ...
})
```

Pattern-specific configuration should override engine configuration.

Engine configuration should override global configuration.

## Flags

The public API should accept multiple flag formats for convenience.

These should all be equivalent:

```lua
pattern:match(str, "imu")
```

```lua
pattern:match(str, { "i", "m", "u" })
```

```lua
pattern:match(str, {
    i = true,
    m = true,
    u = true,
})
```

```lua
pattern:match(str, {
    RegexFlag.IGNORE_CASE,
    RegexFlag.MULTILINE,
    RegexFlag.UNICODE,
})
```

```lua
pattern:match(str, {
    [RegexFlag.IGNORE_CASE] = true,
    [RegexFlag.MULTILINE] = true,
    [RegexFlag.UNICODE] = true,
})
```

Normalize every representation to a single internal format before execution.

The parser and matcher should never depend on raw strings.

## Configuration Values

Where appropriate, support both user-friendly values and enums.

Examples include:

* escape character
* newline mode
* capture history
* parser options
* matcher options

The public API may accept descriptive strings, but the engine should normalize them to enums before execution.

Avoid propagating raw strings throughout the implementation.

## Engineering Standards

* Keep the public API independent from the parser and matcher implementation.
* Do not expose internal state objects.
* Do not expose parser or matcher internals.
* Keep the API consistent across every operation.
* Prefer immutable public objects wherever practical.
* Keep naming consistent and self-explanatory.
* Update documentation and examples.
* Add comprehensive API tests.

## Deliverables

* Public API implemented.
* Configuration system redesigned.
* Pattern compilation API implemented.
* Comprehensive API documentation.
* Examples added.
* Complete API test suite.

## Commit

Commit progress in logical batches throughout the workflow.

Each batch should:

* build successfully
* pass the complete test suite
* keep the public API functional

Create a final commit summarizing the completed public API implementation.
