----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local quantifiersEnum = require("./enums/quantifiers")
local quantifierModesEnum = require("./enums/quantifierModes")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_QUANTIFIER = magicEnum.OPEN_QUANTIFIER
local ENUM_CLOSE_QUANTIFIER = magicEnum.CLOSE_QUANTIFIER
local ENUM_QUANTIFIER_SEPARATOR_CHARACTER = magicEnum.QUANTIFIER_SEPARATOR_CHARACTER
local ENUM_ELEMENT_TYPE_QUANTIFIER = require("./enums/elements").quantifier
----------------------------------------------------------------------------------------------------
local Quantifier = { }

local validateCustomQuantifier = function(index, expression)
	local currentCharacter

	local parameters, currentParameter = {
		[1] = '',
		[2] = ''
	}, 1

	repeat
		index = index + 1
		currentCharacter = expression[index]
		if not currentCharacter then
			return false
		end

		if currentCharacter >= '0' and currentCharacter <= '9' then
			parameters[currentParameter] = parameters[currentParameter] .. currentCharacter
		elseif currentCharacter == ENUM_QUANTIFIER_SEPARATOR_CHARACTER then
			if currentParameter == 2 then
				return false
			end
			currentParameter = 2
		elseif currentCharacter == ENUM_CLOSE_QUANTIFIER then
			index = index + 1
			break
		else
			return false
		end
	until false

	parameters[1] = tonumber(parameters[1])
	parameters[2] = tonumber(parameters[2])
	if (parameters[1] and parameters[2]) and (parameters[1] > parameters[2]) then
		return false, errorsEnum.unorderedCustomQuantifier
	elseif not (parameters[1] or parameters[2]) or parameters[2] == 0 then
		return false
	end

	--[[
		parentElement = {
			quantifier = {
				type = "quantifier",
				min = 1,
				max = 1,
				mode = "lazy"
			}
		}
	]]
	return index, {
		type = ENUM_ELEMENT_TYPE_QUANTIFIER,
		min = parameters[1],
		max = parameters[2],
		mode = nil,
	}
end
----------------------------------------------------------------------------------------------------
Quantifier.checkIfAppliesToParentElement = function(index, expression, parentElement)
	local currentCharacter = expression[index]

	if quantifiersEnum[currentCharacter] then
		parentElement.quantifier = quantifiersEnum[currentCharacter]
		return index + 1, parentElement.quantifier
	elseif currentCharacter == ENUM_OPEN_QUANTIFIER then
		local newIndex, customQuantifier = validateCustomQuantifier(index, expression)
		if newIndex then
			parentElement.quantifier = customQuantifier
			return newIndex, customQuantifier
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index, false
end

Quantifier.checkIfHasMode = function(index, expression, quantifier)
	local quantifierMode = quantifierModesEnum[expression[index]]

	if quantifierMode then
		quantifier.mode = quantifierMode
		return index + 1
	end

	return index
end

Quantifier.try = function(index, expression, parentElement)
	local index, quantifier =
		Quantifier.checkIfAppliesToParentElement(index, expression, parentElement)
	if not index then
		-- quantifier = error message
		return false, quantifier
	elseif not quantifier then
		return index
	end

	index = Quantifier.checkIfHasMode(index, expression, quantifier)

	-- This is not efficient, but that's the basic way of checking for cases like:
	-- `a+++`, `a+?*`, ...
	index, quantifier =
		Quantifier.checkIfAppliesToParentElement(index, expression, parentElement)
	if index and quantifier then
		return false, errorsEnum.nothingToRepeat
	end

	return index, quantifier
end

return Quantifier