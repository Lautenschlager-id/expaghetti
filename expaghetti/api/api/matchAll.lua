--[[
	Finds every occurrence of a pattern in a target string.

	Executes repeated searches and returns every match as a
	structured match object.
]]

--[[ Globals ]]--
local math_max = math.max

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
	--- Finds every occurrence of a pattern in a target string.
	--- Returns an array containing every match found in search order.
	---@param pattern string|Pattern The pattern to search for.
	---@param targetString string The string to search.
	---@param flags string|table|nil Optional regular expression flags.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return Match[]|nil matches All matches found.
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

		local results = {}
		local resultCount = 0

		local currentIndex = (startPosition or 1) - 1

		local targetLength = #targetString
		while currentIndex <= targetLength do
			local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)
			if not hasMatched then
				if matchStart then
					return nil, matchStart
				end
				break
			end

			resultCount = resultCount + 1
			results[resultCount] = buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)

			if matchEnd < matchStart then
				currentIndex = math_max(currentIndex + 1, matchStart)
			else
				currentIndex = matchEnd
			end
		end

		return results
	end
end