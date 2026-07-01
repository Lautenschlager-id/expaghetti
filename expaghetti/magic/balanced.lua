----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_BALANCED = elementsEnum.balanced
----------------------------------------------------------------------------------------------------
local Balanced = { }

Balanced.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_BALANCED
end

Balanced.match = function(currentElement, stringIndex, splitStr, strLength)
	local opener = currentElement.open
	local closer = currentElement.close

	-- The first character MUST match the opener
	local currentStrIndex = stringIndex + 1
	if splitStr[currentStrIndex] ~= opener then
		return false
	end

	local depth = 1
	currentStrIndex = currentStrIndex + 1

	while currentStrIndex <= strLength do
		local char = splitStr[currentStrIndex]
		if char == closer then
			depth = depth - 1
			if depth == 0 then
				return true, nil, currentStrIndex
			end
		elseif char == opener then
			-- It's possible opener == closer. If so, it was already handled by the first `if` and depth decreased.
			-- So this only increments depth if opener ~= closer.
			depth = depth + 1
		end
		currentStrIndex = currentStrIndex + 1
	end

	return false
end

return Balanced
