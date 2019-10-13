local test = require("../../test/util")
local set = require("../../handler/set")
local parse = require("../../parser")
local enum = require("../../enum")

local checkMany = function(rset, data, expectFail, name)
	local isTbl = type(rset) == "table"

	name = (isTbl and name or rset)
	rset = (isTbl and rset or parse(rset):get(1))

	for i = 1, #data do
		test.assertion.value(set.match, not expectFail, name .. " -> " .. data[i], rset, data[i])
	end
end

-- Normal
checkMany("[abc]", { 'a', 'b', 'c' })
checkMany("[abc]", { 'd', 'e', 'f', '0', '9', '@', 'A', 'D' }, true)

-- Negated set
checkMany("[^abc]", { 'a', 'b', 'c' }, true)
checkMany("[^abc]", { 'd', 'e', 'f', '0', '9', '@', 'A', 'D' })

-- Range
checkMany("[a-d]", { 'a', 'b', 'c', 'd' })
checkMany("[a-d]", { 'e', 'f', '0', '9', '@', 'A', 'D' }, true)

-- Negated Range
checkMany("[^a-d]", { 'a', 'b', 'c', 'd' }, true)
checkMany("[^a-d]", { 'e', 'f', '0', '9', '@', 'A', 'D' })

-- Set with Range
checkMany("[a-def]", { 'a', 'b', 'c', 'd', 'e', 'f' })
checkMany("[a-def]", { 'g', 'j', '0', '9', '@', 'A', 'D' }, true)

-- Set with magic character
checkMany("[]$^[()%-.{},*+?%%|]", { ']', '$', '^', '[', '(', ')', '%', '-', '.', '{', '}', ',', '*', '+', '?', '%', '|' })
checkMany("[]$^[()%-.{},*+?%%|]", { '@', 'f', '0', '9', '@', 'A', 'D' }, true)

-- Set with character classes
checkMany(enum.class.a, { 'a', 'A', 'b', 'C' }, nil, 'a')
checkMany(enum.class.a, { '0', '@', '_' }, true, 'a')

checkMany(enum.class.d, { '0', '5', '3', '6' }, nil, 'd')
checkMany(enum.class.d, { 'a', 'b', '_' }, true, 'd')

-- Negated set with character classes
checkMany(enum.class.A, { 'a', 'A', 'b', 'C' }, true, 'A')
checkMany(enum.class.A, { '0', '@', '_' }, nil, 'A')

checkMany(enum.class.D, { '0', '5', '3', '6' }, true, 'D')
checkMany(enum.class.D, { 'a', 'b', '_' }, nil, 'D')

-- Set with ]
checkMany("[]a]", { ']', 'a' })

-- Negated set with ]
checkMany("[^]a]", { ']', 'a' }, true)
checkMany("[^]a]", { '@', '0' })

return test.assertion.get()