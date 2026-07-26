--[[
	Shared API Utilities.
]]

--[[ Globals ]]--
local next = next
local string_sub = string.sub
local table_concat = table.concat
local table_sort = table.sort
local type = type

--[[ Dependencies ]]--
local Assertion = require("helpers.assertion")
local parser = require("parser.init")

--[[ Enums ]]--
local Flag = require("api.enums").Flag

--[[ Aliases ]]--
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsTable = Assertion.isTable

--[[ Module ]]--

--- Compiles or retrieves a compiled pattern.
--- String patterns are normalized, looked up in the compilation cache,
--- parsed if necessary, and cached for future use. Precompiled pattern
--- objects are returned unchanged.
---@param pattern string|Pattern The pattern to compile or a precompiled pattern.
---@param flags string|table|nil Optional flags used when compiling string patterns.
---@param config EngineConfig The engine configuration.
---@return Pattern|nil pattern The compiled pattern, or nil if compilation failed.
---@return FlagTable|nil flagsLookup The normalized flag lookup table, or nil if compilation failed.
---@return string|nil errorMessage The compilation error message, or nil if compilation succeeded.
local compilePattern
do
	--- Normalizes user-provided flags into the parser's internal representations.
	--- Accepts either a flag string or a table of flags, ignoring unsupported
	--- values while producing a lookup table for fast membership checks and
	--- a canonical flag string suitable for cache key generation.
	---@param flags string|table|nil The flags to normalize.
	---@return FlagTable flagsLookup A lookup table keyed by enabled flag identifiers.
	---@return string flagsKey A sorted, canonical string of enabled flag identifiers.
	local normalizeFlags = function(flags)
		local flagsLookup, flagsArray = {}, {}

		local flagType, flagCount = type(flags), 0
		if flagType == "table" then
			for key, value in next, flags do
				if type(key) == "number" and type(value) == "string" then
					if Flag[value] and not flagsLookup[key] then
						flagsLookup[value] = true
						flagCount = flagCount + 1
						flagsArray[flagCount] = value
					end
				elseif type(key) == "string" and value then
					if Flag[key] then
						flagsLookup[key] = true
						flagCount = flagCount + 1
						flagsArray[flagCount] = key
					end
				end
			end
		elseif flagType == "string" then
			for charIndex = 1, #flags do
				local flag = string_sub(flags, charIndex, charIndex)
				if Flag[flag] and not flagsLookup[flag] then
					flagsLookup[flag] = true
					flagCount = flagCount + 1
					flagsArray[flagCount] = flag
				end
			end
		end

		table_sort(flagsArray)
		return flagsLookup, table_concat(flagsArray)
	end

	local treeCache, treeCacheCount = {}, 0
	local parseErrorCache, parseErrorCacheCount = {}, 0

	--- Builds a unique cache key for a compiled pattern.
	--- Combines the pattern, normalized flags, and engine configuration into
	--- a canonical string suitable for cache lookups.
	---@param pattern string The pattern to compile.
	---@param flagsKey string The normalized flag string.
	---@param config EngineConfig The engine configuration.
	---@return string cacheKey The generated cache key.
	local buildCacheKey = function(pattern, flagsKey, config)
		return table_concat({
			pattern,
			flagsKey,
			config._cacheKey,
		}, "\0")
	end

	compilePattern = function(pattern, flags, config)
		local patternType = type(pattern)

		-- User input (external)
		if patternType == "string" then
			local flagsKey
			flags, flagsKey = normalizeFlags(flags)

			local cacheKey = buildCacheKey(pattern, flagsKey, config)
			
			local cachedTree = treeCache[cacheKey]
			if cachedTree then
				return cachedTree, flags
			end

			local cachedParseError = parseErrorCache[cacheKey]
			if cachedParseError then
				return nil, nil, cachedParseError
			end

			local tree, errorMessage = parser(pattern, flags)
			if not tree then
				parseErrorCacheCount = parseErrorCacheCount + 1

				if parseErrorCacheCount > config.patternCacheSize then
					parseErrorCacheCount = 1
					parseErrorCache = {
						[cacheKey] = errorMessage
					}
				else
					parseErrorCache[cacheKey] = errorMessage
				end

				return nil, nil, errorMessage
			end

			treeCacheCount = treeCacheCount + 1
			if treeCacheCount > config.patternCacheSize then
				treeCacheCount = 1
				treeCache = {
					[cacheKey] = tree
				}
			else
				treeCache[cacheKey] = tree
			end

			return tree, flags
		
		-- Pattern input (internal)
		elseif patternType == "table" and pattern._index then
			return pattern, flags, nil
		end

		-- In theory, compilePattern will always receive validated input,
		-- but as a failsafe we perform assertions here to understand what went wrong.
		AssertionIsStringOrTable(pattern, "pattern")
		AssertionIsStringOrTable(flags, "flags", true)
		AssertionIsTable(config, "config")
	end
end

--- Builds a public match object from the raw matcher result.
--- Constructs a structured match object containing the matched substring,
--- all captures in chronological order, and captures grouped by their
--- corresponding capture group. Named capture groups are additionally
--- exposed through their group names.
---@param targetString string The original target string that was matched.
---@param matchStart number The starting position of the match.
---@param matchEnd number The ending position of the match.
---@param matcherMetadata MatcherMetadata Metadata produced by the matcher, including capture information.
---@return Match match The constructed public match object.
local buildMatchObject = function(targetString, matchStart, matchEnd, matcherMetadata)
	local matchGroups, matchCaptures = {}, {}
	local match = {
		start = matchStart,
		stop = matchEnd,
		value = string_sub(targetString, matchStart, matchEnd),
		captures = matchCaptures,
		groups = matchGroups,
	}

	if not matcherMetadata.captureStarts then
		return match
	end

	-- %0 represents the entire match
	matchCaptures[0] = {
		groupIndex = 0,
		start = matchStart,
		stop = matchEnd,
		value = match.value,
	}
	matchGroups[0] = {
		matchCaptures[0]
	}

	local captureStarts = matcherMetadata.captureStarts
	local captureEnds = matcherMetadata.captureEnds
	local captureCounts = matcherMetadata.captureCounts
	local groupNames = matcherMetadata.groupNames

	-- Build reverse lookup: groupIndex -> groupName
	local namesByIndex = {}
	for groupName, groupIndex in next, groupNames do
		namesByIndex[groupIndex] = groupName
	end

	local captureCount = 0
	for groupKey, groupCaptureCount in next, captureCounts do
		local groupArray = {}
		matchGroups[groupKey] = groupArray

		local groupName = namesByIndex[groupKey]
		if groupName then
			matchGroups[groupName] = groupArray
		end

		local captureStartsGroup = captureStarts[groupKey]
		local captureEndsGroup = captureEnds[groupKey]
		for captureIndex = 1, groupCaptureCount do
			local captureStart = captureStartsGroup[captureIndex]
			local captureEnd = captureEndsGroup[captureIndex]

			local captureObject = {
				groupIndex = groupKey,
				name = groupName,
				start = captureStart,
				stop = captureEnd,
				value = string_sub(targetString, captureStart, captureEnd),
			}

			groupArray[captureIndex] = captureObject
			captureCount = captureCount + 1
			matchCaptures[captureCount] = captureObject
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

return {
	buildMatchObject = buildMatchObject,
	compilePattern = compilePattern,
}
