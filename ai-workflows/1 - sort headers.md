# Code Style & Organization Feedback

Overall, the architecture has reached a level of maturity where consistency is now more valuable than further structural refactors. I recommend establishing a project-wide style guide and applying it consistently across every module.

---

## 1. Standardize the file layout

Every Lua file should follow the same high-level organization.

```lua
--[[
    Module description.
]]

--[[ Globals ]]--
local require = require
local next = next

local table_concat = table.concat
local string_byte = string.byte

--[[ Dependencies ]]--
local AST = require("ast")
local MatchState = require("matcher.state")
local Set = require("magic.set")

--[[ Enum Aliases ]]--
local ElementType = AST.ElementType
local QuantifierType = AST.QuantifierType

--[[ Constants ]]--
local DEFAULT_MAX = 255
local ESCAPE_CHAR = "%"

--[[ Module ]]--
local Module = {}

--[[ Private Functions ]]--
local helper = function()
end

--[[ Public API ]]--
Module.execute = function()
end

return Module
```

Using the same layout everywhere makes files much easier to navigate and immediately familiar.

---

## 2. Localize globals consistently

Many files already localize Lua globals and standard library functions, but the approach isn't consistent.

Recommended rules:

- Localize only functions actually used by the file.
- Keep all localized globals in one dedicated section.

Example:

```lua
local require = require
local next = next
local ipairs = ipairs
local type = type

local table_concat = table.concat
local table_insert = table.insert
local string_byte = string.byte
local string_sub = string.sub
local math_min = math.min
```

Avoid localizing unused globals simply because "every file does it."

---

## 3. Group imports by responsibility

Instead of one long list of `require()` calls, group them logically.

Example:

```lua
--[[ Dependencies ]]--

-- Core
local AST = require("ast")

-- State
local MatchState = require("matcher.state")

-- Parser / Matcher
local Quantifier = require("matcher.quantifier")

-- Magic
local Literal = require("magic.literal")
local Set = require("magic.set")
```

This makes dependencies much easier to understand.

---

## 4. Separate enum aliases from imports

Avoid mixing imports and aliases.

Instead of:

```lua
local AST = require(...)
local ElementType = AST.ElementType

local ParserState = require(...)
local Errors = ParserState.Errors
```

Prefer:

```lua
---------------------------------------------------------------------
-- Dependencies
---------------------------------------------------------------------

local AST = require(...)
local ParserState = require(...)

---------------------------------------------------------------------
-- Enum Aliases
---------------------------------------------------------------------

local ElementType = AST.ElementType
local Errors = ParserState.Errors
```

This creates a much cleaner header.

---

## 5. Standardize naming

The project currently mixes camelCase and snake_case.

Example:

```lua
currentElement
current_element

stringIndex
string_index
```

Use **camelCase** throughout the project (code and files!).

The majority of the engine already follows this style:

```lua
collectOccurrences
continueMatcher
executeElement
currentElement
stringIndex
maximumOccurrences
startStringPositions
```

Migrating entirely to camelCase would require less work than switching everything to snake_case.

One exception where snake_case is beneficial is for localized Lua library functions.

Example:

```lua
table_concat
table_insert
string_byte
string_sub
math_min
```

These directly mirror:

```lua
table.concat
table.insert
string.byte
string.sub
math.min
```

which makes their origin immediately recognizable.

---

## 7. Naming conventions

### Modules

Use PascalCase.

```lua
MatchState
ParserState
Quantifier
Literal
```

### Functions

Use camelCase.

```lua
collectOccurrences()
compileSet()
matchElement()
```

### Variables

Use camelCase.

```lua
stringIndex
currentElement
captureCount
```

### Constants

Use UPPER_SNAKE_CASE.

```lua
DEFAULT_MAX
ESCAPE_CHAR
HEX_BASE
```

---

## 8. Consistent spacing

Separate logical groups with a single blank line.

Avoid unnecessary blank lines inside a group.

Good:

```lua
local AST = require(...)
local MatchState = require(...)

local Literal = require(...)
local Set = require(...)
```

---

## 9. Section separators

For larger modules, section separators significantly improve readability.

Example:

```lua
--[[ Dependencies ]]--

--[[ Enum Aliases ]]--

--[[ Constants ]]--

--[[ Module ]]--

--[[ Private Functions ]]--

--[[ Public API ]]--

--[[ Return ]]--
```

Large files become much easier to scan.

---

## 10. Documentation

The project would benefit from consistent documentation across all public and private functions.

Please document every function using EmmyLua-style comments similar to:

```lua
--- The main parser entry point. Parses a regex expression string into an AST.
---@param exprOrState string|table The regular expression string or an existing ParserState.
---@param flags string|table|nil A string of flag characters or a table of boolean flags.
---@return table|boolean tree The generated AST, or false if an error occurred.
---@return string|table|nil errorMessage An error message or error token if parsing failed.
```

Every function should include:

- A concise description of its purpose.
- `@param` annotations for every parameter.
- `@return` annotations for every return value.

Maintaining this consistently across the entire project will greatly improve editor IntelliSense, readability, and long-term maintainability.
