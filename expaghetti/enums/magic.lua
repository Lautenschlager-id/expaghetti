local characters = {
	ANCHOR_START = '^', -- ^a
	ANCHOR_END = '$', -- a$

	ALTERNATE_SEPARATOR = '|', -- a|b

	ANY_CHARACTER = '.', -- .

	ESCAPE_CHARACTER = '%', -- %%

	OPEN_GROUP = '(', -- (abc)
	CLOSE_GROUP = ')', -- (abc)
	GROUP_BEHAVIOR_CHARACTER = '?', -- (?xabc)
	GROUP_NON_CAPTURING_BEHAVIOR = ':', -- (?:abc)
	GROUP_ATOMIC_BEHAVIOR = '>', -- (?>abc)
	GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR = '=', -- (?=abc)
	GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR = '!', -- (?!abc)
	GROUP_LOOKBEHIND_BEHAVIOR = '<', -- (?<=abc) and (?<!abc)
	GROUP_NAME_OPEN = '<', -- (?<name>abc)
	GROUP_NAME_CLOSE = '>', -- (?<name>abc)

	OPEN_QUANTIFIER = '{', -- {1,2}
	CLOSE_QUANTIFIER = '}', -- {1,2}
	QUANTIFIER_SEPARATOR_CHARACTER = ',', -- {1,2}
	ONE_OR_MORE_QUANTIFIER = '+', -- a+
	ZERO_OR_MORE_QUANTIFIER = '*', -- a*
	ZERO_OR_ONE_QUANTIFIER = '?', -- a?
	LAZY_QUANTIFIER = '?', -- a+?
	POSSESSIVE_QUANTIFIER = '+', -- a++

	OPEN_SET = '[', -- [abc]
	CLOSE_SET = ']', -- [abc]
	NEGATE_SET = '^', -- [^abc]
	SET_RANGE_SEPARATOR = '-', -- [0-9]
}
----------------------------------------------------------------------------------------------------
local _hasmap = { }
for _, v in next, characters do
	_hasmap[v] = true
end

characters._hasmap = _hasmap

return characters