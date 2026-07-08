----------------------------------------------------------------------------------------------------
local pcall = pcall
local strchar = string.char
local strformat = string.format
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local stringCharToCtrlChar = require("./helpers/string").stringCharToCtrlChar
local tblDeepCopy = require("./helpers/table").tblDeepCopy
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local CaptureReference = require("./magic/capture_reference")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local elementsEnum = require("./enums/elements")
local errorsEnum = require("./enums/errors")
local characterClasses = require("./enums/classes")
----------------------------------------------------------------------------------------------------
local ENUM_ESCAPE_CHARACTER = magicEnum.ESCAPE_CHARACTER
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_BOUNDARY = elementsEnum.boundary
local ENUM_ELEMENT_TYPE_BALANCED = elementsEnum.balanced
local ENUM_MAGIC_HASHMAP = magicEnum._hasmap
----------------------------------------------------------------------------------------------------
local Escaped = { }

local specialEscaped = {
	-- %1 --> reference capture N
	int = CaptureReference.parseInt,
	-- %k<NN> --> reference capture NN
	k = CaptureReference.parseString,
}

-- %cA --> ctrl char A
specialEscaped.c = function(state, currentCharacter, index, expression)
	local ctrlChar = currentCharacter and stringCharToCtrlChar(currentCharacter)
	if not ctrlChar then
		return false, errorsEnum.invalidParamCtrlChar
	end

	return index + 1, {
		type = ENUM_ELEMENT_TYPE_LITERAL,
		value = ctrlChar
	}
end
-- %e00FF --> char(0x00FF)
specialEscaped.e = function(state, currentCharacter, index, expression)
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
-- %bxy --> balanced match between x and y
specialEscaped.b = function(state, currentCharacter, index, expression)
	local opener = expression[index]
	local closer = expression[index + 1]
	if not opener or not closer then
		return false, errorsEnum.incompleteEscape
	end

	local opener, openerLower, openerUpper = state:getExecutionValues(opener)
	local closer, closerLower, closerUpper = state:getExecutionValues(closer)

	return index + 2, AST.Balanced(
		openerLower or opener,
		openerUpper or opener,
		closerLower or closer,
		closerUpper or closer
	)
end
-- %f --> frontier boundary
specialEscaped.f = function(state, currentCharacter, index)
	return index, {
		type = ENUM_ELEMENT_TYPE_BOUNDARY,
		isNegated = false,
	}
end
-- %F --> negated frontier boundary
specialEscaped.F = function(state, currentCharacter, index)
	return index, {
		type = ENUM_ELEMENT_TYPE_BOUNDARY,
		isNegated = true,
	}
end
----------------------------------------------------------------------------------------------------
Escaped.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ESCAPE_CHARACTER
end

Escaped.parse = function(state, index, expression)
	-- Skip escape
	index = index + 1

	local currentCharacter = expression[index]
	if not currentCharacter then
		return false, errorsEnum.incompleteEscape
	end

	-- Returns the index for the next character
	index = index + 1

	if characterClasses[currentCharacter] then
		local set = tblDeepCopy(characterClasses[currentCharacter])
		state:compileSet(set)
		return index, set
	elseif ENUM_MAGIC_HASHMAP[currentCharacter] then
		return index, {
			type = ENUM_ELEMENT_TYPE_LITERAL,
			value = currentCharacter
		}
	elseif specialEscaped[currentCharacter] then
		return specialEscaped[currentCharacter](state, expression[index], index, expression)
	elseif CaptureReference.isIntToken(currentCharacter) then
		return specialEscaped.int(state, currentCharacter, index)
	end

	return false, strformat(errorsEnum.invalidEscape, currentCharacter)
end

return Escaped