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
	local nextStateIndex, errorMessage = Set.parse(state, tempTree)
	state.index = oldIndex
	
	if errorMessage then
		return false, errorMessage
	end
	
	return nextStateIndex, AST.Boundary(isNegated, tempTree[1])
end

Boundary.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local prevChar = stringIndex > 0 and state:getTargetCharacter(stringIndex) or nil
	local currChar = state:getTargetCharacter(stringIndex + 1)

	local isPrevInSet = prevChar and Set.match(currentElement.set, prevChar) or false
	local isCurrInSet = currChar and Set.match(currentElement.set, currChar) or false

	local hasBoundary = isPrevInSet ~= isCurrInSet
	if hasBoundary ~= currentElement.isNegated then
		return true, nil, stringIndex
	end
	return false
end

return Boundary
