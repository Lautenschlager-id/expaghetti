--[[
    Helper functions for string manipulation and character conversion.
]]

--[[ Globals ]]--
local bit32_bxor = bit32.bxor
local string_byte = string.byte
local string_char = string.char
local string_sub = string.sub

--[[ Dependencies ]]--
local utf8ToCharArray = require("helpers.utf8").toCharArray

--[[ Module ]]--

--- Splits a string into an array of characters.
--- When UTF-8 encoding is enabled, delegates to the UTF-8 helper.
---@param str string The string to split.
---@param encodeUTF8 boolean Whether to split using UTF-8 code points.
---@return table characters The resulting character array.
---@return number length The number of characters.
local toCharArray = function(str, encodeUTF8)
	if encodeUTF8 then
		return utf8ToCharArray(str)
	end

	local splitString = { }
	local stringLength = #str

	for index = 1, stringLength do
		splitString[index] = string_sub(str, index, index)
	end

	return splitString, stringLength
end

--- Converts a printable ASCII character into its corresponding control
--- character according to the Lua pattern `%c` rules.
---@param char string The printable ASCII character.
---@return string|nil controlCharacter The corresponding control character, or nil if unsupported.
local toControlCharacter
do
	local delimiters = {
		-- <init_lim>, <final_lim>, <xor_by>
		'\x20', '_', 0x40,
		'{', '~', 0x40,
		'a', 'z', 0x60
	}
	local delimitersLength = #delimiters

	toControlCharacter = function(char)
		for index = 1, delimitersLength, 3 do
			if char >= delimiters[index] and char <= delimiters[index + 1] then
				return string_char(
					bit32_bxor(
						string_byte(char),
						delimiters[index + 2]
					)
				)
			end
		end
	end
end

return {
	toCharArray = toCharArray,
	toControlCharacter = toControlCharacter
}