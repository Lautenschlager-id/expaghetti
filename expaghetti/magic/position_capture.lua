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
			index = 1,
			quantifier = false
		}
	]]
	tree._index = tree._index + 1
	tree[tree._index] = {
		type = ENUM_ELEMENT_TYPE_POSITION_CAPTURE,
		index = parserMetaData.positionCaptureIndex,
		quantifier = false,
	}

	return index + 1
end

PositionCapture.match = function(currentElement, stringIndex, matcherMetaData)
	matcherMetaData.positionCaptures[currentElement.index] = stringIndex
	return true, nil, stringIndex - 1
end

return PositionCapture