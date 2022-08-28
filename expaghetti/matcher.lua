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
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local singleElementMatcher = function(currentElement, currentCharacter)
	if not currentCharacter then
		return
	elseif Any.isElement(currentElement) then
		return Any.match(currentElement, currentCharacter)
	elseif Set.isElement(currentElement) then
		return Set.match(currentElement, currentCharacter)
	else
		return Literal.match(currentElement, currentCharacter)
	end
end

local function _matcher(
	flags, tree, treeLength, treeIndex,
	splitStr, strLength,
	stringIndex, initialStringIndex)

	pdebug(string.format("GOT INDEX %d AND TREE INDEX %d AND STRING %q", stringIndex, treeIndex, table.concat(splitStr, '', stringIndex + 1)))

	local currentElement, currentCharacter

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]
		pdebug('\t\tcurrentCharacter', currentCharacter)
		if not currentCharacter then
			return
		else
			local hasQuantifier = Quantifier.isElement(currentElement)

			if not hasQuantifier then
				if not singleElementMatcher(currentElement, currentCharacter) then
					return
				end
			else
				return Quantifier.loopOver(
					currentElement, currentCharacter, singleElementMatcher, _matcher,
					flags, tree, treeLength, treeIndex,
					splitStr, strLength,
					stringIndex, initialStringIndex
				)
			end
		end
	end

	pdebug('Finished', initialStringIndex, stringIndex)
	return true,
		--[[debug:]]splitStr and table.concat(splitStr, '', initialStringIndex + 1, stringIndex)
end

local matcher = function(expr, str, flags, stringIndex)
	flags = flags or { }

	local tree = parser(expr, flags)
	local treeLength = tree._index

	local splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

	stringIndex = stringIndex or 0

	while stringIndex < strLength do
		pdebug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
		local matched, debugStr = _matcher(
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

--see(matcher("aba", "abacateiro d\3o abc!")) -- valid(aba)
--see(matcher("%cCo ", "abacateiro d\3o abc!")) -- valid(\3o )
--see(matcher("abc!", "abcateiro d\3o abc!")) -- valid(abc!)
--see(matcher("[ei]", "abacateiro d\3o abc!")) -- valid (e)
--see(matcher("[ro] d", "abacateiro d\3o abc!")) -- valid (o d)
--see(matcher("[^ro] [da]", "abacateiro d\3u abc!")) -- valid (u a)
--see(matcher("[i-t][i-t][i-t][^i-t][^i-t]", "abacateiro d\3u abc!")) -- valid (iro d)
--see(matcher("%d%d%d%d [%lz][%lz][%uz][%L][^]%U]", "i just won R$ 1000 onTHE lottery")) -- valid (1000 onTHE)
--see(matcher("[ac][ac].e", "abacateiro d\3o abc!")) -- valid (cate)
--see(matcher("....................", "abacateiro d\3o abc!")) -- invalid
see(matcher("mo*n", "mn")) -- valid
see(matcher("mo?o?o?o?o?o?o?o?o?o?o?o?o?o?o?n", "mn")) -- valid
see(matcher("mo*n", "mon")) -- valid
see(matcher("mo*oo?o*n", "mon")) -- valid
see(matcher("mo*oo?o*n", "mooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooon")) -- valid
see(matcher("mo{,2}on", "mooon")) -- valid
see(matcher("o+", "mooon")) -- valid
see(matcher("o*", "mooon")) -- valid
see(matcher("o?", "mooon")) -- valid
see(matcher("o{3,}", "moooon")) -- valid
see(matcher("o{3,}", "moon")) -- invalid
see(matcher("o+.o+", "mooon")) -- valid
see(matcher("[aeiou]+", "mooon")) -- valid
see(matcher("[%D]+[aeiou]+[%l]*", "mooon")) -- valid
see(matcher(".a+b+c+", ";aaaaabbbbbaaaaaaabbbbbbc")) -- valid (baaaaaaabbbbbbc)
see(matcher("a+.b+.a+", "aabaaac")) -- valid (aabaaa)
see(matcher("a.?c", "aabaaac")) -- valid (aac)
see(matcher("[%l%d_%p]*.", "aba!_@Q22?")) -- valid (aba!_@Q)
see(matcher(".*", "aba!_@Q22?")) -- valid
see(matcher(".+;", "aba!_@Q22?")) -- invalid
see(matcher("%d+%??", "aba!_@Q22?")) -- valid

----------------------------------------------------------------------------------------------------

return matcher