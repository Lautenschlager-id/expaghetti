----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local quantifiersEnum = require("./enums/quantifiers")
local quantifierModesEnum = require("./enums/quantifierModes")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_QUANTIFIER = magicEnum.OPEN_QUANTIFIER
local ENUM_CLOSE_QUANTIFIER = magicEnum.CLOSE_QUANTIFIER
local ENUM_QUANTIFIER_SEPARATOR_CHARACTER = magicEnum.QUANTIFIER_SEPARATOR_CHARACTER
local ENUM_LAZY_QUANTIFIER = magicEnum.LAZY_QUANTIFIER
local ENUM_POSSESSIVE_QUANTIFIER = magicEnum.POSSESSIVE_QUANTIFIER
local ENUM_ELEMENT_TYPE_QUANTIFIER = require("./enums/elements").quantifier
----------------------------------------------------------------------------------------------------
local Quantifier = { }

local lookForCustomQuantifier = function(index, tokens)
	local currentToken

	local parameters, currentParameter = {
		[1] = '',
		[2] = ''
	}, 1

	repeat
		index = index + 1
		currentToken = tokens[index]
		if not currentToken or type(currentToken.raw) == "table" then
			return false
		end

		local rawChar = currentToken.raw

		if rawChar >= '0' and rawChar <= '9' then
			parameters[currentParameter] = parameters[currentParameter] .. rawChar
		elseif rawChar == ENUM_QUANTIFIER_SEPARATOR_CHARACTER then
			if currentParameter == 2 then
				return false
			end
			currentParameter = 2
		elseif rawChar == ENUM_CLOSE_QUANTIFIER then
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

local checkIfAppliesToParentTreeElement = function(index, tokens)
	local currentToken = tokens[index]
	if not currentToken then return index, false end
	
	local rawChar = currentToken.raw

	if quantifiersEnum[rawChar] then
		return index + 1, quantifiersEnum[rawChar]
	elseif rawChar == ENUM_OPEN_QUANTIFIER then
		local newIndex, customQuantifier = lookForCustomQuantifier(index, tokens)
		if newIndex then
			return newIndex, customQuantifier
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index, false
end

local lookForModeToken = function(index, tokens, quantifier)
	local currentToken = tokens[index]
	if currentToken then
		local quantifierMode = quantifierModesEnum[currentToken.raw]

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
	local index, quantifier = checkIfAppliesToParentTreeElement(state.index, state.tokens)

	return index and quantifier
end

Quantifier.isElement = function(currentElement)
	return currentElement.quantifier
		and currentElement.quantifier.type == ENUM_ELEMENT_TYPE_QUANTIFIER
end

Quantifier.lookForElementOperation = function(state, parentElement)
	-- If the object explicitly says quantifier = false, then a quantifier operator shouldn't exist
	local shouldntHaveQuantifier = parentElement.quantifier == false

	local index, quantifier = checkIfAppliesToParentTreeElement(state.index, state.tokens)

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

	index, quantifier = lookForModeToken(index, state.tokens, quantifier)
	parentElement.quantifier = quantifier

	return index
end

return Quantifier