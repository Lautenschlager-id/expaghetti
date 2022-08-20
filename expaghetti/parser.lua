----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
local Literal = require("./magic/literal")
local Set = require("./magic/set")
local Group = require("./magic/group")
local Quantifier = require("./magic/Quantifier")
----------------------------------------------------------------------------------------------------
local errorsEnum = require("./enums/errors")
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
local function parser(expr,
	-- Parameters passed for recursion on (groups)'	parsing
	isGroup, -- Should be true or else it's going to ignore all the next parameters
	index, expression, expressionLength,
	charactersIndex, charactersList, charactersValueList, boolEscapedList,
	metaData)

	local hasGroupClosed
	if not isGroup then
		expression, expressionLength = splitStringByEachChar(expr)
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
			else
				index = Literal.execute(currentCharacter, index, tree)
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
		return false, errorsEnum.untermitedGroup
	end

	return tree, index
end
----------------------------------------------------------------------------------------------------
local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('(?:a)')) -- valid
print(parser('(?>a)')) -- valid
print(parser('(?=a)')) -- valid
print(parser('(?!a)')) -- valid
print(parser('(?<=a)')) -- valid
print(parser('(?<!a)')) -- valid
print(parser('(??a)')) -- invalid
print(parser('(?<<a)')) -- invalid
print(parser('(?<!(?!a))')) -- valid
print(parser('(%?<!(?!a))')) -- valid
print(parser('(?<!%(?!a%))')) -- valid
print(parser('(?<oi>xau)')) -- valid
print(parser('(?<>xau)')) -- invalid
print(parser('(?<?>xau)')) -- invalid
print(parser('(?<:()>xau)')) -- invalid
print(parser('(?<abacuiahdysuifsodsfdibvndmclvdnfklmcnkmccvkdfkls>)')) -- valid
print(parser('(?<0a>)')) -- invalid
print(parser('(?<abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$_>)')) -- valid
print(parser('(?<a>((?<a>((?<a>((?<a>((?<a>((?<a>())))))))))))')) -- invalid
print(parser('(?<a>((?<ab>((?<ac>((?<ad>((?<ae>((?<af>(;))))))))))))')) -- valid

return parser