----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
local parser = require("./parser")
local MatchState = require("./match_state")
local config = require("./config")
----------------------------------------------------------------------------------------------------
local Alternate = require("./magic/alternate")
local Anchor = require("./magic/anchor")
local Balanced = require("./magic/balanced")
local Boundary = require("./magic/boundary")
local CaptureReference = require("./magic/capture_reference")
local Group = require("./magic/group")
local PositionCapture = require("./magic/position_capture")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local elementsEnum = require("./enums/elements")
local ENUM_ELEMENT_TYPE_ANY = elementsEnum.any
local ENUM_ELEMENT_TYPE_LITERAL = elementsEnum.literal
local ENUM_ELEMENT_TYPE_SET = elementsEnum.set
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local printdebug = false

local function treeHasNestedQuantifier(tree)
	if not tree then
		return false
	end
	for elementIndex = 1, tree._index do
		if Quantifier.isElement(tree[elementIndex]) then
			return true
		end
	end
	return false
end

local function elementHasNestedQuantifier(element)
	if Group.isElement(element) then
		return treeHasNestedQuantifier(element.tree)
	end
	return false
end

local function elementInnerQuantifierIsPossessive(element)
	if Group.isElement(element) and element.tree then
		for elementIndex = 1, element.tree._index do
			local child = element.tree[elementIndex]
			if Quantifier.isElement(child) and child.quantifier.mode == "possessive" then
				return true
			end
		end
	elseif Quantifier.isElement(element) and element.quantifier.mode == "possessive" then
		return true
	end
	return false
end

local function canBacktrackNestedQuantifier(quantifier, element)
	local mode = quantifier.mode or "greedy"
	return mode ~= "possessive"
		and elementHasNestedQuantifier(element)
		and not elementInnerQuantifierIsPossessive(element)
end

local function popCaptureForElement(metaData, element)
	local groupIndex = element.index or element.name
	if not groupIndex then
		return
	end
	local inits = metaData.groupCapturesInitStringPositions[groupIndex]
	if inits and #inits > 0 then
		table.remove(inits)
		table.remove(metaData.groupCapturesEndStringPositions[groupIndex])
	end
