local util = require("helper/util")

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
		NEG_LOOKAHEAD = '!', -- (?!abc)
		LOOKBEHIND = '<', -- (?<=abc) and (?<!abc)
		ANY = '.' -- .
	},
	class = {
		-- %x
		a = newSet({ 'a','z', 'A','Z' }), -- [a-zA-Z]
		d = newSet({ '0','9' }), -- [0-9]
		h = newSet({ '0','9', 'a','f', 'A','F' }), -- [0-9a-fA-F]
		l = newSet({ 'a','z' }), -- [a-z]
		s = newSet(nil, { '\f', '\n', '\r', '\t', ' ' }), -- [\f\n\r\t ]
		u = newSet({ 'A','Z' }), -- [A-Z]
		w = newSet({ '0','9', 'a','z', 'A','Z' }, { '_' }), -- [0-9a-zA-Z_]
		-- %X
		A = newSet({ 'a','z', 'A','Z' }, nil, true), -- [^a-zA-Z]
		D = newSet({ '0','9' }, nil, true), -- [^0-9]
		H = newSet({ '0','9', 'a','f', 'A','F' }, nil, true), -- [^0-9a-fA-F]
		L = newSet({ 'a','z' }, nil, true), -- [^a-z]
		S = newSet(nil, { '\f', '\n', '\r', '\t', ' ' }, true), -- [^\f\n\r\t ]
		U = newSet({ 'A','Z' }, nil, true), -- [^A-Z]
		W = newSet({ 'a','z', 'A','Z', '0','9' }, { '_' }, true) -- [^0-9a-zA-Z_]
	},
	specialClass = {
		controlChar = 'c', -- %cX
		any = newSet(nil, { '\n', '\r' }, true) -- [^\n\r]
	}
}

return enum