----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
----------------------------------------------------------------------------------------------------
local ENUM_ALTERNATE_SEPARATOR = require("./enums/magic").ALTERNATE_SEPARATOR
local ENUM_ELEMENT_TYPE_ALTERNATE = require("./enums/elements").alternate
----------------------------------------------------------------------------------------------------
local Alternate = { }

Alternate.is = function(currentCharacter)
	return currentCharacter == ENUM_ALTERNATE_SEPARATOR
end

Alternate.transform = function(tree)
	--[[
		{
			type = "alternate",
			trees = {
				...
			},
		}
	]]
	return {
		[1] = {
			type = ENUM_ELEMENT_TYPE_ALTERNATE,
			trees = tree,
		},
		_index = 1
	}
end

Alternate.execute = function(parser, index, tree, expression, expressionLength, charactersIndex,
	charactersList, charactersValueList, boolEscapedList, parserMetaData, isGroup, hasGroupClosed)

	local totalAlternates = 1
	tree[1] = tblDeepCopy(tree)

	local alternativeTree
	repeat
		alternativeTree, index, hasGroupClosed = parser(nil, nil,
			isGroup	, true, index + 1, expression,
			expressionLength, charactersIndex, charactersList, charactersValueList, boolEscapedList,
			parserMetaData, hasGroupClosed)

		if not alternativeTree then
			-- index = error message
			return false, index
		end

		totalAlternates = totalAlternates + 1
		tree[totalAlternates] = alternativeTree
	until index > charactersIndex or (isGroup and hasGroupClosed)

	for elementIndex = totalAlternates + 1, tree._index do
		tree[elementIndex] = nil
	end
	tree._index = totalAlternates

	return index, nil, hasGroupClosed
end

return Alternate