----------------------------------------------------------------------------------------------------
local strformat = string.format
local tblconcat = table.concat
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local isPositiveIntegerChar = require("./helpers/token").isPositiveIntegerChar
----------------------------------------------------------------------------------------------------
local PositionCapture = require("./magic/position_capture")
----------------------------------------------------------------------------------------------------
local behaviorCapture = require("./magic/group/behavior_capture")
local behaviorAtomic = require("./magic/group/behavior_atomic")
local behaviorBranchReset = require("./magic/group/behavior_branch_reset")
local behaviorLookaround = require("./magic/group/behavior_lookaround")
local behaviorRecursion = require("./magic/group/behavior_recursion")
local behaviorComment = require("./magic/group/behavior_comment")
local behaviorFlags = require("./magic/group/behavior_flags")
local magicEnum = require("./enums/magic")
local elementsEnum = require("./enums/elements")
local errorsEnum = require("./enums/errors")
local inlineFlagsEnum = require("./enums/flags").inlineFlags
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_GROUP = magicEnum.OPEN_GROUP
local ENUM_CLOSE_GROUP = magicEnum.CLOSE_GROUP
local ENUM_GROUP_BEHAVIOR_CHARACTER = magicEnum.GROUP_BEHAVIOR_CHARACTER
local ENUM_GROUP_NON_CAPTURING_BEHAVIOR = magicEnum.GROUP_NON_CAPTURING_BEHAVIOR
local ENUM_GROUP_ATOMIC_BEHAVIOR = magicEnum.GROUP_ATOMIC_BEHAVIOR
local ENUM_GROUP_BRANCH_RESET_BEHAVIOR = magicEnum.GROUP_BRANCH_RESET_BEHAVIOR
local ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR = magicEnum.GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR
local ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR = magicEnum.GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR
local ENUM_GROUP_LOOKBEHIND_BEHAVIOR = magicEnum.GROUP_LOOKBEHIND_BEHAVIOR
local ENUM_GROUP_NAME_OPEN = magicEnum.GROUP_NAME_OPEN
local ENUM_GROUP_NAME_CLOSE = magicEnum.GROUP_NAME_CLOSE
local ENUM_GROUP_COMMENT_BEHAVIOR = magicEnum.GROUP_COMMENT_BEHAVIOR
local ENUM_ELEMENT_TYPE_GROUP = elementsEnum.group
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_ANY = elementsEnum.any
local ENUM_ELEMENT_TYPE_SET = elementsEnum.set
local ENUM_ELEMENT_TYPE_ALTERNATE = elementsEnum.alternate
local ENUM_ELEMENT_TYPE_QUANTIFIER = elementsEnum.quantifier
----------------------------------------------------------------------------------------------------
local Group = { }

local function getFixedLength(tree)
	if not tree then return 0 end
	local totalLen = 0
	for i = 1, (tree._index or 0) do
		local elem = tree[i]
		
		-- Elements that don't consume characters
		if elementsEnum.anchor == elem.type or elementsEnum.boundary == elem.type or elementsEnum.position_capture == elem.type then
			-- Length 0
		elseif elem.isLookahead or elem.isLookbehind then
			-- Length 0
		-- Elements that consume 1 character
		elseif elem.type == ENUM_ELEMENT_TYPE_LITERAL or elem.type == ENUM_ELEMENT_TYPE_ANY or elem.type == ENUM_ELEMENT_TYPE_SET then
			local q = elem.quantifier
			if q then
				if q.min ~= q.max or q.max == 0 then return nil end
				totalLen = totalLen + q.min
			else
				totalLen = totalLen + 1
			end
		elseif elem.type == ENUM_ELEMENT_TYPE_GROUP then
			local gLen = getFixedLength(elem.tree)
			if not gLen then return nil end
			local q = elem.quantifier
			if q then
				if q.min ~= q.max or q.max == 0 then return nil end
				totalLen = totalLen + (gLen * q.min)
			else
				totalLen = totalLen + gLen
			end
		elseif elem.type == ENUM_ELEMENT_TYPE_ALTERNATE then
			local altLen = nil
			for _, branchTree in ipairs(elem.trees) do
				local bLen = getFixedLength(branchTree)
				if not bLen then return nil end
				if altLen == nil then
					altLen = bLen
				elseif altLen ~= bLen then
					return nil
				end
			end
			local q = elem.quantifier
			if q then
				if q.min ~= q.max or q.max == 0 then return nil end
				totalLen = totalLen + ((altLen or 0) * q.min)
			else
				totalLen = totalLen + (altLen or 0)
			end
		else
			return nil -- Unknown element, cannot determine length safely
		end
	end
	return totalLen
