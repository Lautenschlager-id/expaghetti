local singleElementMatcher = require("matcher.single_element")
local quantifierMatcher = require("matcher.quantifier")
local Quantifier = require("magic.Quantifier")

local coreTreeMatcher
coreTreeMatcher = function(state)
	local tree = state.tree
	local treeIndex = state.treeIndex

	local outerTreeReference = state.metaData.outerTreeReference[tree]
	local outerTree = outerTreeReference and outerTreeReference.tree

	local currentElement, currentCharacter
	local hasQuantifier
	local hasMatched, iniStr, endStr, _, shouldEndThisExecution

	while treeIndex < tree._index do
		treeIndex = treeIndex + 1
		state.treeIndex = treeIndex
		currentElement = tree[treeIndex]

		state.stringIndex = state.stringIndex + 1
		currentCharacter = state:getTargetCharacter(state.stringIndex)

		hasQuantifier = Quantifier.isElement(currentElement)
		if hasQuantifier then
			return quantifierMatcher(
				currentElement, currentCharacter, state
			)
		end

		hasMatched, iniStr, endStr, _, shouldEndThisExecution = singleElementMatcher(
			currentElement, currentCharacter, state
		)

		-- Groups continue the execution of the previous tree in another stack
		if shouldEndThisExecution then
			return hasMatched, iniStr, endStr, state.metaData
		elseif not hasMatched then
			return
		elseif endStr then
			state.stringIndex = endStr
		end
	end

	if outerTreeReference then
		local groupIndex = tree._groupIndex
		local pushedCapture = false
		if groupIndex then
			state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
			pushedCapture = true
		end

		state.initialStringIndex = outerTreeReference.initialStringIndex
		
		state.tree = outerTreeReference.tree
		state.treeIndex = outerTreeReference.treeIndex

		local hasMatched, oIni, oEnd, oMeta = coreTreeMatcher(state)

		if not hasMatched and pushedCapture then
			state:popCapture(groupIndex)
		end

		return hasMatched, oIni, oEnd, oMeta
	end

	local groupIndex = tree._groupIndex
	if groupIndex then
		state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
	end

	return true, state.initialStringIndex + 1, state.stringIndex, state.metaData
end

return coreTreeMatcher
