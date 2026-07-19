----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local ENUM_ANCHOR_START = magicEnum.ANCHOR_START
local ENUM_ANCHOR_END = magicEnum.ANCHOR_END
local ENUM_ELEMENT_TYPE_ANCHOR = require("./enums/elements").anchor
local ENUM_LINE_BREAKS = require("./enums/constants").LINE_BREAKS
----------------------------------------------------------------------------------------------------
local Anchor = { }

Anchor.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ANCHOR_START or currentCharacter == ENUM_ANCHOR_END
end

Anchor.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_ANCHOR
end

Anchor.parse = function(state, currentCharacter, tree)
	tree._index = tree._index + 1
	local node = AST.Anchor(currentCharacter == ENUM_ANCHOR_START)
	if state.flags.m then
		node.isMultiline = true
	end
	tree[tree._index] = node

	state.index = state.index + 1
	return nil
end

Anchor.match = function(currentElement, state, currentCharacter)
	local stringIndex = state.stringIndex - 1
	local isBeginning = currentElement.isBeginning

	if (isBeginning and stringIndex == 0) or (not isBeginning and stringIndex >= state.targetStringLength) then
		return true, nil, stringIndex
	elseif currentElement.isMultiline then
		if isBeginning then
			currentCharacter = state:getTargetCharacter(stringIndex)
		end
		if ENUM_LINE_BREAKS[currentCharacter] then
			return true, nil, stringIndex
		end
	end

	return false
end

return Anchor