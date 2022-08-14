----------------------------------------------------------------------------------------------------
local strsub = string.sub
----------------------------------------------------------------------------------------------------
local splitStringByEachChar = function(str)
	local splitString = { }
	local stringLength = #str

	for index = 1, stringLength do
		splitString[index] = strsub(str, index, index)
	end

	return splitString, stringLength
end

local stringCharToCtrlChar
do
	local strbyte = string.byte
	local strchar = string.char
	local xor = bit32.bxor

	local delimiters = {
		-- <init_lim>, <final_lim>, <xor_by>
		'\x20', '_', 0x40,
		'{', '~', 0x40,
		'a', 'z', 0x60
	}
	local delimitersLength = #delimiters

	stringCharToCtrlChar = function(char)
		for index = 1, delimitersLength, 3 do
			if char >= delimiters[index] and char <= delimiters[index + 1] then
				return strchar(xor(strbyte(char), delimiters[index + 2]))
			end
		end
	end
end

return {
	splitStringByEachChar = splitStringByEachChar,
	stringCharToCtrlChar = stringCharToCtrlChar,
}