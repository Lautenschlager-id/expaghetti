----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local parser = require("./parser")
----------------------------------------------------------------------------------------------------
--local Anchor = require("./magic/anchor")
--local Alternate = require("./magic/alternate")
--local Any = require("./magic/any")
--local Group = require("./magic/group")
local Literal = require("./magic/literal")
--local Quantifier = require("./magic/Quantifier")
--local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local function matcher(expr, str, flags)
	flags = flags or { }

	local tree = parser(expr, flags)
	local treeLength = tree._index

	local splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

	local treeIndex, stringIndex = 0, 0
	local currentElement, currentCharacter
	local hasMatched

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		repeat
			stringIndex = stringIndex + 1
			currentCharacter = splitStr[stringIndex]

			if not currentCharacter then
				return
			else
				hasMatched = Literal.match(currentElement, currentCharacter)
			end

			if not hasMatched then
				treeIndex = 0
				break
			end
		until hasMatched
	end

	return true
end

----------------------------------------------------------------------------------------------------
-- Debugging
local p = require("./helpers/pretty-print")
local see = function(t) print(p(t, true)) end

see(matcher("%cCo ", "abacateiro d\3o abc!"))

----------------------------------------------------------------------------------------------------

return matcher