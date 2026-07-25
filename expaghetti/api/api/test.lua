--[[
    API: test
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
		return nil, "Expaghetti Error: " .. errorMessage
	end
	return hasMatched == true
end
