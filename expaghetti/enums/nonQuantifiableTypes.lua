----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
----------------------------------------------------------------------------------------------------
local ENUM_ANCHOR = elementsEnum.anchor
local ENUM_BOUNDARY = elementsEnum.boundary
local ENUM_POSITION_CAPTURE = elementsEnum.position_capture
----------------------------------------------------------------------------------------------------

return {
	[ENUM_ANCHOR] = true,
	[ENUM_BOUNDARY] = true,
	[ENUM_POSITION_CAPTURE] = true,
}