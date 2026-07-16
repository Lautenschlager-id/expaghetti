----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local parserHelpers = require("./helpers/parser_helpers")
local isPositiveOrZeroIntegerChar = parserHelpers.isPositiveOrZeroIntegerChar
local isPositiveIntegerChar = parserHelpers.isPositiveIntegerChar
local consumeWhile = parserHelpers.consumeWhile
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_CLOSE_GROUP = magicEnum.CLOSE_GROUP
local GROUP_RECURSION_ROOT_BEHAVIOR = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR
local GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS
local ENUM_GROUP_RECURSION_NAMED = magicEnum.GROUP_RECURSION_NAMED_BEHAVIOR
----------------------------------------------------------------------------------------------------

-- Helper to validate if a character is not a closing group parenthesis
local function isNotCloseGroup(char)
	return char ~= ENUM_CLOSE_GROUP
end

return function(state, peekIndex, peekChar)
	local node = AST.GroupRecursion()
	local finalIndex, nextChar, errorToThrow
	
	-- Handle root recursion e.g. `(?R)` or `(?0)`
	if peekChar == GROUP_RECURSION_ROOT_BEHAVIOR or peekChar == GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS then
		node.isRecursionRoot = true
		finalIndex, nextChar = state:readElement(peekIndex)
		errorToThrow = errorsEnum.invalidGroupBehavior
		
	-- Handle indexed target recursion e.g. `(?1)`, `(?123)`
	elseif isPositiveIntegerChar(peekChar) then
		local numStr, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isPositiveOrZeroIntegerChar)
		node.targetIndex = tonumber(peekChar .. numStr)
		finalIndex, nextChar = afterLoopIndex, afterLoopChar
		errorToThrow = errorsEnum.invalidGroupBehavior
		
	-- Handle named target recursion e.g. `(?&name)`
	elseif peekChar == ENUM_GROUP_RECURSION_NAMED then
		local nameStr, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isNotCloseGroup)

		errorToThrow = errorsEnum.invalidGroupRecursionName
		if #nameStr == 0 then
			return false, nil, errorToThrow
		end

		node.targetName = nameStr
		finalIndex, nextChar = afterLoopIndex, afterLoopChar
	else
		return false, nil, errorsEnum.invalidGroupBehavior
	end
	
	-- Common validation: The recursion declaration must immediately close
	if finalIndex and not state:isElement(nextChar) and nextChar == ENUM_CLOSE_GROUP then
		return finalIndex, node
	else
		return false, nil, errorToThrow
	end
end
