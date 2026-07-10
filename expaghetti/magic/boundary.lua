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
	local peekIndex, nextElement = state:readElement(index)
	if not Set.isToken(nextElement) then
		return false, errorsEnum.missingFrontierSet
	end

	local oldIndex = state.index
	state.index = index
	local tempTree = { _index = 0 }
	local nextStateIndex, errorMessage = Set.parse(state, tempTree)
	state.index = oldIndex
	
	if errorMessage then return false, errorMessage end
	
	return nextStateIndex, AST.Boundary(isNegated, tempTree[1])
end

Boundary.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local prevChar = stringIndex > 0 and state:getTargetCharacter(stringIndex) or nil
	local currChar = state:getTargetCharacter(stringIndex + 1)

	local isPrevInSet = prevChar and Set.match(currentElement.set, prevChar, state) or false
	local isCurrInSet = currChar and Set.match(currentElement.set, currChar, state) or false

	if currentElement.isNegated then
		-- %F (non-frontier boundary): Matches if BOTH are in set, or NEITHER are in set
		if isPrevInSet == isCurrInSet then
			return true, nil, stringIndex
		end
	else
		-- %f (frontier boundary): Matches if EXACTLY ONE is in set
		if isPrevInSet ~= isCurrInSet then
			return true, nil, stringIndex
		end
	end

	return false
end

return Boundary
