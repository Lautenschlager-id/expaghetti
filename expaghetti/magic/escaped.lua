--[[
    Parser and matcher for escaped sequences.

    Supports escaped literals, character classes, backreferences,
    balanced elements, frontier assertions, control characters,
    and Unicode escape sequences.
]]

--[[ Globals ]]--
local pcall = pcall
local string_char = string.char
local string_format = string.format
local tonumber = tonumber

--[[ Dependencies ]]--
local Balanced = require("magic.balanced")
local Backreference = require("magic.backreference")
local FrontierParse = require("magic.frontier").parse

local CharacterClasses = require("enums.characterClasses")
local Errors = require("enums.errors")
local Magic = require("enums.magic")

local deepCopy = require("helpers.table").deepCopy
local isPositiveIntegerChar = require("helpers.parser").isPositiveIntegerChar
local toControlCharacter = require("helpers.string").toControlCharacter

local LiteralNode = require("core.ast").Literal

--[[ Enum Aliases ]]--
local ERROR_INVALID_CONTROL_CHARACTER_PARAMETER = Errors.invalidControlCharacterParameter
local ERROR_INVALID_UNICODE_PARAMETER = Errors.invalidUnicodeParameter
local ERROR_INCOMPLETE_ESCAPE = Errors.incompleteEscape
local ERROR_INVALID_ESCAPE = Errors.invalidEscape

local MAGIC_ESCAPE = Magic.ESCAPE
local MAGIC_HASHMAP = Magic._hashmap

--[[ Module ]]--
local Escaped = {}

-- Specialized parsers for escaped sequences that require custom handling.
local escapeHandlers = {
	-- %1 -> numeric backreference
	int = Backreference.parseByIndex,
	-- %k<name> -> named backreference
	k = Backreference.parseByName,
	-- %bxy -> balanced match between x and y
	b = Balanced.parse,
}

local replacementTemplateHandlers = {
	-- %1 -> numeric backreference
	int = Backreference.parseByIndex,
	-- %k<name> -> named backreference
	k = Backreference.parseByName,
}

-- %cA --> ctrl char A
escapeHandlers.c = function(state, currentCharacter, index, expression, isInsideSet)
	local ctrlChar = currentCharacter and toControlCharacter(currentCharacter)
	if not ctrlChar then
		return false, ERROR_INVALID_CONTROL_CHARACTER_PARAMETER
	end

	local value, lowerValue, upperValue = state:getExecutionValues(ctrlChar, isInsideSet)
	return index + 1, LiteralNode(value, lowerValue, upperValue)
end

-- %e00FF --> Unicode character (0x00FF)
escapeHandlers.e = function(state, currentCharacter, index, expression, isInsideSet)
	local hex = ''

	-- Must be exactly 4 characters long
	for paramIndex = 0, 3 do
		hex = hex .. (expression[index + paramIndex] or '')
	end

	hex = #hex == 4 and tonumber("0x" .. hex)
	if hex then
		local result
		result, hex = pcall(string_char, hex)
		hex = result and hex
	end

	if not hex then
		return false, ERROR_INVALID_UNICODE_PARAMETER
	end

	local value, lowerValue, upperValue = state:getExecutionValues(hex, isInsideSet)
	return index + 4, LiteralNode(value, lowerValue, upperValue)
end

-- %f --> frontier boundary
escapeHandlers.f = function(state, _, index)
	return FrontierParse(state, index, false)
end

-- %F --> negated frontier boundary
escapeHandlers.F = function(state, _, index)
	return FrontierParse(state, index, true)
end

--- Returns whether a character is the escape token (`%`).
---@param currentCharacter string The character to test.
---@return boolean isToken Whether the character is the escape token.
Escaped.isToken = function(currentCharacter)
	return currentCharacter == MAGIC_ESCAPE
end

--- Parses an escaped sequence.
---@param state ParserState The parser state.
---@param index number The current pattern index.
---@param expression CharacterArray The pattern characters.
---@param isInsideSet boolean|nil Whether parsing inside a character set.
---@return number|boolean nextIndex The next pattern index, or false if parsing failed.
---@return ASTElement|string element The parsed AST element or parser error message.
Escaped.parse = function(state, index, expression, isInsideSet)
	-- Skip escape
	index = index + 1

	local currentCharacter = expression[index]
	if not currentCharacter then
		return false, ERROR_INCOMPLETE_ESCAPE
	end

	-- Returns the index for the next character
	index = index + 1

	if CharacterClasses[currentCharacter] then
		local set = deepCopy(CharacterClasses[currentCharacter])
		state:compileSet(set)
		return index, set
	elseif MAGIC_HASHMAP[currentCharacter] then
		local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter, isInsideSet)
		return index, LiteralNode(value, lowerValue, upperValue)
	elseif escapeHandlers[currentCharacter] then
		return escapeHandlers[currentCharacter](state, expression[index], index, expression, isInsideSet)
	elseif isPositiveIntegerChar(currentCharacter) then
		return escapeHandlers.int(state, currentCharacter, index)
	end

	return false, string_format(ERROR_INVALID_ESCAPE, currentCharacter)
end

Escaped.parseReplacementTemplate = function(state, index, expression)
	-- Skip escape
	index = index + 1

	local currentCharacter = expression[index]
	if not currentCharacter then
		return false, ERROR_INCOMPLETE_ESCAPE
	end

	-- Returns the index for the next character
	index = index + 1

	if MAGIC_HASHMAP[currentCharacter] then
		local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter, isInsideSet)
		return index, LiteralNode(value, lowerValue, upperValue)
	elseif replacementTemplateHandlers[currentCharacter] then
		return replacementTemplateHandlers[currentCharacter](state, expression[index], index, expression)
	elseif isPositiveIntegerChar(currentCharacter) then
		return replacementTemplateHandlers.int(state, currentCharacter, index)
	end

	return false, string_format(ERROR_INVALID_ESCAPE, currentCharacter)
end

return Escaped