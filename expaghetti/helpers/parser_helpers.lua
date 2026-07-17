local isPositiveIntegerChar = function(char)
	return char >= '1' and char <= '9'
end

local isPositiveOrZeroIntegerChar = function(char)
	return char >= '0' and char <= '9'
end

local isLetter = function(char)
	return char >= 'A' and char <= 'z'
end

local isAlphanumeric = function(char)
	return (char >= 'A' and char <= 'z')
		or (char >= '0' and char <= '9')
end

local isAlphanumericName = function(char, length)
	return (char >= 'A' and char <= 'z')
		or (length > 0 and (char >= '0' and char <= '9'))
end

-- Consumes consecutive non-element characters from `state` starting after
-- `loopIndex`, stopping when `conditionFn` returns false or an element / end
-- of input is encountered. Returns the accumulated string, the next index, and
-- the next character (which caused the stop).
local function consumeWhile(state, loopIndex, conditionFn)
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

-- Like consumeWhile, but reads directly from an array `tbl` by integer index
-- instead of going through a state object. Starts reading from `tbl[startIndex + 1]`.
-- Returns the accumulated string, the index of the stopping character, and the
-- stopping character itself (or nil if the end of the array was reached).
local function consumeWhileArray(tbl, startIndex, conditionFn)
	local str, length = "", 0
	local loopIndex = startIndex

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
	isPositiveIntegerChar = isPositiveIntegerChar,
	isPositiveOrZeroIntegerChar = isPositiveOrZeroIntegerChar,
	isAlphanumeric = isAlphanumeric,
	isAlphanumericName = isAlphanumericName,
	consumeWhile = consumeWhile,
	consumeWhileArray = consumeWhileArray,
}
