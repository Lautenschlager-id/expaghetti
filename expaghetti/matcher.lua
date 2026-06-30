----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
local parser = require("./parser")
local MatchState = require("./match_state")
----------------------------------------------------------------------------------------------------
local Alternate = require("./magic/alternate")
local CaptureReference = require("./magic/capture_reference")
local Group = require("./magic/group")
local PositionCapture = require("./magic/position_capture")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_ANY = elementsEnum.any
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_SET = elementsEnum.set
----------------------------------------------------------------------------------------------------
local function matchSet(currentElement, currentCharacter)
	local hasMatched = false

	if currentElement[currentCharacter] then
		hasMatched = true
	else
		local ranges = currentElement.ranges
		for rangeIndex = 1, currentElement.rangeIndex, 2 do
			if currentCharacter >= ranges[rangeIndex]
				and currentCharacter <= ranges[rangeIndex + 1] then

				hasMatched = true
				break
			end
		end

		if not hasMatched then
			local classes = currentElement.classes
			for classIndex = 1, currentElement.classIndex do
				if matchSet(classes[classIndex], currentCharacter) then
					hasMatched = true
					break
				end
			end
		end
	end

	return currentElement.hasToNegateMatch ~= hasMatched
end
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
	elseif currentElement.type == ENUM_ELEMENT_TYPE_ANY then
		-- Wiki: "." matches any character but EOL, equivalent to [^\r\n]
		return currentCharacter ~= "\r" and currentCharacter ~= "\n"
	elseif currentElement.type == ENUM_ELEMENT_TYPE_SET then
		return matchSet(currentElement, currentCharacter)
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
			flags, tree, treeLength, treeIndex,
			splitStr, strLength,
			stringIndex - 1, initialStringIndex,
			matcherMetaData
		)
	elseif CaptureReference.isElement(currentElement) then
		return CaptureReference.match(currentElement, stringIndex - 1, splitStr, strLength,
			matcherMetaData)
	elseif currentElement.type == ENUM_ELEMENT_TYPE_LITERAL then
		return currentElement.value == currentCharacter
	end

	return false
end

local debugCurrentStackFrame
local legacyTreeMatcher -- Forward declaration
local coreTreeMatcher -- Forward declaration

