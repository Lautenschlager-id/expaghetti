local DEFAULT_MAX_RECURSION_DEPTH = 200
local DEFAULT_MAX_BACKTRACK_DEPTH = 50000

local settings = {
	maxRecursionDepth = DEFAULT_MAX_RECURSION_DEPTH,
	maxBacktrackDepth = DEFAULT_MAX_BACKTRACK_DEPTH,
}

return {
	DEFAULT_MAX_RECURSION_DEPTH = DEFAULT_MAX_RECURSION_DEPTH,
	DEFAULT_MAX_BACKTRACK_DEPTH = DEFAULT_MAX_BACKTRACK_DEPTH,

	get = function()
		return settings
	end,

	set = function(options)
		if type(options) ~= "table" then
			return settings
		end
		if options.maxRecursionDepth then
			settings.maxRecursionDepth = options.maxRecursionDepth
		end
		if options.maxBacktrackDepth then
			settings.maxBacktrackDepth = options.maxBacktrackDepth
		end
		return settings
	end,
}
