----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
----------------------------------------------------------------------------------------------------
local errors = {
	invalidParamCtrlChar =
		"Parameter passed to \"" .. magicEnum.ESCAPE_CHARACTER .. "c\" must be valid",

	invalidParamUnicodeChar =
		"A valid 4 characters hexadecimal value must be passed to \""
		.. magicEnum.ESCAPE_CHARACTER .. "e\"",

	incompleteEscape = "Attempt to escape null",

	invalidEscape = "Invalid escape \"" .. magicEnum.ESCAPE_CHARACTER .. "%s\"",

	unclosedSet = "Missing '" .. magicEnum.CLOSE_SET .. "' to close set",

	unorderedSetRange = "Range out of order in set",

	unorderedCustomQuantifier = "Numbers out of order in quantifier",
}
----------------------------------------------------------------------------------------------------
local base = "Invalid regular expression: "

for k, v in next, errors do
	errors[k] = base .. v
end

return errors