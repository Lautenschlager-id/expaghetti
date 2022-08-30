----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = require("./enums/elements").position_capture
----------------------------------------------------------------------------------------------------
local PositionCapture = { }

PositionCapture.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_POSITION_CAPTURE
end

PositionCapture.parse = function(index, tree)
	--[[
		{
			type = "position_capture",
			quantifier = false
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_POSITION_CAPTURE,
		quantifier = false,
	}

	return index + 1
end

return PositionCapture