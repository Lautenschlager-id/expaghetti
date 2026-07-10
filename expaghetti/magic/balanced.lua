----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BALANCED = elementsEnum.balanced
----------------------------------------------------------------------------------------------------
local Balanced = { }

Balanced.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BALANCED
end

Balanced.parse = function(state, currentCharacter, index, expression)
	local opener = expression[index]
	local closer = expression[index + 1]
	if not opener or not closer then
		return false, errorsEnum.incompleteEscape
	end

	local opener, openerLower, openerUpper = state:getExecutionValues(opener)
	local closer, closerLower, closerUpper = state:getExecutionValues(closer)

	return index + 2, AST.Balanced(
		openerLower or opener,
		openerUpper or opener,
		closerLower or closer,
		closerUpper or closer
	)
end

Balanced.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1

	local lowerOpen, upperOpen, lowerClose, upperClose = 
		currentElement.lowerOpen, currentElement.upperOpen,
		currentElement.lowerClose, currentElement.upperClose

	-- The first character MUST match the opener
	local currentStrIndex = stringIndex + 1
	local firstChar = state:getTargetCharacter(currentStrIndex)
	if firstChar ~= lowerOpen and firstChar ~= upperOpen then
		return false
	end

	local depth = 1
	currentStrIndex = currentStrIndex + 1

	while currentStrIndex <= state.targetStringLength do
		local char = state:getTargetCharacter(currentStrIndex)
		if char == lowerClose or char == upperClose then
			depth = depth - 1
			if depth == 0 then
				return true, nil, currentStrIndex
			end
		elseif char == lowerOpen or char == upperOpen then
			-- It's possible opener == closer. If so, it was already handled by the first `if` and depth decreased.
			-- So this only increments depth if opener ~= closer.
			depth = depth + 1
		end
		currentStrIndex = currentStrIndex + 1
	end

	return false
end

return Balanced
