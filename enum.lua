local util = require("helper/util")

local boundaryHandler = require("handler/boundary"):new()

local newSet, newAlternate
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

	local queueFactory = require("queue")
	local alternateFactory = require("handler/alternate")
	newAlternate = function(exp, negate)
		local queueHandler = queueFactory:new()
		local alternateHandler = alternateFactory:new()

		for i = 1, #exp do
			queueHandler:push(exp[i])
			alternateHandler:push(i)
		end

		-- no "negate" implementation yet
		return alternateHandler:generate(queueHandler)
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
	},
	class = {
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
	},
	specialClass = {
		controlChar = 'c', -- %cX
		any = newSet(nil, { '\n', '\r' }, true), -- [^\n\r]
		encode = 'e', -- %uFFFF, but %e (encode) because %u exists for the uppercase set.
	}
}
enum.class.b = newAlternate({ boundaryHandler:push(enum.magic.BEGINNING):get(), boundaryHandler:push(enum.magic.END):get(), enum.class.W }) -- ^|$|%W
enum.class.B = newAlternate({ boundaryHandler:push(enum.magic.BEGINNING):get(), boundaryHandler:push(enum.magic.END):get(), enum.class.W }, true) -- not ^|$|%W
enum.class.x = enum.class.h
enum.class.X = enum.class.H

return enum