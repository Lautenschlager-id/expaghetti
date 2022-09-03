----------------------------------------------------------------------------------------------------
local strformat = string.format
local tblconcat = table.concat
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
local ENUM_ELEMENT_TYPE_GROUP = elementsEnum.group
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
----------------------------------------------------------------------------------------------------
local Group = { }

local getGroupBehavior = function(index, charactersList, charactersValueList, groupElement,
	parserMetaData)
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
	else
		errorMessage = errorsEnum.invalidGroupBehavior
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

Group.parse = function(parser, index, tree, expression, expressionLength, charactersIndex,
	charactersList, charactersValueList, boolEscapedList, parserMetaData)

	-- skip magic opening
	index = index + 1

	--[[
		{
			type = "group",
			disableCapture = false,
			isAtomic = false,
			isLookahead = false,
			isLookbehind = false,
			isNegative = false,
			name = "",
			index = 1,
			tree = {
				...
			}
		}
	]]
	local value = {
		type = ENUM_ELEMENT_TYPE_GROUP,
	}

	local errorMessage
	index, errorMessage = getGroupBehavior(index, charactersList, charactersValueList,
		value, parserMetaData)
	if not index then
		return false, errorMessage
	end

	-- A group with any value
	if expression[index] ~= ENUM_CLOSE_GROUP then
		if not (
			value.disableCapture
			or value.name
		) then
			parserMetaData.groupIndex = parserMetaData.groupIndex + 1
			value.index = parserMetaData.groupIndex
		end

		local groupTree
		groupTree, index = parser(nil, nil,
			true, false, index, expression,
			expressionLength, charactersIndex, charactersList, charactersValueList, boolEscapedList,
			parserMetaData)

		if not groupTree then
			-- index = error message
			return false, index
		end

		value.tree = groupTree
	elseif not value.hasBehavior then
		return PositionCapture.parse(index, tree, parserMetaData)
	end

	tree._index = tree._index + 1
	tree[tree._index] = value

	return index + 1
end

Group.match = function(
		currentElement, treeMatcher,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex,
		matcherMetaData
	)

	local groupTree = currentElement.tree

	if not matcherMetaData.outerTreeReference[groupTree] then
		matcherMetaData.outerTreeReference[groupTree] = {
			tree = tree,
			treeLength = treeLength,
			treeIndex = treeIndex,
			initialStringIndex = initialStringIndex
		}
	end

	local hasMatched, iniStr, endStr = treeMatcher(
		flags, groupTree, groupTree._index, 0,
		splitStr, strLength,
		stringIndex, stringIndex,
		matcherMetaData
	)

	local groupIndex = currentElement.index or currentElement.name
	if groupIndex then
		local groupCapturesInitStringPositions, groupCapturesEndStringPositions =
			matcherMetaData.groupCapturesInitStringPositions,
			matcherMetaData.groupCapturesEndStringPositions

		if hasMatched and iniStr <= endStr then
			groupCapturesInitStringPositions[groupIndex] = iniStr
			groupCapturesEndStringPositions[groupIndex] = endStr
		elseif not groupCapturesInitStringPositions[groupIndex] then
			groupCapturesInitStringPositions[groupIndex] = 2
			groupCapturesEndStringPositions[groupIndex] = 1
		end
	else
		hasMatched = hasMatched ~= currentElement.isNegative
		if not hasMatched then
			return
		end

		if currentElement.isLookahead then
			iniStr = iniStr and (iniStr - 1) or stringIndex
			endStr = iniStr
		end
	end

	return hasMatched, iniStr, endStr, matcherMetaData, true
end

return Group