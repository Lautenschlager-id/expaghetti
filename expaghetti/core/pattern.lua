--[[
    Compiled Pattern Object.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Api = require("api.init")

--[[ Module ]]--
local Pattern = {}
Pattern.__index = Pattern

function Pattern.new(tree, flags, config)
	return setmetatable({
		tree = tree,
		flags = flags,
		config = config
	}, Pattern)
end

function Pattern:test(string, start)
	return Api.test(self.tree, string, self.flags, start, self.config)
end

function Pattern:match(string, start)
	return Api.match(self.tree, string, self.flags, start, self.config)
end

function Pattern:matchAll(string, start)
	return Api.matchAll(self.tree, string, self.flags, start, self.config)
end

function Pattern:gmatch(string, start)
	return Api.gmatch(self.tree, string, self.flags, start, self.config)
end

function Pattern:find(string, start)
	return Api.find(self.tree, string, self.flags, start, self.config)
end

function Pattern:replace(string, replacement, start)
	return Api.replace(self.tree, string, replacement, self.flags, start, self.config)
end

function Pattern:gsub(string, replacement, limit, start)
	return Api.replace(self.tree, string, replacement, self.flags, start, self.config, limit)
end

function Pattern:split(string, start)
	return Api.split(self.tree, string, self.flags, start, self.config)
end

return Pattern
