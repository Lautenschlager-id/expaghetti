local createSet = function(array)
	local set = { }
	for i = 1, #array do
		set[array[i]] = i
	end
	return set
end

local strToArr
do
	local strsub = string.sub

	strToArr = function(str) -- string.split(str, '.')
		local tbl = { }

		local len = #str
		for i = 1, len do
			tbl[i] = strsub(str, i, i)
		end

		return tbl, len
	end
end

local toArray = function(tbl)
	local arr = { }

	local index = 0
	for _, v in next, tbl do
		index = index + 1
		arr[index] = v
	end

	return arr
end

local charToCtrlChar, reverseCase
do
	local strbyte = string.byte
	local strchar = string.char
	local strupper = string.upper

	local A, Z = strbyte('AZ', 1, 2)
	local Aminus = A - 1

	charToCtrlChar = function(char)
		local tmp = strbyte(strupper(char))
		if tmp >= A and tmp <= Z then -- A to Z
			return strchar(tmp - Aminus)
		end
	end

	local strlower = string.lower
	local a = 'a'

	reverseCase = function(char)
		local reversed = ((char < a) and strlower(char) or strupper(char))
		return reversed, char ~= reversed 
	end
end

local flagsCode
do
	local tblsort = table.sort
	local tblconcat = table.concat

	flagsCode = function(flags)
		tblsort(flags)
		return tblconcat(flags)
	end
end

local unpack
if _VERSION > "Lua 5.1" then
	unpack = table.unpack
else
	unpack = unpack
end

return {
	createSet = createSet,
	strToArr = strToArr,
	toArray = toArray,
	charToCtrlChar = charToCtrlChar,
	flagsCode = flagsCode,
	reverseCase = reverseCase,
	unpack = unpack
}