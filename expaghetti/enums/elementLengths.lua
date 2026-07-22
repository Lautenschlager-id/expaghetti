--[[
    Lookup tables classifying AST element types by the number of characters
    they consume during matching.

    Used to efficiently determine the fixed length of lookbehind expressions
    and other fixed-length constructs.
]]

--[[ Enums ]]--
local Elements = require("enums.elements")

--[[ Aliases ]]--
local ELEMENT_ANCHOR = Elements.anchor
local ELEMENT_ANY = Elements.any
local ELEMENT_BOUNDARY = Elements.boundary
local ELEMENT_LITERAL = Elements.literal
local ELEMENT_positionCapture = Elements.positionCapture
local ELEMENT_SET = Elements.set

--[[ Module ]]--
local ZERO_LENGTH = {
	[ELEMENT_ANCHOR] = true,
	[ELEMENT_BOUNDARY] = true,
	[ELEMENT_positionCapture] = true,
}

local SINGLE_LENGTH = {
	[ELEMENT_LITERAL] = true,
	[ELEMENT_ANY] = true,
	[ELEMENT_SET] = true,
}

return {
    ZERO_LENGTH = ZERO_LENGTH,
    SINGLE_LENGTH = SINGLE_LENGTH, 
}