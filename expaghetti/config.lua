--[[
    Configuration module.
]]

--[[ Globals ]]--
local type = type
local setmetatable = setmetatable

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

--[[ Module ]]--
local Config = {}
Config.__index = Config

Config.DEFAULT_MAX_RECURSION_DEPTH = DEFAULT_MAX_RECURSION_DEPTH
Config.DEFAULT_MAX_BACKTRACK_DEPTH = DEFAULT_MAX_BACKTRACK_DEPTH

--[[ Methods ]]--
function Config.new(parent)
	local self = setmetatable({}, Config)
	
	-- Flatten settings for fast property access
	self.maxRecursionDepth = parent and parent.maxRecursionDepth or DEFAULT_MAX_RECURSION_DEPTH
	self.maxBacktrackDepth = parent and parent.maxBacktrackDepth or DEFAULT_MAX_BACKTRACK_DEPTH
	
	return self
end

function Config:get(key)
	return self[key]
end

function Config:getAll()
	return {
		maxRecursionDepth = self.maxRecursionDepth,
		maxBacktrackDepth = self.maxBacktrackDepth
	}
end

function Config:set(options)
	if type(options) ~= "table" then
		return self:getAll()
	end
	if options.maxRecursionDepth ~= nil then
		self.maxRecursionDepth = options.maxRecursionDepth
	end
	if options.maxBacktrackDepth ~= nil then
		self.maxBacktrackDepth = options.maxBacktrackDepth
	end
	return self:getAll()
end

--[[ Singleton Export ]]--
local globalConfig = Config.new()

return {
	new = Config.new,
	global = globalConfig,
}
