--[[
    Main entry point for expaghetti.
]]

--[[ Globals ]]--
local setmetatable = setmetatable

--[[ Dependencies ]]--
local Config = require("config")
local Matcher = require("matcher.init")

--[[ Module ]]--
local Expaghetti = {}

--[[ Private Functions ]]--
local create = function(options)
	if options then
		Config.set(options)
	end

	return {
		match = Matcher,
		configure = Config.set,
	}
end

--[[ Public API ]]--
Expaghetti.create = create

--[[ Return ]]--
return setmetatable(Expaghetti, {
	__call = function(_, options)
		return create(options)
	end,
})
