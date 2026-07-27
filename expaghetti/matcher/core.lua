--[[
	Core matching loop.

	Matches an AST tree against the target string.
]]

--[[ Dependencies ]]--
local elementMatcher = require("expaghetti.matcher.element")
local QuantifierIsElement = require("expaghetti.magic.Quantifier").isElement
local quantifierMatcher = require("expaghetti.matcher.quantifier")

--[[ Module ]]--

--- Matches an AST tree against the target string.
---@param state MatchState The matcher state.
---@return boolean hasMatched Whether the tree matched successfully.
---@return number|nil iniStr The starting string index of the match.
---@return number|nil endStr The ending string index of the match.
---@return MatcherMetadata|nil metadata The match metadata.
local coreTreeMatcher
coreTreeMatcher = function(state)
	local tree = state.tree
	local treeIndex = state.treeIndex

	while treeIndex < tree._index do
		treeIndex = treeIndex + 1
		state.treeIndex = treeIndex

		local currentElement = tree[treeIndex]

		state.stringIndex = state.stringIndex + 1
		local currentCharacter = state:getTargetCharacter(state.stringIndex)

		if QuantifierIsElement(currentElement) then
			return quantifierMatcher(currentElement, currentCharacter, state)
		end

		local hasMatched, iniStr, endStr, _, shouldEndThisExecution = elementMatcher(currentElement, currentCharacter, state)
		-- Group execution continues in a nested execution context.
		if shouldEndThisExecution then
			return hasMatched, iniStr, endStr, state.metadata
		elseif not hasMatched then
			return
		elseif endStr then
			state.stringIndex = endStr
		end
	end

	-- Resume execution in the parent tree after this nested tree completes.
	local groupIndex = tree._groupIndex
	local outerTreeReference = state.metadata.outerTreeReference[tree]
	if outerTreeReference then
		local pushedCapture = false
		if groupIndex then
			-- Record the completed capture before resuming the parent execution.
			state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
			pushedCapture = true
		end

		state.initialStringIndex = outerTreeReference.initialStringIndex
		state.tree = outerTreeReference.tree
		state.treeIndex = outerTreeReference.treeIndex

		local hasMatched, parentIniStr, parentEndStr, parentMetadata = coreTreeMatcher(state)

		if not hasMatched and pushedCapture then
			state:popCapture(groupIndex)
		end

		return hasMatched, parentIniStr, parentEndStr, parentMetadata
	end

	if groupIndex then
		state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
	end

	return true, state.initialStringIndex + 1, state.stringIndex, state.metadata
end

return coreTreeMatcher
