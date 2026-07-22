--[[
    Parses alternate elements.
]]

--[[ Dependencies ]]--
local AST = require("ast")
local Group = require("magic.group.group")
local magicEnum = require("enums.magic")
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local MAGIC_ALTERNATE_BRANCH_SEPARATOR = magicEnum.ALTERNATE_BRANCH_SEPARATOR
local ELEMENT_ALTERNATE = elementsEnum.alternate

--[[ Module ]]--
local Alternate = {}

--[[ Public API ]]--
Alternate.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_ALTERNATE_BRANCH_SEPARATOR
end

Alternate.isElement = function(currentElement)
	return currentElement.type == ELEMENT_ALTERNATE
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

Alternate.match = function(currentElement, state)
	local trees = currentElement.trees
	local tree = state.tree
	local treeIndex = state.treeIndex
	local matcher = state.matcher

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
		tempState.tree = branchTree
		tempState.treeIndex = 0
		hasMatched, iniStr, endStr = matcher(
			tempState
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, state.metaData, true
		end
	end

	return false
end

--[[ Return ]]--
return Alternate