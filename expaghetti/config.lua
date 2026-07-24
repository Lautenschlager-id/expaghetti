--[[
    Configuration module.
]]

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

return {
	global = {
		maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
		maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH
	}
}
