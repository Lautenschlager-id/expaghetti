--[[
    Main entry point for expaghetti.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Config = require("config")
local Api = require("api")
local Pattern = require("pattern")
local parser = require("parser.init")
local flags = require("enums.flags")

--[[ Engine Class ]]--
local Engine = {}
Engine.__index = Engine

function Engine.new(options)
	local self = setmetatable({}, Engine)
	self.config = Config.new(Config.global)
	if type(options) == "table" then
		self.config:set(options)
	end
	return self
end

function Engine:configure(options)
	return self.config:set(options)
end

function Engine:compile(regex, options)
	local opts = Api.normalizeFlags(options)
	local tree, errorMessage = parser(regex, opts)
	if not tree then
		error("Failed to compile pattern: " .. tostring(errorMessage))
	end
	return Pattern.new(tree, opts, self.config)
end

function Engine:test(pattern, string, options) return Api.test(pattern, string, options, self.config) end
function Engine:match(pattern, string, options) return Api.match(pattern, string, options, self.config) end
function Engine:matchAll(pattern, string, options) return Api.matchAll(pattern, string, options, self.config) end
function Engine:gmatch(pattern, string, options) return Api.gmatch(pattern, string, options, self.config) end
function Engine:find(pattern, string, options) return Api.find(pattern, string, options, self.config) end
function Engine:replace(pattern, string, replacement, options) return Api.replace(pattern, string, replacement, options, self.config) end
function Engine:gsub(pattern, string, replacement, options) return Api.replace(pattern, string, replacement, options, self.config) end
function Engine:split(pattern, string, options) return Api.split(pattern, string, options, self.config) end

--[[ Module ]]--
local Expaghetti = {}

--[[ Public API ]]--
Expaghetti.RegexFlag = flags.FLAGS

-- Engine Constructor
Expaghetti.create = function(options)
	return Engine.new(options)
end

-- Global Configuration
Expaghetti.configure = function(options)
	return Config.global:set(options)
end

Expaghetti.compile = function(regex, options)
	local opts = Api.normalizeFlags(options)
	local tree, errorMessage = parser(regex, opts)
	if not tree then
		error("Failed to compile pattern: " .. tostring(errorMessage))
	end
	return Pattern.new(tree, opts, Config.global)
end

-- Global One-Off Operations
Expaghetti.test = function(pattern, string, options) return Api.test(pattern, string, options, Config.global) end
Expaghetti.match = function(pattern, string, options) return Api.match(pattern, string, options, Config.global) end
Expaghetti.matchAll = function(pattern, string, options) return Api.matchAll(pattern, string, options, Config.global) end
Expaghetti.gmatch = function(pattern, string, options) return Api.gmatch(pattern, string, options, Config.global) end
Expaghetti.find = function(pattern, string, options) return Api.find(pattern, string, options, Config.global) end
Expaghetti.replace = function(pattern, string, replacement, options) return Api.replace(pattern, string, replacement, options, Config.global) end
Expaghetti.gsub = function(pattern, string, replacement, options) return Api.replace(pattern, string, replacement, options, Config.global) end
Expaghetti.split = function(pattern, string, options) return Api.split(pattern, string, options, Config.global) end

-- Keep old match export for backwards compat in tests, but tests should be updated.
Expaghetti._matcher = require("matcher.init")

--[[ Return ]]--
return setmetatable(Expaghetti, {
	__call = function(_, options)
		return Engine.new(options)
	end,
})