end

local GROUP_RECURSION_ROOT_BEHAVIOR = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR
local GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS = magicEnum.GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS
local ENUM_GROUP_RECURSION_NAMED_BEHAVIOR = magicEnum.GROUP_RECURSION_NAMED_BEHAVIOR

local ENUM_GROUP_FLAG_IGNORE_CASE = magicEnum.GROUP_FLAG_IGNORE_CASE
local ENUM_GROUP_FLAG_MULTILINE = magicEnum.GROUP_FLAG_MULTILINE
local ENUM_GROUP_FLAG_DOTALL = magicEnum.GROUP_FLAG_DOTALL
local ENUM_GROUP_FLAG_NO_CAPTURE = magicEnum.GROUP_FLAG_NO_CAPTURE
local ENUM_GROUP_FLAGS_DISABLE_BEHAVIOR = magicEnum.GROUP_FLAGS_DISABLE_BEHAVIOR

local parseGroupBehavior = function(state)
	local index = state.index
	local nextIndex, currentChar = state:readElement(index)

	-- Standard capturing group (no `?` behavior prefix)
	if not nextIndex or state:isElement(currentChar) or currentChar ~= ENUM_GROUP_BEHAVIOR_CHARACTER then
		return behaviorCapture(state, index)
	end

	local peekIndex, peekChar = state:readElement(nextIndex)
	if not peekIndex or state:isElement(peekChar) then 
		return false, nil, errorsEnum.invalidGroupBehavior
	end

	-- Branch reset groups: (?|...)
	if peekChar == ENUM_GROUP_BRANCH_RESET_BEHAVIOR then
		return behaviorBranchReset(state, peekIndex)
	
	-- Non-capturing groups: (?:...)
	elseif peekChar == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
		return behaviorCapture(state, index, peekIndex, peekChar)
		
	-- Atomic groups: (?>...)
	elseif peekChar == ENUM_GROUP_ATOMIC_BEHAVIOR then
		return behaviorAtomic(state, peekIndex)
		
	-- Positive / Negative Lookahead: (?=...), (?!...)
	elseif peekChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR or peekChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
		return behaviorLookaround(state, peekIndex, peekChar)
		
	-- Positive / Negative Lookbehind: (?<=...), (?<!...)
	elseif peekChar == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		local lookbehindIndex, lookbehindChar = state:readElement(peekIndex)
		if lookbehindIndex and not state:isElement(lookbehindChar) and (lookbehindChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR or lookbehindChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR) then
			return behaviorLookaround(state, peekIndex, peekChar, lookbehindIndex, lookbehindChar)
		else
			-- Fallback to Named Capture which also uses `<` i.e. `(?<name>...)`
			return behaviorCapture(state, index, peekIndex, peekChar)
		end
		
	-- Comments: (?#...)
	elseif peekChar == ENUM_GROUP_COMMENT_BEHAVIOR then
		return behaviorComment(state, peekIndex)
		
	-- Recursion: (?R), (?0), (?123), (?&name)
	elseif peekChar == GROUP_RECURSION_ROOT_BEHAVIOR or peekChar == GROUP_RECURSION_ROOT_BEHAVIOR_ALIAS or peekChar == ENUM_GROUP_RECURSION_NAMED_BEHAVIOR or isPositiveIntegerChar(peekChar) then
		return behaviorRecursion(state, peekIndex, peekChar)
		
	-- Inline and Scoped Flags: (?i), (?i:...)
	elseif inlineFlagsEnum[peekChar] then
		return behaviorFlags(state)
		
	-- Unrecognized behavior token after `(?`
	else
		return false, nil, errorsEnum.invalidGroupBehavior
	end
end
----------------------------------------------------------------------------------------------------
Group.isOpeningToken = function(currentCharacter)
	return currentCharacter == ENUM_OPEN_GROUP
end

Group.isClosingToken = function(currentCharacter)
	return currentCharacter == ENUM_CLOSE_GROUP
end

Group.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_GROUP
end

Group.parse = function(state, tree)

	-- skip magic opening
	state.index = state.index + 1

	local value, errorMessage
	state.index, value, errorMessage = parseGroupBehavior(state)
	if not state.index then
		return false, errorMessage
	end
	
	-- Apply inline toggle flags immediately to state
	if value.inlineFlags then
		for k, v in pairs(value.inlineFlags.enable) do state.flags[k] = true end
		for k, v in pairs(value.inlineFlags.disable) do state.flags[k] = nil end
		return state.index
	end
	
	local restoreFlags = nil
	if value.scopedFlags then
		restoreFlags = {}
		for k, v in pairs(state.flags) do restoreFlags[k] = v end
		for k, v in pairs(value.scopedFlags.enable) do state.flags[k] = true end
		for k, v in pairs(value.scopedFlags.disable) do state.flags[k] = nil end
	end

	-- A group with any value
	if value.isRecursion then
		value.tree = { _index = 0 }
	elseif not state.patternChars[state.index] or state.patternChars[state.index] ~= ENUM_CLOSE_GROUP then
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

		local groupTree, groupErrorMessage = state:parseSubTree(true, false, nil, value.isBranchReset)

		if not groupTree then
			-- index = error message
			return false, groupErrorMessage
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
		return PositionCapture.parse(state.index, tree, state.metaData)
	else
		value.tree = { _index = 0 }
	end
	
	if restoreFlags then
		-- Clear current flags table and restore previous state
		for k in pairs(state.flags) do state.flags[k] = nil end
		for k, v in pairs(restoreFlags) do state.flags[k] = v end
	end

	if value.isLookbehind then
		local len = getFixedLength(value.tree)
		if not len then
			return false, errorsEnum.variableLengthLookbehind
		end
		value.fixedLength = len
	end

	if not value._skipFromTree then
		tree._index = tree._index + 1
		tree[tree._index] = value
	end

	-- For recursion, getGroupBehavior already consumed the `)`, so state.index is pointing at the NEXT character.
	-- We return state.index instead of state.index + 1
	if value.isRecursion then
		return state.index
	end

	return state.index + 1
end

Group.match = function(currentElement, treeMatcher, state, tree, treeIndex)
	local stringIndex = state.stringIndex - 1
	local groupTree = currentElement.tree

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
	if groupIndex then
		groupTree._groupIndex = groupIndex
	else
		groupTree._groupIndex = nil
	end

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
	local hasMatched, iniStr, endStr = treeMatcher(
		tempState, groupTree, 0
	)

	if isAssertion then
		local originalHasMatched = hasMatched
		if currentElement.isLookbehind then
			if originalHasMatched and (endStr ~= stringIndex) then
				originalHasMatched = false
			end
		end
		hasMatched = originalHasMatched ~= currentElement.isNegative

		state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
		groupTree._groupIndex = oldGroupIndex

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
			state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
			groupTree._groupIndex = oldGroupIndex
			return false, nil, nil, state.metaData, false
		end
		state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
		groupTree._groupIndex = oldGroupIndex
		return true, nil, endStr, state.metaData, false
	end

	if not groupIndex then
		hasMatched = hasMatched ~= currentElement.isNegative
		if not hasMatched then
			state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
			groupTree._groupIndex = oldGroupIndex
			return
		end
	end

	state.metaData.outerTreeReference[groupTree] = oldOuterTreeRef
	groupTree._groupIndex = oldGroupIndex
	return hasMatched, iniStr, endStr, state.metaData, true
end

return Group