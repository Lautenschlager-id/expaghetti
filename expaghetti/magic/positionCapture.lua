----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = require("./enums/elements").POSITION_CAPTURE
----------------------------------------------------------------------------------------------------
local POSITION_CAPTURE = { }

POSITION_CAPTURE.isElement = function(currentElement)
	return currentElement.type == ENUM_ELEMENT_TYPE_POSITION_CAPTURE
end

POSITION_CAPTURE.parse = function(index, tree, parserMetaData)
	parserMetaData.POSITION_CAPTUREIndex = parserMetaData.POSITION_CAPTUREIndex + 1

	tree._index = tree._index + 1
	tree[tree._index] = AST.POSITION_CAPTURE(parserMetaData.POSITION_CAPTUREIndex)

	return index + 1
end

POSITION_CAPTURE.match = function(currentElement, state)
	state.metaData.POSITION_CAPTUREs[currentElement.index] = state.stringIndex
	return true, nil, state.stringIndex - 1
end

return POSITION_CAPTURE