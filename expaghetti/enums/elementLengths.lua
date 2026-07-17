----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_ANCHOR = elementsEnum.anchor
local ENUM_ELEMENT_TYPE_BOUNDARY = elementsEnum.boundary
local ENUM_ELEMENT_TYPE_POSITION_CAPTURE = elementsEnum.position_capture
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_ANY = elementsEnum.any
local ENUM_ELEMENT_TYPE_SET = elementsEnum.set
----------------------------------------------------------------------------------------------------
local ZERO_LENGTH_ELEMENTS = {
	[ENUM_ELEMENT_TYPE_ANCHOR] = true,
	[ENUM_ELEMENT_TYPE_BOUNDARY] = true,
	[ENUM_ELEMENT_TYPE_POSITION_CAPTURE] = true,
}

local SINGLE_LENGTH_ELEMENTS = {
	[ENUM_ELEMENT_TYPE_LITERAL] = true,
	[ENUM_ELEMENT_TYPE_ANY] = true,
	[ENUM_ELEMENT_TYPE_SET] = true,
}

return {
    ZERO_LENGTH_ELEMENTS = ZERO_LENGTH_ELEMENTS,
    SINGLE_LENGTH_ELEMENTS = SINGLE_LENGTH_ELEMENTS, 
}