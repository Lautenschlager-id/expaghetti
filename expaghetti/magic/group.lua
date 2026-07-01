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
	local charactersList = state.charactersList
	local charactersValueList = state.charactersValueList
	local parserMetaData = state.metaData
	local currentCharacter = charactersList[index]

	if currentCharacter ~= ENUM_GROUP_BEHAVIOR_CHARACTER then
		return index
	end

	index = index + 1
	currentCharacter = charactersList[index]

	local errorMessage
	if currentCharacter == ENUM_GROUP_NON_CAPTURING_BEHAVIOR then
		groupElement.disableCapture = true
	elseif currentCharacter == ENUM_GROUP_ATOMIC_BEHAVIOR then
		groupElement.isAtomic = true
	elseif currentCharacter == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR then
		groupElement.isLookahead = true
		groupElement.disableCapture = true
	elseif currentCharacter == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
		groupElement.isLookahead = true
		groupElement.isNegative = true
		groupElement.disableCapture = true
	elseif currentCharacter == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		index = index + 1
		currentCharacter = charactersList[index]

		if currentCharacter == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR then
			groupElement.isLookbehind = true
			groupElement.disableCapture = true
		elseif currentCharacter == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
			groupElement.isLookbehind = true
			groupElement.isNegative = true
			groupElement.disableCapture = true
		else
			index = index - 1
			currentCharacter = charactersList[index]

			errorMessage = errorsEnum.invalidGroupBehavior
		end
	elseif currentCharacter == ENUM_GROUP_COMMENT_BEHAVIOR then
		groupElement.disableCapture = true
		groupElement._skipFromTree = true
	else
		-- Check for inline flags
		local charVal = charactersValueList[index]
		if charVal == 'i' or charVal == 'm' or charVal == 's' or charVal == 'n' or charVal == '-' then
			local enableFlags = {}
			local disableFlags = {}
			local currentTarget = enableFlags
			while charVal == 'i' or charVal == 'm' or charVal == 's' or charVal == 'n' or charVal == '-' do
				if charVal == '-' then
					currentTarget = disableFlags
				else
					currentTarget[charVal] = true
				end
				index = index + 1
				charVal = charactersValueList[index]
			end
			
			local nextChar = charactersList[index]
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
	if errorMessage and currentCharacter == ENUM_GROUP_NAME_OPEN then
		local currentCharacterValue
		local name, nameIndex = { }, 0
		local firstCharacter = index + 1
		repeat
			index = index + 1
			currentCharacter = charactersList[index]
			currentCharacterValue = charactersValueList[index]

			if not currentCharacterValue then
				errorMessage = errorsEnum.invalidGroupName
				break
			-- The first character must be letter
			elseif (currentCharacterValue >= 'A' and currentCharacterValue <= 'z')
				or currentCharacterValue == '$'
				or (index > firstCharacter
					and (currentCharacterValue >= '0' and currentCharacterValue <= '9')) then

				nameIndex = nameIndex + 1
				name[nameIndex] = currentCharacter
			elseif nameIndex > 0 and currentCharacter == ENUM_GROUP_NAME_CLOSE then
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
	return index + 1
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
	if state.charactersList[state.index] ~= ENUM_CLOSE_GROUP then
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

		local groupTree, groupErrorMessage = state:parseSubTree(true, false)

		if not groupTree then
			-- index = error message
			return false, groupErrorMessage
		end

		value.tree = groupTree
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

	return state.index + 1
end

Group.match = function(
		currentElement, treeMatcher,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex,
		matcherMetaData
	)

	local groupTree = currentElement.tree

	local isAssertion = currentElement.isLookahead or currentElement.isLookbehind

	if not isAssertion and not matcherMetaData.outerTreeReference[groupTree] and tree then
		matcherMetaData.outerTreeReference[groupTree] = {
			tree = tree,
			treeLength = treeLength,
			treeIndex = treeIndex,
			initialStringIndex = initialStringIndex
		}
	end

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
			if currentElement.isNegative then
				return true, nil, stringIndex, matcherMetaData, false
			else
				return false, nil, nil, matcherMetaData, false
			end
		end
	end

	local hasMatched, iniStr, endStr = treeMatcher(
		flags, groupTree, groupTree._index, 0,
		splitStr, strLength,
		execStringIndex, execStringIndex,
		matcherMetaData
	)

	if isAssertion then
		local originalHasMatched = hasMatched
		if currentElement.isLookbehind then
			if originalHasMatched and (endStr ~= stringIndex) then
				originalHasMatched = false
			end
		end
		hasMatched = originalHasMatched ~= currentElement.isNegative

		if not hasMatched then
			return false, nil, nil, matcherMetaData, false
		end

		return true, nil, stringIndex, matcherMetaData, false
	end

	if not groupIndex then
		hasMatched = hasMatched ~= currentElement.isNegative
		if not hasMatched then
			return
		end
	end

	return hasMatched, iniStr, endStr, matcherMetaData, true
end

return Group