package.path = package.path .. ";../?.lua;../expaghetti/?.lua"

local prettyPrint = require("helpers.prettyPrint")

local expaghetti = require("expaghetti")

local function assertDeepEqual(a, b, path)
	path = path or "root"
	if type(a) ~= type(b) then
		error("Type mismatch at " .. path .. ": expected " .. type(b) .. " but got " .. type(a), 2)
	end
	if type(a) == "table" then
		for k, v in pairs(a) do
			assertDeepEqual(v, b[k], path .. "." .. tostring(k))
		end
		for k, v in pairs(b) do
			if a[k] == nil then
				error("Missing key at " .. path .. ": " .. tostring(k), 2)
			end
		end
	else
		if a ~= b then
			error("Mismatch at " .. path .. ": expected " .. tostring(b) .. " but got " .. tostring(a), 2)
		end
	end
end

local performance = require("helpers.performance")

local errorCount = 0
local function check(name, fn)
	local status, err = pcall(fn)
	if not status then
		print("  [FAIL] " .. name)
		print("    " .. tostring(err))
		print("    " .. debug.traceback())
		errorCount = errorCount + 1
	else
		print("  [PASS] " .. name)
	end
end

performance.logPerformanceAtTheEnd(function()

print("Running Comprehensive API tests...")

--------------------------------------------------------------------------------
-- 1. exp.test
--------------------------------------------------------------------------------
print("\n--- exp.test ---")
check("Basic test", function()
	assertDeepEqual(expaghetti.test("abc", "abc"), true)
	assertDeepEqual(expaghetti.test("abc", "xabcx"), true)
	assertDeepEqual(expaghetti.test("abc", "abx"), false)
end)

check("Test with flags", function()
	assertDeepEqual(expaghetti.test("abc", "ABC", "i"), true)
	assertDeepEqual(expaghetti.test("abc", "ABC"), false)
	assertDeepEqual(expaghetti.test("^abc", "x\nabc", "m"), true)
	assertDeepEqual(expaghetti.test("^abc", "x\nabc"), false)
	assertDeepEqual(expaghetti.test("a.b", "a\nb", "s"), true)
end)

check("Test with start index", function()
	assertDeepEqual(expaghetti.test("abc", "xABC", "i", 2), true)
	assertDeepEqual(expaghetti.test("abc", "xABC", "i", 3), false)
	assertDeepEqual(expaghetti.test("^a", "a a a", nil, 3), false) -- ^ matches start of string, which is index 1. At index 3, it fails.
end)

check("Test with array/table flags", function()
	assertDeepEqual(expaghetti.test("abc", "ABC", { "i" }), true)
	assertDeepEqual(expaghetti.test("abc", "ABC", { i = true }), true)
	assertDeepEqual(expaghetti.test("abc", "ABC", { [expaghetti.Flag.CASE_INSENSITIVE] = true }), true)
end)

--------------------------------------------------------------------------------
-- 2. exp.match
--------------------------------------------------------------------------------
print("\n--- exp.match ---")
check("Basic match", function()
	local match = expaghetti.match("b(c)d", "abcdef")
	assertDeepEqual(match.start, 2)
	assertDeepEqual(match.stop, 4)
	assertDeepEqual(match.value, "bcd")
	assertDeepEqual(#match.captures, 1)
	assertDeepEqual(match.groups[1][1].value, "c")
end)

check("Match with quantifiers and multiple captures", function()
	local match = expaghetti.match("(a)+(?<foo>b)(c)", "aaabc")
	assertDeepEqual(match.start, 1)
	assertDeepEqual(match.stop, 5)
	assertDeepEqual(match.value, "aaabc")

	-- Chronological Captures
	assertDeepEqual(#match.captures, 5)
	assertDeepEqual(match.captures[1], { groupIndex = 1, start = 1, stop = 1, value = "a" })
	assertDeepEqual(match.captures[2], { groupIndex = 1, start = 2, stop = 2, value = "a" })
	assertDeepEqual(match.captures[3], { groupIndex = 1, start = 3, stop = 3, value = "a" })
	assertDeepEqual(match.captures[4], { groupIndex = 2, name = "foo", start = 4, stop = 4, value = "b" })
	assertDeepEqual(match.captures[5], { groupIndex = 3, start = 5, stop = 5, value = "c" })

	-- Grouped Captures
	assertDeepEqual(#match.groups[1], 3)
	assertDeepEqual(match.groups[1][1].value, "a")
	assertDeepEqual(#match.groups.foo, 1)
	assertDeepEqual(match.groups.foo[1].value, "b")
	assertDeepEqual(#match.groups[2], 1)
	assertDeepEqual(match.groups[2][1].value, "b")
	assertDeepEqual(#match.groups[3], 1)
	assertDeepEqual(match.groups[3][1].value, "c")
end)

check("Match with nested captures (chronological sorting)", function()
	-- (a(b(c))) -> group 1: abc, group 2: bc, group 3: c
	local match = expaghetti.match("(a(b(c)))", "abc")
	assertDeepEqual(#match.captures, 3)
	-- Chronological completion order: innermost stopes first!
	assertDeepEqual(match.captures[1].groupIndex, 3) -- (c) stopes at 3, starts at 3
	assertDeepEqual(match.captures[1].value, "c")
	assertDeepEqual(match.captures[2].groupIndex, 2) -- (b(c)) stopes at 3, starts at 2
	assertDeepEqual(match.captures[2].value, "bc")
	assertDeepEqual(match.captures[3].groupIndex, 1) -- (a(b(c))) stopes at 3, starts at 1
	assertDeepEqual(match.captures[3].value, "abc")
end)

check("Match with backreferences", function()
	local match = expaghetti.match("(a)+(b)%2", "aabb")
	assertDeepEqual(match.value, "aabb")
	assertDeepEqual(match.start, 1)
	assertDeepEqual(match.stop, 4)
	assertDeepEqual(#match.captures, 3)
	assertDeepEqual(match.captures[1].value, "a")
	assertDeepEqual(match.captures[2].value, "a")
	assertDeepEqual(match.captures[3].value, "b")
end)

check("Match with branch reset (?|...)", function()
	local match = expaghetti.match("(?|(a)|(b))(c)", "bc")
	assertDeepEqual(match.value, "bc")
	assertDeepEqual(#match.captures, 2)
	-- In branch reset, (b) is group 1, (c) is group 2
	assertDeepEqual(match.groups[1][1].value, "b")
	assertDeepEqual(match.groups[2][1].value, "c")
end)

check("Match with zero-length matches", function()
	local match = expaghetti.match("(?<=a)b?", "ac")
	-- Should match zero-length at index 2 (between a and c)
	assertDeepEqual(match.start, 2)
	assertDeepEqual(match.stop, 1) -- length 0 means stop = start - 1
	assertDeepEqual(match.value, "")
end)

--------------------------------------------------------------------------------
-- 3. exp.matchAll
--------------------------------------------------------------------------------
print("\n--- exp.matchAll ---")
check("Basic matchAll", function()
	local all = expaghetti.matchAll("(?:[a-z])(%d+)(?=[A-Z])", "a123B c45D e6F")
	assertDeepEqual(#all, 3)

	assertDeepEqual(all[1].value, "a123")
	assertDeepEqual(all[1].groups[1][1].value, "123")

	assertDeepEqual(all[2].value, "c45")
	assertDeepEqual(all[3].value, "e6")
end)

check("matchAll with zero-length matches (avoids infinite loops)", function()
	local all = expaghetti.matchAll("a*", "baac")
	-- Matches:
	-- index 1 (before b): ""
	-- index 2 (after b, matches aa): "aa"
	-- index 4 (after aa): ""
	-- index 5 (after c): ""
	assertDeepEqual(#all, 4)
	assertDeepEqual(all[1].value, "")
	assertDeepEqual(all[1].start, 1)
	assertDeepEqual(all[2].value, "aa")
	assertDeepEqual(all[2].start, 2)
	assertDeepEqual(all[3].value, "")
	assertDeepEqual(all[3].start, 4)
	assertDeepEqual(all[4].value, "")
	assertDeepEqual(all[4].start, 5)
end)

check("matchAll with flags and start", function()
	local all = expaghetti.matchAll("a", "aAaAa", "i", 3)
	assertDeepEqual(#all, 3) -- matches at 3(A), 4(a), 5(a)
	assertDeepEqual(all[1].start, 3)
end)

--------------------------------------------------------------------------------
-- 4. exp.gmatch
--------------------------------------------------------------------------------
print("\n--- exp.gmatch ---")
check("Basic gmatch iteration", function()
	local count = 0
	local results = {}
	for match in expaghetti.gmatch("%w+", "hello world 123") do
		count = count + 1
		results[count] = match.value
	end
	assertDeepEqual(count, 3)
	assertDeepEqual(results, { "hello", "world", "123" })
end)

check("gmatch with captures", function()
	local count = 0
	for match in expaghetti.gmatch("([a-z]+)=(%d+)", "a=1, b=2") do
		count = count + 1
		if count == 1 then
			assertDeepEqual(match.groups[1][1].value, "a")
			assertDeepEqual(match.groups[2][1].value, "1")
		elseif count == 2 then
			assertDeepEqual(match.groups[1][1].value, "b")
			assertDeepEqual(match.groups[2][1].value, "2")
		end
	end
	assertDeepEqual(count, 2)
end)

check("gmatch zero-length matches progression", function()
	local count = 0
	for match in expaghetti.gmatch("x?", "y") do
		count = count + 1
	end
	assertDeepEqual(count, 2) -- at index 1 before y, at index 2 after y
end)

--------------------------------------------------------------------------------
-- 5. exp.find
--------------------------------------------------------------------------------
print("\n--- exp.find ---")
check("Basic find", function()
	local start, stop = expaghetti.find("b+", "abbbc")
	assertDeepEqual(start, 2)
	assertDeepEqual(stop, 4)

	local s2, f2 = expaghetti.find("b+", "ac")
	assertDeepEqual(s2, nil)
	assertDeepEqual(f2, nil)
end)

check("find with start index", function()
	local s, f = expaghetti.find("b+", "abbbc", nil, 3)
	assertDeepEqual(s, 3)
	assertDeepEqual(f, 4)

	local s2, f2 = expaghetti.find("b+", "abbbc", nil, 5)
	assertDeepEqual(s2, nil)
end)

check("find with flags", function()
	local s, f = expaghetti.find("B+", "abbbc", "i")
	assertDeepEqual(s, 2)
	assertDeepEqual(f, 4)
end)

--------------------------------------------------------------------------------
-- 6. exp.replace / exp.gsub
--------------------------------------------------------------------------------
print("\n--- exp.replace and exp.gsub ---")
check("String replacement with templates", function()
	local rep, count = expaghetti.replace("([a-z]+)=(%d+)", "a=1 b=2 c=3", "%2=%1")
	assertDeepEqual(rep, "1=a b=2 c=3")
	assertDeepEqual(count, 1)

	local rep2, count2 = expaghetti.replace("([a-z]+)=(%d+)", "a=1", "val: %0")
	assertDeepEqual(rep2, "val: a=1")
	assertDeepEqual(count2, 1)

	-- Template with multiple captures of the same group uses the LAST capture
	local rep3, count3 = expaghetti.replace("(.)+", "abc", "group1=%1")
	assertDeepEqual(rep3, "group1=c")
	assertDeepEqual(count3, 1)
end)

check("String replacement with function", function()
	local rep, count = expaghetti.replace("([a-z]+)=(%d+)", "a=10 b=20", function(match)
		local num = tonumber(match.groups[2][1].value)
		return match.groups[1][1].value .. "=" .. tostring(num * 2)
	end)
	assertDeepEqual(rep, "a=20 b=20")
	assertDeepEqual(count, 1)

	-- Function returning nil means no replacement
	local rep2, count2 = expaghetti.replace("%d+", "1 2 3", function(match)
		if match.value == "1" then return nil end
		return "X"
	end)
	assertDeepEqual(rep2, "1 X 3")
	assertDeepEqual(count2, 1)
end)

check("String replacement with table", function()
	local tbl = { ["1"] = "ONE", ["3"] = "THREE" }
	local res, count = expaghetti.replace("(%d+)", "1 2 3", tbl)
	assertDeepEqual(res, "ONE 2 3")
	assertDeepEqual(count, 1)

	local tbl2 = { ["a"] = "A" }
	local res2, count2 = expaghetti.replace("([a-z])=", "a= b=", tbl2)
	assertDeepEqual(res2, "A b=")
	assertDeepEqual(count2, 1)

	local tbl3 = { ["b"] = "B" }
	local res3, count3 = expaghetti.replace("([a-z])=", "a= b=", tbl3)
	assertDeepEqual(res3, "a= B")
	assertDeepEqual(count3, 1)
end)

check("String replacement with templates", function()
	local rep, count = expaghetti.gsub("([a-z]+)=(%d+)", "a=1 b=2 c=3", "%2=%1")
	assertDeepEqual(rep, "1=a 2=b 3=c")
	assertDeepEqual(count, 3)

	local rep2, count2 = expaghetti.gsub("([a-z]+)=(%d+)", "a=1", "val: %0")
	assertDeepEqual(rep2, "val: a=1")
	assertDeepEqual(count2, 1)

	-- Template with multiple captures of the same group uses the LAST capture
	local rep3, count3 = expaghetti.gsub("(.)+", "abc", "group1=%1")
	assertDeepEqual(rep3, "group1=c")
	assertDeepEqual(count3, 1)
end)

check("String replacement with function", function()
	local rep, count = expaghetti.gsub("([a-z]+)=(%d+)", "a=10 b=20", function(match)
		local num = tonumber(match.groups[2][1].value)
		return match.groups[1][1].value .. "=" .. tostring(num * 2)
	end)
	assertDeepEqual(rep, "a=20 b=40")
	assertDeepEqual(count, 2)

	-- Function returning nil means no replacement and does NOT count towards the limit
	local rep2, count2 = expaghetti.gsub("%d+", "1 2 3", function(match)
		if match.value == "2" then return nil end
		return "X"
	end)
	assertDeepEqual(rep2, "X 2 X")
	assertDeepEqual(count2, 2)

	-- Verify that skipped replacements do not consume the limit
	local rep3, count3 = expaghetti.gsub("%d+", "1 2 3 4", function(match)
		if match.value == "1" then return nil end
		return "X"
	end, nil, 2)
	assertDeepEqual(rep3, "1 X X 4")
	assertDeepEqual(count3, 2)
end)

check("String replacement with table", function()
	local tbl = { ["1"] = "ONE", ["3"] = "THREE" }
	local res, count = expaghetti.gsub("(%d+)", "1 2 3", tbl)
	assertDeepEqual(res, "ONE 2 THREE")
	assertDeepEqual(count, 2)

	local tbl2 = { ["a"] = "A" }
	-- Uses group 1 if present, otherwise whole match
	local res2, count2 = expaghetti.gsub("([a-z])=", "a= b=", tbl2)
	assertDeepEqual(res2, "A b=")
	assertDeepEqual(count2, 1)

	local tbl3 = { ["b"] = "B" }
	local res3, count3 = expaghetti.gsub("([a-z])=", "a= b=", tbl3)
	assertDeepEqual(res3, "a= B")
	assertDeepEqual(count3, 1)
end)

check("gsub with limit (n) parameter", function()
	local res, count = expaghetti.gsub("a", "aaaaa", "X", nil, 3)
	assertDeepEqual(res, "XXXaa")
	assertDeepEqual(count, 3)

	local res2, count2 = expaghetti.gsub("a", "aaaaa", "X", nil, 0)
	assertDeepEqual(res2, "aaaaa")
	assertDeepEqual(count2, 0)
end)

check("gsub with zero-length matches (progression)", function()
	local res, count = expaghetti.gsub("x?", "y", "Z")
	assertDeepEqual(res, "ZyZ")
	assertDeepEqual(count, 2)
end)

--------------------------------------------------------------------------------
-- 7. exp.split
--------------------------------------------------------------------------------
print("\n--- exp.split ---")
check("Basic split", function()
	local parts = expaghetti.split(",", "a,b,c")
	assertDeepEqual(parts, { "a", "b", "c" })

	local parts2 = expaghetti.split("%s+", "hello   world  test")
	assertDeepEqual(parts2, { "hello", "world", "test" })
end)

check("Split with limit / empty elements", function()
	local parts = expaghetti.split(",", ",a,,b,")
	assertDeepEqual(parts, { "", "a", "", "b", "" })
end)

check("Split with lookarounds", function()
	local parts = expaghetti.split("(?<=a)b", "cabcb")
	assertDeepEqual(parts, { "ca", "cb" }) -- matches 'b' only if preceded by 'a'
end)

check("Split with no matches", function()
	local parts = expaghetti.split("x", "abc")
	assertDeepEqual(parts, { "abc" })
end)

check("Split with start index", function()
	local parts = expaghetti.split(",", "a,b,c", nil, 3)
	assertDeepEqual(parts, { "a,b", "c" })
end)

--------------------------------------------------------------------------------
-- 8. exp.compile
--------------------------------------------------------------------------------
print("\n--- exp.compile ---")
check("Compiled pattern reuse", function()
	local pat = expaghetti.compile("(?<word>%a+)", "i")
	assertDeepEqual(pat:test("Hello"), true)

	local match = pat:match("Testing 123")
	assertDeepEqual(match.value, "Testing")
	assertDeepEqual(match.groups.word[1].value, "Testing")

	local rep = pat:replace("Testing 123", "X")
	assertDeepEqual(rep, "X 123")

	local all = pat:matchAll("A B C")
	assertDeepEqual(#all, 3)
	assertDeepEqual(all[2].value, "B")

	local start, stop = pat:find("A B C", 3)
	assertDeepEqual(start, 3)
	assertDeepEqual(stop, 3)

	local str, count = pat:gsub("A B C", "X", 2)
	assertDeepEqual(str, "X X C")
	assertDeepEqual(count, 2)

	local parts = pat:split("A,B,C")
	assertDeepEqual(parts, { "", ",", ",", "" }) -- splits on letters
end)

--------------------------------------------------------------------------------
-- 9. Custom Engine Configuration
--------------------------------------------------------------------------------
print("\n--- Custom Engine ---")
check("Immutable isolated config", function()
	local engine = expaghetti.custom({ maxRecursionDepth = 5, maxBacktrackDepth = 100 })

	local result = engine.test("(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
	-- Should hit backtrack limit and fail gracefully returning false
	assertDeepEqual(result, false)

	-- Default engine should not be affected
	local defaultResult = expaghetti.test("(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
	-- Assuming default backtrack depth is much higher, it might take longer or return false eventually
	-- We just assert the custom engine behaves according to its own config.
end)

check("Module is callable to create custom engines", function()
	local custom = expaghetti({ maxBacktrackDepth = 10 })
	assertDeepEqual(custom.test("abc", "abc"), true)

	local result = custom.test("(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
	assertDeepEqual(result, false)
end)

--------------------------------------------------------------------------------
-- 10. String Library Installation
--------------------------------------------------------------------------------
print("\n--- exp.install and uninstall ---")
check("Monkey-patching Lua's string library", function()
	expaghetti:install()

	-- Test native string function override (remember argument swap is handled automatically)
	local match = string.match("hello", "e(l+)")
	assertDeepEqual(type(match), "table")
	assertDeepEqual(match.value, "ell")
	assertDeepEqual(match.groups[1][1].value, "ll")

	local rep = string.replace("hello", "l+", "L")
	assertDeepEqual(rep, "heLo")

	local s, f = string.find("hello", "o")
	assertDeepEqual(s, 5)

	local parts = string.split("a,b", ",")
	assertDeepEqual(parts, { "a", "b" })

	expaghetti.uninstall()

	-- Test native restored
	local native = string.match("hello", "e(l+)")
	assertDeepEqual(native, "ll")
	assertDeepEqual(string.split, nil) -- split shouldn't exist anymore
end)

--------------------------------------------------------------------------------
-- 11. Error Handling and Validation
--------------------------------------------------------------------------------
print("\n--- Error Handling ---")
check("Returns errors gracefully for malformed patterns", function()
	local result, err = expaghetti.match("[a-", "abc")
	assertDeepEqual(result, nil)
	assertDeepEqual(err, "Invalid regular expression: Expected ']' to close character set")

	local result2, err2 = expaghetti.test("+", "abc")
	assertDeepEqual(result2, nil)
	assertDeepEqual(err2, "Invalid regular expression: Nothing to repeat")

	local result3, err3 = expaghetti.split("%", "a%b")
	assertDeepEqual(result3, nil)
	assertDeepEqual(err3, "Invalid regular expression: Incomplete escape sequence")
end)

check("Returns errors gracefully for invalid targets", function()
	local success, err = pcall(expaghetti.match, 123, "abc")
	assertDeepEqual(success, false)
	local expectedMessage = "bad argument 'pattern' (string or table expected, got number)"
	assertDeepEqual(err:sub(#err - #expectedMessage + 1), expectedMessage)

	local success, err = pcall(expaghetti.match, "a", 123)
	assertDeepEqual(success, false)
	local expectedMessage = "bad argument 'targetString' (string expected, got number)"
	assertDeepEqual(err:sub(#err - #expectedMessage + 1), expectedMessage)
end)

--------------------------------------------------------------------------------
-- Conclusion
--------------------------------------------------------------------------------
if errorCount == 0 then
	print("\nAll Comprehensive API tests passed successfully!")
else
	print("\nAPI tests failed with " .. errorCount .. " errors.")
end

end, {
	runs = 1
})