end
----------------------------------------------------------------------------------------------------
local function matchSet(currentElement, currentCharacter)
	local hasMatched = false

	if currentElement.isCaseInsensitive and type(currentCharacter) == "string" then
		local lowerChar = string.lower(currentCharacter)
		local upperChar = string.upper(currentCharacter)
		if currentElement[lowerChar] or currentElement[upperChar] then
			hasMatched = true
		end
	elseif currentElement[currentCharacter] then
		hasMatched = true
	end

	if not hasMatched then
		local ranges = currentElement.ranges
		for rangeIndex = 1, currentElement.rangeIndex, 2 do
			local rStart = ranges[rangeIndex]
			local rEnd = ranges[rangeIndex + 1]
			
			if currentElement.isCaseInsensitive and type(currentCharacter) == "string" then
				local lowerChar = string.lower(currentCharacter)
				local upperChar = string.upper(currentCharacter)
				if (lowerChar >= rStart and lowerChar <= rEnd) or (upperChar >= rStart and upperChar <= rEnd) then
					hasMatched = true
					break
				end
			elseif currentCharacter >= rStart and currentCharacter <= rEnd then
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
		currentElement, currentCharacter, treeMatcher, state, tree, treeIndex
	)

	if PositionCapture.isElement(currentElement) then
		return PositionCapture.match(currentElement, state)
	elseif Anchor.isElement(currentElement) then
		return Anchor.match(currentElement, state)
	elseif Boundary.isElement(currentElement) then
		return Boundary.match(currentElement, state, matchSet)
	elseif Balanced.isElement(currentElement) then
		return Balanced.match(currentElement, state)
	elseif Group.isElement(currentElement) then
		return Group.match(
			currentElement, treeMatcher,
			state.flags, tree, tree and tree._index or nil, treeIndex,
			state.splitStr, state.strLength,
			state.stringIndex - 1, state.initialStringIndex,
			state.metaData
		)
	elseif Alternate.isElement(currentElement) then
		return Alternate.match(
			currentElement, treeMatcher,
			state.flags, tree, tree and tree._index or nil, treeIndex,
			state.splitStr, state.strLength,
			state.stringIndex - 1, state.initialStringIndex,
			state.metaData
		)
	elseif CaptureReference.isElement(currentElement) then
		return CaptureReference.match(currentElement, state)
	elseif not currentCharacter then
		return
	elseif currentElement.type == ENUM_ELEMENT_TYPE_ANY then
		-- Wiki: "." matches any character but EOL, equivalent to [^\r\n]
		-- With DotAll flag (s), "." matches everything including newlines
		if currentElement.isDotAll or (state.flags and state.flags.s) then
			return true
		end
		return currentCharacter ~= "\r" and currentCharacter ~= "\n"
	elseif currentElement.type == ENUM_ELEMENT_TYPE_SET then
		return matchSet(currentElement, currentCharacter)
	elseif currentElement.type == ENUM_ELEMENT_TYPE_LITERAL then
		if currentElement.isCaseInsensitive then
			return string.lower(currentCharacter) == currentElement.lowercaseValue
		end
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
	local minimumOccurrences = quantifier.min
	local mode = quantifier.mode or "greedy"
	local canBacktrackInner = canBacktrackNestedQuantifier(quantifier, currentElement)

	local totalOccurrences = 0
	local endStringPositions = { }
	local startStringPositions = { }

	local hasMatched, iniStr, endStr, lastIniStr, lastEndStr
	local stringIndex = state.stringIndex

	local function hasMoreOccurrencesAllowed()
		return maximumOccurrences == 0 or totalOccurrences < maximumOccurrences
	end

	local function extendOccurrenceCollection()
		while hasMoreOccurrencesAllowed() do
			startStringPositions[totalOccurrences + 1] = stringIndex

			local tempState = state:branch(stringIndex, state.initialStringIndex)
			hasMatched, iniStr, endStr = singleElementMatcher(
				currentElement, currentCharacter, legacyTreeMatcher,
				tempState, nil, nil
			)

			if not hasMatched then
				return false
			end

			endStr = endStr or stringIndex

			if state.metaData.quantifierMaxEnd and endStr > state.metaData.quantifierMaxEnd then
				return false
			end

			totalOccurrences = totalOccurrences + 1
			endStringPositions[totalOccurrences] = endStr

			if not hasMoreOccurrencesAllowed()
				or (iniStr and iniStr > endStr)
				or (lastIniStr == iniStr and lastEndStr == endStr)
			then
				return true
			end
			lastIniStr, lastEndStr = iniStr, endStr

			stringIndex = endStr + 1
			currentCharacter = state.splitStr[stringIndex]
		end

		return true
	end

	extendOccurrenceCollection()

	while totalOccurrences < minimumOccurrences and canBacktrackInner and totalOccurrences > 0 do
		local lastOccurrence = totalOccurrences
		local occurrenceStart = startStringPositions[lastOccurrence]
		local occurrenceEnd = endStringPositions[lastOccurrence]

		if not occurrenceStart or occurrenceEnd <= occurrenceStart then
			break
		end

		state.metaData.backtrackSteps = (state.metaData.backtrackSteps or 0) + 1
		if state.metaData.backtrackSteps > state.metaData.maxBacktrackDepth then
			return
		end

		popCaptureForElement(state.metaData, currentElement)
		state.metaData.quantifierMaxEnd = occurrenceEnd - 1

		local tempState = state:branch(occurrenceStart, occurrenceStart)
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state.splitStr[occurrenceStart], legacyTreeMatcher,
			tempState, nil, nil
		)

		state.metaData.quantifierMaxEnd = nil

		if not hasMatched then
			break
		end

		endStr = endStr or occurrenceStart
		endStringPositions[lastOccurrence] = endStr
		stringIndex = endStr + 1
		currentCharacter = state.splitStr[stringIndex]
		lastIniStr, lastEndStr = nil, nil

		extendOccurrenceCollection()
	end

	local maximumOccurrencesOfElement = totalOccurrences

	if maximumOccurrencesOfElement < minimumOccurrences then
		return
	end
	
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

	local function shortenOccurrenceAt(occurrenceIndex)
		local occurrenceStart = startStringPositions[occurrenceIndex]
		local occurrenceEnd = endStringPositions[occurrenceIndex]

		if not occurrenceStart or occurrenceEnd <= occurrenceStart then
			return false
		end

		state.metaData.backtrackSteps = (state.metaData.backtrackSteps or 0) + 1
		if state.metaData.backtrackSteps > state.metaData.maxBacktrackDepth then
			return false
		end

		popCaptureForElement(state.metaData, currentElement)
		state.metaData.quantifierMaxEnd = occurrenceEnd - 1

		local tempState = state:branch(occurrenceStart, occurrenceStart)
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state.splitStr[occurrenceStart], legacyTreeMatcher,
			tempState, nil, nil
		)

		state.metaData.quantifierMaxEnd = nil

		if not hasMatched then
			return false
		end

		endStr = endStr or occurrenceStart
		endStringPositions[occurrenceIndex] = endStr
		totalOccurrences = occurrenceIndex
		stringIndex = endStr + 1
		currentCharacter = state.splitStr[stringIndex]
		lastIniStr, lastEndStr = nil, nil
		extendOccurrenceCollection()
		maximumOccurrencesOfElement = totalOccurrences

		return true
	end

	for occurrence = startOccurrences, endOccurrences, step do
		if occurrence ~= startOccurrences then
			state.metaData.backtrackSteps = (state.metaData.backtrackSteps or 0) + 1
			if state.metaData.backtrackSteps > state.metaData.maxBacktrackDepth then
				return
			end
		end

		local backtrackOccurrence = occurrence
		while backtrackOccurrence >= minimumOccurrences do
			while true do
				local targetStringIndex = endStringPositions[occurrence]
					or (state.stringIndex - 1)

				hasMatched, iniStr, endStr = legacyTreeMatcher(
					state.flags, tree, tree._index, treeIndex,
					state.splitStr, state.strLength,
					targetStringIndex, state.initialStringIndex,
					state.metaData
				)

				if hasMatched then
					return hasMatched, iniStr, endStr, state.metaData
				end

				if not canBacktrackInner then
					break
				end

				local occurrenceStart = startStringPositions[backtrackOccurrence]
				if not occurrenceStart or targetStringIndex <= occurrenceStart then
					break
				end

				if not shortenOccurrenceAt(backtrackOccurrence) then
					break
				end
			end

			if backtrackOccurrence <= minimumOccurrences then
				break
			end

			backtrackOccurrence = backtrackOccurrence - 1
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
	if printdebug then
		pdebug("\n%sStarting tree %s at position %d with outer tree being %s at position %s",
			debugCurrentStackFrameStr,
			tree, treeIndex + 1,
			outerTree, outerTreeReference and outerTreeReference.treeIndex + 1,
			string.sub(p(tree), 1, 200),
			"\t\t\t\t",
			outerTree and string.sub(p(outerTree), 1, 80))
	end

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
				state, tree, treeIndex
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

	if type(flags) == "string" then
		local t = {}
		for char in flags:gmatch(".") do
			t[char] = true
		end
		flags = t
	else
		flags = flags or {}
	end

	local tree, errorMessage = parser(expr, flags)
	if not tree then
		return false, errorMessage
	end
	local treeLength = tree._index

	local splitStr, strLength = splitStringByEachChar(str, not not flags[ENUM_FLAG_UNICODE])

	stringIndex = stringIndex or 0

	local hasMatched, iniStr, endStr, matcherMetaData
	while stringIndex <= strLength do
		debugCurrentStackFrame = 0
		pdebug("\n# Matching starting in new stringIndex %d", stringIndex)
		
		local parsedMetaData = tree._metaData
		local limits = config.get()
		local state = MatchState.new(
			flags, splitStr, strLength, stringIndex, stringIndex, {
				groupCapturesInitStringPositions = {},
				groupCapturesEndStringPositions = {},
				positionCaptures = {},
				outerTreeReference = {},
				rootTree = tree,
				parsedMetaData = parsedMetaData,
				groupNames = parsedMetaData and parsedMetaData.groupNames,
				recursionDepth = 0,
				backtrackSteps = 0,
				maxRecursionDepth = limits.maxRecursionDepth,
				maxBacktrackDepth = limits.maxBacktrackDepth,
			}
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
