--[[
    Group parser and matcher.

    Handles parsing and execution of all regular expression group constructs,
	including its different behaviors.
]]

--[[ Globals ]]--
local string_format = string.format
local tostring = tostring

--[[ Dependencies ]]--
local BehaviorAtomic = require("magic.group.behaviorAtomic")
local BehaviorBranchReset = require("magic.group.behaviorBranchReset")
local BehaviorCapturing = require("magic.group.behaviorCapturing")
local BehaviorComment = require("magic.group.behaviorComment")
local BehaviorFlags = require("magic.group.behaviorFlags")
local BehaviorLookaround = require("magic.group.behaviorLookaround")
local BehaviorRecursion = require("magic.group.behaviorRecursion")
local PositionCapture = require("magic.positionCapture")

--[[ Enums ]]--
local Elements = require("enums.elements")
local ElementLengths = require("enums.elementLengths")
local Errors = require("enums.errors")
local Magic = require("enums.magic")

--[[ Aliases ]]--
local isPositiveIntegerChar = require("helpers.parser").isPositiveIntegerChar

local FLAGS_INLINE_TOKENS = require("enums.flags").INLINE_TOKENS

local ELEMENT_GROUP = Elements.GROUP
local ELEMENT_ALTERNATE = Elements.ALTERNATE

local ERROR_UNKNOWN_ELEMENT_LENGTH = Errors.unknownElementLength
local ERROR_INVALID_GROUP_BEHAVIOR = Errors.invalidGroupBehavior
local ERROR_VARIABLE_LENGTH_LOOKBEHIND = Errors.variableLengthLookbehind
local ERROR_NO_GROUP_TO_CLOSE = Errors.unexpectedGroupClose

local MAGIC_GROUP_CLOSE = Magic.GROUP_CLOSE
local MAGIC_GROUP_OPEN = Magic.GROUP_OPEN

local MAGIC_GROUP_BEHAVIOR_PREFIX = Magic.GROUP_BEHAVIOR_PREFIX

local MAGIC_GROUP_ATOMIC_BEHAVIOR = Magic.GROUP_ATOMIC_BEHAVIOR
local MAGIC_GROUP_BRANCH_RESET_BEHAVIOR = Magic.GROUP_BRANCH_RESET_BEHAVIOR
local MAGIC_GROUP_COMMENT_BEHAVIOR = Magic.GROUP_COMMENT_BEHAVIOR
local MAGIC_GROUP_NON_CAPTURING_BEHAVIOR = Magic.GROUP_NON_CAPTURING_BEHAVIOR

local MAGIC_GROUP_LOOKBEHIND_BEHAVIOR = Magic.GROUP_LOOKBEHIND_BEHAVIOR
local MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR = Magic.GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR
local MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR = Magic.GROUP_LOOKAROUND_POSITIVE_BEHAVIOR

local MAGIC_GROUP_RECURSION_NAMED_BEHAVIOR = Magic.GROUP_RECURSION_NAMED_BEHAVIOR
local MAGIC_GROUP_RECURSION_ROOT_ALIAS = Magic.GROUP_RECURSION_ROOT_ALIAS
local MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR = Magic.GROUP_RECURSION_ROOT_BEHAVIOR

local SINGLE_LENGTH_ELEMENTS = ElementLengths.SINGLE_LENGTH
local ZERO_LENGTH_ELEMENTS = ElementLengths.ZERO_LENGTH

--[[ Module ]]--
local Group = {}

--[[ Private Functions ]]--

