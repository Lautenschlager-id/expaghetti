--[[
	Parser and matcher for backreferences.

	Supports numeric (`%1`) and named (`%k<name>`) backreferences.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local BackreferenceNode = require("expaghetti.core.ast").Backreference
local ParserHelpers = require("expaghetti.helpers.parser")

--[[ Enums ]]--
local ELEMENT_BACKREFERENCE = require("expaghetti.enums.elements").BACKREFERENCE

local Errors = require("expaghetti.enums.errors")

local Magic = require("expaghetti.enums.magic")

--[[ Aliases ]]--
local consumeWhileArray = ParserHelpers.consumeWhileArray
local isAlphanumeric = ParserHelpers.isAlphanumeric

local ERROR_INVALID_BACKREFERENCE_NAME = Errors.invalidBackreferenceName
local ERROR_INVALID_BACKREFERENCE_SYNTAX = Errors.invalidBackreferenceSyntax
local ERROR_UNTERMINATED_BACKREFERENCE = Errors.unterminatedBackreference

local MAGIC_GROUP_NAME_OPEN = Magic.GROUP_NAME_OPEN
local MAGIC_GROUP_NAME_CLOSE = Magic.GROUP_NAME_CLOSE

--[[ Module ]]--
local Backreference = {}

--- Returns whether an AST element is a backreference.
---@param currentElement ASTElement The element to test.
---@return boolean isElement Whether the element is a backreference.
Backreference.isElement = function(currentElement)
	return currentElement.type == ELEMENT_BACKREFERENCE
end

--- Parses a numeric backreference (`%1`).
---@param state ParserState The parser state.
---@param currentCharacter string The backreference character.
---@param index number The current pattern index.
---@return number|boolean nextIndex The next pattern index, or false if parsing failed.
---@return BackreferenceNode|string element The parsed backreference or parser error message.
Backreference.parseByIndex = function(state, currentCharacter, index)
	return index, BackreferenceNode(currentCharacter + 0)
end

--- Parses a named backreference (`%k<name>`).
---@param state ParserState The parser state.
---@param currentCharacter string The escape character.
---@param index number The current pattern index.
---@param expression CharacterArray The pattern characters.
---@return number|boolean nextIndex The next pattern index, or false if parsing failed.
---@return BackreferenceNode|string element The parsed backreference or parser error message.
Backreference.parseByName = function(state, currentCharacter, index, expression)
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

	local numericName = tonumber(name)
	local node = BackreferenceNode(numericName or name)
	if not numericName then
		local stateMetadata = state.metadata
		local refIndex = stateMetadata.namedReferenceIndex + 1
		stateMetadata.namedReferenceIndex = refIndex
		stateMetadata.namedReferences[refIndex] = node
	end
	return afterIndex + 1, node
end

--- Matches a previously captured value against the target string.
---@param currentElement BackreferenceNode The backreference element.
---@param state MatchState The matcher state.
---@return boolean hasMatched Whether the backreference matched successfully.
---@return nil
---@return number|nil stringIndex The updated target string index.
Backreference.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1

	local stateMetadata, elementIndex = state.metadata, currentElement.index

	local initStringPositionList = stateMetadata.captureStarts[elementIndex]
	local endStringPositionList = stateMetadata.captureEnds[elementIndex]
	local length = stateMetadata.captureCounts[elementIndex] or 0

	if length == 0 then
		return false
	end

	local initStringPosition = initStringPositionList[length]
	local endStringPosition = endStringPositionList[length]

	if stringIndex + (endStringPosition - initStringPosition + 1) > state.targetStringLength then
		return false
	end

	for backreferencePosition = initStringPosition, endStringPosition do
		stringIndex = stringIndex + 1
		local targetCharacter = state:getTargetCharacter(stringIndex)

		if targetCharacter ~= state:getTargetCharacter(backreferencePosition) then
			return false
		end
	end

	return true, nil, stringIndex
end

return Backreference