--[[
	API configuration.

	Defines the default API configuration and provides utilities
	for resolving user-supplied configuration with the library's
	default values.
]]

--[[ Globals ]]--
local math_huge = math.huge
local next = next
local table_concat = table.concat

--[[ Dependencies ]]--
local AssertionIsNumber = require("expaghetti.helpers.assertion").isNumber

--[[ Module ]]--
local defaults = {
	maxRecursionDepth = 200,
	maxBacktrackDepth = 50000,
	patternCacheSize = math_huge,
	_cacheKey = nil
}

--- Builds a cache key for a resolved API configuration.
---@param config ResolvedAPIConfig The resolved API configuration.
---@return string cacheKey The generated cache key.
local buildCacheKey = function(config)
	return table_concat({
		config.maxRecursionDepth,
		config.maxBacktrackDepth,
	}, "\0")
end

--- Determines whether a configuration overrides compiler settings.
---@param config ResolvedAPIConfig The resolved API configuration.
---@return boolean usesCustomSettings Whether custom compiler settings are present.
local usesCustomCompilerSettings = function(config)
	return config.maxRecursionDepth
		or config.maxBacktrackDepth
end

--- Builds an API configuration.
--- Resolves a user-supplied configuration with the library's default
--- values. If no configuration is provided, the default configuration
--- is returned.
---@param config APIConfig|nil The user-supplied API configuration.
---@return ResolvedAPIConfig config The resolved API configuration.
local new = function(config)
	if not config or not next(config) then
		return defaults
	end

	local maxRecursionDepth = config.maxRecursionDepth
	AssertionIsNumber(maxRecursionDepth, "maxRecursionDepth", true)

	local maxBacktrackDepth = config.maxBacktrackDepth
	AssertionIsNumber(maxBacktrackDepth, "maxBacktrackDepth", true)

	local patternCacheSize = config.patternCacheSize
	AssertionIsNumber(patternCacheSize, "patternCacheSize", true)

	local self = {
		maxRecursionDepth = maxRecursionDepth or defaults.maxRecursionDepth,
		maxBacktrackDepth = maxBacktrackDepth or defaults.maxBacktrackDepth,
		patternCacheSize = patternCacheSize or defaults.patternCacheSize,
	}
	self._cacheKey = usesCustomCompilerSettings(config) and buildCacheKey(self) or defaults._cacheKey

	return self
end

defaults._cacheKey = buildCacheKey(defaults)

return {
	defaults = defaults,
	new = new,
}
