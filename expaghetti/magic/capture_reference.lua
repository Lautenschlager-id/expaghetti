----------------------------------------------------------------------------------------------------
local tblconcat = table.concat
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
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

CaptureReference.isNameToken = function(currentCharacter)
	return (currentCharacter >= 'A' and currentCharacter <= 'z')
		or (currentCharacter >= '0' and currentCharacter <= '9')
		or currentCharacter == '$'
end

CaptureReference.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE
end

-- %1 --> reference capture N
CaptureReference.parseByIndex = function(state, currentCharacter, index)
	return index, AST.CaptureReference(currentCharacter + 0)
end

-- %k<NN> --> reference capture NN
CaptureReference.parseByName = function(state, currentCharacter, index, expression)
	if expression[index] ~= ENUM_GROUP_NAME_OPEN then
		return false, errorsEnum.invalidBackreferenceSyntax
	end

	local name, nameIndex = { }, 0
	repeat
		index = index + 1
		currentCharacter = expression[index]

		if not currentCharacter then
			return false, errorsEnum.unterminatedBackreference
		elseif CaptureReference.isNameToken(currentCharacter) then
			nameIndex = nameIndex + 1
			name[nameIndex] = currentCharacter
		elseif nameIndex > 0 and currentCharacter == ENUM_GROUP_NAME_CLOSE then
			name = tblconcat(name)
			break
		else
			return false, errorsEnum.invalidBackreferenceName
		end
	until false

	return index + 1, AST.CaptureReference(tonumber(name) or name)
end

CaptureReference.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local initStringPositionList = state.metaData.captureStarts[currentElement.index]
	local endStringPositionList = state.metaData.captureEnds[currentElement.index]

	if not initStringPositionList or #initStringPositionList == 0 then
		return false
	end

	local initStringPosition = initStringPositionList[#initStringPositionList]
	local endStringPosition = endStringPositionList[#endStringPositionList]

	if stringIndex + (endStringPosition - initStringPosition + 1) > state.targetStringLength then
		return false
	end

	local currentCharacter
	for backreferencePosition = initStringPosition, endStringPosition do
		stringIndex = stringIndex + 1
		currentCharacter = state:getTargetCharacter(stringIndex)

		if currentCharacter ~= state:getTargetCharacter(backreferencePosition) then
			return false
		end
	end

	return true, nil, stringIndex
end

return CaptureReference