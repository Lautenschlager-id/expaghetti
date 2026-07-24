--[[
    Public API wrapper functions.
]]

--[[ Globals ]]--
local string_byte = string.byte
local string_sub = string.sub
local table_concat = table.concat
local table_sort = table.sort
local math_max = math.max
local tostring = tostring
local type = type
local pairs = pairs

--[[ Dependencies ]]--
local matcher = require("matcher.init")
local parser = require("parser.init")
local ESCAPE = require("enums.magic").ESCAPE

--[[ Constants ]]--
local BYTE_0 = string_byte('0')
local BYTE_9 = string_byte('9')
local BYTE_ESCAPE = string_byte(ESCAPE)

--[[ Module ]]--
local Api = {}

local function compilePattern(pattern, flags)
	if type(pattern) == "string" then
		flags = Api.normalizeFlags(flags)
		local tree, err = parser(pattern, flags)
		if not tree then
			return nil, nil, "Expaghetti Error: " .. tostring(err)
		end
		return tree, flags, nil
	end
	return pattern, flags, nil
end

--[[ Flags Normalization ]]--

--- Normalizes flags from string, array, or dictionary form into a lookup table.
---@param flags string|table|nil
---@return table normalizedFlags A table of { [flagChar] = true } entries.
function Api.normalizeFlags(flags)
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

--[[ Helpers ]]--

local function buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
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
				-- Determine if this is a named group
				-- Named groups use their string name as the key in captureCounts
				local isNamed = type(groupKey) == "string"
				local groupName = isNamed and groupKey or nil

				local groupArr = {}
				matchObj.groups[groupKey] = groupArr
				-- Named groups also get an alias: groups["foo"] = groups[numericIndex]
				-- But since the key IS the name, we don't need a numeric alias here

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

local function applyTemplate(template, matchObj)
	local templateLength = #template
	local segments = {}
	local segmentCount = 0
	local segmentStart = 1

	local templateIndex = 1
	while templateIndex <= templateLength do
		local currentByte = string_byte(template, templateIndex)

		if currentByte == BYTE_ESCAPE and templateIndex < templateLength then
			local nextByte = string_byte(template, templateIndex + 1)
			if nextByte >= BYTE_0 and nextByte <= BYTE_9 then
				if templateIndex > segmentStart then
					segmentCount = segmentCount + 1
					segments[segmentCount] = string_sub(template, segmentStart, templateIndex - 1)
				end

				local groupIndex = nextByte - BYTE_0
				segmentCount = segmentCount + 1
				if groupIndex == 0 then
					segments[segmentCount] = matchObj.value
				else
					local groupArr = matchObj.groups[groupIndex]
					if groupArr and #groupArr > 0 then
						segments[segmentCount] = groupArr[#groupArr].value
					else
						segments[segmentCount] = ""
					end
				end

				templateIndex = templateIndex + 2
				segmentStart = templateIndex
			else
				templateIndex = templateIndex + 1
			end
		else
			templateIndex = templateIndex + 1
		end
	end

	if segmentStart <= templateLength then
		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(template, segmentStart, templateLength)
	end

	return table_concat(segments, "", 1, segmentCount)
end

--[[ API Implementation ]]--

function Api.test(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
	if err then return nil, err end
	local currentIndex = (start or 1) - 1
	local hasMatched, matchErr = matcher(pattern, targetString, flags, currentIndex, config)
	if hasMatched == false and type(matchErr) == "string" then return nil, "Expaghetti Error: " .. matchErr end
	return hasMatched == true
end

function Api.match(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
	if err then return nil, err end
	local currentIndex = (start or 1) - 1
	local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
	if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
	if hasMatched then
		return buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
	end
	return nil
end

function Api.matchAll(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
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
		results[resultCount] = buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)

		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd
		end
	end

	return results
end

function Api.gmatch(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
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

			return buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
		end

		return nil
	end
end

function Api.find(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
	if err then return nil, err end
	local currentIndex = (start or 1) - 1
	local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, flags, currentIndex, config)
	if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
	if hasMatched then
		return matchStart, matchEnd
	end
	return nil
end

function Api.replace(pattern, targetString, replacement, flags, start, config, limit)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
	if err then return nil, err end
	local segments = {}
	local segmentCount = 0
	local currentIndex = (start or 1) - 1
	local targetLength = #targetString
	local lastCopied = 0
	local replaceCount = 0
	local replacementType = type(replacement)

	while currentIndex <= targetLength do
		if limit and replaceCount >= limit then
			break
		end
		
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
		if not hasMatched then
			break
		end

		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		local matchObj = buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)

		if replacementType == "string" then
			segmentCount = segmentCount + 1
			segments[segmentCount] = applyTemplate(replacement, matchObj)
		elseif replacementType == "function" then
			local substitution = replacement(matchObj)
			segmentCount = segmentCount + 1
			if substitution ~= nil then
				segments[segmentCount] = tostring(substitution)
			else
				segments[segmentCount] = matchObj.value
			end
		elseif replacementType == "table" then
			local lookupKey = matchObj.value
			if matchObj.groups[1] and #matchObj.groups[1] > 0 then
				lookupKey = matchObj.groups[1][#matchObj.groups[1]].value
			end
			
			local substitution = replacement[lookupKey]
			segmentCount = segmentCount + 1
			if substitution ~= nil then
				segments[segmentCount] = tostring(substitution)
			else
				segments[segmentCount] = matchObj.value
			end
		end

		replaceCount = replaceCount + 1

		lastCopied = math_max(lastCopied, matchEnd)
		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd
		end
	end

	segmentCount = segmentCount + 1
	segments[segmentCount] = string_sub(targetString, lastCopied + 1)
	
	return table_concat(segments, "", 1, segmentCount), replaceCount
end

function Api.split(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = compilePattern(pattern, flags)
	if err then return nil, err end
	local parts = {}
	local partCount = 0
	local currentIndex = (start or 1) - 1
	local targetLength = #targetString
	local lastCopied = 0

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
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

return Api
