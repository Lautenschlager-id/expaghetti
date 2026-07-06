----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local ENUM_ANCHOR_START = magicEnum.ANCHOR_START
local ENUM_ANCHOR_END = magicEnum.ANCHOR_END
local ENUM_ELEMENT_TYPE_ANCHOR = require("./enums/elements").anchor
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
	if state.flags.m then node.isMultiline = true end
	tree[tree._index] = node

	return state.index + 1
end

Anchor.match = function(currentElement, state)
	local stringIndex = state.stringIndex - 1
	if currentElement.isBeginning then
		-- ^
		if stringIndex == 0 then
			return true, nil, stringIndex
		elseif currentElement.isMultiline or (state.flags and state.flags.m) then
			local prevChar = state.splitStr[stringIndex]
			if prevChar == '\n' or prevChar == '\r' then
				return true, nil, stringIndex
			end
		end
	else
		-- $
		if stringIndex >= state.strLength then
			return true, nil, stringIndex
		elseif currentElement.isMultiline or (state.flags and state.flags.m) then
			local currChar = state.splitStr[stringIndex + 1]
			if currChar == '\n' or currChar == '\r' then
				return true, nil, stringIndex
			end
		end
	end

	return false
end

return Anchor