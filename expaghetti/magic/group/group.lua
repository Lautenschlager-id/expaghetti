--[[
    Group module. Parses and matches groups.
]]

--[[ Globals ]]--
local tostring = tostring
local string = string

--[[ Dependencies ]]--
local isPositiveIntegerChar = require("helpers.parser").isPositiveIntegerChar

local PositionCapture = require("magic.positionCapture")
local behaviorCapture = require("magic.group.behaviorCapturing")
local behaviorAtomic = require("magic.group.behaviorAtomic")
local behaviorBranchReset = require("magic.group.behaviorBranchReset")
local behaviorLookaround = require("magic.group.behaviorLookaround")
local behaviorRecursion = require("magic.group.behaviorRecursion")
local behaviorComment = require("magic.group.behaviorComment")
local behaviorFlags = require("magic.group.behaviorFlags")

local magicEnum = require("enums.magic")
local elementsEnum = require("enums.elements")
local elementLengths = require("enums.elementLengths")
local errorsEnum = require("enums.errors")
local inlineFlagsEnum = require("enums.flags").INLINE_TOKENS

--[[ Enum Aliases ]]--
local MAGIC_GROUP_OPEN = magicEnum.GROUP_OPEN
local MAGIC_GROUP_CLOSE = magicEnum.GROUP_CLOSE
local MAGIC_GROUP_BEHAVIOR_PREFIX = magicEnum.GROUP_BEHAVIOR_PREFIX
local MAGIC_GROUP_NON_CAPTURING_BEHAVIOR = magicEnum.GROUP_NON_CAPTURING_BEHAVIOR
local MAGIC_GROUP_ATOMIC_BEHAVIOR = magicEnum.GROUP_ATOMIC_BEHAVIOR
local MAGIC_GROUP_BRANCH_RESET_BEHAVIOR = magicEnum.GROUP_BRANCH_RESET_BEHAVIOR
local MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR = magicEnum.GROUP_LOOKAROUND_POSITIVE_BEHAVIOR
local MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR = magicEnum.GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR
local MAGIC_GROUP_LOOKBEHIND_BEHAVIOR = magicEnum.GROUP_LOOKBEHIND_BEHAVIOR
local MAGIC_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local MAGIC_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
local MAGIC_GROUP_COMMENT_BEHAVIOR = magicEnum.GROUP_COMMENT_BEHAVIOR
local MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR
local MAGIC_GROUP_RECURSION_ROOT_ALIAS = magicEnum.GROUP_RECURSION_ROOT_ALIAS
local MAGIC_GROUP_RECURSION_NAMED_BEHAVIOR = magicEnum.GROUP_RECURSION_NAMED_BEHAVIOR
local MAGIC_GROUP_FLAG_IGNORE_CASE = magicEnum.GROUP_FLAG_IGNORE_CASE
local MAGIC_GROUP_FLAG_MULTILINE = magicEnum.GROUP_FLAG_MULTILINE
local MAGIC_GROUP_FLAG_DOT_ALL = magicEnum.GROUP_FLAG_DOT_ALL
local MAGIC_GROUP_FLAG_NO_CAPTURE = magicEnum.GROUP_FLAG_NO_CAPTURE
local MAGIC_GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR = magicEnum.GROUP_SCOPED_FLAGS_DISABLE_BEHAVIOR

local ELEMENT_GROUP = elementsEnum.GROUP
local ELEMENT_LITERAL = elementsEnum.LITERAL
local ELEMENT_ANY = elementsEnum.ANY
local ELEMENT_SET = elementsEnum.SET
local ELEMENT_ALTERNATE = elementsEnum.ALTERNATE
local ELEMENT_QUANTIFIER = elementsEnum.QUANTIFIER

local ZERO_LENGTH_ELEMENTS = elementLengths.ZERO_LENGTH
local SINGLE_LENGTH_ELEMENTS = elementLengths.SINGLE_LENGTH

local ERROR_UNKNOWN_ELEMENT_LENGTH = errorsEnum.unknownElementLength
local ERROR_INVALID_GROUP_BEHAVIOR = errorsEnum.invalidGroupBehavior
local ERROR_VARIABLE_LENGTH_LOOKBEHIND = errorsEnum.variableLengthLookbehind
local ERROR_NO_GROUP_TO_CLOSE = errorsEnum.unexpectedGroupClose

--[[ Module ]]--
local Group = {}

