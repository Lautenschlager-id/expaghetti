local singleElementMatcher = require("matcher.single_element")
local AST = require("ast")

local quantifierModesEnum = require("enums.quantifierModes")
local ENUM_QUANTIFIER_MODE_LAZY = quantifierModesEnum.LAZY
local ENUM_QUANTIFIER_MODE_POSSESSIVE = quantifierModesEnum.POSSESSIVE
local ENUM_QUANTIFIER_MODE_GREEDY = quantifierModesEnum.GREEDY

local QuantifierMatcher = {}

function QuantifierMatcher.canBacktrackNestedQuantifier(quantifier, element)
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	return mode ~= ENUM_QUANTIFIER_MODE_POSSESSIVE
		and AST.elementHasNestedQuantifier(element)
		and not AST.elementInnerQuantifierIsPossessive(element)
end

function QuantifierMatcher.collectOccurrences(
	state,
	currentElement,
	currentCharacter,
	stringIndex,
	maximumOccurrences,
	startStringPositions,
	endStringPositions,
	totalOccurrences,
	lastIniStr,
	lastEndStr
)
	local hasMatched, iniStr, endStr

	while maximumOccurrences == 0 or totalOccurrences < maximumOccurrences do
		startStringPositions[totalOccurrences + 1] = stringIndex

		local tempState = state:branch(stringIndex, state.initialStringIndex)
		tempState.tree = nil
		tempState.treeIndex = nil
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, currentCharacter, tempState
		)

		if not hasMatched then
			return false, totalOccurrences, stringIndex, currentCharacter, lastIniStr, lastEndStr
		end

		endStr = endStr or stringIndex

		if state.metaData.quantifierMaxEnd and endStr > state.metaData.quantifierMaxEnd then
			return false, totalOccurrences, stringIndex, currentCharacter, lastIniStr, lastEndStr
		end

		totalOccurrences = totalOccurrences + 1
		endStringPositions[totalOccurrences] = endStr

		if (maximumOccurrences ~= 0 and totalOccurrences >= maximumOccurrences)
			or (iniStr and iniStr > endStr)
			or (lastIniStr == iniStr and lastEndStr == endStr)
		then
			return true, totalOccurrences, stringIndex, currentCharacter, lastIniStr, lastEndStr
		end
		lastIniStr, lastEndStr = iniStr, endStr

		stringIndex = endStr + 1
		currentCharacter = state:getTargetCharacter(stringIndex)
	end

	return true, totalOccurrences, stringIndex, currentCharacter, lastIniStr, lastEndStr
end

function QuantifierMatcher.shortenOccurrenceAt(
	state,
	currentElement,
	occurrenceIndex,
	startStringPositions,
	endStringPositions
)
	local occurrenceStart = startStringPositions[occurrenceIndex]
	local occurrenceEnd = endStringPositions[occurrenceIndex]

	if not occurrenceStart or occurrenceEnd <= occurrenceStart then
		return false
	end

	if state:incrementBacktrack() then
		return false
	end

	state:popCapture(currentElement.index or currentElement.name)
	state.metaData.quantifierMaxEnd = occurrenceEnd - 1

	local tempState = state:branch(occurrenceStart, occurrenceStart)
	tempState.tree = nil
	tempState.treeIndex = nil
	local hasMatched, iniStr, endStr = singleElementMatcher(
		currentElement, state:getTargetCharacter(occurrenceStart), tempState
	)

	state.metaData.quantifierMaxEnd = nil

	if not hasMatched or (endStr and endStr >= occurrenceEnd) then
		return false
	end

	endStr = endStr or occurrenceStart
	endStringPositions[occurrenceIndex] = endStr

	return true, endStr
end

function QuantifierMatcher.match(currentElement, currentCharacter, state)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	local canBacktrackInner = QuantifierMatcher.canBacktrackNestedQuantifier(quantifier, currentElement)

	local totalOccurrences = 0
	local endStringPositions = {}
	local startStringPositions = {}

	local hasMatched, iniStr, endStr, lastIniStr, lastEndStr
	local stringIndex = state.stringIndex
	local coreTreeMatcher = state.matcher

	local function extend()
		local _
		_, totalOccurrences, stringIndex, currentCharacter, lastIniStr, lastEndStr = QuantifierMatcher.collectOccurrences(
			state,
			currentElement,
			currentCharacter,
			stringIndex,
			maximumOccurrences,
			startStringPositions,
			endStringPositions,
			totalOccurrences,
			lastIniStr,
			lastEndStr
		)
	end

	extend()

	while totalOccurrences < minimumOccurrences and canBacktrackInner and totalOccurrences > 0 do
		local lastOccurrence = totalOccurrences
		local occurrenceStart = startStringPositions[lastOccurrence]
		local occurrenceEnd = endStringPositions[lastOccurrence]

		if not occurrenceStart or occurrenceEnd <= occurrenceStart then
			break
		end

		if state:incrementBacktrack() then
			return
		end

		state:popCapture(currentElement.index or currentElement.name)
		state.metaData.quantifierMaxEnd = occurrenceEnd - 1

		local tempState = state:branch(occurrenceStart, occurrenceStart)
		tempState.tree = nil
		tempState.treeIndex = nil
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state:getTargetCharacter(occurrenceStart), tempState
		)

		state.metaData.quantifierMaxEnd = nil

		if not hasMatched then
			break
		end

		endStr = endStr or occurrenceStart
		endStringPositions[lastOccurrence] = endStr
		stringIndex = endStr + 1
		currentCharacter = state:getTargetCharacter(stringIndex)
		lastIniStr, lastEndStr = nil, nil

		extend()
	end

	local maximumOccurrencesOfElement = totalOccurrences

	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end
	
	local startOccurrences, endOccurrences, step
	if mode == ENUM_QUANTIFIER_MODE_GREEDY then
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = minimumOccurrences
		step = -1
	elseif mode == ENUM_QUANTIFIER_MODE_LAZY then
		startOccurrences = minimumOccurrences
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	elseif mode == ENUM_QUANTIFIER_MODE_POSSESSIVE then
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	end

	for occurrence = startOccurrences, endOccurrences, step do
		if occurrence ~= startOccurrences then
			if state:incrementBacktrack() then
				return
			end
		end

		-- Try continuation from end of this many occurrences
		local targetStringIndex = endStringPositions[occurrence]
			or (state.stringIndex - 1)

		local tempState = state:branch(targetStringIndex, state.initialStringIndex)
		hasMatched, iniStr, endStr = coreTreeMatcher(
			tempState
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, state.metaData
		end

		-- Inner backtracking: shorten the current last occurrence
		if canBacktrackInner and occurrence > 0 then
			totalOccurrences = occurrence
			local didShorten
			repeat
				didShorten = QuantifierMatcher.shortenOccurrenceAt(
					state,
					currentElement,
					totalOccurrences,
					startStringPositions,
					endStringPositions
				)

				if didShorten then
					targetStringIndex = endStringPositions[totalOccurrences]
						or (state.stringIndex - 1)

					tempState = state:branch(targetStringIndex, state.initialStringIndex)
					hasMatched, iniStr, endStr = coreTreeMatcher(
						tempState
					)

					if hasMatched then
						return hasMatched, iniStr, endStr, state.metaData
					end
				end
			until not didShorten
		end
	end
end

return QuantifierMatcher
