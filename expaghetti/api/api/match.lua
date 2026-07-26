--[[
	Finds the first occurrence of a pattern in a target string.

	Returns a match object describing the match and its captures,
	or nil if no match is found.
]]

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local ApiHelpers = require("helpers.api")
local matcher = require("matcher.init")

--[[ Aliases ]]--
local buildMatchObject = ApiHelpers.buildMatchObject
local compilePattern = ApiHelpers.compilePattern

local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsTable = Assertion.isTable

--[[ Module ]]--

--- Finds the first occurrence of a pattern in a target string.
--- Compiles the pattern if necessary and returns the first match as a
--- structured match object. Returns nil if no match is found.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|table|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@param config EngineConfig The engine configuration.
---@return Match|nil match The first match found, or nil if no match exists.
---@return string|nil errorMessage The compilation or matching error message.
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
	local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)

	if hasMatched then
		return buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
	elseif matchStart then
		return nil, matchStart
	end
	return nil
end
