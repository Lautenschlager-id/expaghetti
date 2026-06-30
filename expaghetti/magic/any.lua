----------------------------------------------------------------------------------------------------
local ENUM_ANY_CHARACTER = require("./enums/magic").ANY_CHARACTER
local AST = require("./ast")
local ENUM_ELEMENT_TYPE_ANY = require("./enums/elements").any
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
	tree[tree._index] = AST.Any()

	return state.index + 1
end

return Any