--[[
	Reusable error message templates shared by the parser and matcher.
]]

--[[ Globals ]]--
local next = next
local string_format = string.format

--[[ Enums ]]--
local Magic = require("expaghetti.enums.magic")

--[[ Aliases ]]--
local MAGIC_ESCAPE = Magic.ESCAPE
local MAGIC_SET_CLOSE = Magic.SET_CLOSE
local MAGIC_GROUP_NAME_OPEN = Magic.GROUP_NAME_OPEN
local MAGIC_GROUP_NAME_CLOSE = Magic.GROUP_NAME_CLOSE

--[[ Module ]]--
local errors = {
	duplicateGroupName = "Duplicate group name '%s'",
	expectedFrontierSet = "Expected a character set after frontier pattern",
	incompleteEscape = "Incomplete escape sequence",
	invalidBackreferenceName = "Invalid backreference name",
	invalidBackreferenceSyntax = string_format(
		"Invalid backreference: expected '%s'",
		MAGIC_GROUP_NAME_OPEN
	),

	invalidEscape = string_format(
		"Invalid escape '%s%%%%s'",
		MAGIC_ESCAPE
	),
	invalidGroupBehavior = "Invalid group behavior",
	invalidGroupBehaviorIndex = "Invalid group behavior index",
	invalidGroupName = "Invalid group name",
	invalidGroupRecursionName = "Invalid group recursion name",
	missingBalancedDelimiters = "Balanced pattern requires two delimiters",
	nothingToRepeat = "Nothing to repeat",
	unexpectedGroupClose = "Unexpected group close",
	unknownElementLength = "Cannot determine the fixed length of element '%%s'",
	unterminatedBackreference = string_format(
		"Unterminated backreference: expected '%s'",
		MAGIC_GROUP_NAME_CLOSE
	),
	unterminatedGroup = "Unterminated group",
	unterminatedSet = string_format(
		"Expected '%s' to close character set",
		MAGIC_SET_CLOSE
	),
	unorderedQuantifierRange = "Quantifier range is out of order",
	unorderedSetRange = "Character range is out of order",
	variableLengthLookbehind = "Lookbehinds can only be applied to fixed-length expressions",
}

local base = "Invalid regular expression: %s"
for key, value in next, errors do
	errors[key] = string_format(base, value)
end

return errors