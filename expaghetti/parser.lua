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
local Group = require("./magic/group/group")
local Literal = require("./magic/literal")
local Quantifier = require("./magic/Quantifier")
local Set = require("./magic/set")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
----------------------------------------------------------------------------------------------------
local ENUM_FLAG_UNICODE = require("./enums/flags").flags.UNICODE
----------------------------------------------------------------------------------------------------
local ParserState = require("./parser_state")

local function parserCore(state)
	local tree = {
		_index = 0
	}

	local stopParsing, errorMessage

	while state.index <= state.patternLength do
		local currentIndex = state.index
		local nextIndex, element = state:readElement(currentIndex)
		if not nextIndex then return false, element end

		if state:isElement(element) then
			state.index = nextIndex
			tree._index = tree._index + 1
			tree[tree._index] = element
		else
			if Set.isToken(element) then
				errorMessage = Set.parse(state, tree)
			elseif Group.isOpeningToken(element) then
				errorMessage = Group.parse(state, tree)
			elseif Group.isClosingToken(element) then
				stopParsing, errorMessage = Group.parseClosing(state)
				if not errorMessage and stopParsing then
					break
				end
			elseif Anchor.isToken(element) then
				errorMessage = Anchor.parse(state, element, tree)
			elseif Any.isToken(element) then
				errorMessage = Any.parse(state, tree)
			elseif Alternate.isToken(element) then
				tree, stopParsing, errorMessage = Alternate.parse(state, tree)
				if not errorMessage and stopParsing then
					break
				end
			else
				errorMessage = Literal.parse(state, element, tree)
			end
		end

		if not errorMessage and tree[tree._index] then
			errorMessage = Quantifier.lookForElementOperation(state, tree[tree._index])
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	if state.isGroup and not state.isAlternate then
		local currentToken = state.patternChars[state.index]
		if not Group.isClosingToken(currentToken) then
			return false, errorsEnum.unterminatedGroup
		end
	end

	return tree
end

function parser(exprOrState, flags)
	local state
	if type(exprOrState) == "table" and exprOrState.index then
		state = exprOrState
	else
		local expr = exprOrState
		flags = flags or { }

		local patternChars, patternLength = splitStringByEachChar(expr, not not flags[ENUM_FLAG_UNICODE])

		state = ParserState.new(
			expr, flags, false, false, 1, patternChars, patternLength,
			nil, true
		)
	end

	local tree, errorMessage = parserCore(state)
	if not tree then
		return false, errorMessage or tree
	end
	
	if not state.isGroup and not state.isAlternate then
		tree._metaData = state.metaData
	end

	return tree
end

ParserState.parser = parser

return parser
