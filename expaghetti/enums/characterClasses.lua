--[[
	Precompiled character class definitions used by the parser to expand
	regular expression character classes (e.g. %a, %d, %w, %s) into set elements.

	Each entry is represented as a reusable AST set node that can be shared
	whenever the corresponding character class is encountered.
]]

--[[ Dependencies ]]--
local SetNode = require("core.ast").Set
local deepCopy = require("helpers.table").deepCopy

--[[ Module ]]--

--- Creates a character class set from a string of characters.
---@param characters string The characters to include in the set.
---@return CharacterSet set The generated character class set.
local createSet = function(settings)
	local set = SetNode()

	local ranges = settings.ranges
	if ranges then
		set.ranges = ranges
		set.rangeIndex = #ranges
	end

	local values = settings.values
	if values then
		set.values = values
	end

	return set
end

--- Negates a character class set.
---@param set CharacterSet The set to negate.
---@return CharacterSet negatedSet The negated character class set.
local negateSet = function(set)
	local tbl = deepCopy(set)
	tbl.hasToNegateMatch = not tbl.hasToNegateMatch
	return tbl
end

-- [a-zA-Z]
local alpha = createSet({
	ranges = {
		'a', 'z',
		'A', 'Z'
	},
})
-- [\0-\31\127]
local control = createSet({
	ranges = {
		'\0', '\31'
	},
	values = {
		['\127'] = true
	},
})
-- [0-9]
local digit = createSet({
	ranges = {
		'0', '9'
	},
})
-- [0-9a-fA-F]
local hex = createSet({
	ranges = {
		'0', '9',
		'a', 'f',
		'A', 'F'
	},
})
-- [a-z]
local lower = createSet({
	ranges = {
		'a', 'z'
	},
})
-- [!-/:-@[-`{-~]
local punctuation = createSet({
	ranges = {
		'!', '/',
		':', '@',
		'[', '`',
		'{', '~'
	},
})
-- [\f\n\r\t ]
local space = createSet({
	values = {
		['\f'] = true,
		['\n'] = true,
		['\r'] = true,
		['\t'] = true,
		[' '] = true
	},
})
-- [A-Z]
local upper = createSet({
	ranges = {
		'A', 'Z'
	},
})
-- [0-9a-zA-Z_]
local word = createSet({
	ranges = {
		'0', '9',
		'a', 'z',
		'A', 'Z'
	},
	values = {
		['_'] = true
	},
})

return {
	a = alpha,
	c = control,
	d = digit,
	h = hex,
	x = hex,
	l = lower,
	p = punctuation,
	s = space,
	u = upper,
	w = word,

	A = negateSet(alpha),
	C = negateSet(control),
	D = negateSet(digit),
	H = negateSet(hex),
	X = negateSet(hex),
	L = negateSet(lower),
	P = negateSet(punctuation),
	S = negateSet(space),
	U = negateSet(upper),
	W = negateSet(word),
}