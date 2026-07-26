--[[
	Installs and removes Expaghetti's optional string library extensions.

	Allows Lua's string library to transparently use Expaghetti's
	regular expression implementation.
]]

--[[ Globals ]]--
local next = next
local string = string

--[[ Module ]]--
local originalStringModule, installApi

--- Installs Expaghetti's string library extensions.
--- Replaces selected functions in Lua's string library with
--- Expaghetti-backed implementations.
---@param api APIInstance The API instance.
local install = function(api)
	installApi = api
	if not originalStringModule then
		originalStringModule = {}
		for method, fn in next, string do
			originalStringModule[method] = fn
		end

		--- Tests whether a pattern matches a target string.
		--- Extends Lua's string library with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return boolean|nil matched Whether a match was found.
		---@return string|nil errorMessage The compilation or matching error message.
		string.test = function(targetString, pattern, flags, startPosition)
			return installApi.test(pattern, targetString, flags, startPosition)
		end

		--- Finds the first occurrence of a pattern in a target string.
		--- Extends Lua's string.match with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return Match|nil match The first match found.
		---@return string|nil errorMessage The compilation or matching error message.
		string.match = function(targetString, pattern, flags, startPosition)
			return installApi.match(pattern, targetString, flags, startPosition)
		end

		--- Finds every occurrence of a pattern in a target string.
		--- Extends Lua's string library with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return Match[]|nil matches All matches found.
		---@return string|nil errorMessage The compilation or matching error message.
		string.matchAll = function(targetString, pattern, flags, startPosition)
			return installApi.matchAll(pattern, targetString, flags, startPosition)
		end

		--- Iterates over every occurrence of a pattern in a target string.
		--- Extends Lua's string.gmatch with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return fun(): Match|nil iterator The match iterator.
		---@return string|nil errorMessage The compilation or matching error message.
		string.gmatch = function(targetString, pattern, flags, startPosition)
			return installApi.gmatch(pattern, targetString, flags, startPosition)
		end

		--- Finds the first occurrence of a pattern in a target string.
		--- Extends Lua's string.find with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return integer|nil matchStart The starting position of the match.
		---@return integer|string|nil matchEndOrError The ending position of the match, or an error message.
		string.find = function(targetString, pattern, flags, startPosition)
			return installApi.find(pattern, targetString, flags, startPosition)
		end

		--- Replaces the first occurrence of a pattern in a target string.
		--- Extends Lua's string library with support for regular expressions,
		--- callback replacements, lookup tables, optional flags, and a custom
		--- starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param replacement string|function|table The replacement specification.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return string|nil result The resulting string.
		---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
		string.replace = function(targetString, pattern, replacement, flags, startPosition)
			return installApi.replace(pattern, targetString, replacement, flags, startPosition)
		end

		--- Replaces occurrences of a pattern in a target string.
		--- Extends Lua's string.gsub with support for regular expressions,
		--- callback replacements, lookup tables, optional flags, a replacement
		--- limit, and a custom starting position.
		---@param targetString string The string to search.
		---@param pattern string|Pattern The pattern to search for.
		---@param replacement string|function|table The replacement specification.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param limit integer|nil The maximum number of replacements to perform. If nil, all matches are replaced.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return string|nil result The resulting string.
		---@return integer|string|nil replaceCountOrError The number of replacements performed, or an error message.
		string.gsub = function(targetString, pattern, replacement, flags, limit, startPosition)
			return installApi.gsub(pattern, targetString, replacement, flags, limit, startPosition)
		end

		--- Splits a target string using a pattern as the delimiter.
		--- Extends Lua's string library with support for regular expressions,
		--- optional flags, and a custom starting position.
		---@param targetString string The string to split.
		---@param pattern string|Pattern The delimiter pattern.
		---@param flags string|RegexFlag[]|nil Optional regular expression flags.
		---@param startPosition integer|nil The position at which to begin searching.
		---@return string[]|nil slices The resulting substrings.
		---@return string|nil errorMessage The compilation or matching error message.
		string.split = function(targetString, pattern, flags, startPosition)
			return installApi.split(pattern, targetString, flags, startPosition)
		end
	end
end

--- Restores Lua's original string library.
--- Removes all installed extensions and restores the functions
--- that were present before installation.
local uninstall = function()
	if not originalStringModule then
		return
	end

	for method, fn in next, originalStringModule do
		string[method] = fn
	end

	installApi = nil
end

return {
	install = install,
	uninstall = uninstall
}
