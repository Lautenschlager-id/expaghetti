--[[
    Parser for quantifiers.

    Detects and parses standard, custom, and possessive/lazy quantifiers,
    attaching them to the preceding AST element.
]]

--[[ Globals ]]--
local tonumber = tonumber

--[[ Dependencies ]]--
local deepCopy = require("helpers.table").deepCopy
local ParserHelpers = require("helpers.parser")

local QuantifierNode = require("ast").Quantifier

--[[ Enums ]]--
local Magic = require("enums.magic")
local Errors = require("enums.errors")
local Quantifiers = require("enums.quantifiers")

--[[ Aliases ]]--
local consumeWhile = ParserHelpers.consumeWhile
local isPositiveOrZeroIntegerChar = ParserHelpers.isPositiveOrZeroIntegerChar

local ELEMENT_QUANTIFIER = require("enums.elements").QUANTIFIER

local ERROR_UNORDERED_QUANTIFIER_RANGE = Errors.unorderedQuantifierRange
local ERROR_NOTHING_TO_REPEAT = Errors.nothingToRepeat

local MAGIC_QUANTIFIER_CLOSE = Magic.QUANTIFIER_CLOSE
local MAGIC_QUANTIFIER_OPEN = Magic.QUANTIFIER_OPEN
local MAGIC_QUANTIFIER_SEPARATOR = Magic.QUANTIFIER_SEPARATOR

local QUANTIFIER_TOKENS = Quantifiers.TOKENS
local QUANTIFIER_MODES = Quantifiers.MODES

local ZERO_LENGTH_ELEMENTS = require("enums.elementLengths").ZERO_LENGTH

--[[ Module ]]--
local Quantifier = {}

--[[ Private Functions ]]--

--- Attempts to parse a custom quantifier (`{n}`, `{n,}`, `{,m}`, or `{n,m}`).
---@param state ParserState The current parser state.
---@param index number The current parser index.
---@return number|false nextIndex The parser index after the quantifier, or false if no valid custom quantifier was found.
---@return QuantifierNode|string quantifierOrError The parsed quantifier node, or the parser error message.
local lookForCustomQuantifier = function(state, index)
	local min, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	local max

	if currentToken == MAGIC_QUANTIFIER_SEPARATOR then
		max, index, currentToken = consumeWhile(state, index, isPositiveOrZeroIntegerChar)
	end

	if currentToken ~= MAGIC_QUANTIFIER_CLOSE then
		return false
	end

	-- {N}
	min = tonumber(min)

	if max == nil then
		max = min
	else
		-- {N,M}, {N,}, {,M}
		max = tonumber(max)

		if min and max and min > max then
			return false, ERROR_UNORDERED_QUANTIFIER_RANGE
		end
	end

	if not (min or max) or max == 0 then
		return false
	end

	return index, QuantifierNode(min, max)
end

--- Attempts to parse a quantifier at the specified parser position.
---@param state ParserState The current parser state.
---@param index number The current parser index.
---@return number|false nextIndex The parser index after the quantifier, or false if none was found.
---@return QuantifierNode|table|false|string quantifierOrError The parsed quantifier node, a predefined quantifier, false if none was found, or the parser error message.
local tryParseQuantifier = function(state, index)
	local nextIndex, currentToken = state:readElement(index)
	if not nextIndex then
		return index, false
	end
	
	if not state:isElement(currentToken) and QUANTIFIER_TOKENS[currentToken] then
		return nextIndex, QUANTIFIER_TOKENS[currentToken]
	elseif currentToken == MAGIC_QUANTIFIER_OPEN then
		local newIndex, quantifierOrError = lookForCustomQuantifier(state, nextIndex)
		if newIndex then
			return newIndex, quantifierOrError
		elseif quantifierOrError then
			return false, quantifierOrError
		end
	end

	return index, false
end

--- Parses an optional quantifier mode modifier.
---@param state ParserState The current parser state.
---@param index number The current parser index.
---@param quantifier QuantifierNode The quantifier to update.
---@return number nextIndex The parser index after the optional mode modifier.
---@return QuantifierNode quantifier The parsed quantifier.
local lookForModeToken = function(state, index, quantifier)
	local nextIndex, currentToken = state:readElement(index)
	if nextIndex and not state:isElement(currentToken) then
		local quantifierMode = QUANTIFIER_MODES[currentToken]

		if quantifierMode then
			quantifier = deepCopy(quantifier)
			quantifier.mode = quantifierMode
			index = nextIndex
		end
	end
	return index, quantifier
end

--[[ Public API ]]--

--- Returns whether a quantifier starts at the current parser position.
---@param state ParserState The current parser state.
---@return boolean hasQuantifier Whether a quantifier was found.
Quantifier.isToken = function(state)
	local index, quantifier = tryParseQuantifier(state, state.index)
	return index and quantifier
end

--- Returns whether an AST element has a quantifier.
---@param currentElement table The AST element to test.
---@return boolean hasQuantifier Whether the element has a quantifier.
Quantifier.isElement = function(currentElement)
	local quantifier = currentElement.quantifier
	return quantifier and quantifier.type == ELEMENT_QUANTIFIER
end

--- Parses and attaches a quantifier to an AST element.
---@param state ParserState The current parser state.
---@param parentElement table The AST element to update.
---@return string|nil errorMessage The parser error message on failure.
Quantifier.lookForElementOperation = function(state, parentElement)
	-- Verify if the element type supports quantifiers
	local isZeroLengthElement = ZERO_LENGTH_ELEMENTS[parentElement.type] == true

	local index, quantifier = tryParseQuantifier(state, state.index)

	if not index then
		-- quantifier = error message
		return quantifier
	elseif not quantifier then
		-- not a quantifier
		return nil
	elseif isZeroLengthElement then
		-- has a quantifier but shouldn't
		return ERROR_NOTHING_TO_REPEAT
	end

	index, quantifier = lookForModeToken(state, index, quantifier)
	parentElement.quantifier = quantifier

	state.index = index
	return nil
end

return Quantifier