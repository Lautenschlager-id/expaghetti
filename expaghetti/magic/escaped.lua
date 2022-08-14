local stringUtils = require("./helpers/string")
local stringCharToCtrlChar = stringUtils.stringCharToCtrlChar

local characterClasses = require("./magic/characterClasses")

local Escaped = { }

local ESCAPE_CHARACTER = '%'

Escaped.c = function(currentCharacter, index, expression)
	local ctrlChar = stringCharToCtrlChar(currentCharacter)
	if not ctrlChar then
		return false, "Invalid regular expression: Character following \"" .. ESCAPE_CHARACTER .. "c\" must be valid"
	end

	return index, {
		type = "literal",
		value = ctrlChar
	}
end

Escaped.is = function(currentCharacter)
	return currentCharacter == ESCAPE_CHARACTER
end

Escaped.execute = function(currentCharacter, index, expression, tree)
	index = index + 1
	currentCharacter = expression[index]

	if not currentCharacter then
		return false, "Invalid regular expression: Attempt to escape null"
	end

	index = index + 1

	if characterClasses[currentCharacter] then
		return index, characterClasses[currentCharacter]
	elseif currentCharacter == ESCAPE_CHARACTER then
		return index, {
			type = "literal",
			value = currentCharacter
		}
	elseif currentCharacter then
		if Escaped[currentCharacter] then
			return Escaped[currentCharacter](expression[index], index, expression)
		end
	end
end

return Literal