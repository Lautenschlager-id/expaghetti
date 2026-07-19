----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
local parser = require("./parser")
local MatchState = require("./match_state")
local config = require("./config")
----------------------------------------------------------------------------------------------------
local Alternate = require("./magic/alternate")
local Anchor = require("./magic/anchor")
local Balanced = require("./magic/balanced")
local Boundary = require("./magic/boundary")
local CaptureReference = require("./magic/capture_reference")
local Group = require("./magic/group/group")
local PositionCapture = require("./magic/position_capture")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local Any = require("./magic/any")
local Literal = require("./magic/literal")
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local ENUM_FLAG_UNICODE = require("./enums/flags").flags.UNICODE
local quantifierModesEnum = require("./enums/quantifierModes")
local ENUM_QUANTIFIER_MODE_LAZY = quantifierModesEnum.LAZY
local ENUM_QUANTIFIER_MODE_POSSESSIVE = quantifierModesEnum.POSSESSIVE
local ENUM_QUANTIFIER_MODE_GREEDY = quantifierModesEnum.GREEDY
----------------------------------------------------------------------------------------------------
local enumElements = require("./enums/elements")
local ENUM_ELEMENT_TYPE_ALTERNATE = enumElements.alternate
local ENUM_ELEMENT_TYPE_ANCHOR = enumElements.anchor
local ENUM_ELEMENT_TYPE_ANY = enumElements.any
local ENUM_ELEMENT_TYPE_BALANCED = enumElements.balanced
local ENUM_ELEMENT_TYPE_BOUNDARY = enumElements.boundary
local ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE = enumElements.capture_reference
local ENUM_ELEMENT_TYPE_GROUP = enumElements.group
local ENUM_ELEMENT_TYPE_LITERAL = enumElements.literal
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = enumElements.position_capture
local ENUM_ELEMENT_TYPE_SET = enumElements.set
----------------------------------------------------------------------------------------------------
local function canBacktrackNestedQuantifier(quantifier, element)
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	return mode ~= ENUM_QUANTIFIER_MODE_POSSESSIVE
		and AST.elementHasNestedQuantifier(element)
		and not AST.elementInnerQuantifierIsPossessive(element)
end
----------------------------------------------------------------------------------------------------
local elementMatchers = {
	[ENUM_ELEMENT_TYPE_ALTERNATE] = {
		matcher = Alternate.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_ANCHOR] = {
		matcher = Anchor.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_ANY] = {
		matcher = Any.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_BALANCED] = {
		matcher = Balanced.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_BOUNDARY] = {
		matcher = Boundary.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE] = {
		matcher = CaptureReference.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_GROUP] = {
		matcher = Group.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_LITERAL] = {
		matcher = Literal.match,
		requiresCharacter = true,
	},
	[ENUM_ELEMENT_TYPE_POSITION_CAPTURE] = {
		matcher = PositionCapture.match,
		requiresCharacter = false,
	},
	[ENUM_ELEMENT_TYPE_SET] = {
		matcher = Set.match,
		requiresCharacter = true,
	},
}

local singleElementMatcher = function(currentElement, currentCharacter, state)
	local elementClass = elementMatchers[currentElement.type]
	if not elementClass then
		return false
	end

	if elementClass.requiresCharacter and not currentCharacter then
		return false
	end

	return elementClass.matcher(currentElement, state, currentCharacter)
end

local coreTreeMatcher -- Forward declaration

