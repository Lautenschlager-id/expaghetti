----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local parser = require("./parser")
----------------------------------------------------------------------------------------------------
--local Anchor = require("./magic/anchor")
--local Alternate = require("./magic/alternate")
local Any = require("./magic/any")
--local Group = require("./magic/group")
local Literal = require("./magic/literal")
--local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local function matcher(expr, str, flags,
	-- For recursive purposes only
	stringIndex,
	tree, treeLength, splitStr, strLength)

	if not tree then
		flags = flags or { }

		tree = parser(expr, flags)
		treeLength = tree._index

		splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

		stringIndex = 0
	end

	local treeIndex = 0
	local initialStringIndex = stringIndex

	local currentElement, currentCharacter
	local hasMatched

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]

		if not currentCharacter then
			return
		elseif Any.isElement(currentElement) then
			hasMatched = Any.match(currentElement, currentCharacter)
		elseif Set.isElement(currentElement) then
			hasMatched = Set.match(currentElement, currentCharacter)
		else
			hasMatched = Literal.match(currentElement, currentCharacter)
		end

		if not hasMatched then
			return matcher(
				nil, --[[debug:]]str, flags,
				initialStringIndex + 1,
				tree, treeLength, splitStr, strLength
			)
		end
	end

	return true, --[[debug:]]str, initialStringIndex + 1, stringIndex
end

----------------------------------------------------------------------------------------------------
-- Debugging
local p = require("./helpers/pretty-print")
_G.see = function(t, s, i, e) print(s and ("%q"):format(s:sub(i, e)), p(t, true)) end

see(matcher("aba", "abacateiro d\3o abc!")) -- valid(aba)
see(matcher("%cCo ", "abacateiro d\3o abc!")) -- valid(\3o )
see(matcher("abc!", "abcateiro d\3o abc!")) -- valid(abc!)
see(matcher("[ei]", "abacateiro d\3o abc!")) -- valid (e)
see(matcher("[ro] d", "abacateiro d\3o abc!")) -- valid (o d)
see(matcher("[^ro] [da]", "abacateiro d\3u abc!")) -- valid (u a)
see(matcher("[i-t][i-t][i-t][^i-t][^i-t]", "abacateiro d\3u abc!")) -- valid (iro d)
see(matcher("%d%d%d%d [%lz][%lz][%uz][%L][^]%U]", "i just won R$ 1000 onTHE lottery")) -- valid (1000 onTHE)
see(matcher("[ac][ac].e", "abacateiro d\3o abc!")) -- valid (cate)
see(matcher("....................", "abacateiro d\3o abc!")) -- invalid

----------------------------------------------------------------------------------------------------

return matcher