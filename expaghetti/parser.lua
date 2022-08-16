----------------------------------------------------------------------------------------------------
local splitStringByEachChar = require("./helpers/string").splitStringByEachChar
----------------------------------------------------------------------------------------------------
local Literal = require("./magic/literal")
local Set = require("./magic/set")
local Quantifier = require("./magic/Quantifier")
----------------------------------------------------------------------------------------------------
local parser = function(expr)
	local expression, expressionLength = splitStringByEachChar(expr)

	local tree = {
		_index = 0
	}

	local index, insertedValue, errorMessage = 1

	while index <= expressionLength do
		local currentCharacter = expression[index]

		local newIndex
		if Set.is(currentCharacter) then
			newIndex, insertedValue = Set.execute(currentCharacter, index, expression, tree)
		else
			newIndex, insertedValue = Literal.execute(currentCharacter, index, expression, tree)
		end

		if not newIndex then
			-- insertedValue = error message
			return false, insertedValue
		end

		index, errorMessage = Quantifier.try(newIndex, expression, insertedValue)
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


return parser