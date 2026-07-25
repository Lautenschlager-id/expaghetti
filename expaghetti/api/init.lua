--[[
    API Entry Point
]]

local helpers = require("helpers.api")

return {
	test = require("api.api.test"),
	match = require("api.api.match"),
	matchAll = require("api.api.matchAll"),
	gmatch = require("api.api.gmatch"),
	find = require("api.api.find"),
	replace = require("api.api.replace"),
	split = require("api.api.split"),
	
	installHooks = require("api.api.install"),
	normalizeFlags = helpers.normalizeFlags,
	compilePattern = helpers.compilePattern
}
