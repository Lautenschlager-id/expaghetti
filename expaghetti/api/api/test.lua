--[[
    Tests whether a pattern matches a target string.

    Implements a boolean matching API for efficiently checking
    whether a match exists.
]]

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local compilePattern = require("helpers.api").compilePattern
local matcher = require("matcher.init")

--[[ Aliases ]]--
local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsTable = Assertion.isTable

--[[ Module ]]--

--- Tests whether a pattern matches a target string.
--- Returns true if a match is found, false otherwise.
---@param pattern string|Pattern The pattern to search for.
---@param targetString string The string to search.
---@param flags string|table|nil Optional regular expression flags.
---@param startPosition integer|nil The position at which to begin searching.
---@param config EngineConfig The engine configuration.
---@return boolean|nil matched Whether a match was found.
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
	local hasMatched, errorMessage = matcher(tree, targetString, parsedFlags, currentIndex, config)

	if hasMatched == false and errorMessage then
		return nil, errorMessage
	end
	return hasMatched == true
end
