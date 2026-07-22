--[[
    Quantifier token definitions.
]]

--[[ Dependencies ]]--
local magicEnum = require("enums.magic")
local elementsEnum = require("enums.elements")

--[[ Enum Aliases ]]--
local ELEMENT_QUANTIFIER = elementsEnum.quantifier
local MAGIC_QUANTIFIER_ONE_OR_MORE = magicEnum.QUANTIFIER_ONE_OR_MORE
local MAGIC_QUANTIFIER_ZERO_OR_MORE = magicEnum.QUANTIFIER_ZERO_OR_MORE
local MAGIC_QUANTIFIER_ZERO_OR_ONE = magicEnum.QUANTIFIER_ZERO_OR_ONE

--[[ Return ]]--
return {
	[MAGIC_QUANTIFIER_ONE_OR_MORE] = {
		type = ELEMENT_QUANTIFIER,
		min = 1,
		max = 0,
		mode = nil
	},

	[MAGIC_QUANTIFIER_ZERO_OR_MORE] = {
		type = ELEMENT_QUANTIFIER,
		min = 0,
		max = 0,
		mode = nil
	},

	[MAGIC_QUANTIFIER_ZERO_OR_ONE] = {
		type = ELEMENT_QUANTIFIER,
		min = 0,
		max = 1,
		mode = nil
	},
}