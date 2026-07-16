----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local nonQuantifiableTypes = require("./enums/nonQuantifiableTypes")
local quantifiersEnum = require("./enums/quantifiers")
local quantifierModesEnum = require("./enums/quantifierModes")
local parserHelpers = require("./helpers/parser_helpers")
----------------------------------------------------------------------------------------------------
local consumeWhile = parserHelpers.consumeWhile
local isPositiveOrZeroIntegerChar = parserHelpers.isPositiveOrZeroIntegerChar
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_QUANTIFIER = magicEnum.OPEN_QUANTIFIER
local ENUM_CLOSE_QUANTIFIER = magicEnum.CLOSE_QUANTIFIER
local ENUM_QUANTIFIER_SEPARATOR_CHARACTER = magicEnum.QUANTIFIER_SEPARATOR_CHARACTER
local ENUM_ELEMENT_TYPE_QUANTIFIER = require("./enums/elements").quantifier
----------------------------------------------------------------------------------------------------
local Quantifier = { }
----------------------------------------------------------------------------------------------------
local lookForCustomQuantifier = function(state, index)
	local min, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	local max

	if currentToken == ENUM_QUANTIFIER_SEPARATOR_CHARACTER then
		max, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	end

	if currentToken ~= ENUM_CLOSE_QUANTIFIER then
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
			return false, errorsEnum.unorderedCustomQuantifier
		end
	end

	if not (min or max) or max == 0 then
		return false
	end

	return index, AST.Quantifier(min, max)
end

local parseQuantifier = function(state, index)
	local nextIndex, currentToken = state:readElement(index)
	if not nextIndex then
		return index, false
	end
	
	if not state:isElement(currentToken) and quantifiersEnum[currentToken] then
		return nextIndex, quantifiersEnum[currentToken]
	elseif currentToken == ENUM_OPEN_QUANTIFIER then
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
			quantifier = tblDeepCopy(quantifier)
			quantifier.mode = quantifierMode
			index = nextIndex
		end
	end
	return index, quantifier
end


----------------------------------------------------------------------------------------------------
Quantifier.isToken = function(state, parentElement)
	local index, quantifier = parseQuantifier(state, state.index)

	return index and quantifier
end

Quantifier.isElement = function(currentElement)
	return currentElement.quantifier
		and currentElement.quantifier.type == ENUM_ELEMENT_TYPE_QUANTIFIER
end

Quantifier.lookForElementOperation = function(state, parentElement)
	-- Verify if the element type supports quantifiers
	local shouldntHaveQuantifier = nonQuantifiableTypes[parentElement.type] == true

	local index, quantifier = parseQuantifier(state, state.index)

	if not index then
		-- quantifier = error message
		return false, quantifier
	elseif not quantifier then
		-- not a quantifier
		return index
	elseif shouldntHaveQuantifier then
		-- has a quantifier but shouldn't
		return false, errorsEnum.nothingToRepeat
	end

	index, quantifier = lookForModeToken(state, index, quantifier)
	parentElement.quantifier = quantifier

	return index
end

return Quantifier