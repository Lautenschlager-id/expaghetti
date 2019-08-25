local bit32 = require("helper/bit32")
local utf8 = require("helper/utf8")
local enum = require("enum")

local parse = require("parser")

local match = function(str, exp)
	-- TODO
end

local gmatch = function(str, exp)
	-- TODO
end

-----------------> DEBUG ONLY <-----------------
local test = require("test/util")
local tree = parse("[𝒳-𝒴]", { enum.flag.unicode })
print(test.tableToString(tree, true, true))
-----------------<            >-----------------

return {
	version = '',
	bit32 = bit32,
	parse = parser,
	flag = enum.flag,
	gmatch = gmatch,
	match = match,
	utf8 = utf8
}