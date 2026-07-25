--[[
    Configuration module.
]]

--[[ Globals ]]--
local math_huge = math.huge
local table_concat = table.concat

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

local buildCacheKey = function(config)
	return table_concat({
		config.maxRecursionDepth,
		config.maxBacktrackDepth,
	}, "\0")
end

local globalConfig = {
	maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
	maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH,
	patternCacheSize = math_huge,
}
globalConfig._cacheKey = buildCacheKey(globalConfig)

local function validateType(val, expectedType, defaultVal, key)
	if val ~= nil then
		if type(val) ~= expectedType then
			error("Config Error: " .. key .. " must be a " .. expectedType)
		end
		return val
	end
	return defaultVal
end

local function buildConfig(config)
	if type(config) ~= "table" then return globalConfig end
	
	local self = {
		maxRecursionDepth = validateType(config.maxRecursionDepth, "number", globalConfig.maxRecursionDepth, "maxRecursionDepth"),
		maxBacktrackDepth = validateType(config.maxBacktrackDepth, "number", globalConfig.maxBacktrackDepth, "maxBacktrackDepth"),
		patternCacheSize = validateType(config.patternCacheSize, "number", globalConfig.patternCacheSize, "patternCacheSize"),
	}
	self._cacheKey = buildCacheKey(self)

	return self
end

return {
	global = globalConfig,
	build = buildConfig,
}
