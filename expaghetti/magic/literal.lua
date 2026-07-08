----------------------------------------------------------------------------------------------------
local Quantifier = require("./magic/Quantifier")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local Literal = { }

Literal.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_LITERAL
end

Literal.parse = function(state, currentCharacter, tree)
	if Quantifier.isToken(state, tree) then
		return false, errorsEnum.nothingToRepeat
	end

	tree._index = tree._index + 1
	local node = AST.Literal(currentCharacter)
	
	node.unicodeValue = currentCharacter
	node.byteValue = string.byte(currentCharacter)

	if state.flags.i then
		node.isCaseInsensitive = true
		local lowerChar = string.lower(currentCharacter)
		local upperChar = string.upper(currentCharacter)
		
		node.unicodeLowerValue = lowerChar
		node.unicodeUpperValue = upperChar
		
		node.byteLowerValue = string.byte(lowerChar)
		node.byteUpperValue = string.byte(upperChar)
	end
	
	tree[tree._index] = node
	return state.index + 1
end

Literal.match = function(currentElement, currentCharacter, state)
	if currentElement.isCaseInsensitive then
		return currentCharacter == state:getExecutionLowerValue(currentElement)
			or currentCharacter == state:getExecutionUpperValue(currentElement)
	end
	
	return currentCharacter == state:getExecutionValue(currentElement)
end

return Literal