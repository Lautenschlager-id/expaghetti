--[[
    Parser and matcher for literal characters.

    Matches a single character, optionally supporting case-insensitive
    comparisons depending on the active flags.
]]

--[[ Dependencies ]]--
local LiteralNode = require("ast").Literal
local QuantifierIsToken = require("magic.Quantifier").isToken


--[[ Enums ]]--

--[[ Aliases ]]--
local ELEMENT_LITERAL = require("enums.elements").LITERAL

local ERROR_NOTHING_TO_REPEAT = require("enums.errors").nothingToRepeat

--[[ Module ]]--
local Literal = { }

--- Returns whether an AST element is a literal node.
---@param currentElement table The AST element to test.
---@return boolean isLiteral Whether the element is a literal node.
Literal.isElement = function(currentElement)
	return currentElement.type == ELEMENT_LITERAL
end

--- Parses a literal element.
---@param state ParserState The current parser state.
---@param currentCharacter string The current pattern character.
---@param tree ASTTree The AST tree being built.
---@return string|nil errorMessage The parser error message on failure.
Literal.parse = function(state, currentCharacter, tree)
	if QuantifierIsToken(state, tree) then
		return ERROR_NOTHING_TO_REPEAT
	end

	local treeIndex = tree._index + 1
	tree._index = treeIndex

	local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter)
	local node = LiteralNode(value, lowerValue, upperValue)

	tree[treeIndex] = node

	state.index = state.index + 1
	return nil
end

--- Matches a literal element against the target string.
---@param currentElement table The literal AST node to match.
---@param state MatchState Unused matcher state.
---@param currentCharacter string|nil The current target character.
---@return boolean hasMatched Whether the literal matched.
Literal.match = function(currentElement, _, currentCharacter)
	if currentElement.isCaseInsensitive then
		return currentCharacter == currentElement.lowerValue
			or currentCharacter == currentElement.upperValue
	end
	return currentCharacter == currentElement.value
end

return Literal