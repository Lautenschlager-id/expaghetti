--[[ Globals ]]--
local assert = assert
local next = next
local string_format = string.format
local tostring = tostring
local type = type

--[[ Module ]]--
local IGNORED_KEYS = {
	byteValue = true, unicodeValue = true,
	byteLowerValue = true, unicodeLowerValue = true,
	byteUpperValue = true, unicodeUpperValue = true,
	byteRanges = true, unicodeRanges = true,
	byteKeys = true, unicodeKeys = true,
	byteOpen = true, unicodeOpen = true,
	byteClose = true, unicodeClose = true,
	keys = true -- also ignore generic keys map added to set
}

local compareTables
compareTables = function(tbl1, tbl2, path)
	path = path or "Source<tbl1>."

	assert(tbl2, string_format("%s: Table not found", path))

	-- First pass: check everything in tbl1 exists and matches in tbl2
	for key, value in next, tbl1 do
		if not IGNORED_KEYS[key] then
			local valueType = type(value)
			local compValue = tbl2[key]
			
			if valueType == "table" then
				compareTables(value, compValue, string_format("%s%s.", path, key))
			else
				local compValueType = type(compValue)
				assert(value == compValue and valueType == compValueType,
					string_format(
						"%s: Key '%s' expected to have value %q<%s>, but got %q<%s>",
						tostring(path), tostring(key), tostring(value), tostring(valueType),
						tostring(compValue), tostring(compValueType)
					)
				)
			end
		end
	end

	-- Second pass: ensure tbl2 doesn't have extra keys not present in tbl1
	for key, _ in next, tbl2 do
		if not IGNORED_KEYS[key] then
			assert(tbl1[key] ~= nil, string_format("%s: Extra key '%s' found in Source<tbl2> that is missing in Source<tbl1>", path, tostring(key)))
		end
	end
end

return compareTables