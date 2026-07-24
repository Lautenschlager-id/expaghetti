--[[
    Compiled Pattern Object.
]]

local Api = require("api")

local Pattern = {}
Pattern.__index = Pattern

function Pattern.new(tree, options, config)
	local self = setmetatable({}, Pattern)
	self.tree = tree
	self.options = Api.normalizeFlags(options)
	self.config = config
	return self
end

function Pattern:test(string, start)
	return Api.test(self.tree, string, self.options, start, self.config)
end

function Pattern:match(string, start)
	return Api.match(self.tree, string, self.options, start, self.config)
end

function Pattern:matchAll(string, start)
	return Api.matchAll(self.tree, string, self.options, start, self.config)
end

function Pattern:gmatch(string, start)
	return Api.gmatch(self.tree, string, self.options, start, self.config)
end

function Pattern:find(string, start)
	return Api.find(self.tree, string, self.options, start, self.config)
end

function Pattern:replace(string, replacement, start)
	local result = Api.replace(self.tree, string, replacement, self.options, start, self.config)
	return result
end
function Pattern:gsub(string, replacement, limit, start) return Api.replace(self.tree, string, replacement, self.options, start, self.config, limit) end

function Pattern:split(string, start)
	return Api.split(self.tree, string, self.options, start, self.config)
end

return Pattern
