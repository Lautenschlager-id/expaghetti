----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local quantifiersEnum = require("./enums/quantifiers")
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

	return index, {
		type = ENUM_ELEMENT_TYPE_QUANTIFIER,
		min = parameters[1],
		max = parameters[2]
	}
end
----------------------------------------------------------------------------------------------------
Quantifier.try = function(index, expression, parentElement)
	local currentCharacter = expression[index]

	if quantifiersEnum[currentCharacter] then
		parentElement.quantifier = quantifiersEnum[currentCharacter]
		return index + 1
	elseif currentCharacter == ENUM_OPEN_QUANTIFIER then
		local newIndex, customQuantifier = validateCustomQuantifier(index, expression)
		if newIndex then
			parentElement.quantifier = customQuantifier
			return newIndex
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index
end

return Quantifier