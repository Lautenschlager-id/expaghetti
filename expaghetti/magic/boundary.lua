----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BOUNDARY = elementsEnum.boundary
----------------------------------------------------------------------------------------------------
local Boundary = { }

Boundary.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BOUNDARY
end

Boundary.match = function(currentElement, stringIndex, splitStr, strLength, matchSet)
	local prevChar = splitStr[stringIndex]
	local currChar = splitStr[stringIndex + 1]

	local isPrevInSet = prevChar and matchSet(currentElement.set, prevChar) or false
	local isCurrInSet = currChar and matchSet(currentElement.set, currChar) or false

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
