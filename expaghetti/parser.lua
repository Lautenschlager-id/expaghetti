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

	local errorMessage

	while state.index <= state.patternLength do
		local currentIndex = state.index
		local nextIndex, element = state:readElement(currentIndex)
		if not nextIndex then return false, element end

		if element.type then
			state.index = nextIndex
			tree._index = tree._index + 1
			tree[tree._index] = element
		else
			if Set.isToken(element) then
				state.index, errorMessage = Set.parse(state, tree)
			elseif Group.isOpeningToken(element) then
				state.index, errorMessage = Group.parse(state, tree)
			elseif Group.isClosingToken(element) then
				-- assumes hasGroupClosed = false
				if state.isGroup then
					state.hasGroupClosed = true
					break
				else
					errorMessage = errorsEnum.noGroupToClose
				end
			elseif Anchor.isToken(element) then
				state.index = Anchor.parse(state, element, tree)
			elseif Any.isToken(element) then
				state.index = Any.parse(state, tree)
			elseif Alternate.isToken(element) then
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
				state.index, errorMessage = Literal.parse(state, element, tree)
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
