--[[
    Lookup tables classifying AST element types by the number of characters
    they consume during matching.

    Used to efficiently determine the fixed length of lookbehind expressions
    and other fixed-length constructs.
]]

--[[ Enums ]]--
local Elements = require("enums.elements")

--[[ Aliases ]]--
local ELEMENT_ANCHOR = Elements.ANCHOR
local ELEMENT_ANY = Elements.ANY
local ELEMENT_BOUNDARY = Elements.BOUNDARY
local ELEMENT_LITERAL = Elements.LITERAL
local ELEMENT_POSITION_CAPTURE = Elements.POSITION_CAPTURE
local ELEMENT_SET = Elements.SET

--[[ Module ]]--
local ZERO_LENGTH = {
	[ELEMENT_ANCHOR] = true,
	[ELEMENT_BOUNDARY] = true,
	[ELEMENT_POSITION_CAPTURE] = true,
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