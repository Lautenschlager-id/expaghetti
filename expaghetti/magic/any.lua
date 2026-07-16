----------------------------------------------------------------------------------------------------
local ENUM_ANY_CHARACTER = require("./enums/magic").ANY_CHARACTER
local AST = require("./ast")
local ENUM_ELEMENT_TYPE_ANY = require("./enums/elements").any
local ENUM_LINE_BREAKS = require("./enums/constants").LINE_BREAKS
----------------------------------------------------------------------------------------------------
local Any = { }

Any.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ANY_CHARACTER
end

Any.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_ANY
end

Any.parse = function(state, tree)
	tree._index = tree._index + 1
	local node = AST.Any()
	if state.flags.s then
		node.isDotAll = true
	end
	tree[tree._index] = node

	return state.index + 1
end

Any.match = function(currentElement, currentCharacter, state)
	return currentElement.isDotAll or not ENUM_LINE_BREAKS[currentCharacter]
end

return Any