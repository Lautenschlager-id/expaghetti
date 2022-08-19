----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_OPEN_GROUP = magicEnum.OPEN_GROUP
local ENUM_CLOSE_GROUP = magicEnum.CLOSE_GROUP
local ENUM_ELEMENT_TYPE_GROUP = require("./enums/elements").group
----------------------------------------------------------------------------------------------------
local Group = { }

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

	local groupTree, index = parser(nil,
		true, index, expression,
		expressionLength, charactersIndex, charactersList, charactersValueList, boolEscapedList)

	if not groupTree then
		-- index = error message
		return false, index
	end

	--[[
		{
			type = "group",
			tree = {
				...
			}
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_GROUP,
		tree = groupTree
	}

	return index + 1
end

return Group