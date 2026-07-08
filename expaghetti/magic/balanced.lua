----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BALANCED = elementsEnum.balanced
----------------------------------------------------------------------------------------------------
local Balanced = { }

Balanced.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BALANCED
end

Balanced.getExecutionOpen = function(element, state)
	if state.flags.u then
		if state.flags.i then
			return string.lower(element.open), string.upper(element.open)
		end
		return element.open
	else
		if state.flags.i then
			return string.byte(string.lower(element.open)), string.byte(string.upper(element.open))
		end
		return string.byte(element.open)
	end
end

Balanced.getExecutionClose = function(element, state)
	if state.flags.u then
		if state.flags.i then
			return string.lower(element.close), string.upper(element.close)
		end
		return element.close
	else
		if state.flags.i then
			return string.byte(string.lower(element.close)), string.byte(string.upper(element.close))
		end
		return string.byte(element.close)
	end
end

Balanced.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local opener, openerAlt = Balanced.getExecutionOpen(currentElement, state)
	local closer, closerAlt = Balanced.getExecutionClose(currentElement, state)

	-- The first character MUST match the opener
	local currentStrIndex = stringIndex + 1
	local firstChar = state:getTargetCharacter(currentStrIndex)
	if firstChar ~= opener and firstChar ~= openerAlt then
		return false
	end

	local depth = 1
	currentStrIndex = currentStrIndex + 1

	while currentStrIndex <= state.targetStringLength do
		local char = state:getTargetCharacter(currentStrIndex)
		if char == closer or char == closerAlt then
			depth = depth - 1
			if depth == 0 then
				return true, nil, currentStrIndex
			end
		elseif char == opener or char == openerAlt then
			-- It's possible opener == closer. If so, it was already handled by the first `if` and depth decreased.
			-- So this only increments depth if opener ~= closer.
			depth = depth + 1
		end
		currentStrIndex = currentStrIndex + 1
	end

	return false
end

return Balanced
