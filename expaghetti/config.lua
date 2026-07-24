--[[
    Configuration module.
]]

--[[ Constants ]]--
local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

local function parseOptions(options)
	if type(options) ~= "table" then return {} end
	local parsed = {}
	
	if options.maxRecursionDepth ~= nil then
		if type(options.maxRecursionDepth) ~= "number" then
			error("Config Error: maxRecursionDepth must be a number")
		end
		parsed.maxRecursionDepth = options.maxRecursionDepth
	end
	
	if options.maxBacktrackDepth ~= nil then
		if type(options.maxBacktrackDepth) ~= "number" then
			error("Config Error: maxBacktrackDepth must be a number")
		end
		parsed.maxBacktrackDepth = options.maxBacktrackDepth
	end
	
	return parsed
end

return {
	global = {
		maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
		maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH
	},
	parse = parseOptions
}