--- Computes the fixed character length of a lookbehind subtree.
---@param tree ASTTree The AST subtree to evaluate.
---@return number|nil fixedLength The subtree's fixed length, or nil if it is variable-length.
---@return string|nil errorMessage The parser error message when evaluation fails.
local getLookbehindFixedLength
getLookbehindFixedLength = function(tree)
	local totalLen = 0
	for index = 1, tree._index do
		local elem = tree[index]

		local quantifier = elem.quantifier
		local quantifierMin = quantifier and quantifier.min
		if quantifier and (quantifierMin ~= quantifier.max or quantifier.max == 0) then
			return nil
		end
		quantifierMin = quantifierMin or 1

		local errorMessage

		local elemType = elem.type

		-- Elements that don't consume characters
		if ZERO_LENGTH_ELEMENTS[elemType] or (elem.isLookahead or elem.isLookbehind) then
		-- Elements that consume 1 character
		elseif SINGLE_LENGTH_ELEMENTS[elemType] then
			totalLen = totalLen + quantifierMin
		elseif elemType == ELEMENT_GROUP then
			local groupLength
			groupLength, errorMessage = getLookbehindFixedLength(elem.tree)
			if not groupLength then
				return nil, errorMessage
			end
			totalLen = totalLen + (groupLength * quantifierMin)
		elseif elemType == ELEMENT_ALTERNATE then
			local branches, alternateLength, expectedAlternateLength = elem.branches
			for branch = 1, branches._index do
				alternateLength, errorMessage = getLookbehindFixedLength(branches[branch])
				if not alternateLength then
					return nil, errorMessage
				end

				-- Alternates must all have the same fixed length
				expectedAlternateLength = expectedAlternateLength or alternateLength
				if expectedAlternateLength ~= alternateLength then
					return nil
				end
			end

			totalLen = totalLen + (alternateLength * quantifierMin)
		else
			-- Unknown element, cannot determine length safely
			return nil, string_format(ERROR_UNKNOWN_ELEMENT_LENGTH, tostring(elemType or elem))
		end
    end
	return totalLen
end

