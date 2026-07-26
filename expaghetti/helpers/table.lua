--[[
	Helper functions for table manipulation.
]]

--[[ Globals ]]--
local next = next
local type = type

--[[ Module ]]--

--- Creates a deep copy of a table.
--- Nested tables are recursively copied, while non-table values are copied by reference.
---@param tbl table The table to copy.
---@return table copy A deep copy of the input table.
local deepCopy
deepCopy = function(tbl)
	local copy = { }
	for key, value in next, tbl do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return {
	deepCopy = deepCopy,
}