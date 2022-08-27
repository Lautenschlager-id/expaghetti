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
local elementMatches = function(currentElement, currentCharacter)
	local hasMatched

	if not currentCharacter then
		return
	elseif Any.isElement(currentElement) then
		hasMatched = Any.match(currentElement, currentCharacter)
	elseif Set.isElement(currentElement) then
		hasMatched = Set.match(currentElement, currentCharacter)
	else
		hasMatched = Literal.match(currentElement, currentCharacter)
	end

	return hasMatched
end

local function matcher(expr, str, flags,
	stringIndex,
	-- For recursive purposes only
	tree, treeLength, treeIndex,
	splitStr, strLength)

	if not tree then
		flags = flags or { }

		tree = parser(expr, flags)
		treeLength = tree._index

		splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

		treeIndex = 0
		stringIndex = 0
	end

	local initialStringIndex = stringIndex

	local currentElement, currentCharacter
	local hasMatched

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]

		--print('\t\t\t\tcurrentElement', currentElement.value, currentCharacter)

		if not currentCharacter then
			return
		else
			local hasQuantifier = Quantifier.isElement(currentElement)

			if not hasQuantifier then
				hasMatched = elementMatches(currentElement, currentCharacter)
			else
				local quantifier = currentElement.quantifier

				local min, max = quantifier.min or 0, quantifier.max or 0
				local maxOccurrencesFound = 0

				-- get maximum iterations
				local newCurrentCharacter = currentCharacter
				local newStringIndex = stringIndex
				repeat
					if not elementMatches(currentElement, newCurrentCharacter) then
						break
					end

					maxOccurrencesFound = maxOccurrencesFound + 1
					if maxOccurrencesFound == max then
						break
					end

					newStringIndex = newStringIndex + 1
					newCurrentCharacter = splitStr[newStringIndex]
				until false

				--print('maxOccurrencesFound', maxOccurrencesFound, min <= maxOccurrencesFound)

				-- greedy
				if min <= maxOccurrencesFound then
					if not quantifier.mode then
						for occurence = maxOccurrencesFound, min, -1 do
							if occurence == 0 then
								hasMatched = true
								stringIndex = stringIndex - 1
								break
							end

							if matcher(
								nil, nil, flags,
								stringIndex + occurence - 1,
								tree, treeLength, treeIndex,
								splitStr, strLength
							) then
								hasMatched = true
								stringIndex = stringIndex + occurence - 1
								break
							end
						end
					end
				end
			end
		end

		if not hasMatched then
			return matcher(
				nil, --[[debug:]]str, flags,
				initialStringIndex + 1,
				tree, treeLength, 0,
				splitStr, strLength
			)
		end
	end

	return true,
		--[[debug:]]splitStr and table.concat(splitStr, '', initialStringIndex + 1, stringIndex)
end

----------------------------------------------------------------------------------------------------
-- Debugging
local p = require("./helpers/pretty-print")
_G.see = function(t, s) print(s and ("%q"):format(s), p(t, true)) end

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

----------------------------------------------------------------------------------------------------

return matcher