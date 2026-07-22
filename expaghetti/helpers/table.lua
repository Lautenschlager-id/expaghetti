----------------------------------------------------------------------------------------------------
local next = next
local type = type
----------------------------------------------------------------------------------------------------
local table_deepcopy
table_deepcopy = function(tbl)
	local copy = { }
	for key, value in next, tbl do
		if type(value) == "table" then
			copy[key] = table_deepcopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return {
	table_deepcopy = table_deepcopy,
}