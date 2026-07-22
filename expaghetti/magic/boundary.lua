--[[
    Parses boundary elements.
]]

--[[ Dependencies ]]--
local AST = require("ast")
local Set = require("magic.set")
local errorsEnum = require("enums.errors")
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local ELEMENT_BOUNDARY = elementsEnum.boundary
local ERROR_MISSING_FRONTIER_SET = errorsEnum.expectedFrontierSet

--[[ Module ]]--
local Boundary = {}

--[[ Public API ]]--
Boundary.isElement = function(currentElement)
	return currentElement.type == ELEMENT_BOUNDARY
end

Boundary.parse = function(state, index, isNegated)
	local _, nextElement = state:readElement(index)
	if not Set.isToken(nextElement) then
		return false, ERROR_MISSING_FRONTIER_SET
	end

	local oldIndex = state.index
	state.index = index
	local tempTree = { _index = 0 }
	local errorMessage = Set.parse(state, tempTree)
	local nextStateIndex = state.index
	state.index = oldIndex
	
	if errorMessage then
		return false, errorMessage
	end
	
	return nextStateIndex, AST.Boundary(isNegated, tempTree[1])
end

Boundary.match = function(currentElement, state, currentCharacter)
	local stringIndex = state.stringIndex - 1
	local previousChararacter = stringIndex > 0 and state:getTargetCharacter(stringIndex) or nil

	local isPrevInSet = previousChararacter and Set.match(currentElement.set, state, previousChararacter) or false
	local isCurrInSet = currentCharacter and Set.match(currentElement.set, state, currentCharacter) or false

	local hasBoundary = isPrevInSet ~= isCurrInSet
	if hasBoundary ~= currentElement.isNegated then
		return true, nil, stringIndex
	end
	return false
end

--[[ Return ]]--
return Boundary
