--[[
    Main entry point for expaghetti.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Config = require("config")
local Api = require("api.init")
local Pattern = require("pattern")
local parser = require("parser.init")
local flags = require("enums.flags")

--[[ Engine Class ]]--
local Engine = {}
Engine.__index = Engine

function Engine.new(options)
	local self = setmetatable({}, Engine)
	self.config = Config.build(options)
	return self
end

function Engine:compile(regex, options)
	local tree, flags, errorMessage = Api.compilePattern(regex, options, self.config)
	if not tree then
		error("Failed to compile pattern: " .. tostring(errorMessage))
	end
	return Pattern.new(tree, flags, self.config)
end

function Engine:test(pattern, string, flags, start) return Api.test(pattern, string, flags, start, self.config) end
function Engine:match(pattern, string, flags, start) return Api.match(pattern, string, flags, start, self.config) end
function Engine:matchAll(pattern, string, flags, start) return Api.matchAll(pattern, string, flags, start, self.config) end
function Engine:gmatch(pattern, string, flags, start) return Api.gmatch(pattern, string, flags, start, self.config) end
function Engine:find(pattern, string, flags, start) return Api.find(pattern, string, flags, start, self.config) end
function Engine:replace(pattern, string, replacement, flags, start)
	local result = Api.replace(pattern, string, replacement, flags, start, self.config)
	return result
end
function Engine:gsub(pattern, string, replacement, flags, limit, start) return Api.replace(pattern, string, replacement, flags, start, self.config, limit) end
function Engine:split(pattern, string, flags, start) return Api.split(pattern, string, flags, start, self.config) end

Engine.install = Api.installHooks.install
Engine.uninstall = Api.installHooks.uninstall


--[[ Default Global Engine ]]--
local DefaultEngine = Engine.new()

--[[ Module ]]--
local Expaghetti = setmetatable({}, {
	__call = function(_, options)
		return Engine.new(options)
	end
})

local PublicEnums = require("api.enums")
Expaghetti.RegexFlag = PublicEnums.RegexFlag

-- Custom Engine Constructor
Expaghetti.custom = function(options)
	return Engine.new(options)
end

Expaghetti.compile = function(regex, options)
	return DefaultEngine:compile(regex, options)
end

-- Global One-Off Operations (uses DefaultEngine)
Expaghetti.test = function(...) return DefaultEngine:test(...) end
Expaghetti.match = function(...) return DefaultEngine:match(...) end
Expaghetti.matchAll = function(...) return DefaultEngine:matchAll(...) end
Expaghetti.gmatch = function(...) return DefaultEngine:gmatch(...) end
Expaghetti.find = function(...) return DefaultEngine:find(...) end
Expaghetti.replace = function(...) return DefaultEngine:replace(...) end
Expaghetti.gsub = function(...) return DefaultEngine:gsub(...) end
Expaghetti.split = function(...) return DefaultEngine:split(...) end

Expaghetti.install = function() DefaultEngine:install() end
Expaghetti.uninstall = function() DefaultEngine:uninstall() end

--[[ Return ]]--
return Expaghetti

