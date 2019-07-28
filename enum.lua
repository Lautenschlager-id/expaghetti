local util = require("util")

local enum = {
	magic = {
		ESCAPE = '%', -- %%
		OPEN_SET = '[', -- [abc]
		CLOSE_SET = ']', -- [abc]
		NEGATED_SET = '^', -- [^abc]
		RANGE = '-', -- [0-9]
		OPEN_GROUP = '(', -- (abc)
		CLOSE_GROUP = ')', -- (abc)
		GROUP_BEHAVIOR = '?', -- (?xabc)
		NON_CAPTURING_GROUP = ':', -- (?:abc)
		POS_LOOKAHEAD = '=', -- (?=abc)
		NEG_LOOKAHEAD = '!' -- (?!abc)
	},
	class = {
		-- %x
		a = "[a-zA-Z]",
		d = "[0-9]",
		h = "[0-9a-fA-F]",
		l = "[a-z]",
		s = "[\f\n\r\t ]",
		u = "[A-Z]",
		w = "[a-zA-Z0-9_]",
		-- %X
		A = "[^a-zA-Z]",
		D = "[^0-9]",
		H = "[^0-9a-fA-F]",
		L = "[^a-z]",
		S = "[^\f\n\r\t ]",
		U = "[^A-Z]",
		W = "[^a-zA-Z0-9_]"
	},
	specialClass = {
		controlChar = 'c',
		['.'] = "[^\n\r]" -- Not working yet
	}
}

for k in next, enum.class do
	enum.class[k] = util.strToTbl(enum.class[k])
end

return enum