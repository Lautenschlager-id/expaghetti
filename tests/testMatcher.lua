package.path = package.path .. ";../?.lua;../expaghetti/?.lua"

--[[ Globals ]]--
local assert = assert
local error = error
local next = next
local pcall = pcall
local string_find = string.find
local string_format = string.format
local string_sub = string.sub
local table_concat = table.concat
local tostring = tostring
local type = type

--[[ Dependencies ]]--
local Assertion = require("expaghetti.helpers.assertion")
local ConfigNew = require("expaghetti.core.config").new
local compilePattern = require("expaghetti.helpers.api").compilePattern(ConfigNew())
local _matcher = require("expaghetti.matcher.init")

local prettyPrint = require("tests.helpers.prettyPrint")
local testRunner = require("tests.helpers.testRunner")

local performance = require("tests.helpers.performance")

local ENUM_FLAG_UNICODE = require("expaghetti.enums.flags").UNICODE
local toCharArray = require("expaghetti.helpers.string").toCharArray

--[[ Aliases ]]--
local AssertionIsStringOrTable = Assertion.isStringOrTable
local AssertionIsString = Assertion.isString
local AssertionIsNumber = Assertion.isNumber
local AssertionIsTable = Assertion.isTable

local describe = testRunner.describe
local it = testRunner.it

--[[ Module ]]--
local matcher = function(expr, str, flags, startPosition, config)
	AssertionIsStringOrTable(expr, "pattern")
	AssertionIsString(str, "targetString")
	AssertionIsStringOrTable(flags, "flags", true)
	AssertionIsNumber(startPosition, "startPosition", true)
	AssertionIsTable(config, "config", true)

	config = ConfigNew(config or {})

	local expr, flags, err = compilePattern(expr, flags, config)
	if not expr and err then
		return nil, err
	end

	return _matcher(expr, str, flags, startPosition or 0, config)
end

local getSubstring = function(str, ini, en, flags)
	local isUnicode = false
	if type(flags) == "string" then
		isUnicode = string_find(flags, "u")
	elseif type(flags) == "table" then
		isUnicode = flags[ENUM_FLAG_UNICODE] or flags.u
	end

	if isUnicode then
		local chars = toCharArray(str, true)
		return table_concat(chars, "", ini, en)
	end
	return string_sub(str, ini, en)
end

local assertMatch = function(expr, str, expectedHasMatched, expectedIniStr, expectedEndStr, flags)
	local hasMatched, iniStr, endStr, metadata = matcher(expr, str, flags)
	if (not hasMatched) ~= (not expectedHasMatched) then
		error(string_format(
			"Expected hasMatched=%s for expr='%s', str='%s' but got %s",
			tostring(expectedHasMatched), expr, str, tostring(hasMatched)
		), 2)
	end
	if expectedHasMatched then
		if iniStr ~= expectedIniStr or endStr ~= expectedEndStr then
			error(string_format(
				"Expected span=(%s, %s) but got (%s, %s)",
				tostring(expectedIniStr), tostring(expectedEndStr), tostring(iniStr), tostring(endStr)
			), 2)
		end
	end
end

local assertError = function(expr, str)
	local hasMatched, err = matcher(expr, str)
	if hasMatched ~= nil or type(err) ~= "string" then
		error(string_format("Expected parse error for expr='%s', but got hasMatched=%s", expr, tostring(hasMatched)), 2)
	end
end

