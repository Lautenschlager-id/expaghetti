--[[
	Parser and matcher for alternation (`|`) expressions.

	Handles parsing alternate branches into a single AST node and
	evaluates them sequentially during matching until one succeeds.
]]

--[[ Dependencies ]]--
local AlternateNode = require("core.ast").Alternate

--[[ Aliases ]]--
local ELEMENT_ALTERNATE = require("enums.elements").ALTERNATE

local GroupIsClosingToken = require("magic.group.group").isClosingToken

local MAGIC_ALTERNATE_BRANCH_SEPARATOR = require("enums.magic").ALTERNATE_BRANCH_SEPARATOR

--[[ Module ]]--
local Alternate = {}

--- Returns whether a character is an alternation token.
---@param currentCharacter string The character to test.
---@return boolean isAlternateToken Whether the character is an alternation token.
Alternate.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_ALTERNATE_BRANCH_SEPARATOR
end

--- Returns whether an AST element is an alternation node.
---@param currentElement table The AST element to test.
---@return boolean isAlternate Whether the element is an alternation node.
Alternate.isElement = function(currentElement)
	return currentElement.type == ELEMENT_ALTERNATE
end

--- Parses an alternation expression.
---@param state ParserState The current parser state.
---@param tree ASTTree The AST tree built before the alternation token.
---@return ASTTree|nil tree The parsed alternation tree.
---@return boolean hasParsed Whether an alternation was parsed.
---@return string|nil errorMessage The parser error message on failure.
Alternate.parse = function(state, tree)
	if state.isAlternate then
		return tree, true, nil
	end

	local branchCount, treeIndex = 1, tree._index
	local firstBranch = {
		_index = treeIndex
	}

	for index = 1, treeIndex do
		firstBranch[index] = tree[index]
	end
	tree[1] = firstBranch

	local isBranchReset, initialGroupIndex = state.isBranchReset, state.initialGroupIndex
	local stateMetadata = state.metadata
	local maxGroupIndex, stateIsGroup = stateMetadata.groupIndex, state.isGroup
	local statePatternLength, statePatternChars = state.patternLength, state.patternChars

	-- Parse each subsequent alternate branch
	repeat
		state.index = state.index + 1

		-- Branch reset groups reuse capture numbering for every branch
		if isBranchReset then
			stateMetadata.groupIndex = initialGroupIndex
		end

		local childState = state:fork()
		childState.isAlternate = true

		local branchTree, errorMessage = state:parseSubTree(childState)
		if not branchTree then
			return nil, false, errorMessage
		end

		-- Preserve the highest capture index across all branches
		if isBranchReset then
			if stateMetadata.groupIndex > maxGroupIndex then
				maxGroupIndex = stateMetadata.groupIndex
			end
		end

		branchCount = branchCount + 1
		tree[branchCount] = branchTree
	until state.index > statePatternLength or (stateIsGroup and GroupIsClosingToken(statePatternChars[state.index]))

	if isBranchReset then
		stateMetadata.groupIndex = maxGroupIndex
	end

	-- Replace the original tree contents with a single alternation element
	for elementIndex = branchCount + 1, treeIndex do
		tree[elementIndex] = nil
	end
	tree._index = branchCount

	tree = {
		[1] = AlternateNode(tree),
		_index = 1
	}

	return tree, true, nil
end

--- Matches an alternation element against the target string.
---@param currentElement table The alternation AST node to match.
---@param state MatchState The current matcher state.
---@return boolean hasMatched Whether any alternate branch matched.
---@return number|nil startIndex The match start index.
---@return number|nil endIndex The match end index.
---@return table|nil metadata The updated matcher metadata.
---@return boolean|nil allowCapture Whether captures should be recorded.
Alternate.match = function(currentElement, state)
	local branches = currentElement.branches
	local tree = state.tree
	local treeIndex = state.treeIndex
	local matcher = state.matcher
	local stateMetadata = state.metadata
	local outerTreeReference = state.metadata.outerTreeReference

	local hasMatched, iniStr, endStr
	for branchIndex = 1, branches._index do
		if branchIndex > 1 then
			if state:incrementBacktrack() then
				return false
			end
		end

		local branchTree = branches[branchIndex]

		-- Preserve the caller's execution context for nested backtracking.
		if tree and not outerTreeReference[branchTree] then
			outerTreeReference[branchTree] = {
				tree = tree,
				treeLength = tree._index,
				treeIndex = treeIndex,
				initialStringIndex = state.initialStringIndex
			}
		end

		local tempState = state:branch(state.stringIndex - 1, state.initialStringIndex)
		tempState.tree = branchTree
		tempState.treeIndex = 0
		hasMatched, iniStr, endStr = matcher(tempState)

		if hasMatched then
			return hasMatched, iniStr, endStr, stateMetadata, true
		end
	end

	return false
end

return Alternate