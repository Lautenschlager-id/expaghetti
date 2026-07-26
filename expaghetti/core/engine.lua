--[[
    Expaghetti regular expression engine.

    Stores the engine configuration and exposes the primary API for
    compiling patterns, searching, matching, replacing, and splitting
    strings using regular expressions.
]]

--[[ Globals ]]--
local setmetatable = setmetatable
local string_format = string.format

--[[ Dependencies ]]--
local Api = require("api.init")
local compilePattern = require("helpers.api").compilePattern
local ConfigNew = require("core.config").new
local Pattern = require("core.pattern")

--[[ Module ]]--
local Engine = {}
Engine.__index = Engine

--- Creates a new regular expression engine.
--- Builds an engine instance using the provided configuration. All
--- patterns compiled or executed through the engine inherit these
--- configuration options.
---@param config EngineConfig|nil The engine configuration.
---@return Engine engine The created engine.
function Engine.new(config)
	return setmetatable({
		config = ConfigNew(config),
	}, Engine)
end

--- Compiles a regular expression into a reusable pattern.
--- Parses and validates the pattern, returning a compiled Pattern
--- instance that can be reused across multiple matching operations.
---@param regex string The regular expression to compile.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@return Pattern|nil pattern The compiled pattern.
---@return string|nil errorMessage The compilation error message, if compilation fails.
function Engine:compile(regex, flags)
	local tree, parsedFlags, errorMessage = compilePattern(regex, flags, self.config)
	if not tree then
		return nil, errorMessage
	end
	return Pattern.new(tree, parsedFlags, self.config)
end

--- Tests whether a pattern matches a target string.
--- Returns true if a match is found, or false otherwise.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return boolean|nil matched Whether a match was found.
---@return string|nil errorMessage The compilation or matching error message.
function Engine:test(pattern, string, flags, start)
	return Api.test(pattern, string, flags, start, self.config)
end

--- Finds the first occurrence of a pattern in a target string.
--- Returns a match object describing the match and its captures,
--- or nil if no match is found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match|nil match The first match found.
---@return string|nil errorMessage The compilation or matching error message.
function Engine:match(pattern, string, flags, start)
	return Api.match(pattern, string, flags, start, self.config)
end

--- Finds every occurrence of a pattern in a target string.
--- Returns an array containing every match found in search order.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match[]|nil matches All matches found.
---@return string|nil errorMessage The compilation or matching error message.
function Engine:matchAll(pattern, string, flags, start)
	return Api.matchAll(pattern, string, flags, start, self.config)
end

--- Iterates over every occurrence of a pattern in a target string.
--- Returns an iterator that yields one match object per successful
--- match until no further matches are found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return fun(): Match|nil iterator The match iterator.
---@return string|nil errorMessage The compilation or matching error message.
function Engine:gmatch(pattern, string, flags, start)
	return Api.gmatch(pattern, string, flags, start, self.config)
end

--- Finds the first occurrence of a pattern in a target string.
--- Returns the start and end positions of the first match,
--- or nil if no match is found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return integer|nil matchStart The starting position of the match.
---@return integer|string|nil matchEndOrError The ending position of the match, or an error message.
function Engine:find(pattern, string, flags, start)
	return Api.find(pattern, string, flags, start, self.config)
end

--- Replaces the first occurrence of a pattern in a target string.
--- Supports replacement strings, callback functions, and lookup
--- tables. At most one replacement is performed.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param replacement string|function|table The replacement specification.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return string|nil result The resulting string.
---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
function Engine:replace(pattern, string, replacement, flags, start)
	return Api.replace(pattern, string, replacement, flags, start, self.config, 1)
end

--- Replaces occurrences of a pattern in a target string.
--- Supports replacement strings, callback functions, and lookup
--- tables. Replacements continue until no further matches are found
--- or the specified limit is reached.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param replacement string|function|table The replacement specification.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param limit integer|nil The maximum number of replacements to perform. If nil, all matches are replaced.
---@param startPosition integer|nil The position at which to begin searching.
---@return string|nil result The resulting string.
---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
function Engine:gsub(pattern, string, replacement, flags, limit, start)
	return Api.replace(pattern, string, replacement, flags, start, self.config, limit)
end

--- Splits a target string using a pattern as the delimiter.
--- Returns an array containing the resulting substrings.
---@param pattern string|Pattern The delimiter pattern.
---@param targetString string The string to split.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return string[]|nil slices The resulting substrings.
---@return string|nil errorMessage The compilation or matching error message.
function Engine:split(pattern, string, flags, start)
	return Api.split(pattern, string, flags, start, self.config)
end

--- Installs Expaghetti's string library extensions.
--- Replaces supported functions in Lua's string library with
--- Expaghetti-backed implementations while preserving the originals.
Engine.install = Api.installHooks.install

--- Restores Lua's original string library.
--- Removes all installed extensions and restores the functions
--- that were present before installation.
Engine.uninstall = Api.installHooks.uninstall

return Engine
