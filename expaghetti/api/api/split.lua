--[[
    API: split
]]

--[[ Globals ]]--
local math_max = math.max
local string_sub = string.sub

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

	local slices = {}
	local sliceCount = 0

	local currentIndex = (startPosition or 1) - 1
	
	local lastCopied = 0
	
	local targetLength = #targetString
	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd = matcher(tree, targetString, parsedFlags, currentIndex, config)
		if not hasMatched then
			if matchStart then
				return nil, "Expaghetti Error: " .. matchStart
			end
			break
		end

		sliceCount = sliceCount + 1
		slices[sliceCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		lastCopied = math_max(lastCopied, matchEnd)
		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd
		end
	end

	sliceCount = sliceCount + 1
	slices[sliceCount] = string_sub(targetString, lastCopied + 1)

	return slices
end
