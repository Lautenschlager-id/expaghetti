package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local matcher = require("matcher")

local performance = require("performance")

local splitStringByEachChar = require("helpers.string").splitStringByEachChar
local ENUM_FLAG_UNICODE = require("enums.flags").UNICODE

local function getSubstring(str, ini, en, flags)
	local isUnicode = false
	if type(flags) == "string" then
		isUnicode = flags:find("u")
	elseif type(flags) == "table" then
		isUnicode = flags[ENUM_FLAG_UNICODE] or flags.u
	end

	if isUnicode then
		local chars = splitStringByEachChar(str, true)
		return table.concat(chars, "", ini, en)
	end
	return string.sub(str, ini, en)
end

local function assertMatch(expr, str, expectedHasMatched, expectedIniStr, expectedEndStr, desc, flags)
	local hasMatched, iniStr, endStr, metaData = matcher(expr, str, flags)
	if (not hasMatched) ~= (not expectedHasMatched) then
		error(string.format("Test '%s' failed: Expected hasMatched=%s for expr='%s', str='%s' but got %s", desc, tostring(expectedHasMatched), expr, str, tostring(hasMatched)))
	end
	if expectedHasMatched then
		if iniStr ~= expectedIniStr or endStr ~= expectedEndStr then
			error(string.format("Test '%s' failed: Expected span=(%s, %s) but got (%s, %s)", desc, tostring(expectedIniStr), tostring(expectedEndStr), tostring(iniStr), tostring(endStr)))
		end
	end
end

local function assertError(expr, str, desc)
	local hasMatched, err = matcher(expr, str)
	if hasMatched ~= false or type(err) ~= "string" then
		error(string.format("Test '%s' failed: Expected parse error for expr='%s', but got hasMatched=%s", desc, expr, tostring(hasMatched)))
	end
end

