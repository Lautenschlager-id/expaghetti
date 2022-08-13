local splitStringByEachChar = require("./helpers/string").splitStringByEachChar

local Literal = require("./magic/literal")

local parser = function(expr)
	local expression, expressionLength = splitStringByEachChar(expr)

	local tree = { }

	local index = 1
	while index <= expressionLength do
		local currentCharacter = expression[index]

		index = Literal.execute(currentCharacter, index, expression, tree)
	end

	return tree
end

local print = require("./helpers/pretty-print")
print(parser(''))
print(parser('a'))
print(parser('ab'))
print(parser('abc'))

return parser