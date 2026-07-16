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

	return state.index + 1
end

Anchor.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	local isBeginning = currentElement.isBeginning

	if (isBeginning and stringIndex == 0) or (not isBeginning and stringIndex >= state.targetStringLength) then
		return true, nil, stringIndex
	elseif currentElement.isMultiline then
		local charIndex = stringIndex + (isBeginning and 0 or 1)
		if ENUM_LINE_BREAKS[state:getTargetCharacter(charIndex)] then
			return true, nil, stringIndex
		end
	end

	return false
end

return Anchor