local function assertCapture(expr, str, captureIndex, expectedStr, desc, flags)
	local hasMatched, iniStr, endStr, metaData = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match for expr='%s', str='%s'", desc, expr, str))
	local ini = metaData.captureStarts[captureIndex]
	local en  = metaData.captureEnds[captureIndex]
	if type(ini) == "table" then
		ini = ini[#ini]
		en = en[#en]
	end
	assert(ini, string.format("Test '%s': capture %s not found", desc, tostring(captureIndex)))
	local got = getSubstring(str, ini, en, flags)
	assert(got == expectedStr,
		string.format("Test '%s': expected capture=%q but got=%q", desc, expectedStr, got))
end

local function assertCaptureAbsent(expr, str, captureIndex, desc, flags)
	local hasMatched, _, _, metaData = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match for expr='%s', str='%s'", desc, expr, str))
	assert(not metaData.captureStarts[captureIndex],
		string.format("Test '%s': expected capture %s to be absent", desc, tostring(captureIndex)))
end

local function assertNoCapture(expr, str, desc, flags)
	local hasMatched, _, _, metaData = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match", desc))
	local hasAny = false
	for _ in pairs(metaData.captureStarts) do hasAny = true; break end
	assert(not hasAny, string.format("Test '%s': expected no captures", desc))
end

local function assertPositionCapture(expr, str, captureIndex, expectedPos, desc, flags)
	local hasMatched, _, _, metaData = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match for expr='%s', str='%s'", desc, expr, str))
	local pos = metaData.positionCaptures[captureIndex]
	assert(pos ~= nil, string.format("Test '%s': position capture %d not found", desc, captureIndex))
	assert(pos == expectedPos, string.format("Test '%s': expected position=%d but got %s", desc, expectedPos, tostring(pos)))
end

print("Running matcher tests for core engine...")

performance.logPerformanceAtTheEnd(function()

-- 1. Malformed inputs
do
	local hasMatched, err = matcher(123, "abc")
	assert(hasMatched == false, "Malformed input should return false")
	assert(type(err) == "string", "Malformed input should return error message")

	hasMatched, err = matcher("abc", 123)
	assert(hasMatched == false, "Malformed target string should return false")
end

----------------------------------------------------------------------------------------------------
print("  [2] Literal matching...")
assertMatch("a", "a",           true, 1, 1,  "Single literal exact")
assertMatch("a", "ba",          true, 2, 2,  "Single literal inside string")
assertMatch("abc", "xyzabcdef", true, 4, 6,  "Multiple literals inside string")
assertMatch("abc", "abx",       nil,  nil, nil, "Multiple literal mismatch")
assertMatch("abc", "",          nil,  nil, nil, "Literal against empty string")

----------------------------------------------------------------------------------------------------
print("  [3] Wildcard (.) matching...")
-- Wiki: matches any character but EOL, equivalent to [^\r\n]
assertMatch(".",   "a",         true, 1, 1, "Wildcard: normal char")
assertMatch(".",   "\t",        true, 1, 1, "Wildcard: tab")
assertMatch(".",   " ",         true, 1, 1, "Wildcard: space")
assertMatch("a.c", "abc",       true, 1, 3, "Wildcard surrounded by literals")
assertMatch(".",   "\n",        nil,  nil, nil, "Wildcard does not match newline")
assertMatch(".",   "\r",        nil,  nil, nil, "Wildcard does not match carriage return")

----------------------------------------------------------------------------------------------------
print("  [4] Escaped literals (%magic)...")
assertMatch("%.", "a.c",        true, 2, 2, "Escaped dot matches literal dot")
assertMatch("%.", "abc",        nil,  nil, nil, "Escaped dot does not match letter")
assertMatch("%(", "a(b",        true, 2, 2, "Escaped open paren")
assertMatch("%)", "a)b",        true, 2, 2, "Escaped close paren")
assertMatch("%[", "a[b",        true, 2, 2, "Escaped open bracket")
assertMatch("%+", "a+b",        true, 2, 2, "Escaped plus")
assertMatch("%*", "a*b",        true, 2, 2, "Escaped asterisk")
assertMatch("%?", "a?b",        true, 2, 2, "Escaped question mark")
assertMatch("%%", "50%",        true, 3, 3, "Escaped percent sign")

----------------------------------------------------------------------------------------------------
print("  [5] %a -- letters [a-zA-Z]...")
assertMatch("%a", "a",          true, 1, 1, "%a matches lowercase letter")
assertMatch("%a", "Z",          true, 1, 1, "%a matches uppercase letter")
assertMatch("%a", "1",          nil,  nil, nil, "%a does not match digit")
assertMatch("%a", "_",          nil,  nil, nil, "%a does not match underscore")
assertMatch("%A", "1",          true, 1, 1, "%A matches non-letter")
assertMatch("%A", "a",          nil,  nil, nil, "%A does not match letter")

----------------------------------------------------------------------------------------------------
print("  [6] %d -- digits [0-9]...")
assertMatch("%d", "5",          true, 1, 1, "%d matches digit")
assertMatch("%d", "9",          true, 1, 1, "%d matches 9")
assertMatch("%d", "a",          nil,  nil, nil, "%d does not match letter")
assertMatch("%D", "a",          true, 1, 1, "%D matches non-digit")
assertMatch("%D", "5",          nil,  nil, nil, "%D does not match digit")

----------------------------------------------------------------------------------------------------
print("  [7] %h / %x -- hex digits [0-9a-fA-F]...")
assertMatch("%h", "0",          true, 1, 1, "%h matches '0'")
assertMatch("%h", "9",          true, 1, 1, "%h matches '9'")
assertMatch("%h", "a",          true, 1, 1, "%h matches 'a'")
assertMatch("%h", "f",          true, 1, 1, "%h matches 'f'")
assertMatch("%h", "A",          true, 1, 1, "%h matches 'A'")
assertMatch("%h", "F",          true, 1, 1, "%h matches 'F'")
assertMatch("%h", "g",          nil,  nil, nil, "%h does not match 'g'")
assertMatch("%h", "G",          nil,  nil, nil, "%h does not match 'G'")
assertMatch("%x", "f",          true, 1, 1, "%x matches 'f'")
assertMatch("%x", "g",          nil,  nil, nil, "%x does not match 'g'")
assertMatch("%H", "g",          true, 1, 1, "%H matches non-hex")
assertMatch("%H", "f",          nil,  nil, nil, "%H does not match hex digit")
assertMatch("%X", "g",          true, 1, 1, "%X matches non-hex")
assertMatch("%X", "f",          nil,  nil, nil, "%X does not match hex digit")

----------------------------------------------------------------------------------------------------
print("  [8] %l -- lowercase letters [a-z]...")
assertMatch("%l", "a",          true, 1, 1, "%l matches lowercase")
assertMatch("%l", "z",          true, 1, 1, "%l matches 'z'")
assertMatch("%l", "A",          nil,  nil, nil, "%l does not match uppercase")
assertMatch("%L", "A",          true, 1, 1, "%L matches non-lowercase")
assertMatch("%L", "a",          nil,  nil, nil, "%L does not match lowercase")

----------------------------------------------------------------------------------------------------
print("  [9] %u -- uppercase letters [A-Z]...")
assertMatch("%u", "A",          true, 1, 1, "%u matches uppercase")
assertMatch("%u", "Z",          true, 1, 1, "%u matches 'Z'")
assertMatch("%u", "a",          nil,  nil, nil, "%u does not match lowercase")
assertMatch("%U", "a",          true, 1, 1, "%U matches non-uppercase")
assertMatch("%U", "A",          nil,  nil, nil, "%U does not match uppercase")

----------------------------------------------------------------------------------------------------
print("  [10] %w -- word chars [a-zA-Z0-9_]...")
assertMatch("%w", "a",          true, 1, 1, "%w matches letter")
assertMatch("%w", "Z",          true, 1, 1, "%w matches uppercase letter")
assertMatch("%w", "5",          true, 1, 1, "%w matches digit")
assertMatch("%w", "_",          true, 1, 1, "%w matches underscore")
assertMatch("%w", "-",          nil,  nil, nil, "%w does not match hyphen")
assertMatch("%W", "-",          true, 1, 1, "%W matches non-word char")
assertMatch("%W", "a",          nil,  nil, nil, "%W does not match word char")

----------------------------------------------------------------------------------------------------
print("  [11] %s -- whitespace [\\f\\n\\r\\t ]...")
assertMatch("%s", " ",          true, 1, 1, "%s matches space")
assertMatch("%s", "\t",         true, 1, 1, "%s matches tab")
assertMatch("%s", "\n",         true, 1, 1, "%s matches newline")
assertMatch("%s", "\r",         true, 1, 1, "%s matches carriage return")
assertMatch("%s", "\f",         true, 1, 1, "%s matches form feed")
assertMatch("%s", "a",          nil,  nil, nil, "%s does not match letter")
assertMatch("%S", "a",          true, 1, 1, "%S matches non-whitespace")
assertMatch("%S", " ",          nil,  nil, nil, "%S does not match space")

----------------------------------------------------------------------------------------------------
print("  [12] %p -- punctuation...")
assertMatch("%p", "!",          true, 1, 1, "%p matches '!'")
assertMatch("%p", "/",          true, 1, 1, "%p matches '/'")
assertMatch("%p", ":",          true, 1, 1, "%p matches ':'")
assertMatch("%p", "@",          true, 1, 1, "%p matches '@'")
assertMatch("%p", "[",          true, 1, 1, "%p matches '['")
assertMatch("%p", "`",          true, 1, 1, "%p matches '`'")
assertMatch("%p", "{",          true, 1, 1, "%p matches '{'")
assertMatch("%p", "~",          true, 1, 1, "%p matches '~'")
assertMatch("%p", "a",          nil,  nil, nil, "%p does not match letter")
assertMatch("%p", "1",          nil,  nil, nil, "%p does not match digit")
assertMatch("%P", "a",          true, 1, 1, "%P matches non-punctuation")
assertMatch("%P", "!",          nil,  nil, nil, "%P does not match punctuation")

----------------------------------------------------------------------------------------------------
print("  [13] %cX -- control characters...")
assertMatch("%cA", "\001",      true, 1, 1, "%cA matches ctrl-A (\\001)")
assertMatch("%cZ", "\026",      true, 1, 1, "%cZ matches ctrl-Z (\\026)")
assertMatch("%cA", "a",         nil,  nil, nil, "%cA does not match 'a'")

----------------------------------------------------------------------------------------------------
print("  [14] %eFFFF -- unicode codepoint escape...")
assertMatch("%e0041", "A",      true, 1, 1, "%e0041 matches 'A' (U+0041)")
assertMatch("%e0041", "B",      nil,  nil, nil, "%e0041 does not match 'B'")

----------------------------------------------------------------------------------------------------
print("  [15] Sets -- basic...")
assertMatch("[abc]",  "a",      true, 1, 1, "Set: literal match 'a'")
assertMatch("[abc]",  "b",      true, 1, 1, "Set: literal match 'b'")
assertMatch("[abc]",  "d",      nil,  nil, nil, "Set: non-member")
assertMatch("[^abc]", "d",      true, 1, 1, "Negated set: non-member matches")
assertMatch("[^abc]", "a",      nil,  nil, nil, "Negated set: member does not match")

----------------------------------------------------------------------------------------------------
print("  [16] Sets -- ranges...")
assertMatch("[a-z]",  "m",      true, 1, 1, "Set range: lowercase mid")
assertMatch("[a-z]",  "a",      true, 1, 1, "Set range: range start")
assertMatch("[a-z]",  "z",      true, 1, 1, "Set range: range end")
assertMatch("[a-z]",  "A",      nil,  nil, nil, "Set range: outside range")
assertMatch("[0-9]",  "5",      true, 1, 1, "Set range: digit mid")
assertMatch("[0-9]",  "a",      nil,  nil, nil, "Set range: letter not in digit range")
assertMatch("[^a-z]", "A",      true, 1, 1, "Negated range: uppercase matches")
assertMatch("[^a-z]", "m",      nil,  nil, nil, "Negated range: lowercase does not match")
assertMatch("[A-Za-z0-9]", "q", true, 1, 1, "Set: multi-range match")
assertMatch("[A-Za-z0-9]", "-", nil,  nil, nil, "Set: multi-range non-match")

----------------------------------------------------------------------------------------------------
print("  [17] Sets -- nested character classes...")
assertMatch("[%d]",   "5",      true, 1, 1, "Set with %d class: digit")
assertMatch("[%d]",   "a",      nil,  nil, nil, "Set with %d class: non-digit")
assertMatch("[%w]",   "_",      true, 1, 1, "Set with %w class: underscore")
assertMatch("[%a%d]", "5",      true, 1, 1, "Set with %a and %d: digit")
assertMatch("[%a%d]", "z",      true, 1, 1, "Set with %a and %d: letter")
assertMatch("[%a%d]", "-",      nil,  nil, nil, "Set with %a and %d: hyphen")

----------------------------------------------------------------------------------------------------
print("  [18] Sets -- compound (ranges + literals + classes)...")
assertMatch("[a-z_]",      "_",  true, 1, 1, "Compound set: range + literal underscore")
assertMatch("[a-z_]",      "m",  true, 1, 1, "Compound set: range matches")
assertMatch("[a-z_]",      "A",  nil,  nil, nil, "Compound set: uppercase outside")
assertMatch("[%da-f]",     "3",  true, 1, 1, "Compound set: class + range, digit via class")
assertMatch("[%da-f]",     "e",  true, 1, 1, "Compound set: class + range, letter in range")
assertMatch("[%da-f]",     "g",  nil,  nil, nil, "Compound set: class + range, letter outside")
assertMatch("[^%d_]",      "a",  true, 1, 1, "Negated compound: non-digit, non-underscore")
assertMatch("[^%d_]",      "5",  nil,  nil, nil, "Negated compound: digit excluded")
assertMatch("[^%d_]",      "_",  nil,  nil, nil, "Negated compound: underscore excluded")
assertMatch("[a-zA-Z0-9_]","_",  true, 1, 1, "Compound set: full word chars via ranges")
assertMatch("[a-zA-Z0-9_]","-", nil,  nil, nil, "Compound set: hyphen not in word chars")

----------------------------------------------------------------------------------------------------
-- ALTERNATION
----------------------------------------------------------------------------------------------------
print("  [19] Alternation | ...")
assertMatch("a|b", "a",     true, 1, 1, "Alternation: first branch")
assertMatch("a|b", "b",     true, 1, 1, "Alternation: second branch")
assertMatch("a|b", "c",     nil,  nil, nil, "Alternation: no branch matches")
assertMatch("cat|dog", "dog", true, 1, 3, "Alternation: multi-char branch")
assertMatch("a|b|c", "c",   true, 1, 1, "Alternation: three branches")
assertMatch("a|", "a",      true, 1, 1, "Alternation: empty right branch matches a")
assertMatch("a|", "b",      true, 1, 0, "Alternation: empty right branch matches empty string")
assertMatch("|a", "a",      true, 1, 0, "Alternation: empty left branch matches empty string before a")
assertMatch("a||c", "b",    true, 1, 0, "Alternation: middle empty branch matches empty string")

----------------------------------------------------------------------------------------------------
print("  [20] Quantifiers -- greedy...")
assertMatch("a?", "b",        true, 1, 0, "Greedy ?: empty match")
assertMatch("a?", "a",        true, 1, 1, "Greedy ?: matches 1")
assertMatch("a?", "aa",       true, 1, 1, "Greedy ?: matches 1 out of many")
assertMatch("a*", "b",        true, 1, 0, "Greedy *: empty match")
assertMatch("a*", "a",        true, 1, 1, "Greedy *: matches 1")
assertMatch("a*", "aaa",      true, 1, 3, "Greedy *: matches all")
assertMatch("a+", "b",        nil,  nil, nil, "Greedy +: requires 1")
assertMatch("a+", "a",        true, 1, 1, "Greedy +: matches 1")
assertMatch("a+", "aaa",      true, 1, 3, "Greedy +: matches all")
assertMatch("a{2}", "a",      nil,  nil, nil, "Greedy {2}: requires 2")
assertMatch("a{2}", "aa",     true, 1, 2, "Greedy {2}: matches 2")
assertMatch("a{2}", "aaa",    true, 1, 2, "Greedy {2}: matches exactly 2")
assertMatch("a{2,4}", "a",    nil,  nil, nil, "Greedy {2,4}: requires 2")
assertMatch("a{2,4}", "aa",   true, 1, 2, "Greedy {2,4}: matches 2")
assertMatch("a{2,4}", "aaaaa",true, 1, 4, "Greedy {2,4}: matches up to 4")
assertMatch("a{2,}", "a",     nil,  nil, nil, "Greedy {2,}: requires 2")
assertMatch("a{2,}", "aaaaa", true, 1, 5, "Greedy {2,}: matches all >= 2")

----------------------------------------------------------------------------------------------------
print("  [21] Quantifiers -- lazy...")
assertMatch("a??", "a",       true, 1, 0, "Lazy ??: empty match favored")
assertMatch("a??a", "a",      true, 1, 1, "Lazy ??: matches 1 to satisfy rest")
assertMatch("a*?", "aaa",     true, 1, 0, "Lazy *?: empty match favored")
assertMatch("a*?a", "aaa",    true, 1, 1, "Lazy *?: matches enough to satisfy rest")
assertMatch("a+?", "aaa",     true, 1, 1, "Lazy +?: matches exactly 1")
assertMatch("a+?a", "aaa",    true, 1, 2, "Lazy +?: matches enough to satisfy rest")
assertMatch("a{2,4}?", "aaaa",true, 1, 2, "Lazy {2,4}?: matches exactly 2")

----------------------------------------------------------------------------------------------------
print("  [22] Quantifiers -- possessive...")
assertMatch("a?+a", "a",      nil,  nil, nil, "Possessive ?+: no backtrack, fails rest")
assertMatch("a*+a", "aaa",    nil,  nil, nil, "Possessive *+: consumes all, fails rest")
assertMatch("a++a", "aaa",    nil,  nil, nil, "Possessive ++: consumes all, fails rest")

----------------------------------------------------------------------------------------------------
print("  [23] Quantifiers -- backtracking edge cases...")
-- greedy backtracks to let 'c' match
assertMatch(".*c", "abcc",    true, 1, 4, "Greedy *: backtracks to match 'c'")
-- lazy expands to let 'c' match
assertMatch(".*?c", "abcc",   true, 1, 3, "Lazy *?: expands to match 'c'")
-- possessive does not backtrack
assertMatch(".*+c", "abcc",   nil,  nil, nil, "Possessive *+: fails to backtrack for 'c'")
-- nested quantifier: inner + must backtrack when outer continuation needs chars
assertMatch("(a+)+a", "aaaaa", true, 1, 5, "Nested quantifiers: inner + backtracks for trailing literal")
assertMatch("(a+)+a", "aa",    true, 1, 2, "Nested quantifiers: minimal inner match + literal")
assertMatch("(a+)+a", "a",     nil,  nil, nil, "Nested quantifiers: single a cannot satisfy trailing a")

----------------------------------------------------------------------------------------------------
print("  [24] Quantifiers -- inside alternations...")
assertMatch("a|b+", "bb",    true, 1, 2, "Alternation: quantified right branch")
assertMatch("a+|b", "aa",    true, 1, 2, "Alternation: quantified left branch")
assertMatch("a.*b|c", "axxb",true, 1, 4, "Alternation: complex quantified left branch")
assertMatch("a.*b|c", "c",   true, 1, 1, "Alternation: complex left branch fails, right branch matches")
assertMatch("a|b.*c", "bxxxc",true,1, 5, "Alternation: complex right branch matches")
assertMatch("a|b.*c", "a",   true, 1, 1, "Alternation: complex right branch fails, left branch matches")
assertMatch("a.*b|a.*c", "ac", true, 1, 2, "Alternation: full branch backtrack with quantifiers")

----------------------------------------------------------------------------------------------------
-- GROUPS & CAPTURES
----------------------------------------------------------------------------------------------------
print("  [25] Capturing groups (...)...")
assertMatch("(a)",      "a",    true, 1, 1, "Group: single char")
assertMatch("(ab)c",   "abc",   true, 1, 3, "Group: then literal")
assertMatch("a(b)c",   "abc",   true, 1, 3, "Group: in the middle")
assertMatch("(abc)",   "xabc",  true, 2, 4, "Group: searched string")
assertCapture("(a)",   "a",  1, "a",  "Capture 1: single char")
assertCapture("(ab)",  "xaby", 1, "ab", "Capture 1: two chars")
assertCapture("a(b)c", "abc", 1, "b",  "Capture 1: middle char")
assertCapture("(a)(b)(c)", "abc", 1, "a", "Capture 1 of 3")
assertCapture("(a)(b)(c)", "abc", 2, "b", "Capture 2 of 3")
assertCapture("(a)(b)(c)", "abc", 3, "c", "Capture 3 of 3")

----------------------------------------------------------------------------------------------------
print("  [26] Non-capturing groups (?:...)...")
assertMatch("(?:ab)c",  "abc",  true, 1, 3, "Non-cap group: then literal")
assertMatch("(?:a)+",   "aaa",  true, 1, 3, "Non-cap group: with quantifier")
assertNoCapture("(?:ab)c", "abc", "Non-cap group: creates no capture")

----------------------------------------------------------------------------------------------------
print("  [27] Named capturing groups (?<name>...)...")
assertMatch("(?<foo>ab)c", "abc", true, 1, 3, "Named group: then literal")
assertCapture("(?<foo>ab)c", "abc", "foo", "ab", "Named group captures correctly")
do
	local hasMatched, _, _, metaData = matcher("(?<first>[a-z]+)_(?<second>[a-z]+)", "hello_world")
	assert(hasMatched, "Named groups: expected match")
	local fi = metaData.captureStarts["first"]
	local fe = metaData.captureEnds["first"]
	local si = metaData.captureStarts["second"]
	local se = metaData.captureEnds["second"]
	if type(fi) == "table" then
		fi = fi[#fi] fe = fe[#fe]
		si = si[#si] se = se[#se]
	end
	assert(getSubstring("hello_world", fi, fe) == "hello", "Named capture 'first' should be 'hello'")
	assert(getSubstring("hello_world", si, se) == "world", "Named capture 'second' should be 'world'")
end

----------------------------------------------------------------------------------------------------
print("  [28] Backreferences (%1, %k<name>)...")
assertMatch("(a)%1",         "aa",      true, 1, 2, "Backreference %1: repeated char")
assertMatch("(a)%1",         "ab",      nil,  nil, nil, "Backreference %1: no match on diff")
assertMatch("(ab)%1",        "abab",    true, 1, 4, "Backreference %1: two-char repeat")
assertMatch("([a-z]+)_%1",   "cat_cat", true, 1, 7, "Backreference: repeated word")
assertMatch("([a-z]+)_%1",   "cat_dog", nil,  nil, nil, "Backreference: different words")
do
	local hasMatched, iniStr, endStr = matcher("(?<w>[a-z]+)_%k<w>", "hello_hello")
	assert(hasMatched, "Named backreference: expected match")
	assert(iniStr == 1 and endStr == 11, "Named backreference: expected full span")
	hasMatched = matcher("(?<w>[a-z]+)_%k<w>", "hello_world")
	assert(not hasMatched, "Named backreference: different words should not match")
end

----------------------------------------------------------------------------------------------------
print("  [29] Inline comments (?#...)...")
assertMatch("a(?#hello)b",  "ab",  true, 1, 2, "Comment: transparent")
assertMatch("(?#skip)abc",  "abc", true, 1, 3, "Comment: leading")

----------------------------------------------------------------------------------------------------
print("  [30] Position capture ()...")
-- () captures the current string position (1-based), just like Lua's ()
assertMatch("()",       "abc",  true, 1, 0,  "Position capture: empty match")
assertMatch("a()",      "abc",  true, 1, 1,  "Position capture: after 'a'")
assertMatch("ab()",     "abc",  true, 1, 2,  "Position capture: after 'ab'")
assertPositionCapture("()",   "abc", 1, 1,  "Position 1: at start of string (1-based)")
assertPositionCapture("a()",  "abc", 1, 2,  "Position 1: after first char")
assertPositionCapture("ab()", "abc", 1, 3,  "Position 1: after two chars")
assertPositionCapture("()a()", "abc", 1, 1, "Two positions: first at start")
assertPositionCapture("()a()", "abc", 2, 2, "Two positions: second after 'a'")
assertPositionCapture("(a()b)", "ab", 1, 2, "Position inside a capturing group: index is 1 (first pos capture)")
assertPositionCapture("()abc()", "abc", 1, 1, "Position at start and end: first")
assertPositionCapture("()abc()", "abc", 2, 4, "Position at start and end: second")
-- () must NOT consume a numbered capture slot; %1 should reference the first string capture
assertMatch("()(a)%1",    "aa", true, 1, 2, "Position capture: does not consume %1 slot")
assertCapture("()(a)%1",  "aa", 1, "a",   "Position capture: %1 refers to first string capture (a)") 
assertMatch("(a)()(b)%2", "abb", true, 1, 3, "Position capture in middle: %2 refers to (b), not ()")
assertCapture("(a)()(b)%2", "abb", 2, "b",  "Position capture in middle: %2 is (b)")

----------------------------------------------------------------------------------------------------
print("  [31] Groups + Alternation (backtracking)...")
assertMatch("(a|b)",       "b",    true, 1, 1, "Group alternation: second branch")
assertMatch("(a|b)c",      "bc",   true, 1, 2, "Group alternation: with continuation")
assertMatch("(ab|a)bc",    "abc",  true, 1, 3, "Group alternation: backtrack into group")
assertCapture("(ab|a)bc",  "abc", 1, "a", "Group alternation: capture is the matched branch")
assertMatch("(cat|dog)s",  "dogs", true, 1, 4, "Group alternation: multi-char branch")

----------------------------------------------------------------------------------------------------
print("  [32] Groups + Quantifiers...")
assertMatch("(a)+",    "aaa",  true, 1, 3, "Group quantifier: greedy +")
assertMatch("(ab)+",   "abab", true, 1, 4, "Group quantifier: two-char greedy +")
assertMatch("(?:ab)+", "abab", true, 1, 4, "Non-cap group quantifier: +")
assertCapture("(a)+", "aaa", 1, "a", "Group quantifier: capture is last iteration")

----------------------------------------------------------------------------------------------------
print("  [33] Assertions -- Anchors ^ and $...")
assertMatch("^abc", "abc",   true, 1, 3, "Start anchor ^: matches at start")
assertMatch("^abc", "xabc",  nil,  nil, nil, "Start anchor ^: fails if not at start")
assertMatch("abc$", "abc",   true, 1, 3, "End anchor $: matches at end")
assertMatch("abc$", "abcx",  nil,  nil, nil, "End anchor $: fails if not at end")
assertMatch("^(a|b)c$", "ac", true, 1, 2, "Anchors with alternates: matches ac")
assertMatch("^(a|b)c$", "bc", true, 1, 2, "Anchors with alternates: matches bc")
assertMatch("^(a|b)c$", "xac", nil, nil, nil, "Anchors with alternates: fails start anchor")
assertMatch("^(a|b)c$", "acx", nil, nil, nil, "Anchors with alternates: fails end anchor")
assertMatch("^(?:a+b)c$", "aabc", true, 1, 4, "Anchors with groups: matches")
assertMatch("^a(b$)c", "abc", nil, nil, nil, "Anchors inside groups: fails because $ is followed by c")
assertMatch("^a(b$)", "ab", true, 1, 2, "Anchors inside groups: matches")
assertMatch("^a(b|c)$", "ab", true, 1, 2, "Anchors with alternations at end: matches ab")
assertMatch("^a(b|c)$", "ac", true, 1, 2, "Anchors with alternations at end: matches ac")
assertMatch("^(a|b)(c|d)$", "ad", true, 1, 2, "Anchors with multiple alternations: matches ad")
assertMatch("(^|b)c", "c", true, 1, 1, "Start anchor inside group alternate: matches start")
assertMatch("(^|b)c", "bc", true, 1, 2, "Start anchor inside group alternate: matches literal")
assertMatch("(^|b)c", "xc", nil, nil, nil, "Start anchor inside group alternate: fails")
assertMatch("a($|b)", "a", true, 1, 1, "End anchor inside group alternate: matches end")
assertMatch("a($|b)", "ab", true, 1, 2, "End anchor inside group alternate: matches literal")
assertMatch("a($|b)", "ax", nil, nil, nil, "End anchor inside group alternate: fails")

----------------------------------------------------------------------------------------------------
print("  [34] Assertions -- Boundaries %f and %F...")
assertMatch("a%f[%d]1", "a1", true, 1, 2, "Frontier boundary %f: letter to digit")
assertMatch("a%f[%d]b", "ab", nil,  nil, nil, "Frontier boundary %f: fails letter to letter")
assertMatch("%f[%d]1", "1",   true, 1, 1, "Frontier boundary %f: string start to digit")
assertMatch("a%F[%d]b", "ab", true, 1, 2, "Non-frontier boundary %F: letter to letter")
assertMatch("a%F[%d]1", "a1", nil,  nil, nil, "Non-frontier boundary %F: fails letter to digit")
assertMatch("a%f[%w]", "a!",  true, 1, 1, "Frontier boundary %f[%w]: word to non-word")
assertMatch("%f[%w]a", " a",  true, 2, 2, "Frontier boundary %f[%w]: non-word to word")

----------------------------------------------------------------------------------------------------
print("  [35] Assertions -- Balanced Match %bxy...")
assertMatch("%b()", "(a(b)c)", true, 1, 7, "Balanced match %b(): nested parentheses")
assertMatch("%b{}", "{abc{def}}", true, 1, 10, "Balanced match %b{}: nested curly braces")
assertMatch("%b()", "(ab", nil, nil, nil, "Balanced match %b(): unclosed")
assertMatch("x%b()y", "x(a)y", true, 1, 5, "Balanced match %b(): within string")

----------------------------------------------------------------------------------------------------
print("  [36] Assertions -- Positive Lookahead...")
assertMatch("a(?=b)b", "ab", true, 1, 2, "Positive lookahead: matches")
assertMatch("a(?=b)c", "abc", nil, nil, nil, "Positive lookahead: fails")
assertMatch("a(?=[0-9])", "a1", true, 1, 1, "Lookahead with set: matches before digit")
assertMatch("a(?=[0-9])", "ab", nil, nil, nil, "Lookahead with set: fails before letter")
assertMatch("a(?=b+c)b", "abbbc", true, 1, 2, "Lookahead with greedy quantifier: matches")
assertMatch("a(?=b{2,3}c)b", "abbc", true, 1, 2, "Lookahead with range quantifier: matches")
assertMatch("a(?=b|c)", "ab", true, 1, 1, "Lookahead with alternate: matches branch 1")
assertMatch("a(?=b|c)", "ac", true, 1, 1, "Lookahead with alternate: matches branch 2")
assertMatch("^(?=a)a", "ab", true, 1, 1, "Lookahead with start anchor outside: matches")
assertMatch("(?=^a)a", "ab", true, 1, 1, "Lookahead with start anchor inside: matches")
assertMatch("a(?=b$)", "ab", true, 1, 1, "Lookahead with end anchor inside: matches")
assertMatch("a(?=(b))", "ab", true, 1, 1, "Lookahead with group: matches")
assertCapture("a(?=(b))", "ab", 1, "b", "Lookahead with group: captures inside lookahead")
assertMatch("(?=a)+a", "a", true, 1, 1, "Quantifier outside positive lookahead: greedy +")
assertMatch("(?=a)*a", "a", true, 1, 1, "Quantifier outside positive lookahead: greedy *")
assertMatch("(?=a)?a", "a", true, 1, 1, "Quantifier outside positive lookahead: greedy ?")
assertMatch("a(?=b)?(b|c)", "ac", true, 1, 2, "Quantifier outside positive lookahead with ?: fallback matching")
assertMatch("(?=a)(?=ab)abc", "abc", true, 1, 3, "Consecutive positive lookaheads: matches")
assertMatch("(?=(?=a)a)a", "a", true, 1, 1, "Nested positive lookaheads: matches")
assertMatch("(?=(a))%1", "a", true, 1, 1, "Lookahead with group and backreference: matches")
assertMatch("(?=(a))%1", "b", nil, nil, nil, "Lookahead with group and backreference: fails")

print("  [37] Assertions -- Negative Lookahead...")
assertMatch("a(?!b)c", "ac", true, 1, 2, "Negative lookahead: matches")
assertMatch("a(?!b)b", "ab", nil, nil, nil, "Negative lookahead: fails")
assertMatch("a(?![0-9])", "ab", true, 1, 1, "Negative lookahead with set: matches before letter")
assertMatch("a(?![0-9])", "a1", nil, nil, nil, "Negative lookahead with set: fails before digit")
assertMatch("a(?!b$)", "abc", true, 1, 1, "Negative lookahead with anchor: matches when not at end")
assertMatch("a(?!b$)", "ab", nil, nil, nil, "Negative lookahead with anchor: fails at end")
assertMatch("a(?!b)", "a", true, 1, 1, "Negative lookahead: matches at end of string")
assertMatch("(?!a)+b", "b", true, 1, 1, "Quantifier outside negative lookahead: greedy +")
assertMatch("(?!a)(?!c)b", "b", true, 1, 1, "Consecutive negative lookaheads: matches")
assertMatch("(?!a)(?!c)b", "a", nil, nil, nil, "Consecutive negative lookaheads: fails (first fails)")
assertMatch("(?!a)(?!c)b", "cb", true, 2, 2, "Consecutive negative lookaheads: fails first position but matches later")
assertMatch("(?!(?!a)b)c", "c", true, 1, 1, "Nested negative lookaheads: matches")
assertMatch("(?!(?!a)b)b", "ab", nil, nil, nil, "Nested negative lookaheads: fails")
assertMatch("(?!(a))%1", "b", nil, nil, nil, "Negative lookahead with group and backreference: fails (uncaptured group)")

print("  [38] Assertions -- Positive Lookbehind...")
assertMatch("(?<=a)b", "ab", true, 2, 2, "Positive lookbehind: matches")
assertMatch("(?<=a)b", "xb", nil, nil, nil, "Positive lookbehind: fails")
assertMatch("(?<=ab)c", "abc", true, 3, 3, "Positive lookbehind length > 1: matches")
assertMatch("(?<=[a-z])1", "a1", true, 2, 2, "Lookbehind with set: matches after letter")
assertMatch("(?<=[a-z])1", "A1", nil, nil, nil, "Lookbehind with set: fails after uppercase")
assertMatch("(?<=a{3})b", "aaab", true, 4, 4, "Lookbehind with fixed quantifier: matches")
assertMatch("(?<=a{3})b", "aab", nil, nil, nil, "Lookbehind with fixed quantifier: fails (too few)")
assertError("(?<=a+)b", "ab", "Lookbehind with variable quantifier +: parse error")
assertError("(?<=a*)b", "ab", "Lookbehind with variable quantifier *: parse error")
assertError("(?<=a?)b", "ab", "Lookbehind with variable quantifier ?: parse error")
assertError("(?<=a|bb)c", "abc", "Lookbehind with unequal-length alternate: parse error")
assertMatch("(?<=ab|cd)e", "abe", true, 3, 3, "Lookbehind with valid fixed-length alternate: matches branch 1")
assertMatch("(?<=ab|cd)e", "cde", true, 3, 3, "Lookbehind with valid fixed-length alternate: matches branch 2")
assertMatch("(?<=a|b)c", "ac", true, 2, 2, "Lookbehind with alternate: matches branch 1")
assertMatch("(?<=a|b)c", "bc", true, 2, 2, "Lookbehind with alternate: matches branch 2")
assertMatch("(?<=a|b)c", "xc", nil, nil, nil, "Lookbehind with alternate: fails")
assertMatch("(?<=^a)b", "ab", true, 2, 2, "Lookbehind with start anchor inside: matches")
assertMatch("(?<=^a)b", "xab", nil, nil, nil, "Lookbehind with start anchor inside: fails because not at start")
assertMatch("(?<=(a))b", "ab", true, 2, 2, "Lookbehind with group: matches")
assertCapture("(?<=(a))b", "ab", 1, "a", "Lookbehind with group: captures inside lookbehind")
assertMatch("(?<=a)+b", "ab", true, 2, 2, "Quantifier outside positive lookbehind: greedy +")
assertMatch("(?<=ab)(?<=b)c", "abc", true, 3, 3, "Consecutive positive lookbehinds: matches")
assertMatch("(?<=ab)(?<=b)c", "xbc", nil, nil, nil, "Consecutive positive lookbehinds: fails (first fails)")
assertMatch("(?<=(?<=a)b)c", "abc", true, 3, 3, "Nested positive lookbehinds: matches")
assertMatch("(?<=(a))%1", "aa", true, 2, 2, "Lookbehind with group and backreference: matches")
assertMatch("(?<=(a))%1", "ab", nil, nil, nil, "Lookbehind with group and backreference: fails")

print("  [39] Assertions -- Negative Lookbehind...")
assertMatch("(?<!a)b", "xb", true, 2, 2, "Negative lookbehind: matches")
assertMatch("(?<!a)b", "ab", nil, nil, nil, "Negative lookbehind: fails")
assertMatch("(?<!a|b)c", "xc", true, 2, 2, "Negative lookbehind with alternate: matches branch 1")
assertMatch("(?<!a|b)c", "ac", nil, nil, nil, "Negative lookbehind with alternate: fails branch 1")
assertMatch("(?<!a|b)c", "bc", nil, nil, nil, "Negative lookbehind with alternate: fails branch 2")
assertError("(?<!a+)b", "ab", "Negative lookbehind with variable quantifier +: parse error")
assertError("(?<!a*)b", "ab", "Negative lookbehind with variable quantifier *: parse error")
assertError("(?<!a|bb)c", "abc", "Negative lookbehind with unequal-length alternate: parse error")
assertMatch("(?<!a)+b", "b", true, 1, 1, "Quantifier outside negative lookbehind: greedy +")
assertMatch("(?<!a)(?<!b)c", "c", true, 1, 1, "Consecutive negative lookbehinds: matches")
assertMatch("(?<!a)(?<!b)c", "ac", nil, nil, nil, "Consecutive negative lookbehinds: fails (first fails)")
assertMatch("(?<!(?<=a)b)c", "c", true, 1, 1, "Nested lookbehinds (negative outer): matches")
assertMatch("(?<!(?<=a)b)c", "abc", nil, nil, nil, "Nested lookbehinds (negative outer): fails")

print("  [40] Flags -- i (Case Insensitive)...")
assertMatch("abc", "ABC", true, 1, 3, "Global i flag: literal matches", "i")
assertMatch("[a-c]", "B", true, 1, 1, "Global i flag: set range matches", "i")
assertMatch("[x-z]", "B", nil, nil, nil, "Global i flag: set range fails", "i")
assertMatch("a(?i)bc", "aBC", true, 1, 3, "Inline toggle i flag: matches")
assertMatch("(?i)a(?-i)b", "Ab", true, 1, 2, "Inline toggle and disable i flag: matches")
assertMatch("(?i)a(?-i)b", "AB", nil, nil, nil, "Inline toggle and disable i flag: fails on disabled part")
assertMatch("a(?i:b)c", "aBc", true, 1, 3, "Scoped inline i flag: matches")
assertMatch("a(?i:b)c", "aBC", nil, nil, nil, "Scoped inline i flag: fails outside scope")

print("  [41] Flags -- m (Multiline)...")
assertMatch("^b", "a\nb", true, 3, 3, "Global m flag: ^ matches after newline", "m")
assertMatch("^b", "a\nb", nil, nil, nil, "Without m flag: ^ fails after newline")
assertMatch("a$", "a\nb", true, 1, 1, "Global m flag: $ matches before newline", "m")
assertMatch("a$", "a\nb", nil, nil, nil, "Without m flag: $ fails before newline")
assertMatch("a\n(?m)^b", "a\nb", true, 1, 3, "Inline m flag: matches")
assertMatch("(?m:^b)", "a\nb", true, 3, 3, "Scoped m flag: matches")

print("  [42] Flags -- s (DotAll)...")
assertMatch("a.b", "a\nb", true, 1, 3, "Global s flag: . matches newline", "s")
assertMatch("a.b", "a\nb", nil, nil, nil, "Without s flag: . fails on newline")
assertMatch("a(?s:.)b", "a\nb", true, 1, 3, "Scoped s flag: matches")
assertMatch("(?s)a(?-s:.)b", "a\nb", nil, nil, nil, "Inline toggle s flag with scoped disable: fails on newline")

print("  [43] Flags -- n (No Auto-Capture)...")
assertMatch("(a)", "a", true, 1, 1, "Global n flag: matches", "n")
assertNoCapture("(a)", "a", "Global n flag: standard group does not capture", "n")
assertMatch("(?n:(a))", "a", true, 1, 1, "Scoped n flag: matches")
assertNoCapture("(?n:(a))", "a", "Scoped n flag: standard group does not capture")
assertMatch("(?n)(?<foo>a)", "a", true, 1, 1, "Inline n flag: matches named group")
assertCapture("(?n)(?<foo>a)", "a", "foo", "a", "Inline n flag: named group still captures")

print("  [44] Flags -- Complex Modifiers & Edge Cases...")
assertMatch("(?im-s)", "", true, 1, 0, "Multiple toggles: parses without error")
assertMatch("(?i:a(?-i:b)c)", "AbC", true, 1, 3, "Nested scopes with disables: matches")
assertMatch("(?i:a(?-i:b)c)", "ABC", nil, nil, nil, "Nested scopes with disables: fails correctly")
assertError("(?z)", "", "Invalid inline flag: parse error")
assertMatch("(?i-m:)", "", true, 1, 0, "Empty scoped inline flag: matches empty string")

print("  [45] Advanced Groups -- Atomic (?>...)...")
-- Basic behavior
assertMatch("(?>a)b", "ab", true, 1, 2, "Atomic: simple match")
assertMatch("(?>ab)", "ab", true, 1, 2, "Atomic: literal match")
assertMatch("a(?>bc|b)c", "abcc", true, 1, 4, "Atomic: alternation commits to first match")
assertMatch("a(?>bc|b)c", "abc", nil, nil, nil, "Atomic: prevents backtracking into alternation")
assertMatch("(?>a+)a", "aa", nil, nil, nil, "Atomic: quantifier inside group prevents backtracking")
assertMatch("(?>a*)a", "a", nil, nil, nil, "Atomic: zero-or-more inside, cannot backtrack")
-- Quantifiers on the atomic group itself
assertMatch("(?>a)*a", "a", true, 1, 1, "Atomic: outer * can backtrack on repetition count")
assertMatch("(?>a)+", "aaa", true, 1, 3, "Atomic: outer + repeats")
assertMatch("(?>a+)+", "aaa", true, 1, 3, "Atomic: quantifier inside and outside")
assertMatch("(?>a*)+", "aaa", true, 1, 3, "Atomic: zero-or-more inside, plus outside")
assertMatch("(?>a){2}", "aa", true, 1, 2, "Atomic: exact count quantifier")
assertMatch("(?>a){2}", "a", nil, nil, nil, "Atomic: exact count quantifier fail")
assertMatch("a(?>bc|b)c", "abcc", true, 1, 4, "Atomic: commits to bc, c after matches")
assertMatch("a(?>bc|b)c", "abc", nil, nil, nil, "Atomic: commits to bc, no c left after")
assertMatch("a(?:bc|b)c", "abc", true, 1, 3, "Non-atomic control: backtracks to b, c matches")
-- Capturing inside atomic groups (atomic is non-capturing itself, but inner groups can capture)
assertMatch("((?>a+))%1", "aaa", nil, nil, nil, "Atomic: inner capture, backref to it (group 1 = 'aa', %1 needs 'aa' but only 'a' left)")
assertMatch("((?>a))%1", "aa", true, 1, 2, "Atomic: inner capture backref succeeds")
assertMatch("((?>a))%1", "ab", nil, nil, nil, "Atomic: inner capture backref fails on mismatch")
assertCapture("((?>cat|ca))t", "catt", 1, "cat", "Atomic: inner group captures committed value (cat)")
assertMatch("((?>cat|ca))t", "cat", nil, nil, nil, "Atomic: commits to cat, no t left")
assertMatch("((?>cat|ca))t", "catt", true, 1, 4, "Atomic: commits to cat, t follows")
-- Nested atomic
assertMatch("(?>.(?>b+))c", "abbc", true, 1, 4, "Atomic: nested atomic groups")
assertMatch("(?>.(?>b+))c", "abc", true, 1, 3, "Atomic: nested atomic, single b")

print("  [46] Advanced Groups -- Branch Reset (?|...)...")
-- Basic non-match
assertMatch("(?|(a)|(b)(c)|(d))e(f)", "ae", nil, nil, nil, "Branch reset: f fails")
-- Capture alignment: branch with 2 groups
do
	local hasMatched, _, _, metaData = matcher("(?|(a)|(b)(c)|(d))e(f)", "bcef")
	assert(hasMatched, "Branch reset: bcef should match")
	-- b=group1, c=group2. outer f=group3 (max inside was 2)
	assert(metaData.captureStarts[1][1] == 1, "Branch reset bcef: group1 init=1")
	assert(metaData.captureStarts[2][1] == 2, "Branch reset bcef: group2 init=2")
	assert(metaData.captureStarts[3][1] == 4, "Branch reset bcef: group3 init=4")
end
-- Capture alignment: branch with 1 group (shorter branch)
do
	local hasMatched, _, _, metaData = matcher("(?|(a)|(b)(c)|(d))e(f)", "def")
	assert(hasMatched, "Branch reset: def should match")
	assert(metaData.captureStarts[1][1] == 1, "Branch reset def: group1=d")
	assert(not metaData.captureStarts[2],     "Branch reset def: group2 is nil")
	assert(metaData.captureStarts[3][1] == 3, "Branch reset def: group3=f")
end
-- Backreferences inside branch reset
assertMatch("(?|(a)|(b))%1", "aa", true, 1, 2, "Branch reset: backref %1 to first branch")
assertMatch("(?|(a)|(b))%1", "bb", true, 1, 2, "Branch reset: backref %1 to second branch")
assertMatch("(?|(a)|(b))%1", "ab", nil, nil, nil, "Branch reset: backref %1 fails on mismatch")
assertMatch("(?|(ab)|(a)(b))%1", "abab", true, 1, 4, "Branch reset: backref %1 two-char first branch")
assertMatch("(?|(ab)|(a)(b))%1", "aba", true, 1, 3, "Branch reset: backref %1 to second branch (a)")
-- Backreferences to outer group after branch reset
assertMatch("(?|(a)|(b)(c))x(d)%3", "axdd", true, 1, 4, "Branch reset: outer group %3 backref")
assertMatch("(?|(a)|(b)(c))x(d)%3", "bxdd", nil, nil, nil, "Branch reset: outer %3 fails (c+d mismatch)")
assertCapture("(?|(a)|(b)(c))x(d)%3", "axdd", 3, "d", "Branch reset: outer group 3 captured value")
-- With lookahead
assertMatch("(?|(?=a)(a)|(?=b)(b))", "a", true, 1, 1, "Branch reset: with lookahead")
assertMatch("(?|(?=a)(a)|(?=b)(b))%1", "aa", true, 1, 2, "Branch reset: lookahead branch backref")
assertMatch("(?|(?=a)(a)|(?=b)(b))%1", "bb", true, 1, 2, "Branch reset: lookahead second branch backref")
-- Nested groups inside branch reset
assertMatch("(?|((a))|b)c", "ac", true, 1, 2, "Branch reset: nested groups")
assertCapture("(?|((a))|b)c", "ac", 1, "a", "Branch reset: outer nested group 1")
assertCapture("(?|((a))|b)c", "ac", 2, "a", "Branch reset: inner nested group 2")
assertMatch("(?|((a))|b)c%2", "aca", true, 1, 3, "Branch reset: backref %2 to inner nested group")
assertMatch("(?|((a))|b)c%1", "aca", true, 1, 3, "Branch reset: backref %1 to outer nested group")

print("  [47] Advanced Groups -- Recursion (?R), (?1), (?&name)...")
-- Root recursion: matches 'a', then recursively calls the whole pattern which matches 'a', then 'b', then 'b'
assertMatch("a(?R)?b", "aabb", true, 1, 4, "Recursion: whole pattern recursion (?R)")
assertMatch("a(?0)?b", "aabb", true, 1, 4, "Recursion: whole pattern recursion (?0)")
assertMatch("a(?R)?b", "ab", true, 1, 2, "Recursion: recursion is optional and skipped")
-- Numbered recursion
assertMatch("(a(?1)?b)", "aabb", true, 1, 4, "Recursion: numbered recursion (?1)")
assertMatch("(a)(?1)", "aa", true, 1, 2, "Recursion: backreference to group 1 using (?1)")
assertMatch("(a)(?1)", "ab", nil, nil, nil, "Recursion: fails if group 1 pattern doesn't match")
assertMatch("(a|b)(?1)", "ab", true, 1, 2, "Recursion: (?1) re-evaluates the group 1 pattern, matching 'b'")
-- The difference between backreference %1 and recursion (?1)
assertMatch("(a|b)%1", "ab", nil, nil, nil, "Backref: %1 requires exact captured text, fails 'ab'")
-- Forward reference
assertMatch("(?1)(a)", "aa", true, 1, 2, "Recursion: forward reference to (?1)")
-- Named recursion
assertMatch("(?<P>a(?&P)?b)", "aabb", true, 1, 4, "Recursion: named recursion (?&P)")
assertMatch("(?<P>a)(?&P)", "aa", true, 1, 2, "Recursion: backreference to named group")
-- Quantified recursion
assertMatch("(a)(?1)+", "aaa", true, 1, 3, "Recursion: quantified recursive group")
assertMatch("(a)(?1){2}", "aaa", true, 1, 3, "Recursion: exact-count quantified recursive group")
-- Complex nesting
assertMatch("(((a)))(?2)", "aa", true, 1, 2, "Recursion: deep group reference")

-- Recursion mixed with alternation
assertMatch("a(?R)?b|c", "aabb", true, 1, 4, "Recursion: recursive alt matched")
assertMatch("a(?R)?b|c", "c", true, 1, 1, "Recursion: non-recursive alt matched")
assertMatch("a(?R)?b|c", "acb", true, 1, 3, "Recursion: recursion evaluates inner alt")

-- Recursion inside lookahead
assertMatch("^(?=(a(?1)?b))a+b+", "aabb", true, 1, 4, "Recursion: subroutine inside positive lookahead (calling inner group)")
assertMatch("^(?=(a(?1)?b))a+b+", "aab", nil, nil, nil, "Recursion: lookahead prevents match on incomplete string")

-- Lookaround inside recursion
assertMatch("^(a(?=a|b)(?1)?b)", "aabb", true, 1, 4, "Recursion: subroutine contains lookahead")
assertMatch("^(a(?=b)(?1)?b)", "aabb", nil, nil, nil, "Recursion: subroutine contains lookahead that fails")

-- Recursion and backreferences mixed
assertMatch("(a)(?1)%1", "aaa", true, 1, 3, "Recursion: subroutine then backreference")
assertMatch("(a|b)(?1)%1", "aba", true, 1, 3, "Recursion: subroutine evaluates 'b', then backreference evaluates 'a'")

-- Multiple quantifiers on recursion
assertMatch("(a)(?1)*", "aaaaa", true, 1, 5, "Recursion: star quantifier on subroutine")
assertMatch("(a|b)(?1){2,3}", "abb", true, 1, 3, "Recursion: bounded quantifier on subroutine")
assertMatch("(?<X>x|y)(?&X){2}", "xyy", true, 1, 3, "Recursion: quantified named subroutine")

-- Mutual recursion-like behavior (calling another group that calls back - not fully supported without careful regex, but let's test deep calls)
assertMatch("(?<A>a(?&B)?)(?<B>b(?&A)?)", "ab", true, 1, 2, "Recursion: call another named group")
assertMatch("(?<A>a(?&B)?)(?<B>b(?&A)?)", "aba", true, 1, 3, "Recursion: ping pong calls")

-- Key-Value multiline format recursion
assertMatch("^([%w]+): ([%w]+)$[\n ]*(?R)?", "name: john\nage: 10", true, 1, 18, "Recursion: key-value multiline recursion", "m")


print("  [48] Error Handling...")
assertError("(?<>abc)", "", "Empty named group: parse error")
assertError("(?P=name)", "", "PCRE-style named backref: parse error")
assertError("(?>", "", "Unterminated atomic group: parse error")
assertError("(?<name>", "", "Unterminated named group: parse error")
assertError("(?&)", "", "Empty subroutine name: parse error")
assertError("%b", "", "Balanced match missing delimiters: parse error")
assertError("a{3,1}", "", "Reversed quantifier range: parse error")
assertError("[z-a]", "", "Reversed set range: parse error")
assertError("[abc", "", "Unclosed set: parse error")
assertMatch("%1", "a", nil, nil, nil, "Undefined backreference: runtime no-match")
assertMatch("(?5)(a)", "a", nil, nil, nil, "Non-existent group subroutine: runtime no-match")
assertMatch("(?999)(a)", "a", nil, nil, nil, "Out-of-bounds group index: runtime no-match")

print("  [49] Cross-Feature Integration...")
-- Multi-iteration capture history
do
	local hasMatched, _, _, metaData = matcher("(a)+", "aaa")
	assert(hasMatched, "Capture history: (a)+ should match")
	local inits = metaData.captureStarts[1]
	assert(type(inits) == "table" and #inits == 3, "Capture history: three iterations recorded")
	assert(inits[1] == 1 and inits[2] == 2 and inits[3] == 3, "Capture history: positions 1,2,3")
end
do
	local hasMatched, _, _, metaData = matcher("((a)(b))+", "abab")
	assert(hasMatched, "Capture history: nested quantified groups should match")
	local g1 = metaData.captureStarts[1]
	local g2 = metaData.captureStarts[2]
	local g3 = metaData.captureStarts[3]
	assert(#g1 == 2 and #g2 == 2 and #g3 == 2, "Capture history: nested groups record two iterations each")
end
-- Nested group backtracking with capture rollback (branch isolation)
do
	local hasMatched, _, _, metaData = matcher("(a(b)|c(d))e", "cde")
	assert(hasMatched, "Capture rollback: c-branch match")
	assert(metaData.captureStarts[1][1] == 1, "Capture rollback: group1 captured")
	assert(not metaData.captureStarts[2], "Capture rollback: unused nested group2 absent")
	assert(metaData.captureStarts[3][1] == 2, "Capture rollback: group3 captured on c-branch")
end
do
	local hasMatched, _, _, metaData = matcher("(a(b)|c(d))e", "abe")
	assert(hasMatched, "Capture rollback: a-branch match")
	assert(metaData.captureStarts[2][1] == 2, "Capture rollback: nested group2 captured on a-branch")
	assert(not metaData.captureStarts[3], "Capture rollback: unused group3 absent")
end
-- Recursion + branch reset
assertMatch("(?|(?R)|b)", "ab", true, 2, 2, "Recursion + branch reset: second branch via recursion")
assertMatch("(?|(?R)|b)", "b", true, 1, 1, "Recursion + branch reset: direct b branch")
-- Recursion + atomic group
assertMatch("a(?>(?R))?b", "aabb", true, 1, 4, "Recursion + atomic: optional atomic recursion")
assertMatch("a(?>(?R))?b", "ab", true, 1, 2, "Recursion + atomic: skip recursion")
-- Atomic inside recursion
assertMatch("(a(?>b|bc)(?1)?c)", "abcc", true, 1, 3, "Atomic inside recursion: matches abc prefix")
assertMatch("(a(?>b|bc)(?1)?c)", "abc", true, 1, 3, "Atomic inside recursion: b path")
-- Named group + recursion + flags
assertMatch("(?i:(?<P>a(?&P)?b))", "AaBb", true, 1, 4, "Named recursion + case-insensitive flag")
-- Branch reset + backreferences across alternation depth
assertMatch("(?|((a)(b))|(c))%2", "aba", true, 1, 3, "Branch reset: deep backref %2 first branch")
assertMatch("(?|((a)(b))|(c))%2", "cb", nil, nil, nil, "Branch reset: deep backref fails on second branch")
assertCapture("(?|((a)(b))|(c))%2", "aba", 2, "a", "Branch reset: group2 capture on deep branch")
assertCapture("(?|((a)(b))|(c))%2", "aba", 3, "b", "Branch reset: group3 inner capture on deep branch")

print("  [50] Depth Limits...")
do
	local config = require("config")
	local saved = config.get()
	config.set({ maxRecursionDepth = 5 })
	assertMatch("(?R)", "x", nil, nil, nil, "Recursion depth limit: infinite (?R) fails gracefully")
	config.set(saved)
end
do
	local config = require("config")
	local saved = config.get()
	config.set({ maxBacktrackDepth = 10 })
	assertMatch("(a+)+b", "aaaaaaaaaaaaac", nil, nil, nil, "Backtrack limit: catastrophic pattern fails gracefully")
	config.set(saved)
end
do
	local config = require("config")
	local saved = config.get()
	local expaghetti = require("expaghetti")({ maxRecursionDepth = 100, maxBacktrackDepth = 1000 })
	assert(type(expaghetti.match) == "function", "init entry point: returns match function")
	local hasMatched, iniStr, endStr = expaghetti.match("a", "a")
	assert(hasMatched and iniStr == 1 and endStr == 1, "init entry point: configured instance matches")
	config.set(saved)
end

----------------------------------------------------------------------------------------------------
print("  [51] Quantifiers -- extensive backtracking (greedy, lazy, possessive, groups, alternates)...")

-- Greedy backtracks for trailing literals; possessive does not
assertMatch("a+a",      "aaa",  true, 1, 3, "Greedy +: keeps one char for trailing a")
assertMatch("a++a",     "aaa",  nil,  nil, nil, "Possessive ++: no backtrack for trailing a")
assertMatch("a*a",      "aaa",  true, 1, 3, "Greedy *: backtracks star for trailing a")
assertMatch("a*+a",     "aaa",  nil,  nil, nil, "Possessive *+: no backtrack for trailing a")
assertMatch("a?a",      "aa",   true, 1, 2, "Greedy ?: backtracks optional for trailing a")
assertMatch("a?+a",     "aa",   true, 1, 2, "Possessive ?+: zero-or-one then literal")

-- Dot quantifiers with trailing literal
assertMatch(".+b",      "abbb", true, 1, 4, "Greedy .+: backtracks to leave b")
assertMatch(".++b",     "abbb", nil,  nil, nil, "Possessive .++: cannot backtrack for b")
assertMatch(".+?b",     "abbb", true, 1, 2, "Lazy .+?: expands minimally to reach b")
assertMatch(".*b",      "abbb", true, 1, 4, "Greedy .*: backtracks to leave b")
assertMatch(".*+b",     "abbb", nil,  nil, nil, "Possessive .*+: cannot backtrack for b")

-- Nested quantifiers inside groups (greedy inner must backtrack for outer continuation)
assertMatch("(a+)+a",   "aaaaa", true, 1, 5, "Nested +: inner backtracks, trailing a matches")
assertMatch("(a+)+a",   "aa",    true, 1, 2, "Nested +: minimal inner + trailing a")
assertMatch("(a+)+a",   "a",     nil,  nil, nil, "Nested +: single a cannot satisfy trailing a")
assertMatch("(a+)+b",   "aaab",  true, 1, 4, "Nested +: inner backtracks for trailing b")
assertMatch("(a+)+b",   "aaaaa", nil,  nil, nil, "Nested +: no trailing b available")
assertMatch("(a++)+a",   "aaaaa", nil,  nil, nil, "Nested possessive inner: no backtrack for trailing a")
assertMatch("(?:a+)+a",  "aaaaa", true, 1, 5, "Non-cap nested +: inner backtracks for trailing a")
assertMatch("(a)+a",     "aaaaa", true, 1, 5, "Group + (no inner quant): per-char outer + trailing a")
assertMatch("(a)+a",     "aaa",   true, 1, 3, "Group +: three iterations + trailing a")

-- Exact-count quantifiers on groups with inner +
assertMatch("(a+){2}",   "aa",    true, 1, 2, "Exact {2} on (a+): one a per repetition")
assertMatch("(a+){2}",   "aaa",   true, 1, 3, "Exact {2} on (a+): splits 1+2 across repetitions")
assertMatch("(a+){2}",   "a",     nil,  nil, nil, "Exact {2} on (a+): insufficient characters")
assertMatch("(a){2}a",  "aaa",   true, 1, 3, "Exact {2} on (a) + trailing a")

-- Alternation combined with quantifiers
assertMatch("(a|aa)+b", "aab",   true, 1, 3, "Alt quantified: a+aa+b")
assertMatch("(a|aa)+b", "aaa",   nil,  nil, nil, "Alt quantified: no trailing b")
assertMatch("(a|aa)+",  "aaaa",  true, 1, 4, "Alt quantified: greedy branch repetition")
assertMatch("(ab|a)+b", "abb",   true, 1, 3, "Alt quantified: ab branch + trailing b")
assertMatch("(ab|a)+b", "aab",   nil,  nil, nil, "Alt quantified: a branch cannot reach trailing b")
assertMatch("a.*b|a.*c", "ac",  true, 1, 2, "Alt: left branch backtracks for c")
assertMatch("a.*b|a.*c", "axxb", true, 1, 4, "Alt: left branch matches xxb")
assertMatch("a.*+b|a.*c", "ac", true, 1, 2, "Alt: possessive left fails, right matches c")
assertMatch("a.*+b|a.*c", "axxb", nil, nil, nil, "Alt: possessive left cannot backtrack for b")
assertMatch("(a+|b+)+c", "aaabc", true, 1, 5, "Alt quantified: mixed a/b branches + c")
assertMatch("(a+|b+)+c", "bbc",  true, 1, 3, "Alt quantified: b branch + c")

-- Quantifiers with nested groups in pattern
assertMatch("a(b+)+c",  "abbbc", true, 1, 5, "Nested group+: greedy b+ inside pattern")
assertMatch("a(b+)+c",  "abc",   true, 1, 3, "Nested group+: single b iteration")
assertMatch("x(a+)+y",   "xaaay", true, 1, 5, "Nested group+: bounded by literals")
assertMatch("(a+?)+a",   "aaaaa", true, 1, 5, "Lazy inner + with outer +: expands to fit")

-- Custom range quantifiers with trailing literal
assertMatch("a{1,3}a",  "aaaa",  true, 1, 4, "Greedy {1,3}: backtracks for trailing a")
assertMatch("a{1,3}+a", "aaaa", true, 1, 4, "Possessive {1,3}+: still leaves trailing a here")
assertMatch("a{1,3}+a", "aaa",  nil,  nil, nil, "Possessive {1,3}+: consumes all, trailing a fails")
assertMatch("a{2,4}b",  "aaab",  true, 1, 4, "Range {2,4}: backtracks for trailing b")
assertMatch("a{2,4}b",  "aaaab", true, 1, 5, "Range {2,4}: longer greedy prefix + b")

-- Multiple quantified elements
assertMatch(".+.+",     "ab",    true, 1, 2, "Two greedy .+: second dot backtracks")
assertMatch(".+.+",     "a",     nil,  nil, nil, "Two .+: insufficient chars")
assertMatch(".++.+",    "ab",    nil,  nil, nil, "Possessive .+ then .: first blocks second")

-- Atomic groups vs backtracking
assertMatch("(?>a+)+a", "aaaaa", true, 1, 5, "Atomic inner: split across outer + for trailing a")
assertMatch("(?>a+)+a", "aaa",   true, 1, 3, "Atomic inner: three chars via outer + split")
assertMatch("a(?>bc|b)c", "abc", nil, nil, nil, "Atomic alt: cannot backtrack from bc to b")

-- Capture behavior during quantifier backtracking
do
	local hasMatched, _, _, metaData = matcher("(a+)+a", "aaaaa")
	assert(hasMatched, "Nested +: capture history should match")
	local inits = metaData.captureStarts[1]
	local ends = metaData.captureEnds[1]
	assert(#inits == 2, "Nested +: two outer repetitions recorded")
	assert(getSubstring("aaaaa", inits[1], ends[1]) == "aaaa", "Nested +: first capture after inner backtrack")
	assert(getSubstring("aaaaa", inits[2], ends[2]) == "a", "Nested +: second capture is trailing group iteration")
end
do
	local hasMatched, _, _, metaData = matcher("(a|aa)+b", "aab")
	assert(hasMatched, "Alt quantified: capture history should match")
	local inits = metaData.captureStarts[1]
	local ends = metaData.captureEnds[1]
	assert(getSubstring("aab", inits[#inits], ends[#ends]) == "aa", "Alt quantified: last capture is winning branch")
end

-- Contrasting greedy vs possessive nested inner quantifier
assertMatch("(a+)+a",  "aaaaa", true, 1, 5, "Greedy inner + in group: backtracks for trailing a")
assertMatch("(a++)+a", "aaaaa", nil,  nil, nil, "Possessive inner ++ in group: no backtrack for trailing a")

----------------------------------------------------------------------------------------------------
print("  [52] Flags -- u (Unicode)...")

assertMatch("maçã", "maçã", true, 1, 6, "Unicode flag off: UTF-8 text is byte-positioned")
assertMatch("maçã", "maçã", true, 1, 4, "Unicode flag on: UTF-8 text is codepoint-positioned", "u")
assertMatch(".", "ã", true, 1, 1, "Unicode flag off: dot matches first byte of UTF-8 char")
assertMatch(".", "ã", true, 1, 1, "Unicode flag on: dot matches one codepoint", "u")
assertMatch(".+", "aã", true, 1, 3, "Unicode flag off: quantified dot counts bytes")
assertMatch(".+", "aã", true, 1, 2, "Unicode flag on: quantified dot counts codepoints", "u")
assertMatch("[ã]", "ã", true, 1, 1, "Unicode flag on: set member is one codepoint", "u")
assertMatch("[ã-ã]", "ã", true, 1, 1, "Unicode flag on: set range compares codepoint strings", "u")
assertMatch("%f[ã]ã", "ã", true, 1, 1, "Unicode flag on: frontier sees codepoint boundary", "u")
assertMatch("(ä)", "ä", true, 1, 2, "Unicode flag off: group captures bytes")
assertMatch("(ä)", "ä", true, 1, 1, "Unicode flag on: group captures one codepoint", "u")
assertCapture("(ä)", "ä", 1, "ä", "Unicode flag off: captured group contains bytes")
assertCapture("(ä)", "ä", 1, "ä", "Unicode flag on: captured group contains one codepoint", "u")
assertMatch("ä+", "äää", true, 1, 2, "Unicode flag off: literal quantifier repeats last byte")
assertMatch("ä+", "äää", true, 1, 3, "Unicode flag on: literal quantifier repeats codepoints", "u")
assertMatch("(ä)+", "ää", true, 1, 4, "Unicode flag off: group quantifier repeats bytes")
assertMatch("(ä)+", "ää", true, 1, 2, "Unicode flag on: group quantifier repeats codepoints", "u")
assertMatch("(?=ä)ä", "ä", true, 1, 2, "Unicode flag off: positive lookahead sees bytes")
assertMatch("(?=ä)ä", "ä", true, 1, 1, "Unicode flag on: positive lookahead sees codepoint", "u")
assertMatch("(?!b)ä", "ä", true, 1, 2, "Unicode flag off: negative lookahead keeps byte position")
assertMatch("(?!b)ä", "ä", true, 1, 1, "Unicode flag on: negative lookahead keeps codepoint position", "u")
assertMatch("(?<=ä)b", "äb", true, 3, 3, "Unicode flag off: positive lookbehind sees prior bytes")
assertMatch("(?<=ä)b", "äb", true, 2, 2, "Unicode flag on: positive lookbehind sees prior codepoint", "u")
assertMatch("(?<!b)ä", "ä", true, 1, 2, "Unicode flag off: negative lookbehind sees prior bytes")
assertMatch("(?<!b)ä", "ä", true, 1, 1, "Unicode flag on: negative lookbehind sees prior codepoint", "u")
assertMatch("(ã)|(b)", "ã", true, 1, 2, "Unicode flag off: alternate first branch spans bytes")
assertCapture("(ã)|(b)", "ã", 1, "ã", "Unicode flag off: alternate first branch captured")
assertCaptureAbsent("(ã)|(b)", "ã", 2, "Unicode flag off: alternate second branch not captured")
assertMatch("(ã)|(b)", "ã", true, 1, 1, "Unicode flag on: alternate first branch spans codepoint", "u")
assertCapture("(ã)|(b)", "ã", 1, "ã", "Unicode flag on: alternate first branch captured", "u")
assertCaptureAbsent("(ã)|(b)", "ã", 2, "Unicode flag on: alternate second branch not captured", "u")
assertMatch("(a)|(ã)", "ã", true, 1, 2, "Unicode flag off: alternate second branch spans bytes")
assertCaptureAbsent("(a)|(ã)", "ã", 1, "Unicode flag off: alternate first branch not captured")
assertCapture("(a)|(ã)", "ã", 2, "ã", "Unicode flag off: alternate second branch captured")
assertMatch("(a)|(ã)", "ã", true, 1, 1, "Unicode flag on: alternate second branch spans codepoint", "u")
assertCaptureAbsent("(a)|(ã)", "ã", 1, "Unicode flag on: alternate first branch not captured", "u")
assertCapture("(a)|(ã)", "ã", 2, "ã", "Unicode flag on: alternate second branch captured", "u")
assertPositionCapture("^ã()$", "ã", 1, 3, "Unicode flag off: position capture uses byte offset")
assertPositionCapture("^ã()$", "ã", 1, 2, "Unicode flag on: position capture uses codepoint offset", "u")
assertError("(?u)", "", "Inline Unicode flag is not accepted")
assertError("(?u:ã)", "ã", "Scoped Unicode flag is not accepted")

----------------------------------------------------------------------------------------------------
print("  [53] Combined Flags...")

assertMatch("ÁBC", "ÁBC", true, 1, 3, "Global iu flags: Unicode literal", "iu")
assertMatch("[Á-Ã]", "Â", true, 1, 1, "Global iu flags: Unicode range", "iu")
assertMatch("[Á-Ã]", "Ä", nil, nil, nil, "Global iu flags: outside unicode range", "iu")
assertMatch("a.b", "A\nB", true, 1, 3, "Global is flags: dotall + case-insensitive", "is")
assertMatch("^abc$", "ABC\nxyz", true, 1, 3, "Global im flags: multiline + case-insensitive", "im")
assertMatch("^xyz$", "ABC\nXYZ", true, 5, 7, "Global im flags: second line", "im")
assertMatch("^a.*c$", "a\nb\nc", true, 1, 5, "Global ms flags: multiline + dotall", "ms")
assertNoCapture("(abc)", "ABC", "Global in flags: no auto capture + case-insensitive", "in")
assertCapture("(?<word>abc)", "ABC", "word", "ABC", "Global in flags: named captures still work", "in")
assertMatch("Á.B", "Á\nB", true, 1, 3, "Global ius flags: Unicode + dotall", "ius")
assertMatch("(?i)ÁBC", "ÁBC", true, 1, 3, "Inline iu flags", "u")
assertMatch("(?is)a.b", "A\nB", true, 1, 3, "Inline is flags")
assertMatch("(?i:ÁBC)", "ÁBC", true, 1, 3, "Scoped iu flags", "u")
assertMatch("a(?is:.)b", "a\nB", nil, nil, nil, "Scoped is flags: i does not leak outside scope")
assertMatch("(?i)a(?-i)(?i)b", "AB", true, 1, 2, "Nested enable/disable of i")
assertMatch("(?is)a(?-s:.)b", "A\nB", nil, nil, nil, "Disable only s inside is scope")
assertMatch("(?is)a(?-i:.)b", "A\nB", true, 1, 3, "Disable only i inside is scope")
assertMatch("(?im-s)^abc$", "ABC\nDEF", true, 1, 3, "Enable i,m disable s together")
assertMatch("(?ims)^a.*c$", "A\nB\nC", true, 1, 5, "Enable i,m,s together")

----------------------------------------------------------------------------------------------------
print("All matcher tests passed!")


end, {
	runs = 1
})