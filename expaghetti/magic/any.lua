----------------------------------------------------------------------------------------------------
local ENUM_ANY_CHARACTER = require("./enums/magic").ANY_CHARACTER
local ENUM_ELEMENT_TYPE_ANY = require("./enums/elements").any
----------------------------------------------------------------------------------------------------
local Any = { }

Any.is = function(currentCharacter)
	return currentCharacter == ENUM_ANY_CHARACTER
end

Any.execute = function(index, currentCharacter, tree)
	--[[
		{
			type = ENUM_ELEMENT_TYPE_ANY,
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_ANY,
	}

	return index + 1
end

return Any