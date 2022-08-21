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
			type = ENUM_ELEMENT_TYPE_ALTERNATE,
			tree = {
				...
			},
			quantifier = false,
		}
	]]
	return {
		[1] = {
			type = ENUM_ELEMENT_TYPE_ALTERNATE,
			tree = tree,
			quantifier = false,
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
		print('\t\trepeat starting in ', index+1, charactersList[index + 1], ' with isGroup = ', isGroup, 'and hasGroupClosed = ', hasGroupClosed)
		alternativeTree, index, hasGroupClosed = parser(nil, nil,
			isGroup	, true, index + 1, expression,
			expressionLength, charactersIndex, charactersList, charactersValueList, boolEscapedList,
			parserMetaData, hasGroupClosed)

		if not alternativeTree then
			print('\t\t\tfailure ', index)
			-- index = error message
			return false, index
		end

		totalAlternates = totalAlternates + 1
		tree[totalAlternates] = alternativeTree
		print('isGroup and hasGroupClosed', isGroup and hasGroupClosed)
	until index > charactersIndex or (isGroup and hasGroupClosed)

	for elementIndex = totalAlternates + 1, tree._index do
		tree[elementIndex] = nil
	end
	tree._index = totalAlternates

	return index, nil, hasGroupClosed
end

return Alternate