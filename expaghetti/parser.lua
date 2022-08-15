local splitStringByEachChar = require("./helpers/string").splitStringByEachChar

local Literal = require("./magic/literal")
local Set = require("./magic/set")

local parser = function(expr)
	local expression, expressionLength = splitStringByEachChar(expr)

	local tree = {
		_index = 0
	}

	local index = 1
	while index <= expressionLength do
		local currentCharacter = expression[index]

		local newIndex, errorMessage
		if Set.is(currentCharacter) then
			newIndex, errorMessage = Set.execute(currentCharacter, index, expression, tree)
		else
			newIndex, errorMessage = Literal.execute(currentCharacter, index, expression, tree)
		end

		if not newIndex or errorMessage then
			return false, errorMessage
		end

		index = newIndex
	end

	return tree
end

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

return parser