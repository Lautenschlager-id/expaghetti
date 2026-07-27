--[[
	Shared API function registry.

	Centralizes Expaghetti's API implementations so they can be shared among module APIs.
]]

--[[ Globals ]]--
local require = require

--[[ Dependencies ]]--
local createCompilePattern = require("expaghetti.helpers.api").compilePattern

--[[ Module ]]--
return function(config)
	local compilePattern = createCompilePattern(config)

	local find = require("expaghetti.api.api.find")(config, compilePattern)
	local gmatch = require("expaghetti.api.api.gmatch")(config, compilePattern)
	local gsub = require("expaghetti.api.api.replace")(config, compilePattern)
	local match = require("expaghetti.api.api.match")(config, compilePattern)
	local matchAll = require("expaghetti.api.api.matchAll")(config, compilePattern)
	local split = require("expaghetti.api.api.split")(config, compilePattern)
	local test = require("expaghetti.api.api.test")(config, compilePattern)

	local replace = function(pattern, targetString, replacement, flags, startPosition)
		return gsub(pattern, targetString, replacement, flags, 1, startPosition)
	end

	local api = {
		find = find,
		gmatch = gmatch,
		match = match,
		matchAll = matchAll,
		gsub = gsub,
		replace = replace,
		split = split,
		test = test,
	}

	api.compile = require("expaghetti.api.api.compile")(api, compilePattern)

	return api
end
