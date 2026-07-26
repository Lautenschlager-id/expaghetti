--[[
	Compiled regular expression.

	Represents a reusable compiled pattern created by `Engine:compile()`.
	Once compiled, the pattern can be matched against multiple target
	strings without reparsing the original regular expression.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Api = require("api.init")

--[[ Module ]]--
local Pattern = {}
Pattern.__index = Pattern

--- Creates a compiled pattern.
--- Constructs a Pattern from a parsed regular expression and its
--- associated flags.
---@param tree AST The parsed regular expression.
---@param flags RegexFlag[] The compiled regular expression flags.
---@param config EngineConfig The engine configuration.
---@return Pattern pattern The compiled pattern.
function Pattern.new(tree, flags, config)
	return setmetatable({
		tree = tree,
		flags = flags,
		config = config
	}, Pattern)
end

--- Tests whether this pattern matches a target string.
--- Returns true if a match is found, or false otherwise.
---@param targetString string The string to search.
---@param startPosition integer|nil The position at which to begin searching.
---@return boolean|nil matched Whether a match was found.
---@return string|nil errorMessage The matching error message.
function Pattern:test(targetString, startPosition)
	return Api.test(self.tree, targetString, self.flags, startPosition, self.config)
end

--- Finds the first occurrence of this pattern in a target string.
--- Returns a match object describing the match and its captures,
--- or nil if no match is found.
---@param targetString string The string to search.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match|nil match The first match found.
---@return string|nil errorMessage The matching error message.
function Pattern:match(targetString, startPosition)
	return Api.match(self.tree, targetString, self.flags, startPosition, self.config)
end

--- Finds every occurrence of this pattern in a target string.
--- Returns an array containing every match found in search order.
---@param targetString string The string to search.
---@param startPosition integer|nil The position at which to begin searching.
---@return Match[]|nil matches All matches found.
---@return string|nil errorMessage The matching error message.
function Pattern:matchAll(targetString, startPosition)
	return Api.matchAll(self.tree, targetString, self.flags, startPosition, self.config)
end

--- Iterates over every occurrence of this pattern in a target string.
--- Returns an iterator that yields one match object per successful
--- match until no further matches are found.
---@param targetString string The string to search.
---@param startPosition integer|nil The position at which to begin searching.
---@return fun(): Match|nil iterator The match iterator.
---@return string|nil errorMessage The matching error message.
function Pattern:gmatch(targetString, startPosition)
	return Api.gmatch(self.tree, targetString, self.flags, startPosition, self.config)
end

--- Finds the first occurrence of this pattern in a target string.
--- Returns the start and end positions of the first match,
--- or nil if no match is found.
---@param targetString string The string to search.
---@param startPosition integer|nil The position at which to begin searching.
---@return integer|nil matchStart The starting position of the match.
---@return integer|string|nil matchEndOrError The ending position of the match, or an error message.
function Pattern:find(targetString, startPosition)
	return Api.find(self.tree, targetString, self.flags, startPosition, self.config)
end

--- Replaces the first occurrence of this pattern in a target string.
--- Supports replacement strings, callback functions, and lookup
--- tables. At most one replacement is performed.
---@param targetString string The string to search.
---@param replacement string|function|table The replacement specification.
---@param startPosition integer|nil The position at which to begin searching.
---@return string|nil result The resulting string.
---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
function Pattern:replace(targetString, replacement, startPosition)
	return Api.replace(self.tree, targetString, replacement, self.flags, startPosition, self.config, 1)
end

--- Replaces occurrences of this pattern in a target string.
--- Supports replacement strings, callback functions, and lookup
--- tables. Replacements continue until no further matches are found
--- or the specified limit is reached.
---@param targetString string The string to search.
---@param replacement string|function|table The replacement specification.
---@param limit integer|nil The maximum number of replacements to perform. If nil, all matches are replaced.
---@param startPosition integer|nil The position at which to begin searching.
---@return string|nil result The resulting string.
---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
function Pattern:gsub(targetString, replacement, limit, startPosition)
	return Api.replace(self.tree, targetString, replacement, self.flags, startPosition, self.config, limit)
end

--- Splits a target string using this pattern as the delimiter.
--- Returns an array containing the resulting substrings.
---@param targetString string The string to split.
---@param startPosition integer|nil The position at which to begin searching.
---@return string[]|nil slices The resulting substrings.
---@return string|nil errorMessage The matching error message.
function Pattern:split(targetString, startPosition)
	return Api.split(self.tree, targetString, self.flags, startPosition, self.config)
end

return Pattern
