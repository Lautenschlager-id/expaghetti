--[[
    Parser for recursion group behaviors.
    Supports `(?R)`, `(?0)`, `(?123)`, and `(?&name)`.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local AST = require("ast")
local ParserHelper = require("helpers.parser")

--[[ Enums ]]--
local Magic = require("enums.magic")
local Errors = require("enums.errors")

--[[ Aliases ]]--
local consumeWhile = ParserHelper.consumeWhile
local isAlphanumericName = ParserHelper.isAlphanumericName
local isPositiveIntegerChar = ParserHelper.isPositiveIntegerChar
local isPositiveOrZeroIntegerChar = ParserHelper.isPositiveOrZeroIntegerChar

local ERROR_INVALID_GROUP_BEHAVIOR = Errors.invalidGroupBehavior
local ERROR_INVALID_GROUP_RECURSION_NAME = Errors.invalidGroupRecursionName

local GroupRecursionNode = AST.GroupRecursion

local MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR = Magic.GROUP_RECURSION_ROOT_BEHAVIOR
local MAGIC_GROUP_RECURSION_ROOT_ALIAS = Magic.GROUP_RECURSION_ROOT_ALIAS
local MAGIC_GROUP_RECURSION_NAMED = Magic.GROUP_RECURSION_NAMED_BEHAVIOR

--[[ Module ]]--

--- Parses a recursion group behavior.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index after the behavior token.
---@param peekChar string The behavior token following `(?`.
---@param GroupIsClosingToken fun(char: string): boolean Function from the Group module that returns whether a character closes the current group.
---@return number|false nextIndex The parser index after the parsed behavior, or false on failure.
---@return table|nil group The parsed AST group node.
---@return string|nil errorMessage The parser error message when parsing fails.
return function(state, peekIndex, peekChar, GroupIsClosingToken)
	local node = GroupRecursionNode()
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
		local nameStr, afterLoopIndex, afterLoopChar = consumeWhile(state, peekIndex, isAlphanumericName)

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
	if finalIndex and not state:isElement(nextChar) and GroupIsClosingToken(nextChar) then
		return finalIndex, node
	else
		return false, nil, errorToThrow
	end
end
