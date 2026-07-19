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
	if Quantifier.isToken(state, tree) then
		return errorsEnum.nothingToRepeat
	end

	tree._index = tree._index + 1

	local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter)
	local node = AST.Literal(value, lowerValue, upperValue)

	tree[tree._index] = node

	state.index = state.index + 1
	return nil
end

Literal.match = function(currentElement, _, currentCharacter)
	if currentElement.isCaseInsensitive then
		return currentCharacter == currentElement.lowerValue
			or currentCharacter == currentElement.upperValue
	end
	return currentCharacter == currentElement.value
end

return Literal