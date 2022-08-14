----------------------------------------------------------------------------------------------------
local strchar = string.char
local strformat = string.format
local pcall = pcall
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local stringUtils = require("./helpers/string")
local stringCharToCtrlChar = stringUtils.stringCharToCtrlChar
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local errorsEnum = require("./enums/errors")
local characterClasses = require("./enums/classes")
----------------------------------------------------------------------------------------------------
local ENUM_ESCAPE_CHARACTER = magicEnum.ESCAPE_CHARACTER
local ENUM_ELEMENT_TYPE_LITERAL = require("./enums/elements").literal
local ENUM_MAGIC_HASHMAP = magicEnum._hasmap
----------------------------------------------------------------------------------------------------
local Escaped = { }

Escaped.c = function(currentCharacter, index, expression)
	local ctrlChar = stringCharToCtrlChar(currentCharacter)
	if not ctrlChar then
		return false, errorsEnum.invalidParamCtrlChar
	end

	return index + 1, {
		type = ENUM_ELEMENT_TYPE_LITERAL,
		value = ctrlChar
	}
end

Escaped.e = function(currentCharacter, index, expression)
	local hex = ''

	-- Must be exactly 4 characters long
	for paramIndex = 0, 3 do
		hex = hex .. (expression[index + paramIndex] or '')
	end

	hex = #hex == 4 and tonumber("0x" .. hex)
	if hex then
		local result
		result, hex = pcall(strchar, hex)
		hex = result and hex
	end

	if not hex then
		return false, errorsEnum.invalidParamUnicodeChar
	end

	return index + 4, {
		type = ENUM_ELEMENT_TYPE_LITERAL,
		value = hex
	}
end
----------------------------------------------------------------------------------------------------
Escaped.is = function(currentCharacter)
	return currentCharacter == ENUM_ESCAPE_CHARACTER
end

Escaped.execute = function(currentCharacter, index, expression, tree)
	index = index + 1
	currentCharacter = expression[index]

	if not currentCharacter then
		return false, errorsEnum.incompleteEscape
	end

	index = index + 1

	if characterClasses[currentCharacter] then
		return index, characterClasses[currentCharacter]
	elseif ENUM_MAGIC_HASHMAP[currentCharacter] then
		return index, {
			type = ENUM_ELEMENT_TYPE_LITERAL,
			value = currentCharacter
		}
	elseif Escaped[currentCharacter] then
		return Escaped[currentCharacter](expression[index], index, expression)
	end

	return false, strformat(errorsEnum.invalidEscape, currentCharacter)
end

return Escaped