----------------------------------------------------------------------------------------------------
local assert = assert
local next = next
local strformat = string.format
local type = type
----------------------------------------------------------------------------------------------------
local function compareTables(tbl1, tbl2, name, isSecondCheck)
	name = name or strformat("%s.", (isSecondCheck and "Source<tbl2>" or "Source<tbl1>"))

	assert(tbl2, strformat("%s: Table not found", name))

	local valueType, compValueType
	for key, value in next, tbl1 do
		valueType = type(value)
		if valueType == "table" then
			compareTables(value, tbl2[key], strformat("%s%s.", name, key), isSecondCheck)
		else
			compValueType = type(tbl2[key])
			assert(value == tbl2[key] and valueType == compValueType,
				strformat(
					"%s: Key '%s' expected to have value %q<%s>, but got %q<%s>",
					name, key, value, valueType, tbl2[key], compValueType
				)
			)
		end
	end

	if not isSecondCheck then
		compareTables(tbl2, tbl1, nil, true)
	end
end

return {
	compareTables = compareTables
}