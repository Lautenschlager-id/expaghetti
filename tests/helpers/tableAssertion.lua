----------------------------------------------------------------------------------------------------
local assert = assert
local next = next
local strformat = string.format
local type = type
----------------------------------------------------------------------------------------------------
local function compareTables(tbl1, tbl2, name, isSecondCheck)
	name = name or strformat("%s.", (isSecondCheck and "Source<tbl2>" or "Source<tbl1>"))

	assert(tbl2, strformat("%s: Table not found", name))

	local ignoredKeys = {
		byteValue = true, unicodeValue = true,
		byteLowerValue = true, unicodeLowerValue = true,
		byteUpperValue = true, unicodeUpperValue = true,
		byteRanges = true, unicodeRanges = true,
		byteKeys = true, unicodeKeys = true,
		byteOpen = true, unicodeOpen = true,
		byteClose = true, unicodeClose = true,
		keys = true -- also ignore generic keys map added to set
	}

	local valueType, compValueType
	for key, value in next, tbl1 do
		if not ignoredKeys[key] then
			valueType = type(value)
			if valueType == "table" then
				compareTables(value, tbl2[key], strformat("%s%s.", name, key), isSecondCheck)
			else
				compValueType = type(tbl2[key])
				assert(value == tbl2[key] and valueType == compValueType,
					strformat(
						"%s: Key '%s' expected to have value %q<%s>, but got %q<%s>",
						tostring(name), tostring(key), tostring(value), tostring(valueType),
						tostring(tbl2[key]), tostring(compValueType)
					)
				)
			end
		end
	end

	if not isSecondCheck then
		compareTables(tbl2, tbl1, nil, true)
	end
end

return {
	compareTables = compareTables
}