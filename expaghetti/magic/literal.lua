----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
local Quantifier = require("./magic/Quantifier")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
----------------------------------------------------------------------------------------------------
local Literal = { }

Literal.execute = function(currentCharacter, index, expression, tree)
	local value
	if Escaped.is(currentCharacter) then
		index, value = Escaped.execute(currentCharacter, index, expression, tree)
		if not index then
			-- value = error message
			return false, value
		end
	else
		--[[
			{
				type = "literal",
				value = 'a',
				quantifier = nil,
			}
		]]
		value = {
			type = ENUM_ELEMENT_TYPE_LITERAL,
			value = currentCharacter
		}

		index = index + 1
	end

	index = Quantifier.try(index, expression, value)

	tree._index = tree._index + 1
	tree[tree._index] = value

	return index
end

return Literal