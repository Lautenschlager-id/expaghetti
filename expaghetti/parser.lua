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
local getElementsList = function(expression, expressionLength)
	local charactersIndex, charactersList, charactersValueList, boolEscapedList = 0, { }, { }, { }

	local index = 1

	local currentCharacter
	while index <= expressionLength do
		currentCharacter = expression[index]

		charactersIndex = charactersIndex + 1

		if Escaped.is(currentCharacter) then
			index, currentCharacter = Escaped.execute(index, expression)
			if not index then
				-- currentCharacter = error message
				return false, currentCharacter
			end
			boolEscapedList[charactersIndex] = true

			charactersValueList[charactersIndex] = currentCharacter.value
		else
			index = index + 1

			charactersValueList[charactersIndex] = currentCharacter
		end

		charactersList[charactersIndex] = currentCharacter
	end

	return charactersIndex, charactersList, charactersValueList, boolEscapedList
end
----------------------------------------------------------------------------------------------------
local function parser(expr, flags,
	-- At least one should be true or else it's going to ignore all the next parameters
	isGroup, isAlternate,
	-- Parameters passed for recursion parsing
	index, expression, expressionLength,
	charactersIndex, charactersList, charactersValueList, boolEscapedList,
	metaData,
	hasGroupClosed)

	if not (isGroup or isAlternate) then
		flags = flags or { }

		expression, expressionLength = splitStringByEachChar(expr, not not flags[ENUM_FLAG_UNICODE])
		charactersIndex, charactersList, charactersValueList, boolEscapedList =
			getElementsList(expression, expressionLength)

		if not charactersIndex then
			-- charactersList = error message
			return false, charactersList
		end

		-- Data shared for all sub-groups
		metaData = {
			groupNames = { }
		}

		index = 1
		hasGroupClosed = true

	-- If hasGroupClosed is not nil, then it's already inside a loop
	elseif isGroup and hasGroupClosed == nil then
		print(1)
		hasGroupClosed = false
	end

	local tree = {
		_index = 0
	}

	local nextIndex, errorMessage
	local currentCharacter

	while index <= charactersIndex do
		currentCharacter = charactersList[index]

		if boolEscapedList[index] then
			index = index + 1

			tree._index = tree._index + 1
			tree[tree._index] = currentCharacter
		else
			if Set.is(currentCharacter) then
				index, errorMessage = Set.execute(index, charactersList, charactersValueList, tree)
			elseif Group.isOpening(currentCharacter) then
				index, errorMessage = Group.execute(
					parser, index, tree,
					expression, expressionLength,
					charactersIndex, charactersList, charactersValueList, boolEscapedList,
					metaData
				)
			elseif Group.isClosing(currentCharacter) then
				-- assumes hasGroupClosed = false
				if isGroup then
					hasGroupClosed = true
					break
				else
					errorMessage = errorsEnum.noGroupToClose
				end
			elseif Anchor.is(currentCharacter) then
				index = Anchor.execute(index, currentCharacter, tree)
			elseif Any.is(currentCharacter) then
				index = Any.execute(index, tree)
			elseif Alternate.is(currentCharacter) then
				if not isAlternate then
					-- First occurrence
					index, errorMessage, hasGroupClosed = Alternate.execute(
						parser, index, tree,
						expression, expressionLength,
						charactersIndex, charactersList, charactersValueList, boolEscapedList,
						metaData,
						isGroup, hasGroupClosed
					)

					if errorMessage then
						return false, errorMessage
					end

					tree = Alternate.transform(tree)
				end
				-- Whenever found, stop processing the rest of the expression since it's looping
				break
			else
				index, errorMessage = Literal.execute(currentCharacter, index, tree, charactersList)
			end
		end

		if not errorMessage then
			index, errorMessage = Quantifier.checkForElement(index, charactersList,
				tree[tree._index])
		end

		if errorMessage then
			return false, errorMessage
		end
	end

	if isGroup and not hasGroupClosed and not isAlternate then
		return false, errorsEnum.unterminatedGroup
	end

	return tree, index, hasGroupClosed
end
----------------------------------------------------------------------------------------------------
local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('a|b|c)')) -- invalid
print(parser('(a|b|c)')) -- valid
print(parser('(a|b|c|)')) -- valid
print(parser('(|a|b|c|)')) -- valid
print(parser('(||||)')) -- valid
print(parser('|(||||)||')) -- valid
print(parser('|((((|(|(((|||((||(())|))|)))||))|)|))||||||')) -- valid
print(parser('[|((((|(|(((|||((||(())|))|)))||))|)|))||||||]')) -- valid
print(parser('(a(b)|(c|(d|(f|g))))')) -- valid
print(parser('|+')) -- invalid
print(parser('e(a|b|c)f')) -- valid
print(parser('e|(a|b|c)|f')) -- valid
print(parser('e(a|b|c)|f')) -- valid
print(parser('(a|(.)b|.)')) -- valid
print(parser('(aaa%||b)')) -- valid
print(parser('(|+||)|+')) -- invalid
print(parser('(|||)|+')) -- invalid

return parser