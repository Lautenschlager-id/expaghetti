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

function Pattern:test(string)
	return Api.test(self.tree, string, self.options, self.config)
end

function Pattern:match(string)
	return Api.match(self.tree, string, self.options, self.config)
end

function Pattern:matchAll(string)
	return Api.matchAll(self.tree, string, self.options, self.config)
end

function Pattern:gmatch(string)
	return Api.gmatch(self.tree, string, self.options, self.config)
end

function Pattern:find(string)
	return Api.find(self.tree, string, self.options, self.config)
end

function Pattern:replace(string, replacement)
	return Api.replace(self.tree, string, replacement, self.options, self.config)
end

function Pattern:gsub(string, replacement)
	return self:replace(string, replacement)
end

function Pattern:split(string)
	return Api.split(self.tree, string, self.options, self.config)
end

return Pattern
