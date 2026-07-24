--[[
    Shared API Utilities.
]]

local string_byte = string.byte
local string_sub = string.sub
local table_sort = table.sort
local type = type
local pairs = pairs
local tostring = tostring

local parser = require("parser.init")

local ApiUtils = {}

function ApiUtils.normalizeFlags(flags)
	if not flags then
		return {}
	end

	local flagType = type(flags)
	if flagType == "table" then
		local normalized = {}
		for key, value in pairs(flags) do
			if type(key) == "number" and type(value) == "string" then
				normalized[value] = true
			elseif type(key) == "string" and value then
				normalized[key] = true
			end
		end
		return normalized
	elseif flagType == "string" then
		local normalized = {}
		local flagsLength = #flags
		for charIndex = 1, flagsLength do
			normalized[string_sub(flags, charIndex, charIndex)] = true
		end
		return normalized
	end

	return {}
end

local table_concat = table.concat
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

function ApiUtils.compilePattern(pattern, flags)
	if type(pattern) == "string" then
		flags = ApiUtils.normalizeFlags(flags)
		local cacheKey = pattern .. "\0" .. getFlagsKey(flags)
		
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
	end
	return pattern, flags, nil
end

function ApiUtils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
	local matchObj = {
		start = matchStart,
		finish = matchEnd,
		value = string_sub(targetString, matchStart, matchEnd),
		captures = {},
		groups = {},
	}

	if matcherMetadata and matcherMetadata.captureStarts then
		local captureStarts = matcherMetadata.captureStarts
		local captureEnds = matcherMetadata.captureEnds
		local captureCounts = matcherMetadata.captureCounts
		local groupNames = matcherMetadata.groupNames or {}

		local capCount = 0
		for groupKey, count in pairs(captureCounts) do
			if count > 0 then
				local isNamed = type(groupKey) == "string"
				local groupName = isNamed and groupKey or nil

				local groupArr = {}
				matchObj.groups[groupKey] = groupArr

				for i = 1, count do
					local cStart = captureStarts[groupKey][i]
					local cEnd = captureEnds[groupKey][i]

					local capObj = {
						groupIndex = groupKey,
						start = cStart,
						finish = cEnd,
						value = string_sub(targetString, cStart, cEnd)
					}
					if groupName then
						capObj.name = groupName
					end

					groupArr[i] = capObj
					capCount = capCount + 1
					matchObj.captures[capCount] = capObj
				end
			end
		end

		table_sort(matchObj.captures, function(a, b)
			if a.finish ~= b.finish then
				return a.finish < b.finish
			end
			return a.start > b.start
		end)
	end
	
	return matchObj
end

return ApiUtils
