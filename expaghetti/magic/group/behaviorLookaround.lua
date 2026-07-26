--[[
	Parser for lookahead and lookbehind group behaviors.
	Supports `(?=...)`, `(?!...)`, `(?<=...)`, and `(?<!...)`.
]]

--[[ Dependencies ]]--
local AST = require("core.ast")

--[[ Enums ]]--
local Magic = require("enums.magic")

--[[ Aliases ]]--
local ENUM_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR = Magic.GROUP_LOOKAROUND_POSITIVE_BEHAVIOR
local ENUM_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR = Magic.GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR
local ENUM_GROUP_LOOKBEHIND_BEHAVIOR = Magic.GROUP_LOOKBEHIND_BEHAVIOR

local ERROR_INVALID_GROUP_BEHAVIOR = require("enums.errors").invalidGroupBehavior

local GroupLookaheadNode = AST.GroupLookahead
local GroupLookbehindNode = AST.GroupLookbehind

--[[ Module ]]--

--- Parses a lookahead or lookbehind group behavior.
---@param state ParserState The current parser state.
---@param peekIndex number The parser index after the behavior token.
---@param peekChar string The behavior token following `(?`.
---@param lookbehindIndex number|nil The parser index after the lookbehind polarity token.
---@param lookbehindChar string|nil The lookbehind polarity token.
---@return number|false nextIndex The parser index after the parsed behavior, or false on failure.
---@return table|nil group The parsed AST group node.
---@return string|nil errorMessage The parser error message when parsing fails.
return function(state, peekIndex, peekChar, lookbehindIndex, lookbehindChar)
	-- Lookahead: (?=...), (?!...)
	local isNegativeLookahead = (peekChar == ENUM_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR) or nil
	if peekChar == ENUM_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or isNegativeLookahead then
		local node = GroupLookaheadNode()
		node.isLookahead = true
		node.isNonCapturing = true
		node.hasSpecialBehavior = true
		node.isNegative = isNegativeLookahead
		return peekIndex, node
		
	-- Lookbehind: (?<=...), (?<!...)
	-- Peek at the third character to determine polarity
	elseif peekChar == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		if not lookbehindIndex then
			return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
		end

		local isNegativeLookbehind = (lookbehindChar == ENUM_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR) or nil
		if lookbehindChar == ENUM_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or isNegativeLookbehind then
			local node = GroupLookbehindNode()
			node.isLookbehind = true
			node.isNonCapturing = true
			node.hasSpecialBehavior = true
			node.isNegative = isNegativeLookbehind
			return lookbehindIndex, node
		end
	end
	
	return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
end
