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
	local firstAlternative = { _index = tree._index }
	for i = 1, tree._index do
		firstAlternative[i] = tree[i]
	end
	tree[1] = firstAlternative

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
	flags, tree, treeLength, treeIndex,
	splitStr, strLength,
	stringIndex, initialStringIndex,
	matcherMetaData)

	local trees = currentElement.trees

	local hasMatched, iniStr, endStr
	for branchIndex = 1, trees._index do
		local branchTree = trees[branchIndex]

		if not matcherMetaData.outerTreeReference[branchTree] and tree then
			matcherMetaData.outerTreeReference[branchTree] = {
				tree = tree,
				treeLength = treeLength,
				treeIndex = treeIndex,
				initialStringIndex = initialStringIndex
			}
		end

		hasMatched, iniStr, endStr = treeMatcher(
			flags, branchTree, branchTree._index, 0,
			splitStr, strLength,
			stringIndex, initialStringIndex,
			matcherMetaData
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData, true
		end
	end

	return false
end

return Alternate