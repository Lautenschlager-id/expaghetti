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
	self._parent = parent
	self._settings = {}
	if not parent then
		-- Global defaults
		self._settings.maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH
		self._settings.maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH
	end
	return self
end

function Config:get(key)
	if self._settings[key] ~= nil then
		return self._settings[key]
	elseif self._parent then
		return self._parent:get(key)
	end
	return nil
end

function Config:getAll()
	local settings = {}
	if self._parent then
		settings = self._parent:getAll()
	end
	for k, v in pairs(self._settings) do
		settings[k] = v
	end
	return settings
end

function Config:set(options)
	if type(options) ~= "table" then
		return self:getAll()
	end
	if options.maxRecursionDepth ~= nil then
		self._settings.maxRecursionDepth = options.maxRecursionDepth
	end
	if options.maxBacktrackDepth ~= nil then
		self._settings.maxBacktrackDepth = options.maxBacktrackDepth
	end
	return self:getAll()
end

--[[ Singleton Export ]]--
local globalConfig = Config.new()

return {
	new = Config.new,
	global = globalConfig,
}