--- Parses a group behavior declaration.
---@param state ParserState The current parser state.
---@return number|false nextIndex The parser index after the parsed behavior, or false on failure.
---@return table|nil group The parsed AST group node.
---@return string|nil errorMessage The parser error message when parsing fails.
local parseGroupBehavior = function(state)
	local index = state.index
	local nextIndex, currentChar = state:readElement(index)

	-- Standard capturing group (no `?` behavior prefix)
	if not nextIndex or state:isElement(currentChar) or currentChar ~= MAGIC_GROUP_BEHAVIOR_PREFIX then
		return BehaviorCapturing(state, index)
	end

	local peekIndex, peekChar = state:readElement(nextIndex)
	if not peekIndex or state:isElement(peekChar) then 
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end

	-- Branch reset groups: (?|...)
	if peekChar == MAGIC_GROUP_BRANCH_RESET_BEHAVIOR then
		return BehaviorBranchReset(state, peekIndex)
	
	-- Non-capturing groups: (?:...)
	elseif peekChar == MAGIC_GROUP_NON_CAPTURING_BEHAVIOR then
		return BehaviorCapturing(state, index, peekIndex, peekChar)
		
	-- Atomic groups: (?>...)
	elseif peekChar == MAGIC_GROUP_ATOMIC_BEHAVIOR then
		return BehaviorAtomic(state, peekIndex)
		
	-- Positive / Negative Lookahead: (?=...), (?!...)
	elseif peekChar == MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or peekChar == MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR then
		return BehaviorLookaround(state, peekIndex, peekChar)
		
	-- Positive / Negative Lookbehind: (?<=...), (?<!...)
	elseif peekChar == MAGIC_GROUP_LOOKBEHIND_BEHAVIOR then
		local lookbehindIndex, lookbehindChar = state:readElement(peekIndex)
		if lookbehindIndex and not state:isElement(lookbehindChar) and (
			lookbehindChar == MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or lookbehindChar == MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR
		) then
			return BehaviorLookaround(state, peekIndex, peekChar, lookbehindIndex, lookbehindChar)
		else
			-- Fallback to Named Capture which also uses `<` i.e. `(?<name>...)`
			return BehaviorCapturing(state, index, peekIndex, peekChar)
		end
		
	-- Comments: (?#...)
	elseif peekChar == MAGIC_GROUP_COMMENT_BEHAVIOR then
		return BehaviorComment(state, peekIndex)
		
	-- Recursion: (?R), (?0), (?123), (?&name)
	elseif peekChar == MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR or peekChar == MAGIC_GROUP_RECURSION_ROOT_ALIAS
		or peekChar == MAGIC_GROUP_RECURSION_NAMED_BEHAVIOR or isPositiveIntegerChar(peekChar)
	then
		return BehaviorRecursion(state, peekIndex, peekChar, Group.isClosingToken)
		
	-- Inline and Scoped Flags: (?i), (?i:...)
	elseif FLAGS_INLINE_TOKENS[peekChar] then
		return BehaviorFlags(state, peekIndex, peekChar)
		
	-- Unrecognized behavior token after `(?`
	else
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end
end

--[[ Public API ]]--

--- Returns whether a character is a group opening token.
---@param currentCharacter string The character to test.
---@return boolean isOpeningToken Whether the character opens a group.
Group.isOpeningToken = function(currentCharacter)
	return currentCharacter == MAGIC_GROUP_OPEN
end

--- Returns whether a character is a group closing token.
---@param currentCharacter string The character to test.
---@return boolean isClosingToken Whether the character closes a group.
Group.isClosingToken = function(currentCharacter)
	return currentCharacter == MAGIC_GROUP_CLOSE
end

--- Returns whether an AST element is a group node.
---@param currentElement table The AST element to test.
---@return boolean isGroup Whether the element is a group node.
Group.isElement = function(currentElement)
	return currentElement.type == ELEMENT_GROUP
end

--- Parses a group element.
---@param state ParserState The current parser state.
---@param tree ASTTree The AST tree being built.
---@return string|nil errorMessage The parser error message on failure.
Group.parse = function(state, tree)
	-- skip magic opening
	state.index = state.index + 1

	local newIndex, group, errorMessage = parseGroupBehavior(state)
	if not newIndex then
		return errorMessage
	end
	state.index = newIndex
	
	-- Apply inline toggle flags immediately to state
	if group.inlineFlags then
		state:applyInlineFlags(group.inlineFlags)
		return nil
	end
	
	local previousFlags
	if group.scopedFlags then
		previousFlags = state:pushScopedFlags(group.scopedFlags)
	end

	local stateMetadata, statePatternChars = state.metadata, state.patternChars
	local groupIsRecursion = group.isRecursion

	-- Parse the group's contents.
	if groupIsRecursion then
		group.tree = {
			_index = 0
		}
	elseif not statePatternChars[state.index] or statePatternChars[state.index] ~= MAGIC_GROUP_CLOSE then
		local groupName = group.name

		if not group.isNonCapturing then
			if groupName or not state.flags.n then
				local groupIndex = stateMetadata.groupIndex + 1
				stateMetadata.groupIndex = groupIndex
				group.index = groupIndex
				if groupName then
					stateMetadata.groupNames[groupName] = groupIndex
				end
			else
				group.isNonCapturing = true
			end
		end

		local childState = state:fork()
		childState.isGroup = true
		childState.isAlternate = false
		childState.isBranchReset = group.isBranchReset

		local groupTree, groupErrorMessage = state:parseSubTree(childState)
		if not groupTree then
			return groupErrorMessage
		end
		group.tree = groupTree
		
		-- Register groups for recursion target lookup
		local groupIndex, groupTrees = group.index, stateMetadata.groupTrees
		if groupIndex and groupTrees then
			groupTrees[groupIndex] = groupTree
		end
	elseif not group.hasSpecialBehavior then
		state.index = PositionCapture.parse(state.index, tree, stateMetadata)
		return nil
	else
		group.tree = { _index = 0 }
	end
	
	if previousFlags then
		state:popScopedFlags(previousFlags)
	end

	if group.isLookbehind then
		local fixedLength
		fixedLength, errorMessage = getLookbehindFixedLength(group.tree)
		if not fixedLength then
			return errorMessage or ERROR_VARIABLE_LENGTH_LOOKBEHIND
		end
		group.fixedLength = fixedLength
	end

	if not group._skipFromTree then
		local treeIndex = tree._index + 1
		tree._index = treeIndex
		tree[treeIndex] = group
	end

	-- For recursion, parseGroupBehavior already consumed the `)`, so state.index is pointing at the NEXT character.
	if groupIsRecursion then
		return nil
	end

	state.index = state.index + 1
	return nil
end

--- Parses a group closing token.
---@param state ParserState The current parser state.
---@return boolean shouldClose Whether the current subtree should be closed.
---@return string|nil errorMessage The parser error message on failure.
Group.parseClosing = function(state)
	if state.isGroup then
		return true, nil
	end
	return false, ERROR_NO_GROUP_TO_CLOSE
end

--- Matches a group element against the target string.
---@param currentElement table The group AST node to match.
---@param state MatchState The current matcher state.
---@return boolean hasMatched Whether the group matched.
---@return number|nil startIndex The match start index.
---@return number|nil endIndex The match end index.
---@return table metadata The updated matcher metadata.
---@return boolean allowCapture Whether captures should be recorded.
Group.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local groupTree = currentElement.tree
	local tree = state.tree
	local treeIndex = state.treeIndex
	local matcher = state.matcher

	local stateMetadata = state.metadata
	local isRecursion = currentElement.isRecursion

	-- Resolve the recursion target before executing the group
	if isRecursion then
		local elementTargetIndex = currentElement.targetIndex
		if currentElement.isRecursionRoot then
			groupTree = stateMetadata.rootTree
		elseif elementTargetIndex then
			groupTree = stateMetadata.parsedMetadata.groupTrees[elementTargetIndex]
		end
		
		if not groupTree or state:enterRecursion() then
			return false, nil, nil, stateMetadata, false
		end
	end

	local isLookbehind = currentElement.isLookbehind
	local isAssertion = currentElement.isLookahead or isLookbehind

	-- Preserve the caller's execution context while entering this group
	local outerTreeReference = stateMetadata.outerTreeReference
	local oldOuterTreeRef = outerTreeReference[groupTree]
	local isAtomic = currentElement.isAtomic
	
	if isRecursion then
		outerTreeReference[groupTree] = nil
	elseif not isAssertion and not isAtomic and tree then
		outerTreeReference[groupTree] = {
			tree = tree,
			treeLength = tree._index,
			treeIndex = treeIndex,
			initialStringIndex = state.initialStringIndex
		}
	end

	local oldGroupIndex = groupTree._groupIndex

	-- Temporarily associate this execution with the current capture group
	local groupIndex = currentElement.index or currentElement.name
	groupTree._groupIndex = groupIndex

	local isNegative = currentElement.isNegative

	-- Determine the starting position for group execution
	local execStringIndex = stringIndex
	if isLookbehind then
		execStringIndex = stringIndex - currentElement.fixedLength
		-- Lookbehind cannot match before the beginning of the target string
		if execStringIndex < 0 then
			if isRecursion then
				state:leaveRecursion()
			end

			outerTreeReference[groupTree] = oldOuterTreeRef
			groupTree._groupIndex = oldGroupIndex

			if isNegative then
				return true, nil, stringIndex, stateMetadata, false
			end
			return false, nil, nil, stateMetadata, false
		end
	end

	-- Execute the group's subtree in an isolated matcher state
	local tempState = state:branch(execStringIndex, execStringIndex)
	tempState.tree = groupTree
	tempState.treeIndex = 0

	local hasMatched, iniStr, endStr = matcher(tempState)

	-- Restore the caller's execution context
	outerTreeReference[groupTree] = oldOuterTreeRef
	groupTree._groupIndex = oldGroupIndex

	-- Assertions do not consume characters
	if isAssertion then
		local originalHasMatched = hasMatched
		if isLookbehind and originalHasMatched and (endStr ~= stringIndex) then
			originalHasMatched = false
		end
		hasMatched = originalHasMatched ~= isNegative

		if not hasMatched then
			return false, nil, nil, stateMetadata, false
		end

		return true, nil, stringIndex, stateMetadata, false
	end

	-- Atomic groups and recursion never expose captures for backtracking
	if isAtomic or isRecursion then
		if isRecursion then
			-- Restore recursion depth before returning
			state:leaveRecursion()
		end

		if not hasMatched then
			return false, nil, nil, stateMetadata, false
		end
		return true, nil, endStr, stateMetadata, false
	end

	-- Non-capturing groups only need their match result
	if not groupIndex then
		hasMatched = hasMatched ~= isNegative
		if not hasMatched then
			return
		end
	end

	return hasMatched, iniStr, endStr, stateMetadata, true
end

return Group