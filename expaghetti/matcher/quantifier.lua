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

local function executeWithTemporaryState(state, stringIndex, quantifierMaxEnd, clearTree, func, arg1, arg2)
	local savedStringIndex = state.stringIndex
	local savedTree = state.tree
	local savedTreeIndex = state.treeIndex
	local savedQuantifierMaxEnd = state.quantifierMaxEnd

	state.stringIndex = stringIndex
	if quantifierMaxEnd ~= nil then
		state.quantifierMaxEnd = quantifierMaxEnd
	end
	if clearTree then
		state.tree = nil
		state.treeIndex = nil
	end

	local r1, r2, r3, r4 = func(arg1, arg2, state)

	state.stringIndex = savedStringIndex
	state.tree = savedTree
	state.treeIndex = savedTreeIndex
	state.quantifierMaxEnd = savedQuantifierMaxEnd

	return r1, r2, r3, r4
end

local function callMatcher(_, _, state)
	return state.matcher(state)
end

function QuantifierMatcher.continueMatching(state, targetStringIndex)
	return executeWithTemporaryState(state, targetStringIndex, nil, false, callMatcher)
end

function QuantifierMatcher.collectOccurrences(
	state,
	currentElement,
	stringIndex,
	maximumOccurrences,
	startStringPositions,
	endStringPositions,
	totalOccurrences
)
	local hasMatched, iniStr, endStr
	local lastIniStr, lastEndStr

	while maximumOccurrences == 0 or totalOccurrences < maximumOccurrences do
		startStringPositions[totalOccurrences + 1] = stringIndex

		local currentCharacter = state:getTargetCharacter(stringIndex)
		hasMatched, iniStr, endStr = executeWithTemporaryState(
			state, stringIndex, nil, true, singleElementMatcher, currentElement, currentCharacter
		)

		if not hasMatched then
			return totalOccurrences, stringIndex
		end

		endStr = endStr or stringIndex

		if state.quantifierMaxEnd and endStr > state.quantifierMaxEnd then
			return totalOccurrences, stringIndex
		end

		totalOccurrences = totalOccurrences + 1
		endStringPositions[totalOccurrences] = endStr

		if (maximumOccurrences ~= 0 and totalOccurrences >= maximumOccurrences)
			or (iniStr and iniStr > endStr)
			or (lastIniStr == iniStr and lastEndStr == endStr)
		then
			return totalOccurrences, stringIndex
		end
		
		lastIniStr, lastEndStr = iniStr, endStr
		stringIndex = endStr + 1
	end

	return totalOccurrences, stringIndex
end

function QuantifierMatcher.shortenOccurrenceAt(
	state,
	currentElement,
	elementCaptureId,
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

	state:popCapture(elementCaptureId)
	
	local currentCharacter = state:getTargetCharacter(occurrenceStart)
	local hasMatched, iniStr, endStr = executeWithTemporaryState(
		state, occurrenceStart, occurrenceEnd - 1, true, singleElementMatcher, currentElement, currentCharacter
	)

	if not hasMatched or (endStr and endStr >= occurrenceEnd) then
		return false
	end

	endStr = endStr or occurrenceStart
	endStringPositions[occurrenceIndex] = endStr

	return true
end

function QuantifierMatcher.match(currentElement, currentCharacter, state)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	local canBacktrackInner = QuantifierMatcher.canBacktrackNestedQuantifier(quantifier, currentElement)
	local elementCaptureId = currentElement.index or currentElement.name

	local totalOccurrences = 0
	local endStringPositions = {}
	local startStringPositions = {}

	local stringIndex = state.stringIndex

	totalOccurrences, stringIndex = QuantifierMatcher.collectOccurrences(
		state,
		currentElement,
		stringIndex,
		maximumOccurrences,
		startStringPositions,
		endStringPositions,
		totalOccurrences
	)

	while totalOccurrences < minimumOccurrences and canBacktrackInner and totalOccurrences > 0 do
		if not QuantifierMatcher.shortenOccurrenceAt(state, currentElement, elementCaptureId, totalOccurrences, startStringPositions, endStringPositions) then
			break
		end
		
		stringIndex = endStringPositions[totalOccurrences] + 1
		
		totalOccurrences, stringIndex = QuantifierMatcher.collectOccurrences(
			state,
			currentElement,
			stringIndex,
			maximumOccurrences,
			startStringPositions,
			endStringPositions,
			totalOccurrences
		)
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

		local targetStringIndex = endStringPositions[occurrence] or (state.stringIndex - 1)
		local hasMatched, iniStr, endStr, meta = QuantifierMatcher.continueMatching(state, targetStringIndex)
		
		if hasMatched then
			return hasMatched, iniStr, endStr, meta
		end

		if canBacktrackInner and occurrence > 0 then
			totalOccurrences = occurrence
			local didShorten
			repeat
				didShorten = QuantifierMatcher.shortenOccurrenceAt(
					state,
					currentElement,
					elementCaptureId,
					totalOccurrences,
					startStringPositions,
					endStringPositions
				)

				if didShorten then
					targetStringIndex = endStringPositions[totalOccurrences] or (state.stringIndex - 1)
					hasMatched, iniStr, endStr, meta = QuantifierMatcher.continueMatching(state, targetStringIndex)

					if hasMatched then
						return hasMatched, iniStr, endStr, meta
					end
				end
			until not didShorten
		end
	end
end

return QuantifierMatcher
