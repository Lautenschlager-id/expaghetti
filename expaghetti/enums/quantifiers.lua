--[[
	Definitions and lookup tables for regular expression quantifiers.
]]

--[[ Dependencies ]]--
local QuantifierNode = require("core.ast").Quantifier

--[[ Enums ]]--
local Magic = require("enums.magic")

--[[ Aliases ]]--
local MAGIC_QUANTIFIER_ONE_OR_MORE = Magic.QUANTIFIER_ONE_OR_MORE
local MAGIC_QUANTIFIER_ZERO_OR_MORE = Magic.QUANTIFIER_ZERO_OR_MORE
local MAGIC_QUANTIFIER_ZERO_OR_ONE = Magic.QUANTIFIER_ZERO_OR_ONE

local MAGIC_QUANTIFIER_LAZY = Magic.QUANTIFIER_LAZY
local MAGIC_QUANTIFIER_POSSESSIVE = Magic.QUANTIFIER_POSSESSIVE

--[[ Constants ]]--
local LAZY = "lazy"
local POSSESSIVE = "possessive"
local GREEDY = "greedy"

--[[ Module ]]--
local TOKENS = {
	-- a+
	[MAGIC_QUANTIFIER_ONE_OR_MORE] = QuantifierNode(1, 0),
	-- a*
	[MAGIC_QUANTIFIER_ZERO_OR_MORE] = QuantifierNode(0, 0),
	-- a?
	[MAGIC_QUANTIFIER_ZERO_OR_ONE] = QuantifierNode(0, 1),
}

local MODES = {
	-- a+
	GREEDY = GREEDY,
	-- a+?
	LAZY = LAZY,
	-- a++
	POSSESSIVE = POSSESSIVE,

	[MAGIC_QUANTIFIER_LAZY] = LAZY,
	[MAGIC_QUANTIFIER_POSSESSIVE] = POSSESSIVE,
}

return {
	TOKENS = TOKENS,
	MODES = MODES,
}