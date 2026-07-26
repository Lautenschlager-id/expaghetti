--[[
	Parser and matcher for frontier boundary elements (`%f[...]`).

	Matches positions where the transition between characters crosses
	the specified character set.
]]

--[[ Dependencies ]]--
local FrontierNode = require("core.ast").Frontier
local Set = require("magic.set")

--[[ Aliases ]]--
local ELEMENT_FRONTIER = require("enums.elements").FRONTIER
local ERROR_EXPECTED_FRONTIER_SET = require("enums.errors").expectedFrontierSet

local SetIsToken = Set.isToken
local SetMatch = Set.match
local SetParse = Set.parse

--[[ Module ]]--
local Frontier = {}

--- Returns whether an AST element is a frontier boundary node.
---@param currentElement table The AST element to test.
---@return boolean isFrontier Whether the element is a frontier boundary node.
Frontier.isElement = function(currentElement)
	return currentElement.type == ELEMENT_FRONTIER
end

--- Parses a frontier boundary element.
---@param state ParserState The current parser state.
---@param index number The current pattern index.
---@param isNegated boolean Whether the frontier is negated.
---@return number|false nextIndex The parser index after the frontier boundary, or false on failure.
---@return table|string nodeOrError The frontier AST node, or the parser error message on failure.
Frontier.parse = function(state, index, isNegated)
	local _, nextElement = state:readElement(index)
	if not SetIsToken(nextElement) then
		return false, ERROR_EXPECTED_FRONTIER_SET
	end

	local oldIndex = state.index
	state.index = index

	local setTree = {
		_index = 0
	}
	local errorMessage = SetParse(state, setTree)

	local nextIndex = state.index
	state.index = oldIndex
	
	if errorMessage then
		return false, errorMessage
	end
	
	return nextIndex, FrontierNode(isNegated, setTree[1])
end

--- Matches a frontier boundary element against the target string.
---@param currentElement table The frontier AST node to match.
---@param state MatchState The current matcher state.
---@param currentCharacter string|nil The current target character.
---@return boolean hasMatched Whether the frontier matched.
---@return number|nil startIndex The match start index.
---@return number|nil endIndex The match end index.
Frontier.match = function(currentElement, state, currentCharacter)
	local stringIndex = state.stringIndex - 1
	local previousCharacter = stringIndex > 0 and state:getTargetCharacter(stringIndex) or nil

	local elementSet = currentElement.set
	local isPrevInSet = previousCharacter and SetMatch(elementSet, state, previousCharacter) or false
	local isCurrInSet = currentCharacter and SetMatch(elementSet, state, currentCharacter) or false

	local hasFrontier = isPrevInSet ~= isCurrInSet
	if hasFrontier ~= currentElement.isNegated then
		return true, nil, stringIndex
	end
	return false
end

return Frontier
