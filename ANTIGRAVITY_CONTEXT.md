# Antigravity Context: Expaghetti Architecture & Migration

## 1. Project Overview & Current State
We are in the midst of a major architectural overhaul of the **Expaghetti** Lua regular expression engine. The overarching goal is to modernize the engine from a legacy, loosely-typed, multi-pass functional architecture to a structured, state-driven, Object-Oriented pipeline.

We have recently completed:
- **Workflow 12.1 (Parser Migration)**: Removed legacy compatibility wrappers, consolidated AST node generation to rely strictly on the `Tokenizer`'s `tokens` list, and eliminated dual-list hacks (`charactersList`, `charactersValueList`).
- **Workflow 12.2 (Matcher Migration)**: Completely removed `legacyTreeMatcher` and replaced it with `coreTreeMatcher` using the new `MatchState` object. Magic modules (`Group`, `Alternate`, `Quantifier`, `Anchor`, etc.) now natively consume `MatchState` and utilize `MatchState:branch()` for clean backtracking and recursion, without relying on long parameter lists (`flags, tree, treeLength, stringIndex...`). All matcher tests pass.

## 2. Current Active Goal: Workflow 12.3 - State Consolidation
We are currently targeting the consolidation of the execution state throughout the engine to further reduce coupling and simplify APIs. 

**Key Tasks for 12.3:**
- **Consolidate Parser & Matcher State**: `ParserState` and `MatchState` currently exist but have redundant or loosely structured properties (e.g., sharing similar metadata or repeating string metrics like `splitStr` / `strLength`).
- **Eliminate Duplicated State**: Remove duplicated representations of execution state, capture state, and recursion state.
- **Cleanup**: Rename fields to be descriptive, remove obsolete debugging utilities, and simplify cross-module state flow.

*Note: The user currently has `14 - public api.md` open, indicating we are rapidly approaching the final API wrapper phase once state management is completely clean.*

## 3. Data Schemas & Architecture Decisions

### MatchState Architecture
The `MatchState` object is now the sole source of truth during execution:
```lua
MatchState = {
    flags = {},                 -- Engine modifier flags (i, m, s, etc.)
    splitStr = {},              -- The target string split into an array of chars (supports Unicode)
    strLength = 0,              -- Length of target string
    stringIndex = 0,            -- Current execution pointer
    initialStringIndex = 0,     -- Starting index of the current execution frame
    metaData = {                -- Mutable state shared across branches
        groupCapturesInitStringPositions = {},
        groupCapturesEndStringPositions = {},
        positionCaptures = {},
        outerTreeReference = {},
        recursionDepth = 0,
        backtrackSteps = 0,
        maxRecursionDepth = X,
        maxBacktrackDepth = Y
    }
}
```
**Key Decision**: We use `MatchState:branch(stringIndex, initialStringIndex)` to clone the shallow state pointers while keeping the `metaData` reference shared. This allows safe, garbage-collected branching for alternates and quantifiers without manually reconstructing parameter lists, while still tracking global capture state and recursion limits.

### ParserState Architecture
The parser uses a similar state object:
```lua
ParserState = {
    expr = "",                  -- Original expression
    flags = {},
    isGroup = false,
    isAlternate = false,
    index = 1,                  -- Token pointer
    expression = {},            -- Split expression chars
    expressionLength = 0,
    tokens = {},                -- Unified token stream from Tokenizer
    metaData = {},              -- Shared parsing metadata (group counts, names, root tree refs)
    hasGroupClosed = false
}
```

## 4. Pending Tasks & Next Steps
1. **Execute Workflow 12.3**:
   - Analyze `MatchState` and `ParserState` for overlapping structures.
   - Refactor `metaData` to explicitly define capture state, recursion state, and engine metadata, removing loose variables.
   - Validate that no performance regressions or behavioral changes occur (via `lua init.lua` and `lua test_matcher.lua`).
2. **Execute Workflow 14 (Public API)**:
   - Design and implement the final public-facing API for Expaghetti that wraps this internal architecture cleanly.
3. **Documentation**:
   - Update any remaining inline comments mentioning "legacy" terminology or deprecated multi-argument flows.

## 5. Rules & Guidelines
- **Source of Truth**: The Expaghetti Wiki dictates correct syntax, semantics, validation rules, edge cases, and expected behaviors. Correctness always comes first.
- **Code Purity**: We strictly avoid reverting to legacy patterns (threading massive argument lists). If a module requires more context, it should either live on the `State` object or be a localized configuration, never a loose parameter.
