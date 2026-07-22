local elementMatcher = require("matcher.element")
local AST = require("ast")

local quantifierModesEnum = require("enums.quantifiers").MODES
local ENUM_QUANTIFIER_MODE_LAZY = quantifierModesEnum.LAZY
local ENUM_QUANTIFIER_MODE_POSSESSIVE = quantifierModesEnum.POSSESSIVE
local ENUM_QUANTIFIER_MODE_GREEDY = quantifierModesEnum.GREEDY

local elementsEnum = require("enums.elements")
local ENUM_ELEMENT_TYPE_GROUP = elementsEnum.GROUP
local ENUM_ELEMENT_TYPE_QUANTIFIER = elementsEnum.QUANTIFIER

--- Determines if the internal element of a quantifier is allowed to be backtracked.
---@param element table The AST element containing the quantifier.
---@param quantifier table The quantifier metadata for the element.
---@return boolean canBacktrack True if nested backtracking is allowed.
local canBacktrackNestedQuantifier = function(element, quantifier)
	local tree = element.tree

	if (
		quantifier.mode == ENUM_QUANTIFIER_MODE_POSSESSIVE
		or element.type ~= ENUM_ELEMENT_TYPE_GROUP
		or not tree
 	) then
		return false
	end

	local hasNested = false
	for index = 1, tree._index do
		local childQuantifier = tree[index].quantifier
		if childQuantifier then
			if childQuantifier.mode == ENUM_QUANTIFIER_MODE_POSSESSIVE then
				return false
			end
			hasNested = true
		end
	end

	return hasNested
end

--- Executes a single match step for the element while preserving and restoring the current state.
---@param state table The MatchState object containing the matching context.
---@param currentElement table The AST element being matched.
---@param currentCharacter string|number The target character at the current stringIndex.
---@param stringIndex number The string index to start matching from.
---@param quantifierMaxEnd number|nil The maximum allowed string index for this element to match.
---@return boolean hasMatched True if the element successfully matched.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
local executeElement = function(state, currentElement, currentCharacter, stringIndex, quantifierMaxEnd)
	local savedStringIndex = state.stringIndex
	local savedTree = state.tree
	local savedTreeIndex = state.treeIndex
	local savedQuantifierMaxEnd = state.quantifierMaxEnd

	state.stringIndex = stringIndex
	state.tree = nil
	state.treeIndex = nil
	state.quantifierMaxEnd = quantifierMaxEnd

	local hasMatched, iniStr, endStr = elementMatcher(currentElement, currentCharacter, state)

	state.stringIndex = savedStringIndex
	state.tree = savedTree
	state.treeIndex = savedTreeIndex
	state.quantifierMaxEnd = savedQuantifierMaxEnd

	return hasMatched, iniStr, endStr
end

--- Continues the main matching process from the target string index after a quantifier match.
---@param state table The MatchState object containing the execution context.
---@param targetStringIndex number The string index to resume the main engine at.
---@return boolean hasMatched True if the rest of the expression successfully matched.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return table|nil meta Captured metadata from the subsequent execution.
local continueMatcher = function(state, targetStringIndex)
	local savedStringIndex = state.stringIndex
	local savedTree = state.tree
	local savedTreeIndex = state.treeIndex
	local savedQuantifierMaxEnd = state.quantifierMaxEnd

	state.stringIndex = targetStringIndex

	local hasMatched, iniStr, endStr, meta = state.matcher(state)

	state.stringIndex = savedStringIndex
	state.tree = savedTree
	state.treeIndex = savedTreeIndex
	state.quantifierMaxEnd = savedQuantifierMaxEnd

	return hasMatched, iniStr, endStr, meta
end

--- Greedily collects all matching occurrences of the quantified element up to maximumOccurrences.
---@param state table The MatchState object containing the matching context.
---@param currentElement table The AST element being matched.
---@param maximumOccurrences number The maximum number of occurrences allowed.
---@param stringIndex number The current string index to start collecting from.
---@param totalOccurrences number The current total count of occurrences collected.
---@param startStringPositions table The output array to record start positions.
---@param endStringPositions table The output array to record end positions.
---@return number totalOccurrences The updated total number of occurrences collected.
---@return number stringIndex The updated string index after all collections.
local collectOccurrences = function(
	state,
	currentElement,
	maximumOccurrences,
	stringIndex,
	totalOccurrences,
	startStringPositions,
	endStringPositions
)
	local hasMatched, iniStr, endStr
	local lastIniStr, lastEndStr
	local currentCharacter
	
	-- Greedily match the element repeatedly until we hit the maximum limit (0 means no limit).
	while maximumOccurrences == 0 or totalOccurrences < maximumOccurrences do
		-- Record the start position of the current occurrence for future backtracking.
		startStringPositions[totalOccurrences + 1] = stringIndex

		currentCharacter = state:getTargetCharacter(stringIndex)
		hasMatched, iniStr, endStr = executeElement(state, currentElement, currentCharacter, stringIndex, nil)

		if not hasMatched then
			return totalOccurrences, stringIndex
		end

		endStr = endStr or stringIndex

		if state.quantifierMaxEnd and endStr > state.quantifierMaxEnd then
			return totalOccurrences, stringIndex
		end

		totalOccurrences = totalOccurrences + 1
		endStringPositions[totalOccurrences] = endStr

		-- Stop collecting if we hit the limit, matched backwards, or if this match consumed exactly 
		-- zero characters (matching the identical boundaries as the previous iteration) to prevent infinite loops.
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

