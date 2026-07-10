----------------------------------------------------------------------------------------------------
local Quantifier = require("./magic/Quantifier")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
local ENUM_FLAG_UNICODE = require("./enums/flags").flags.UNICODE
----------------------------------------------------------------------------------------------------
local Literal = { }

Literal.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_LITERAL
end

Literal.parse = function(state, currentCharacter, tree)
	-- tree is a bad parameter, but if it's true then an error is thrown anyway
	if Quantifier.isToken(state, tree) then
		return false, errorsEnum.nothingToRepeat
	end

	tree._index = tree._index + 1

	local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter)
	local node = AST.Literal(value, lowerValue, upperValue)

	tree[tree._index] = node

	return state.index + 1
end

Literal.match = function(currentElement, currentCharacter)
	if currentElement.isCaseInsensitive then
		return currentCharacter == currentElement.lowerValue
			or currentCharacter == currentElement.upperValue
	end
	return currentCharacter == currentElement.value
end

return Literal