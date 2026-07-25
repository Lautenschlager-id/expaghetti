--[[
    API: find
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
	local hasMatched, matchStart, matchEnd = matcher(tree, targetString, parsedFlags, currentIndex, config)
	
	if hasMatched then
		return matchStart, matchEnd
	elseif matchStart then
		return nil, "Expaghetti Error: " .. matchStart
	end
	return nil
end
