-- Based on luvit/ustring.lua
----------------------------------------------------------------------------------------------------
local rshift = bit32.rshift
local strbyte = string.byte
local strsub = string.sub
----------------------------------------------------------------------------------------------------
local utf8 = utf8 or { }

--[[
	Gets the number of bytes of a character.
	@param byte {string} A character
	@returns {int} The number of bytes of the given character
]]
local charLength = function(byte)
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
----------------------------------------------------------------------------------------------------
--[[
	Transforms a Lua string into a table with the given string split by UTF8 characters.
	@param str {string} A string
	@returns #1 {table} A table with the given string split by unicode characters
	@returns #2 {int} The string length considering the unicodes
]]
utf8.transform = function(str)
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

	return new, index - 1
end

return utf8