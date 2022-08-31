----------------------------------------------------------------------------------------------------
local ENUM_ANY_CHARACTER = require("./enums/magic").ANY_CHARACTER
local ENUM_ELEMENT_TYPE_ANY = require("./enums/elements").any
----------------------------------------------------------------------------------------------------
local Any = { }

Any.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ANY_CHARACTER
end

Any.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_ANY
end

Any.parse = function(index, tree)
	--[[
		{
			type = "any",
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_ANY,
	}

	return index + 1
end

Any.match = function(currentElement, currentCharacter)
	return true
end

return Any