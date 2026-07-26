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

return {
	toCharArray = toCharArray,
}