--[[
	Splits a target string using a pattern as the delimiter.

	Returns the unmatched portions of the string separated by
	each pattern match.
]]

--[[ Globals ]]--
local math_max = math.max
local string_sub = string.sub

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local matcher = require("matcher.init")

--[[ Aliases ]]--
local AssertionIsNumber = Assertion.isNumber
local AssertionIsString = Assertion.isString
local AssertionIsStringOrTable = Assertion.isStringOrTable

--[[ Module ]]--
return function(config, compilePattern)
	--- Splits a target string using a pattern as the delimiter.
	--- Returns an array containing the resulting substrings.
	---@param pattern string|Pattern The delimiter pattern.
	---@param targetString string The string to split.
	---@param flags string|table|nil Optional regular expression flags.
	---@param startPosition integer|nil The position at which to begin searching.
	---@return string[]|nil slices The resulting substrings.
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

		local slices = {}
		local sliceCount = 0

		local currentIndex = (startPosition or 1) - 1

		local lastCopied = 0

		local targetLength = #targetString
		while currentIndex <= targetLength do
			local hasMatched, matchStart, matchEnd = matcher(tree, targetString, parsedFlags, currentIndex, config)
			if not hasMatched then
				if matchStart then
					return nil, matchStart
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
end