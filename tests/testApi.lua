package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local expaghetti = require("expaghetti")
local matcher = require("matcher.init")

print("\nRunning API tests...")
local errorCount = 0

local function assertDeepEqual(a, b, path)
	path = path or ""
	if type(a) ~= type(b) then
		print("Mismatch at " .. path .. ": expected " .. type(b) .. " but got " .. type(a))
		errorCount = errorCount + 1
		return
	end
	if type(a) == "table" then
		for k, v in pairs(a) do
			assertDeepEqual(v, b[k], path .. "." .. tostring(k))
		end
		for k, v in pairs(b) do
			if a[k] == nil then
				print("Mismatch at " .. path .. "." .. tostring(k) .. ": expected " .. tostring(v) .. " but got nil")
				errorCount = errorCount + 1
			end
		end
	else
		if a ~= b then
			print("Mismatch at " .. path .. ": expected " .. tostring(b) .. " but got " .. tostring(a))
			errorCount = errorCount + 1
		end
	end
end

-- Test normalization
print("  API test: test (flags and complex matching)")
assertDeepEqual(expaghetti.test("(?i)aBc", "AbC"), true)
assertDeepEqual(expaghetti.test("aBc", "AbC", "i"), true)
assertDeepEqual(expaghetti.test("aBc", "AbC", { "i" }), true)
assertDeepEqual(expaghetti.test("aBc", "AbC", { i = true }), true)
assertDeepEqual(expaghetti.test("^(a|b)+c$", "ababc"), true)
assertDeepEqual(expaghetti.test("^(a|b)+c$", "ababd"), false)
assertDeepEqual(expaghetti.test("(?<=a)b", "cab"), true)
assertDeepEqual(expaghetti.test("(?<=a)b", "cb"), false)
assertDeepEqual(expaghetti.test("%b()", "a(b(c)d)e"), true)
assertDeepEqual(expaghetti.test("(?R)", "a"), false)

-- Test match
print("  API test: match (captures and groups)")
local m, c = expaghetti.match("(a(b+)c)", "xabbbcy")
assertDeepEqual(m, "abbbc")
assertDeepEqual(c, { "abbbc", "bbb" })

local m2, c2 = expaghetti.match("(?<name>%a+)%s+(?<age>%d+)", "John 25")
assertDeepEqual(m2, "John 25")
assertDeepEqual(c2, { name = "John", age = "25" })

local m3, c3 = expaghetti.match("(?|((a)(b))|(c))%2", "aba")
assertDeepEqual(m3, "aba")
assertDeepEqual(c3, { "ab", "a", "b" })

-- Test matchAll
print("  API test: matchAll (lookaheads, non-capturing, multiple)")
local all = expaghetti.matchAll("(?:[a-z])(%d+)(?=[A-Z])", "a123B c45D e6F")
assertDeepEqual(#all, 3)
assertDeepEqual(all[1].match, "a123")
assertDeepEqual(all[1].captures[1], "123")
assertDeepEqual(all[1].index, 1)
assertDeepEqual(all[2].match, "c45")
assertDeepEqual(all[2].captures[1], "45")
assertDeepEqual(all[2].index, 7)
assertDeepEqual(all[3].match, "e6")
assertDeepEqual(all[3].captures[1], "6")
assertDeepEqual(all[3].index, 12)

local all2 = expaghetti.matchAll("(?<letter>[a-c])+", "abcdabc")
assertDeepEqual(#all2, 2)
assertDeepEqual(all2[1].match, "abc")
assertDeepEqual(all2[2].match, "abc")

-- Test find
print("  API test: find (boundaries and anchors)")
local s, e = expaghetti.find("%f[%w]cat%f[%W]", "the cat in the hat")
assertDeepEqual(s, 5)
assertDeepEqual(e, 7)

local s2, e2 = expaghetti.find("^dog", "dog\ncat", "m")
assertDeepEqual(s2, 1)
assertDeepEqual(e2, 3)

local s3, e3 = expaghetti.find("^cat", "dog\ncat", "m")
assertDeepEqual(s3, 5)
assertDeepEqual(e3, 7)

-- Test replace (gsub)
print("  API test: replace / gsub (templates, tables, functions)")
local res, cnt = expaghetti.replace("([a-z]+)=(%d+)", "a=1 b=2 c=3", "%2=%1")
assertDeepEqual(res, "1=a 2=b 3=c")
assertDeepEqual(cnt, 3)

local res2, cnt2 = expaghetti.gsub("%w+", "hello world", function(m) return string.upper(m) end)
assertDeepEqual(res2, "HELLO WORLD")
assertDeepEqual(cnt2, 2)

local res3, cnt3 = expaghetti.gsub("(?<amount>%d+)(?<unit>m|cm)", "100m and 50cm", function(m, caps)
	if caps.unit == "m" then
		return (tonumber(caps.amount) * 100) .. "cm"
	end
	return m
end)
assertDeepEqual(res3, "10000cm and 50cm")
assertDeepEqual(cnt3, 2)

local res4 = expaghetti.gsub("([abc]+)", "a b c abc", { a = "x", b = "y", c = "z", abc = "xyz" })
assertDeepEqual(res4, "x y z xyz")

-- Empty match string replacement loop test
local res5 = expaghetti.gsub("a?", "bb", "X")
assertDeepEqual(res5, "XbXbX")

-- Test split
print("  API test: split")
local parts = expaghetti.split("%s+", "hello  world   lua")
assertDeepEqual(parts, { "hello", "world", "lua" })

local parts2 = expaghetti.split("[,;]%s*", "a, b;c,d; e")
assertDeepEqual(parts2, { "a", "b", "c", "d", "e" })

local parts3 = expaghetti.split("(?<=a)b", "cabcb")
assertDeepEqual(parts3, { "ca", "cb" })

-- Test Engine instance configuration
print("  API test: engine instance (limits)")
local engine = expaghetti.create({ maxRecursionDepth = 5, maxBacktrackDepth = 100 })
assertDeepEqual(engine.config:get("maxRecursionDepth"), 5)
assertDeepEqual(engine.config:get("maxBacktrackDepth"), 100)

local success, result = pcall(engine.test, engine, "(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
-- Should fail gracefully due to backtrack limits, throwing an error or returning false
assertDeepEqual(type(result) == "string" or result == false, true)

-- Test compiled pattern
print("  API test: compile pattern")
local pat = expaghetti.compile("(?<word>%a+)", "i")
assertDeepEqual(pat:test("Hello"), true)
assertDeepEqual(pat:test("123"), false)

local m4, c4 = pat:match("Testing 123")
assertDeepEqual(m4, "Testing")
assertDeepEqual(c4, { word = "Testing" })

if errorCount == 0 then
	print("API tests passed successfully!")
else
	print("API tests failed with " .. errorCount .. " errors.")
	os.exit(1)
end
