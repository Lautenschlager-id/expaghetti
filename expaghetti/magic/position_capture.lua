----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = require("./enums/elements").position_capture
----------------------------------------------------------------------------------------------------
local PositionCapture = { }

PositionCapture.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_POSITION_CAPTURE
end

PositionCapture.parse = function(index, tree, parserMetaData)
	parserMetaData.positionCaptureIndex = parserMetaData.positionCaptureIndex + 1

	--[[
		{
			type = "position_capture",
			index = 1
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_POSITION_CAPTURE,
		index = parserMetaData.positionCaptureIndex,
	}

	return index + 1
end

PositionCapture.match = function(currentElement, state)
	state.metaData.positionCaptures[currentElement.index] = state.stringIndex
	return true, nil, state.stringIndex - 1
end

return PositionCapture