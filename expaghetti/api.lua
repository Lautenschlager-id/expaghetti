--[[
    Public API wrapper functions.
]]

--[[ Globals ]]--
local string_byte = string.byte
local string_sub = string.sub
local table_concat = table.concat
local math_max = math.max
local tostring = tostring
local type = type
local pairs = pairs
local unpack = unpack

--[[ Dependencies ]]--
local matcher = require("matcher.init")

--[[ Aliases ]]--
local ESCAPE = require("enums.magic").ESCAPE

--[[ Constants ]]--
local BYTE_0 = string_byte('0')
local BYTE_9 = string_byte('9')
local BYTE_ESCAPE = string_byte(ESCAPE)

--[[ Module ]]--
local Api = {}

--[[ Flags Normalization ]]--

--- Normalizes flags from string, array, or dictionary form into a lookup table.
---@param flags string|table|nil
---@return table normalizedFlags A table of { [flagChar] = true } entries.
local function normalizeFlags(flags)
	if not flags then
		return {}
	end

	local flagType = type(flags)
	if flagType == "table" then
		local normalized = {}
		for key, value in pairs(flags) do
			if type(key) == "number" and type(value) == "string" then
				-- Array of flag chars: { "i", "m" }
				normalized[value] = true
			elseif type(key) == "string" and value then
				-- Dictionary of flag chars: { i = true, m = true }
				normalized[key] = true
			end
		end
		return normalized
	elseif flagType == "string" then
		-- String of flag chars: "imu"
		local normalized = {}
		local flagsLength = #flags
		for charIndex = 1, flagsLength do
			normalized[string_sub(flags, charIndex, charIndex)] = true
		end
		return normalized
	end

	return {}
end

Api.normalizeFlags = normalizeFlags

--[[ Internal Helpers ]]--

--- Extracts captures from matcher metadata into a table keyed by group index/name.
---@param targetString string The original target string.
---@param matcherMetadata table|nil The metadata returned by the matcher.
---@return table captures The extracted captures.
local function extractCaptures(targetString, matcherMetadata)
	local captures = {}
	if matcherMetadata and matcherMetadata.captureStarts then
		local captureStarts = matcherMetadata.captureStarts
		local captureEnds = matcherMetadata.captureEnds
		local captureCounts = matcherMetadata.captureCounts
		for group, count in pairs(captureCounts) do
			if count > 0 then
				local captureStart = captureStarts[group][count]
				local captureEnd = captureEnds[group][count]
				captures[group] = string_sub(targetString, captureStart, captureEnd)
			end
		end
	end
	return captures
end

--- Applies a replacement template string, substituting %N references with captures.
--- Does NOT use Lua's string.gsub — manually scans for ESCAPE + digit sequences.
---@param template string The replacement template (e.g. "X%1Y").
---@param matchedStr string The full matched substring.
---@param captures table The captured groups.
---@return string result The substituted replacement string.
local function applyTemplate(template, matchedStr, captures)
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
				-- Flush any preceding literal segment
				if templateIndex > segmentStart then
					segmentCount = segmentCount + 1
					segments[segmentCount] = string_sub(template, segmentStart, templateIndex - 1)
				end

				local groupIndex = nextByte - BYTE_0
				if groupIndex == 0 then
					segmentCount = segmentCount + 1
					segments[segmentCount] = matchedStr
				else
					segmentCount = segmentCount + 1
					segments[segmentCount] = captures[groupIndex] or ""
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

	-- Flush remaining literal segment
	if segmentStart <= templateLength then
		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(template, segmentStart, templateLength)
	end

	return table_concat(segments, "", 1, segmentCount)
end

--[[ API Implementation ]]--

