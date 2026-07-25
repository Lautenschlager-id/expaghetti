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

local function buildConfig(options)
	if type(options) ~= "table" then return globalConfig end
	
	local config = {
		maxRecursionDepth = globalConfig.maxRecursionDepth,
		maxBacktrackDepth = globalConfig.maxBacktrackDepth
	}
	
	if options.maxRecursionDepth ~= nil then
		if type(options.maxRecursionDepth) ~= "number" then
			error("Config Error: maxRecursionDepth must be a number")
		end
		config.maxRecursionDepth = options.maxRecursionDepth
	end
	
	if options.maxBacktrackDepth ~= nil then
		if type(options.maxBacktrackDepth) ~= "number" then
			error("Config Error: maxBacktrackDepth must be a number")
		end
		config.maxBacktrackDepth = options.maxBacktrackDepth
	end
	
	return config
end

return {
	global = globalConfig,
	build = buildConfig
}
