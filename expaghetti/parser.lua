----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local Escaped = require("./magic/escaped")
local Literal = require("./magic/literal")
local Set = require("./magic/set")
local Quantifier = require("./magic/Quantifier")
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
local parser = function(expr)
	local expression, expressionLength = splitStringByEachChar(expr)
	local charactersIndex, charactersList, charactersValueList, boolEscapedList =
		getElementsList(expression, expressionLength)

	if not charactersIndex then
		-- charactersList = error message
		return false, charactersList
	end

	local tree = {
		_index = 0
	}

	local nextIndex, errorMessage
	local index, currentCharacter = 1
	while index <= charactersIndex do
		currentCharacter = charactersList[index]

		if boolEscapedList[index] then
			index = index + 1

			tree._index = tree._index + 1
			tree[tree._index] = currentCharacter
		else
			if Set.is(currentCharacter) then
				index, errorMessage = Set.execute(
					currentCharacter, index, charactersList, charactersValueList, tree)
			else
				index = Literal.execute(currentCharacter, index, charactersList, tree)
			end
		end

		if errorMessage then
			return false, errorMessage
		end

		index, errorMessage = Quantifier.checkForElement(index, charactersList, tree[tree._index])

		if errorMessage then
			return false, errorMessage
		end
	end

	return tree
