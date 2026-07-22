--[[
    Quantifier mode definitions (lazy, possessive, greedy).
]]

--[[ Dependencies ]]--
local magicEnum = require("enums.magic")

--[[ Enum Aliases ]]--
local MAGIC_QUANTIFIER_LAZY = magicEnum.QUANTIFIER_LAZY
local MAGIC_QUANTIFIER_POSSESSIVE = magicEnum.QUANTIFIER_POSSESSIVE

--[[ Constants ]]--
local QUANTIFIER_MODE_LAZY = "lazy"
local QUANTIFIER_MODE_POSSESSIVE = "possessive"
local QUANTIFIER_MODE_GREEDY = "greedy"

--[[ Return ]]--
return {
	[MAGIC_QUANTIFIER_LAZY] = QUANTIFIER_MODE_LAZY,
	[MAGIC_QUANTIFIER_POSSESSIVE] = QUANTIFIER_MODE_POSSESSIVE,
	LAZY = QUANTIFIER_MODE_LAZY,
	POSSESSIVE = QUANTIFIER_MODE_POSSESSIVE,
	GREEDY = QUANTIFIER_MODE_GREEDY,
}