--[[
	Finds the first occurrence of a pattern in a target string.

	Returns a match object describing the match and its captures,
	or nil if no match is found.
]]

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local buildMatchObject = require("helpers.api").buildMatchObject
local matcher = require("matcher.init")

--[[ Aliases ]]--
local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable

--[[ Module ]]--
return function(config, compilePattern)
	--- Finds the first occurrence of a pattern in a target string.
	--- Compiles the pattern if necessary and returns the first match as a
	--- structured match object. Returns nil if no match is found.
	---@param pattern string|Pattern The pattern to search for.
	---@param targetString string The string to search.
	---@param flags string|table|nil Optional regular expression flags.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return Match|nil match The first match found, or nil if no match exists.
	---@return string|nil errorMessage The compilation or matching error message.
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
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)

		if hasMatched then
			return buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
		elseif matchStart then
			return nil, matchStart
		end
		return nil
	end
end