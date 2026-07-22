--[[
    Parser and matcher for the wildcard (`.`) element.

    Matches any character except line breaks by default, or every
    character when the dot-all (`s`) flag is enabled.
]]

--[[ Dependencies ]]--
local AnyNode = require("ast").Any

--[[ Enums ]]--
local LINE_BREAKS = require("enums.lineBreaks")

--[[ Aliases ]]--
local MAGIC_ANY = require("enums.magic").ANY
local ELEMENT_ANY = require("enums.elements").ANY

--[[ Module ]]--
local Any = {}

--- Returns whether a character is the wildcard token.
---@param currentCharacter string The character to test.
---@return boolean isAnyToken Whether the character is the wildcard token.
Any.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_ANY
end

--- Returns whether an AST element is a wildcard node.
---@param currentElement table The AST element to test.
---@return boolean isAny Whether the element is a wildcard node.
Any.isElement = function(currentElement)
	return currentElement.type == ELEMENT_ANY
end

--- Parses a wildcard element.
---@param state ParserState The current parser state.
---@param tree ASTTree The AST tree being built.
---@return string|nil errorMessage The parser error message on failure.
Any.parse = function(state, tree)
	local treeIndex = tree._index + 1
	tree._index = treeIndex

	local node = AnyNode()
	if state.flags.s then
		node.isDotAll = true
	end

	tree[treeIndex] = node

	state.index = state.index + 1
	return nil
end

--- Matches a wildcard element against the target string.
---@param currentElement table The wildcard AST node to match.
---@param state MatchState Unused matcher state.
---@param currentCharacter string|nil The current target character.
---@return boolean hasMatched Whether the wildcard matched.
Any.match = function(currentElement, _, currentCharacter)
	return currentElement.isDotAll or not LINE_BREAKS[currentCharacter]
end

return Any