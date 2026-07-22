--[[
    Parses capture-oriented group behaviors.
]]

--[[ Globals ]]--
local string = string
local strformat = string.format

--[[ Dependencies ]]--
local parser = require("helpers.parser")
local consumeWhile = parser.consumeWhile
local isAlphanumericName = parser.isAlphanumericName

local AST = require("ast")
local magicEnum = require("enums.magic")
local errorsEnum = require("enums.errors")

--[[ Enum Aliases ]]--
local MAGIC_GROUP_NON_CAPTURING_BEHAVIOR = magicEnum.GROUP_NON_CAPTURING_BEHAVIOR
local MAGIC_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local MAGIC_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
local ERROR_INVALID_GROUP_NAME = errorsEnum.invalidGroupName
local ERROR_DUPLICATED_GROUP_NAME = errorsEnum.duplicateGroupName
local ERROR_INVALID_GROUP_BEHAVIOR_INDEX = errorsEnum.invalidGroupBehaviorIndex

--[[ Return ]]--
-- Parses capture-oriented group behaviors:
--	Standard capturing groups:	(...)
--	Non-capturing groups:		(?:...)
--	Named capturing groups:		(?<name>...)
return function(state, index, peekIndex, peekChar)
	-- No behavior token found: standard capturing group
	if not peekIndex then
		return index, AST.GroupCapture()
	end
	
	-- Non-capturing group: (?:...)
	if peekChar == MAGIC_GROUP_NON_CAPTURING_BEHAVIOR then
		return peekIndex, AST.GroupNonCapturing()

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

		if state.metaData.groupNames[name] then
			return false, nil, strformat(ERROR_DUPLICATED_GROUP_NAME, name)
		end

		state.metaData.groupNames[name] = true
		return afterLoopIndex, AST.GroupNamed(name)
	end
	
	return false, nil, ERROR_INVALID_GROUP_BEHAVIOR_INDEX
end
