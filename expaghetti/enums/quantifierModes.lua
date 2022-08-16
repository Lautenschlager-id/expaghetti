----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
----------------------------------------------------------------------------------------------------
local ENUM_LAZY_QUANTIFIER = magicEnum.LAZY_QUANTIFIER
local ENUM_POSSESSIVE_QUANTIFIER = magicEnum.POSSESSIVE_QUANTIFIER
----------------------------------------------------------------------------------------------------

return {
	[ENUM_LAZY_QUANTIFIER] = "lazy",

	[ENUM_POSSESSIVE_QUANTIFIER] = "possessive",
}