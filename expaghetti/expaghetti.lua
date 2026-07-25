--[[
    Main entry point for expaghetti.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Engine = require("core.engine")

--[[ Enums ]]--
local PublicEnums = require("api.enums")

--[[ Module ]]--
local DefaultEngine = Engine.new()

local Expaghetti = setmetatable({}, {
	__call = function(_, config)
		return Engine.new(config)
	end
})

Expaghetti.Flag = PublicEnums.Flag

Expaghetti.custom = function(config)
	return Engine.new(config)
end

Expaghetti.compile = function(regex, flags)
	return DefaultEngine:compile(regex, flags)
end

Expaghetti.test = function(...)
	return DefaultEngine:test(...)
end

Expaghetti.match = function(...)
	return DefaultEngine:match(...)
end

Expaghetti.matchAll = function(...)
	return DefaultEngine:matchAll(...)
end

Expaghetti.gmatch = function(...)
	return DefaultEngine:gmatch(...)
end

Expaghetti.find = function(...)
	return DefaultEngine:find(...)
end

Expaghetti.replace = function(...)
	return DefaultEngine:replace(...)
end

Expaghetti.gsub = function(...)
	return DefaultEngine:gsub(...)
end

Expaghetti.split = function(...)
	return DefaultEngine:split(...)
end

Expaghetti.install = function()
	DefaultEngine:install()
end

Expaghetti.uninstall = function()
	DefaultEngine:uninstall()
end

return Expaghetti
