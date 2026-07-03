local config = require("config")
local matcher = require("matcher")

local function create(options)
	if options then
		config.set(options)
	end

	return {
		match = matcher,
		configure = config.set,
	}
end

return setmetatable({
	create = create,
}, {
	__call = function(_, options)
		return create(options)
	end,
})
