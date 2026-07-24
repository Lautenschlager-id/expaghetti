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
print("  API test: test")
assertDeepEqual(expaghetti.test("a", "a"), true)
assertDeepEqual(expaghetti.test("a", "b"), false)
assertDeepEqual(expaghetti.test("a", "A", "i"), true)
assertDeepEqual(expaghetti.test("a", "A", { "i" }), true)
assertDeepEqual(expaghetti.test("a", "A", { i = true }), true)

-- Test match
print("  API test: match")
local m, c = expaghetti.match("(a(b)c)", "xabcy")
assertDeepEqual(m, "abc")
assertDeepEqual(c, { "abc", "b" })

-- Test matchAll
print("  API test: matchAll")
local all = expaghetti.matchAll("(a)b", "abxab")
assertDeepEqual(#all, 2)
assertDeepEqual(all[1].match, "ab")
assertDeepEqual(all[1].captures[1], "a")
assertDeepEqual(all[2].match, "ab")
assertDeepEqual(all[2].index, 4)

-- Test find
print("  API test: find")
local s, e = expaghetti.find("b", "abc")
assertDeepEqual(s, 2)
assertDeepEqual(e, 2)

-- Test replace (gsub)
print("  API test: replace / gsub")
local res, cnt = expaghetti.replace("b(c)", "abcdbcx", "X%1")
assertDeepEqual(res, "aXcdXcx")
assertDeepEqual(cnt, 2)

local res2 = expaghetti.gsub("b", "abc", function() return "X" end)
assertDeepEqual(res2, "aXc")

local res3 = expaghetti.gsub("b(c)", "abc", function(m, caps) return m .. caps[1] end)
assertDeepEqual(res3, "abcc")

local res4 = expaghetti.gsub("b", "abc", { b = "X" })
assertDeepEqual(res4, "aXc")

-- Test split
print("  API test: split")
local parts = expaghetti.split(",", "a,b,c")
assertDeepEqual(parts, { "a", "b", "c" })

local parts2 = expaghetti.split("[,;]", "a;b,c")
assertDeepEqual(parts2, { "a", "b", "c" })

-- Test Engine instance configuration
print("  API test: engine instance")
local engine = expaghetti.create({ maxRecursionDepth = 5 })
assertDeepEqual(engine.config:get("maxRecursionDepth"), 5)
assertDeepEqual(engine.config:get("maxBacktrackDepth"), 50000)

local tree, err = pcall(engine.test, engine, "(?R)", "x")
assertDeepEqual(tree, true)

-- Test compiled pattern
print("  API test: compile pattern")
local pat = expaghetti.compile("a", "i")
assertDeepEqual(pat:test("A"), true)
assertDeepEqual(pat:test("b"), false)

local m, c = pat:match("A")
assertDeepEqual(m, "A")

if errorCount == 0 then
	print("API tests passed successfully!")
else
	print("API tests failed with " .. errorCount .. " errors.")
	os.exit(1)
end
