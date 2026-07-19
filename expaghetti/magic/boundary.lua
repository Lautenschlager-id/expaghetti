----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BOUNDARY = elementsEnum.boundary
----------------------------------------------------------------------------------------------------
local Boundary = { }

Boundary.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BOUNDARY
end

Boundary.parse = function(state, index, isNegated)
	local _, nextElement = state:readElement(index)
	if not Set.isToken(nextElement) then
		return false, errorsEnum.missingFrontierSet
	end

	local oldIndex = state.index
	state.index = index
	local tempTree = { _index = 0 }
	local errorMessage = Set.parse(state, tempTree)
	local nextStateIndex = state.index
	state.index = oldIndex
	
	if errorMessage then
		return false, errorMessage
	end
	
	return nextStateIndex, AST.Boundary(isNegated, tempTree[1])
end

Boundary.match = function(currentElement, state, currentCharacter)
	local stringIndex = state.stringIndex - 1
	local previousChararacter = stringIndex > 0 and state:getTargetCharacter(stringIndex) or nil

	local isPrevInSet = previousChararacter and Set.match(currentElement.set, state, previousChararacter) or false
	local isCurrInSet = currentCharacter and Set.match(currentElement.set, state, currentCharacter) or false

	local hasBoundary = isPrevInSet ~= isCurrInSet
	if hasBoundary ~= currentElement.isNegated then
		return true, nil, stringIndex
	end
	return false
end

return Boundary
