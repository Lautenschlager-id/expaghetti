--[[
    API: split
]]

local matcher = require("matcher.init")
local string_sub = string.sub
local math_max = math.max
local type = type

local utils = require("helpers.api")

return function(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = utils.compilePattern(pattern, flags, config)
	if err then
		return nil, err
	end
	local parts = {}
	local partCount = 0
	local currentIndex = (start or 1) - 1
	local targetLength = #targetString
	local lastCopied = 0

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then
			return nil, "Expaghetti Error: " .. matchStart
		end
		if not hasMatched then
			break
		end

		partCount = partCount + 1
		parts[partCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		lastCopied = math_max(lastCopied, matchEnd)
		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd
		end
	end

	partCount = partCount + 1
	parts[partCount] = string_sub(targetString, lastCopied + 1)
	return parts
end