--[[ Private Functions ]]--
local getLookbehindFixedLength
getLookbehindFixedLength = function(tree)
	local totalLen = 0
	local elem, quantifier, groupLength, errorMessage, alternateLength, trees, expectedAlternateLength
	for i = 1, tree._index do
		elem = tree[i]
		quantifier = elem.quantifier
		if quantifier and (quantifier.min ~= quantifier.max or quantifier.max == 0) then
			return nil
		end
		
		-- Elements that don't consume characters
		if ZERO_LENGTH_ELEMENTS[elem.type] or (elem.isLookahead or elem.isLookbehind) then
		-- Elements that consume 1 character
		elseif SINGLE_LENGTH_ELEMENTS[elem.type] then
			totalLen = totalLen + (quantifier and quantifier.min or 1)
		elseif elem.type == ELEMENT_GROUP then
			groupLength, errorMessage = getLookbehindFixedLength(elem.tree)
			if not groupLength then
				return nil, errorMessage
			end
			totalLen = totalLen + (groupLength * (quantifier and quantifier.min or 1))
		elseif elem.type == ELEMENT_ALTERNATE then
			trees = elem.trees
			expectedAlternateLength = nil

			for branch = 1, trees._index do
				alternateLength, errorMessage = getLookbehindFixedLength(trees[branch])
				if not alternateLength then
					return nil, errorMessage
				end

				-- Alternates must all have the same fixed length
				expectedAlternateLength = expectedAlternateLength or alternateLength
				if expectedAlternateLength ~= alternateLength then
					return nil
				end
			end

			totalLen = totalLen + (alternateLength * (quantifier and quantifier.min or 1))
		else
			-- Unknown element, cannot determine length safely
			return nil, string.format(ERROR_UNKNOWN_ELEMENT_LENGTH, tostring(elem.type or elem))
		end
    end
	return totalLen
end

