package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local matcher = require("matcher")

local function assertMatch(expr, str, expectedHasMatched, expectedIniStr, expectedEndStr, desc)
	local hasMatched, iniStr, endStr, metaData, splitStr = matcher(expr, str)
	if hasMatched ~= expectedHasMatched then
		error(string.format("Test '%s' failed: Expected hasMatched=%s for expr='%s', str='%s' but got %s", desc, tostring(expectedHasMatched), expr, str, tostring(hasMatched)))
	end
	if expectedHasMatched then
		if iniStr ~= expectedIniStr or endStr ~= expectedEndStr then
			error(string.format("Test '%s' failed: Expected span=(%s, %s) but got (%s, %s)", desc, tostring(expectedIniStr), tostring(expectedEndStr), tostring(iniStr), tostring(endStr)))
		end
	end
end

print("Running matcher tests for core engine...")

-- 1. Malformed inputs
do
	local hasMatched, err = matcher(123, "abc")
	assert(hasMatched == false, "Malformed input should return false")
	assert(type(err) == "string", "Malformed input should return error message")
	
	hasMatched, err = matcher("abc", 123)
	assert(hasMatched == false, "Malformed target string should return false")
end

-- 2. Literal matching
assertMatch("a", "a", true, 1, 1, "Single literal exact")
assertMatch("a", "ba", true, 2, 2, "Single literal inside")
assertMatch("abc", "xyzabcdef", true, 4, 6, "Multiple literal inside")
assertMatch("abc", "abx", nil, nil, nil, "Multiple literal mismatch")

-- 3. Wildcard matching
assertMatch(".", "a", true, 1, 1, "Single wildcard exact")
assertMatch("a.c", "abc", true, 1, 3, "Wildcard surrounded by literals")
assertMatch("a.c", "abbc", nil, nil, nil, "Wildcard wrong length")

-- 4. Escaped literals
assertMatch("%.", "a.c", true, 2, 2, "Escaped dot literal")
assertMatch("%.", "abc", nil, nil, nil, "Escaped dot non-match")

print("All matcher core engine tests passed!")
