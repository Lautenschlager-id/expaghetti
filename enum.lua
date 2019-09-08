local newSet
do
	local setHandler = require("handler/set"):new()
	newSet = function(range, push, negate)
		setHandler:open()

		if range then
			for i = 1, #range, 2 do
				setHandler:range(range[i], range[i + 1])
			end
		end
		if push then
			for i = 1, #push do
				setHandler:push(push[i])
			end
		end
		if negate then
			setHandler:negate()
		end

		return setHandler:get(), setHandler:close()
	end
end

local enum = { }

enum.magic = {
	ESCAPE = '%', -- %%
	OPEN_SET = '[', -- [abc]
	CLOSE_SET = ']', -- [abc]
	NEGATED_SET = '^', -- [^abc]
	RANGE = '-', -- [0-9]
	OPEN_GROUP = '(', -- (abc)
	CLOSE_GROUP = ')', -- (abc)
	GROUP_BEHAVIOR = '?', -- (?xabc)
	NON_CAPTURING_GROUP = ':', -- (?:abc)
	POSITIVE_LOOKAHEAD = '=', -- (?=abc)
	NEGATIVE_LOOKAHEAD = '!', -- (?!abc)
	LOOKBEHIND = '<', -- (?<=abc) and (?<!abc)
	ANY = '.', -- .
	OPEN_QUANTIFIER = '{', -- {1,2}
	CLOSE_QUANTIFIER = '}', -- {1,2}
	QUANTIFIER_SEPARATOR = ',', -- {1,2}
	ONE_OR_MORE = '+', -- a+
	ZERO_OR_MORE = '*', -- a*
	ZERO_OR_ONE = '?', -- a?
	LAZY = '?', -- a+?
	BEGINNING = '^', -- ^a
	END = '$', -- a$
	ALTERNATE = '|', -- a|b
}

enum.class = {
	-- %x
	a = newSet({ 'a','z', 'A','Z' }), -- [a-zA-Z]
	d = newSet({ '0','9' }), -- [0-9]
	h = newSet({ '0','9', 'a','f', 'A','F' }), -- [0-9a-fA-F]
	l = newSet({ 'a','z' }), -- [a-z]
	p = newSet({ '!','/', ':','@', '[','`', '{','~' }), -- [!-/:-@[-`{-~]
	s = newSet(nil, { '\f', '\n', '\r', '\t', ' ' }), -- [\f\n\r\t ]
	u = newSet({ 'A','Z' }), -- [A-Z]
	w = newSet({ '0','9', 'a','z', 'A','Z' }, { '_' }), -- [0-9a-zA-Z_]
	-- %X
	A = newSet({ 'a','z', 'A','Z' }, nil, true), -- [^a-zA-Z]
	D = newSet({ '0','9' }, nil, true), -- [^0-9]
	H = newSet({ '0','9', 'a','f', 'A','F' }, nil, true), -- [^0-9a-fA-F]
	L = newSet({ 'a','z' }, nil, true), -- [^a-z]
	P = newSet({ '!','/', ':','@', '[','`', '{','~' }, nil, true), -- [^!-/:-@[-`{-~]
	S = newSet(nil, { '\f', '\n', '\r', '\t', ' ' }, true), -- [^\f\n\r\t ]
	U = newSet({ 'A','Z' }, nil, true), -- [^A-Z]
	W = newSet({ 'a','z', 'A','Z', '0','9' }, { '_' }, true) -- [^0-9a-zA-Z_]
}
enum.class.x = enum.class.h
enum.class.X = enum.class.H

enum.specialClass = {
	controlChar = 'c', -- %cX
	any = newSet(nil, { '\n', '\r' }, true), -- [^\n\r]
	encode = 'e', -- %uFFFF, but %e (encode) because %u exists for the uppercase set.
	boundary = 'b',
	notBoundary = 'B'
}

enum.anchor = {
	BEGINNING = { type = "anchor", anchor = enum.magic.BEGINNING },
	END = { type = "anchor", anchor = enum.magic.END },
	BOUNDARY = { type = "anchor", anchor = enum.specialClass.boundary },
	NOTBOUNDARY = { type = "anchor", anchor = enum.specialClass.notBoundary }
}

enum.flag = {
	unicode = 'u',
	insensitive = 'i',
	multiline = 'm', -- match-only
}

enum.option = {
	DISABLE_ANCHOR = '^',
	DISABLE_SET = '[',
	DISABLE_GROUP = '(',
	DISABLE_QUANTIFIER = '{',
	DISABLE_ALTERNATE = '|',
	DISABLE_ESCAPE = '%',
	DISABLE_MAGIC = 'X'
}

enum.error = {
	-- TODO
}

enum.limit = {
	QUANTIFIER_MAX = 2 ^ 15,
	QUANTIFIER_MIN = 0
}

return enum