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

local quantifierMatchMode = { }

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
		min = parameters[1] or 0,
		max = parameters[2] or 0,
		mode = nil,
	}
end

local checkIfAppliesToParentElement = function(index, charactersList)
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

local checkIfHasMode = function(index, charactersList, quantifier)
	local quantifierMode = quantifierModesEnum[charactersList[index]]

	if quantifierMode then
		quantifier = tblDeepCopy(quantifier)
		quantifier.mode = quantifierMode
		index = index + 1
	end

	return index, quantifier
end

local getMaximumOccurrencesOfElement = function(quantifier, currentElement, singleElementMatcher,
	currentCharacter, stringIndex, splitStr)

	local maximumOccurrences = quantifier.max

	local totalOccurrences = 0
	repeat
		if not singleElementMatcher(currentElement, currentCharacter) then
			break
		end

		totalOccurrences = totalOccurrences + 1
		if totalOccurrences == maximumOccurrences then
			break
		end

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]
	until false

	return totalOccurrences
end

quantifierMatchMode.greedy = function(treeMatcher, minimumOccurrences, maximumOccurrencesOfElement,
	flags, tree, treeLength, treeIndex,
	splitStr, strLength,
	stringIndex, initialStringIndex)

	pdebug('\tLooping from ', maximumOccurrencesOfElement, ' to ', minimumOccurrences,
		' and from index ', stringIndex)
	local hasMatched
	for occurence = maximumOccurrencesOfElement, minimumOccurrences, -1 do
		hasMatched, debugStr = treeMatcher(
			flags, tree, treeLength, treeIndex,
			splitStr, strLength,
			stringIndex + occurence - 1, initialStringIndex
		)
		if hasMatched then
			return hasMatched, debugStr
		end
	end
	pdebug("########################################")
end
----------------------------------------------------------------------------------------------------
Quantifier.is = function(index, charactersList, parentElement)
	local index, quantifier = checkIfAppliesToParentElement(index, charactersList)

	return index and quantifier
end

Quantifier.isElement = function(currentElement)
	return currentElement.quantifier
		and currentElement.quantifier.type == ENUM_ELEMENT_TYPE_QUANTIFIER
end

Quantifier.checkForElement = function(index, charactersList, parentElement)
	-- If the object explicitly says quantifier = false, then a quantifier operator shouldn't exist
	local shouldntHaveQuantifier = parentElement.quantifier == false

	local index, quantifier = checkIfAppliesToParentElement(index, charactersList)

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

	index, quantifier = checkIfHasMode(index, charactersList, quantifier)
	parentElement.quantifier = quantifier

	return index
end

Quantifier.loopOver = function(currentElement, currentCharacter, singleElementMatcher, treeMatcher,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex
	)

	local quantifier = currentElement.quantifier

	local maximumOccurrencesOfElement = getMaximumOccurrencesOfElement(
		quantifier, currentElement, singleElementMatcher, currentCharacter, stringIndex, splitStr)

	pdebug('\tmaximumOccurrencesOfElement', maximumOccurrencesOfElement)

	local minimumOccurrences = quantifier.min
	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end

	return quantifierMatchMode.greedy(
		treeMatcher, minimumOccurrences, maximumOccurrencesOfElement,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex
	)
end

return Quantifier