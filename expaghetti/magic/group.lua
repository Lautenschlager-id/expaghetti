----------------------------------------------------------------------------------------------------
local strformat = string.format
local tblconcat = table.concat
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local PositionCapture = require("./magic/position_capture")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local elementsEnum = require("./enums/elements")
local errorsEnum = require("./enums/errors")
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

local getGroupBehavior = function(state, groupElement)
	local index = state.index
	local parserMetaData = state.metaData
	
	local nextIndex, currentChar = state:readElement(index)
	if not nextIndex or type(currentChar) ~= "string" then return index end

	if currentChar ~= ENUM_GROUP_BEHAVIOR_CHARACTER then
		return index
	end

	index = nextIndex
	nextIndex, currentChar = state:readElement(index)
	if not nextIndex then return index end

	local errorMessage
	if type(currentChar) ~= "string" then
		errorMessage = errorsEnum.invalidGroupBehavior
	elseif currentChar == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
		groupElement.disableCapture = true
	elseif currentChar == ENUM_GROUP_ATOMIC_BEHAVIOR then
		groupElement.isAtomic = true
		groupElement.disableCapture = true
	elseif currentChar == ENUM_GROUP_BRANCH_RESET_BEHAVIOR then
		groupElement.isBranchReset = true
		groupElement.disableCapture = true
	elseif currentChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR then
		groupElement.isLookahead = true
		groupElement.disableCapture = true
	elseif currentChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
		groupElement.isLookahead = true
		groupElement.isNegative = true
		groupElement.disableCapture = true
	elseif currentChar == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		local lookbehindIndex, lookbehindChar = state:readElement(nextIndex)
		if not lookbehindIndex or type(lookbehindChar) ~= "string" then
			errorMessage = errorsEnum.invalidGroupBehavior
		else
			if lookbehindChar == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR then
				groupElement.isLookbehind = true
				groupElement.disableCapture = true
				nextIndex = lookbehindIndex
				currentChar = lookbehindChar
			elseif lookbehindChar == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
				groupElement.isLookbehind = true
				groupElement.isNegative = true
				groupElement.disableCapture = true
				nextIndex = lookbehindIndex
				currentChar = lookbehindChar
			else
				errorMessage = errorsEnum.invalidGroupBehavior
			end
		end
	elseif currentChar == ENUM_GROUP_COMMENT_BEHAVIOR then
		groupElement.disableCapture = true
		groupElement._skipFromTree = true
	else
		local charVal = currentChar
		if charVal == 'R' or charVal == '0' then
			index = nextIndex
			nextIndex, currentChar = state:readElement(index)
			if nextIndex and type(currentChar) == "string" and currentChar == ENUM_CLOSE_GROUP then
				groupElement.isRecursion = true
				groupElement.isRecursionRoot = true
			else
				errorMessage = errorsEnum.invalidGroupBehavior
			end
		elseif charVal >= '1' and charVal <= '9' then
			local numStr = ""
			while true do
				numStr = numStr .. charVal
				index = nextIndex
				nextIndex, currentChar = state:readElement(index)
				if not nextIndex or type(currentChar) ~= "string" or currentChar < '0' or currentChar > '9' then
					break
				end
				charVal = currentChar
			end
			if nextIndex and type(currentChar) == "string" and currentChar == ENUM_CLOSE_GROUP then
				groupElement.isRecursion = true
				groupElement.targetIndex = tonumber(numStr)
			else
				errorMessage = errorsEnum.invalidGroupBehavior
			end
		elseif charVal == '&' then
			local nameStr = ""
			index = nextIndex
			nextIndex, currentChar = state:readElement(index)
			while nextIndex and type(currentChar) == "string" and currentChar ~= ENUM_CLOSE_GROUP do
				nameStr = nameStr .. currentChar
				index = nextIndex
				nextIndex, currentChar = state:readElement(index)
			end
			if nextIndex and type(currentChar) == "string" and currentChar == ENUM_CLOSE_GROUP and #nameStr > 0 then
				groupElement.isRecursion = true
				groupElement.targetName = nameStr
			else
				errorMessage = errorsEnum.invalidGroupName
			end
		-- Check for inline flags
		elseif charVal == 'i' or charVal == 'm' or charVal == 's' or charVal == 'n' or charVal == '-' then
			local enableFlags = {}
			local disableFlags = {}
			local currentTarget = enableFlags
			while charVal == 'i' or charVal == 'm' or charVal == 's' or charVal == 'n' or charVal == '-' do
				if charVal == '-' then
					currentTarget = disableFlags
				else
					currentTarget[charVal] = true
				end
				index = nextIndex
				nextIndex, currentChar = state:readElement(index)
				if not nextIndex or type(currentChar) ~= "string" then break end
				charVal = currentChar
			end
			
			local nextChar = currentChar
			if nextChar == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
				-- Scoped flags (?i:...)
				groupElement.disableCapture = true
				groupElement.scopedFlags = { enable = enableFlags, disable = disableFlags }
			elseif nextChar == ENUM_CLOSE_GROUP then
				-- Inline toggle (?i)
				groupElement._skipFromTree = true
				groupElement.inlineFlags = { enable = enableFlags, disable = disableFlags }
			else
				errorMessage = errorsEnum.invalidGroupBehavior
			end
		else
			errorMessage = errorsEnum.invalidGroupBehavior
		end
	end

	-- Since ENUM_GROUP_LOOKBEHIND_BEHAVIOR == ENUM_GROUP_NAME_OPEN, it needs to be in another chunk
	if errorMessage and currentChar == ENUM_GROUP_NAME_OPEN then
		local name, nameIndex = { }, 0
		local firstCharacter = nextIndex
		
		repeat
			index = nextIndex
			nextIndex, currentChar = state:readElement(index)
			if not nextIndex or type(currentChar) ~= "string" then
				errorMessage = errorsEnum.invalidGroupName
				break
			end
			local currentCharacterValue = currentChar

			-- The first character must be letter
			if (currentCharacterValue >= 'A' and currentCharacterValue <= 'z')
				or currentCharacterValue == '$'
				or (index > firstCharacter
					and (currentCharacterValue >= '0' and currentCharacterValue <= '9')) then

				nameIndex = nameIndex + 1
				name[nameIndex] = currentChar
			elseif nameIndex > 0 and currentChar == ENUM_GROUP_NAME_CLOSE then
				name = tblconcat(name)
				if parserMetaData.groupNames[name] then
					errorMessage = strformat(errorsEnum.duplicatedGroupName, name)
				else
					parserMetaData.groupNames[name] = true
					groupElement.name = name
					errorMessage = nil
				end
				break
			else
				errorMessage = errorsEnum.invalidGroupName
				break
			end
		until false
	end

	if errorMessage then
		return false, errorMessage
	end

	groupElement.hasBehavior = true
	return nextIndex
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

	local value = AST.Group()

	local errorMessage
	state.index, errorMessage = getGroupBehavior(state, value)
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

		state.metaData.recursionDepth = (state.metaData.recursionDepth or 0) + 1
		if state.metaData.recursionDepth > state.metaData.maxRecursionDepth then
			state.metaData.recursionDepth = state.metaData.recursionDepth - 1
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
				state.metaData.recursionDepth = state.metaData.recursionDepth - 1
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
			state.metaData.recursionDepth = state.metaData.recursionDepth - 1
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