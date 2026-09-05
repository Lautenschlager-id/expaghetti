[![Donate](https://img.shields.io/badge/Donate-PayPal-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=TSTEG3PXK4HJ4&source=url)<p align="center">
  <img height="300" alt="Expaghetti Logo" src="https://github.com/user-attachments/assets/2ed8e2f3-fb6e-4be7-8da6-87c6858e641a" />
</p>

<h1 align="center">Expaghetti</h1>

<p align="center">
A modern, feature-rich regular expression engine written entirely in Lua.
</p>

<p align="center">
  <a href="https://github.com/Lautenschlager-id/expaghetti/wiki"><strong>Documentation</strong></a>
</p>

## What is Expaghetti?

Expaghetti is a complete regular expression engine implemented from scratch in pure Lua.

Unlike Lua's built-in pattern matching, Expaghetti provides a modern regex implementation inspired by engines such as PCRE while remaining lightweight, portable, and easy to embed into Lua projects.

It is designed for applications that need expressive pattern matching without relying on external native libraries.

Some supported features include:

- Full regular expression parser and AST
- Unicode support
- Named capturing groups
- Backreferences
- Lookahead and lookbehind assertions
- Atomic groups
- Branch reset groups
- Recursive patterns
- Inline and scoped modifiers
- Greedy, lazy, and possessive quantifiers
- Character classes and ranges
- Position captures

## Documentation

The complete documentation is available in the project Wiki.

👉 **https://github.com/Lautenschlager-id/expaghetti/wiki**

The wiki contains detailed documentation for:

- Pattern syntax
- Character classes
- Groups
- Lookarounds
- Quantifiers
- Modifiers
- API Reference
- Configuration
- Parser internals
- Matcher internals
- Examples

## Installation

Expaghetti is written entirely in pure Lua and has no external dependencies.

Clone (or download) the repository and include it in your project.

```sh
git clone https://github.com/Lautenschlager-id/expaghetti.git
```

<details>
  <summary>
    <h3>With Standard Lua</h3>
  </summary>

Place the `expaghetti` directory somewhere in your `package.path`.

Project structure example:

```text
my-project/
│
├── expaghetti/
│   ├── expaghetti.lua
│   ├── src/
│   └── ...
│
└── main.lua
```

Then simply require it:

```lua
local exp = require("expaghetti")
```

If necessary, extend `package.path` first:

```lua
package.path = "./?/?.lua;" .. package.path
local exp = require("expaghetti")
```

</details>

<details>
  <summary>
    <h3>With Luvit</h3>
  </summary>

Luvit uses a different module resolution strategy than standard Lua.

You can easily install Expaghetti using the `lit` package manager:

```sh
lit install Lautenschlager-id/expaghetti
```

Alternatively, to generate a Luvit-compatible distribution from source, run the build script:

**Windows**

```bat
scripts\luvit\build.bat
```

**Linux / macOS**

```sh
./scripts/luvit/build.sh
```

The build creates a `dist/` directory containing a transformed copy of the library.

Copy the generated `expaghetti` directory into your project:

```text
dist/
└── expaghetti/
    ├── init.lua
    ├── src/
    └── ...
```

↓

```text
my-project/
│
├── expaghetti/
│   ├── init.lua
│   ├── src/
│   └── ...
│
└── main.lua
```

Then require it normally:

```lua
local exp = require("expaghetti")
```

The build process automatically rewrites Expaghetti's internal module imports for Luvit's module loader, so your application code remains identical to the standard Lua version.

</details>

## Quick Example

```lua
local exp = require("expaghetti")

local result = exp.match(
    "My email is john@example.com",
    "(?<user>%a+)@(?<domain>[%w.]+)"
)

print(result.group.user)     --> john
print(result.group.domain)   --> example.com
```

## Installing into the String Library

Expaghetti can optionally replace Lua's standard pattern-matching functions with regex-powered implementations.

```lua
local exp = require("expaghetti")

exp:install()

local startPos, endPos =
    string.find("hello world", "(?<=hello )world")
```

> [!WARNING]
> Installing Expaghetti monkey-patches Lua's global `string` library.
>
> After installation, the affected functions use Expaghetti's regular expression syntax, parameters, and return values instead of Lua's native pattern matching behavior.
>
> This is intended as a convenience feature for applications and should be used carefully in shared codebases and avoided in libraries.

## Why Expaghetti?

Lua patterns are intentionally simple and extremely fast.

However, many applications eventually need features such as:

- Lookarounds
- Named groups
- Recursion
- Backreferences
- Atomic groups
- Unicode-aware matching
- Advanced replacement templates

Expaghetti brings those capabilities to Lua while remaining entirely self-contained.

## Compatibility

Expaghetti is implemented in pure Lua.

It has no native dependencies and is designed to work anywhere a compatible Lua interpreter is available.

## Contributing

Bug reports, feature requests, documentation improvements, and pull requests are always welcome.

If you've found an issue or have an idea for improvement, feel free to open one.
