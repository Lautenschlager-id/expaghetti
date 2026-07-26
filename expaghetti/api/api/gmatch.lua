--[[
	Iterates over every occurrence of a pattern in a target string.

	Provides a lazy matching API that yields match objects one
	at a time.
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
	--- Iterates over every occurrence of a pattern in a target string.
	--- Returns an iterator that yields one match object per successful
	--- match until no further matches are found.
	---@param pattern string|Pattern The pattern to search for.
	---@param targetString string The string to search.
	---@param flags string|table|nil Optional regular expression flags.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return fun(): Match|nil, string|nil iterator The match iterator.
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

		local targetLength = #targetString
		return function()
			if currentIndex > targetLength then
				return nil
			end

			local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)
			if hasMatched then
				if matchEnd < matchStart then
					currentIndex = math_max(currentIndex + 1, matchStart)
				else
					currentIndex = matchEnd
				end

				return buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
			elseif matchStart then
				return nil, matchStart
			end
			return nil
		end
	end
end