local strsub = string.sub
local tblinsert = table.insert
local tblremove = table.remove

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

local insert = function(src, pos, tbl, ignore)
	ignore = ignore or 0

	local tblLen = #tbl
	--[[local realLen = tblLen - ignore

	for i = pos + ignore, #src do
		src[realLen + i] = src[i]
	end
	for i = pos, pos + tblLen - 1 do
		src[i] = tbl[i - pos + 1]
	end

	return realLen]] -- ↑ Needs more debugging to find the problems
	for i = 1, ignore do
		tblremove(src, pos)
	end
	for i = tblLen, 1, -1 do
		tblinsert(src, pos, tbl[i])
	end

	return tblLen - ignore
end

return {
	createSet = createSet,
	strToTbl = strToTbl,
	toArray = toArray,
	insert = insert
}