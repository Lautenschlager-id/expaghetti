--[[
    Configuration module.
]]

--[[ Globals ]]--
local type = type

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

--[[ Module ]]--
local Config = {}

local settings = {
	maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
	maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH,
}

--[[ Public API ]]--
Config.DEFAULT_MAX_RECURSION_DEPTH = DEFAULT_MAX_RECURSION_DEPTH
Config.DEFAULT_MAX_BACKTRACK_DEPTH = DEFAULT_MAX_BACKTRACK_DEPTH

Config.get = function()
	return settings
end

Config.set = function(options)
	if type(options) ~= "table" then
		return settings
	end
	if options.maxRecursionDepth then
		settings.maxRecursionDepth = options.maxRecursionDepth
	end
	if options.maxBacktrackDepth then
		settings.maxBacktrackDepth = options.maxBacktrackDepth
	end
	return settings
end

--[[ Return ]]--
return Config
