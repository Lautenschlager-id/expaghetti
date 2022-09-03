----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local parser = require("./parser")
----------------------------------------------------------------------------------------------------
--local Anchor = require("./magic/anchor")
local Alternate = require("./magic/alternate")
local Any = require("./magic/any")
local CaptureReference = require("./magic/capture_reference")
local Group = require("./magic/group")
local Literal = require("./magic/literal")
local PositionCapture = require("./magic/position_capture")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local singleElementMatcher = function(
		currentElement, currentCharacter, treeMatcher,
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex,
		matcherMetaData
	)

	if PositionCapture.isElement(currentElement) then
		return PositionCapture.match(currentElement, stringIndex, matcherMetaData)
	elseif not currentCharacter then
		return
	elseif Any.isElement(currentElement) then
		return Any.match(currentElement, currentCharacter)
	elseif Set.isElement(currentElement) then
		return Set.match(currentElement, currentCharacter)
	elseif Group.isElement(currentElement) then
		return Group.match(
			currentElement, treeMatcher,
			flags, tree, treeLength, treeIndex,
			splitStr, strLength,
			stringIndex - 1, initialStringIndex,
			matcherMetaData
		)
	elseif Alternate.isElement(currentElement) then
		return Alternate.match(
			currentElement, treeMatcher,
			flags,
			splitStr, strLength,
			stringIndex - 1,
			matcherMetaData
		)
	elseif CaptureReference.isElement(currentElement) then
		return CaptureReference.match(currentElement, stringIndex - 1, splitStr, strLength,
			matcherMetaData)
	end

	return Literal.match(currentElement, currentCharacter)
end

