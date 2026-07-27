--[[
	Parser and matcher for balanced elements (`%bxy`).

	Matches balanced pairs of delimiters while supporting nested
	occurrences of the same delimiter pair.
]]

--[[ Dependencies ]]--
local BalancedNode = require("expaghetti.core.ast").Balanced

--[[ Aliases ]]--
local ELEMENT_BALANCED = require("expaghetti.enums.elements").BALANCED
local ERROR_MISSING_BALANCED_DELIMITERS = require("expaghetti.enums.errors").missingBalancedDelimiters

--[[ Module ]]--
local Balanced = {}

--- Returns whether an AST element is a balanced node.
---@param currentElement table The AST element to test.
---@return boolean isBalanced Whether the element is a balanced node.
Balanced.isElement = function(currentElement)
	return currentElement.type == ELEMENT_BALANCED
end

--- Parses a balanced element.
---@param state ParserState The current parser state.
---@param currentCharacter string The current pattern character.
---@param index number The current pattern index.
---@param expression table The parsed pattern characters.
---@return number|false nextIndex The parser index after the balanced element, or false on failure.
---@return table|string nodeOrError The balanced AST node, or the parser error message on failure.
Balanced.parse = function(state, currentCharacter, index, expression)
	local opener = expression[index]
	local closer = expression[index + 1]
	if not opener or not closer then
		return false, ERROR_MISSING_BALANCED_DELIMITERS
	end

	local opener, openerLower, openerUpper = state:getExecutionValues(opener)
	local closer, closerLower, closerUpper = state:getExecutionValues(closer)

	return index + 2, BalancedNode(
		openerLower or opener,
		openerUpper or opener,
		closerLower or closer,
		closerUpper or closer
	)
end

--- Matches a balanced element against the target string.
---@param currentElement table The balanced AST node to match.
---@param state MatchState The current matcher state.
---@param currentCharacter string|nil The current target character.
---@return boolean hasMatched Whether a balanced sequence was matched.
---@return number|nil startIndex The match start index.
---@return number|nil endIndex The match end index.
Balanced.match = function(currentElement, state, currentCharacter)
	local lowerOpen, upperOpen, lowerClose, upperClose = 
		currentElement.lowerOpen, currentElement.upperOpen,
		currentElement.lowerClose, currentElement.upperClose

	-- The first character MUST match the opener
	local currentStrIndex = state.stringIndex
	if currentCharacter ~= lowerOpen and currentCharacter ~= upperOpen then
		return false
	end

	local depth = 1
	currentStrIndex = currentStrIndex + 1

	local targetStringLength = state.targetStringLength 
	while currentStrIndex <= targetStringLength do
		local char = state:getTargetCharacter(currentStrIndex)
		if char == lowerClose or char == upperClose then
			depth = depth - 1
			if depth == 0 then
				return true, nil, currentStrIndex
			end
		elseif char == lowerOpen or char == upperOpen then
			-- It's possible opener == closer. If so, it was already handled by the first `if` and depth decreased.
			-- So this only increments depth if opener ~= closer.
			depth = depth + 1
		end
		currentStrIndex = currentStrIndex + 1
	end

	return false
end

return Balanced
