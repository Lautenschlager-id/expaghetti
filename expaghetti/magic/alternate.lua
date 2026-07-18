local AST = require("./ast")
local Group = require("./magic/group/group")
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

Alternate.parse = function(state, tree)
	if state.isAlternate then
		return tree, true, nil
	end

	local totalAlternates = 1
	local firstBranch = { _index = tree._index }
	for i = 1, tree._index do
		firstBranch[i] = tree[i]
	end
	tree[1] = firstBranch

	local isBranchReset = state.isBranchReset
	local initialGroupIndex = state.initialGroupIndex
	local maxGroupIndex = state.metaData.groupIndex

	local alternativeTree, altErrorMessage
	repeat
		state.index = state.index + 1
		
		if isBranchReset then
			state.metaData.groupIndex = initialGroupIndex
		end

		local childState = state:fork()
		childState.isAlternate = true
		alternativeTree, altErrorMessage = state:parseSubTree(childState)
		if not alternativeTree then
			return nil, false, altErrorMessage
		end

		if isBranchReset then
			if state.metaData.groupIndex > maxGroupIndex then
				maxGroupIndex = state.metaData.groupIndex
			end
		end

		totalAlternates = totalAlternates + 1
		tree[totalAlternates] = alternativeTree
	until state.index > state.patternLength or (state.isGroup and Group.isClosingToken(state.patternChars[state.index]))

	if isBranchReset then
		state.metaData.groupIndex = maxGroupIndex
	end

	for elementIndex = totalAlternates + 1, tree._index do
		tree[elementIndex] = nil
	end
	tree._index = totalAlternates

	tree = {
		[1] = AST.Alternate(tree),
		_index = 1
	}

	return tree, true, nil
end

Alternate.match = function(currentElement, treeMatcher, state, tree, treeIndex)
	local trees = currentElement.trees

	local hasMatched, iniStr, endStr
	for branchIndex = 1, trees._index do
		if branchIndex > 1 then
			if state:incrementBacktrack() then
				return false
			end
		end

		local branchTree = trees[branchIndex]

		if tree and not state.metaData.outerTreeReference[branchTree] then
			state.metaData.outerTreeReference[branchTree] = {
				tree = tree,
				treeLength = tree._index,
				treeIndex = treeIndex,
				initialStringIndex = state.initialStringIndex
			}
		end

		local tempState = state:branch(state.stringIndex - 1, state.initialStringIndex)
		hasMatched, iniStr, endStr = treeMatcher(
			tempState, branchTree, 0
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, state.metaData, true
		end
	end

	return false
end

return Alternate