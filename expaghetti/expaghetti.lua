--[[
	Expaghetti public API.

	Provides a default regular expression engine for convenient
	one-off operations, while also exposing the constructors and
	enumerations required to create and configure custom engines.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local API = require("api.init")
local ConfigNew = require("core.config").new
local installHooks = require("api.api.installHooks")

--[[ Enums ]]--
local ApiEnums = require("api.enums")

--[[ Aliases ]]--
local AssertionIsTable = require("helpers.assertion").isTable

--[[ Module ]]--
local Expaghetti = {
	Flag = ApiEnums.Flag,
}
Expaghetti.__index = Expaghetti

Expaghetti = setmetatable(Expaghetti, {
	__call = function(self, config)
		return setmetatable(
			API(ConfigNew(config)),
			self
		)
	end
})

local default = Expaghetti()

--- Creates a custom API instance.
---@param config APIConfig|nil The API configuration.
---@return API api The configured API instance.
Expaghetti.custom = function(config)
	AssertionIsTable(config)
	return Expaghetti(config)
end

--- Compiles a regular expression into a reusable pattern.
--- Parses and validates the pattern, returning a compiled Pattern
--- instance that can be reused across multiple matching operations.
---@param regex string The regular expression to compile.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@return Pattern|nil pattern The compiled pattern.
---@return string|nil errorMessage The compilation error message, if compilation fails.
Expaghetti.compile = default.compile

--- Tests whether a pattern matches a target string.
--- Returns true if a match is found, or false otherwise.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return boolean|nil matched Whether a match was found.
---@return string|nil errorMessage The compilation or matching error message.
Expaghetti.test = default.test

--- Finds the first occurrence of a pattern in a target string.
--- Returns a match object describing the match and its captures,
--- or nil if no match is found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match|nil match The first match found.
---@return string|nil errorMessage The compilation or matching error message.
Expaghetti.match = default.match

--- Finds every occurrence of a pattern in a target string.
--- Returns an array containing every match found in search order.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match[]|nil matches All matches found.
---@return string|nil errorMessage The compilation or matching error message.
Expaghetti.matchAll = default.matchAll

--- Iterates over every occurrence of a pattern in a target string.
--- Returns an iterator that yields one match object per successful
--- match until no further matches are found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return fun(): Match|nil iterator The match iterator.
---@return string|nil errorMessage The compilation or matching error message.
Expaghetti.gmatch = default.gmatch

--- Finds the first occurrence of a pattern in a target string.
--- Returns the start and end positions of the first match,
--- or nil if no match is found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return integer|nil matchStart The starting position of the match.
---@return integer|string|nil matchEndOrError The ending position of the match, or an error message.
Expaghetti.find = default.find

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
Expaghetti.replace = default.replace

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
Expaghetti.gsub = default.gsub

--- Splits a target string using a pattern as the delimiter.
--- Returns an array containing the resulting substrings.
---@param pattern string|Pattern The delimiter pattern.
---@param targetString string The string to split.
---@param flags string|RegexFlag[]|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@return string[]|nil slices The resulting substrings.
---@return string|nil errorMessage The compilation or matching error message.
Expaghetti.split = default.split

--- Installs Expaghetti's string library extensions.
--- Replaces supported functions in Lua's string library with
--- Expaghetti-backed implementations while preserving the originals.
Expaghetti.install = function(self)
	return installHooks.install(self)
end

--- Restores Lua's original string library.
--- Removes all installed extensions and restores the functions
--- that were present before installation.
Expaghetti.uninstall = installHooks.uninstall

return Expaghetti
