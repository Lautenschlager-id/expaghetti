--[[
    CAPTURE_REFERENCE module. Parses and matches backreferences.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local parser = require("helpers.parser")
local consumeWhileArray = parser.consumeWhileArray
local isAlphanumeric = parser.isAlphanumeric

local AST = require("ast")

local magicEnum = require("enums.magic")
local errorsEnum = require("enums.errors")
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local MAGIC_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local MAGIC_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
local ELEMENT_CAPTURE_REFERENCE = elementsEnum.CAPTURE_REFERENCE

local ERROR_INVALID_BACKREFERENCE_SYNTAX = errorsEnum.invalidBackreferenceSyntax
local ERROR_INVALID_BACKREFERENCE_NAME = errorsEnum.invalidBackreferenceName
local ERROR_UNTERMINATED_BACKREFERENCE = errorsEnum.unterminatedBackreference

--[[ Module ]]--
local CaptureReference = {}

--[[ Private Functions ]]--

--[[ Public API ]]--
CaptureReference.isElement = function(currentElement)
	return currentElement.type == ELEMENT_CAPTURE_REFERENCE
end

-- %1 --> reference capture N
CaptureReference.parseByIndex = function(state, currentCharacter, index)
	return index, AST.CaptureReference(currentCharacter + 0)
end

-- %k<NN> --> reference capture NN
CaptureReference.parseByName = function(state, currentCharacter, index, expression)
	if expression[index] ~= MAGIC_GROUP_NAME_OPEN then
		return false, ERROR_INVALID_BACKREFERENCE_SYNTAX
	end

	local name, afterIndex, closeChar = consumeWhileArray(expression, index, isAlphanumeric)

	if #name == 0 then
		return false, ERROR_INVALID_BACKREFERENCE_NAME
	end

	if closeChar ~= MAGIC_GROUP_NAME_CLOSE then
		return false, closeChar and ERROR_INVALID_BACKREFERENCE_NAME or ERROR_UNTERMINATED_BACKREFERENCE
	end

	return afterIndex + 1, AST.CaptureReference(tonumber(name) or name)
end

CaptureReference.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local initStringPositionList = state.metaData.captureStarts[currentElement.index]
	local endStringPositionList = state.metaData.captureEnds[currentElement.index]
	local length = state.metaData.captureCounts[currentElement.index] or 0

	if length == 0 then
		return false
	end

	local initStringPosition = initStringPositionList[length]
	local endStringPosition = endStringPositionList[length]

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

--[[ Return ]]--
return CaptureReference