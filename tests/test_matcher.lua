package.path = package.path .. ";../?.lua;../expaghetti/?.lua"
local matcher = require("matcher")

local function assertMatch(expr, str, expectedHasMatched, expectedIniStr, expectedEndStr, desc, flags)
	local hasMatched, iniStr, endStr, metaData, splitStr = matcher(expr, str, flags)
	if hasMatched ~= expectedHasMatched then
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

print("Running matcher tests for core engine...")

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

local function assertCapture(expr, str, captureIndex, expectedStr, desc, flags)
	local hasMatched, iniStr, endStr, metaData, splitStr = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match for expr='%s', str='%s'", desc, expr, str))
	local ini = metaData.groupCapturesInitStringPositions[captureIndex]
	local en  = metaData.groupCapturesEndStringPositions[captureIndex]
	if type(ini) == "table" then
		ini = ini[#ini]
		en = en[#en]
	end
	assert(ini, string.format("Test '%s': capture %s not found", desc, tostring(captureIndex)))
	local got = table.concat(splitStr, "", ini, en)
	assert(got == expectedStr,
		string.format("Test '%s': expected capture=%q but got=%q", desc, expectedStr, got))
end

local function assertNoCapture(expr, str, desc, flags)
	local hasMatched, _, _, metaData = matcher(expr, str, flags)
	assert(hasMatched, string.format("Test '%s': expected match", desc))
	local hasAny = false
	for _ in pairs(metaData.groupCapturesInitStringPositions) do hasAny = true; break end
	assert(not hasAny, string.format("Test '%s': expected no captures", desc))
end

local function assertPositionCapture(expr, str, captureIndex, expectedPos, desc)
	local hasMatched, _, _, metaData = matcher(expr, str)
	assert(hasMatched, string.format("Test '%s': expected match for expr='%s', str='%s'", desc, expr, str))
	local pos = metaData.positionCaptures[captureIndex]
	assert(pos ~= nil, string.format("Test '%s': position capture %d not found", desc, captureIndex))
	assert(pos == expectedPos, string.format("Test '%s': expected position=%d but got %s", desc, expectedPos, tostring(pos)))
end

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
	local hasMatched, _, _, metaData, splitStr = matcher("(?<first>[a-z]+)_(?<second>[a-z]+)", "hello_world")
	assert(hasMatched, "Named groups: expected match")
	local fi = metaData.groupCapturesInitStringPositions["first"]
	local fe = metaData.groupCapturesEndStringPositions["first"]
	local si = metaData.groupCapturesInitStringPositions["second"]
	local se = metaData.groupCapturesEndStringPositions["second"]
	if type(fi) == "table" then
		fi = fi[#fi] fe = fe[#fe]
		si = si[#si] se = se[#se]
	end
	assert(table.concat(splitStr, "", fi, fe) == "hello", "Named capture 'first' should be 'hello'")
	assert(table.concat(splitStr, "", si, se) == "world", "Named capture 'second' should be 'world'")
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

print("All matcher tests passed!")