local function quantifyElement(
	currentElement, currentCharacter, singleElementMatcher, legacyTreeMatcher,
	state, tree, treeIndex
)
	local quantifier = currentElement.quantifier
	local maximumOccurrences = quantifier.max

	local totalOccurrences = 0
	local endStringPositions = { }

	local hasMatched, iniStr, endStr, lastIniStr, lastEndStr
	local stringIndex = state.stringIndex
	
	repeat
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, currentCharacter, legacyTreeMatcher,
			state.flags, nil, nil, nil,
			state.splitStr, state.strLength,
			stringIndex, state.initialStringIndex,
			state.metaData
		)

		if not hasMatched then
			break
		end

		endStr = endStr or stringIndex

		totalOccurrences = totalOccurrences + 1
		endStringPositions[totalOccurrences] = endStr

		if totalOccurrences == maximumOccurrences
			-- Empty match
			or (iniStr and iniStr > endStr)
			-- Loop match
			or (lastIniStr == iniStr and lastEndStr == endStr)
		then
			break
		end
		lastIniStr, lastEndStr = iniStr, endStr

		stringIndex = endStr + 1
		currentCharacter = state.splitStr[stringIndex]
	until false

	local minimumOccurrences = quantifier.min
	local maximumOccurrencesOfElement = totalOccurrences

	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end

	local mode = quantifier.mode or "greedy"
	
	local startOccurrences, endOccurrences, step
	if mode == "greedy" then
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = minimumOccurrences
		step = -1
	elseif mode == "lazy" then
		startOccurrences = minimumOccurrences
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	elseif mode == "possessive" then
		startOccurrences = maximumOccurrencesOfElement
		endOccurrences = maximumOccurrencesOfElement
		step = 1
	end

	for occurrence = startOccurrences, endOccurrences, step do
		local targetStringIndex = endStringPositions[occurrence] or (state.stringIndex - 1)
		
		hasMatched, iniStr, endStr = legacyTreeMatcher(
			state.flags, tree, tree._index, treeIndex,
			state.splitStr, state.strLength,
			targetStringIndex, state.initialStringIndex,
			state.metaData
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, state.metaData
		end
	end
end

local function coreTreeMatcher(
		state, tree, treeIndex
	)

	debugCurrentStackFrame = debugCurrentStackFrame + 1
	local debugCurrentStackFrameStr = "[Stack "..debugCurrentStackFrame.."]: "

	local outerTreeReference = state.metaData.outerTreeReference[tree]
	local outerTree = outerTreeReference and outerTreeReference.tree
	pdebug("\n%sStarting tree %s at position %d with outer tree being %s at position %s",
		debugCurrentStackFrameStr,
		tree, treeIndex + 1,
		outerTree, outerTreeReference and outerTreeReference.treeIndex + 1,
		string.sub(p(tree), 1, 200),
		"\t\t\t\t",
		outerTree and string.sub(p(outerTree), 1, 80))

	local currentElement, currentCharacter
	local hasQuantifier
	local hasMatched, iniStr, endStr, _, shouldEndThisExecution

	while treeIndex < tree._index do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		state.stringIndex = state.stringIndex + 1
		currentCharacter = state.splitStr[state.stringIndex]

		hasQuantifier = Quantifier.isElement(currentElement)

		if not hasQuantifier then
			pdebug("\t%sValidating stringIndex %d -> %q<%s> == %q", debugCurrentStackFrameStr,
				state.stringIndex,
				currentElement.value, currentElement.type, currentCharacter)

			hasMatched, iniStr, endStr, _, shouldEndThisExecution = singleElementMatcher(
				currentElement, currentCharacter, legacyTreeMatcher,
				state.flags, tree, tree._index, treeIndex,
				state.splitStr, state.strLength,
				state.stringIndex, state.initialStringIndex,
				state.metaData
			)

			pdebug("\t%s%salidated stringIndex %d -> %q<%s> == %q", debugCurrentStackFrameStr,
				(hasMatched and 'V' or "Not v"),
				state.stringIndex, currentElement.value, currentElement.type, currentCharacter)

			-- Groups continue the execution of the previous tree in another stack
			if shouldEndThisExecution then
				return hasMatched, iniStr, endStr, state.metaData
			elseif not hasMatched then
				return
			elseif endStr then
				state.stringIndex = endStr
			end
		else
			pdebug("\t%s@ Will quantify starting in stringIndex %d", debugCurrentStackFrameStr,
				state.stringIndex)
			return quantifyElement(
				currentElement, currentCharacter, singleElementMatcher, legacyTreeMatcher,
				state, tree, treeIndex
			)
		end
	end

	if outerTreeReference then
		pdebug("&%sTree Matching outerTreeReference:", debugCurrentStackFrameStr)
		
		local groupIndex = tree._groupIndex
		local pushedCapture = false
		if groupIndex then
			local gIni = state.initialStringIndex + 1
			local gEnd = state.stringIndex
			local inits = state.metaData.groupCapturesInitStringPositions
			local ends = state.metaData.groupCapturesEndStringPositions
			if not inits[groupIndex] then
				inits[groupIndex] = {}
				ends[groupIndex] = {}
			end
			if gIni <= gEnd then
				table.insert(inits[groupIndex], gIni)
				table.insert(ends[groupIndex], gEnd)
			else
				table.insert(inits[groupIndex], 2)
				table.insert(ends[groupIndex], 1)
			end
			pushedCapture = true
		end

		state.initialStringIndex = outerTreeReference.initialStringIndex

		local hasMatched, oIni, oEnd, oMeta = coreTreeMatcher(
			state,
			outerTreeReference.tree, outerTreeReference.treeIndex
		)

		if not hasMatched and pushedCapture then
			local inits = state.metaData.groupCapturesInitStringPositions[groupIndex]
			local ends = state.metaData.groupCapturesEndStringPositions[groupIndex]
			table.remove(inits)
			table.remove(ends)
		end

		return hasMatched, oIni, oEnd, oMeta
	end

	local groupIndex = tree._groupIndex
	if groupIndex then
		local gIni = state.initialStringIndex + 1
		local gEnd = state.stringIndex
		local inits = state.metaData.groupCapturesInitStringPositions
		local ends = state.metaData.groupCapturesEndStringPositions
		if not inits[groupIndex] then
			inits[groupIndex] = {}
			ends[groupIndex] = {}
		end
		if gIni <= gEnd then
			table.insert(inits[groupIndex], gIni)
			table.insert(ends[groupIndex], gEnd)
		else
			table.insert(inits[groupIndex], 2)
			table.insert(ends[groupIndex], 1)
		end
	end

	return true, state.initialStringIndex + 1, state.stringIndex, state.metaData
end

legacyTreeMatcher = function(
		flags, tree, treeLength, treeIndex,
		splitStr, strLength,
		stringIndex, initialStringIndex,
		metaData
	)
	local state = MatchState.new(
		flags, splitStr, strLength, stringIndex, initialStringIndex, metaData
	)
	return coreTreeMatcher(state, tree, treeIndex)
end

local matcher = function(expr, str, flags, stringIndex)
	if type(expr) ~= "string" then
		return false, "Expression must be a string"
	end
	if type(str) ~= "string" then
		return false, "Target must be a string"
	end

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
		debugCurrentStackFrame = 0
		pdebug("\n# Matching starting in new stringIndex %d", stringIndex)
		
		local state = MatchState.new(
			flags, splitStr, strLength, stringIndex, stringIndex, nil
		)
		hasMatched, iniStr, endStr, matcherMetaData = coreTreeMatcher(
			state, tree, 0
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData, splitStr
		end

		stringIndex = stringIndex + 1
	end
end

----------------------------------------------------------------------------------------------------
-- Debugging
local printdebug = not true
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

-- m("()a()(b)()c()(d)()(e)()f()", "abcdef") -- valid (abcdefg)
-- m("()a()(b)()c()(()(d)()(e()(f)())()g())", "abcdefg") -- valid (abcdefg)

-- m("%d+(.)", "1235") -- valid (1235)
-- m("(x+()x)()x", "xxxxxxxxxxxx") -- valid (xxxxxxxxxxxx)

-- m("(.{0,}(.+))()(...)()(.{1,}.)", "abcdef") -- valid (abcdef)
-- m("aba(c+)ate", "abacccccccccccaty ou abaccccccate?") -- valid (abaccccccate)

-- m("a(b)acate", "abacate") -- valid (abacate)
-- m("a(ba)?cate", "acate") -- valid (acate)
-- m("a()(ba)?()cat(.)", "acate") -- valid (acate)
-- m("a()(b.?a)().?()cate", "abacate") -- valid (abacate)
-- m("a(b?c?a)te", "abacate") -- valid (acate)
-- m("a?((b?c?)a)+", "abacate") -- valid (abaca)
-- m("a([bc]a)+", "abacate") -- valid (acaba)
-- m("([bc]a)+", "abacate") -- valid (baca)
-- m("a([bct]a?)+", "abacate") -- valid (abacat)
-- m("([bct]a?)+", "abacate") -- valid (bacat)
-- m("([bct]a?)+?", "abacate") -- valid (ba)
-- m("((((((((((((((((((((((((((((((((((.)?))))))))))))))))))))))))))?)))))))", '.') -- valid (.)
-- m("(a??)", "abacate") -- valid ('')
-- m(".?((a+()(((b+)))()))().?", "aaacbab") -- valid (bab)
-- m("(x+x+)+()y", "xxxxxxxxxxy") -- valid (xxxxxxxxxxy)
-- m("(a+|b+)c", "aaaaaaaadbbbbbbbbbbc") -- valid (bbbbbbbbbbc)
-- m("([ab]+)c", "aaaaaaaadbbbbbbbbbbc") -- valid (bbbbbbbbbbc)
-- m("(b?c?a)+te", "abacate") -- valid (abacate)
-- m("a(ba(c(a)(t)?e))e?", "abacate") -- valid (abacate)
-- m("(ab?(cd?e)*f)+.", "ldskfsdpkabcdefacdefacefacdececdecefasjdoasdi") -- valid (abcdefacdefacefacdececdecefa)
-- m("(a)+()b", "aaacaab") -- valid (aab)
-- m("(b?c?t?a?)+", "abacate") -- valid (abacat)
-- m("(b?c?a?)+", "abacate") -- valid (abaca)

-- m("(?:b?c?t?(a?))+", "abacate") -- valid (abacat)
-- m("(b?)+", '.............................') -- valid ("")

-- m("(a)+x", "aaax") -- valid (aaax)
-- m("([ac])+x", "aacx") -- valid (aacx)
-- m("([^N]*N)+", "abNNxyzN") -- valid (abNNxyzN)
-- m("([^N]*N)+", "abNNxyz") -- valid (abNN)
-- m("(([a-z]+):)?([a-z]+)", "smil") -- valid (smil)
-- m("(x?)?", "x") -- valid (x)
-- m("((a)c)?(ab)", "ab") -- valid (ab)
-- m("([^/]*/)*sub1/", "d:msgs/tdir/sub1/trial/away.cpp") -- valid (d:msgs/tdir/sub1/)
-- m("([abc])*d", "abbbcd") -- valid (abbbcd)
-- m("([abc])*bcd", "abcd") -- valid (abcd)
-- m("\"(?:\\\"|[^\"])*?\"", "\"\"\"") -- valid (\"\")
-- m("(a+b+)+(a+b+)+a", 'abbbbbbbcaaaaaaaaaaaaabaaaaba') -- valid (aaaaaaaaaaaaabaaaaba)

--m("([ab]*?)(?=(b))c", "abc") -- captures returning ini=0

return matcher