----------------------------------------------------------------------------------------------------
local next = next
local type = type
----------------------------------------------------------------------------------------------------
local function tblDeepCopy(tbl)
	local copy = { }
	for key, value in next, tbl do
		if type(value) == "table" then
			copy[key] = tblDeepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return {
	tblDeepCopy = tblDeepCopy
}