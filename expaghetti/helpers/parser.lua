--[[
    Helper functions for parsing and string consumption.
]]

--[[ Module ]]--

--- Returns whether a character is a decimal digit from '1' to '9'.
---@param char string The character to test.
---@return boolean isPositiveIntegerChar True if the character is between '1' and '9'.
local isPositiveIntegerChar = function(char)
	return char >= '1' and char <= '9'
end

--- Returns whether a character is a decimal digit from '0' to '9'.
---@param char string The character to test.
---@return boolean isPositiveOrZeroIntegerChar True if the character is between '0' and '9'.
local isPositiveOrZeroIntegerChar = function(char)
	return char >= '0' and char <= '9'
end

--- Returns whether a character is an ASCII letter.
---@param char string The character to test.
---@return boolean isLetter True if the character is between 'A' and 'z'.
local isLetter = function(char)
	return char >= 'A' and char <= 'z'
end

--- Returns whether a character is an ASCII letter or decimal digit.
---@param char string The character to test.
---@return boolean isAlphanumeric True if the character is alphanumeric.
local isAlphanumeric = function(char)
	return (char >= 'A' and char <= 'z')
		or (char >= '0' and char <= '9')
end

--- Returns whether a character is valid within an identifier, requiring the
--- first character to be a letter.
---@param char string The character to test.
---@param length number The number of previously consumed characters.
---@return boolean isAlphanumericName True if the character is valid at the current identifier position.
local isAlphanumericName = function(char, length)
	return (char >= 'A' and char <= 'z')
		or (length > 0 and (char >= '0' and char <= '9'))
end

--- Consumes consecutive non-element characters from a parser state while a
--- predicate returns true.
---@param state ParserState The parser state to consume characters from.
---@param loopIndex number The current parser index.
---@param conditionFn fun(char:string, length:number):boolean Predicate evaluated for each consumed character.
---@return string consumed The accumulated consumed string.
---@return number|nil nextLoopIndex The index where consumption stopped.
---@return string|table|nil nextElement The element or character that caused consumption to stop.
local consumeWhile = function(state, loopIndex, conditionFn)
	local str, length = "", 0
	while true do
		local nextLoopIndex, nextChar = state:readElement(loopIndex)

		if not nextLoopIndex or not nextChar or state:isElement(nextChar) or not conditionFn(nextChar, length) then
			return str, nextLoopIndex, nextChar
		end

		str = str .. nextChar
		loopIndex = nextLoopIndex
		length = length + 1
	end
end

--- Consumes consecutive characters from an array while a predicate returns
--- true.
---@param tbl table The array of characters to consume from.
---@param loopIndex number The starting array index.
---@param conditionFn fun(char:string, length:number):boolean Predicate evaluated for each consumed character.
---@return string consumed The accumulated consumed string.
---@return number nextIndex The index where consumption stopped.
---@return string|nil nextChar The character that caused consumption to stop, or nil at end of input.
local consumeWhileArray = function(tbl, loopIndex, conditionFn)
	local str, length = "", 0
	while true do
		local char = tbl[loopIndex + 1]

		if not char or not conditionFn(char, length) then
			return str, loopIndex + 1, char
		end

		str = str .. char
		loopIndex = loopIndex + 1
		length = length + 1
	end
end

return {
	consumeWhile = consumeWhile,
	consumeWhileArray = consumeWhileArray,
	isAlphanumeric = isAlphanumeric,
	isAlphanumericName = isAlphanumericName,
	isLetter = isLetter,
	isPositiveIntegerChar = isPositiveIntegerChar,
	isPositiveOrZeroIntegerChar = isPositiveOrZeroIntegerChar,
}
