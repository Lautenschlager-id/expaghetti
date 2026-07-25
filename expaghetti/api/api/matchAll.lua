--[[
    API: matchAll and gmatch
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

	local results = {}
	local resultCount = 0

	local currentIndex = (startPosition or 1) - 1

	local targetLength = #targetString
	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(tree, targetString, parsedFlags, currentIndex, config)
		if not hasMatched then
			if matchStart then
				return nil, "Expaghetti Error: " .. matchStart
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
