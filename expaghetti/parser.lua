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
			newIndex = Literal.execute(currentCharacter, index, expression, tree)
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
print(parser('a[b]c'))
print(parser('a[^b]c'))
print(parser('a[b-c]d'))
print(parser('a[bc-de]f'))
print(parser('a[bc-d]e'))
print(parser('a[b-cd]e'))
print(parser('a[bc-de-fg]h'))
print(parser('a[^b-c]d'))
print(parser('a[^bc-de]f'))
print(parser('a[^bc-d]e'))
print(parser('a[^b-cd]e'))
print(parser('a[^bc-de-fg]h'))
print(parser('a[-]b'))
print(parser('a[b-]c'))
print(parser('a[-b]c'))
print(parser('a[-b]c'))
print(parser('a[a-b-]c'))
print(parser('a[-a-b]c'))
print(parser('a[-bc-d]e'))
print(parser('a[b-c-d-e-f-g----]h'))

return parser