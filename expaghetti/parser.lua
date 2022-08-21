----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local Anchor = require("./magic/anchor")
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
	-- Parameters passed for recursion on (groups)'	parsing
	isGroup, -- Should be true or else it's going to ignore all the next parameters
	index, expression, expressionLength,
	charactersIndex, charactersList, charactersValueList, boolEscapedList,
	metaData)

	local hasGroupClosed
	if not isGroup then
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
	else
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
				index, errorMessage = Group.execute(parser, index, tree, expression,
					expressionLength, charactersIndex, charactersList, charactersValueList,
					boolEscapedList, metaData)
			elseif Group.isClosing(currentCharacter) then
				if isGroup then
					hasGroupClosed = true
					break
				else
					errorMessage = errorsEnum.noGroupToClose
				end
			elseif Anchor.is(currentCharacter) then
				index = Anchor.execute(index, currentCharacter, tree)
			elseif Any.is(currentCharacter) then
				index = Any.execute(index, currentCharacter, tree)
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

	if isGroup and not hasGroupClosed then
		return false, errorsEnum.unterminatedGroup
	end

	return tree, index
end
----------------------------------------------------------------------------------------------------
local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('maçã')) -- valid (not utf8)
print(parser('maçã', {['u']=true})) -- valid (utf8)
print(parser('[çã]+', {['u']=true})) -- valid (utf8)
print(parser('[çã]+')) -- valid (not utf8)

return parser