----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local parser = require("./parser")
----------------------------------------------------------------------------------------------------
--local Anchor = require("./magic/anchor")
--local Alternate = require("./magic/alternate")
local Any = require("./magic/any")
local Group = require("./magic/group")
local Literal = require("./magic/literal")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local singleElementMatcher = function(currentElement, currentCharacter, treeMatcher,
	flags,
	splitStr, strLength,
	stringIndex)

	if not currentCharacter then
		return
	elseif Any.isElement(currentElement) then
		return Any.match(currentElement, currentCharacter)
	elseif Set.isElement(currentElement) then
		return Set.match(currentElement, currentCharacter)
	elseif Group.isElement(currentElement) then
		return Group.match(
			currentElement, treeMatcher,
			flags,
			splitStr, strLength,
			stringIndex - 1
		)
	else
		return Literal.match(currentElement, currentCharacter)
	end
end

local function treeMatcher(
	flags, tree, treeLength, treeIndex,
	splitStr, strLength,
	stringIndex, initialStringIndex)

	local currentElement, currentCharacter

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]

		if not currentCharacter then
			return
		else
			local hasQuantifier = Quantifier.isElement(currentElement)

			if not hasQuantifier then
				if not singleElementMatcher(
					currentElement, currentCharacter, treeMatcher,
					flags,
					splitStr, strLength,
					stringIndex
				) then
					return
				end
			else
				return Quantifier.loopOver(
					currentElement, currentCharacter, singleElementMatcher, treeMatcher,
					flags, tree, treeLength, treeIndex,
					splitStr, strLength,
					stringIndex, initialStringIndex
				)
			end
		end
	end

	return true,
		--[[debug:]]splitStr and table.concat(splitStr, '', initialStringIndex + 1, stringIndex)
end

local matcher = function(expr, str, flags, stringIndex)
	flags = flags or { }

	local tree, errorMessage = parser(expr, flags)
	if not tree then
		return false, errorMessage
	end
	local treeLength = tree._index

	local splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

	stringIndex = stringIndex or 0

	while stringIndex < strLength do
		local matched, debugStr = treeMatcher(
			flags, tree, treeLength, 0,
			splitStr, strLength,
			stringIndex, stringIndex
		)

		if matched then
			return matched, debugStr
		end

		stringIndex = stringIndex + 1
	end
end

----------------------------------------------------------------------------------------------------
-- Debugging
local p = require("./helpers/pretty-print")
_G.see = function(t, s) print(s and ("%q"):format(s), p(t, true)) end
local printdebug = false
_G.pdebug = function(...) if printdebug then print(...) end end

-- see(matcher("aba", "abacateiro d\3o abc!")) -- valid(aba)
-- see(matcher("%cCo ", "abacateiro d\3o abc!")) -- valid(\3o )
-- see(matcher("abc!", "abcateiro d\3o abc!")) -- valid(abc!)
-- see(matcher("[ei]", "abacateiro d\3o abc!")) -- valid (e)
-- see(matcher("[ro] d", "abacateiro d\3o abc!")) -- valid (o d)
-- see(matcher("[^ro] [da]", "abacateiro d\3u abc!")) -- valid (u a)
-- see(matcher("[i-t][i-t][i-t][^i-t][^i-t]", "abacateiro d\3u abc!")) -- valid (iro d)
-- see(matcher("%d%d%d%d [%lz][%lz][%uz][%L][^]%U]", "i just won R$ 1000 onTHE lottery")) -- valid (1000 onTHE)
-- see(matcher("[ac][ac].e", "abacateiro d\3o abc!")) -- valid (cate)
-- see(matcher("....................", "abacateiro d\3o abc!")) -- invalid
-- see(matcher("mo*n", "mn")) -- valid
-- see(matcher("mo?o?o?o?o?o?o?o?o?o?o?o?o?o?o?n", "mn")) -- valid
-- see(matcher("mo*n", "mon")) -- valid
-- see(matcher("mo*oo?o*n", "mon")) -- valid
-- see(matcher("mo*oo?o*n", "mooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooon")) -- valid
-- see(matcher("mo{,2}on", "mooon")) -- valid
-- see(matcher("o+", "mooon")) -- valid
-- see(matcher("o*", "mooon")) -- valid
-- see(matcher("o?", "mooon")) -- valid
-- see(matcher("o{3,}", "moooon")) -- valid
-- see(matcher("o{3,}", "moon")) -- invalid
-- see(matcher("o+.o+", "mooon")) -- valid
-- see(matcher("[aeiou]+", "mooon")) -- valid
-- see(matcher("[%D]+[aeiou]+[%l]*", "mooon")) -- valid
-- see(matcher(".a+b+c+", ";aaaaabbbbbaaaaaaabbbbbbc")) -- valid (baaaaaaabbbbbbc)
-- see(matcher("a+.b+.a+", "aabaaac")) -- valid (aabaaa)
-- see(matcher("a.?c", "aabaaac")) -- valid (aac)
-- see(matcher("[%l%d_%p]*.", "aba!_@Q22?")) -- valid (aba!_@Q)
-- see(matcher(".*", "aba!_@Q22?")) -- valid
-- see(matcher(".+;", "aba!_@Q22?")) -- invalid
-- see(matcher("%d+%??", "aba!_@Q22?")) -- valid (22?)
-- see(matcher("<.+>", "<html> <body>hi?</body> </html>")) -- valid
-- see(matcher("<.+?>", "<html> <body>hi?</body> </html>")) -- valid (<html>)
-- see(matcher("o+?", "mooon")) -- valid (o)
-- see(matcher(".o*.", "mooon")) -- valid (mooon)
-- see(matcher(".o?.", "mooon")) -- valid (moo)
-- see(matcher(".o*?.", "mooon")) -- valid (mo)
-- see(matcher(".o??.", "mooon")) -- valid (mo)
-- see(matcher("%w{3,5}", "bonjoour mon amour")) -- valid (bonjo)
-- see(matcher("%w{3,5}?", "bonjoour mon amour")) -- valid (bon)
-- see(matcher("a[sc]?[abco]", "cacao tabasco tobacco")) -- valid (aca)
-- see(matcher("a[sc]??[abco]", "cacao tabasco tobacco")) -- valid (ac)
-- see(matcher("a+amo", "te aaaaaaamoo")) -- valid (aaaaaaamo)
-- see(matcher("a++amo", "te aaaaaaamoo")) -- invalid
-- see(matcher("a++mo++", "te aaaaaaamoo")) -- valid (aaaaaaamoo)
-- see(matcher("a{1,5}+m++o++", "te aaaaaaamoo")) -- valid (aaaaamoo)
-- see(matcher("a?+mo", "te aaaaaaamoo")) -- valid (amo)

see(matcher("a(b)acate", "abacate"))
----------------------------------------------------------------------------------------------------

return matcher