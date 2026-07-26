--[[
	Shared API function registry.

	Centralizes Expaghetti's API implementations so they can be shared among module APIs.
]]

--[[ Dependencies ]]--
local createCompilePattern = require("helpers.api").compilePattern

--[[ Module ]]--
return function(config)
	local compilePattern = createCompilePattern(config)

	local find = require("api.api.find")(config, compilePattern)
	local gmatch = require("api.api.gmatch")(config, compilePattern)
	local gsub = require("api.api.replace")(config, compilePattern)
	local match = require("api.api.match")(config, compilePattern)
	local matchAll = require("api.api.matchAll")(config, compilePattern)
	local split = require("api.api.split")(config, compilePattern)
	local test = require("api.api.test")(config, compilePattern)

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

	api.compile = require("api.api.compile")(api, compilePattern)

	return api
end
