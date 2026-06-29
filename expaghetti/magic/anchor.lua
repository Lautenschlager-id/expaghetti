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

Anchor.parse = function(state, currentCharacter, tree)
	tree._index = tree._index + 1
	tree[tree._index] = AST.Anchor(currentCharacter == ENUM_ANCHOR_START)

	return state.index + 1
end

return Anchor