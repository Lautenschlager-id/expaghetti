local isPositiveIntegerChar = function(char)
	return char >= '1' and char <= '9'
end

local isPositiveOrZeroIntegerChar = function(char)
	return char >= '0' and char <= '9'
end

return {
    isPositiveIntegerChar = isPositiveIntegerChar,
    isPositiveOrZeroIntegerChar = isPositiveOrZeroIntegerChar
}