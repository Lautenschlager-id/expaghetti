--[[
    Parser and matcher for position captures (`()`).

    Captures the current position in the target string without consuming
    any characters.
]]

--[[ Dependencies ]]--
local PositionCaptureNode = require("ast").PositionCapture

--[[ Aliases ]]--
local ELEMENT_POSITION_CAPTURE = require("enums.elements").POSITION_CAPTURE

--[[ Module ]]--
local PositionCapture = { }

--- Returns whether an AST element is a position capture node.
---@param currentElement table The AST element to test.
---@return boolean isPositionCapture Whether the element is a position capture node.
PositionCapture.isElement = function(currentElement)
	return currentElement.type == ELEMENT_POSITION_CAPTURE
end

--- Parses a position capture element.
---@param index number The current pattern index.
---@param tree ASTTree The AST tree being built.
---@param parserMetadata ParserMetadata The parser metadata.
---@return number nextIndex The parser index after the position capture.
PositionCapture.parse = function(index, tree, parserMetadata)
	local positionCaptureIndex = parserMetadata.positionCaptureIndex + 1
	parserMetadata.positionCaptureIndex = positionCaptureIndex

	local treeIndex = tree._index + 1
	tree._index = treeIndex
	tree[treeIndex] = PositionCaptureNode(positionCaptureIndex)

	return index + 1
end

--- Matches a position capture element against the target string.
---@param currentElement table The position capture AST node.
---@param state MatchState The current matcher state.
---@return boolean hasMatched Whether the position capture succeeded.
---@return number|nil startIndex The match start index.
---@return number endIndex The match end index.
PositionCapture.match = function(currentElement, state)
	local stateStringIndex = state.stringIndex
	state.metadata.positionCaptures[currentElement.index] = stateStringIndex
	return true, nil, stateStringIndex - 1
end

return PositionCapture