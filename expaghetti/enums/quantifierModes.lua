----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
----------------------------------------------------------------------------------------------------
local ENUM_LAZY_QUANTIFIER = magicEnum.LAZY_QUANTIFIER
local ENUM_POSSESSIVE_QUANTIFIER = magicEnum.POSSESSIVE_QUANTIFIER
----------------------------------------------------------------------------------------------------
local ENUM_QUANTIFIER_MODE_LAZY = "lazy"
local ENUM_QUANTIFIER_MODE_POSSESSIVE = "possessive"
local ENUM_QUANTIFIER_MODE_GREEDY = "greedy"
----------------------------------------------------------------------------------------------------
return {
	[ENUM_LAZY_QUANTIFIER] = ENUM_QUANTIFIER_MODE_LAZY,
	[ENUM_POSSESSIVE_QUANTIFIER] = ENUM_QUANTIFIER_MODE_POSSESSIVE,
	LAZY = ENUM_QUANTIFIER_MODE_LAZY,
	POSSESSIVE = ENUM_QUANTIFIER_MODE_POSSESSIVE,
	GREEDY = ENUM_QUANTIFIER_MODE_GREEDY,
}