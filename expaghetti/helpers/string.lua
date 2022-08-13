local strsub = string.sub

local splitStringByEachChar = function(str)
	local splitString = { }
	local stringLength = #str

	for index = 1, stringLength do
		splitString[index] = strsub(str, index, index)
	end

	return splitString, stringLength
end

return {
	splitStringByEachChar = splitStringByEachChar
}