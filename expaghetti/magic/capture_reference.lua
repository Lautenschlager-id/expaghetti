----------------------------------------------------------------------------------------------------
local tblconcat = table.concat
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local ENUM_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
local ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE = require("./enums/elements").capture_reference
----------------------------------------------------------------------------------------------------
local CaptureReference = { }

CaptureReference.isIntToken = function(currentCharacter)
	return currentCharacter >= '1' and currentCharacter <= '9'
end

CaptureReference.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE
end

-- %1 --> reference capture N
CaptureReference.parseInt = function(currentCharacter, index)
	currentCharacter = currentCharacter + 0

	--[[
		{
			type = "capture_reference",
			index = 1
		}
	]]
	return index, {
		type = ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE,
		index = currentCharacter
	}
end

-- %k<NN> --> reference capture NN
CaptureReference.parseString = function(currentCharacter, index, expression)
	if expression[index] ~= ENUM_GROUP_NAME_OPEN then
		return false, errorsEnum.invalidBackreferenceSyntax
	end

	local name, nameIndex = { }, 0
	repeat
		index = index + 1
		currentCharacter = expression[index]

		if not currentCharacter then
			return false, errorsEnum.unterminatedBackreference
		-- The first character must be letter
		elseif (currentCharacter >= 'A' and currentCharacter <= 'z')
			or (currentCharacter >= '0' and currentCharacter <= '9')
			or currentCharacter == '$' then

			nameIndex = nameIndex + 1
			name[nameIndex] = currentCharacter
		elseif nameIndex > 0 and currentCharacter == ENUM_GROUP_NAME_CLOSE then
			name = tblconcat(name)
			break
		else
			return false, errorsEnum.invalidBackreferenceName
		end
	until false

	return index + 1, {
		type = ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE,
		index = tonumber(name) or name
	}
end

CaptureReference.match = function(currentElement, stringIndex, splitStr, strLength, matcherMetaData)
	local initStringPosition, endStringPosition =
		matcherMetaData.groupCapturesInitStringPositions[currentElement.index],
		matcherMetaData.groupCapturesEndStringPositions[currentElement.index]

	if not initStringPosition then
		return false
	elseif stringIndex + (endStringPosition - initStringPosition + 1) > strLength then
		return false
	end

	local currentCharacter
	for backreferencePosition = initStringPosition, endStringPosition do
		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]

		if currentCharacter ~= splitStr[backreferencePosition] then
			return false
		end
	end

	return true, nil, stringIndex
end

return CaptureReference