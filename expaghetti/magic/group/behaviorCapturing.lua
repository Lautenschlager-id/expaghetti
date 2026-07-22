--[[
    Parser for capturing group behaviors: `(...)`, `(?:...)`, `(?<name>...)`.
]]

--[[ Globals ]]--
local string_format = string.format

--[[ Dependencies ]]--
local AST = require("ast")
local Errors = require("enums.errors")
local Magic = require("enums.magic")
local ParserHelpers = require("helpers.parser")

--[[ Aliases ]]--
local consumeWhile = ParserHelpers.consumeWhile
local isAlphanumericName = ParserHelpers.isAlphanumericName

local GroupCaptureNode = AST.GroupCapture
local GroupNonCapturingNode = AST.GroupNonCapturing
local GroupNamedNode = AST.GroupNamed

local MAGIC_GROUP_NAME_CLOSE = Magic.GROUP_NAME_CLOSE
local MAGIC_GROUP_NAME_OPEN = Magic.GROUP_NAME_OPEN
local MAGIC_GROUP_NON_CAPTURING_BEHAVIOR = Magic.GROUP_NON_CAPTURING_BEHAVIOR

local ERROR_DUPLICATE_GROUP_NAME = Errors.duplicateGroupName
local ERROR_INVALID_GROUP_BEHAVIOR_INDEX = Errors.invalidGroupBehaviorIndex
local ERROR_INVALID_GROUP_NAME = Errors.invalidGroupName

--[[ Module ]]--

--- Parses a capturing group behavior.
---@param state ParserState The current parser state.
---@param index number The parser index of the group opening.
---@param peekIndex number|nil The parser index after the behavior token, if present.
---@param peekChar string|table|nil The behavior token following `(?`, if present.
---@return number|false nextIndex The parser index after the parsed behavior, or false on failure.
---@return table|nil group The parsed AST group node.
---@return string|nil errorMessage The parser error message when parsing fails.
return function(state, index, peekIndex, peekChar)
	-- No behavior token found: standard capturing group
	if not peekIndex then
		return index, GroupCaptureNode()
	end
	
	-- Non-capturing group: (?:...)
	if peekChar == MAGIC_GROUP_NON_CAPTURING_BEHAVIOR then
		return peekIndex, GroupNonCapturingNode()

	-- Named capturing group: (?<name>...)
	-- Parse the name between `<` and `>`, validating each character
	elseif peekChar == MAGIC_GROUP_NAME_OPEN then
		local name, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isAlphanumericName)

		if #name == 0 then
			return false, nil, ERROR_INVALID_GROUP_NAME
		end

		if afterLoopChar ~= MAGIC_GROUP_NAME_CLOSE then
			return false, nil, ERROR_INVALID_GROUP_NAME
		end

		local groupNames = state.metadata.groupNames
		if groupNames[name] then
			return false, nil, string_format(ERROR_DUPLICATE_GROUP_NAME, name)
		end

		groupNames[name] = true
		return afterLoopIndex, GroupNamedNode(name)
	end
	
	return false, nil, ERROR_INVALID_GROUP_BEHAVIOR_INDEX
end