--- Attempts to shorten a previously collected occurrence by backtracking by one match length.
---@param state table The MatchState object containing the matching context.
---@param currentElement table The AST element being matched.
---@param elementCaptureId number|string The identifier for capturing groups or named groups.
---@param occurrenceIndex number The index of the occurrence to shorten.
---@param startStringPositions table The array containing start positions of occurrences.
---@param endStringPositions table The array containing end positions of occurrences.
---@return boolean didShorten True if the occurrence was successfully shortened.
local shortenOccurrenceAt = function(
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

	-- Erase the previously recorded capture group since we are about to modify its boundaries.
	state:popCapture(elementCaptureId)
	
	local currentCharacter = state:getTargetCharacter(occurrenceStart)
	
	-- Re-execute the element, but artificially restrict its maximum consumption to one character less than before.
	local hasMatched, iniStr, endStr = executeElement(state, currentElement, currentCharacter, occurrenceStart, occurrenceEnd - 1)

	-- If the element fails to match with the restricted length, or it ignores the restriction, shortening failed.
	if not hasMatched or (endStr and endStr >= occurrenceEnd) then
		return false
	end

	endStringPositions[occurrenceIndex] = endStr or occurrenceStart

	return true
end

--- The main entry point for matching elements with quantifiers (?, *, +, {m,n}).
---@param currentElement table The AST element representing the quantifier.
---@param currentCharacter string|number The character at the current match position.
---@param state table The MatchState object.
---@return boolean hasMatched True if the quantifier and its element matched successfully.
---@return number|nil iniStr The starting string index.
---@return number|nil endStr The ending string index.
---@return table|nil metaData Captured metadata if the execution finishes here.
---@return boolean|nil shouldEndThisExecution True if the execution stack should end here.
local quantifierMatcher = function(currentElement, currentCharacter, state)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or ENUM_QUANTIFIER_MODE_GREEDY
	local canBacktrackInner = canBacktrackNestedQuantifier(currentElement, quantifier)
	local elementCaptureId = currentElement.index or currentElement.name

	local totalOccurrences = 0
	local endStringPositions = {}
	local startStringPositions = {}

	local stringIndex = state.stringIndex

	-- Step 1: Initial Greedy Collection
	-- Execute the element sequentially, collecting as many full occurrences as possible up to max.
	totalOccurrences, stringIndex = collectOccurrences(
		state,
		currentElement,
		maximumOccurrences,
		stringIndex,
		totalOccurrences,
		startStringPositions,
		endStringPositions
	)

	-- Step 2: Satisfy Minimum Occurrences via Internal Backtracking
	-- If we haven't met the minimum required matches, but the element itself is internally backtrackable 
	-- (e.g., a greedy group), we can try to artificially shorten the last occurrence to allow subsequent matches.
	while totalOccurrences < minimumOccurrences and canBacktrackInner and totalOccurrences > 0 do
		if not shortenOccurrenceAt(
			state,
			currentElement,
			elementCaptureId,
			totalOccurrences,
			startStringPositions,
			endStringPositions
		) then
			break
		end
		
		stringIndex = endStringPositions[totalOccurrences] + 1
		
		totalOccurrences, stringIndex = collectOccurrences(
			state,
			currentElement,
			maximumOccurrences,
			stringIndex,
			totalOccurrences,
			startStringPositions,
			endStringPositions
		)
	end

	local maximumOccurrencesOfElement = totalOccurrences

	-- If after all attempts we still haven't met the minimum quantifier requirement, the entire quantifier fails.
	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end
	
	-- Step 3: Outer Engine Yield Order
	-- Configure the loop that will yield the collected occurrences to the rest of the matching engine.
	local startOccurrences, endOccurrences, step
	if mode == ENUM_QUANTIFIER_MODE_GREEDY then
		-- Greedy: Start from maximum occurrences and backtrack down to minimum.
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = minimumOccurrences
		step = -1
	elseif mode == ENUM_QUANTIFIER_MODE_LAZY then
		-- Lazy: Start from minimum occurrences and work up to maximum.
		startOccurrences = minimumOccurrences
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	elseif mode == ENUM_QUANTIFIER_MODE_POSSESSIVE then
		-- Possessive: Yield the maximum occurrences exactly once. Never backtrack.
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	end

	local targetStringIndex
	local hasMatched, iniStr, endStr, meta
	local didShorten

	for occurrence = startOccurrences, endOccurrences, step do
		if occurrence ~= startOccurrences then
			if state:incrementBacktrack() then
				return
			end
		end

		-- Yield the boundary of the current occurrence sequence to the rest of the regex engine.
		targetStringIndex = endStringPositions[occurrence] or (state.stringIndex - 1)
		hasMatched, iniStr, endStr, meta = continueMatcher(state, targetStringIndex)
		
		-- If the rest of the engine matched successfully, the entire regex is satisfied!
		if hasMatched then
			return hasMatched, iniStr, endStr, meta
		end

		-- Step 4: Internal Backtracking during Outer Failure
		-- The rest of the engine failed. Before giving up and trying the next total count, 
		-- check if we can shorten the currently active occurrence internally and retry the engine.
		if canBacktrackInner and occurrence > 0 then
			totalOccurrences = occurrence
			repeat
				-- Shrink the boundary of the last occurrence by one character.
				didShorten = shortenOccurrenceAt(
					state,
					currentElement,
					elementCaptureId,
					totalOccurrences,
					startStringPositions,
					endStringPositions
				)

				if didShorten then
					targetStringIndex = endStringPositions[totalOccurrences] or (state.stringIndex - 1)
					hasMatched, iniStr, endStr, meta = continueMatcher(state, targetStringIndex)

					if hasMatched then
						return hasMatched, iniStr, endStr, meta
					end
				end
			until not didShorten
		end
	end
end

return quantifierMatcher
