--[[
    Iterates over every occurrence of a pattern in a target string.

    Provides a lazy matching API that yields match objects one
    at a time.
]]

--[[ Globals ]]--
local math_max = math.max

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local ApiHelpers = require("helpers.api")
local matcher = require("matcher.init")

--[[ Aliases ]]--
local compilePattern = ApiHelpers.compilePattern
local buildMatchObject = ApiHelpers.buildMatchObject

local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsTable = Assertion.isTable

--[[ Module ]]--

--- Iterates over every occurrence of a pattern in a target string.
--- Returns an iterator that yields one match object per successful
--- match until no further matches are found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|table|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@param config EngineConfig The engine configuration.
---@return fun(): Match|nil, string|nil iterator The match iterator.
return function(pattern, targetString, flags, startPosition, config)
	AssertionIsStringOrTable(pattern, "pattern")
	AssertionIsString(targetString, "targetString")
	AssertionIsStringOrTable(flags, "flags", true)
	AssertionIsNumber(startPosition, "startPosition", true)
	AssertionIsTable(config, "config")

	local tree, parsedFlags, errorMessage = compilePattern(pattern, flags, config)
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

