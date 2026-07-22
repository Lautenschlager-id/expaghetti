--[[
    Quantifier module. Parses quantifiers.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local table_deepcopy = require("helpers.table").table_deepcopy
local parserHelpers = require("helpers.parserHelpers")
local consumeWhile = parserHelpers.consumeWhile
local isPositiveOrZeroIntegerChar = parserHelpers.isPositiveOrZeroIntegerChar

local AST = require("ast")

local magicEnum = require("enums.magic")
local errorsEnum = require("enums.errors")
local quantifiersEnum = require("enums.quantifiers")
local quantifierModesEnum = require("enums.quantifierModes")
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local MAGIC_QUANTIFIER_OPEN = magicEnum.QUANTIFIER_OPEN
local MAGIC_QUANTIFIER_CLOSE = magicEnum.QUANTIFIER_CLOSE
local MAGIC_QUANTIFIER_SEPARATOR = magicEnum.QUANTIFIER_SEPARATOR
local ELEMENT_QUANTIFIER = elementsEnum.quantifier

local ERROR_UNORDERED_CUSTOM_QUANTIFIER = errorsEnum.unorderedQuantifierRange
local ERROR_NOTHING_TO_REPEAT = errorsEnum.nothingToRepeat

local ZERO_LENGTH_ELEMENTS = require("enums.elementLengths").ZERO_LENGTH


--[[ Module ]]--
local Quantifier = {}

--[[ Private Functions ]]--
local lookForCustomQuantifier = function(state, index)
	local min, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	local max

	if currentToken == MAGIC_QUANTIFIER_SEPARATOR then
		max, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	end

	if currentToken ~= MAGIC_QUANTIFIER_CLOSE then
		return false
	end

	-- {N}
	min = tonumber(min)

	if max == nil then
		max = min
	else
		-- {N,M}, {N,}, {,M}
		max = tonumber(max)

		if min and max and min > max then
			return false, ERROR_UNORDERED_CUSTOM_QUANTIFIER
		end
	end

	if not (min or max) or max == 0 then
		return false
	end

	return index, AST.Quantifier(min, max)
end

local tryParseQuantifier = function(state, index)
	local nextIndex, currentToken = state:readElement(index)
	if not nextIndex then
		return index, false
	end
	
	if not state:isElement(currentToken) and quantifiersEnum[currentToken] then
		return nextIndex, quantifiersEnum[currentToken]
	elseif currentToken == MAGIC_QUANTIFIER_OPEN then
		local newIndex, customQuantifier = lookForCustomQuantifier(state, nextIndex)
		if newIndex then
			return newIndex, customQuantifier
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index, false
end

local lookForModeToken = function(state, index, quantifier)
	local nextIndex, currentToken = state:readElement(index)
	if nextIndex and not state:isElement(currentToken) then
		local quantifierMode = quantifierModesEnum[currentToken]

		if quantifierMode then
			quantifier = table_deepcopy(quantifier)
			quantifier.mode = quantifierMode
			index = nextIndex
		end
	end
	return index, quantifier
end

--[[ Public API ]]--
Quantifier.isToken = function(state, parentElement)
	local index, quantifier = tryParseQuantifier(state, state.index)
	return index and quantifier
end

Quantifier.isElement = function(currentElement)
	return currentElement.quantifier
		and currentElement.quantifier.type == ELEMENT_QUANTIFIER
end

Quantifier.lookForElementOperation = function(state, parentElement)
	-- Verify if the element type supports quantifiers
	local shouldntHaveQuantifier = ZERO_LENGTH_ELEMENTS[parentElement.type] == true

	local index, quantifier = tryParseQuantifier(state, state.index)

	if not index then
		-- quantifier = error message
		return quantifier
	elseif not quantifier then
		-- not a quantifier
		return nil
	elseif shouldntHaveQuantifier then
		-- has a quantifier but shouldn't
		return ERROR_NOTHING_TO_REPEAT
	end

	index, quantifier = lookForModeToken(state, index, quantifier)
	parentElement.quantifier = quantifier

	state.index = index
	return nil
end

--[[ Return ]]--
return Quantifier