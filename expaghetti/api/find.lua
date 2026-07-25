--[[
    API: find
]]

local matcher = require("matcher.init")
local type = type

local utils = require("helpers.api")

return function(pattern, targetString, flags, start, config)
	local err
	pattern, flags, err = utils.compilePattern(pattern, flags, config)
	if err then return nil, err end
	local currentIndex = (start or 1) - 1
	local hasMatched, matchStart, matchEnd = matcher(pattern, targetString, flags, currentIndex, config)
	if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
	if hasMatched then
		return matchStart, matchEnd
	end
	return nil
end
