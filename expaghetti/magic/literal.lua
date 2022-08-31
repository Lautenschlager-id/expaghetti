----------------------------------------------------------------------------------------------------
local Quantifier = require("./magic/Quantifier")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
----------------------------------------------------------------------------------------------------
local Literal = { }

Literal.parse = function(currentCharacter, index, tree, charactersList)
	-- tree is a bad parameter, but if it's true then an error is thrown anyway
	if Quantifier.isToken(index, charactersList, tree) then
		return false, errorsEnum.nothingToRepeat
	end

	--[[
		{
			type = "literal",
			value = 'a',
			quantifier = nil,
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_LITERAL,
		value = currentCharacter
	}

	return index + 1
end

Literal.match = function(currentElement, currentCharacter)
	return currentElement.value == currentCharacter
end

return Literal