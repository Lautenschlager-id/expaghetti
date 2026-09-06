package.path = package.path .. ";../?.lua;../expaghetti/?.lua"

--[[ Globals ]]--
local assert = assert
local pcall = pcall

--[[ Dependencies ]]--
local expaghetti = require("expaghetti")

local performance = require("tests.helpers.performance")
local testRunner = require("tests.helpers.testRunner")

--[[ Aliases ]]--
local describe = testRunner.describe
local it = testRunner.it
local runnerAssert = testRunner.assert

local assert_isTrue = runnerAssert.isTrue
local assert_isFalse = runnerAssert.isFalse
local assert_equal = runnerAssert.equal
local assert_deepEqual = runnerAssert.deepEqual
local assert_isNil = runnerAssert.isNil

--[[ Module ]]--
performance(function()

print("Running API tests...")

--------------------------------------------------------------------------------
-- 1. exp.test
--------------------------------------------------------------------------------
describe("exp.test", function()
	it("Basic test", function()
		assert_isTrue(expaghetti.test("abc", "abc"))
		assert_isTrue(expaghetti.test("abc", "xabcx"))
		assert_isFalse(expaghetti.test("abc", "abx"))
	end)

	it("Test with flags", function()
		assert_isTrue(expaghetti.test("abc", "ABC", "i"))
		assert_isFalse(expaghetti.test("abc", "ABC"))
		assert_isTrue(expaghetti.test("^abc", "x\nabc", "m"))
		assert_isFalse(expaghetti.test("^abc", "x\nabc"))
		assert_isTrue(expaghetti.test("a.b", "a\nb", "s"))
	end)

	it("Test with start index", function()
		assert_isTrue(expaghetti.test("abc", "xABC", "i", 2))
		assert_isFalse(expaghetti.test("abc", "xABC", "i", 3))
		assert_isFalse(expaghetti.test("^a", "a a a", nil, 3))
	end)

	it("Test with array/table flags", function()
		assert_isTrue(expaghetti.test("abc", "ABC", { "i" }))
		assert_isTrue(expaghetti.test("abc", "ABC", { i = true }))
		assert_isTrue(expaghetti.test("abc", "ABC", { [expaghetti.Flag.CASE_INSENSITIVE] = true }))
	end)
end)

--------------------------------------------------------------------------------
-- 2. exp.match
--------------------------------------------------------------------------------
describe("exp.match", function()
	it("Basic match", function()
		local match = expaghetti.match("b(c)d", "abcdef")
		assert_equal(match.start, 2)
		assert_equal(match.stop, 4)
		assert_equal(match.value, "bcd")
		assert_equal(#match.captures, 1)
		assert_equal(match.groups[1][1].value, "c")
	end)

	it("Match with quantifiers and multiple captures", function()
		local match = expaghetti.match("(a)+(?<foo>b)(c)", "aaabc")
		assert_equal(match.start, 1)
		assert_equal(match.stop, 5)
		assert_equal(match.value, "aaabc")

		assert_equal(#match.captures, 5)
		assert_deepEqual(match.captures[1], { groupIndex = 1, start = 1, stop = 1, value = "a" })
		assert_deepEqual(match.captures[2], { groupIndex = 1, start = 2, stop = 2, value = "a" })
		assert_deepEqual(match.captures[3], { groupIndex = 1, start = 3, stop = 3, value = "a" })
		assert_deepEqual(match.captures[4], { groupIndex = 2, name = "foo", start = 4, stop = 4, value = "b" })
		assert_deepEqual(match.captures[5], { groupIndex = 3, start = 5, stop = 5, value = "c" })

		assert_equal(#match.groups[1], 3)
		assert_equal(match.groups[1][1].value, "a")
		assert_equal(#match.groups.foo, 1)
		assert_equal(match.groups.foo[1].value, "b")
		assert_equal(#match.groups[2], 1)
		assert_equal(match.groups[2][1].value, "b")
		assert_equal(#match.groups[3], 1)
		assert_equal(match.groups[3][1].value, "c")
	end)

	it("Match with nested captures (chronological sorting)", function()
		local match = expaghetti.match("(a(b(c)))", "abc")
		assert_equal(#match.captures, 3)
		assert_equal(match.captures[1].groupIndex, 3)
		assert_equal(match.captures[1].value, "c")
		assert_equal(match.captures[2].groupIndex, 2)
		assert_equal(match.captures[2].value, "bc")
		assert_equal(match.captures[3].groupIndex, 1)
		assert_equal(match.captures[3].value, "abc")
	end)

	it("Match with backreferences", function()
		local match = expaghetti.match("(a)+(b)%2", "aabb")
		assert_equal(match.value, "aabb")
		assert_equal(match.start, 1)
		assert_equal(match.stop, 4)
		assert_equal(#match.captures, 3)
		assert_equal(match.captures[1].value, "a")
		assert_equal(match.captures[2].value, "a")
		assert_equal(match.captures[3].value, "b")
	end)

	it("Match with branch reset (?|...)", function()
		local match = expaghetti.match("(?|(a)|(b))(c)", "bc")
		assert_equal(match.value, "bc")
		assert_equal(#match.captures, 2)
		assert_equal(match.groups[1][1].value, "b")
		assert_equal(match.groups[2][1].value, "c")
	end)

	it("Match with zero-length matches", function()
		local match = expaghetti.match("(?<=a)b?", "ac")
		assert_equal(match.start, 2)
		assert_equal(match.stop, 1)
		assert_equal(match.value, "")
	end)

	it("Match with position captures", function()
		local match = expaghetti.match("()world", "hello world")
		assert_equal(match.value, "world")
		assert_equal(match.positionCaptures[1], 7)
	end)
end)

--------------------------------------------------------------------------------
-- 3. exp.matchAll
--------------------------------------------------------------------------------
describe("exp.matchAll", function()
	it("Basic matchAll", function()
		local all = expaghetti.matchAll("(?:[a-z])(%d+)(?=[A-Z])", "a123B c45D e6F")
		assert_equal(#all, 3)
		assert_equal(all[1].value, "a123")
		assert_equal(all[1].groups[1][1].value, "123")
		assert_equal(all[2].value, "c45")
		assert_equal(all[3].value, "e6")
	end)

	it("matchAll with zero-length matches (avoids infinite loops)", function()
		local all = expaghetti.matchAll("a*", "baac")
		assert_equal(#all, 4)
		assert_equal(all[1].value, "")
		assert_equal(all[1].start, 1)
		assert_equal(all[2].value, "aa")
		assert_equal(all[2].start, 2)
		assert_equal(all[3].value, "")
		assert_equal(all[3].start, 4)
		assert_equal(all[4].value, "")
		assert_equal(all[4].start, 5)
	end)

	it("matchAll with flags and start", function()
		local all = expaghetti.matchAll("a", "aAaAa", "i", 3)
		assert_equal(#all, 3)
		assert_equal(all[1].start, 3)
	end)
end)

--------------------------------------------------------------------------------
-- 4. exp.gmatch
--------------------------------------------------------------------------------
describe("exp.gmatch", function()
	it("Basic gmatch iteration", function()
		local count = 0
		local results = {}
		for match in expaghetti.gmatch("%w+", "hello world 123") do
			count = count + 1
			results[count] = match.value
		end
		assert_equal(count, 3)
		assert_deepEqual(results, { "hello", "world", "123" })
	end)

	it("gmatch with captures", function()
		local count = 0
		for match in expaghetti.gmatch("([a-z]+)=(%d+)", "a=1, b=2") do
			count = count + 1
			if count == 1 then
				assert_equal(match.groups[1][1].value, "a")
				assert_equal(match.groups[2][1].value, "1")
			elseif count == 2 then
				assert_equal(match.groups[1][1].value, "b")
				assert_equal(match.groups[2][1].value, "2")
			end
		end
		assert_equal(count, 2)
	end)

	it("gmatch zero-length matches progression", function()
		local count = 0
		for match in expaghetti.gmatch("x?", "y") do
			count = count + 1
		end
		assert_equal(count, 2)
	end)
end)

--------------------------------------------------------------------------------
-- 5. exp.find
--------------------------------------------------------------------------------
describe("exp.find", function()
	it("Basic find", function()
		local start, stop = expaghetti.find("b+", "abbbc")
		assert_equal(start, 2)
		assert_equal(stop, 4)

		local startPos2, finishPos2 = expaghetti.find("b+", "ac")
		assert_isNil(startPos2)
		assert_isNil(finishPos2)
	end)

	it("find with start index", function()
		local startPos, finishPos = expaghetti.find("b+", "abbbc", nil, 3)
		assert_equal(startPos, 3)
		assert_equal(finishPos, 4)

		local startPos2, finishPos2 = expaghetti.find("b+", "abbbc", nil, 5)
		assert_isNil(startPos2)
	end)

	it("find with flags", function()
		local startPos, finishPos = expaghetti.find("B+", "abbbc", "i")
		assert_equal(startPos, 2)
		assert_equal(finishPos, 4)
	end)
end)

--------------------------------------------------------------------------------
-- 6. exp.replace / exp.gsub
--------------------------------------------------------------------------------
describe("exp.replace and exp.gsub", function()
	it("String replacement with templates", function()
		local rep, count = expaghetti.replace("([a-z]+)=(%d+)", "a=1 b=2 c=3", "%2=%1")
		assert_equal(rep, "1=a b=2 c=3")
		assert_equal(count, 1)

		local rep2, count2 = expaghetti.replace("([a-z]+)=(%d+)", "a=1", "val: %0")
		assert_equal(rep2, "val: a=1")
		assert_equal(count2, 1)

		local rep3, count3 = expaghetti.replace("(.)+", "abc", "group1=%1")
		assert_equal(rep3, "group1=c")
		assert_equal(count3, 1)
	end)

	it("String replacement with function", function()
		local rep, count = expaghetti.replace("([a-z]+)=(%d+)", "a=10 b=20", function(match)
			local num = tonumber(match.groups[2][1].value)
			return match.groups[1][1].value .. "=" .. tostring(num * 2)
		end)
		assert_equal(rep, "a=20 b=20")
		assert_equal(count, 1)

		local rep2, count2 = expaghetti.replace("%d+", "1 2 3", function(match)
			if match.value == "1" then return nil end
			return "X"
		end)
		assert_equal(rep2, "1 X 3")
		assert_equal(count2, 1)
	end)

	it("String replacement with table", function()
		local tbl = { ["1"] = "ONE", ["3"] = "THREE" }
		local res, count = expaghetti.replace("(%d+)", "1 2 3", tbl)
		assert_equal(res, "ONE 2 3")
		assert_equal(count, 1)

		local tbl2 = { ["a"] = "A" }
		local res2, count2 = expaghetti.replace("([a-z])=", "a= b=", tbl2)
		assert_equal(res2, "A b=")
		assert_equal(count2, 1)

		local tbl3 = { ["b"] = "B" }
		local res3, count3 = expaghetti.replace("([a-z])=", "a= b=", tbl3)
		assert_equal(res3, "a= B")
		assert_equal(count3, 1)
	end)

	it("String replacement with templates (gsub)", function()
		local rep, count = expaghetti.gsub("([a-z]+)=(%d+)", "a=1 b=2 c=3", "%2=%1")
		assert_equal(rep, "1=a 2=b 3=c")
		assert_equal(count, 3)

		local rep2, count2 = expaghetti.gsub("([a-z]+)=(%d+)", "a=1", "val: %0")
		assert_equal(rep2, "val: a=1")
		assert_equal(count2, 1)

		local rep3, count3 = expaghetti.gsub("(.)+", "abc", "group1=%1")
		assert_equal(rep3, "group1=c")
		assert_equal(count3, 1)
	end)

	it("String replacement with function (gsub)", function()
		local rep, count = expaghetti.gsub("([a-z]+)=(%d+)", "a=10 b=20", function(match)
			local num = tonumber(match.groups[2][1].value)
			return match.groups[1][1].value .. "=" .. tostring(num * 2)
		end)
		assert_equal(rep, "a=20 b=40")
		assert_equal(count, 2)

		local rep2, count2 = expaghetti.gsub("%d+", "1 2 3", function(match)
			if match.value == "2" then return nil end
			return "X"
		end)
		assert_equal(rep2, "X 2 X")
		assert_equal(count2, 2)

		local rep3, count3 = expaghetti.gsub("%d+", "1 2 3 4", function(match)
			if match.value == "1" then return nil end
			return "X"
		end, nil, 2)
		assert_equal(rep3, "1 X X 4")
		assert_equal(count3, 2)
	end)

	it("String replacement with table (gsub)", function()
		local tbl = { ["1"] = "ONE", ["3"] = "THREE" }
		local res, count = expaghetti.gsub("(%d+)", "1 2 3", tbl)
		assert_equal(res, "ONE 2 THREE")
		assert_equal(count, 2)

		local tbl2 = { ["a"] = "A" }
		local res2, count2 = expaghetti.gsub("([a-z])=", "a= b=", tbl2)
		assert_equal(res2, "A b=")
		assert_equal(count2, 1)

		local tbl3 = { ["b"] = "B" }
		local res3, count3 = expaghetti.gsub("([a-z])=", "a= b=", tbl3)
		assert_equal(res3, "a= B")
		assert_equal(count3, 1)
	end)

	it("gsub with limit (n) parameter", function()
		local res, count = expaghetti.gsub("a", "aaaaa", "X", nil, 3)
		assert_equal(res, "XXXaa")
		assert_equal(count, 3)

		local res2, count2 = expaghetti.gsub("a", "aaaaa", "X", nil, 0)
		assert_equal(res2, "aaaaa")
		assert_equal(count2, 0)
	end)

	it("gsub with zero-length matches (progression)", function()
		local res, count = expaghetti.gsub("x?", "y", "Z")
		assert_equal(res, "ZyZ")
		assert_equal(count, 2)
	end)
end)

--------------------------------------------------------------------------------
-- 7. exp.split
--------------------------------------------------------------------------------
describe("exp.split", function()
	it("Basic split", function()
		local parts = expaghetti.split(",", "a,b,c")
		assert_deepEqual(parts, { "a", "b", "c" })

		local parts2 = expaghetti.split("%s+", "hello   world  test")
		assert_deepEqual(parts2, { "hello", "world", "test" })
	end)

	it("Split with limit / empty elements", function()
		local parts = expaghetti.split(",", ",a,,b,")
		assert_deepEqual(parts, { "", "a", "", "b", "" })
	end)

	it("Split with lookarounds", function()
		local parts = expaghetti.split("(?<=a)b", "cabcb")
		assert_deepEqual(parts, { "ca", "cb" })
	end)

	it("Split with no matches", function()
		local parts = expaghetti.split("x", "abc")
		assert_deepEqual(parts, { "abc" })
	end)

	it("Split with start index", function()
		local parts = expaghetti.split(",", "a,b,c", nil, 3)
		assert_deepEqual(parts, { "a,b", "c" })
	end)
end)

--------------------------------------------------------------------------------
-- 8. exp.compile
--------------------------------------------------------------------------------
describe("exp.compile", function()
	it("Compiled pattern reuse", function()
		local pat = expaghetti.compile("(?<word>%a+)", "i")
		assert_isTrue(pat:test("Hello"))

		local match = pat:match("Testing 123")
		assert_equal(match.value, "Testing")
		assert_equal(match.groups.word[1].value, "Testing")

		local rep = pat:replace("Testing 123", "X")
		assert_equal(rep, "X 123")

		local all = pat:matchAll("A B C")
		assert_equal(#all, 3)
		assert_equal(all[2].value, "B")

		local start, stop = pat:find("A B C", 3)
		assert_equal(start, 3)
		assert_equal(stop, 3)

		local str, count = pat:gsub("A B C", "X", 2)
		assert_equal(str, "X X C")
		assert_equal(count, 2)

		local parts = pat:split("A,B,C")
		assert_deepEqual(parts, { "", ",", ",", "" })
	end)
end)

--------------------------------------------------------------------------------
-- 9. Custom Engine Configuration
--------------------------------------------------------------------------------
describe("Custom Engine Configuration", function()
	it("Immutable isolated config", function()
		local engine = expaghetti.custom({ maxRecursionDepth = 5, maxBacktrackDepth = 100 })

		local result = engine.test("(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
		assert_isFalse(result)
	end)

	it("Module is callable to create custom engines", function()
		local custom = expaghetti({ maxBacktrackDepth = 10 })
		assert_isTrue(custom.test("abc", "abc"))

		local result = custom.test("(a+)+b", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaac")
		assert_isFalse(result)
	end)
end)

--------------------------------------------------------------------------------
-- 10. String Library Installation
--------------------------------------------------------------------------------
describe("String Library Installation", function()
	it("Monkey-patching Lua's string library", function()
		expaghetti:install()

		local match = string.match("hello", "e(l+)")
		assert_equal(type(match), "table")
		assert_equal(match.value, "ell")
		assert_equal(match.groups[1][1].value, "ll")

		local rep = string.replace("hello", "l+", "L")
		assert_equal(rep, "heLo")

		local startPos, finishPos = string.find("hello", "o")
		assert_equal(startPos, 5)

		local parts = string.split("a,b", ",")
		assert_deepEqual(parts, { "a", "b" })

		expaghetti.uninstall()

		local native = string.match("hello", "e(l+)")
		assert_equal(native, "ll")
		assert_isNil(string.split)
	end)
end)

--------------------------------------------------------------------------------
-- 11. Error Handling and Validation
--------------------------------------------------------------------------------
describe("Error Handling and Validation", function()
	it("Returns errors gracefully for malformed patterns", function()
		local result, err = expaghetti.match("[a-", "abc")
		assert_isNil(result)
		assert_equal(err, "Invalid regular expression: Expected ']' to close character set")

		local result2, err2 = expaghetti.test("+", "abc")
		assert_isNil(result2)
		assert_equal(err2, "Invalid regular expression: Nothing to repeat")

		local result3, err3 = expaghetti.split("%", "a%b")
		assert_isNil(result3)
		assert_equal(err3, "Invalid regular expression: Incomplete escape sequence")
	end)

	it("Returns errors gracefully for invalid targets", function()
		local success, err = pcall(expaghetti.match, 123, "abc")
		assert_isFalse(success)
		local expectedMessage = "bad argument 'pattern' (string or table expected, got number)"
		assert_equal(err:sub(#err - #expectedMessage + 1), expectedMessage)

		local success2, err2 = pcall(expaghetti.match, "a", 123)
		assert_isFalse(success2)
		local expectedMessage2 = "bad argument 'targetString' (string expected, got number)"
		assert_equal(err2:sub(#err2 - #expectedMessage2 + 1), expectedMessage2)
	end)
end)

testRunner.run()

end, {
	runs = 1
})