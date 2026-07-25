--[[
    API Entry Point
]]

local helpers = require("helpers.api")
local matchAllAPI = require("api.matchAll")

local Api = {
	test = require("api.test"),
	match = require("api.match"),
	matchAll = matchAllAPI.matchAll,
	gmatch = matchAllAPI.gmatch,
	find = require("api.find"),
	replace = require("api.replace"),
	split = require("api.split"),
	
	installHooks = require("api.install"),
	normalizeFlags = helpers.normalizeFlags,
	compilePattern = helpers.compilePattern
}

return Api
