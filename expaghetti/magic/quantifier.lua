----------------------------------------------------------------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
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

local validateCustomQuantifier = function(index, charactersList)
	local currentCharacter

	local parameters, currentParameter = {
		[1] = '',
		[2] = ''
	}, 1

	repeat
		index = index + 1
		currentCharacter = charactersList[index]
		if not currentCharacter or currentCharacter.type then
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
Quantifier.checkIfAppliesToParentElement = function(index, charactersList)
	local currentCharacter = charactersList[index]

	if quantifiersEnum[currentCharacter] then
		return index + 1, quantifiersEnum[currentCharacter]
	elseif currentCharacter == ENUM_OPEN_QUANTIFIER then
		local newIndex, customQuantifier = validateCustomQuantifier(index, charactersList)
		if newIndex then
			return newIndex, customQuantifier
		elseif customQuantifier then
			-- customQuantifier = error message
			return false, customQuantifier
		end
	end

	return index, false
end

Quantifier.checkIfHasMode = function(index, charactersList, quantifier)
	local quantifierMode = quantifierModesEnum[charactersList[index]]

	if quantifierMode then
		quantifier = tblDeepCopy(quantifier)
		quantifier.mode = quantifierMode
		index = index + 1
	end

	return index, quantifier
end

Quantifier.checkForElement = function(index, charactersList, parentElement)
	-- If the object explicitly says quantifier = false, then a quantifier operator shouldn't exist
	local shouldntHaveQuantifier = parentElement.quantifier == false

	local index, quantifier = Quantifier.checkIfAppliesToParentElement(index, charactersList)

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

	index, quantifier = Quantifier.checkIfHasMode(index, charactersList, quantifier)
	parentElement.quantifier = quantifier

	return index
end

Quantifier.is = function(index, charactersList, parentElement)
	local index, quantifier = Quantifier.checkIfAppliesToParentElement(
		index, charactersList, parentElement)

	return index and quantifier
end

return Quantifier