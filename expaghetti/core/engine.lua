--[[
    Main entry point for expaghetti.
]]

--[[ Globals ]]--
local setmetatable = setmetatable
local string_format = string.format

--[[ Dependencies ]]--
local Api = require("api.init")
local Config = require("core.config")
local Pattern = require("core.pattern")

--[[ Module ]]--
local Engine = {}
Engine.__index = Engine

function Engine.new(config)
	return setmetatable({
		config = Config.build(config)
	}, Engine)
end

function Engine:compile(regex, flags)
	local tree, parsedFlags, errorMessage = Api.compilePattern(regex, flags, self.config)
	if not tree then
		error(string_format("Failed to compile pattern:\n\t%s", tostring(errorMessage)))
	end
	return Pattern.new(tree, parsedFlags, self.config)
end

function Engine:test(pattern, string, flags, start)
	return Api.test(pattern, string, flags, start, self.config)
end

function Engine:match(pattern, string, flags, start)
	return Api.match(pattern, string, flags, start, self.config)
end

function Engine:matchAll(pattern, string, flags, start)
	return Api.matchAll(pattern, string, flags, start, self.config)
end

function Engine:gmatch(pattern, string, flags, start)
	return Api.gmatch(pattern, string, flags, start, self.config)
end

function Engine:find(pattern, string, flags, start)
	return Api.find(pattern, string, flags, start, self.config)
end

function Engine:replace(pattern, string, replacement, flags, start)
	return Api.replace(pattern, string, replacement, flags, start, self.config)
end

function Engine:gsub(pattern, string, replacement, flags, limit, start)
	return Api.replace(pattern, string, replacement, flags, start, self.config, limit)
end

function Engine:split(pattern, string, flags, start)
	return Api.split(pattern, string, flags, start, self.config)
end

Engine.install = Api.installHooks.install
Engine.uninstall = Api.installHooks.uninstall

return Engine