local function treeMatcher(
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex,
		metaData
	)

	if not metaData then
		metaData = {
			groupCapturesInitStringPositions = { },
			groupCapturesEndStringPositions = { },
			positionCaptures = { },
			outerTreeReference = { }
		}
	end

	local outerTreeReference = metaData.outerTreeReference[tree]
	local outerTree = outerTreeReference and outerTreeReference.tree
	pdebug("Starting tree %s with outer tree being %s", tree, outerTree,
		string.sub(p(tree), 1, 80),
		"\t\t\t\t",
		outerTree and string.sub(p(outerTree), 1, 80))

	local currentElement, currentCharacter

	while treeIndex < treeLength do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		stringIndex = stringIndex + 1
		currentCharacter = splitStr[stringIndex]

		local hasQuantifier = Quantifier.isElement(currentElement)

		if not hasQuantifier then
			local hasMatched, iniStr, endStr, _, shouldEndThisExecution = singleElementMatcher(
				currentElement, currentCharacter, treeMatcher,
				flags, tree, treeLength, treeIndex,
				splitStr, strLength,
				stringIndex, initialStringIndex,
				metaData
			)

			-- Groups continue the execution of the previous tree in another stack
			if shouldEndThisExecution then
				return hasMatched, iniStr, endStr, metaData
			elseif not hasMatched then
				return
			elseif endStr then
				stringIndex = endStr
			end
		else
			return Quantifier.operateOver(
				currentElement, currentCharacter, singleElementMatcher, treeMatcher,
				flags, tree, treeLength, treeIndex,
				splitStr, strLength,
				stringIndex, initialStringIndex,
				metaData
			)
		end
	end

	if outerTreeReference then
		return treeMatcher(
			flags,
			outerTreeReference.tree, outerTreeReference.treeLength, outerTreeReference.treeIndex,
			splitStr, strLength,
			stringIndex, outerTreeReference.initialStringIndex,
			metaData
		)
	end

	return true, initialStringIndex + 1, stringIndex, metaData
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

	local hasMatched, iniStr, endStr, matcherMetaData
	while stringIndex < strLength do
		pdebug("\n# Matching starting in new stringIndex %d", stringIndex)
		hasMatched, iniStr, endStr, matcherMetaData = treeMatcher(
			flags, tree, treeLength, 0,
			splitStr, strLength,
			stringIndex, stringIndex
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData, splitStr
		end

		stringIndex = stringIndex + 1
	end
end

----------------------------------------------------------------------------------------------------
-- Debugging
local printdebug = true
_G.p = require("./helpers/pretty-print")
_G.m = function(expr, str, flags)
	local hasMatched, iniStr, endStr, matcherMetaData, splitStr = matcher(expr, str, flags)

	if not hasMatched then
		return print(string.format("match(%q, %q) = %q", expr, str, iniStr))
	end

	print(string.format("match(%q, %q) = %q", expr, str, table.concat(splitStr, '', iniStr, endStr)))

	local groupCapturesInitStringPositions = matcherMetaData.groupCapturesInitStringPositions
	if #groupCapturesInitStringPositions > 0 then
		local groupCapturesEndStringPositions = matcherMetaData.groupCapturesEndStringPositions

		print("\t---------Captures---------")
		for posIndex = 1, #groupCapturesInitStringPositions do
			iniStr, endStr = groupCapturesInitStringPositions[posIndex] or 0,
				groupCapturesEndStringPositions[posIndex] or 0
			print(string.format("\t\t[%02d]\t=\t(%d, %d)\t=\t%q", posIndex, iniStr, endStr,
				table.concat(splitStr, '', iniStr, endStr)))
		end

		print("\t---------Named Captures---------")
		for key, value in next, groupCapturesInitStringPositions do
			if not tonumber(key) then
				iniStr, endStr = v or 0, groupCapturesEndStringPositions[key] or 0
				print(string.format("\t\t[%q]\t=\t(%d, %d)\t=\t%q", key, iniStr, endStr,
					table.concat(splitStr, '', iniStr, endStr)))
			end
		end
	end

	local positionCaptures = matcherMetaData.positionCaptures
	if #positionCaptures > 0 then
		print("\t---------Position Captures---------")
		for posIndex = 1, #positionCaptures do
			iniStr = positionCaptures[posIndex]
			print(string.format("\t\t[%02d]\t=\t\"%s(%d)%s\"", posIndex,
				table.concat(splitStr, '', 1, iniStr - 1), iniStr,
				table.concat(splitStr, '', iniStr)))
		end
	end

	print('\n')
end
_G.pdebug = function(str, ...)
	if printdebug then
		if type(str) == "table" then
			return print(str, ...)
		end

		local args = { ... }
		local _, countFormats = string.gsub(str, '%%', '')

		print(
			string.format(
				str,
				table.unpack(args, 1, countFormats)
			),
			"\t\t\t\t",
			table.unpack(args, countFormats + 1, select('#', ...))
		)
	end
end
----------------------------------------------------------------------------------------------------

--m("()a()(b)()c()(d)()(e)()f()", "abcdef")
--m("()a()(b)()c()(()(d)()(e()(f)())()g())", "abcdefg")

--m("%d+(.)", "1235")
--m("(x+()x)()x", "xxxxxxxxxxxx")

--m("(.{1,}(.+))()(..)()(.{1,}.)", "abcdef")
--m("aba(c+)ate", "abacccccccccccaty ou abaccccccate?")

--m("a(b)acate", "abacate") -- valid (abacate)
--m("a(ba)?cate", "acate") -- valid (acate)
--m("a()(ba)?()cat(.)", "acate") -- valid (acate)
--m("a()(b.?a)().?()cate", "abacate") -- valid (abacate)
--m("a(b?c?a)te", "abacate") -- valid (acate)
--m("a?((b?c?)a)+", "abacate") -- valid (abaca)
--m("a([bc]a)+", "abacate") -- valid (acaba)
--m("([bc]a)+", "abacate") -- valid (baca)
--m("a([bct]a?)+", "abacate") -- valid (abacat)
--m("([bct]a?)+", "abacate") -- valid (bacat)
--m("([bct]a?)+?", "abacate") -- valid (ba)
--m("((((((((((((((((((((((((((((((((((.)?))))))))))))))))))))))))))?)))))))", '.') -- valid (.)
--m("(a??)", "abacate") -- valid ('')

--*m("(x+x+)+y", "xxxxxxxxxxy") -- "()+SOMETHING" breaks
--*m("(b?c?a)+te", "abacate") -- valid (abacate)  -- "()+SOMETHING" breaks
--*m("a(ba(c(a)(t)?e))e?", "abacate") -- valid (abacate) -- "()?SOMETHING" breaks
--*m("(b?c?t?a?)+", "abacate") -- valid (abacat) -- INF LOOP
--*m("(b?c?a?)+", "abacate") -- valid (abaca) -- INF LOOP
--*m("(ab?(cd?e)*f)+.", "ldskfsdpkabcdefacdefacefacdececdecefasjdoasdi") -- valid (abcdefacdefacefacdececdecefa) -- "()*SOMETHING" breaks
--*m("(?:b?c?t?(a?))+", "abacate") -- valid (abacat) -- INF LOOP


return matcher