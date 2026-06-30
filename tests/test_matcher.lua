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

print("All matcher tests passed!")
