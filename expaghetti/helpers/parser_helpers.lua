local isPositiveIntegerChar = function(char)
	return char >= '1' and char <= '9'
end

local isPositiveOrZeroIntegerChar = function(char)
	return char >= '0' and char <= '9'
end

local isNameToken = function(char)
	return (char >= 'A' and char <= 'z')
		or (char >= '0' and char <= '9')
		or char == '$'
end

-- Consumes consecutive non-element characters from `state` starting after
-- `loopIndex`, stopping when `conditionFn` returns false or an element / end
-- of input is encountered. Returns the accumulated string, the next index, and
-- the next character (which caused the stop).
local function consumeWhile(state, loopIndex, conditionFn)
	local str = ""

	while true do
		local nextLoopIndex, nextChar = state:readElement(loopIndex)

		if not nextLoopIndex or not nextChar or state:isElement(nextChar) or not conditionFn(nextChar) then
			return str, nextLoopIndex, nextChar
		end

		str = str .. nextChar
		loopIndex = nextLoopIndex
	end
end

-- Like consumeWhile, but reads directly from an array `tbl` by integer index
-- instead of going through a state object. Starts reading from `tbl[startIndex + 1]`.
-- Returns the accumulated string, the index of the stopping character, and the
-- stopping character itself (or nil if the end of the array was reached).
local function consumeWhileArray(tbl, startIndex, conditionFn)
	local str = ""
	local i = startIndex

	while true do
		local ch = tbl[i + 1]

		if not ch or not conditionFn(ch) then
			return str, i + 1, ch
		end

		str = str .. ch
		i = i + 1
	end
end

return {
	isPositiveIntegerChar = isPositiveIntegerChar,
	isPositiveOrZeroIntegerChar = isPositiveOrZeroIntegerChar,
	isNameToken = isNameToken,
	consumeWhile = consumeWhile,
	consumeWhileArray = consumeWhileArray,
}
