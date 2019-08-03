local bit32 = bit32
if not bit32 then
	bit32 = require("helper/bit32")
end

local rshift = bit32.rshift
local strsub, strbyte = string.sub, string.byte

local charLength = function(byte) -- Gets the quantity of bytes of a character.
	if rshift(byte, 7) == 0x00 then
		return 1
	elseif rshift(byte, 5) == 0x06 then
		return 2
	elseif rshift(byte, 4) == 0x0E then
		return 3
	elseif rshift(byte, 3) == 0x1E then
		return 4
	end
	return 0
end

return function(str) -- Transforms a Lua string into a table with the given string split by UTF8 characters.
	local new = { }

	local index, append = 1, 0
	local charLen

	local char
	for i = 1, #str do
		repeat
			char = strsub(str, i, i)
			if append ~= 0 then
				new[index] = new[index] .. char

				append = append - 1
				if append == 0 then
					index = index + 1
				end
				break
			end
			new[index] = char

			charLen = charLength(strbyte(char))
			if charLength == 1 then
				index = index + 1
			end
			append = append + charLen - 1
		until true
	end

	return new, index
end