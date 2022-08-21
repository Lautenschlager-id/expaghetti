----------------------------------------------------------------------------------------------------
local strchar = string.char
local strformat = string.format
local pcall = pcall
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local stringCharToCtrlChar = require("./helpers/string").stringCharToCtrlChar
local tblDeepCopy = require("./helpers/table").tblDeepCopy
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local elementsEnum = require("./enums/elements")
local errorsEnum = require("./enums/errors")
local characterClasses = require("./enums/classes")
----------------------------------------------------------------------------------------------------
local ENUM_ESCAPE_CHARACTER = magicEnum.ESCAPE_CHARACTER
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE = elementsEnum.capture_reference
local ENUM_MAGIC_HASHMAP = magicEnum._hasmap
----------------------------------------------------------------------------------------------------
local Escaped = { }

local specialEscaped = { }
specialEscaped.c = function(currentCharacter, index, expression)
	local ctrlChar = stringCharToCtrlChar(currentCharacter)
	if not ctrlChar then
		return false, errorsEnum.invalidParamCtrlChar
	end

	return index + 1, {
		type = ENUM_ELEMENT_TYPE_LITERAL,
		value = ctrlChar
	}
end

specialEscaped.e = function(currentCharacter, index, expression)
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

specialEscaped.int = function(currentCharacter, index)
	currentCharacter = currentCharacter + 0

	--[[
		{
			type = ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE,
			index = 1
		}
	]]
	return index, {
		type = ENUM_ELEMENT_TYPE_CAPTURE_REFERENCE,
		index = currentCharacter
	}
end
----------------------------------------------------------------------------------------------------
Escaped.is = function(currentCharacter)
	return currentCharacter == ENUM_ESCAPE_CHARACTER
end

Escaped.execute = function(index, expression)
	-- Skip escape
	index = index + 1

	local currentCharacter = expression[index]
	if not currentCharacter then
		return false, errorsEnum.incompleteEscape
	end

	-- Returns the index for the next character
	index = index + 1

	if characterClasses[currentCharacter] then
		return index, tblDeepCopy(characterClasses[currentCharacter])
	elseif ENUM_MAGIC_HASHMAP[currentCharacter] then
		return index, {
			type = ENUM_ELEMENT_TYPE_LITERAL,
			value = currentCharacter
		}
	elseif specialEscaped[currentCharacter] then
		return specialEscaped[currentCharacter](expression[index], index, expression)
	elseif currentCharacter >= '1' and currentCharacter <= '9' then
		return specialEscaped.int(currentCharacter, index)
	end

	return false, strformat(errorsEnum.invalidEscape, currentCharacter)
end

return Escaped