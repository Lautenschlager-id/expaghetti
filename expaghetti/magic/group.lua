----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
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
local ENUM_ELEMENT_TYPE_GROUP = require("./enums/elements").group
----------------------------------------------------------------------------------------------------
local Group = { }

local getGroupBehavior = function(index, charactersList, groupElement)
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
	elseif currentCharacter == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
		groupElement.isLookahead = true
		groupElement.isNegative = true
	elseif currentCharacter == ENUM_GROUP_LOOKBEHIND_BEHAVIOR then
		index = index + 1
		currentCharacter = charactersList[index]

		if currentCharacter == ENUM_GROUP_POSITIVE_LOOKAHEAD_BEHAVIOR then
			groupElement.isLookbehind = true
		elseif currentCharacter == ENUM_GROUP_NEGATIVE_LOOKAHEAD_BEHAVIOR then
			groupElement.isLookbehind = true
			groupElement.isNegative = true
		else
			errorMessage = errorsEnum.invalidGroupBehavior
		end
	else
		errorMessage = errorsEnum.invalidGroupBehavior
	end

	-- Since ENUM_GROUP_LOOKBEHIND_BEHAVIOR == ENUM_GROUP_NAME_OPEN, it needs to be in another chunk
	if errorMessage and currentCharacter == ENUM_GROUP_NAME_OPEN then
		repeat
			index = index + 1
			currentCharacter = charactersList[index]


		until not
	end

	if errorMessage then
		return false, errorMessage
	end

	return index + 1
end
----------------------------------------------------------------------------------------------------
Group.isOpening = function(currentCharacter)
	return currentCharacter == ENUM_OPEN_GROUP
end

Group.isClosing = function(currentCharacter)
	return currentCharacter == ENUM_CLOSE_GROUP
end

Group.execute = function(parser, index, tree, expression, expressionLength, charactersIndex,
	charactersList, charactersValueList, boolEscapedList)

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
			tree = {
				...
			}
		}
	]]
	local value = {
		type = ENUM_ELEMENT_TYPE_GROUP
	}

	local errorMessage
	index, errorMessage = getGroupBehavior(index, charactersList, value)
	if not index then
		return false, errorMessage
	end

	local groupTree, index = parser(nil,
		true, index, expression,
		expressionLength, charactersIndex, charactersList, charactersValueList, boolEscapedList)

	if not groupTree then
		-- index = error message
		return false, index
	end

	value.tree = groupTree

	tree._index = tree._index + 1
	tree[tree._index] = value

	return index + 1
end

return Group