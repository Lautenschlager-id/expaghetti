local bit32 = require("helper/bit32")
local utf8 = require("helper/utf8")

local parser = require("parser")

local match = function(str, exp)
	-- TODO
end

local gmatch = function(str, exp)
	-- TODO
end

return {
	version = '',
	bit32 = bit32,
	parse = parser,
	gmatch = gmatch,
	match = match,
	utf8 = utf8
}