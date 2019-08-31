local bit32 = require("helper/bit32")
local utf8 = require("helper/utf8")
local enum = require("enum")

local match = require("matcher")

local _match = function(str, exp)
	-- TODO
end

local gmatch = function(str, exp)
	-- TODO
end

-----------------> DEBUG ONLY <-----------------
local test = require("test/util")
local matches = { match("testb", "^test[ab]()$") }
print(test.tableToString(matches, true, true))
-----------------<            >-----------------

return {
	version = '',
	bit32 = bit32,
	parse = parser,
	flag = enum.flag,
	gmatch = gmatch,
	match = _match,
	option = enum.option,
	utf8 = utf8
}