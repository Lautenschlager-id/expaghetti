--[[
	Parser and matcher for escaped sequences.

	Supports escaped literals, character classes, backreferences,
	balanced elements, frontier assertions, control characters,
	and Unicode escape sequences.
]]

--[[ Globals ]]--
local string_format = string.format
local tonumber = tonumber

--[[ Dependencies ]]--
local Balanced = require("magic.balanced")
local Backreference = require("magic.backreference")
local Frontier = require("magic.frontier")
local LiteralNode = require("core.ast").Literal

local deepCopy = require("helpers.table").deepCopy

local ParserHelpers = require("helpers.parser")

--[[ Enums ]]--
local CharacterClasses = require("enums.characterClasses")
local Errors = require("enums.errors")
local Magic = require("enums.magic")

local isPositiveIntegerChar = ParserHelpers.isPositiveIntegerChar
local isPositiveOrZeroIntegerChar = ParserHelpers.isPositiveOrZeroIntegerChar

--[[ Aliases ]]--
local ERROR_INCOMPLETE_ESCAPE = Errors.incompleteEscape
local ERROR_INVALID_ESCAPE = Errors.invalidEscape

local FrontierParse = Frontier.parse
local FrontierParseNegated = Frontier.parseNegated

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
	-- %f --> frontier boundary
	f = FrontierParse,
	-- %F --> negated frontier boundary
	F = FrontierParseNegated,
}

local replacementTemplateHandlers = {
	-- %1 -> numeric backreference
	int = Backreference.parseByIndex,
	-- %k<name> -> named backreference
	k = Backreference.parseByName,
}

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
	elseif escapeHandlers[currentCharacter] then
		return escapeHandlers[currentCharacter](state, expression[index], index, expression, isInsideSet)
	elseif isPositiveIntegerChar(currentCharacter) then
		return escapeHandlers.int(state, currentCharacter, index)
	elseif MAGIC_HASHMAP[currentCharacter] then
		local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter, isInsideSet)
		return index, LiteralNode(value, lowerValue, upperValue)
	end

	return false, string_format(ERROR_INVALID_ESCAPE, currentCharacter)
end

--- Parses an escaped sequence in a replacement template.
---@param state ParserState The parser state.
---@param index number The current template index.
---@param expression CharacterArray The replacement template characters.
---@return number|boolean nextIndex The next template index, or false if parsing failed.
---@return ASTElement|string element The parsed AST element or parser error message.
Escaped.parseReplacementTemplate = function(state, index, expression)
	-- Skip escape
	index = index + 1

	local currentCharacter = expression[index]
	if not currentCharacter then
		return false, ERROR_INCOMPLETE_ESCAPE
	end

	-- Returns the index for the next character
	index = index + 1

	if replacementTemplateHandlers[currentCharacter] then
		return replacementTemplateHandlers[currentCharacter](state, expression[index], index, expression)
	elseif isPositiveOrZeroIntegerChar(currentCharacter) then
		return replacementTemplateHandlers.int(state, currentCharacter, index)
	elseif MAGIC_HASHMAP[currentCharacter] then
		local value, lowerValue, upperValue = state:getExecutionValues(currentCharacter, isInsideSet)
		return index, LiteralNode(value, lowerValue, upperValue)
	end
	return false, string_format(ERROR_INVALID_ESCAPE, currentCharacter)
end

return Escaped