local function quantifyElement(
	currentElement, currentCharacter, state
)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	local canBacktrackInner = canBacktrackNestedQuantifier(quantifier, currentElement)

	local totalOccurrences = 0
	local endStringPositions = { }
	local startStringPositions = { }

	local hasMatched, iniStr, endStr, lastIniStr, lastEndStr
	local stringIndex = state.stringIndex

	local function hasMoreOccurrencesAllowed()
		return maximumOccurrences == 0 or totalOccurrences < maximumOccurrences
	end

	local function extendOccurrenceCollection()
		while hasMoreOccurrencesAllowed() do
			startStringPositions[totalOccurrences + 1] = stringIndex

			local tempState = state:branch(stringIndex, state.initialStringIndex)
			tempState.tree = nil
			tempState.treeIndex = nil
			hasMatched, iniStr, endStr = singleElementMatcher(
				currentElement, currentCharacter, tempState
			)

			if not hasMatched then
				return false
			end

			endStr = endStr or stringIndex

			if state.metaData.quantifierMaxEnd and endStr > state.metaData.quantifierMaxEnd then
				return false
			end

			totalOccurrences = totalOccurrences + 1
			endStringPositions[totalOccurrences] = endStr

			if not hasMoreOccurrencesAllowed()
				or (iniStr and iniStr > endStr)
				or (lastIniStr == iniStr and lastEndStr == endStr)
			then
				return true
			end
			lastIniStr, lastEndStr = iniStr, endStr

			stringIndex = endStr + 1
			currentCharacter = state:getTargetCharacter(stringIndex)
		end

		return true
	end

	extendOccurrenceCollection()

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

		extendOccurrenceCollection()
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

	local function shortenOccurrenceAt(occurrenceIndex)
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
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state:getTargetCharacter(occurrenceStart), tempState
		)

		state.metaData.quantifierMaxEnd = nil

		if not hasMatched or (endStr and endStr >= occurrenceEnd) then
			return false
		end

		endStr = endStr or occurrenceStart
		endStringPositions[occurrenceIndex] = endStr
		totalOccurrences = occurrenceIndex
		maximumOccurrencesOfElement = totalOccurrences

		return true
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
			while shortenOccurrenceAt(totalOccurrences) do
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
		end
	end
end

coreTreeMatcher = function(state)
	local tree = state.tree
	local treeIndex = state.treeIndex

	local outerTreeReference = state.metaData.outerTreeReference[tree]
	local outerTree = outerTreeReference and outerTreeReference.tree

	local currentElement, currentCharacter
	local hasQuantifier
	local hasMatched, iniStr, endStr, _, shouldEndThisExecution

	while treeIndex < tree._index do
		treeIndex = treeIndex + 1
		state.treeIndex = treeIndex
		currentElement = tree[treeIndex]

		state.stringIndex = state.stringIndex + 1
		currentCharacter = state:getTargetCharacter(state.stringIndex)

		hasQuantifier = Quantifier.isElement(currentElement)

		if not hasQuantifier then
			hasMatched, iniStr, endStr, _, shouldEndThisExecution = singleElementMatcher(
				currentElement, currentCharacter, state
			)

			-- Groups continue the execution of the previous tree in another stack
			if shouldEndThisExecution then
				return hasMatched, iniStr, endStr, state.metaData
			elseif not hasMatched then
				return
			elseif endStr then
				state.stringIndex = endStr
			end
		else
			return quantifyElement(
				currentElement, currentCharacter, state
			)
		end
	end

	if outerTreeReference then
		local groupIndex = tree._groupIndex
		local pushedCapture = false
		if groupIndex then
			state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
			pushedCapture = true
		end

		state.initialStringIndex = outerTreeReference.initialStringIndex
		
		state.tree = outerTreeReference.tree
		state.treeIndex = outerTreeReference.treeIndex

		local hasMatched, oIni, oEnd, oMeta = coreTreeMatcher(state)

		if not hasMatched and pushedCapture then
			state:popCapture(groupIndex)
		end

		return hasMatched, oIni, oEnd, oMeta
	end

	local groupIndex = tree._groupIndex
	if groupIndex then
		state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
	end

	return true, state.initialStringIndex + 1, state.stringIndex, state.metaData
end



local matcher = function(expr, str, flags, stringIndex)
	if type(expr) ~= "string" then
		return false, "Expression must be a string"
	end
	if type(str) ~= "string" then
		return false, "Target must be a string"
	end

	if type(flags) == "string" then
		local t = {}
		for char in flags:gmatch(".") do
			t[char] = true
		end
		flags = t
	else
		flags = flags or {}
	end

	local tree, errorMessage = parser(expr, flags)
	if not tree then
		return false, errorMessage
	end
	local treeLength = tree._index

	stringIndex = stringIndex or 0

	local state = MatchState.new(flags, str, tree)

	local hasMatched, iniStr, endStr, matcherMetaData
	while stringIndex <= state.targetStringLength do
		state:reset(stringIndex)
		state.tree = tree
		state.treeIndex = 0
		
		hasMatched, iniStr, endStr, matcherMetaData = coreTreeMatcher(state)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData
		end

		stringIndex = stringIndex + 1
	end
end

MatchState.matcher = coreTreeMatcher

return matcher
