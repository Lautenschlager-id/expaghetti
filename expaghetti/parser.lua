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
local Tokenizer = require("./tokenizer")

local function parserCore(state)
	local tree = {
		_index = 0
	}

	local errorMessage
	local currentCharacter

	while state.index <= state.charactersIndex do
		currentCharacter = state.charactersList[state.index]

		if state.boolEscapedList[state.index] then
			state.index = state.index + 1

			if type(currentCharacter) == "table" and currentCharacter.type == "boundary" then
				local nextChar = state.charactersList[state.index]
				if not state.boolEscapedList[state.index] and Set.isToken(nextChar) then
					state.index, errorMessage = Set.parse(state, tree)
					if errorMessage then return false, errorMessage end
					local parsedSet = tree[tree._index]
					currentCharacter.set = parsedSet
					tree[tree._index] = currentCharacter
				else
					errorMessage = errorsEnum.missingFrontierSet
				end
			else
				tree._index = tree._index + 1
				tree[tree._index] = currentCharacter
			end
		else
			if Set.isToken(currentCharacter) then
				state.index, errorMessage = Set.parse(state, tree)
			elseif Group.isOpeningToken(currentCharacter) then
				state.index, errorMessage = Group.parse(state, tree)
			elseif Group.isClosingToken(currentCharacter) then
				-- assumes hasGroupClosed = false
				if state.isGroup then
					state.hasGroupClosed = true
					break
				else
					errorMessage = errorsEnum.noGroupToClose
				end
			elseif Anchor.isToken(currentCharacter) then
				state.index = Anchor.parse(state, currentCharacter, tree)
			elseif Any.isToken(currentCharacter) then
				state.index = Any.parse(state, tree)
			elseif Alternate.isToken(currentCharacter) then
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
				state.index, errorMessage = Literal.parse(state, currentCharacter, tree)
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
	index, expression, expressionLength,
	tokens,
	metaData,
	hasGroupClosed,
	inheritedFlags)

	if not (isGroup or isAlternate) then
		flags = flags or { }

		expression, expressionLength = splitStringByEachChar(expr, not not flags[ENUM_FLAG_UNICODE])
		local tokensLength
		tokensLength, tokens = Tokenizer.tokenize(expression, expressionLength)

		if not tokensLength then
			return false, tokens
		end

		-- Data shared for all sub-groups
		metaData = {
			groupNames = { },
			groupIndex = 0,
			positionCaptureIndex = 0,
		}

		index = 1
		hasGroupClosed = true

	-- If hasGroupClosed is not nil, then it's already inside a loop
	elseif isGroup and hasGroupClosed == nil then
		hasGroupClosed = false
	end

	local state = ParserState.new(
		expr, inheritedFlags or flags, isGroup, isAlternate, index, expression, expressionLength,
		tokens,
		metaData, hasGroupClosed
	)

	local tree, errorMessage = parserCore(state)
	if not tree then
		return false, errorMessage or tree
	end

	return tree, state.index, state.hasGroupClosed
end

return parser