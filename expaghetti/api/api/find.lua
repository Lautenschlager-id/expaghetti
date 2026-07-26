--[[
	Finds the first occurrence of a pattern in a target string.

	Implements a lightweight search API that returns only the
	boundaries of the first match.
]]

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local matcher = require("matcher.init")

--[[ Aliases ]]--
local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable

--[[ Module ]]--
return function(config, compilePattern)
	--- Finds the first occurrence of a pattern in a target string.
	--- Returns the start and end positions of the first match, or nil if
	--- no match is found.
	---@param pattern string|Pattern The pattern to search for.
	---@param targetString string The string to search.
	---@param flags string|table|nil Optional regular expression flags.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return integer|nil matchStart The starting position of the match.
	---@return integer|string|nil matchEndOrError The ending position of the match, or an error message.
	return function(pattern, targetString, flags, startPosition)
		AssertionIsStringOrTable(pattern, "pattern")
		AssertionIsString(targetString, "targetString")
		AssertionIsStringOrTable(flags, "flags", true)
		AssertionIsNumber(startPosition, "startPosition", true)

		local tree, parsedFlags, errorMessage = compilePattern(pattern, flags)
		if errorMessage then
			return nil, errorMessage
		end

		local currentIndex = (startPosition or 1) - 1
		local hasMatched, matchStart, matchEnd = matcher(tree, targetString, parsedFlags, currentIndex, config)

		if hasMatched then
			return matchStart, matchEnd
		elseif matchStart then
			return nil, matchStart
		end
		return nil
	end
end