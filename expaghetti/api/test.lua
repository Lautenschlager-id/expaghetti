--[[
    API: test
]]

local matcher = require("matcher.init")
local type = type

return function(utils)
	return function(pattern, targetString, flags, start, config)
		local err
		pattern, flags, err = utils.compilePattern(pattern, flags)
		if err then return nil, err end
		local currentIndex = (start or 1) - 1
		local hasMatched, matchErr = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchErr) == "string" then return nil, "Expaghetti Error: " .. matchErr end
		return hasMatched == true
	end
end
