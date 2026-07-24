--[[
    Matcher for quantified AST elements.

    Handles greedy, lazy, and possessive quantifiers, including
    nested backtracking and continuation of the main matching engine.
]]

--[[ Dependencies ]]--
local elementMatcher = require("matcher.element")

--[[ Enums ]]--
local QUANTIFIER_MODES = require("enums.quantifiers").MODES

--[[ Aliases ]]--
local ELEMENT_GROUP = require("enums.elements").GROUP

local QUANTIFIER_MODE_GREEDY = QUANTIFIER_MODES.GREEDY
local QUANTIFIER_MODE_LAZY = QUANTIFIER_MODES.LAZY
local QUANTIFIER_MODE_POSSESSIVE = QUANTIFIER_MODES.POSSESSIVE

--[[ Module ]]--

--- Determines whether the quantified element supports nested backtracking.
---@param element ASTElement The quantified AST element.
---@param quantifier Quantifier The quantifier attached to the element.
---@return boolean canBacktrack Whether nested backtracking is allowed.
local canBacktrackNestedQuantifier = function(element, quantifier)
	local tree = element.tree

	if quantifier.mode == QUANTIFIER_MODE_POSSESSIVE or element.type ~= ELEMENT_GROUP or not tree then
		return false
	end

	local hasNested = false
	for index = 1, tree._index do
		local childQuantifier = tree[index].quantifier
		if childQuantifier then
			if childQuantifier.mode == QUANTIFIER_MODE_POSSESSIVE then
				return false
			end
			hasNested = true
		end
	end

	return hasNested
end

--- Executes a single match attempt for an AST element.
--- Preserves and restores the current matcher state before returning.
---@param state MatchState The matcher state.
---@param currentElement ASTElement The AST element to match.
---@param currentCharacter string|number The target character at the current string index.
---@param stringIndex number The string index to begin matching from.
---@param quantifierMaxEnd number|nil The maximum string index the element may consume.
---@return boolean hasMatched Whether the element matched successfully.
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

--- Continues matching after a quantified element.
---@param state MatchState The matcher state.
---@param targetStringIndex number The string index where matching should resume.
---@return boolean hasMatched Whether the remaining expression matched successfully.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return MatcherMetadata|nil metadata The match metadata.
local continueMatcher = function(state, targetStringIndex)
	local savedStringIndex = state.stringIndex
	local savedTree = state.tree
	local savedTreeIndex = state.treeIndex
	local savedQuantifierMaxEnd = state.quantifierMaxEnd

	state.stringIndex = targetStringIndex

	local hasMatched, iniStr, endStr, metadata = state.matcher(state)

	state.stringIndex = savedStringIndex
	state.tree = savedTree
	state.treeIndex = savedTreeIndex
	state.quantifierMaxEnd = savedQuantifierMaxEnd

	return hasMatched, iniStr, endStr, metadata
end

--- Greedily collects consecutive occurrences of a quantified element.
---@param state MatchState The matcher state.
---@param currentElement ASTElement The quantified AST element.
---@param maximumOccurrences number The maximum allowed number of occurrences (0 for unlimited).
---@param stringIndex number The string index to begin matching from.
---@param totalOccurrences number The current number of collected occurrences.
---@param startStringPositions number[] The array storing occurrence start positions.
---@param endStringPositions number[] The array storing occurrence end positions.
---@return number totalOccurrences The updated number of collected occurrences.
---@return number stringIndex The string index after collection completes.
local collectOccurrences = function(
	state,
	currentElement,
	maximumOccurrences,
	stringIndex,
	totalOccurrences,
	startStringPositions,
	endStringPositions
)
	local lastIniStr, lastEndStr
	-- Greedily match the element repeatedly until we hit the maximum limit (0 means no limit).
	while maximumOccurrences == 0 or totalOccurrences < maximumOccurrences do
		-- Record the start position of the current occurrence for future backtracking.
		startStringPositions[totalOccurrences + 1] = stringIndex

		local currentCharacter = state:getTargetCharacter(stringIndex)
		local hasMatched, iniStr, endStr = executeElement(state, currentElement, currentCharacter, stringIndex, nil)

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

--- Attempts to shorten a previously matched occurrence by backtracking.
---@param state MatchState The matcher state.
---@param currentElement ASTElement The quantified AST element.
---@param elementCaptureId number|string The capture group identifier.
---@param occurrenceIndex number The occurrence to shorten.
---@param startStringPositions number[] The occurrence start positions.
---@param endStringPositions number[] The occurrence end positions.
---@return boolean didShorten Whether the occurrence was successfully shortened.
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

--- Matches a quantified AST element.
---@param currentElement ASTElement The quantified AST element.
---@param currentCharacter string|number The target character at the current string index.
---@param state MatchState The matcher state.
---@return boolean hasMatched Whether the quantified element matched successfully.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return MatcherMetadata|nil metadata The match metadata.
---@return boolean|nil shouldEndThisExecution Whether the current execution stack should terminate.
local quantifierMatcher = function(currentElement, currentCharacter, state)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or QUANTIFIER_MODE_GREEDY
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
	if mode == QUANTIFIER_MODE_GREEDY then
		-- Greedy: Start from maximum occurrences and backtrack down to minimum.
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = minimumOccurrences
		step = -1
	elseif mode == QUANTIFIER_MODE_LAZY then
		-- Lazy: Start from minimum occurrences and work up to maximum.
		startOccurrences = minimumOccurrences
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	elseif mode == QUANTIFIER_MODE_POSSESSIVE then
		-- Possessive: Yield the maximum occurrences exactly once. Never backtrack.
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

		-- Yield the boundary of the current occurrence sequence to the rest of the regular expression engine.
		local targetStringIndex = endStringPositions[occurrence] or (state.stringIndex - 1)
		local hasMatched, iniStr, endStr, metadata = continueMatcher(state, targetStringIndex)
		
		-- If the rest of the engine matched successfully, the entire regular expression is satisfied!
		if hasMatched then
			return hasMatched, iniStr, endStr, metadata
		end

		-- Step 4: Internal Backtracking during Outer Failure
		-- The rest of the engine failed. Before giving up and trying the next total count, 
		-- check if we can shorten the currently active occurrence internally and retry the engine.
		if canBacktrackInner and occurrence > 0 then
			totalOccurrences = occurrence
			local didShorten
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
					hasMatched, iniStr, endStr, metadata = continueMatcher(state, targetStringIndex)

					if hasMatched then
						return hasMatched, iniStr, endStr, metadata
					end
				end
			until not didShorten
		end
	end
end

return quantifierMatcher
