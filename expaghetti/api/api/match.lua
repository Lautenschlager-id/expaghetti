--[[
    API: match
]]

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
return function(pattern, targetString, flags, startPosition, config)
	AssertionIsString(pattern, "pattern")
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
		return nil, "Expaghetti Error: " .. matchStart
	end
	return nil
end
