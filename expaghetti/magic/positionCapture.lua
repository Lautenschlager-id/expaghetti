----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_positionCapture = require("./enums/elements").positionCapture
----------------------------------------------------------------------------------------------------
local PositionCapture = { }

PositionCapture.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_positionCapture
end

PositionCapture.parse = function(index, tree, parserMetaData)
	parserMetaData.positionCaptureIndex = parserMetaData.positionCaptureIndex + 1

	tree._index = tree._index + 1
	tree[tree._index] = AST.PositionCapture(parserMetaData.positionCaptureIndex)

	return index + 1
end

PositionCapture.match = function(currentElement, state)
	state.metaData.positionCaptures[currentElement.index] = state.stringIndex
	return true, nil, state.stringIndex - 1
end

return PositionCapture