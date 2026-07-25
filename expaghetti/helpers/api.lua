--[[
    Shared API Utilities.
]]

--[[ Globals ]]--
local next = next
local string_byte = string.byte
local string_sub = string.sub
local table_concat = table.concat
local table_sort = table.sort
local tostring = tostring
local type = type

--[[ Dependencies ]]--
local parser = require("parser.init")

--[[ Enums ]]--
local Flags = require("api.enums").RegexFlag

--[[ Module ]]--
local ApiUtils = {}

function ApiUtils.normalizeFlags(flags)
	local normalized = {}

	local flagType, flagCount = type(flags), 0
	if flagType == "table" then
		for key, value in next, flags do
			if type(key) == "number" and type(value) == "string" then
				flagCount = flagCount + 1
				normalized[flagCount] = value
			elseif type(key) == "string" and value then
				flagCount = flagCount + 1
				normalized[flagCount] = key
			end
		end
	elseif flagType == "string" then
		flagCount = #flags
		for charIndex = 1, flagCount do
			normalized[charIndex] = string_sub(flags, charIndex, charIndex)
		end
	end

	local flags = {}
	for index = 1, flagCount do
		local flag = normalized[index]
		if Flags[flag] then
			flags[flag] = true
		end
	end
	return flags
end

local MAX_CACHE_SIZE = 100
local astCache = {}
local astQueue = {}
local astCacheSize = 0

local function getFlagsKey(normalizedFlags)
	local chars = {}
	for k, v in pairs(normalizedFlags) do
		if v then chars[#chars + 1] = k end
	end
	table_sort(chars)
	return table_concat(chars)
end

local function getConfigKey(config)
	if not config then return "" end
	return tostring(config.maxRecursionDepth) .. "\0" .. tostring(config.maxBacktrackDepth)
end

function ApiUtils.compilePattern(pattern, flags, config)
	local patternType = type(pattern)
	if patternType == "string" then
		flags = ApiUtils.normalizeFlags(flags)
		local cacheKey = pattern .. "\0" .. getFlagsKey(flags) .. "\0" .. getConfigKey(config)
		
		local cachedTree = astCache[cacheKey]
		if cachedTree then
			return cachedTree, flags, nil
		end

		local tree, err = parser(pattern, flags)
		if not tree then
			return nil, nil, "Expaghetti Error: " .. tostring(err)
		end
		
		if astCacheSize >= MAX_CACHE_SIZE then
			local oldestKey = table.remove(astQueue, 1)
			astCache[oldestKey] = nil
			astCacheSize = astCacheSize - 1
		end
		
		astCache[cacheKey] = tree
		table.insert(astQueue, cacheKey)
		astCacheSize = astCacheSize + 1
		
		return tree, flags, nil
	elseif patternType == "table" and pattern._index then
		return pattern, flags, nil
	end
	return nil, nil, "Expaghetti Error: Invalid pattern"
end

function ApiUtils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
	local match = {
		start = matchStart,
		stop = matchEnd,
		value = string_sub(targetString, matchStart, matchEnd),
		captures = {},
		groups = {},
	}

	if not matcherMetadata.captureStarts then
		return match
	end

	local captureStarts = matcherMetadata.captureStarts
	local captureEnds = matcherMetadata.captureEnds
	local captureCounts = matcherMetadata.captureCounts
	local groupNames = matcherMetadata.groupNames

	local matchGroups, matchCaptures = match.groups, match.captures

	local captureCount = 0
	for groupKey, groupCaptureCount in next, captureCounts do
		if groupCaptureCount > 0 then -- TO DO: Check if this can be false
			local isNamed = type(groupKey) == "string"
			local groupName = isNamed and groupKey or nil

			local groupArray = {}
			matchGroups[groupKey] = groupArray

			local captureStartsGroup = captureStarts[groupKey]
			local captureEndsGroup = captureEnds[groupKey]
			for captureIndex = 1, groupCaptureCount do
				local captureStart = captureStartsGroup[captureIndex]
				local captureEnd = captureEndsGroup[captureIndex]

				local captureObject = {
					groupIndex = groupKey,
					start = captureStart,
					stop = captureEnd,
					value = string_sub(targetString, captureStart, captureEnd),
					name = groupName,
				}

				groupArray[captureIndex] = captureObject
				captureCount = captureCount + 1 -- TO DO: Check if named groups should be added to matchCaptures
				matchCaptures[captureCount] = captureObject
			end
		end
	end

	table_sort(matchCaptures, function(captureOne, captureTwo)
		if captureOne.stop ~= captureTwo.stop then
			return captureOne.stop < captureTwo.stop
		end
		return captureOne.start > captureTwo.start
	end)
	
	return match
end

return ApiUtils
