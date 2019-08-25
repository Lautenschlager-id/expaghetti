local bit32 = require("bit32")
local utf8 = utf8 or { }

do
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

	-- Based on luvit/ustring.lua
	utf8.create = function(str) -- Transforms a Lua string into a table with the given string split by UTF8 characters.
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
				if charLen == 1 then
					index = index + 1
				end
				append = append + charLen - 1
			until true
		end

		return new, index
	end
end

if _VERSION < "Lua 5.3" then -- no utf8 native library
	local floor = math.floor
	local strchar = string.char

	-- Based on Stepets/utf8.lua
	utf8.char = function(unicode)
		if unicode <= 0x7F then
			return strchar(unicode)
		end
		if unicode <= 0x7FF then
			return strchar((0xC0 + floor(unicode / 0x40)), (0x80 + (unicode % 0x40)))
		end
		if unicode <= 0xFFFF then
			return strchar((0xE0 + floor(unicode / 0x1000)), (0x80 + (floor(unicode / 0x40) % 0x40)), (0x80 + (unicode % 0x40)))
		end
		if unicode <= 0x10FFFF then
			local byte3 = 0x80 + (unicode % 0x40)
			unicode = floor(unicode / 0x40)
			local byte2 = 0x80 + (unicode % 0x40)
			unicode = floor(unicode / 0x40)
			local byte1 = 0x80 + (unicode % 0x40)
			unicode = floor(unicode / 0x40)
			
			return strchar((0xF0 + unicode), byte1, byte2, byte3)
		end
		error("bad argument #1 to 'char' (value out of range)")
	end
end

return utf8