function Api.test(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local hasMatched = matcher(pattern, targetString, options, 0, config)
	return hasMatched == true
end

function Api.match(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, options, 0, config)

	if hasMatched then
		local captures = extractCaptures(targetString, matcherMetadata)
		return string_sub(targetString, matchStart, matchEnd), captures
	end
	return nil
end

function Api.matchAll(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local results = {}
	local resultCount = 0
	local currentIndex = 0
	local targetLength = #targetString

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, options, currentIndex, config)
		if not hasMatched then
			break
		end

		local captures = extractCaptures(targetString, matcherMetadata)

		resultCount = resultCount + 1
		results[resultCount] = {
			match = string_sub(targetString, matchStart, matchEnd),
			captures = captures,
			index = matchStart,
			lastIndex = matchEnd
		}

		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd + 1
		end
	end

	return results
end

function Api.gmatch(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local currentIndex = 0
	local targetLength = #targetString

	return function()
		if currentIndex > targetLength then
			return nil
		end

		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, options, currentIndex, config)

		if hasMatched then
			if matchEnd < matchStart then
				currentIndex = math_max(currentIndex + 1, matchStart)
			else
				currentIndex = matchEnd + 1
			end

			local captures = {}
			local numCaptures = 0
			if matcherMetadata and matcherMetadata.captureStarts then
				local captureStarts = matcherMetadata.captureStarts
				local captureEnds = matcherMetadata.captureEnds
				local captureCounts = matcherMetadata.captureCounts

				for group, count in pairs(captureCounts) do
					if count > 0 then
						local captureStart = captureStarts[group][count]
						local captureEnd = captureEnds[group][count]
						captures[group] = string_sub(targetString, captureStart, captureEnd)
						if type(group) == "number" and group > numCaptures then
							numCaptures = group
						end
					end
				end
			end

			if numCaptures > 0 then
				local unpacked = {}
				for captureIndex = 1, numCaptures do
					unpacked[captureIndex] = captures[captureIndex]
				end
				return unpack(unpacked)
			else
				return string_sub(targetString, matchStart, matchEnd)
			end
		end

		return nil
	end
end

function Api.find(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, options, 0, config)
	if hasMatched then
		return matchStart, matchEnd
	end
	return nil
end

function Api.replace(pattern, targetString, replacement, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local segments = {}
	local segmentCount = 0
	local currentIndex = 0
	local targetLength = #targetString
	local lastCopied = 0
	local replaceCount = 0
	local replacementType = type(replacement)

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, options, currentIndex, config)
		if not hasMatched then
			break
		end

		-- Copy the unmatched prefix
		segmentCount = segmentCount + 1
		segments[segmentCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		local captures = extractCaptures(targetString, matcherMetadata)
		local matchedStr = string_sub(targetString, matchStart, matchEnd)

		if replacementType == "string" then
			segmentCount = segmentCount + 1
			segments[segmentCount] = applyTemplate(replacement, matchedStr, captures)
		elseif replacementType == "function" then
			local substitution = replacement(matchedStr, captures)
			segmentCount = segmentCount + 1
			if substitution ~= nil then
				segments[segmentCount] = tostring(substitution)
			else
				segments[segmentCount] = matchedStr
			end
		elseif replacementType == "table" then
			local lookupKey = captures[1] or matchedStr
			local substitution = replacement[lookupKey]
			segmentCount = segmentCount + 1
			if substitution ~= nil then
				segments[segmentCount] = tostring(substitution)
			else
				segments[segmentCount] = matchedStr
			end
		end

		replaceCount = replaceCount + 1

		lastCopied = math_max(lastCopied, matchEnd)
		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd + 1
		end
	end

	-- Copy the remaining tail
	segmentCount = segmentCount + 1
	segments[segmentCount] = string_sub(targetString, lastCopied + 1)
	return table_concat(segments, "", 1, segmentCount), replaceCount
end

function Api.split(pattern, targetString, options, config)
	if type(pattern) == "string" then
		options = normalizeFlags(options)
	end

	local parts = {}
	local partCount = 0
	local currentIndex = 0
	local targetLength = #targetString
	local lastCopied = 0

	while currentIndex <= targetLength do
		local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, options, currentIndex, config)
		if not hasMatched then
			break
		end

		partCount = partCount + 1
		parts[partCount] = string_sub(targetString, lastCopied + 1, matchStart - 1)

		lastCopied = math_max(lastCopied, matchEnd)
		if matchEnd < matchStart then
			currentIndex = math_max(currentIndex + 1, matchStart)
		else
			currentIndex = matchEnd + 1
		end
	end

	-- Append the remaining tail
	partCount = partCount + 1
	parts[partCount] = string_sub(targetString, lastCopied + 1)
	return parts
end

return Api
