--[[
	Helper functions for UTF-8 string processing.
	
	Based on luvit/ustring.lua
]]

--[[ Globals ]]--
local bit32_rshift = bit32.rshift
local string_byte = string.byte
local string_sub = string.sub

--[[ Module ]]--

-- Lua 5.3+ has built-in utf8 functions
local utf8 = utf8
if utf8 then
	local utf8_char = utf8.char
	local utf8_codes = utf8.codes

	utf8.toCharArray = function(str)
		local characters = {}
		local index = 0
		
		for _, codepoint in utf8_codes(str) do
			index = index + 1
			characters[index] = utf8_char(codepoint)
		end
		
		return characters, index
	end

	return utf8
end

--[[ Private Functions ]]--

--- Returns the number of bytes in a UTF-8 character based on its leading byte.
---@param byte number The first byte of a UTF-8 character.
---@return number length The number of bytes in the character, or 0 if invalid.
local getByteLength = function(byte)
	if bit32_rshift(byte, 7) == 0x00 then
		return 1
	elseif bit32_rshift(byte, 5) == 0x06 then
		return 2
	elseif bit32_rshift(byte, 4) == 0x0E then
		return 3
	elseif bit32_rshift(byte, 3) == 0x1E then
		return 4
	end
	return 0
end

--[[ Public API ]]--

--- Splits a UTF-8 string into an array of characters.
---@param str string The UTF-8 string to split.
---@return table characters The resulting character array.
---@return number length The number of UTF-8 characters.
local toCharArray = function(str)
	local characters = { }

	local index, remainingBytes = 1, 0
	local char
	for i = 1, #str do
		repeat
			char = string_sub(str, i, i)
			if remainingBytes ~= 0 then
				characters[index] = characters[index] .. char

				remainingBytes = remainingBytes - 1
				if remainingBytes == 0 then
					index = index + 1
				end
				break
			end
			characters[index] = char

			local charLen = getByteLength(string_byte(char))
			if charLen == 1 then
				index = index + 1
			end
			remainingBytes = remainingBytes + charLen - 1
		until true
	end

	return characters, index - 1
end

return {
	toCharArray = toCharArray,
}