end
----------------------------------------------------------------------------------------------------
local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('a')) -- valid
print(parser('a+')) -- valid
print(parser('a*')) -- valid
print(parser('a?')) -- valid
print(parser('a%+')) -- valid
print(parser('a%*')) -- valid
print(parser('a%?')) -- valid
print(parser('a+b-c*d?')) -- valid
print(parser('a+[bcd][^e]f?')) -- valid
print(parser('[bcd]+[^e]*[?][ ]?')) -- valid
print(parser('a{')) -- valid (literal)
print(parser('a}')) -- valid (literal)
print(parser('a{}')) -- valid (literal)
print(parser('a{,}')) -- valid (literal)
print(parser('a%{')) -- valid (literal)
print(parser('a{%}')) -- valid (literal)
print(parser('a{%,}')) -- valid (literal)
print(parser('a{1,}')) -- valid (quantifier)
print(parser('a{,1}')) -- valid (quantifier)
print(parser('a{1,1}')) -- valid (quantifier)
print(parser('a{12345,14535}')) -- valid (quantifier)
print(parser('a{-12345,14535}')) -- valid (literal)
print(parser('a{0,0}')) -- valid (literal)
print(parser('a{,0}')) -- valid (literal)
print(parser('a%{1,0}')) -- valid
print(parser('a{1,0}')) -- invalid
print(parser('a{2,1}')) -- invalid
print(parser('[a{1,2}]{3,4}')) -- valid (literal + quantifer)
print(parser('[a{1,2}]{2,1}')) -- invalid
print(parser('[a{1,2}]?{2,1}')) -- valid (literal + quantifier + literal)
print(parser('a++')) -- valid
print(parser('a*+')) -- valid
print(parser('a?+')) -- valid
print(parser('a{13,60}+')) -- valid
print(parser('a+?')) -- valid
print(parser('a*?')) -- valid
print(parser('a??')) -- valid
print(parser('a{13,60}?')) -- valid
print(parser('ba++c')) -- valid
print(parser('ba+?c')) -- valid
print(parser('ba{1,2}+c')) -- valid
print(parser('ba{1,2}?c')) -- valid
print(parser('b[a{1,2}?]??c')) -- valid (literal + quantifier)
print(parser('a+++')) -- invalid
print(parser('a+*+')) -- invalid
print(parser('a+?+')) -- invalid
print(parser('a++?')) -- invalid
print(parser('a+*?')) -- invalid
print(parser('a+??')) -- invalid
print(parser('a+*')) -- invalid
print(parser('a*++')) -- invalid
print(parser('a**+')) -- invalid
print(parser('a*?+')) -- invalid
print(parser('a*+?')) -- invalid
print(parser('a**?')) -- invalid
print(parser('a*??')) -- invalid
print(parser('a**')) -- invalid
print(parser('a?++')) -- invalid
print(parser('a?*+')) -- invalid
print(parser('a??+')) -- invalid
print(parser('a?+?')) -- invalid
print(parser('a?*?')) -- invalid
print(parser('a???')) -- invalid
print(parser('a?*')) -- invalid
print(parser('a++%+')) -- valid
print(parser('a+*%+')) -- invalid
print(parser('a+?%+')) -- valid
print(parser('a++%?')) -- valid
print(parser('a+*%?')) -- invalid
print(parser('a+?%?')) -- valid
print(parser('a+*%')) -- invalid
print(parser('a*+%+')) -- valid
print(parser('a**%+')) -- invalid
print(parser('a*?%+')) -- valid
print(parser('a*+%?')) -- valid
print(parser('a**%?')) -- invalid
print(parser('a*?%?')) -- valid
print(parser('a**%')) -- invalid
print(parser('a?+%+')) -- valid
print(parser('a?*%+')) -- invalid
print(parser('a??%+')) -- valid
print(parser('a?+%?')) -- valid
print(parser('a?*%?')) -- invalid
print(parser('a??%?')) -- valid
print(parser('a?*%')) -- invalid
print(parser('a{1,1}+')) -- valid
print(parser('a{1,1}*')) -- invalid
print(parser('a{1,1}?')) -- valid
print(parser('a{1,1}{1,1}')) -- invalid
print(parser('a{1,1}%{1,1}')) -- valid
print(parser(''))
print(parser('a[b]c')) -- valid
print(parser('a[^b]c')) -- valid
print(parser('a[b-c]d')) -- valid
print(parser('a[bc-de]f')) -- valid
print(parser('a[bc-d]e')) -- valid
print(parser('a[b-cd]e')) -- valid
print(parser('a[bc-de-fg]h')) -- valid
print(parser('a[^b-c]d')) -- valid
print(parser('a[^bc-de]f')) -- valid
print(parser('a[^bc-d]e')) -- valid
print(parser('a[^b-cd]e')) -- valid
print(parser('a[^bc-de-fg]h')) -- valid
print(parser('a[-]b')) -- valid
print(parser('a[b-]c')) -- valid
print(parser('a[-b]c')) -- valid
print(parser('a[a-b-]c')) -- valid
print(parser('a[-a-b]c')) -- valid
print(parser('a[-bc-d]e')) -- valid
print(parser('a[b-c-d-e-f-g----]h')) -- valid
print(parser('a[----b-c-d-e-f-g]h')) -- valid
print(parser('a[-bc-de')) -- invalid
print(parser('a-bc-d]e')) -- valid
print(parser('a[%z]c')) -- invalid
print(parser('a[^%c1]c')) -- valid
print(parser('a[%cA-%cA]d')) -- valid
print(parser('a[z%cA-%cAf]d')) -- valid
print(parser('a[%cA-%cAf]d')) -- valid
print(parser('a[z%cA-%cA]d')) -- valid
print(parser('a[%cA-cB]d')) -- valid
print(parser('a[cA-%c1]d')) -- valid
print(parser('a[%c\xFF]d')) -- invalid
print(parser('a[%e0070]b')) -- valid
print(parser('a[2%e00701]b')) -- valid
print(parser('a[2%eFFFF1]b')) -- invalid
print(parser('a[%e00AA-%e00FF]b')) -- valid
print(parser('a[%c2-%e00FF]b')) -- valid
print(parser('a[a-%e00FF]b')) -- valid
print(parser('a[%e0070-z]b')) -- valid
print(parser('a[-%e00FF]b')) -- valid
print(parser('a[%e00FF-]b')) -- valid

return parser