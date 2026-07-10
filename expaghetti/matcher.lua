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
local Any = require("./magic/any")
local Literal = require("./magic/literal")
----------------------------------------------------------------------------------------------------
local AST = require("./ast")
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local function canBacktrackNestedQuantifier(quantifier, element)
	local mode = quantifier.mode or "greedy"
	return mode ~= "possessive"
		and AST.elementHasNestedQuantifier(element)
		and not AST.elementInnerQuantifierIsPossessive(element)
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
		return Boundary.match(currentElement, state)
	elseif Balanced.isElement(currentElement) then
		return Balanced.match(currentElement, state)
	elseif Group.isElement(currentElement) then
		return Group.match(currentElement, treeMatcher, state, tree, treeIndex)
	elseif Alternate.isElement(currentElement) then
		return Alternate.match(currentElement, treeMatcher, state, tree, treeIndex)
	elseif CaptureReference.isElement(currentElement) then
		return CaptureReference.match(currentElement, state)
	elseif not currentCharacter then
		return
	elseif Any.isElement(currentElement) then
		return Any.match(currentElement, currentCharacter, state)
	elseif Set.isElement(currentElement) then
		return Set.match(currentElement, currentCharacter)
	elseif Literal.isElement(currentElement) then
		return Literal.match(currentElement, currentCharacter)
	end

	return false
end

local debugCurrentStackFrame
local coreTreeMatcher -- Forward declaration

local function quantifyElement(
	currentElement, currentCharacter, singleElementMatcher,
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
				currentElement, currentCharacter, coreTreeMatcher,
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
			currentCharacter = state:getTargetCharacter(stringIndex)
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

		if state:incrementBacktrack() then
			return
		end

		state:popCapture(currentElement.index or currentElement.name)
		state.metaData.quantifierMaxEnd = occurrenceEnd - 1

		local tempState = state:branch(occurrenceStart, occurrenceStart)
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state:getTargetCharacter(occurrenceStart), coreTreeMatcher,
			tempState, nil, nil
		)

		state.metaData.quantifierMaxEnd = nil

		if not hasMatched then
			break
		end

		endStr = endStr or occurrenceStart
		endStringPositions[lastOccurrence] = endStr
		stringIndex = endStr + 1
		currentCharacter = state:getTargetCharacter(stringIndex)
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

		if state:incrementBacktrack() then
			return false
		end

		state:popCapture(currentElement.index or currentElement.name)
		state.metaData.quantifierMaxEnd = occurrenceEnd - 1

		local tempState = state:branch(occurrenceStart, occurrenceStart)
		hasMatched, iniStr, endStr = singleElementMatcher(
			currentElement, state:getTargetCharacter(occurrenceStart), coreTreeMatcher,
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
		currentCharacter = state:getTargetCharacter(stringIndex)
		lastIniStr, lastEndStr = nil, nil
		extendOccurrenceCollection()
		maximumOccurrencesOfElement = totalOccurrences

		return true
	end

	for occurrence = startOccurrences, endOccurrences, step do
		if occurrence ~= startOccurrences then
			if state:incrementBacktrack() then
				return
			end
		end

		local backtrackOccurrence = occurrence
		while backtrackOccurrence >= minimumOccurrences do
			while true do
				local targetStringIndex = endStringPositions[occurrence]
					or (state.stringIndex - 1)

				local tempState = state:branch(targetStringIndex, state.initialStringIndex)
				hasMatched, iniStr, endStr = coreTreeMatcher(
					tempState, tree, treeIndex
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

coreTreeMatcher = function(
		state, tree, treeIndex
	)

	debugCurrentStackFrame = debugCurrentStackFrame + 1
	local debugCurrentStackFrameStr = "[Stack "..debugCurrentStackFrame.."]: "

	local outerTreeReference = state.metaData.outerTreeReference[tree]
	local outerTree = outerTreeReference and outerTreeReference.tree

	local currentElement, currentCharacter
	local hasQuantifier
	local hasMatched, iniStr, endStr, _, shouldEndThisExecution

	while treeIndex < tree._index do
		treeIndex = treeIndex + 1
		currentElement = tree[treeIndex]

		state.stringIndex = state.stringIndex + 1
		currentCharacter = state:getTargetCharacter(state.stringIndex)

		hasQuantifier = Quantifier.isElement(currentElement)

		if not hasQuantifier then
			hasMatched, iniStr, endStr, _, shouldEndThisExecution = singleElementMatcher(
				currentElement, currentCharacter, coreTreeMatcher,
				state, tree, treeIndex
			)

			-- Groups continue the execution of the previous tree in another stack
			if shouldEndThisExecution then
				return hasMatched, iniStr, endStr, state.metaData
			elseif not hasMatched then
				return
			elseif endStr then
				state.stringIndex = endStr
			end
		else
			return quantifyElement(
				currentElement, currentCharacter, singleElementMatcher,
				state, tree, treeIndex
			)
		end
	end

	if outerTreeReference then
		local groupIndex = tree._groupIndex
		local pushedCapture = false
		if groupIndex then
			state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
			pushedCapture = true
		end

		state.initialStringIndex = outerTreeReference.initialStringIndex

		local hasMatched, oIni, oEnd, oMeta = coreTreeMatcher(
			state,
			outerTreeReference.tree, outerTreeReference.treeIndex
		)

		if not hasMatched and pushedCapture then
			state:popCapture(groupIndex)
		end

		return hasMatched, oIni, oEnd, oMeta
	end

	local groupIndex = tree._groupIndex
	if groupIndex then
		state:recordCapture(groupIndex, state.initialStringIndex + 1, state.stringIndex)
	end

	return true, state.initialStringIndex + 1, state.stringIndex, state.metaData
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
	print('>>>>>>', expr, errorMessage, require("./helpers/pretty-print")(tree, true))
	if not tree then
		return false, errorMessage
	end
	local treeLength = tree._index

	local targetStringChars, targetStringLength = nil, #str
	if flags[ENUM_FLAG_UNICODE] then
		targetStringChars, targetStringLength = splitStringByEachChar(str, true)
	end

	stringIndex = stringIndex or 0

	local hasMatched, iniStr, endStr, matcherMetaData
	while stringIndex <= targetStringLength do
		debugCurrentStackFrame = 0
		
		local state = MatchState.new(
			flags, str, targetStringChars, targetStringLength, stringIndex, stringIndex, tree, tree._metaData
		)
		hasMatched, iniStr, endStr, matcherMetaData = coreTreeMatcher(
			state, tree, 0
		)

		if hasMatched then
			return hasMatched, iniStr, endStr, matcherMetaData
		end

		stringIndex = stringIndex + 1
	end
end

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
