--[[
    Parses recursion-oriented group behaviors.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local AST = require("ast")

local parser = require("helpers.parser")
local isPositiveOrZeroIntegerChar = parser.isPositiveOrZeroIntegerChar
local isPositiveIntegerChar = parser.isPositiveIntegerChar
local consumeWhile = parser.consumeWhile

local magicEnum = require("enums.magic")
local errorsEnum = require("enums.errors")

--[[ Enum Aliases ]]--
local MAGIC_GROUP_CLOSE = magicEnum.GROUP_CLOSE
local MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR
local MAGIC_GROUP_RECURSION_ROOT_ALIAS = magicEnum.GROUP_RECURSION_ROOT_ALIAS
local MAGIC_GROUP_RECURSION_NAMED = magicEnum.GROUP_RECURSION_NAMED_BEHAVIOR
local ERROR_INVALID_GROUP_BEHAVIOR = errorsEnum.invalidGroupBehavior
local ERROR_INVALID_GROUP_RECURSION_NAME = errorsEnum.invalidGroupRecursionName

--[[ Private Functions ]]--
-- Helper to validate if a character is not a closing group parenthesis
local isNotCloseGroup = function(char)
	return char ~= MAGIC_GROUP_CLOSE
end

--[[ Return ]]--
return function(state, peekIndex, peekChar)
	local node = AST.GroupRecursion()
	local finalIndex, nextChar, errorToThrow
	
	-- Handle root recursion e.g. `(?R)` or `(?0)`
	if peekChar == MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR or peekChar == MAGIC_GROUP_RECURSION_ROOT_ALIAS then
		node.isRecursionRoot = true
		finalIndex, nextChar = state:readElement(peekIndex)
		errorToThrow = ERROR_INVALID_GROUP_BEHAVIOR
		
	-- Handle indexed target recursion e.g. `(?1)`, `(?123)`
	elseif isPositiveIntegerChar(peekChar) then
		local numStr, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isPositiveOrZeroIntegerChar)
		node.targetIndex = tonumber(peekChar .. numStr)
		finalIndex, nextChar = afterLoopIndex, afterLoopChar
		errorToThrow = ERROR_INVALID_GROUP_BEHAVIOR
		
	-- Handle named target recursion e.g. `(?&name)`
	elseif peekChar == MAGIC_GROUP_RECURSION_NAMED then
		local nameStr, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isNotCloseGroup)

		errorToThrow = ERROR_INVALID_GROUP_RECURSION_NAME
		if #nameStr == 0 then
			return false, nil, errorToThrow
		end

		node.targetName = nameStr
		finalIndex, nextChar = afterLoopIndex, afterLoopChar
	else
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end
	
	-- Common validation: The recursion declaration must immediately close
	if finalIndex and not state:isElement(nextChar) and nextChar == MAGIC_GROUP_CLOSE then
		return finalIndex, node
	else
		return false, nil, errorToThrow
	end
end
