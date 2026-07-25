--[[
    API: matchAll and gmatch
]]

local matcher = require("matcher.init")
local math_max = math.max
local type = type

local utils = require("helpers.api")

local function matchAll(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = utils.compilePattern(pattern, flags, config)
	if err then return nil, err end
	local results = {}
	local resultCount = 0
	local currentIndex = (start or 1) - 1
	local targetLength = #targetString

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
		if not hasMatched then
			break
		end

		resultCount = resultCount + 1
		results[resultCount] = utils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)

		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd
		end
	end

	return results
end

local function gmatch(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = utils.compilePattern(pattern, flags, config)
	if err then return nil, err end
	local currentIndex = (start or 1) - 1
	local targetLength = #targetString

	return function()
		if currentIndex > targetLength then
			return nil
		end

		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
		if hasMatched then
			if matchEnd < matchStart then
				currentIndex = math_max(currentIndex + 1, matchStart)
			else
				currentIndex = matchEnd
			end

			return utils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
		end

		return nil
	end
end

return { matchAll = matchAll, gmatch = gmatch }
