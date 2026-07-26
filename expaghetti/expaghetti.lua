--[[
	Expaghetti public API.

	Provides a default regular expression engine for convenient
	one-off operations, while also exposing the constructors and
	enumerations required to create and configure custom engines.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Engine = require("core.engine")

--[[ Enums ]]--
local ApiEnums = require("api.enums")

--[[ Aliases ]]--
local AssertionIsTable = require("helpers.assertion").isTable

--[[ Module ]]--
local DefaultEngine = Engine.new()

local Expaghetti = setmetatable({}, {
	__call = function(_, config)
		return Engine.new(config)
	end
})

Expaghetti.Flag = ApiEnums.Flag

--- Creates a custom regular expression engine.
---@param config EngineConfig|nil The engine configuration.
---@return Engine engine The configured engine.
Expaghetti.custom = function(config)
	AssertionIsTable(config)
	return Engine.new(config)
end

--- Compiles a regular expression.
---@see Engine.compile
Expaghetti.compile = function(regex, flags)
	return DefaultEngine:compile(regex, flags)
end

--- Tests whether a pattern matches a target string.
---@see Engine.test
Expaghetti.test = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:test(pattern, targetString, flags, startPosition)
end

--- Finds the first match in a target string.
---@see Engine.match
Expaghetti.match = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:match(pattern, targetString, flags, startPosition)
end

--- Finds every match in a target string.
---@see Engine.matchAll
Expaghetti.matchAll = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:matchAll(pattern, targetString, flags, startPosition)
end

--- Iterates over every match in a target string.
---@see Engine.gmatch
Expaghetti.gmatch = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:gmatch(pattern, targetString, flags, startPosition)
end

--- Finds the first occurrence of a pattern.
---@see Engine.find
Expaghetti.find = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:find(pattern, targetString, flags, startPosition)
end

--- Replaces the first occurrence of a pattern.
---@see Engine.replace
Expaghetti.replace = function(pattern, targetString, replacement, flags, startPosition)
	return DefaultEngine:replace(pattern, targetString, replacement, flags, startPosition)
end
 
--- Replaces occurrences of a pattern.
---@see Engine.gsub
Expaghetti.gsub = function(pattern, targetString, replacement, flags, limit, startPosition)
	return DefaultEngine:gsub(pattern, targetString, replacement, flags, limit, startPosition)
end

--- Splits a target string using a pattern.
---@see Engine.split
Expaghetti.split = function(pattern, targetString, flags, startPosition)
	return DefaultEngine:split(pattern, targetString, flags, startPosition)
end

--- Installs Expaghetti's string library extensions.
---@see Engine.install
Expaghetti.install = function()
	return DefaultEngine:install()
end

--- Restores Lua's original string library.
---@see Engine.uninstall
Expaghetti.uninstall = function()
	return DefaultEngine:uninstall()
end

return Expaghetti
