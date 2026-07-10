----------------------------------------------------------------------------------------------------
local pcall = pcall
local strchar = string.char
local strformat = string.format
local tonumber = tonumber
----------------------------------------------------------------------------------------------------
local stringCharToCtrlChar = require("./helpers/string").stringCharToCtrlChar
local tblDeepCopy = require("./helpers/table").tblDeepCopy
local isPositiveIntegerChar = require("./helpers/token").isPositiveIntegerChar
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
----------------------------------------------------------------------------------------------------
local CaptureReference = require("./magic/capture_reference")
local Boundary = require("./magic/boundary")
local Balanced = require("./magic/balanced")
----------------------------------------------------------------------------------------------------
local magicEnum = require("./enums/magic")
local elementsEnum = require("./enums/elements")
local errorsEnum = require("./enums/errors")
local characterClasses = require("./enums/classes")
----------------------------------------------------------------------------------------------------
local ENUM_ESCAPE_CHARACTER = magicEnum.ESCAPE_CHARACTER
local ENUM_MAGIC_HASHMAP = magicEnum._hasmap
----------------------------------------------------------------------------------------------------
local Escaped = { }

local specialEscaped = {
	-- %1 --> reference capture N
	int = CaptureReference.parseByIndex,
	-- %k<NN> --> reference capture NN
	k = CaptureReference.parseByName,
	-- %bxy --> balanced match between x and y
	b = Balanced.parse,
}

-- %cA --> ctrl char A
specialEscaped.c = function(state, currentCharacter, index, expression, isInsideSet)
	local ctrlChar = currentCharacter and stringCharToCtrlChar(currentCharacter)
	if not ctrlChar then
		return false, errorsEnum.invalidParamCtrlChar
	end

	local value, lowerValue, upperValue = state:getExecutionValues(ctrlChar, isInsideSet)
	return index + 1, AST.Literal(value, lowerValue, upperValue)
end
-- %e00FF --> char(0x00FF)
specialEscaped.e = function(state, currentCharacter, index, expression, isInsideSet)
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

	local value, lowerValue, upperValue = state:getExecutionValues(hex, isInsideSet)
	return index + 4, AST.Literal(value, lowerValue, upperValue)
end
-- %f --> frontier boundary
specialEscaped.f = function(state, currentCharacter, index, expression, isInsideSet)
	return Boundary.parse(state, index, false)
end
-- %F --> negated frontier boundary
specialEscaped.F = function(state, currentCharacter, index, expression, isInsideSet)
	return Boundary.parse(state, index, true)
end
----------------------------------------------------------------------------------------------------
Escaped.isToken = function(currentCharacter)
	return currentCharacter == ENUM_ESCAPE_CHARACTER
end

Escaped.parse = function(state, index, expression, isInsideSet)
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
		local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter, isInsideSet)
		return index, AST.Literal(value, lowerValue, upperValue)
	elseif specialEscaped[currentCharacter] then
		return specialEscaped[currentCharacter](state, expression[index], index, expression, isInsideSet)
	elseif isPositiveIntegerChar(currentCharacter) then
		return specialEscaped.int(state, currentCharacter, index)
	end

	return false, strformat(errorsEnum.invalidEscape, currentCharacter)
end

return Escaped