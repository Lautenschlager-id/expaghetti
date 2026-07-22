----------------------------------------------------------------------------------------------------
local ENUM_ANY = require("./enums/magic").ANY
local AST = require("./ast")
local ENUM_ELEMENT_TYPE_ANY = require("./enums/elements").any
local ENUM_LINE_BREAKS = require("./enums/lineBreaks")
----------------------------------------------------------------------------------------------------
local Any = { }

Any.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ANY
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

	state.index = state.index + 1
	return nil
end

Any.match = function(currentElement, _, currentCharacter)
	return currentElement.isDotAll or not ENUM_LINE_BREAKS[currentCharacter]
end

return Any