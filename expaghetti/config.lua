--[[
    Configuration module.
]]

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

local globalConfig = {
	maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
	maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH
}

local function validateType(val, expectedType, defaultVal, key)
	if val ~= nil then
		if type(val) ~= expectedType then
			error("Config Error: " .. key .. " must be a " .. expectedType)
		end
		return val
	end
	return defaultVal
end

local function buildConfig(options)
	if type(options) ~= "table" then return globalConfig end
	
	return {
		maxRecursionDepth = validateType(options.maxRecursionDepth, "number", globalConfig.maxRecursionDepth, "maxRecursionDepth"),
		maxBacktrackDepth = validateType(options.maxBacktrackDepth, "number", globalConfig.maxBacktrackDepth, "maxBacktrackDepth")
	}
end

return {
	global = globalConfig,
	build = buildConfig
}
