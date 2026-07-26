--[[
	Parser and matcher for string anchors.

	Supports the beginning (`^`) and end (`$`) anchors, including
	multiline matching behavior.
]]
	
--[[ Dependencies ]]--
local AnchorNode = require("core.ast").Anchor

--[[ Enums ]]--
local Elements = require("enums.elements")
local LINE_BREAKS = require("enums.lineBreaks")
local Magic = require("enums.magic")

--[[ Aliases ]]--
local MAGIC_ANCHOR_END = Magic.ANCHOR_END
local MAGIC_ANCHOR_START = Magic.ANCHOR_START
local ELEMENT_ANCHOR = Elements.ANCHOR

--[[ Module ]]--
local Anchor = {}

--- Returns whether a character is an anchor token.
---@param currentCharacter string The character to test.
---@return boolean isAnchorToken Whether the character is an anchor token.
Anchor.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_ANCHOR_START or currentCharacter == MAGIC_ANCHOR_END
end

--- Returns whether an AST element is an anchor node.
---@param currentElement table The AST element to test.
---@return boolean isAnchor Whether the element is an anchor node.
Anchor.isElement = function(currentElement)
	return currentElement.type == ELEMENT_ANCHOR
end

--- Parses an anchor element.
---@param state ParserState The current parser state.
---@param currentCharacter string The current pattern character.
---@param tree ASTTree The AST tree being built.
---@return string|nil errorMessage The parser error message on failure.
Anchor.parse = function(state, currentCharacter, tree)
	local treeIndex = tree._index + 1
	tree._index = treeIndex

	local node = AnchorNode(currentCharacter == MAGIC_ANCHOR_START)
	if state.flags.m then
		node.isMultiline = true
	end

	tree[treeIndex] = node

	state.index = state.index + 1
	return nil
end

--- Matches an anchor element against the target string.
---@param currentElement table The anchor AST node to match.
---@param state MatchState The current matcher state.
---@param currentCharacter string|nil The current target character.
---@return boolean hasMatched Whether the anchor matched.
---@return number|nil startIndex The match start index.
---@return number|nil endIndex The match end index.
Anchor.match = function(currentElement, state, currentCharacter)
	local stringIndex = state.stringIndex - 1
	local isStart = currentElement.isStart

	if (isStart and stringIndex == 0) or (not isStart and stringIndex >= state.targetStringLength) then
		return true, nil, stringIndex
	elseif currentElement.isMultiline then
		if isStart then
			currentCharacter = state:getTargetCharacter(stringIndex)
		end
		if LINE_BREAKS[currentCharacter] then
			return true, nil, stringIndex
		end
	end

	return false
end

return Anchor