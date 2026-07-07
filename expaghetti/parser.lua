package.path = package.path
	.. ";./enums/?.lua"
	.. ";./helpers/?.lua"
	.. ";./magic/?.lua"
----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local Anchor = require("./magic/anchor")
local Alternate = require("./magic/alternate")
local Any = require("./magic/any")
local Escaped = require("./magic/escaped")
local Group = require("./magic/group")
local Literal = require("./magic/literal")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").UNICODE
----------------------------------------------------------------------------------------------------
local ParserState = require("./parser_state")

local function parserCore(state)
	local tree = {
		_index = 0
	}

	local errorMessage

	while state.index <= state.patternLength do
		local currentIndex = state.index
		local currentCharacter = state.patternChars[currentIndex]
		local isEscaped = Escaped.isToken(currentCharacter)
		local rawToken = currentCharacter

		if isEscaped then
			local nextIndex, parsedElement = Escaped.parse(currentIndex, state.patternChars)
			if not nextIndex then return false, parsedElement end
			rawToken = parsedElement
			state.index = nextIndex
		end

		if isEscaped then
			if type(rawToken) == "table" and rawToken.type == "boundary" then
				local nextToken = state.patternChars[state.index]
				if nextToken == '[' then
					state.index, errorMessage = Set.parse(state, tree)
					if errorMessage then return false, errorMessage end
					local parsedSet = tree[tree._index]
					rawToken.set = parsedSet
					tree[tree._index] = rawToken
				else
					errorMessage = errorsEnum.missingFrontierSet
				end
			else
				tree._index = tree._index + 1
				tree[tree._index] = rawToken
			end
		else
			if Set.isToken(rawToken) then
				state.index, errorMessage = Set.parse(state, tree)
			elseif Group.isOpeningToken(rawToken) then
				state.index, errorMessage = Group.parse(state, tree)
			elseif Group.isClosingToken(rawToken) then
				-- assumes hasGroupClosed = false
				if state.isGroup then
					state.hasGroupClosed = true
					break
				else
					errorMessage = errorsEnum.noGroupToClose
				end
			elseif Anchor.isToken(rawToken) then
				state.index = Anchor.parse(state, rawToken, tree)
			elseif Any.isToken(rawToken) then
				state.index = Any.parse(state, tree)
			elseif Alternate.isToken(rawToken) then
				if not state.isAlternate then
					-- First occurrence
					state.index, errorMessage, state.hasGroupClosed = Alternate.parse(state, tree)

					if errorMessage then
						return false, errorMessage
					end

					tree = Alternate.transformIntoParsedTrees(tree)
				end
				-- Whenever found, stop processing the rest of the expression since it's looping
				break
			else
				state.index, errorMessage = Literal.parse(state, rawToken, tree)
			end
		end

		if not errorMessage and tree[tree._index] then
			state.index, errorMessage = Quantifier.lookForElementOperation(state, tree[tree._index])
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	if state.isGroup and not state.hasGroupClosed and not state.isAlternate then
		return false, errorsEnum.unterminatedGroup
	end

	return tree
end

function parser(expr, flags,
	-- At least one should be true or else it's going to ignore all the next parameters
	isGroup, isAlternate,
	-- Parameters passed for recursion parsing
	index, patternChars, patternLength,
	metaData,
	hasGroupClosed,
	inheritedFlags,
	isBranchReset)

	if not (isGroup or isAlternate) then
		flags = flags or { }

		patternChars, patternLength = splitStringByEachChar(expr, not not flags[ENUM_FLAG_UNICODE])

		index = 1
		hasGroupClosed = true

	-- If hasGroupClosed is not nil, then it's already inside a loop
	elseif isGroup and hasGroupClosed == nil then
		hasGroupClosed = false
	end

	local state = ParserState.new(
		expr, inheritedFlags or flags, isGroup, isAlternate, index, patternChars, patternLength,
		metaData, hasGroupClosed
	)
	state.isBranchReset = isBranchReset

	local tree, errorMessage = parserCore(state)
	if not tree then
		return false, errorMessage or tree
	end
	
	if not isGroup and not isAlternate then
		tree._metaData = state.metaData
	end

	return tree, state.index, state.hasGroupClosed
end

return parser
