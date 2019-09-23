local bit32 = require("helper/bit32")
local utf8 = require("helper/utf8")
local enum = require("enum")

local _match = require("matcher")

local match = function(str, exp)
	-- TODO
end

local gmatch = function(str, exp)
	-- TODO
end

-----------------> DEBUG ONLY <-----------------
local test = require("test/util")
local matches = _match("te aaaaamo", "t()e()a|te a?mo()|t()")
print(test.tableToString(matches, true, true))
-----------------<            >-----------------

return {
	version = '',
	bit32 = bit32,
	parse = parser,
	flag = enum.flag,
	gmatch = gmatch,
	match = match,
	option = enum.option,
	utf8 = utf8
}