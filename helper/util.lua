local strsub = string.sub

local createSet = function(array)
	local set = { }
	for i = 1, #array do
		set[array[i]] = i
	end
	return set
end

local strToTbl = function(str) -- string.split(str, '.')
	local tbl = { }

	local len = #str
	for i = 1, len do
		tbl[i] = strsub(str, i, i)
	end

	return tbl, len
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

return {
	createSet = createSet,
	strToTbl = strToTbl,
	toArray = toArray,
	insert = insert
}