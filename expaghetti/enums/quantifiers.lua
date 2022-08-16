----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
----------------------------------------------------------------------------------------------------
local ENUM_ELEMENT_TYPE_QUANTIFIER = require("./enums/elements").quantifier
local ENUM_ONE_OR_MORE_QUANTIFIER = magicEnum.ONE_OR_MORE_QUANTIFIER
local ENUM_ZERO_OR_MORE_QUANTIFIER = magicEnum.ZERO_OR_MORE_QUANTIFIER
local ENUM_ZERO_OR_ONE_QUANTIFIER = magicEnum.ZERO_OR_ONE_QUANTIFIER
----------------------------------------------------------------------------------------------------

return {
	[ENUM_ONE_OR_MORE_QUANTIFIER] = {
		type = ENUM_ELEMENT_TYPE_QUANTIFIER,
		min = 1,
		max = nil,
		mode = nil,
	},

	[ENUM_ZERO_OR_MORE_QUANTIFIER] = {
		type = ENUM_ELEMENT_TYPE_QUANTIFIER,
		min = nil,
		max = nil,
		mode = nil,
	},

	[ENUM_ZERO_OR_ONE_QUANTIFIER] = {
		type = ENUM_ELEMENT_TYPE_QUANTIFIER,
		min = nil,
		max = 1,
		mode = nil,
	},
}