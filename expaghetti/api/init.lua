--[[
	Shared API function registry.

	Centralizes Expaghetti's API implementations so they can be shared among module APIs.
]]

--[[ Module ]]--
return {
	find = require("api.api.find"),
	gmatch = require("api.api.gmatch"),
	installHooks = require("api.api.install"),
	match = require("api.api.match"),
	matchAll = require("api.api.matchAll"),
	replace = require("api.api.replace"),
	split = require("api.api.split"),
	test = require("api.api.test"),
}
