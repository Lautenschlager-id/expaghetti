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

		if errorMessage then
			return false, errorMessage
		end

		index = newIndex
	end

	return tree
end

local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('a%ab')) -- valid
print(parser('a%Ub')) -- valid
print(parser('a%U%%wb')) -- valid
print(parser('a%cAb')) -- valid
print(parser('a%c@b')) -- valid
print(parser('a%c[b')) -- valid
print(parser('a%c\xFFb')) -- invalid
print(parser('a%eFFb')) -- invalid
print(parser('a%e0026b')) -- valid
print(parser('a%e0126b')) -- invalid
print(parser('a%e00Fb')) -- valid

return parser