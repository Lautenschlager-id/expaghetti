----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local quantifiersEnum = require("./enums/quantifiers")
----------------------------------------------------------------------------------------------------
local ENUM_ONE_OR_MORE_QUANTIFIER = magicEnum.ONE_OR_MORE_QUANTIFIER
local ENUM_ZERO_OR_MORE_QUANTIFIER = magicEnum.ZERO_OR_MORE_QUANTIFIER
local ENUM_ZERO_OR_ONE_QUANTIFIER = magicEnum.ZERO_OR_ONE_QUANTIFIER
----------------------------------------------------------------------------------------------------
local Quantifier = { }

Quantifier.try = function(index, expression, parentElement)
	local currentCharacter = expression[index]

	if not quantifiersEnum[currentCharacter] then
		return index
	end

	parentElement.quantifier = quantifiersEnum[currentCharacter]

	return index + 1
end

return Quantifier