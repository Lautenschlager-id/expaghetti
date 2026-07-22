--[[
    Definitions of all regex magic characters and group behavior tokens.
]]

local Magic = {
	ALTERNATE_BRANCH_SEPARATOR = '|', -- a|b

	ANCHOR_START = '^', -- ^a
	ANCHOR_END = '$', -- a$

	ANY = '.', -- .

	ESCAPE = '%', -- %%

	GROUP_OPEN = '(', -- (abc)
	GROUP_CLOSE = ')', -- (abc)
	GROUP_BEHAVIOR_PREFIX = '?', -- (?xabc)

	GROUP_ATOMIC_BEHAVIOR = '>', -- (?>abc)
	GROUP_BRANCH_RESET_BEHAVIOR = '|', -- (?|abc)
	GROUP_COMMENT_BEHAVIOR = '#', -- (?# any message )
	GROUP_NON_CAPTURING_BEHAVIOR = ':', -- (?:abc)

	GROUP_LOOKAROUND_POSITIVE_BEHAVIOR = '=', -- (?=abc)
	GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR = '!', -- (?!abc)
	GROUP_LOOKBEHIND_BEHAVIOR = '<', -- (?<=abc) and (?<!abc)

	GROUP_NAME_OPEN = '<', -- (?<name>abc)
	GROUP_NAME_CLOSE = '>', -- (?<name>abc)

	GROUP_RECURSION_ROOT_BEHAVIOR = 'R', -- (?R)
	GROUP_RECURSION_ROOT_ALIAS = '0', -- (?0)
	GROUP_RECURSION_NAMED_BEHAVIOR = '&', -- (?&name)
	
	GROUP_SCOPED_FLAGS_BEHAVIOR = ':', -- (?i:abc)
	GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR = '-', -- (?-i:abc)

	QUANTIFIER_OPEN = '{', -- {1,2}
	QUANTIFIER_CLOSE = '}', -- {1,2}
	QUANTIFIER_SEPARATOR = ',', -- {1,2}

	QUANTIFIER_ONE_OR_MORE = '+', -- a+
	QUANTIFIER_ZERO_OR_MORE = '*', -- a*
	QUANTIFIER_ZERO_OR_ONE = '?', -- a?
	QUANTIFIER_LAZY = '?', -- a+?
	QUANTIFIER_POSSESSIVE = '+', -- a++

	SET_OPEN = '[', -- [abc]
	SET_CLOSE = ']', -- [abc]
	SET_NEGATE_PREFIX = '^', -- [^abc]
	SET_RANGE_SEPARATOR = '-', -- [0-9]
}

local _hashmap = { }
for _, value in next, Magic do
	_hashmap[value] = true
end

Magic._hashmap = _hashmap

return Magic