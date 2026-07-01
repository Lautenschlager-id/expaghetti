local AST = require("./ast")
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
	return {
		[1] = AST.Alternate(tree),
		_index = 1
	}
end

Alternate.parse = function(state, tree)

	local totalAlternates = 1
	local firstAlternative = { _index = tree._index }
	for i = 1, tree._index do
		firstAlternative[i] = tree[i]
	end
	tree[1] = firstAlternative

	local isBranchReset = state.isBranchReset
	local initialGroupIndex = state.initialGroupIndex
	local maxGroupIndex = state.metaData.groupIndex

	local alternativeTree, altErrorMessage
	repeat
		state.index = state.index + 1
		
		if isBranchReset then
			state.metaData.groupIndex = initialGroupIndex
		end

		alternativeTree, altErrorMessage = state:parseSubTree(state.isGroup, true, state.hasGroupClosed)

		if isBranchReset then
			if state.metaData.groupIndex > maxGroupIndex then
				maxGroupIndex = state.metaData.groupIndex
			end
		end

		if not alternativeTree then
			-- index = error message
			return false, altErrorMessage
		end

		totalAlternates = totalAlternates + 1
		tree[totalAlternates] = alternativeTree
	until state.index > state.charactersIndex or (state.isGroup and state.hasGroupClosed)

	if isBranchReset then
		state.metaData.groupIndex = maxGroupIndex
	end

	for elementIndex = totalAlternates + 1, tree._index do
		tree[elementIndex] = nil
	end
	tree._index = totalAlternates

	return state.index, nil, state.hasGroupClosed
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