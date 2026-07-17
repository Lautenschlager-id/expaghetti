----------------------------------------------------------------------------------------------------
local strformat = string.format
----------------------------------------------------------------------------------------------------
local parserHelpers = require("../../helpers/parser_helpers")
local consumeWhile = parserHelpers.consumeWhile
local isAlphanumericName = parserHelpers.isAlphanumericName
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_GROUP_NON_CAPTURING_BEHAVIOR = magicEnum.GROUP_NON_CAPTURING_BEHAVIOR
local ENUM_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local ENUM_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
----------------------------------------------------------------------------------------------------

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
	if peekChar == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
		return peekIndex, AST.GroupNonCapturing()

	-- Named capturing group: (?<name>...)
	-- Parse the name between `<` and `>`, validating each character
	elseif peekChar == ENUM_GROUP_NAME_OPEN then
		local name, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isAlphanumericName)

		if #name == 0 then
			return false, nil, errorsEnum.invalidGroupName
		end

		if afterLoopChar ~= ENUM_GROUP_NAME_CLOSE then
			return false, nil, errorsEnum.invalidGroupName
		end

		if state.metaData.groupNames[name] then
			return false, nil, strformat(errorsEnum.duplicatedGroupName, name)
		end

		state.metaData.groupNames[name] = true
		return afterLoopIndex, AST.GroupNamed(name)
	end
	
	return false, nil, errorsEnum.invalidGroupBehaviorindex
end