local assertCapture = function(expr, str, captureIndex, expectedStr, flags)
	local hasMatched, iniStr, endStr, metadata = matcher(expr, str, flags)
	assert(hasMatched, string_format("Expected match for expr='%s', str='%s'", expr, str))
	if type(captureIndex) == "string" then
		captureIndex = metadata.groupNames[captureIndex] or captureIndex
	end
	local ini = metadata.captureStarts[captureIndex]
	local en  = metadata.captureEnds[captureIndex]
	if type(ini) == "table" then
		ini = ini[#ini]
		en = en[#en]
	end
	assert(ini, string_format("Capture %s not found", tostring(captureIndex)))
	local got = getSubstring(str, ini, en, flags)
	assert(got == expectedStr,
		string_format("Expected capture=%q but got=%q", expectedStr, got))
end

local assertCaptureAbsent = function(expr, str, captureIndex, flags)
	local hasMatched, _, _, metadata = matcher(expr, str, flags)
	assert(hasMatched, string_format("Expected match for expr='%s', str='%s'", expr, str))
	if type(captureIndex) == "string" then
		captureIndex = metadata.groupNames[captureIndex] or captureIndex
	end
	assert(not metadata.captureStarts[captureIndex],
		string_format("Expected capture %s to be absent", tostring(captureIndex)))
end

local assertNoCapture = function(expr, str, flags)
	local hasMatched, _, _, metadata = matcher(expr, str, flags)
	assert(hasMatched, string_format("Expected match for expr='%s', str='%s'", expr, str))
	assert(not next(metadata.captureStarts), "Expected no captures")
end

local assertPositionCapture = function(expr, str, captureIndex, expectedPos, flags)
	local hasMatched, _, _, metadata = matcher(expr, str, flags)
	assert(hasMatched, string_format("Expected match for expr='%s', str='%s'", expr, str))
	local pos = metadata.positionCaptures[captureIndex]
	assert(pos ~= nil, string_format("Position capture %d not found", captureIndex))
	assert(pos == expectedPos, string_format("Expected position capture=%d but got=%d", expectedPos, pos))
end

performance(function()

print("Running matcher tests for core engine...")

describe("Malformed inputs", function()
	it("handles malformed inputs", function()
		local success, err = pcall(matcher, 123, "abc")
		assert(success == false, "Malformed input should return error")
		assert(type(err) == "string", "Malformed input should return error message")

		success, err = pcall(matcher, "abc", 123)
		assert(success == false, "Malformed target string should return error")
		assert(type(err) == "string", "Malformed target string should return error message")
	end)
end)

describe("Literal matching...", function()
	it("Single literal exact", function() assertMatch("a", "a", true, 1, 1) end)
	it("Single literal inside string", function() assertMatch("a", "ba", true, 2, 2) end)
	it("Multiple literals inside string", function() assertMatch("abc", "xyzabcdef", true, 4, 6) end)
	it("Multiple literal mismatch", function() assertMatch("abc", "abx") end)
	it("Literal against empty string", function() assertMatch("abc", "") end)
end)

describe("Wildcard (.) matching...", function()
	-- Wiki: matches any character but EOL, equivalent to [^\r\n]
	it("Wildcard: normal char", function() assertMatch(".", "a", true, 1, 1) end)
	it("Wildcard: tab", function() assertMatch(".", "\t", true, 1, 1) end)
	it("Wildcard: space", function() assertMatch(".", " ", true, 1, 1) end)
	it("Wildcard surrounded by literals", function() assertMatch("a.c", "abc", true, 1, 3) end)
	it("Wildcard does not match newline", function() assertMatch(".", "\n") end)
	it("Wildcard does not match carriage return", function() assertMatch(".", "\r") end)
end)

describe("Escaped literals (%magic)...", function()
	it("Escaped dot matches literal dot", function() assertMatch("%.", "a.c", true, 2, 2) end)
	it("Escaped dot does not match letter", function() assertMatch("%.", "abc") end)
	it("Escaped open paren", function() assertMatch("%(", "a(b", true, 2, 2) end)
	it("Escaped close paren", function() assertMatch("%)", "a)b", true, 2, 2) end)
	it("Escaped open bracket", function() assertMatch("%[", "a[b", true, 2, 2) end)
	it("Escaped plus", function() assertMatch("%+", "a+b", true, 2, 2) end)
	it("Escaped asterisk", function() assertMatch("%*", "a*b", true, 2, 2) end)
	it("Escaped question mark", function() assertMatch("%?", "a?b", true, 2, 2) end)
	it("Escaped percent sign", function() assertMatch("%%", "50%", true, 3, 3) end)
end)

describe("%a -- letters [a-zA-Z]...", function()
	it("%a matches lowercase letter", function() assertMatch("%a", "a", true, 1, 1) end)
	it("%a matches uppercase letter", function() assertMatch("%a", "Z", true, 1, 1) end)
	it("%a does not match digit", function() assertMatch("%a", "1") end)
	it("%a does not match underscore", function() assertMatch("%a", "_") end)
	it("%A matches non-letter", function() assertMatch("%A", "1", true, 1, 1) end)
	it("%A does not match letter", function() assertMatch("%A", "a") end)
end)

describe("%d -- digits [0-9]...", function()
	it("%d matches digit", function() assertMatch("%d", "5", true, 1, 1) end)
	it("%d matches 9", function() assertMatch("%d", "9", true, 1, 1) end)
	it("%d does not match letter", function() assertMatch("%d", "a") end)
	it("%D matches non-digit", function() assertMatch("%D", "a", true, 1, 1) end)
	it("%D does not match digit", function() assertMatch("%D", "5") end)
end)

describe("%h / %x -- hex digits [0-9a-fA-F]...", function()
	it("%h matches '0'", function() assertMatch("%h", "0", true, 1, 1) end)
	it("%h matches '9'", function() assertMatch("%h", "9", true, 1, 1) end)
	it("%h matches 'a'", function() assertMatch("%h", "a", true, 1, 1) end)
	it("%h matches 'f'", function() assertMatch("%h", "f", true, 1, 1) end)
	it("%h matches 'A'", function() assertMatch("%h", "A", true, 1, 1) end)
	it("%h matches 'F'", function() assertMatch("%h", "F", true, 1, 1) end)
	it("%h does not match 'g'", function() assertMatch("%h", "g") end)
	it("%h does not match 'G'", function() assertMatch("%h", "G") end)
	it("%x matches 'f'", function() assertMatch("%x", "f", true, 1, 1) end)
	it("%x does not match 'g'", function() assertMatch("%x", "g") end)
	it("%H matches non-hex", function() assertMatch("%H", "g", true, 1, 1) end)
	it("%H does not match hex digit", function() assertMatch("%H", "f") end)
	it("%X matches non-hex", function() assertMatch("%X", "g", true, 1, 1) end)
	it("%X does not match hex digit", function() assertMatch("%X", "f") end)
end)

describe("%l -- lowercase letters [a-z]...", function()
	it("%l matches lowercase", function() assertMatch("%l", "a", true, 1, 1) end)
	it("%l matches 'z'", function() assertMatch("%l", "z", true, 1, 1) end)
	it("%l does not match uppercase", function() assertMatch("%l", "A") end)
	it("%L matches non-lowercase", function() assertMatch("%L", "A", true, 1, 1) end)
	it("%L does not match lowercase", function() assertMatch("%L", "a") end)
end)

describe("%u -- uppercase letters [A-Z]...", function()
	it("%u matches uppercase", function() assertMatch("%u", "A", true, 1, 1) end)
	it("%u matches 'Z'", function() assertMatch("%u", "Z", true, 1, 1) end)
	it("%u does not match lowercase", function() assertMatch("%u", "a") end)
	it("%U matches non-uppercase", function() assertMatch("%U", "a", true, 1, 1) end)
	it("%U does not match uppercase", function() assertMatch("%U", "A") end)
end)

describe("%w -- word chars [a-zA-Z0-9_]...", function()
	it("%w matches letter", function() assertMatch("%w", "a", true, 1, 1) end)
	it("%w matches uppercase letter", function() assertMatch("%w", "Z", true, 1, 1) end)
	it("%w matches digit", function() assertMatch("%w", "5", true, 1, 1) end)
	it("%w matches underscore", function() assertMatch("%w", "_", true, 1, 1) end)
	it("%w does not match hyphen", function() assertMatch("%w", "-") end)
	it("%W matches non-word char", function() assertMatch("%W", "-", true, 1, 1) end)
	it("%W does not match word char", function() assertMatch("%W", "a") end)
end)

describe("%s -- whitespace [\\f\\n\\r\\t ]...", function()
	it("%s matches space", function() assertMatch("%s", " ", true, 1, 1) end)
	it("%s matches tab", function() assertMatch("%s", "\t", true, 1, 1) end)
	it("%s matches newline", function() assertMatch("%s", "\n", true, 1, 1) end)
	it("%s matches carriage return", function() assertMatch("%s", "\r", true, 1, 1) end)
	it("%s matches form feed", function() assertMatch("%s", "\f", true, 1, 1) end)
	it("%s does not match letter", function() assertMatch("%s", "a") end)
	it("%S matches non-whitespace", function() assertMatch("%S", "a", true, 1, 1) end)
	it("%S does not match space", function() assertMatch("%S", " ") end)
end)

describe("%p -- punctuation...", function()
	it("%p matches '!'", function() assertMatch("%p", "!", true, 1, 1) end)
	it("%p matches '/'", function() assertMatch("%p", "/", true, 1, 1) end)
	it("%p matches ':'", function() assertMatch("%p", ":", true, 1, 1) end)
	it("%p matches '@'", function() assertMatch("%p", "@", true, 1, 1) end)
	it("%p matches '['", function() assertMatch("%p", "[", true, 1, 1) end)
	it("%p matches '`'", function() assertMatch("%p", "`", true, 1, 1) end)
	it("%p matches '{'", function() assertMatch("%p", "{", true, 1, 1) end)
	it("%p matches '~'", function() assertMatch("%p", "~", true, 1, 1) end)
	it("%p does not match letter", function() assertMatch("%p", "a") end)
	it("%p does not match digit", function() assertMatch("%p", "1") end)
	it("%P matches non-punctuation", function() assertMatch("%P", "a", true, 1, 1) end)
	it("%P does not match punctuation", function() assertMatch("%P", "!") end)
end)

describe("%c -- control characters...", function()
	it("%c matches ctrl-A (\\001)", function() assertMatch("%c", "\001", true, 1, 1) end)
	it("%c matches ctrl-Z (\\026)", function() assertMatch("%c", "\026", true, 1, 1) end)
	it("%c does not match 'a'", function() assertMatch("%c", "a") end)
	it("%C matches 'a'", function() assertMatch("%C", "a", true, 1, 1) end)
end)

describe("\xFF -- codepoint escape...", function()
	it("\\x41 matches 'A' (U+0041)", function() assertMatch("\x41", "A", true, 1, 1) end)
	it("\\x41 does not match 'B'", function() assertMatch("\x41", "B") end)
end)

describe("Sets -- basic...", function()
	it("Set: literal match 'a'", function() assertMatch("[abc]", "a", true, 1, 1) end)
	it("Set: literal match 'b'", function() assertMatch("[abc]", "b", true, 1, 1) end)
	it("Set: non-member", function() assertMatch("[abc]", "d") end)
	it("Negated set: non-member matches", function() assertMatch("[^abc]", "d", true, 1, 1) end)
	it("Negated set: member does not match", function() assertMatch("[^abc]", "a") end)
end)

describe("Sets -- ranges...", function()
	it("Set range: lowercase mid", function() assertMatch("[a-z]", "m", true, 1, 1) end)
	it("Set range: range start", function() assertMatch("[a-z]", "a", true, 1, 1) end)
	it("Set range: range end", function() assertMatch("[a-z]", "z", true, 1, 1) end)
	it("Set range: outside range", function() assertMatch("[a-z]", "A") end)
	it("Set range: digit mid", function() assertMatch("[0-9]", "5", true, 1, 1) end)
	it("Set range: letter not in digit range", function() assertMatch("[0-9]", "a") end)
	it("Negated range: uppercase matches", function() assertMatch("[^a-z]", "A", true, 1, 1) end)
	it("Negated range: lowercase does not match", function() assertMatch("[^a-z]", "m") end)
	it("Set: multi-range match", function() assertMatch("[A-Za-z0-9]", "q", true, 1, 1) end)
	it("Set: multi-range non-match", function() assertMatch("[A-Za-z0-9]", "-") end)
end)

describe("Sets -- nested character classes...", function()
	it("Set with %d class: digit", function() assertMatch("[%d]", "5", true, 1, 1) end)
	it("Set with %d class: non-digit", function() assertMatch("[%d]", "a") end)
	it("Set with %w class: underscore", function() assertMatch("[%w]", "_", true, 1, 1) end)
	it("Set with %a and %d: digit", function() assertMatch("[%a%d]", "5", true, 1, 1) end)
	it("Set with %a and %d: letter", function() assertMatch("[%a%d]", "z", true, 1, 1) end)
	it("Set with %a and %d: hyphen", function() assertMatch("[%a%d]", "-") end)
end)

describe("Sets -- compound (ranges + literals + classes)...", function()
	it("Compound set: range + literal underscore", function() assertMatch("[a-z_]", "_", true, 1, 1) end)
	it("Compound set: range matches", function() assertMatch("[a-z_]", "m", true, 1, 1) end)
	it("Compound set: uppercase outside", function() assertMatch("[a-z_]", "A") end)
	it("Compound set: class + range, digit via class", function() assertMatch("[%da-f]", "3", true, 1, 1) end)
	it("Compound set: class + range, letter in range", function() assertMatch("[%da-f]", "e", true, 1, 1) end)
	it("Compound set: class + range, letter outside", function() assertMatch("[%da-f]", "g") end)
	it("Negated compound: non-digit, non-underscore", function() assertMatch("[^%d_]", "a", true, 1, 1) end)
	it("Negated compound: digit excluded", function() assertMatch("[^%d_]", "5") end)
	it("Negated compound: underscore excluded", function() assertMatch("[^%d_]", "_") end)
	it("Compound set: full word chars via ranges", function() assertMatch("[a-zA-Z0-9_]", "_", true, 1, 1) end)
	it("Compound set: hyphen not in word chars", function() assertMatch("[a-zA-Z0-9_]", "-") end)
end)

describe("Alternation | ...", function()
	it("Alternation: first branch", function() assertMatch("a|b", "a", true, 1, 1) end)
	it("Alternation: second branch", function() assertMatch("a|b", "b", true, 1, 1) end)
	it("Alternation: no branch matches", function() assertMatch("a|b", "c") end)
	it("Alternation: multi-char branch", function() assertMatch("cat|dog", "dog", true, 1, 3) end)
	it("Alternation: three branches", function() assertMatch("a|b|c", "c", true, 1, 1) end)
	it("Alternation: empty right branch matches a", function() assertMatch("a|", "a", true, 1, 1) end)
	it("Alternation: empty right branch matches empty string", function() assertMatch("a|", "b", true, 1, 0) end)
	it("Alternation: empty left branch matches empty string before a", function() assertMatch("|a", "a", true, 1, 0) end)
	it("Alternation: middle empty branch matches empty string", function() assertMatch("a||c", "b", true, 1, 0) end)
end)

describe("Quantifiers -- greedy...", function()
	it("Greedy ?: empty match", function() assertMatch("a?", "b", true, 1, 0) end)
	it("Greedy ?: matches 1", function() assertMatch("a?", "a", true, 1, 1) end)
	it("Greedy ?: matches 1 out of many", function() assertMatch("a?", "aa", true, 1, 1) end)
	it("Greedy *: empty match", function() assertMatch("a*", "b", true, 1, 0) end)
	it("Greedy *: matches 1", function() assertMatch("a*", "a", true, 1, 1) end)
	it("Greedy *: matches all", function() assertMatch("a*", "aaa", true, 1, 3) end)
	it("Greedy +: requires 1", function() assertMatch("a+", "b") end)
	it("Greedy +: matches 1", function() assertMatch("a+", "a", true, 1, 1) end)
	it("Greedy +: matches all", function() assertMatch("a+", "aaa", true, 1, 3) end)
	it("Greedy {2}: requires 2", function() assertMatch("a{2}", "a") end)
	it("Greedy {2}: matches 2", function() assertMatch("a{2}", "aa", true, 1, 2) end)
	it("Greedy {2}: matches exactly 2", function() assertMatch("a{2}", "aaa", true, 1, 2) end)
	it("Greedy {2,4}: requires 2", function() assertMatch("a{2,4}", "a") end)
	it("Greedy {2,4}: matches 2", function() assertMatch("a{2,4}", "aa", true, 1, 2) end)
	it("Greedy {2,4}: matches up to 4", function() assertMatch("a{2,4}", "aaaaa", true, 1, 4) end)
	it("Greedy {2,}: requires 2", function() assertMatch("a{2,}", "a") end)
	it("Greedy {2,}: matches all >= 2", function() assertMatch("a{2,}", "aaaaa", true, 1, 5) end)
end)

describe("Quantifiers -- lazy...", function()
	it("Lazy ??: empty match favored", function() assertMatch("a??", "a", true, 1, 0) end)
	it("Lazy ??: matches 1 to satisfy rest", function() assertMatch("a??a", "a", true, 1, 1) end)
	it("Lazy *?: empty match favored", function() assertMatch("a*?", "aaa", true, 1, 0) end)
	it("Lazy *?: matches enough to satisfy rest", function() assertMatch("a*?a", "aaa", true, 1, 1) end)
	it("Lazy +?: matches exactly 1", function() assertMatch("a+?", "aaa", true, 1, 1) end)
	it("Lazy +?: matches enough to satisfy rest", function() assertMatch("a+?a", "aaa", true, 1, 2) end)
	it("Lazy {2,4}?: matches exactly 2", function() assertMatch("a{2,4}?", "aaaa", true, 1, 2) end)
end)

describe("Quantifiers -- possessive...", function()
	it("Possessive ?+: no backtrack, fails rest", function() assertMatch("a?+a", "a") end)
	it("Possessive *+: consumes all, fails rest", function() assertMatch("a*+a", "aaa") end)
	it("Possessive ++: consumes all, fails rest", function() assertMatch("a++a", "aaa") end)
end)

describe("Quantifiers -- backtracking edge cases...", function()
	-- greedy backtracks to let 'c' match
	it("Greedy *: backtracks to match 'c'", function() assertMatch(".*c", "abcc", true, 1, 4) end)
	-- lazy expands to let 'c' match
	it("Lazy *?: expands to match 'c'", function() assertMatch(".*?c", "abcc", true, 1, 3) end)
	-- possessive does not backtrack
	it("Possessive *+: fails to backtrack for 'c'", function() assertMatch(".*+c", "abcc") end)
	-- nested quantifier: inner + must backtrack when outer continuation needs chars
	it("Nested quantifiers: inner + backtracks for trailing literal", function() assertMatch("(a+)+a", "aaaaa", true, 1, 5) end)
	it("Nested quantifiers: minimal inner match + literal", function() assertMatch("(a+)+a", "aa", true, 1, 2) end)
	it("Nested quantifiers: single a cannot satisfy trailing a", function() assertMatch("(a+)+a", "a") end)
	-- others
	it("Optional elements: group matches shortest valid variant", function() assertMatch("a(b?c?a)te", "abacate", true, 3, 7) end)
	it("Repeated group: optional elements across iterations", function() assertMatch("a?((b?c?)a)+", "abacate", true, 1, 5) end)
	it("Repeated optional elements with trailing literal", function() assertMatch("(b?c?a)+te", "abacate", true, 1, 7) end)
	it("Repeated optional character sequence", function() assertMatch("(b?c?t?a?)+", "abacate", true, 1, 6) end)
	it("Repeated optional character sequence two", function() assertMatch("(b?c?a?)+", "abacate", true, 1, 5) end)
	it("Nested optional quantifiers", function() assertMatch("(x?)?", "x", true, 1, 1) end)
	it("Repeated character class group", function() assertMatch("a([bc]a)+", "abacate", true, 1, 5) end)
	it("Repeated character class group without prefix", function() assertMatch("([bc]a)+", "abacate", true, 2, 5) end)
	it("Repeated character class group with optional suffix", function() assertMatch("a([bct]a?)+", "abacate", true, 1, 6) end)
	it("Repeated character class group with optional suffix two", function() assertMatch("([bct]a?)+", "abacate", true, 2, 6) end)
	it("Lazy repetition of character class group", function() assertMatch("([bct]a?)+?", "abacate", true, 2, 3) end)
	it("Repeated character class with trailing literal", function() assertMatch("([abc])*d", "abbbcd", true, 1, 6) end)
	it("Repeated character class backtracks for trailing literal", function() assertMatch("([abc])*bcd", "abcd", true, 1, 4) end)
	it("Repeated negated character class", function() assertMatch("([^N]*N)+", "abNNxyzN", true, 1, 8) end)
	it("Repeated negated character class with partial match", function() assertMatch("([^N]*N)+", "abNNxyz", true, 1, 4) end)
	it("Greedy quantifier: finds longest valid match", function()
		assertMatch("aba(c+)ate", "abacccccccccccaty ou abaccccccate?", true, 22, 33)
	end)
	it("Nested quantified groups with heavy backtracking", function()
		assertMatch("(ab?(cd?e)*f)+.", "ldskfsdpkabcdefacdefacefacdececdecefasjdoasdi", true, 10, 37)
	end)
	it("Nested quantified groups with partition backtracking", function()
		assertMatch("(a+b+)+(a+b+)+a", "abbbbbbbcaaaaaaaaaaaaabaaaaba", true, 10, 29)
	end)
	it("Group with inner quantifier: reduce outer count to find match", function()
		assertMatch("([^/]*/)*sub1/", "d:msgs/tdir/sub1/trial/away.cpp", true, 1, 17)
	end)
end)

describe("Quantifiers -- inside alternations...", function()
	it("Alternation: quantified right branch", function() assertMatch("a|b+", "bb", true, 1, 2) end)
	it("Alternation: quantified left branch", function() assertMatch("a+|b", "aa", true, 1, 2) end)
	it("Alternation: complex quantified left branch", function() assertMatch("a.*b|c", "axxb", true, 1, 4) end)
	it("Alternation: complex left branch fails, right branch matches", function() assertMatch("a.*b|c", "c", true, 1, 1) end)
	it("Alternation: complex right branch matches", function() assertMatch("a|b.*c", "bxxxc", true, 1, 5) end)
	it("Alternation: complex right branch fails, left branch matches", function() assertMatch("a|b.*c", "a", true, 1, 1) end)
	it("Alternation: full branch backtrack with quantifiers", function() assertMatch("a.*b|a.*c", "ac", true, 1, 2) end)
end)

describe("Capturing groups (...)...", function()
	it("Group: single char", function() assertMatch("(a)", "a", true, 1, 1) end)
	it("Group: then literal", function() assertMatch("(ab)c", "abc", true, 1, 3) end)
	it("Group: in the middle", function() assertMatch("a(b)c", "abc", true, 1, 3) end)
	it("Group: searched string", function() assertMatch("(abc)", "xabc", true, 2, 4) end)
	it("Capture 1: single char", function() assertCapture("(a)", "a", 1, "a") end)
	it("Capture 1: two chars", function() assertCapture("(ab)", "xaby", 1, "ab") end)
	it("Capture 1: middle char", function() assertCapture("a(b)c", "abc", 1, "b") end)
	it("Capture 1 of 3", function() assertCapture("(a)(b)(c)", "abc", 1, "a") end)
	it("Capture 2 of 3", function() assertCapture("(a)(b)(c)", "abc", 2, "b") end)
	it("Capture 3 of 3", function() assertCapture("(a)(b)(c)", "abc", 3, "c") end)
	it("Deeply nested optional groups", function()
		assertMatch("((((((((((((((((((((((((((((((((((.)?))))))))))))))))))))))))))?)))))))", ".", true, 1, 1)
	end)
	it("Nested captures with position captures", function() assertMatch(".?((a+()(((b+)))()))().?", "aaacbab", true, 5, 7) end)
	it("Nested quantified groups with position capture", function() assertMatch("(x+x+)+()y", "xxxxxxxxxxy", true, 1, 11) end)
	it("Repeated non-capturing group with inner capture", function() assertMatch("(?:b?c?t?(a?))+", "abacate", true, 1, 6) end)
end)

describe("Non-capturing groups (?:...)...", function()
	it("Non-cap group: then literal", function() assertMatch("(?:ab)c", "abc", true, 1, 3) end)
	it("Non-cap group: with quantifier", function() assertMatch("(?:a)+", "aaa", true, 1, 3) end)
	it("Non-cap group: creates no capture", function() assertNoCapture("(?:ab)c", "abc") end)
	it("Quoted string with escaped quote support", function() assertMatch("\"(?:\\\\\"|[^\"])*?\"", "\"\"\"", true, 1, 2) end)
end)

describe("Named capturing groups (?<name>...)...", function()
	it("Named group: then literal", function() assertMatch("(?<foo>ab)c", "abc", true, 1, 3) end)
	it("Named group captures correctly", function() assertCapture("(?<foo>ab)c", "abc", "foo", "ab") end)
	it("Multiple named groups capture respective substrings", function()
		local hasMatched, _, _, metadata = matcher("(?<first>[a-z]+)_(?<second>[a-z]+)", "hello_world")
		assert(hasMatched, "Named groups: expected match")
		local firstIdx = metadata.groupNames["first"]
		local secondIdx = metadata.groupNames["second"]
		local firstStart = metadata.captureStarts[firstIdx]
		local firstEnd = metadata.captureEnds[firstIdx]
		local secondStart = metadata.captureStarts[secondIdx]
		local secondEnd = metadata.captureEnds[secondIdx]
		if type(firstStart) == "table" then
			firstStart = firstStart[#firstStart]
			firstEnd = firstEnd[#firstEnd]
			secondStart = secondStart[#secondStart]
			secondEnd = secondEnd[#secondEnd]
		end
		assert(getSubstring("hello_world", firstStart, firstEnd) == "hello", "Named capture 'first' should be 'hello'")
		assert(getSubstring("hello_world", secondStart, secondEnd) == "world", "Named capture 'second' should be 'world'")
	end)
end)

describe("Backreferences (%1, %k<name>)...", function()
	it("Backreference %1: repeated char", function() assertMatch("(a)%1", "aa", true, 1, 2) end)
	it("Backreference %1: no match on diff", function() assertMatch("(a)%1", "ab") end)
	it("Backreference %1: two-char repeat", function() assertMatch("(ab)%1", "abab", true, 1, 4) end)
	it("Backreference: repeated word", function() assertMatch("([a-z]+)_%1", "cat_cat", true, 1, 7) end)
	it("Backreference: different words", function() assertMatch("([a-z]+)_%1", "cat_dog") end)
	it("Named backreference %k<name>: matches identical words, rejects different words", function()
		local hasMatched, matchStart, matchEnd = matcher("(?<w>[a-z]+)_%k<w>", "hello_hello")
		assert(hasMatched, "Named backreference: expected match")
		assert(matchStart == 1 and matchEnd == 11, "Named backreference: expected full span")
		hasMatched = matcher("(?<w>[a-z]+)_%k<w>", "hello_world")
		assert(not hasMatched, "Named backreference: different words should not match")
	end)
	it("Access 15th capture via %k<15>", function()
		assertMatch("(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)(.)%k<15>", "abcdefghijklmnoo", true, 1, 16)
	end)
end)

describe("Inline comments (?#...)...", function()
	it("Comment: transparent", function() assertMatch("a(?#hello)b", "ab", true, 1, 2) end)
	it("Comment: leading", function() assertMatch("(?#skip)abc", "abc", true, 1, 3) end)
end)

describe("Position capture ()...", function()
	-- () captures the current string position (1-based), just like Lua's ()
	it("Position capture: empty match", function() assertMatch("()", "abc", true, 1, 0) end)
	it("Position capture: after 'a'", function() assertMatch("a()", "abc", true, 1, 1) end)
	it("Position capture: after 'ab'", function() assertMatch("ab()", "abc", true, 1, 2) end)
	it("Position 1: at start of string (1-based)", function() assertPositionCapture("()", "abc", 1, 1) end)
	it("Position 1: after first char", function() assertPositionCapture("a()", "abc", 1, 2) end)
	it("Position 1: after two chars", function() assertPositionCapture("ab()", "abc", 1, 3) end)
	it("Two positions: first at start", function() assertPositionCapture("()a()", "abc", 1, 1) end)
	it("Two positions: second after 'a'", function() assertPositionCapture("()a()", "abc", 2, 2) end)
	it("Position inside a capturing group: index is 1 (first pos capture)", function()
		assertPositionCapture("(a()b)", "ab", 1, 2)
	end)
	it("Position at start and end: first", function() assertPositionCapture("()abc()", "abc", 1, 1) end)
	it("Position at start and end: second", function() assertPositionCapture("()abc()", "abc", 2, 4) end)
	-- () must NOT consume a numbered capture slot; %1 should reference the first string capture
	it("Position capture: does not consume %1 slot", function() assertMatch("()(a)%1", "aa", true, 1, 2) end)
	it("Position capture: %1 refers to first string capture (a)", function() assertCapture("()(a)%1", "aa", 1, "a")  end)
	it("Position capture in middle: %2 refers to (b), not ()", function() assertMatch("(a)()(b)%2", "abb", true, 1, 3) end)
	it("Position capture in middle: %2 is (b)", function() assertCapture("(a)()(b)%2", "abb", 2, "b") end)
end)

describe("Groups + Alternation (backtracking)...", function()
	it("Group alternation: second branch", function() assertMatch("(a|b)", "b", true, 1, 1) end)
	it("Group alternation: with continuation", function() assertMatch("(a|b)c", "bc", true, 1, 2) end)
	it("Group alternation: backtrack into group", function() assertMatch("(ab|a)bc", "abc", true, 1, 3) end)
	it("Group alternation: capture is the matched branch", function() assertCapture("(ab|a)bc", "abc", 1, "a") end)
	it("Group alternation: multi-char branch", function() assertMatch("(cat|dog)s", "dogs", true, 1, 4) end)
end)

describe("Groups + Quantifiers...", function()
	it("Group quantifier: greedy +", function() assertMatch("(a)+", "aaa", true, 1, 3) end)
	it("Group quantifier: two-char greedy +", function() assertMatch("(ab)+", "abab", true, 1, 4) end)
	it("Non-cap group quantifier: +", function() assertMatch("(?:ab)+", "abab", true, 1, 4) end)
	it("Group quantifier: capture is last iteration", function() assertCapture("(a)+", "aaa", 1, "a") end)
end)

describe("Assertions -- Anchors ^ and $...", function()
	it("Start anchor ^: matches at start", function() assertMatch("^abc", "abc", true, 1, 3) end)
	it("Start anchor ^: fails if not at start", function() assertMatch("^abc", "xabc") end)
	it("End anchor $: matches at end", function() assertMatch("abc$", "abc", true, 1, 3) end)
	it("End anchor $: fails if not at end", function() assertMatch("abc$", "abcx") end)
	it("Anchors with alternates: matches ac", function() assertMatch("^(a|b)c$", "ac", true, 1, 2) end)
	it("Anchors with alternates: matches bc", function() assertMatch("^(a|b)c$", "bc", true, 1, 2) end)
	it("Anchors with alternates: fails start anchor", function() assertMatch("^(a|b)c$", "xac") end)
	it("Anchors with alternates: fails end anchor", function() assertMatch("^(a|b)c$", "acx") end)
	it("Anchors with groups: matches", function() assertMatch("^(?:a+b)c$", "aabc", true, 1, 4) end)
	it("Anchors inside groups: fails because $ is followed by c", function() assertMatch("^a(b$)c", "abc") end)
	it("Anchors inside groups: matches", function() assertMatch("^a(b$)", "ab", true, 1, 2) end)
	it("Anchors with alternations at end: matches ab", function() assertMatch("^a(b|c)$", "ab", true, 1, 2) end)
	it("Anchors with alternations at end: matches ac", function() assertMatch("^a(b|c)$", "ac", true, 1, 2) end)
	it("Anchors with multiple alternations: matches ad", function() assertMatch("^(a|b)(c|d)$", "ad", true, 1, 2) end)
	it("Start anchor inside group alternate: matches start", function() assertMatch("(^|b)c", "c", true, 1, 1) end)
	it("Start anchor inside group alternate: matches literal", function() assertMatch("(^|b)c", "bc", true, 1, 2) end)
	it("Start anchor inside group alternate: fails", function() assertMatch("(^|b)c", "xc") end)
	it("End anchor inside group alternate: matches end", function() assertMatch("a($|b)", "a", true, 1, 1) end)
	it("End anchor inside group alternate: matches literal", function() assertMatch("a($|b)", "ab", true, 1, 2) end)
	it("End anchor inside group alternate: fails", function() assertMatch("a($|b)", "ax") end)
end)

describe("Assertions -- Boundaries %f and %F...", function()
	it("Frontier boundary %f: letter to digit", function() assertMatch("a%f[%d]1", "a1", true, 1, 2) end)
	it("Frontier boundary %f: fails letter to letter", function() assertMatch("a%f[%d]b", "ab") end)
	it("Frontier boundary %f: string start to digit", function() assertMatch("%f[%d]1", "1", true, 1, 1) end)
	it("Non-frontier boundary %F: letter to letter", function() assertMatch("a%F[%d]b", "ab", true, 1, 2) end)
	it("Non-frontier boundary %F: fails letter to digit", function() assertMatch("a%F[%d]1", "a1") end)
	it("Frontier boundary %f[%w]: word to non-word", function() assertMatch("a%f[%w]", "a!", true, 1, 1) end)
	it("Frontier boundary %f[%w]: non-word to word", function() assertMatch("%f[%w]a", " a", true, 2, 2) end)
end)

describe("Assertions -- Balanced Match %bxy...", function()
	it("Balanced match %b(): nested parentheses", function() assertMatch("%b()", "(a(b)c)", true, 1, 7) end)
	it("Balanced match %b{}: nested curly braces", function() assertMatch("%b{}", "{abc{def}}", true, 1, 10) end)
	it("Balanced match %b(): unclosed", function() assertMatch("%b()", "(ab") end)
	it("Balanced match %b(): within string", function() assertMatch("x%b()y", "x(a)y", true, 1, 5) end)
	it("Balanced match %b(): quantified", function() assertMatch("%b()+", "(a)(b)", true, 1, 6) end)
	it("Balanced match %b(): optional", function() assertMatch("%b()?", "(a)", true, 1, 3) end)
end)

describe("Assertions -- Positive Lookahead...", function()
	it("Positive lookahead: matches", function() assertMatch("a(?=b)b", "ab", true, 1, 2) end)
	it("Positive lookahead: fails", function() assertMatch("a(?=b)c", "abc") end)
	it("Lookahead with set: matches before digit", function() assertMatch("a(?=[0-9])", "a1", true, 1, 1) end)
	it("Lookahead with set: fails before letter", function() assertMatch("a(?=[0-9])", "ab") end)
	it("Lookahead with greedy quantifier: matches", function() assertMatch("a(?=b+c)b", "abbbc", true, 1, 2) end)
	it("Lookahead with range quantifier: matches", function() assertMatch("a(?=b{2,3}c)b", "abbc", true, 1, 2) end)
	it("Lookahead with alternate: matches branch 1", function() assertMatch("a(?=b|c)", "ab", true, 1, 1) end)
	it("Lookahead with alternate: matches branch 2", function() assertMatch("a(?=b|c)", "ac", true, 1, 1) end)
	it("Lookahead with start anchor outside: matches", function() assertMatch("^(?=a)a", "ab", true, 1, 1) end)
	it("Lookahead with start anchor inside: matches", function() assertMatch("(?=^a)a", "ab", true, 1, 1) end)
	it("Lookahead with end anchor inside: matches", function() assertMatch("a(?=b$)", "ab", true, 1, 1) end)
	it("Lookahead with group: matches", function() assertMatch("a(?=(b))", "ab", true, 1, 1) end)
	it("Lookahead with group: captures inside lookahead", function() assertCapture("a(?=(b))", "ab", 1, "b") end)
	it("Quantifier outside positive lookahead: greedy +", function() assertMatch("(?=a)+a", "a", true, 1, 1) end)
	it("Quantifier outside positive lookahead: greedy *", function() assertMatch("(?=a)*a", "a", true, 1, 1) end)
	it("Quantifier outside positive lookahead: greedy ?", function() assertMatch("(?=a)?a", "a", true, 1, 1) end)
	it("Quantifier outside positive lookahead with ?: fallback matching", function() assertMatch("a(?=b)?(b|c)", "ac", true, 1, 2) end)
	it("Consecutive positive lookaheads: matches", function() assertMatch("(?=a)(?=ab)abc", "abc", true, 1, 3) end)
	it("Nested positive lookaheads: matches", function() assertMatch("(?=(?=a)a)a", "a", true, 1, 1) end)
	it("Lookahead with group and backreference: matches", function() assertMatch("(?=(a))%1", "a", true, 1, 1) end)
	it("Lookahead with group and backreference: fails", function() assertMatch("(?=(a))%1", "b") end)

end)

describe("Assertions -- Negative Lookahead...", function()
	it("Negative lookahead: matches", function() assertMatch("a(?!b)c", "ac", true, 1, 2) end)
	it("Negative lookahead: fails", function() assertMatch("a(?!b)b", "ab") end)
	it("Negative lookahead with set: matches before letter", function() assertMatch("a(?![0-9])", "ab", true, 1, 1) end)
	it("Negative lookahead with set: fails before digit", function() assertMatch("a(?![0-9])", "a1") end)
	it("Negative lookahead with anchor: matches when not at end", function() assertMatch("a(?!b$)", "abc", true, 1, 1) end)
	it("Negative lookahead with anchor: fails at end", function() assertMatch("a(?!b$)", "ab") end)
	it("Negative lookahead: matches at end of string", function() assertMatch("a(?!b)", "a", true, 1, 1) end)
	it("Quantifier outside negative lookahead: greedy +", function() assertMatch("(?!a)+b", "b", true, 1, 1) end)
	it("Consecutive negative lookaheads: matches", function() assertMatch("(?!a)(?!c)b", "b", true, 1, 1) end)
	it("Consecutive negative lookaheads: fails (first fails)", function() assertMatch("(?!a)(?!c)b", "a") end)
	it("Consecutive negative lookaheads: fails first position but matches later", function()
		assertMatch("(?!a)(?!c)b", "cb", true, 2, 2)
	end)
	it("Nested negative lookaheads: matches", function() assertMatch("(?!(?!a)b)c", "c", true, 1, 1) end)
	it("Nested negative lookaheads: fails", function() assertMatch("(?!(?!a)b)b", "ab") end)
	it("Negative lookahead with group and backreference: fails (uncaptured group)", function() assertMatch("(?!(a))%1", "b") end)

end)

describe("Assertions -- Positive Lookbehind...", function()
	it("Positive lookbehind: matches", function() assertMatch("(?<=a)b", "ab", true, 2, 2) end)
	it("Positive lookbehind: fails", function() assertMatch("(?<=a)b", "xb") end)
	it("Positive lookbehind length > 1: matches", function() assertMatch("(?<=ab)c", "abc", true, 3, 3) end)
	it("Lookbehind with set: matches after letter", function() assertMatch("(?<=[a-z])1", "a1", true, 2, 2) end)
	it("Lookbehind with set: fails after uppercase", function() assertMatch("(?<=[a-z])1", "A1") end)
	it("Lookbehind with fixed quantifier: matches", function() assertMatch("(?<=a{3})b", "aaab", true, 4, 4) end)
	it("Lookbehind with fixed quantifier: fails (too few)", function() assertMatch("(?<=a{3})b", "aab") end)
	it("Lookbehind with variable quantifier +: parse error", function() assertError("(?<=a+)b", "ab") end)
	it("Lookbehind with variable quantifier *: parse error", function() assertError("(?<=a*)b", "ab") end)
	it("Lookbehind with variable quantifier ?: parse error", function() assertError("(?<=a?)b", "ab") end)
	it("Lookbehind with unequal-length alternate: parse error", function() assertError("(?<=a|bb)c", "abc") end)
	it("Lookbehind with valid fixed-length alternate: matches branch 1", function() assertMatch("(?<=ab|cd)e", "abe", true, 3, 3) end)
	it("Lookbehind with valid fixed-length alternate: matches branch 2", function() assertMatch("(?<=ab|cd)e", "cde", true, 3, 3) end)
	it("Lookbehind with alternate: matches branch 1", function() assertMatch("(?<=a|b)c", "ac", true, 2, 2) end)
	it("Lookbehind with alternate: matches branch 2", function() assertMatch("(?<=a|b)c", "bc", true, 2, 2) end)
	it("Lookbehind with alternate: fails", function() assertMatch("(?<=a|b)c", "xc") end)
	it("Lookbehind with start anchor inside: matches", function() assertMatch("(?<=^a)b", "ab", true, 2, 2) end)
	it("Lookbehind with start anchor inside: fails because not at start", function() assertMatch("(?<=^a)b", "xab") end)
	it("Lookbehind with group: matches", function() assertMatch("(?<=(a))b", "ab", true, 2, 2) end)
	it("Lookbehind with group: captures inside lookbehind", function() assertCapture("(?<=(a))b", "ab", 1, "a") end)
	it("Quantifier outside positive lookbehind: greedy +", function() assertMatch("(?<=a)+b", "ab", true, 2, 2) end)
	it("Consecutive positive lookbehinds: matches", function() assertMatch("(?<=ab)(?<=b)c", "abc", true, 3, 3) end)
	it("Consecutive positive lookbehinds: fails (first fails)", function() assertMatch("(?<=ab)(?<=b)c", "xbc") end)
	it("Nested positive lookbehinds: matches", function() assertMatch("(?<=(?<=a)b)c", "abc", true, 3, 3) end)
	it("Lookbehind with group and backreference: matches", function() assertMatch("(?<=(a))%1", "aa", true, 2, 2) end)
	it("Lookbehind with group and backreference: fails", function() assertMatch("(?<=(a))%1", "ab") end)
	it("Lookbehind after lazy repetition", function() assertMatch("([ab]*?)(?<=(b))c", "abc", true, 1, 3) end)
end)

describe("Assertions -- Negative Lookbehind...", function()
	it("Negative lookbehind: matches", function() assertMatch("(?<!a)b", "xb", true, 2, 2) end)
	it("Negative lookbehind: fails", function() assertMatch("(?<!a)b", "ab") end)
	it("Negative lookbehind with alternate: matches branch 1", function() assertMatch("(?<!a|b)c", "xc", true, 2, 2) end)
	it("Negative lookbehind with alternate: fails branch 1", function() assertMatch("(?<!a|b)c", "ac") end)
	it("Negative lookbehind with alternate: fails branch 2", function() assertMatch("(?<!a|b)c", "bc") end)
	it("Negative lookbehind with variable quantifier +: parse error", function() assertError("(?<!a+)b", "ab") end)
	it("Negative lookbehind with variable quantifier *: parse error", function() assertError("(?<!a*)b", "ab") end)
	it("Negative lookbehind with unequal-length alternate: parse error", function() assertError("(?<!a|bb)c", "abc") end)
	it("Quantifier outside negative lookbehind: greedy +", function() assertMatch("(?<!a)+b", "b", true, 1, 1) end)
	it("Consecutive negative lookbehinds: matches", function() assertMatch("(?<!a)(?<!b)c", "c", true, 1, 1) end)
	it("Consecutive negative lookbehinds: fails (first fails)", function() assertMatch("(?<!a)(?<!b)c", "ac") end)
	it("Nested lookbehinds (negative outer): matches", function() assertMatch("(?<!(?<=a)b)c", "c", true, 1, 1) end)
	it("Nested lookbehinds (negative outer): fails", function() assertMatch("(?<!(?<=a)b)c", "abc") end)
end)

describe("Flags -- i (Case Insensitive)...", function()
	it("Global i flag: literal matches", function() assertMatch("abc", "ABC", true, 1, 3, "i") end)
	it("Global i flag: set range matches", function() assertMatch("[a-c]", "B", true, 1, 1, "i") end)
	it("Global i flag: set range fails", function() assertMatch("[x-z]", "B", nil, nil, nil, "i") end)
	it("Inline toggle i flag: matches", function() assertMatch("a(?i)bc", "aBC", true, 1, 3) end)
	it("Inline toggle and disable i flag: matches", function() assertMatch("(?i)a(?-i)b", "Ab", true, 1, 2) end)
	it("Inline toggle and disable i flag: fails on disabled part", function() assertMatch("(?i)a(?-i)b", "AB") end)
	it("Scoped inline i flag: matches", function() assertMatch("a(?i:b)c", "aBc", true, 1, 3) end)
	it("Scoped inline i flag: fails outside scope", function() assertMatch("a(?i:b)c", "aBC") end)
end)

describe("Flags -- m (Multiline)...", function()
	it("Global m flag: ^ matches after newline", function() assertMatch("^b", "a\nb", true, 3, 3, "m") end)
	it("Without m flag: ^ fails after newline", function() assertMatch("^b", "a\nb") end)
	it("Global m flag: $ matches before newline", function() assertMatch("a$", "a\nb", true, 1, 1, "m") end)
	it("Without m flag: $ fails before newline", function() assertMatch("a$", "a\nb") end)
	it("Inline m flag: matches", function() assertMatch("a\n(?m)^b", "a\nb", true, 1, 3) end)
	it("Scoped m flag: matches", function() assertMatch("(?m:^b)", "a\nb", true, 3, 3) end)
end)

describe("Flags -- s (DotAll)...", function()
	it("Global s flag: . matches newline", function() assertMatch("a.b", "a\nb", true, 1, 3, "s") end)
	it("Without s flag: . fails on newline", function() assertMatch("a.b", "a\nb") end)
	it("Scoped s flag: matches", function() assertMatch("a(?s:.)b", "a\nb", true, 1, 3) end)
	it("Inline toggle s flag with scoped disable: fails on newline", function() assertMatch("(?s)a(?-s:.)b", "a\nb") end)
end)

describe("Flags -- n (No Auto-Capture)...", function()
	it("Global n flag: matches", function() assertMatch("(a)", "a", true, 1, 1, "n") end)
	it("Global n flag: standard group does not capture", function() assertNoCapture("(a)", "a", "n") end)
	it("Scoped n flag: matches", function() assertMatch("(?n:(a))", "a", true, 1, 1) end)
	it("Scoped n flag: standard group does not capture", function() assertNoCapture("(?n:(a))", "a") end)
	it("Inline n flag: matches named group", function() assertMatch("(?n)(?<foo>a)", "a", true, 1, 1) end)
	it("Inline n flag: named group still captures", function() assertCapture("(?n)(?<foo>a)", "a", "foo", "a") end)
end)

describe("Flags -- Complex Modifiers & Edge Cases...", function()
	it("Multiple toggles: parses without error", function() assertMatch("(?im-s)", "", true, 1, 0) end)
	it("Nested scopes with disables: matches", function() assertMatch("(?i:a(?-i:b)c)", "AbC", true, 1, 3) end)
	it("Nested scopes with disables: fails correctly", function() assertMatch("(?i:a(?-i:b)c)", "ABC") end)
	it("Invalid inline flag: parse error", function() assertError("(?z)", "") end)
	it("Empty scoped inline flag: matches empty string", function() assertMatch("(?i-m:)", "", true, 1, 0) end)
end)

describe("Advanced Groups -- Atomic (?>...)...", function()
	-- Basic behavior
	it("Atomic: simple match", function() assertMatch("(?>a)b", "ab", true, 1, 2) end)
	it("Atomic: literal match", function() assertMatch("(?>ab)", "ab", true, 1, 2) end)
	it("Atomic: alternation commits to first match", function() assertMatch("a(?>bc|b)c", "abcc", true, 1, 4) end)
	it("Atomic: prevents backtracking into alternation", function() assertMatch("a(?>bc|b)c", "abc") end)
	it("Atomic: quantifier inside group prevents backtracking", function() assertMatch("(?>a+)a", "aa") end)
	it("Atomic: zero-or-more inside, cannot backtrack", function() assertMatch("(?>a*)a", "a") end)
	-- Quantifiers on the atomic group itself
	it("Atomic: outer * can backtrack on repetition count", function() assertMatch("(?>a)*a", "a", true, 1, 1) end)
	it("Atomic: outer + repeats", function() assertMatch("(?>a)+", "aaa", true, 1, 3) end)
	it("Atomic: quantifier inside and outside", function() assertMatch("(?>a+)+", "aaa", true, 1, 3) end)
	it("Atomic: zero-or-more inside, plus outside", function() assertMatch("(?>a*)+", "aaa", true, 1, 3) end)
	it("Atomic: exact count quantifier", function() assertMatch("(?>a){2}", "aa", true, 1, 2) end)
	it("Atomic: exact count quantifier fail", function() assertMatch("(?>a){2}", "a") end)
	it("Atomic: commits to bc, c after matches", function() assertMatch("a(?>bc|b)c", "abcc", true, 1, 4) end)
	it("Atomic: commits to bc, no c left after", function() assertMatch("a(?>bc|b)c", "abc") end)
	it("Non-atomic control: backtracks to b, c matches", function() assertMatch("a(?:bc|b)c", "abc", true, 1, 3) end)
	-- Capturing inside atomic groups (atomic is non-capturing itself, but inner groups can capture)
	it("Atomic: inner capture, backref to it (group 1 = 'aa', %1 needs 'aa' but only 'a' left)", function()
		assertMatch("((?>a+))%1", "aaa")
	end)
	it("Atomic: inner capture backref succeeds", function() assertMatch("((?>a))%1", "aa", true, 1, 2) end)
	it("Atomic: inner capture backref fails on mismatch", function() assertMatch("((?>a))%1", "ab") end)
	it("Atomic: inner group captures committed value (cat)", function() assertCapture("((?>cat|ca))t", "catt", 1, "cat") end)
	it("Atomic: commits to cat, no t left", function() assertMatch("((?>cat|ca))t", "cat") end)
	it("Atomic: commits to cat, t follows", function() assertMatch("((?>cat|ca))t", "catt", true, 1, 4) end)
	-- Nested atomic
	it("Atomic: nested atomic groups", function() assertMatch("(?>.(?>b+))c", "abbc", true, 1, 4) end)
	it("Atomic: nested atomic, single b", function() assertMatch("(?>.(?>b+))c", "abc", true, 1, 3) end)
end)

describe("Advanced Groups -- Branch Reset (?|...)...", function()
	-- Basic non-match
	it("Branch reset: f fails", function() assertMatch("(?|(a)|(b)(c)|(d))e(f)", "ae") end)
	-- Capture alignment: branch with 2 groups
	it("Capture alignment: branch with 2 groups", function()
		local hasMatched, _, _, metadata = matcher("(?|(a)|(b)(c)|(d))e(f)", "bcef")
		assert(hasMatched, "Branch reset: bcef should match")
		-- b=group1, c=group2. outer f=group3 (max inside was 2)
		assert(metadata.captureStarts[1][1] == 1, "Branch reset bcef: group1 init=1")
		assert(metadata.captureStarts[2][1] == 2, "Branch reset bcef: group2 init=2")
		assert(metadata.captureStarts[3][1] == 4, "Branch reset bcef: group3 init=4")
	end)
	-- Capture alignment: branch with 1 group (shorter branch)
	it("Capture alignment: branch with 1 group (shorter branch)", function()
		local hasMatched, _, _, metadata = matcher("(?|(a)|(b)(c)|(d))e(f)", "def")
		assert(hasMatched, "Branch reset: def should match")
		assert(metadata.captureStarts[1][1] == 1, "Branch reset def: group1=d")
		assert(not metadata.captureStarts[2], "Branch reset def: group2 is nil")
		assert(metadata.captureStarts[3][1] == 3, "Branch reset def: group3=f")
	end)
	-- Backreferences inside branch reset
	it("Branch reset: backref %1 to first branch", function() assertMatch("(?|(a)|(b))%1", "aa", true, 1, 2) end)
	it("Branch reset: backref %1 to second branch", function() assertMatch("(?|(a)|(b))%1", "bb", true, 1, 2) end)
	it("Branch reset: backref %1 fails on mismatch", function() assertMatch("(?|(a)|(b))%1", "ab") end)
	it("Branch reset: backref %1 two-char first branch", function() assertMatch("(?|(ab)|(a)(b))%1", "abab", true, 1, 4) end)
	it("Branch reset: backref %1 to second branch (a)", function() assertMatch("(?|(ab)|(a)(b))%1", "aba", true, 1, 3) end)
	-- Backreferences to outer group after branch reset
	it("Branch reset: outer group %3 backref", function() assertMatch("(?|(a)|(b)(c))x(d)%3", "axdd", true, 1, 4) end)
	it("Branch reset: outer %3 fails (c+d mismatch)", function() assertMatch("(?|(a)|(b)(c))x(d)%3", "bxdd") end)
	it("Branch reset: outer group 3 captured value", function() assertCapture("(?|(a)|(b)(c))x(d)%3", "axdd", 3, "d") end)
	-- With lookahead
	it("Branch reset: with lookahead", function() assertMatch("(?|(?=a)(a)|(?=b)(b))", "a", true, 1, 1) end)
	it("Branch reset: lookahead branch backref", function() assertMatch("(?|(?=a)(a)|(?=b)(b))%1", "aa", true, 1, 2) end)
	it("Branch reset: lookahead second branch backref", function() assertMatch("(?|(?=a)(a)|(?=b)(b))%1", "bb", true, 1, 2) end)
	-- Nested groups inside branch reset
	it("Branch reset: nested groups", function() assertMatch("(?|((a))|b)c", "ac", true, 1, 2) end)
	it("Branch reset: outer nested group 1", function() assertCapture("(?|((a))|b)c", "ac", 1, "a") end)
	it("Branch reset: inner nested group 2", function() assertCapture("(?|((a))|b)c", "ac", 2, "a") end)
	it("Branch reset: backref %2 to inner nested group", function() assertMatch("(?|((a))|b)c%2", "aca", true, 1, 3) end)
	it("Branch reset: backref %1 to outer nested group", function() assertMatch("(?|((a))|b)c%1", "aca", true, 1, 3) end)
end)

describe("Advanced Groups -- Recursion (?R), (?1), (?&name)...", function()
	-- Root recursion: matches 'a', then recursively calls the whole pattern which matches 'a', then 'b', then 'b'
	it("Recursion: whole pattern recursion (?R)", function() assertMatch("a(?R)?b", "aabb", true, 1, 4) end)
	it("Recursion: whole pattern recursion (?0)", function() assertMatch("a(?0)?b", "aabb", true, 1, 4) end)
	it("Recursion: recursion is optional and skipped", function() assertMatch("a(?R)?b", "ab", true, 1, 2) end)
	-- Numbered recursion
	it("Recursion: numbered recursion (?1)", function() assertMatch("(a(?1)?b)", "aabb", true, 1, 4) end)
	it("Recursion: backreference to group 1 using (?1)", function() assertMatch("(a)(?1)", "aa", true, 1, 2) end)
	it("Recursion: fails if group 1 pattern doesn't match", function() assertMatch("(a)(?1)", "ab") end)
	it("Recursion: (?1) re-evaluates the group 1 pattern, matching 'b'", function() assertMatch("(a|b)(?1)", "ab", true, 1, 2) end)
	-- The difference between backreference %1 and recursion (?1)
	it("Backref: %1 requires exact captured text, fails 'ab'", function() assertMatch("(a|b)%1", "ab") end)
	-- Forward reference
	it("Recursion: forward reference to (?1)", function() assertMatch("(?1)(a)", "aa", true, 1, 2) end)
	-- Named recursion
	it("Recursion: named recursion (?&P)", function() assertMatch("(?<P>a(?&P)?b)", "aabb", true, 1, 4) end)
	it("Recursion: backreference to named group", function() assertMatch("(?<P>a)(?&P)", "aa", true, 1, 2) end)
	-- Quantified recursion
	it("Recursion: quantified recursive group", function() assertMatch("(a)(?1)+", "aaa", true, 1, 3) end)
	it("Recursion: exact-count quantified recursive group", function() assertMatch("(a)(?1){2}", "aaa", true, 1, 3) end)
	-- Complex nesting
	it("Recursion: deep group reference", function() assertMatch("(((a)))(?2)", "aa", true, 1, 2) end)
	-- Recursion mixed with alternation
	it("Recursion: recursive alt matched", function() assertMatch("a(?R)?b|c", "aabb", true, 1, 4) end)
	it("Recursion: non-recursive alt matched", function() assertMatch("a(?R)?b|c", "c", true, 1, 1) end)
	it("Recursion: recursion evaluates inner alt", function() assertMatch("a(?R)?b|c", "acb", true, 1, 3) end)
	-- Recursion inside lookahead
	it("Recursion: subroutine inside positive lookahead (calling inner group)", function()
		assertMatch("^(?=(a(?1)?b))a+b+", "aabb", true, 1, 4)
	end)
	it("Recursion: lookahead prevents match on incomplete string", function() assertMatch("^(?=(a(?1)?b))a+b+", "aab") end)
	-- Lookaround inside recursion
	it("Recursion: subroutine contains lookahead", function() assertMatch("^(a(?=a|b)(?1)?b)", "aabb", true, 1, 4) end)
	it("Recursion: subroutine contains lookahead that fails", function() assertMatch("^(a(?=b)(?1)?b)", "aabb") end)
	-- Recursion and backreferences mixed
	it("Recursion: subroutine then backreference", function() assertMatch("(a)(?1)%1", "aaa", true, 1, 3) end)
	it("Recursion: subroutine evaluates 'b', then backreference evaluates 'a'", function()
		assertMatch("(a|b)(?1)%1", "aba", true, 1, 3)
	end)
	-- Multiple quantifiers on recursion
	it("Recursion: star quantifier on subroutine", function() assertMatch("(a)(?1)*", "aaaaa", true, 1, 5) end)
	it("Recursion: bounded quantifier on subroutine", function() assertMatch("(a|b)(?1){2,3}", "abb", true, 1, 3) end)
	it("Recursion: quantified named subroutine", function() assertMatch("(?<X>x|y)(?&X){2}", "xyy", true, 1, 3) end)
	-- Mutual recursion-like behavior (calling another group that calls back -
	-- not fully supported without careful regex, but let's test deep calls)
	it("Recursion: call another named group", function() assertMatch("(?<A>a(?&B)?)(?<B>b(?&A)?)", "ab", true, 1, 2) end)
	it("Recursion: ping pong calls", function() assertMatch("(?<A>a(?&B)?)(?<B>b(?&A)?)", "aba", true, 1, 3) end)
	-- Key-Value multiline format recursion
	it("Recursion: key-value multiline recursion", function()
		assertMatch("^([%w]+): ([%w]+)$[\n ]*(?R)?", "name: john\nage: 10", true, 1, 18, "m")
	end)
end)

describe("Error Handling...", function()
	it("Empty named group: parse error", function() assertError("(?<>abc)", "") end)
	it("PCRE-style named backref: parse error", function() assertError("(?P=name)", "") end)
	it("Unterminated atomic group: parse error", function() assertError("(?>", "") end)
	it("Unterminated named group: parse error", function() assertError("(?<name>", "") end)
	it("Empty subroutine name: parse error", function() assertError("(?&)", "") end)
	it("Balanced match missing delimiters: parse error", function() assertError("%b", "") end)
	it("Reversed quantifier range: parse error", function() assertError("a{3,1}", "") end)
	it("Reversed set range: parse error", function() assertError("[z-a]", "") end)
	it("Unclosed set: parse error", function() assertError("[abc", "") end)
	it("Undefined backreference: runtime no-match", function() assertMatch("%1", "a") end)
	it("Non-existent group subroutine: runtime no-match", function() assertMatch("(?5)(a)", "a") end)
	it("Out-of-bounds group index: runtime no-match", function() assertMatch("(?999)(a)", "a") end)
end)

describe("Cross-Feature Integration...", function()
	-- Multi-iteration capture history
	it("Capture history: multi-iteration (a)+ records all positions", function()
		local hasMatched, _, _, metadata = matcher("(a)+", "aaa")
		assert(hasMatched, "Capture history: (a)+ should match")
		local captureStarts = metadata.captureStarts[1]
		assert(type(captureStarts) == "table" and #captureStarts == 3, "Capture history: three iterations recorded")
		assert(captureStarts[1] == 1 and captureStarts[2] == 2 and captureStarts[3] == 3, "Capture history: positions 1,2,3")
	end)
	it("Capture history: nested quantified groups ((a)(b))+", function()
		local hasMatched, _, _, metadata = matcher("((a)(b))+", "abab")
		assert(hasMatched, "Capture history: nested quantified groups should match")
		local group1Starts = metadata.captureStarts[1]
		local group2Starts = metadata.captureStarts[2]
		local group3Starts = metadata.captureStarts[3]
		assert(
			#group1Starts == 2 and #group2Starts == 2 and #group3Starts == 2,
			"Capture history: nested groups record two iterations each"
		)
	end)
	-- Nested group backtracking with capture rollback (branch isolation)
	it("Capture rollback: c-branch match isolates unused group2", function()
		local hasMatched, _, _, metadata = matcher("(a(b)|c(d))e", "cde")
		assert(hasMatched, "Capture rollback: c-branch match")
		assert(metadata.captureStarts[1][1] == 1, "Capture rollback: group1 captured")
		assert(not metadata.captureStarts[2], "Capture rollback: unused nested group2 absent")
		assert(metadata.captureStarts[3][1] == 2, "Capture rollback: group3 captured on c-branch")
	end)
	it("Capture rollback: a-branch match isolates unused group3", function()
		local hasMatched, _, _, metadata = matcher("(a(b)|c(d))e", "abe")
		assert(hasMatched, "Capture rollback: a-branch match")
		assert(metadata.captureStarts[2][1] == 2, "Capture rollback: nested group2 captured on a-branch")
		assert(not metadata.captureStarts[3], "Capture rollback: unused group3 absent")
	end)
	-- Recursion + branch reset
	it("Recursion + branch reset: second branch via recursion", function() assertMatch("(?|(?R)|b)", "ab", true, 2, 2) end)
	it("Recursion + branch reset: direct b branch", function() assertMatch("(?|(?R)|b)", "b", true, 1, 1) end)
	-- Recursion + atomic group
	it("Recursion + atomic: optional atomic recursion", function() assertMatch("a(?>(?R))?b", "aabb", true, 1, 4) end)
	it("Recursion + atomic: skip recursion", function() assertMatch("a(?>(?R))?b", "ab", true, 1, 2) end)
	-- Atomic inside recursion
	it("Atomic inside recursion: matches abc prefix", function() assertMatch("(a(?>b|bc)(?1)?c)", "abcc", true, 1, 3) end)
	it("Atomic inside recursion: b path", function() assertMatch("(a(?>b|bc)(?1)?c)", "abc", true, 1, 3) end)
	-- Named group + recursion + flags
	it("Named recursion + case-insensitive flag", function() assertMatch("(?i:(?<P>a(?&P)?b))", "AaBb", true, 1, 4) end)
	-- Branch reset + backreferences across alternation depth
	it("Branch reset: deep backref %2 first branch", function() assertMatch("(?|((a)(b))|(c))%2", "aba", true, 1, 3) end)
	it("Branch reset: deep backref fails on second branch", function() assertMatch("(?|((a)(b))|(c))%2", "cb") end)
	it("Branch reset: group2 capture on deep branch", function() assertCapture("(?|((a)(b))|(c))%2", "aba", 2, "a") end)
	it("Branch reset: group3 inner capture on deep branch", function() assertCapture("(?|((a)(b))|(c))%2", "aba", 3, "b") end)
end)

describe("Depth Limits...", function()
	it("Recursion depth limit prevents infinite recursion", function()
		local config = require("expaghetti.core.config").defaults
		local savedRecursion = config.maxRecursionDepth
		config.maxRecursionDepth = 5
		assertMatch("(?R)", "x")
		config.maxRecursionDepth = savedRecursion
	end)
	it("Backtrack depth limit prevents catastrophic backtracking", function()
		local config = require("expaghetti.core.config").defaults
		local savedBacktrack = config.maxBacktrackDepth
		config.maxBacktrackDepth = 10
		assertMatch("(a+)+b", "aaaaaaaaaaaaac")
		config.maxBacktrackDepth = savedBacktrack
	end)
end)

describe("Quantifiers -- extensive backtracking (greedy, lazy, possessive, groups, alternates)...", function()
	-- Greedy backtracks for trailing literals; possessive does not
	it("Greedy +: keeps one char for trailing a", function() assertMatch("a+a", "aaa", true, 1, 3) end)
	it("Possessive ++: no backtrack for trailing a", function() assertMatch("a++a", "aaa") end)
	it("Greedy *: backtracks star for trailing a", function() assertMatch("a*a", "aaa", true, 1, 3) end)
	it("Possessive *+: no backtrack for trailing a", function() assertMatch("a*+a", "aaa") end)
	it("Greedy ?: backtracks optional for trailing a", function() assertMatch("a?a", "aa", true, 1, 2) end)
	it("Possessive ?+: zero-or-one then literal", function() assertMatch("a?+a", "aa", true, 1, 2) end)
	-- Dot quantifiers with trailing literal
	it("Greedy .+: backtracks to leave b", function() assertMatch(".+b", "abbb", true, 1, 4) end)
	it("Possessive .++: cannot backtrack for b", function() assertMatch(".++b", "abbb") end)
	it("Lazy .+?: expands minimally to reach b", function() assertMatch(".+?b", "abbb", true, 1, 2) end)
	it("Greedy .*: backtracks to leave b", function() assertMatch(".*b", "abbb", true, 1, 4) end)
	it("Possessive .*+: cannot backtrack for b", function() assertMatch(".*+b", "abbb") end)
	-- Nested quantifiers inside groups (greedy inner must backtrack for outer continuation)
	it("Nested +: inner backtracks, trailing a matches", function() assertMatch("(a+)+a", "aaaaa", true, 1, 5) end)
	it("Nested +: minimal inner + trailing a", function() assertMatch("(a+)+a", "aa", true, 1, 2) end)
	it("Nested +: single a cannot satisfy trailing a", function() assertMatch("(a+)+a", "a") end)
	it("Nested +: inner backtracks for trailing b", function() assertMatch("(a+)+b", "aaab", true, 1, 4) end)
	it("Nested +: no trailing b available", function() assertMatch("(a+)+b", "aaaaa") end)
	it("Nested possessive inner: no backtrack for trailing a", function() assertMatch("(a++)+a", "aaaaa") end)
	it("Non-cap nested +: inner backtracks for trailing a", function() assertMatch("(?:a+)+a", "aaaaa", true, 1, 5) end)
	it("Group + (no inner quant): per-char outer + trailing a", function() assertMatch("(a)+a", "aaaaa", true, 1, 5) end)
	it("Group +: three iterations + trailing a", function() assertMatch("(a)+a", "aaa", true, 1, 3) end)
	-- Exact-count quantifiers on groups with inner +
	it("Exact {2} on (a+): one a per repetition", function() assertMatch("(a+){2}", "aa", true, 1, 2) end)
	it("Exact {2} on (a+): splits 1+2 across repetitions", function() assertMatch("(a+){2}", "aaa", true, 1, 3) end)
	it("Exact {2} on (a+): insufficient characters", function() assertMatch("(a+){2}", "a") end)
	it("Exact {2} on (a) + trailing a", function() assertMatch("(a){2}a", "aaa", true, 1, 3) end)
	-- Alternation combined with quantifiers
	it("Alt quantified: a+aa+b", function() assertMatch("(a|aa)+b", "aab", true, 1, 3) end)
	it("Alt quantified: no trailing b", function() assertMatch("(a|aa)+b", "aaa") end)
	it("Alt quantified: greedy branch repetition", function() assertMatch("(a|aa)+", "aaaa", true, 1, 4) end)
	it("Alt quantified: ab branch + trailing b", function() assertMatch("(ab|a)+b", "abb", true, 1, 3) end)
	it("Alt quantified: a branch cannot reach trailing b", function() assertMatch("(ab|a)+b", "aab") end)
	it("Alt: left branch backtracks for c", function() assertMatch("a.*b|a.*c", "ac", true, 1, 2) end)
	it("Alt: left branch matches xxb", function() assertMatch("a.*b|a.*c", "axxb", true, 1, 4) end)
	it("Alt: possessive left fails, right matches c", function() assertMatch("a.*+b|a.*c", "ac", true, 1, 2) end)
	it("Alt: possessive left cannot backtrack for b", function() assertMatch("a.*+b|a.*c", "axxb") end)
	it("Alt quantified: mixed a/b branches + c", function() assertMatch("(a+|b+)+c", "aaabc", true, 1, 5) end)
	it("Alt quantified: b branch + c", function() assertMatch("(a+|b+)+c", "bbc", true, 1, 3) end)
	-- Quantifiers with nested groups in pattern
	it("Nested group+: greedy b+ inside pattern", function() assertMatch("a(b+)+c", "abbbc", true, 1, 5) end)
	it("Nested group+: single b iteration", function() assertMatch("a(b+)+c", "abc", true, 1, 3) end)
	it("Nested group+: bounded by literals", function() assertMatch("x(a+)+y", "xaaay", true, 1, 5) end)
	it("Lazy inner + with outer +: expands to fit", function() assertMatch("(a+?)+a", "aaaaa", true, 1, 5) end)
	-- Custom range quantifiers with trailing literal
	it("Greedy {1,3}: backtracks for trailing a", function() assertMatch("a{1,3}a", "aaaa", true, 1, 4) end)
	it("Possessive {1,3}+: still leaves trailing a here", function() assertMatch("a{1,3}+a", "aaaa", true, 1, 4) end)
	it("Possessive {1,3}+: consumes all, trailing a fails", function() assertMatch("a{1,3}+a", "aaa") end)
	it("Range {2,4}: backtracks for trailing b", function() assertMatch("a{2,4}b", "aaab", true, 1, 4) end)
	it("Range {2,4}: longer greedy prefix + b", function() assertMatch("a{2,4}b", "aaaab", true, 1, 5) end)
	-- Multiple quantified elements
	it("Two greedy .+: second dot backtracks", function() assertMatch(".+.+", "ab", true, 1, 2) end)
	it("Two .+: insufficient chars", function() assertMatch(".+.+", "a") end)
	it("Possessive .+ then .: first blocks second", function() assertMatch(".++.+", "ab") end)
	-- Atomic groups vs backtracking
	it("Atomic inner: split across outer + for trailing a", function() assertMatch("(?>a+)+a", "aaaaa", true, 1, 5) end)
	it("Atomic inner: three chars via outer + split", function() assertMatch("(?>a+)+a", "aaa", true, 1, 3) end)
	it("Atomic alt: cannot backtrack from bc to b", function() assertMatch("a(?>bc|b)c", "abc") end)
	-- Capture behavior during quantifier backtracking
	it("Quantifier backtracking: nested + records first capture after inner backtrack", function()
		local hasMatched, _, _, metadata = matcher("(a+)+a", "aaaaa")
		assert(hasMatched, "Nested +: capture history should match")
		local captureStarts = metadata.captureStarts[1]
		local captureEnds = metadata.captureEnds[1]
		assert(#captureStarts == 1, "Nested +: one outer repetition recorded due to greedy inner +")
		assert(
			getSubstring("aaaaa", captureStarts[1], captureEnds[1]) == "aaaa",
			"Nested +: first capture after inner backtrack"
		)
	end)
	it("Quantifier backtracking: alternation (a|aa)+b captures winning branch", function()
		local hasMatched, _, _, metadata = matcher("(a|aa)+b", "aab")
		assert(hasMatched, "Alt quantified: capture history should match")
		local captureStarts = metadata.captureStarts[1]
		local captureEnds = metadata.captureEnds[1]
		assert(
			getSubstring("aab", captureStarts[#captureStarts], captureEnds[#captureEnds]) == "aa",
			"Alt quantified: last capture is winning branch"
		)
	end)
	-- Contrasting greedy vs possessive nested inner quantifier
	it("Greedy inner + in group: backtracks for trailing a", function() assertMatch("(a+)+a", "aaaaa", true, 1, 5) end)
	it("Possessive inner ++ in group: no backtrack for trailing a", function() assertMatch("(a++)+a", "aaaaa") end)
end)

describe("Flags -- u (Unicode)...", function()
	it("Unicode flag off: UTF-8 text is byte-positioned", function() assertMatch("maçã", "maçã", true, 1, 6) end)
	it("Unicode flag on: UTF-8 text is codepoint-positioned", function() assertMatch("maçã", "maçã", true, 1, 4, "u") end)
	it("Unicode flag off: dot matches first byte of UTF-8 char", function() assertMatch(".", "ã", true, 1, 1) end)
	it("Unicode flag on: dot matches one codepoint", function() assertMatch(".", "ã", true, 1, 1, "u") end)
	it("Unicode flag off: quantified dot counts bytes", function() assertMatch(".+", "aã", true, 1, 3) end)
	it("Unicode flag on: quantified dot counts codepoints", function() assertMatch(".+", "aã", true, 1, 2, "u") end)
	it("Unicode flag on: set member is one codepoint", function() assertMatch("[ã]", "ã", true, 1, 1, "u") end)
	it("Unicode flag on: set range compares codepoint strings", function() assertMatch("[ã-ã]", "ã", true, 1, 1, "u") end)
	it("Unicode flag on: frontier sees codepoint boundary", function() assertMatch("%f[ã]ã", "ã", true, 1, 1, "u") end)
	it("Unicode flag off: group captures bytes", function() assertMatch("(ä)", "ä", true, 1, 2) end)
	it("Unicode flag on: group captures one codepoint", function() assertMatch("(ä)", "ä", true, 1, 1, "u") end)
	it("Unicode flag off: captured group contains bytes", function() assertCapture("(ä)", "ä", 1, "ä") end)
	it("Unicode flag on: captured group contains one codepoint", function() assertCapture("(ä)", "ä", 1, "ä", "u") end)
	it("Unicode flag off: literal quantifier repeats last byte", function() assertMatch("ä+", "äää", true, 1, 2) end)
	it("Unicode flag on: literal quantifier repeats codepoints", function() assertMatch("ä+", "äää", true, 1, 3, "u") end)
	it("Unicode flag off: group quantifier repeats bytes", function() assertMatch("(ä)+", "ää", true, 1, 4) end)
	it("Unicode flag on: group quantifier repeats codepoints", function() assertMatch("(ä)+", "ää", true, 1, 2, "u") end)
	it("Unicode flag off: positive lookahead sees bytes", function() assertMatch("(?=ä)ä", "ä", true, 1, 2) end)
	it("Unicode flag on: positive lookahead sees codepoint", function() assertMatch("(?=ä)ä", "ä", true, 1, 1, "u") end)
	it("Unicode flag off: negative lookahead keeps byte position", function() assertMatch("(?!b)ä", "ä", true, 1, 2) end)
	it("Unicode flag on: negative lookahead keeps codepoint position", function() assertMatch("(?!b)ä", "ä", true, 1, 1, "u") end)
	it("Unicode flag off: positive lookbehind sees prior bytes", function() assertMatch("(?<=ä)b", "äb", true, 3, 3) end)
	it("Unicode flag on: positive lookbehind sees prior codepoint", function() assertMatch("(?<=ä)b", "äb", true, 2, 2, "u") end)
	it("Unicode flag off: negative lookbehind sees prior bytes", function() assertMatch("(?<!b)ä", "ä", true, 1, 2) end)
	it("Unicode flag on: negative lookbehind sees prior codepoint", function() assertMatch("(?<!b)ä", "ä", true, 1, 1, "u") end)
	it("Unicode flag off: alternate first branch spans bytes", function() assertMatch("(ã)|(b)", "ã", true, 1, 2) end)
	it("Unicode flag off: alternate first branch captured", function() assertCapture("(ã)|(b)", "ã", 1, "ã") end)
	it("Unicode flag off: alternate second branch not captured", function() assertCaptureAbsent("(ã)|(b)", "ã", 2) end)
	it("Unicode flag on: alternate first branch spans codepoint", function() assertMatch("(ã)|(b)", "ã", true, 1, 1, "u") end)
	it("Unicode flag on: alternate first branch captured", function() assertCapture("(ã)|(b)", "ã", 1, "ã", "u") end)
	it("Unicode flag on: alternate second branch not captured", function() assertCaptureAbsent("(ã)|(b)", "ã", 2, "u") end)
	it("Unicode flag off: alternate second branch spans bytes", function() assertMatch("(a)|(ã)", "ã", true, 1, 2) end)
	it("Unicode flag off: alternate first branch not captured", function() assertCaptureAbsent("(a)|(ã)", "ã", 1) end)
	it("Unicode flag off: alternate second branch captured", function() assertCapture("(a)|(ã)", "ã", 2, "ã") end)
	it("Unicode flag on: alternate second branch spans codepoint", function() assertMatch("(a)|(ã)", "ã", true, 1, 1, "u") end)
	it("Unicode flag on: alternate first branch not captured", function() assertCaptureAbsent("(a)|(ã)", "ã", 1, "u") end)
	it("Unicode flag on: alternate second branch captured", function() assertCapture("(a)|(ã)", "ã", 2, "ã", "u") end)
	it("Unicode flag off: position capture uses byte offset", function() assertPositionCapture("^ã()$", "ã", 1, 3) end)
	it("Unicode flag on: position capture uses codepoint offset", function() assertPositionCapture("^ã()$", "ã", 1, 2, "u") end)
	it("Inline Unicode flag is not accepted", function() assertError("(?u)", "") end)
	it("Scoped Unicode flag is not accepted", function() assertError("(?u:ã)", "ã") end)
end)

describe("Combined Flags...", function()
	it("Global iu flags: Unicode literal", function() assertMatch("ÁBC", "ÁBC", true, 1, 3, "iu") end)
	it("Global iu flags: Unicode range", function() assertMatch("[Á-Ã]", "Â", true, 1, 1, "iu") end)
	it("Global iu flags: outside unicode range", function() assertMatch("[Á-Ã]", "Ä", nil, nil, nil, "iu") end)
	it("Global is flags: dotall + case-insensitive", function() assertMatch("a.b", "A\nB", true, 1, 3, "is") end)
	it("Global im flags: multiline + case-insensitive", function() assertMatch("^abc$", "ABC\nxyz", true, 1, 3, "im") end)
	it("Global im flags: second line", function() assertMatch("^xyz$", "ABC\nXYZ", true, 5, 7, "im") end)
	it("Global ms flags: multiline + dotall", function() assertMatch("^a.*c$", "a\nb\nc", true, 1, 5, "ms") end)
	it("Global in flags: no auto capture + case-insensitive", function() assertNoCapture("(abc)", "ABC", "in") end)
	it("Global in flags: named captures still work", function() assertCapture("(?<word>abc)", "ABC", "word", "ABC", "in") end)
	it("Global ius flags: Unicode + dotall", function() assertMatch("Á.B", "Á\nB", true, 1, 3, "ius") end)
	it("Inline iu flags", function() assertMatch("(?i)ÁBC", "ÁBC", true, 1, 3, "u") end)
	it("Inline is flags", function() assertMatch("(?is)a.b", "A\nB", true, 1, 3) end)
	it("Scoped iu flags", function() assertMatch("(?i:ÁBC)", "ÁBC", true, 1, 3, "u") end)
	it("Scoped is flags: i does not leak outside scope", function() assertMatch("a(?is:.)b", "a\nB") end)
	it("Nested enable/disable of i", function() assertMatch("(?i)a(?-i)(?i)b", "AB", true, 1, 2) end)
	it("Disable only s inside is scope", function() assertMatch("(?is)a(?-s:.)b", "A\nB") end)
	it("Disable only i inside is scope", function() assertMatch("(?is)a(?-i:.)b", "A\nB", true, 1, 3) end)
	it("Enable i,m disable s together", function() assertMatch("(?im-s)^abc$", "ABC\nDEF", true, 1, 3) end)
	it("Enable i,m,s together", function() assertMatch("(?ims)^a.*c$", "A\nB\nC", true, 1, 5) end)
end)

describe("Wiki regex samples", function()
	-- Alternate
	it("Alternate: top-level alternation", function() assertMatch("cat|dog|bird", "I have a dog", true, 10, 12) end)
	it("Alternate: grouped alternation", function() assertCapture("I love (apples|oranges)", "I love oranges", 1, "oranges") end)
	-- Anchor ^$
	it("Anchor: whole string", function() assertMatch("^abc$", "abc", true, 1, 3) end)
	it("Anchor: start", function() assertMatch("^abc$", "xabc") end)
	it("Anchor: end", function() assertMatch("^abc$", "abcx") end)
	-- Character Classes
	it("Character class: escaped magic", function() assertMatch("%$100%.00", "Cost is $100.00", true, 9, 15) end)
	it("Character class: digits", function() assertMatch("%d{3}-%d{2}-%d{4}", "123-45-6789", true, 1, 11) end)
	it("Character class: letters", function() assertMatch("(?<word>%a+)", "hello", true, 1, 5) end)
	it("Character class: named capture", function() assertCapture("(?<word>%a+)", "hello", "word", "hello") end)
	it("Character class: date", function() assertMatch("(%d+)-(%d+)-(%d+)", "2024-05-12", true, 1, 10) end)
	-- Flags
	it("Modifier: enable inline flag", function() assertMatch("abc(?i)def", "abcDEF", true, 1, 6) end)
	it("Modifier: disable inline flag", function() assertMatch("abc(?-i)def", "ABCdef", true, 1, 6, "i") end)
	it("Modifier: scoped enable", function() assertMatch("(?i:abc)def", "ABCdef", true, 1, 6) end)
	it("Modifier: scoped disable", function() assertMatch("abc(?-i:def)", "ABCdef", true, 1, 6, "i") end)
	it("Modifier: scoped flag boundary", function() assertMatch("(?i:abc)def", "ABCDEF") end)
	-- Standard Groups
	it("Group: captures", function() assertMatch("(%d+)-(%d+)-(%d+)", "2024-05-12", true, 1, 10) end)
	it("Group: capture 1", function() assertCapture("(%d+)-(%d+)-(%d+)", "2024-05-12", 1, "2024") end)
	it("Group: capture 2", function() assertCapture("(%d+)-(%d+)-(%d+)", "2024-05-12", 2, "05") end)
	it("Group: capture 3", function() assertCapture("(%d+)-(%d+)-(%d+)", "2024-05-12", 3, "12") end)
	it("Group: non-capturing", function() assertMatch("(?:apple|orange) juice", "orange juice", true, 1, 12) end)
	it("Group: non-capturing 2", function() assertNoCapture("(?:apple|orange) juice", "orange juice") end)
	it("Group: backreference", function() assertMatch("([a-z]+) %1", "hello hello", true, 1, 11) end)
	-- Named Groups
	it("Named group", function() assertMatch("(?<year>%d+)-(?<month>%d+)-(?<day>%d+)", "2024-05-12", true, 1, 10) end)
	it("Named group: year", function() assertCapture("(?<year>%d+)-(?<month>%d+)-(?<day>%d+)", "2024-05-12", "year", "2024") end)
	it("Named group: month", function() assertCapture("(?<year>%d+)-(?<month>%d+)-(?<day>%d+)", "2024-05-12", "month", "05") end)
	it("Named group: day", function() assertCapture("(?<year>%d+)-(?<month>%d+)-(?<day>%d+)", "2024-05-12", "day", "12") end)
	it("Named backreference", function() assertMatch("<(?<tag>[a-z]+)>.*?</%k<tag>>", "<body>content</body>", true, 1, 20) end)
	it("Named backreference capture", function()
		assertCapture("<(?<tag>[a-z]+)>.*?</%k<tag>>", "<body>content</body>", "tag", "body")
	end)
	-- Lookaround
	it("Positive lookahead", function() assertMatch("%w+(?=,)", "apple, banana", true, 1, 5) end)
	it("Negative lookahead", function() assertMatch("%w+(?!,)", "apple, banana", true, 1, 4) end)
	it("Positive lookbehind", function() assertMatch("(?<=USD )%d+", "USD 100", true, 5, 7) end)
	it("Negative lookbehind", function() assertMatch("(?<!USD )%d+", "EUR 100", true, 5, 7) end)
	it("Lookahead does not consume", function() assertMatch("%w+(?= world) world", "hello world", true, 1, 11) end)
	it("Lookbehind does not consume", function() assertMatch("(?<=Mr%. )%a+", "Mr. Smith", true, 5, 9) end)
	it("Negative lookahead failure", function() assertMatch("cat(?!fish)", "catfish") end)
	it("Negative lookbehind failure", function() assertMatch("(?<!Mr%. )Smith", "Mr. Smith") end)
	-- Advanced Groups
	it("Atomic group", function() assertMatch("(?>a+)a", "aaaa") end)
	it("Branch reset", function() assertCapture("(?|(apple)|(orange))", "orange", 1, "orange") end)
	it("Inline comment", function() assertMatch("hello(?# this is just a greeting ) world", "hello world", true, 1, 11) end)
	-- Recursive Groups
	it("Whole-pattern recursion cannot resume after recursive match", function()
		assertMatch("^%((?:[^()]+|(?R))*%)$", "(a(b)c)")
	end)
	it("Whole-pattern recursion rejects unbalanced parentheses", function() assertMatch("^%((?:[^()]+|(?R))*%)$", "(a(bc)") end)
	it("Whole-pattern recursion", function() assertMatch("%((?:[^()]+|(?R))*%)", "(a(b)c)", true, 1, 7) end)
	it("Numbered recursion through alternation", function() assertMatch("(x(?1)?y|A)", "xxAyy", true, 1, 5) end)
	it("Numbered recursion failure: recursive call cannot match", function() assertMatch("(x(?1)?y|A)", "xzx") end)
	-- Magic Characters
	it("Magic: escaped characters", function() assertMatch("%$100%.00", "Cost is $100.00", true, 9, 15) end)
	it("Magic: wildcard", function() assertMatch("a.c", "abc and axc", true, 1, 3) end)
	it("Magic: non-capturing", function() assertMatch("(?:cat|dog)", "dog", true, 1, 3) end)
	it("Magic: named group", function() assertCapture("(?<word>%a+)", "hello", "word", "hello") end)
	it("Magic: lazy quantifier", function() assertMatch("<.+?>", "<a><b>", true, 1, 3) end)
	it("Magic: negated set", function() assertMatch("[^0-9]+", "abc123", true, 1, 3) end)
	-- Quantifiers
	it("Quantifier: *", function() assertMatch("ab*c", "abbbc", true, 1, 5) end)
	it("Quantifier: +", function() assertMatch("ab+c", "abbbc", true, 1, 5) end)
	it("Quantifier: ?", function() assertMatch("colou?r", "color", true, 1, 5) end)
	it("Quantifier: ? present", function() assertMatch("colou?r", "colour", true, 1, 6) end)
	it("Quantifier: exact", function() assertMatch("%d{4}", "Year: 2026", true, 7, 10) end)
	it("Quantifier: at least", function() assertMatch("a{2,}", "aaaa", true, 1, 4) end)
	it("Quantifier: at most", function() assertMatch("a{,2}", "aaaa", true, 1, 2) end)
	it("Quantifier: range", function() assertMatch("%d{2,4}", "123456", true, 1, 4) end)
	-- Lazy Quantifiers
	it("Greedy quantifier", function() assertMatch("<.+>", "<first><second>", true, 1, 15) end)
	it("Lazy quantifier", function() assertMatch("<.+?>", "<first><second>", true, 1, 7) end)
	it("Lazy explicit quantifier", function() assertMatch("a{2,5}?", "aaaaaa", true, 1, 2) end)
	it("Lazy zero-or-one", function() assertMatch("ba??a", "baa", true, 1, 2) end)
	-- Possessive Quantifiers
	it("Possessive comparison: greedy", function() assertMatch("a+mo", "aaamo", true, 1, 5) end)
	it("Possessive one-or-more", function() assertMatch("a++amo", "aaamo") end)
	it("Possessive explicit quantifier", function() assertMatch("a{2,4}+aa", "aaaa") end)
	-- Sets
	it("Set: basic", function() assertMatch("[abc]", "dog and cat", true, 5, 5) end)
	it("Set: negated", function() assertMatch("[^abc]+", "xyzabc", true, 1, 3) end)
	it("Set: numeric range", function() assertMatch("[0-9]+", "Room 204", true, 6, 8) end)
	it("Set: alphabetic range", function() assertMatch("[a-z]+", "Hello", true, 2, 5) end)
	it("Set: multiple ranges", function() assertMatch("[a-zA-Z0-9]+", "Token123", true, 1, 8) end)
	it("Set: literals and range", function() assertMatch("[abc0-9]+", "9cab", true, 1, 4) end)
	it("Set: character class + literals", function() assertMatch("[%w.-]+", "file-name.txt", true, 1, 13) end)
	it("Set: character class + range", function() assertMatch("[%dA-F]+", "ABC123xyz", true, 1, 6) end)
end)

print("All matcher tests passed!")

testRunner.run()
end, {
	runs = 1
})
