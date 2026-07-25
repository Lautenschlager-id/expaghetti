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

local function enforceType(options, config, key, expectedType)
	local val = options[key]
	if val ~= nil then
		if type(val) ~= expectedType then
			error("Config Error: " .. key .. " must be a " .. expectedType)
		end
		config[key] = val
	end
end

local function buildConfig(options)
	if type(options) ~= "table" then return globalConfig end
	
	local config = {
		maxRecursionDepth = globalConfig.maxRecursionDepth,
		maxBacktrackDepth = globalConfig.maxBacktrackDepth
	}
	
	enforceType(options, config, "maxRecursionDepth", "number")
	enforceType(options, config, "maxBacktrackDepth", "number")
	
	return config
end

return {
	global = globalConfig,
	build = buildConfig
}
