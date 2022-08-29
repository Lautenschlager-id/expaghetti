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
local ENUM_LAZY_QUANTIFIER = magicEnum.LAZY_QUANTIFIER
local ENUM_POSSESSIVE_QUANTIFIER = magicEnum.POSSESSIVE_QUANTIFIER
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
	currentCharacter, treeMatcher,
	flags,
	splitStr, strLength,
	stringIndex)

	local maximumOccurrences = quantifier.max

	local totalOccurrences = 0
	local endStringPositions = { }

	local hasMatched, iniStr, endStr, debugStr
	repeat
		print('init quantifier singleElementMatcher')
		hasMatched, iniStr, endStr, debugStr = singleElementMatcher(
			currentElement, currentCharacter, treeMatcher,
			flags,
			splitStr, strLength,
			stringIndex
		)
		print('end quantifier singleElementMatcher')

		if not hasMatched then
			print('broke for character ', currentCharacter)
			break
		end

		iniStr = iniStr or stringIndex
		endStr = endStr or stringIndex

		print('\tmatched for characters ', table.concat(splitStr, '', iniStr, endStr))

		totalOccurrences = totalOccurrences + 1
		endStringPositions[totalOccurrences] = endStr

		if totalOccurrences == maximumOccurrences then
			break
		end
		print('\ttotalOccurrences is', totalOccurrences)

		stringIndex = (endStr or stringIndex) + 1
		currentCharacter = splitStr[stringIndex]
	until false

	return totalOccurrences, endStringPositions
end

local matchBacktrackElement = function(
	minimumOccurrences, maximumOccurrencesOfElement, occurrenceDirection, endStringPositions,
	treeMatcher,
	flags, tree, treeLength, treeIndex,
	splitStr, strLength,
	stringIndex, initialStringIndex)

	local hasMatched, iniStr, endStr, debugStr, debugIni

	local loop = 0

	for occurrence = minimumOccurrences, maximumOccurrencesOfElement, occurrenceDirection do
		print("#begin attempt", minimumOccurrences - maximumOccurrencesOfElement)

		debugIni = endStringPositions[occurrence] or (stringIndex - 1)
		print('@@@@@@@@@@@@@@@@@@@@@@@@@@ stringIndex vs debugIni', stringIndex + occurrence - 1 ,
			debugIni)

		hasMatched, iniStr, endStr, debugStr = treeMatcher(
			flags, tree, treeLength, treeIndex,
			splitStr, strLength,
			debugIni, --stringIndex + occurrence - 1,
			initialStringIndex
		)
		print('@attempt ', minimumOccurrences - maximumOccurrencesOfElement,
			'\n\t: hasMatched: ', hasMatched,
			'\n\t: str considered: ', table.concat(splitStr, '', debugIni+1),--stringIndex + occurrence),
			'\n\t: debugStr: ', table.concat(splitStr, '', iniStr, endStr)
		)

		if loop == 1 then return end
		if hasMatched then
			return hasMatched, iniStr, endStr, debugStr
		end
	end
end

quantifierMatchMode.greedy = function(minimumOccurrences, maximumOccurrencesOfElement,
	endStringPositions, ...)

	return matchBacktrackElement(maximumOccurrencesOfElement, minimumOccurrences, -1,
		endStringPositions, ...)
end

quantifierMatchMode[quantifierModesEnum[ENUM_LAZY_QUANTIFIER]] = function(minimumOccurrences,
	maximumOccurrencesOfElement, endStringPositions, ...)

	return matchBacktrackElement(minimumOccurrences, maximumOccurrencesOfElement, 1,
		endStringPositions, ...)
end

quantifierMatchMode[quantifierModesEnum[ENUM_POSSESSIVE_QUANTIFIER]] = function(
	minimumOccurrences, maximumOccurrencesOfElement, endStringPositions, ...)

	return matchBacktrackElement(maximumOccurrencesOfElement, maximumOccurrencesOfElement, 1,
		endStringPositions, ...)
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

	local maximumOccurrencesOfElement, endStringPositions = getMaximumOccurrencesOfElement(
		quantifier, currentElement, singleElementMatcher,
		currentCharacter, treeMatcher,
		flags,
		splitStr, strLength,
		stringIndex
	)

	pdebug('\t\t\t\tmaximum occurrences  : ', maximumOccurrencesOfElement)

	local minimumOccurrences = quantifier.min
	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end

	local mode = quantifier.mode or "greedy"
	return quantifierMatchMode[mode](
		minimumOccurrences, maximumOccurrencesOfElement, endStringPositions,
		treeMatcher,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex
	)
end

return Quantifier