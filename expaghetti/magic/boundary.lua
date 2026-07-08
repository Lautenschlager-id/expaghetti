----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BOUNDARY = elementsEnum.boundary
----------------------------------------------------------------------------------------------------
local Set = require("./magic/set")
local Boundary = { }

Boundary.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BOUNDARY
end

Boundary.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local prevChar = state.targetStringChars[stringIndex]
	local currChar = state.targetStringChars[stringIndex + 1]

	local isPrevInSet = prevChar and Set.match(currentElement.set, prevChar) or false
	local isCurrInSet = currChar and Set.match(currentElement.set, currChar) or false

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
