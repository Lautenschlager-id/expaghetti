----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local elementsEnum = require("./enums/elements")
local quantifiersEnum = require("./enums/quantifiers")
local quantifierModesEnum = require("./enums/quantifierModes")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_QUANTIFIER = magicEnum.OPEN_QUANTIFIER
local ENUM_CLOSE_QUANTIFIER = magicEnum.CLOSE_QUANTIFIER
local ENUM_QUANTIFIER_SEPARATOR_CHARACTER = magicEnum.QUANTIFIER_SEPARATOR_CHARACTER
local ENUM_LAZY_QUANTIFIER = magicEnum.LAZY_QUANTIFIER
local ENUM_POSSESSIVE_QUANTIFIER = magicEnum.POSSESSIVE_QUANTIFIER
local ENUM_ELEMENT_TYPE_QUANTIFIER = elementsEnum.quantifier
----------------------------------------------------------------------------------------------------
local Quantifier = { }

local lookForCustomQuantifier = function(index, patternChars)
	local currentToken

	local parameters, currentParameter = {
		[1] = '',
		[2] = ''
	}, 1

	repeat
		index = index + 1
		currentToken = patternChars[index]
		if not currentToken then
			return false
		end

		if currentToken >= '0' and currentToken <= '9' then
			parameters[currentParameter] = parameters[currentParameter] .. currentToken
		elseif currentToken == ENUM_QUANTIFIER_SEPARATOR_CHARACTER then
			if currentParameter == 2 then
				return false
			end
			currentParameter = 2
		elseif currentToken == ENUM_CLOSE_QUANTIFIER then
			index = index + 1
			break
		else
			return false
		end
	until false

	parameters[1] = tonumber(parameters[1])

	-- If no separator was given the regex much exactly that number
	if currentParameter == 1 then
		parameters[2] = parameters[1]
	else
		parameters[2] = tonumber(parameters[2])
		if (parameters[1] and parameters[2]) and (parameters[1] > parameters[2]) then
			return false, errorsEnum.unorderedCustomQuantifier
		end
	end

	if not (parameters[1] or parameters[2]) or parameters[2] == 0 then
		return false
	end

	return index, AST.Quantifier(parameters[1], parameters[2])
end

local checkIfAppliesToParentTreeElement = function(index, patternChars)
	local currentToken = patternChars[index]
	if not currentToken then return index, false end
	
	if quantifiersEnum[currentToken] then
		return index + 1, quantifiersEnum[currentToken]
	elseif currentToken == ENUM_OPEN_QUANTIFIER then
		local newIndex, customQuantifier = lookForCustomQuantifier(index, patternChars)
		if newIndex then
			return newIndex, customQuantifier
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index, false
end

local lookForModeToken = function(index, patternChars, quantifier)
	local currentToken = patternChars[index]
	if currentToken then
		local quantifierMode = quantifierModesEnum[currentToken]

		if quantifierMode then
			quantifier = tblDeepCopy(quantifier)
			quantifier.mode = quantifierMode
			index = index + 1
		end
	end
	return index, quantifier
end

----------------------------------------------------------------------------------------------------
Quantifier.isToken = function(state, parentElement)
	local index, quantifier = checkIfAppliesToParentTreeElement(state.index, state.patternChars)

	return index and quantifier
end

Quantifier.isElement = function(currentElement)
	return currentElement.quantifier
		and currentElement.quantifier.type == ENUM_ELEMENT_TYPE_QUANTIFIER
end

local nonQuantifiableTypes = {
	[elementsEnum.anchor] = true,
	[elementsEnum.boundary] = true,
	[elementsEnum.balanced] = true,
	[elementsEnum.position_capture] = true,
}

Quantifier.lookForElementOperation = function(state, parentElement)
	-- Verify if the element type supports quantifiers
	local shouldntHaveQuantifier = nonQuantifiableTypes[parentElement.type] == true

	local index, quantifier = checkIfAppliesToParentTreeElement(state.index, state.patternChars)

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

	index, quantifier = lookForModeToken(index, state.patternChars, quantifier)
	parentElement.quantifier = quantifier

	return index
end

return Quantifier