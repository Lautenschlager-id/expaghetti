----------------------------------------------------------------------------------------------------
local tblDeepCopy = require("./helpers/table").tblDeepCopy
----------------------------------------------------------------------------------------------------
local ENUM_ALTERNATE_SEPARATOR = require("./enums/magic").ALTERNATE_SEPARATOR
local ENUM_ELEMENT_TYPE_ALTERNATE = require("./enums/elements").alternate
----------------------------------------------------------------------------------------------------
local Alternate = { }

Alternate.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ALTERNATE_SEPARATOR
end

Alternate.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_ALTERNATE
end

Alternate.transformIntoParsedTrees = function(tree)
	--[[
		{
			type = "alternate",
			trees = {
				_index = 1,
				{
					...
				}
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

Alternate.parse = function(parser, index, tree, expression, expressionLength, charactersIndex,
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

Alternate.match = function(currentElement, treeMatcher,
	flags,
	splitStr, strLength,
	stringIndex,
	matcherMetaData)

	local trees = currentElement.trees

	local hasMatched, iniStr, endStr, _, debugStr
	for treeIndex = 1, trees._index do
		hasMatched, iniStr, endStr, _, debugStr = treeMatcher(
			flags, trees[treeIndex], trees[treeIndex]._index, 0,
			splitStr, strLength,
			stringIndex, stringIndex,
			matcherMetaData
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData, debugStr
		end
	end

	return false
end

return Alternate