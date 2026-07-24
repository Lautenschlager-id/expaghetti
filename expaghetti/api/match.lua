--[[
    API: match
]]

local matcher = require("matcher.init")
local type = type

return function(utils)
	return function(pattern, targetString, flags, start, config)
		local err
		pattern, flags, err = utils.compilePattern(pattern, flags, config)
		if err then return nil, err end
		local currentIndex = (start or 1) - 1
		local hasMatched, matchStart, matchEnd, matcherMetadata = matcher(pattern, targetString, flags, currentIndex, config)
		if hasMatched == false and type(matchStart) == "string" then return nil, "Expaghetti Error: " .. matchStart end
		if hasMatched then
			return utils.buildMatchObject(targetString, matchStart, matchEnd, matcherMetadata)
		end
		return nil
	end
end