local parseGroupBehavior = function(state)
	local index = state.index
	local nextIndex, currentChar = state:readElement(index)

	-- Standard capturing group (no `?` behavior prefix)
	if not nextIndex or state:isElement(currentChar) or currentChar ~= MAGIC_GROUP_BEHAVIOR_PREFIX then
		return behaviorCapture(state, index)
	end

	local peekIndex, peekChar = state:readElement(nextIndex)
	if not peekIndex or state:isElement(peekChar) then 
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end

	-- Branch reset groups: (?|...)
	if peekChar == MAGIC_GROUP_BRANCH_RESET_BEHAVIOR then
		return behaviorBranchReset(state, peekIndex)
	
	-- Non-capturing groups: (?:...)
	elseif peekChar == MAGIC_GROUP_NON_CAPTURING_BEHAVIOR then
		return behaviorCapture(state, index, peekIndex, peekChar)
		
	-- Atomic groups: (?>...)
	elseif peekChar == MAGIC_GROUP_ATOMIC_BEHAVIOR then
		return behaviorAtomic(state, peekIndex)
		
	-- Positive / Negative Lookahead: (?=...), (?!...)
	elseif peekChar == MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or peekChar == MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR then
		return behaviorLookaround(state, peekIndex, peekChar)
		
	-- Positive / Negative Lookbehind: (?<=...), (?<!...)
	elseif peekChar == MAGIC_GROUP_LOOKBEHIND_BEHAVIOR then
		local lookbehindIndex, lookbehindChar = state:readElement(peekIndex)
		if lookbehindIndex and not state:isElement(lookbehindChar) and (lookbehindChar == MAGIC_GROUP_LOOKAROUND_POSITIVE_BEHAVIOR or lookbehindChar == MAGIC_GROUP_LOOKAROUND_NEGATIVE_BEHAVIOR) then
			return behaviorLookaround(state, peekIndex, peekChar, lookbehindIndex, lookbehindChar)
		else
			-- Fallback to Named Capture which also uses `<` i.e. `(?<name>...)`
			return behaviorCapture(state, index, peekIndex, peekChar)
		end
		
	-- Comments: (?#...)
	elseif peekChar == MAGIC_GROUP_COMMENT_BEHAVIOR then
		return behaviorComment(state, peekIndex)
		
	-- Recursion: (?R), (?0), (?123), (?&name)
	elseif peekChar == MAGIC_GROUP_RECURSION_ROOT_BEHAVIOR or peekChar == MAGIC_GROUP_RECURSION_ROOT_ALIAS or peekChar == MAGIC_GROUP_RECURSION_NAMED_BEHAVIOR or isPositiveIntegerChar(peekChar) then
		return behaviorRecursion(state, peekIndex, peekChar, Group.isClosingToken)
		
	-- Inline and Scoped Flags: (?i), (?i:...)
	elseif inlineFlagsEnum[peekChar] then
		return behaviorFlags(state, peekIndex, peekChar)
		
	-- Unrecognized behavior token after `(?`
	else
		return false, nil, ERROR_INVALID_GROUP_BEHAVIOR
	end
end

--[[ Public API ]]--
Group.isOpeningToken = function(currentCharacter)
	return currentCharacter == MAGIC_GROUP_OPEN
end

Group.isClosingToken = function(currentCharacter)
	return currentCharacter == MAGIC_GROUP_CLOSE
end

Group.isElement = function(currentElement)
	return currentElement.type == ELEMENT_GROUP
end

Group.parse = function(state, tree)
	-- skip magic opening
	state.index = state.index + 1

	local newIndex, value, errorMessage = parseGroupBehavior(state)
	if not newIndex then
		return errorMessage
	end
	state.index = newIndex
	
	-- Apply inline toggle flags immediately to state
	if value.inlineFlags then
		state:applyInlineFlags(value.inlineFlags)
		return nil
	end
	
	local previousFlags
	if value.scopedFlags then
		previousFlags = state:pushScopedFlags(value.scopedFlags)
	end

	-- A group with any value
	if value.isRecursion then
		value.tree = { _index = 0 }
	elseif not state.patternChars[state.index] or state.patternChars[state.index] ~= MAGIC_GROUP_CLOSE then
		if not (
			value.disableCapture
			or value.name
		) then
			if not state.flags.n then
				state.metaData.groupIndex = state.metaData.groupIndex + 1
				value.index = state.metaData.groupIndex
			else
				value.disableCapture = true
			end
		end

		local childState = state:fork()
		childState.isGroup = true
		childState.isAlternate = false
		childState.isBranchReset = value.isBranchReset
		local groupTree, groupErrorMessage = state:parseSubTree(childState)

		if not groupTree then
			return groupErrorMessage
		end

		value.tree = groupTree
		
		-- Register groups for recursion target lookup
		if value.index and state.metaData.groupTreesByIndex then
			state.metaData.groupTreesByIndex[value.index] = groupTree
		end
		if value.name and state.metaData.groupTreesByName then
			state.metaData.groupTreesByName[value.name] = groupTree
		end
	elseif not value.hasBehavior then
		state.index = PositionCapture.parse(state.index, tree, state.metaData)
		return nil
	else
		value.tree = { _index = 0 }
	end
	
	if previousFlags then
		state:popScopedFlags(previousFlags)
	end

	if value.isLookbehind then
		local len, errorMessage = getLookbehindFixedLength(value.tree)
		if not len then
			return errorMessage or ERROR_VARIABLE_LENGTH_LOOKBEHIND
		end
		value.fixedLength = len
	end

	if not value._skipFromTree then
		tree._index = tree._index + 1
		tree[tree._index] = value
	end

	-- For recursion, getGroupBehavior already consumed the `)`, so state.index is pointing at the NEXT character.
	if value.isRecursion then
		return nil
	end

	state.index = state.index + 1
	return nil
end

Group.parseClosing = function(state)
	if state.isGroup then
		return true, nil
	end
	return false, ERROR_NO_GROUP_TO_CLOSE
end

Group.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local groupTree = currentElement.tree
	local tree = state.tree
	local treeIndex = state.treeIndex
	local matcher = state.matcher

	if currentElement.isRecursion then
		if currentElement.isRecursionRoot then
			groupTree = state.metaData.rootTree
		elseif currentElement.targetIndex then
			groupTree = state.metaData.parsedMetaData.groupTreesByIndex[currentElement.targetIndex]
		elseif currentElement.targetName then
			groupTree = state.metaData.parsedMetaData.groupTreesByName[currentElement.targetName]
		end

		if not groupTree then
			return false, nil, nil, state.metaData, false
		end

		if state:enterRecursion() then
			return false, nil, nil, state.metaData, false
		end
	end

	local isAssertion = currentElement.isLookahead or currentElement.isLookbehind

	local oldOuterTreeRef = state.metaData.outerTreeReference[groupTree]
	
	if currentElement.isRecursion then
		state.metaData.outerTreeReference[groupTree] = nil
	elseif not isAssertion and not currentElement.isAtomic and tree then
		state.metaData.outerTreeReference[groupTree] = {
			tree = tree,
			treeLength = tree._index,
			treeIndex = treeIndex,
			initialStringIndex = state.initialStringIndex
		}
	end

	local oldGroupIndex = groupTree._groupIndex
	local groupIndex = currentElement.index or currentElement.name
	groupTree._groupIndex = groupIndex

	local execStringIndex = stringIndex
	if currentElement.isLookbehind then
		execStringIndex = stringIndex - currentElement.fixedLength
		if execStringIndex < 0 then
			if currentElement.isRecursion then
				state:leaveRecursion()
			end

			state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
			groupTree._groupIndex = oldGroupIndex

			if currentElement.isNegative then
				return true, nil, stringIndex, state.metaData, false
			else
				return false, nil, nil, state.metaData, false
			end
		end
	end

	local tempState = state:branch(execStringIndex, execStringIndex)
	tempState.tree = groupTree
	tempState.treeIndex = 0
	local hasMatched, iniStr, endStr = matcher(
		tempState
	)

	state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
	groupTree._groupIndex = oldGroupIndex

	if isAssertion then
		local originalHasMatched = hasMatched
		if currentElement.isLookbehind then
			if originalHasMatched and (endStr ~= stringIndex) then
				originalHasMatched = false
			end
		end
		hasMatched = originalHasMatched ~= currentElement.isNegative

		if not hasMatched then
			return false, nil, nil, state.metaData, false
		end

		return true, nil, stringIndex, state.metaData, false
	end

	if currentElement.isAtomic or currentElement.isRecursion then
		if currentElement.isRecursion then
			state:leaveRecursion()
		end

		if not hasMatched then
			return false, nil, nil, state.metaData, false
		end
		return true, nil, endStr, state.metaData, false
	end

	if not groupIndex then
		hasMatched = hasMatched ~= currentElement.isNegative
		if not hasMatched then
			return
		end
	end

	return hasMatched, iniStr, endStr, state.metaData, true
end

--[[ Return ]]--
return Group